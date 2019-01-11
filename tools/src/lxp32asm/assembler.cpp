/*
 * Copyright (c) 2016 by Alex I. Kuznetsov.
 *
 * Part of the LXP32 CPU IP core.
 *
 * This module implements members of the Assembler class.
 */

#include "assembler.h"
#include "utils.h"

#include <iostream>
#include <fstream>
#include <sstream>
#include <stdexcept>
#include <utility>
#include <limits>
#include <type_traits>
#include <cctype>
#include <cassert>
#include <cstdlib>

void Assembler::processFile(const std::string &filename) {
	auto nativePath=Utils::normalizeSeparators(filename);
	auto pos=nativePath.find_last_of('/');
	if(pos!=std::string::npos) nativePath=filename.substr(pos+1);
	_obj.setName(nativePath);
	
	_line=0;
	_state=Initial;
	_currentFileName=filename;
	processFileRecursive(filename);

// Examine symbol table
	for(auto const &sym: _obj.symbols()) {
		if(sym.second.type==LinkableObject::Unknown&&!sym.second.refs.empty()) {
			std::ostringstream msg;
			msg<<"Undefined symbol \""+sym.first+"\"";
			msg<<" (referenced from "<<sym.second.refs[0].source;
			msg<<":"<<sym.second.refs[0].line<<")";
			throw std::runtime_error(msg.str());
		}
	}
	
	for(auto const &sym: _exportedSymbols) _obj.exportSymbol(sym);
}

void Assembler::processFileRecursive(const std::string &filename) {
	std::ifstream in(filename,std::ios_base::in);
	if(!in) throw std::runtime_error("Cannot open file \""+filename+"\"");
	
// Process input file line-by-line
	auto savedLine=_line;
	auto savedState=_state;
	auto savedFileName=_currentFileName;
	
	_line=1;
	_state=Initial;
	_currentFileName=filename;
	
	std::string line;
	while(std::getline(in,line)) {
		auto tokens=tokenize(line);
		expand(tokens);
		elaborate(tokens);
		_line++;
	}
	
	if(_state!=Initial) throw std::runtime_error("Unexpected end of file");
	
	_line=savedLine;
	_state=savedState;
	_currentFileName=savedFileName;
	
	if(!_currentLabels.empty())
		throw std::runtime_error("Symbol definition must be followed by an instruction or data definition statement");
}

void Assembler::addIncludeSearchDir(const std::string &dir) {
	auto ndir=Utils::normalizeSeparators(dir);
	if(!ndir.empty()&&ndir.back()!='/') ndir.push_back('/');
	_includeSearchDirs.push_back(std::move(ndir));
}

int Assembler::line() const {
	return _line;
}

std::string Assembler::currentFileName() const {
	return _currentFileName;
}

LinkableObject &Assembler::object() {
	return _obj;
}

const LinkableObject &Assembler::object() const {
	return _obj;
}

Assembler::TokenList Assembler::tokenize(const std::string &str) {
	TokenList tokenList;
	std::string word;
	std::size_t i;
	for(i=0;i<str.size();i++) {
		char ch=str[i];
		switch(_state) {
		case Initial:
			if(ch==' '||ch=='\t'||ch=='\n'||ch=='\r') continue; // skip whitespace
			else if(ch==','||ch==':') { // separator
				tokenList.push_back(std::string(1,ch));
			}
			else if(std::isalnum(ch)||ch=='.'||ch=='#'||ch=='_'||ch=='-'||ch=='+') {
				word=std::string(1,ch);
				_state=Word;
			}
			else if(ch=='\"') {
				word="\"";
				_state=StringLiteral;
			}
			else if(ch=='/') {
				if(++i>=str.size()) throw std::runtime_error("Unexpected end of line");
				ch=str[i];
				if(ch=='/') i=str.size(); // skip the rest of the line
				else if(ch=='*') _state=BlockComment;
				else throw std::runtime_error(std::string("Unexpected character: \"")+ch+"\"");
			}
			else throw std::runtime_error(std::string("Unexpected character: \"")+ch+"\"");
			break;
		case Word:
			if(std::isalnum(ch)||ch=='_'||ch=='@'||ch=='+'||ch=='-') word+=ch;
			else {
				i--;
				_state=Initial;
				tokenList.push_back(std::move(word));
			}
			break;
		case StringLiteral:
			if(ch=='\\') {
				if(++i>=str.size()) throw std::runtime_error("Unexpected end of line");
				ch=str[i];
				if(ch=='\\') word.push_back('\\');
				else if(ch=='\"') word.push_back('\"');
				else if(ch=='\'') word.push_back('\'');
				else if(ch=='t') word.push_back('\t');
				else if(ch=='n') word.push_back('\n');
				else if(ch=='r') word.push_back('\r');
				else if(ch=='x') { // hexadecimal sequence can be 1-2 digit long
					std::string seq;
					if(i+1<str.size()&&Utils::ishexdigit(str[i+1])) seq+=str[i+1];
					if(i+2<str.size()&&Utils::ishexdigit(str[i+2])) seq+=str[i+2];
					if(seq.empty()) throw std::runtime_error("Ill-formed escape sequence");
					try {
						word.push_back(static_cast<char>(std::stoul(seq,nullptr,16)));
					}
					catch(std::exception &) {
						throw std::runtime_error("Ill-formed escape sequence");
					}
					i+=seq.size();
				}
				else if(Utils::isoctdigit(ch)) { // octal sequence can be 1-3 digit long
					std::string seq(1,ch);
					if(i+1<str.size()&&Utils::isoctdigit(str[i+1])) seq+=str[i+1];
					if(i+2<str.size()&&Utils::isoctdigit(str[i+2])) seq+=str[i+2];
					unsigned long value;
					try {
						value=std::stoul(seq,nullptr,8);
					}
					catch(std::exception &) {
						throw std::runtime_error("Ill-formed escape sequence");
					}
					
					if(value>255) throw std::runtime_error("Octal value is out of range");
					word.push_back(static_cast<char>(value));
					
					i+=seq.size()-1;
				}
				else throw std::runtime_error(std::string("Unknown escape sequence: \"\\")+ch+"\"");
			}
			else if(ch=='\"') {
				word.push_back('\"');
				tokenList.push_back(std::move(word));
				_state=Initial;
			}
			else word.push_back(ch);
			break;
		case BlockComment:
			if(ch=='*') {
				if(++i>=str.size()) break;
				ch=str[i];
				if(ch=='/') _state=Initial;
				else i--;
			}
			break;
		}
	}
	
	if(_state==StringLiteral) throw std::runtime_error("Unexpected end of line");
	if(_state==Word) tokenList.push_back(std::move(word)); // store last word
	if(_state!=BlockComment) _state=Initial; // reset state if not in block comment
	
	return tokenList;
}

void Assembler::expand(TokenList &list) {
	TokenList newlist;
// Perform macro substitution
	for(auto &token: list) {
		auto it=_macros.find(token);
// Note: we don't expand a macro identifier in the #define statement
// since that would lead to counter-intuitive results
		if(it==_macros.end()||
			(newlist.size()==1&&newlist[0]=="#define")||
			(newlist.size()==3&&newlist[1]==":"&&newlist[2]=="#define"))
				newlist.push_back(std::move(token));
		else for(auto const &replace: it->second) newlist.push_back(replace);
	}
	list=std::move(newlist);
}

void Assembler::elaborate(TokenList &list) {
	if(list.empty()) return;
	
// Process label (if present)
	if(list.size()>=2&&list[1]==":") {
		if(!validateIdentifier(list[0]))
			throw std::runtime_error("Ill-formed identifier: \""+list[0]+"\"");
		_currentLabels.push_back(std::move(list[0]));
		list.erase(list.begin(),list.begin()+2);
	}
	
	if(list.empty()) return;
	
// Process statement itself
	if(list[0][0]=='#') elaborateDirective(list);
	else {
		LinkableObject::Word rva;
		if(list[0][0]=='.') rva=elaborateDataDefinition(list);
		else rva=elaborateInstruction(list);
		
		for(auto const &label: _currentLabels) {
			_obj.addSymbol(label,rva);
		}
		_currentLabels.clear();
	}
}

void Assembler::elaborateDirective(TokenList &list) {
	assert(!list.empty());
	
	if(list[0]=="#define") {
		if(list.size()<3)
			throw std::runtime_error("Wrong number of tokens in the directive");
		if(_macros.find(list[1])!=_macros.end())
			throw std::runtime_error("Macro \""+list[1]+"\" has been already defined");
		if(!validateIdentifier(list[1]))
			throw std::runtime_error("Ill-formed identifier: \""+list[1]+"\"");
		_macros.emplace(list[1],TokenList(list.begin()+2,list.end()));
	}
	else if(list[0]=="#export") {
		if(list.size()!=2) std::runtime_error("Wrong number of tokens in the directive");
		if(!validateIdentifier(list[1])) throw std::runtime_error("Ill-formed identifier: \""+list[1]+"\"");
		_exportedSymbols.push_back(list[1]);
	}
	else if(list[0]=="#import") {
		if(list.size()!=2) std::runtime_error("Wrong number of tokens in the directive");
		if(!validateIdentifier(list[1])) throw std::runtime_error("Ill-formed identifier: \""+list[1]+"\"");
		_obj.addImportedSymbol(list[1]);
	}
	else if(list[0]=="#include") {
		if(list.size()!=2) std::runtime_error("Wrong number of tokens in the directive");
		auto filename=Utils::dequoteString(list[1]);
		if(Utils::isAbsolutePath(filename)) return processFileRecursive(filename);
		else {
			auto path=Utils::relativePath(currentFileName(),filename);
			if(Utils::fileExists(path)) return processFileRecursive(path);
			else {
				for(auto const &dir: _includeSearchDirs) {
					path=Utils::nativeSeparators(dir+filename);
					if(Utils::fileExists(path)) return processFileRecursive(path);
				}
			}
		}
		throw std::runtime_error("Cannot locate include file \""+filename+"\"");
	}
	else if(list[0]=="#message") {
		if(list.size()!=2) std::runtime_error("Wrong number of tokens in the directive");
		auto msg=Utils::dequoteString(list[1]);
		std::cout<<currentFileName()<<":"<<line()<<": "<<msg<<std::endl;
	}
	else throw std::runtime_error("Unrecognized directive: \""+list[0]+"\"");
}

LinkableObject::Word Assembler::elaborateDataDefinition(TokenList &list) {
	assert(!list.empty());
	
	LinkableObject::Word rva=0;
	
	if(list[0]==".align") {
		if(list.size()>2) throw std::runtime_error("Unexpected token: \""+list[2]+"\"");
		std::size_t align=4;
		if(list.size()>1) align=static_cast<std::size_t>(numericLiteral(list[1]));
		if(!Utils::isPowerOf2(align)) throw std::runtime_error("Alignment must be a power of 2");
		if(align<4) throw std::runtime_error("Alignment must be at least 4");
		rva=_obj.addPadding(align);
	}
	else if(list[0]==".reserve") {
		if(list.size()<2) throw std::runtime_error("Unexpected end of statement");
		else if(list.size()>2) throw std::runtime_error("Unexpected token: \""+list[2]+"\"");
		auto n=static_cast<std::size_t>(numericLiteral(list[1]));
		rva=_obj.addZeros(n);
	}
	else if(list[0]==".word") {
		if(list.size()<2) throw std::runtime_error("Unexpected end of statement");
		for(std::size_t i=1;i<list.size();i++) {
			if(i%2!=0) {
				auto w=static_cast<LinkableObject::Word>(numericLiteral(list[i]));
				auto r=_obj.addWord(w);
				if(i==1) rva=r;
			}
			else {
				if(list[i]!=",") throw std::runtime_error("Comma expected");
				if(i+1==list.size()) throw std::runtime_error("Unexpected end of statement");
			}
		}
	}
	else if(list[0]==".byte") {
		if(list.size()<2) throw std::runtime_error("Unexpected end of statement");
		for(std::size_t i=1;i<list.size();i++) {
			if(i%2!=0) {
				if(list[i].at(0)=='\"') { // string literal
					auto bytes=Utils::dequoteString(list[i]);
					auto r=_obj.addBytes(reinterpret_cast<const LinkableObject::Byte*>
						(bytes.c_str()),bytes.size());
					if(i==1) rva=r;
				}
				else {
					auto n=numericLiteral(list[i]);
					
					if(n>255||n<-128) throw std::runtime_error("\""+list[i]+"\": out of range");
					
					auto b=static_cast<LinkableObject::Byte>(n);
					auto r=_obj.addByte(b);
					if(i==1) rva=r;
				}
			}
			else {
				if(list[i]!=",") throw std::runtime_error("Comma expected");
				if(i+1==list.size()) throw std::runtime_error("Unexpected end of statement");
			}
		}
	}
	else throw std::runtime_error("Unrecognized statement: \""+list[0]+"\"");
	
	return rva;
}

LinkableObject::Word Assembler::elaborateInstruction(TokenList &list) {
	assert(!list.empty());
	auto rva=_obj.addPadding();
	if(list[0]=="add") encodeAdd(list);
	else if(list[0]=="and") encodeAnd(list);
	else if(list[0]=="call") encodeCall(list);
	else if(list[0].substr(0,4)=="cjmp") encodeCjmpxx(list);
	else if(list[0]=="divs") encodeDivs(list);
	else if(list[0]=="divu") encodeDivu(list);
	else if(list[0]=="hlt") encodeHlt(list);
	else if(list[0]=="jmp") encodeJmp(list);
	else if(list[0]=="iret") encodeIret(list);
	else if(list[0]=="lc") encodeLc(list);
	else if(list[0]=="lcs") encodeLcs(list);
	else if(list[0]=="lsb") encodeLsb(list);
	else if(list[0]=="lub") encodeLub(list);
	else if(list[0]=="lw") encodeLw(list);
	else if(list[0]=="mods") encodeMods(list);
	else if(list[0]=="modu") encodeModu(list);
	else if(list[0]=="mov") encodeMov(list);
	else if(list[0]=="mul") encodeMul(list);
	else if(list[0]=="neg") encodeNeg(list);
	else if(list[0]=="nop") encodeNop(list);
	else if(list[0]=="not") encodeNot(list);
	else if(list[0]=="or") encodeOr(list);
	else if(list[0]=="ret") encodeRet(list);
	else if(list[0]=="sb") encodeSb(list);
	else if(list[0]=="sl") encodeSl(list);
	else if(list[0]=="srs") encodeSrs(list);
	else if(list[0]=="sru") encodeSru(list);
	else if(list[0]=="sub") encodeSub(list);
	else if(list[0]=="sw") encodeSw(list);
	else if(list[0]=="xor") encodeXor(list);
	else throw std::runtime_error("Unrecognized instruction: \""+list[0]+"\"");
	return rva;
}

bool Assembler::validateIdentifier(const std::string &str) {
/*
 * Valid identifier must satisfy the following requirements:
 *  1. Must not be empty
 *  2. The first character must be either alphabetic or an underscore
 *  3. Subsequent characters must be either alphanumeric or underscores
 */
	if(str.empty()) return false;
	for(std::size_t i=0;i<str.size();i++) {
		char ch=str[i];
		if(i==0) {
			if(!std::isalpha(ch)&&ch!='_') return false;
		}
		else {
			if(!std::isalnum(ch)&&ch!='_') return false;
		}
	}
	return true;
}

Assembler::Integer Assembler::numericLiteral(const std::string &str) {
	std::size_t pos;
	Integer i;
	try {
		i=std::stoll(str,&pos,0);
	}
	catch(std::exception &) {
		throw std::runtime_error("Ill-formed numeric literal: \""+str+"\"");
	}
	if(pos<str.size()) throw std::runtime_error("Ill-formed numeric literal: \""+str+"\"");
	
	typedef std::make_signed<LinkableObject::Word>::type SignedWord;
	
	if(i>static_cast<Integer>(std::numeric_limits<LinkableObject::Word>::max())||
		i<static_cast<Integer>(std::numeric_limits<SignedWord>::min()))
			throw std::runtime_error("\""+str+"\": out of range");
	
	return i;
}

std::vector<Assembler::Operand> Assembler::getOperands(const TokenList &list) {
	std::vector<Operand> arglist;
	for(std::size_t i=1;i<list.size();i++) {
		if(i%2!=0) {
			Operand a;
			a.str=list[i];
			
			if(!list[i].empty()&&list[i][0]=='r') {
// Is argument a register?
				char *endptr;
				auto regstr=list[i].substr(1);
				auto reg=std::strtol(regstr.c_str(),&endptr,10);
				
				if(!*endptr&&reg>=0&&reg<=255) {
					a.type=Operand::Register;
					a.reg=static_cast<std::uint8_t>(reg);
					arglist.push_back(std::move(a));
					continue;
				}
			}
			
// Try alternative register names
			if(list[i]=="sp") { // stack pointer
				a.type=Operand::Register;
				a.reg=255;
				arglist.push_back(std::move(a));
			}
			else if(list[i]=="rp") { // return pointer
				a.type=Operand::Register;
				a.reg=254;
				arglist.push_back(std::move(a));
			}
			else if(list[i]=="irp") { // interrupt return pointer
				a.type=Operand::Register;
				a.reg=253;
				arglist.push_back(std::move(a));
			}
			else if(list[i]=="cr") { // control register
				a.type=Operand::Register;
				a.reg=252;
				arglist.push_back(std::move(a));
			}
			else if(list[i].size()==3&&list[i].substr(0,2)=="iv"&&
				list[i][2]>='0'&&list[i][2]<='7') // interrupt vector
			{
				a.type=Operand::Register;
				a.reg=240+(list[i][2]-'0');
				arglist.push_back(std::move(a));
			}
			else if(validateIdentifier(list[i])) {
// Is argument an identifier?
				a.type=Operand::Identifier;
				arglist.push_back(std::move(a));
			}
			else {
				auto atpos=list[i].find_first_of('@');
				if(atpos!=std::string::npos) {
// Identifier with an offset?
					a.type=Operand::Identifier;
					a.str=list[i].substr(0,atpos);
					if(!validateIdentifier(a.str)) throw std::runtime_error("Ill-formed identifier");
					a.i=numericLiteral(list[i].substr(atpos+1));
					arglist.push_back(std::move(a));
				}
				else {
// Numeric literal?
					a.type=Operand::NumericLiteral;
					a.i=numericLiteral(list[i]);
					arglist.push_back(std::move(a));
				}
			}
		}
		else {
			if(list[i]!=",") throw std::runtime_error("Comma expected");
			if(i+1==list.size()) throw std::runtime_error("Unexpected end of line");
		}
	}
	return arglist;
}

/*
 * Member functions to encode LXP32 instructions
 */

void Assembler::encodeDstOperand(LinkableObject::Word &word,const Operand &arg) {
	if(arg.type!=Operand::Register)
		throw std::runtime_error("\""+arg.str+"\": must be a register");
	word|=arg.reg<<16;
}

void Assembler::encodeRd1Operand(LinkableObject::Word &word,const Operand &arg) {
	if(arg.type==Operand::Register) {
		word|=0x02000000;
		word|=arg.reg<<8;
	}
	else if(arg.type==Operand::NumericLiteral) {
		if((arg.i<-128||arg.i>127)&&(arg.i<0xFFFFFF80||arg.i>0xFFFFFFFF))
			throw std::runtime_error("\""+arg.str+"\": out of range");
		auto b=static_cast<LinkableObject::Byte>(arg.i);
		word|=b<<8;
	}
	else throw std::runtime_error("\""+arg.str+"\": bad argument");
}

void Assembler::encodeRd2Operand(LinkableObject::Word &word,const Operand &arg) {
	if(arg.type==Operand::Register) {
		word|=0x01000000;
		word|=arg.reg;
	}
	else if(arg.type==Operand::NumericLiteral) {
		if((arg.i<-128||arg.i>127)&&(arg.i<0xFFFFFF80||arg.i>0xFFFFFFFF))
			throw std::runtime_error("\""+arg.str+"\": out of range");
		auto b=static_cast<LinkableObject::Byte>(arg.i);
		word|=b;
	}
	else throw std::runtime_error("\""+arg.str+"\": bad argument");
}

void Assembler::encodeAdd(const TokenList &list) {
	auto args=getOperands(list);
	if(args.size()!=3) throw std::runtime_error("add instruction requires 3 operands");
	LinkableObject::Word w=0x40000000;
	encodeDstOperand(w,args[0]);
	encodeRd1Operand(w,args[1]);
	encodeRd2Operand(w,args[2]);
	_obj.addWord(w);
}

void Assembler::encodeAnd(const TokenList &list) {
	auto args=getOperands(list);
	if(args.size()!=3) throw std::runtime_error("and instruction requires 3 operands");
	LinkableObject::Word w=0x60000000;
	encodeDstOperand(w,args[0]);
	encodeRd1Operand(w,args[1]);
	encodeRd2Operand(w,args[2]);
	_obj.addWord(w);
}

void Assembler::encodeCall(const TokenList &list) {
	auto args=getOperands(list);
	if(args.size()!=1) throw std::runtime_error("call instruction requires 1 operand");
	if(args[0].type!=Operand::Register) throw std::runtime_error("\""+args[0].str+"\": must be a register");
	LinkableObject::Word w=0x86FE0000;
	encodeRd1Operand(w,args[0]);
	_obj.addWord(w);
}

void Assembler::encodeCjmpxx(const TokenList &list) {
	auto args=getOperands(list);
	if(args.size()!=3) throw std::runtime_error("cjmpxx instruction requires 3 operands");
	
	LinkableObject::Word w;
	bool reverse=false;
/*
 * Note: cjmpul, cjmpule, cjmpsl and cjmpsle don't have distinct opcodes;
 * instead, they are aliases for respective "g" or "ge" instructions
 * with reversed operand order.
 */
	if(list[0]=="cjmpe") w=0xE0000000;
	else if(list[0]=="cjmpne") w=0xD0000000;
	else if(list[0]=="cjmpug"||list[0]=="cjmpul") w=0xC8000000;
	else if(list[0]=="cjmpuge"||list[0]=="cjmpule") w=0xE8000000;
	else if(list[0]=="cjmpsg"||list[0]=="cjmpsl") w=0xC4000000;
	else if(list[0]=="cjmpsge"||list[0]=="cjmpsle") w=0xE4000000;
	else throw std::runtime_error("Unrecognized instruction: \""+list[0]+"\"");
	
	if(list[0]=="cjmpul"||list[0]=="cjmpule"||
		list[0]=="cjmpsl"||list[0]=="cjmpsle") reverse=true;
	
	encodeDstOperand(w,args[0]);
	
	if(!reverse) {
		encodeRd1Operand(w,args[1]);
		encodeRd2Operand(w,args[2]);
	}
	else {
		encodeRd1Operand(w,args[2]);
		encodeRd2Operand(w,args[1]);
	}
	_obj.addWord(w);
}

void Assembler::encodeDivs(const TokenList &list) {
	auto args=getOperands(list);
	if(args.size()!=3) throw std::runtime_error("divs instruction requires 3 operands");
	LinkableObject::Word w=0x54000000;
	encodeDstOperand(w,args[0]);
	encodeRd1Operand(w,args[1]);
	encodeRd2Operand(w,args[2]);
	_obj.addWord(w);
}

void Assembler::encodeDivu(const TokenList &list) {
	auto args=getOperands(list);
	if(args.size()!=3) throw std::runtime_error("divu instruction requires 3 operands");
	LinkableObject::Word w=0x50000000;
	encodeDstOperand(w,args[0]);
	encodeRd1Operand(w,args[1]);
	encodeRd2Operand(w,args[2]);
	_obj.addWord(w);
}

void Assembler::encodeHlt(const TokenList &list) {
	auto args=getOperands(list);
	if(!args.empty()) throw std::runtime_error("hlt instruction doesn't take operands");
	_obj.addWord(0x08000000);
}

void Assembler::encodeJmp(const TokenList &list) {
	auto args=getOperands(list);
	if(args.size()!=1) throw std::runtime_error("jmp instruction requires 1 operand");
	if(args[0].type!=Operand::Register) throw std::runtime_error("\""+args[0].str+"\": must be a register");
	LinkableObject::Word w=0x82000000;
	encodeRd1Operand(w,args[0]);
	_obj.addWord(w);
}

void Assembler::encodeIret(const TokenList &list) {
// Note: "iret" is not a real instruction, but an alias for "jmp irp"
	auto args=getOperands(list);
	if(!args.empty()) throw std::runtime_error("iret instruction doesn't take operands");
	_obj.addWord(0x8200FD00);
}

void Assembler::encodeLc(const TokenList &list) {
	auto args=getOperands(list);
	if(args.size()!=2) throw std::runtime_error("lc instruction requires 2 operands");
	
	LinkableObject::Word w=0x04000000;
	encodeDstOperand(w,args[0]);
	_obj.addWord(w);
	
	if(args[1].type==Operand::Identifier) {
		LinkableObject::Reference ref;
		ref.source=currentFileName();
		ref.line=line();
		ref.rva=_obj.addWord(0);
		ref.offset=args[1].i;
		ref.type=LinkableObject::Regular;
		_obj.addReference(args[1].str,ref);
	}
	else if(args[1].type==Operand::NumericLiteral) {
		_obj.addWord(static_cast<LinkableObject::Word>(args[1].i));
	}
	else throw std::runtime_error("\""+args[1].str+"\": bad argument");
}

void Assembler::encodeLcs(const TokenList &list) {
	auto args=getOperands(list);
	if(args.size()!=2) throw std::runtime_error("lcs instruction requires 2 operands");
	
	LinkableObject::Word w=0xA0000000;
	encodeDstOperand(w,args[0]);
	
	if(args[1].type==Operand::NumericLiteral) {
		if((args[1].i<-1048576||args[1].i>1048575)&&(args[1].i<0xFFF00000||args[1].i>0xFFFFFFFF))
			throw std::runtime_error("\""+args[1].str+"\": out of range");
		auto c=static_cast<LinkableObject::Word>(args[1].i)&0x1FFFFF;
		w|=(c&0xFFFF);
		w|=((c<<8)&0x1F000000);
		_obj.addWord(w);
	}
	else if(args[1].type==Operand::Identifier) {
		LinkableObject::Reference ref;
		ref.source=currentFileName();
		ref.line=line();
		ref.rva=_obj.addWord(w);
		ref.offset=args[1].i;
		ref.type=LinkableObject::Short;
		_obj.addReference(args[1].str,ref);
	}
	else throw std::runtime_error("\""+args[1].str+"\": bad argument");
}

void Assembler::encodeLsb(const TokenList &list) {
	auto args=getOperands(list);
	if(args.size()!=2) throw std::runtime_error("lsb instruction requires 2 operands");
	if(args[1].type!=Operand::Register) throw std::runtime_error("\""+args[1].str+"\": must be a register");
	LinkableObject::Word w=0x2E000000;
	encodeDstOperand(w,args[0]);
	encodeRd1Operand(w,args[1]);
	_obj.addWord(w);
}

void Assembler::encodeLub(const TokenList &list) {
	auto args=getOperands(list);
	if(args.size()!=2) throw std::runtime_error("lub instruction requires 2 operands");
	if(args[1].type!=Operand::Register) throw std::runtime_error("\""+args[1].str+"\": must be a register");
	LinkableObject::Word w=0x2A000000;
	encodeDstOperand(w,args[0]);
	encodeRd1Operand(w,args[1]);
	_obj.addWord(w);
}

void Assembler::encodeLw(const TokenList &list) {
	auto args=getOperands(list);
	if(args.size()!=2) throw std::runtime_error("lw instruction requires 2 operands");
	if(args[1].type!=Operand::Register) throw std::runtime_error("\""+args[1].str+"\": must be a register");
	LinkableObject::Word w=0x22000000;
	encodeDstOperand(w,args[0]);
	encodeRd1Operand(w,args[1]);
	_obj.addWord(w);
}

void Assembler::encodeMods(const TokenList &list) {
	auto args=getOperands(list);
	if(args.size()!=3) throw std::runtime_error("mods instruction requires 3 operands");
	LinkableObject::Word w=0x5C000000;
	encodeDstOperand(w,args[0]);
	encodeRd1Operand(w,args[1]);
	encodeRd2Operand(w,args[2]);
	_obj.addWord(w);
}

void Assembler::encodeModu(const TokenList &list) {
	auto args=getOperands(list);
	if(args.size()!=3) throw std::runtime_error("modu instruction requires 3 operands");
	LinkableObject::Word w=0x58000000;
	encodeDstOperand(w,args[0]);
	encodeRd1Operand(w,args[1]);
	encodeRd2Operand(w,args[2]);
	_obj.addWord(w);
}

void Assembler::encodeMov(const TokenList &list) {
// Note: "mov" is not a real instruction, but an alias for "add dst, src, 0"
	auto args=getOperands(list);
	if(args.size()!=2) throw std::runtime_error("mov instruction requires 2 operands");
	LinkableObject::Word w=0x40000000;
	encodeDstOperand(w,args[0]);
	encodeRd1Operand(w,args[1]);
	_obj.addWord(w);
}

void Assembler::encodeMul(const TokenList &list) {
	auto args=getOperands(list);
	if(args.size()!=3) throw std::runtime_error("mul instruction requires 3 operands");
	LinkableObject::Word w=0x48000000;
	encodeDstOperand(w,args[0]);
	encodeRd1Operand(w,args[1]);
	encodeRd2Operand(w,args[2]);
	_obj.addWord(w);
}

void Assembler::encodeNeg(const TokenList &list) {
// Note: "neg" is not a real instruction, but an alias for "sub dst, 0, src"
	auto args=getOperands(list);
	if(args.size()!=2) throw std::runtime_error("neg instruction requires 2 operands");
	LinkableObject::Word w=0x44000000;
	encodeDstOperand(w,args[0]);
	encodeRd2Operand(w,args[1]);
	_obj.addWord(w);
}

void Assembler::encodeNop(const TokenList &list) {
	auto args=getOperands(list);
	if(!args.empty()) throw std::runtime_error("nop instruction doesn't take operands");
	_obj.addWord(0);
}

void Assembler::encodeNot(const TokenList &list) {
// Note: "not" is not a real instruction, but an alias for "xor dst, src, -1"
	auto args=getOperands(list);
	if(args.size()!=2) throw std::runtime_error("not instruction requires 2 operands");
	LinkableObject::Word w=0x680000FF;
	encodeDstOperand(w,args[0]);
	encodeRd1Operand(w,args[1]);
	_obj.addWord(w);
}

void Assembler::encodeOr(const TokenList &list) {
	auto args=getOperands(list);
	if(args.size()!=3) throw std::runtime_error("or instruction requires 3 operands");
	LinkableObject::Word w=0x64000000;
	encodeDstOperand(w,args[0]);
	encodeRd1Operand(w,args[1]);
	encodeRd2Operand(w,args[2]);
	_obj.addWord(w);
}

void Assembler::encodeRet(const TokenList &list) {
// Note: "ret" is not a real instruction, but an alias for "jmp rp"
	auto args=getOperands(list);
	if(!args.empty()) throw std::runtime_error("ret instruction doesn't take operands");
	_obj.addWord(0x8200FE00);
}

void Assembler::encodeSb(const TokenList &list) {
	auto args=getOperands(list);
	if(args.size()!=2) throw std::runtime_error("sb instruction requires 2 operands");
	if(args[0].type!=Operand::Register) throw std::runtime_error("\""+args[0].str+"\": must be a register");
	if(args[1].type==Operand::NumericLiteral) {
// If numeric literal value is between 128 and 255 (inclusive), convert
// it to a signed byte to avoid exception in encodeRd2Operand()
		if(args[1].i>=128&&args[1].i<=255) args[1].i-=256;
	}
	LinkableObject::Word w=0x3A000000;
	encodeRd1Operand(w,args[0]);
	encodeRd2Operand(w,args[1]);
	_obj.addWord(w);
}

void Assembler::encodeSl(const TokenList &list) {
	auto args=getOperands(list);
	if(args.size()!=3) throw std::runtime_error("sl instruction requires 3 operands");
	if(args[2].type==Operand::NumericLiteral&&
		(args[2].i<0||args[2].i>=static_cast<Integer>(8*sizeof(LinkableObject::Word))))
	{
			std::cerr<<currentFileName()<<":"<<line()<<": ";
			std::cerr<<"Warning: Bitwise shift result is undefined when "
			"the second operand is negative or greater than 31"<<std::endl;
	}
	
	LinkableObject::Word w=0x70000000;
	encodeDstOperand(w,args[0]);
	encodeRd1Operand(w,args[1]);
	encodeRd2Operand(w,args[2]);
	_obj.addWord(w);
}

void Assembler::encodeSrs(const TokenList &list) {
	auto args=getOperands(list);
	if(args.size()!=3) throw std::runtime_error("srs instruction requires 3 operands");
	if(args[2].type==Operand::NumericLiteral&&
		(args[2].i<0||args[2].i>=static_cast<Integer>(8*sizeof(LinkableObject::Word))))
	{
			std::cerr<<currentFileName()<<":"<<line()<<": ";
			std::cerr<<"Warning: Bitwise shift result is undefined when "
			"the second operand is negative or greater than 31"<<std::endl;
	}
	
	LinkableObject::Word w=0x7C000000;
	encodeDstOperand(w,args[0]);
	encodeRd1Operand(w,args[1]);
	encodeRd2Operand(w,args[2]);
	_obj.addWord(w);
}

void Assembler::encodeSru(const TokenList &list) {
	auto args=getOperands(list);
	if(args.size()!=3) throw std::runtime_error("sru instruction requires 3 operands");
	if(args[2].type==Operand::NumericLiteral&&
		(args[2].i<0||args[2].i>=static_cast<Integer>(8*sizeof(LinkableObject::Word))))
	{
			std::cerr<<currentFileName()<<":"<<line()<<": ";
			std::cerr<<"Warning: Bitwise shift result is undefined when "
			"the second operand is negative or greater than 31"<<std::endl;
	}
	
	LinkableObject::Word w=0x78000000;
	encodeDstOperand(w,args[0]);
	encodeRd1Operand(w,args[1]);
	encodeRd2Operand(w,args[2]);
	_obj.addWord(w);
}

void Assembler::encodeSub(const TokenList &list) {
	auto args=getOperands(list);
	if(args.size()!=3) throw std::runtime_error("sub instruction requires 3 operands");
	LinkableObject::Word w=0x44000000;
	encodeDstOperand(w,args[0]);
	encodeRd1Operand(w,args[1]);
	encodeRd2Operand(w,args[2]);
	_obj.addWord(w);
}

void Assembler::encodeSw(const TokenList &list) {
	auto args=getOperands(list);
	if(args.size()!=2) throw std::runtime_error("sw instruction requires 2 operands");
	if(args[0].type!=Operand::Register) throw std::runtime_error("\""+args[0].str+"\": must be a register");
	LinkableObject::Word w=0x32000000;
	encodeRd1Operand(w,args[0]);
	encodeRd2Operand(w,args[1]);
	_obj.addWord(w);
}

void Assembler::encodeXor(const TokenList &list) {
	auto args=getOperands(list);
	if(args.size()!=3) throw std::runtime_error("xor instruction requires 3 operands");
	LinkableObject::Word w=0x68000000;
	encodeDstOperand(w,args[0]);
	encodeRd1Operand(w,args[1]);
	encodeRd2Operand(w,args[2]);
	_obj.addWord(w);
}
