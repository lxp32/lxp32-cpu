/*
 * Copyright (c) 2016 by Alex I. Kuznetsov.
 *
 * Part of the LXP32 CPU IP core.
 *
 * This module implements members of the LinkableObject class.
 */

#include "linkableobject.h"
#include "utils.h"

#include <iostream>
#include <fstream>
#include <stdexcept>
#include <utility>
#include <cassert>
#include <cstdlib>

std::string LinkableObject::name() const {
	return _name;
}

void LinkableObject::setName(const std::string &str) {
	_name=str;
}

LinkableObject::Word LinkableObject::virtualAddress() const {
	return _virtualAddress;
}

void LinkableObject::setVirtualAddress(Word addr) {
	_virtualAddress=addr;
}

LinkableObject::Byte *LinkableObject::code() {
	return _code.data();
}

const LinkableObject::Byte *LinkableObject::code() const {
	return _code.data();
}

std::size_t LinkableObject::codeSize() const {
	return _code.size();
}

LinkableObject::Word LinkableObject::addWord(Word w) {
	auto rva=addPadding(sizeof(Word));
// Note: this code doesn't depend on host machine's endianness
	_code.push_back(static_cast<Byte>(w));
	_code.push_back(static_cast<Byte>(w>>8));
	_code.push_back(static_cast<Byte>(w>>16));
	_code.push_back(static_cast<Byte>(w>>24));
	return rva;
}

LinkableObject::Word LinkableObject::addByte(Byte b) {
	auto rva=static_cast<LinkableObject::Word>(_code.size());
	_code.push_back(b);
	return rva;
}

LinkableObject::Word LinkableObject::addBytes(const Byte *p,std::size_t n) {
	auto rva=static_cast<LinkableObject::Word>(_code.size());
	_code.insert(_code.end(),p,p+n);
	return rva;
}

LinkableObject::Word LinkableObject::addZeros(std::size_t n) {
	auto rva=static_cast<LinkableObject::Word>(_code.size());
	_code.resize(_code.size()+n);
	return rva;
}

LinkableObject::Word LinkableObject::addPadding(std::size_t size) {
	auto padding=(size-_code.size()%size)%size;
	if(padding>0) _code.resize(_code.size()+padding);
	return static_cast<LinkableObject::Word>(_code.size());
}

LinkableObject::Word LinkableObject::getWord(Word rva) const {
	Word w=0;
	if(rva<codeSize()) w|=static_cast<Word>(_code[rva++]);
	if(rva<codeSize()) w|=static_cast<Word>(_code[rva++])<<8;
	if(rva<codeSize()) w|=static_cast<Word>(_code[rva++])<<16;
	if(rva<codeSize()) w|=static_cast<Word>(_code[rva++])<<24;
	return w;
}

void LinkableObject::replaceWord(Word rva,Word value) {
	assert(rva+sizeof(Word)<=codeSize());
// Note: this code doesn't depend on host machine's endianness
	_code[rva++]=static_cast<Byte>(value);
	_code[rva++]=static_cast<Byte>(value>>8);
	_code[rva++]=static_cast<Byte>(value>>16);
	_code[rva++]=static_cast<Byte>(value>>24);
}

void LinkableObject::addSymbol(const std::string &name,Word rva) {
	auto &data=symbol(name);
	if(data.type!=Unknown) throw std::runtime_error("Symbol \""+name+"\" is already defined");
	data.type=Local;
	data.rva=rva;
}

void LinkableObject::addImportedSymbol(const std::string &name) {
	auto &data=symbol(name);
	if(data.type!=Unknown) throw std::runtime_error("Symbol \""+name+"\" is already defined");
	data.type=Imported;
}

void LinkableObject::exportSymbol(const std::string &name) {
	auto it=_symbols.find(name);
	if(it==_symbols.end()||it->second.type==Unknown) throw std::runtime_error("Undefined symbol \""+name+"\"");
	if(it->second.type==Imported) throw std::runtime_error("Symbol \""+name+"\" can't be both imported and exported at the same time");
	if(it->second.type==Exported) throw std::runtime_error("Symbol \""+name+"\" has been already exported");
	it->second.type=Exported;
}

void LinkableObject::addReference(const std::string &symbolName,const Reference &ref) {
	auto &data=symbol(symbolName);
	data.refs.push_back(ref);
}

LinkableObject::SymbolData &LinkableObject::symbol(const std::string &name) {
	return _symbols[name];
}

const LinkableObject::SymbolData &LinkableObject::symbol(const std::string &name) const {
	auto const it=_symbols.find(name);
	if(it==_symbols.end()) throw std::runtime_error("Undefined symbol \""+name+"\"");
	return it->second;
}

const LinkableObject::SymbolTable &LinkableObject::symbols() const {
	return _symbols;
}

void LinkableObject::serialize(const std::string &filename) const {
	std::ofstream out(filename,std::ios_base::out);
	if(!out) throw std::runtime_error("Cannot open \""+filename+"\" for writing");
	
	out<<"LinkableObject"<<std::endl;
	if(!_name.empty()) out<<"Name "<<Utils::urlEncode(_name)<<std::endl;
	out<<"VirtualAddress 0x"<<Utils::hex(_virtualAddress)<<std::endl;
	
	out<<std::endl;
	out<<"Start Code"<<std::endl;
	
	for(Word rva=0;rva<_code.size();rva+=sizeof(Word)) {
		out<<"\t0x"<<Utils::hex(getWord(rva))<<std::endl;
	}
	
	out<<"End Code"<<std::endl;
	
	for(auto const &sym: _symbols) {
		if(sym.second.type==Unknown)
			throw std::runtime_error("Undefined symbol: \""+sym.first+"\"");
		out<<std::endl;
		out<<"Start Symbol"<<std::endl;
		out<<"\tName "<<Utils::urlEncode(sym.first)<<std::endl;
		if(sym.second.type==Local) out<<"\tType Local"<<std::endl;
		else if(sym.second.type==Exported) out<<"\tType Exported"<<std::endl;
		else out<<"\tType Imported"<<std::endl;
		if(sym.second.type!=Imported) out<<"\tRVA 0x"<<Utils::hex(sym.second.rva)<<std::endl;
		for(auto const &ref: sym.second.refs) {
			out<<"\tRef ";
			out<<Utils::urlEncode(ref.source)<<" ";
			out<<ref.line<<" ";
			out<<"0x"<<Utils::hex(ref.rva)<<" ";
			out<<ref.offset<<" ";
			if(ref.type==Regular) out<<"Regular"<<std::endl;
			else if(ref.type==Short) out<<"Short"<<std::endl;
		}
		out<<"End Symbol"<<std::endl;
	}
}

void LinkableObject::deserialize(const std::string &filename) {
	std::ifstream in(filename,std::ios_base::in);
	if(!in) throw std::runtime_error("Cannot open \""+filename+"\"");
	
	operator=(LinkableObject());
	
	std::string line;
	for(;;) {
		if(!std::getline(in,line)) throw std::runtime_error("Bad object format");
		auto tokens=tokenize(line);
		if(tokens.empty()) continue;
		else if(tokens[0]!="LinkableObject") throw std::runtime_error("Bad object format");
		break;
	}
	
	while(std::getline(in,line)) {
		auto tokens=tokenize(line);
		if(tokens.empty()) continue;
		if(tokens.size()<2) throw std::runtime_error("Unexpected end of line");
		else if(tokens[0]=="Name") _name=Utils::urlDecode(tokens[1]);
		else if(tokens[0]=="VirtualAddress") _virtualAddress=std::strtoul(tokens[1].c_str(),NULL,0);
		else if(tokens[0]=="Start") {
			if(tokens[1]=="Code") deserializeCode(in);
			else if(tokens[1]=="Symbol") deserializeSymbol(in);
			else throw std::runtime_error("Unexpected token: \""+tokens[1]+"\"");
		}
		else throw std::runtime_error("Unexpected token: \""+tokens[0]+"\"");
	}
}

/*
 * Private members
 */

void LinkableObject::deserializeCode(std::istream &in) {
	std::string line;
	while(std::getline(in,line)) {
		auto tokens=tokenize(line);
		if(tokens.empty()) continue;
		if(tokens[0]=="End") {
			if(tokens.size()<2) throw std::runtime_error("Unexpected end of line");
			if(tokens[1]=="Code") return;
			throw std::runtime_error("Unexpected token: \""+tokens[1]+"\"");
		}
		auto w=static_cast<Word>(std::strtoul(tokens[0].c_str(),NULL,0));
		addWord(w);
	}
	throw std::runtime_error("Unexpected end of file");
}

void LinkableObject::deserializeSymbol(std::istream &in) {
	std::string line;
	std::string name;
	SymbolData data;
	while(std::getline(in,line)) {
		auto tokens=tokenize(line);
		if(tokens.empty()) continue;
		if(tokens[0]=="End") {
			if(tokens.size()<2) throw std::runtime_error("Unexpected end of line");
			if(tokens[1]=="Symbol") {
				if(name.empty()) throw std::runtime_error("Symbol name is not defined");
				if(data.type==Unknown) throw std::runtime_error("Bad symbol type");
				_symbols.emplace(std::move(name),std::move(data));
				return;
			}
			throw std::runtime_error("Unexpected token: \""+tokens[1]+"\"");
		}
		else if(tokens[0]=="Name") {
			if(tokens.size()<2) throw std::runtime_error("Unexpected end of line");
			name=Utils::urlDecode(tokens[1]);
		}
		else if(tokens[0]=="Type") {
			if(tokens.size()<2) throw std::runtime_error("Unexpected end of line");
			if(tokens[1]=="Local") data.type=Local;
			else if(tokens[1]=="Exported") data.type=Exported;
			else if(tokens[1]=="Imported") data.type=Imported;
			else throw std::runtime_error("Bad symbol type");
		}
		else if(tokens[0]=="RVA") {
			if(tokens.size()<2) throw std::runtime_error("Unexpected end of line");
			data.rva=std::strtoul(tokens[1].c_str(),NULL,0);
		}
		else if(tokens[0]=="Ref") {
			Reference ref;
			if(tokens.size()<4) throw std::runtime_error("Unexpected end of line");
			ref.source=Utils::urlDecode(tokens[1]);
			ref.line=std::strtoul(tokens[2].c_str(),NULL,0);
			ref.rva=std::strtoul(tokens[3].c_str(),NULL,0);
			ref.offset=std::strtoll(tokens[4].c_str(),NULL,0);
			if(tokens[5]=="Regular") ref.type=Regular;
			else if(tokens[5]=="Short") ref.type=Short;
			else throw std::runtime_error("Invalid reference type: \""+tokens[5]+"\"");
			data.refs.push_back(std::move(ref));
		}
	}
	throw std::runtime_error("Unexpected end of file");
}

std::vector<std::string> LinkableObject::tokenize(const std::string &str) {
	std::vector<std::string> tokens;
	for(std::size_t pos=0;;) {
		auto start=str.find_first_not_of(" \t\r\n",pos);
		if(start==std::string::npos) return tokens;
		auto end=str.find_first_of(" \t\r\n",start);
		if(end==std::string::npos) {
			tokens.push_back(str.substr(start));
			return tokens;
		}
		else tokens.push_back(str.substr(start,end-start));
		pos=end;
	}
}
