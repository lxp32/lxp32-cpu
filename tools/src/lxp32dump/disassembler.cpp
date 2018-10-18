/*
 * Copyright (c) 2016 by Alex I. Kuznetsov.
 *
 * Part of the LXP32 CPU IP core.
 *
 * This module implements members of the Disassembler class.
 */

#include "disassembler.h"

#include <sstream>
#include <stdexcept>

/*
 * Disassembler::Operand class members
 */

Disassembler::Operand::Operand(Type t,int value):
	_type(t),_value(value) {}

Disassembler::Operand::Type Disassembler::Operand::type() const {
	return _type;
}

int Disassembler::Operand::value() const {
	return _value;
}

/*
 * Disassembler class members
 */

Disassembler::Disassembler(std::istream &is,std::ostream &os):
	_is(is),_os(os),_fmt(Bin),_preferAliases(true),_lineNumber(0),_pos(0) {}

void Disassembler::setFormat(Format fmt) {
	_fmt=fmt;
}

void Disassembler::setBase(Word base) {
	_pos=base;
}

void Disassembler::setPreferAliases(bool b) {
	_preferAliases=b;
}

void Disassembler::dump() {
	Word word;
	
	for(;;) {
		auto offset=_pos;
		if(!getWord(word)) break;
		auto opcode=word>>26;
		
		std::string instruction;
		
		bool lcValid=false;
		Word lcOperand;
		
		switch(opcode) {
		case 0x10:
			instruction=decodeAdd(word);
			break;
		case 0x18:
			instruction=decodeAnd(word);
			break;
		case 0x21:
			instruction=decodeCall(word);
			break;
		case 0x15:
			instruction=decodeDivs(word);
			break;
		case 0x14:
			instruction=decodeDivu(word);
			break;
		case 0x02:
			instruction=decodeHlt(word);
			break;
		case 0x20:
			instruction=decodeJmp(word);
			break;
		case 0x01:
			instruction=decodeLc(word,lcValid,lcOperand);
			break;
		case 0x0B:
			instruction=decodeLsb(word);
			break;
		case 0x0A:
			instruction=decodeLub(word);
			break;
		case 0x08:
			instruction=decodeLw(word);
			break;
		case 0x17:
			instruction=decodeMods(word);
			break;
		case 0x16:
			instruction=decodeModu(word);
			break;
		case 0x12:
			instruction=decodeMul(word);
			break;
		case 0x00:
			instruction=decodeNop(word);
			break;
		case 0x19:
			instruction=decodeOr(word);
			break;
		case 0x0E:
			instruction=decodeSb(word);
			break;
		case 0x1C:
			instruction=decodeSl(word);
			break;
		case 0x1F:
			instruction=decodeSrs(word);
			break;
		case 0x1E:
			instruction=decodeSru(word);
			break;
		case 0x11:
			instruction=decodeSub(word);
			break;
		case 0x0C:
			instruction=decodeSw(word);
			break;
		case 0x1A:
			instruction=decodeXor(word);
			break;
		default:
			if((opcode>>4)==0x03) instruction=decodeCjmpxx(word);
			else if((opcode>>3)==0x05) instruction=decodeLcs(word);
			else instruction=decodeWord(word);
		}
		
		auto size=instruction.size();
		std::size_t padding=0;
		if(size<32) padding=32-size;
		
		_os<<'\t'<<instruction<<std::string(padding,' ')<<"// ";
		_os<<hex(offset)<<": "<<hex(word);
		if(lcValid) _os<<' '<<hex(lcOperand);
		_os<<std::endl;
	}
}

bool Disassembler::getWord(Word &w) {
	if(_fmt==Bin) {
		char buf[sizeof(Word)] {}; // zero-initialize
		_is.read(buf,sizeof(Word));
		
		auto n=static_cast<std::size_t>(_is.gcount());
		if(n==0) return false;
		if(n<sizeof(Word)) std::cerr<<"Warning: last word is truncated"<<std::endl;
		
		w=(static_cast<unsigned char>(buf[3])<<24)|(static_cast<unsigned char>(buf[2])<<16)|
			(static_cast<unsigned char>(buf[1])<<8)|static_cast<unsigned char>(buf[0]);
	}
	else {
		try {
			std::string line;
			if(!std::getline(_is,line)) return false;
			_lineNumber++;
			
			if(_fmt==Textio) w=std::stoul(line,nullptr,2);
			else if(_fmt==Dec) w=std::stoul(line,nullptr,10);
			else if(_fmt==Hex) w=std::stoul(line,nullptr,16);
			else return false;
		}
		catch(std::exception &) {
			throw std::runtime_error("Bad literal at line "+std::to_string(_lineNumber));
		}
	}
	_pos+=sizeof(Word);
	return true;
}

std::string Disassembler::str(const Operand &op) {
	if(op.type()==Operand::Register) {
		if(!_preferAliases) return "r"+std::to_string(op.value());
		else if(op.value()>=240&&op.value()<=247) return "iv"+std::to_string(op.value()-240);
		else if(op.value()==252) return "cr";
		else if(op.value()==253) return "irp";
		else if(op.value()==254) return "rp";
		else if(op.value()==255) return "sp";
		else return "r"+std::to_string(op.value());
	}
	else return std::to_string(op.value());
}

Disassembler::Operand Disassembler::decodeRd1Operand(Word w) {
	int value=(w>>8)&0xFF;
	if(w&0x02000000) return Operand(Operand::Register,value);
	else {
		if(value>127) value-=256;
		return Operand(Operand::Direct,value);
	}
}

Disassembler::Operand Disassembler::decodeRd2Operand(Word w) {
	int value=w&0xFF;
	if(w&0x01000000) return Operand(Operand::Register,value);
	else {
		if(value>127) value-=256;
		return Operand(Operand::Direct,value);
	}
}

Disassembler::Operand Disassembler::decodeDstOperand(Word w) {
	int value=(w>>16)&0xFF;
	return Operand(Operand::Register,value);
}

std::string Disassembler::decodeSimpleInstruction(const std::string &op,Word w) {
	std::ostringstream oss;
	auto dst=decodeDstOperand(w);
	auto rd1=decodeRd1Operand(w);
	auto rd2=decodeRd2Operand(w);
	oss<<op<<' '<<str(dst)<<", "<<str(rd1)<<", "<<str(rd2);
	return oss.str();
}

std::string Disassembler::decodeAdd(Word w) {
	std::ostringstream oss;
	
	auto dst=decodeDstOperand(w);
	auto rd1=decodeRd1Operand(w);
	auto rd2=decodeRd2Operand(w);
	
	if(rd2.type()==Operand::Direct&&rd2.value()==0&&_preferAliases)
		oss<<"mov "<<str(dst)<<", "<<str(rd1);
	else
		oss<<"add "<<str(dst)<<", "<<str(rd1)<<", "<<str(rd2);
	
	return oss.str();
}

std::string Disassembler::decodeAnd(Word w) {
	return decodeSimpleInstruction("and",w);
}

std::string Disassembler::decodeCall(Word w) {
	auto dst=decodeDstOperand(w);
	auto rd1=decodeRd1Operand(w);
	auto rd2=decodeRd2Operand(w);
	
	if(dst.value()!=0xFE) return decodeWord(w);
	if(rd1.type()!=Operand::Register) return decodeWord(w);
	if(rd2.type()!=Operand::Direct||rd2.value()!=0) return decodeWord(w);
	
	return "call "+str(rd1);
}

std::string Disassembler::decodeCjmpxx(Word w) {
	auto jumpType=(w>>26)&0x0F;
	std::string op;
	
	switch(jumpType) {
	case 0x8:
		op="cjmpe";
		break;
	case 0x4:
		op="cjmpne";
		break;
	case 0x2:
		op="cjmpug";
		break;
	case 0xA:
		op="cjmpuge";
		break;
	case 0x1:
		op="cjmpsg";
		break;
	case 0x9:
		op="cjmpsge";
		break;
	default:
		return decodeWord(w);
	}
	
	return decodeSimpleInstruction(op,w);
}

std::string Disassembler::decodeDivs(Word w) {
	auto rd2=decodeRd2Operand(w);
	if(rd2.type()==Operand::Direct&&rd2.value()==0) return decodeWord(w);
	return decodeSimpleInstruction("divs",w);
}

std::string Disassembler::decodeDivu(Word w) {
	auto rd2=decodeRd2Operand(w);
	if(rd2.type()==Operand::Direct&&rd2.value()==0) return decodeWord(w);
	return decodeSimpleInstruction("divu",w);
}

std::string Disassembler::decodeHlt(Word w) {
	if(w!=0x08000000) return decodeWord(w);
	return "hlt";
}

std::string Disassembler::decodeJmp(Word w) {
	auto dst=decodeDstOperand(w);
	auto rd1=decodeRd1Operand(w);
	auto rd2=decodeRd2Operand(w);
	
	if(dst.value()!=0) return decodeWord(w);
	if(rd1.type()!=Operand::Register) return decodeWord(w);
	if(rd2.type()!=Operand::Direct||rd2.value()!=0) return decodeWord(w);
	
	if(rd1.value()==253&&_preferAliases) return "iret";
	if(rd1.value()==254&&_preferAliases) return "ret";
	return "jmp "+str(rd1);
}

std::string Disassembler::decodeLc(Word w,bool &valid,Word &operand) {
	auto dst=decodeDstOperand(w);
	auto rd1=decodeRd1Operand(w);
	auto rd2=decodeRd2Operand(w);
	
	valid=false;
	
	if(rd1.type()!=Operand::Direct||rd1.value()!=0) return decodeWord(w);
	if(rd2.type()!=Operand::Direct||rd2.value()!=0) return decodeWord(w);
	
	bool b=getWord(operand);
	if(!b) return decodeWord(w);
	
	valid=true;
	return "lc "+str(dst)+", 0x"+hex(operand);
}

std::string Disassembler::decodeLcs(Word w) {
	auto dst=decodeDstOperand(w);
	auto operand=w&0xFFFF;
	operand|=(w>>8)&0x001F0000;
	if(operand&0x00100000) operand|=0xFFE00000;
	return "lcs "+str(dst)+", 0x"+hex(operand);
}

std::string Disassembler::decodeLsb(Word w) {
	std::ostringstream oss;
	
	auto dst=decodeDstOperand(w);
	auto rd1=decodeRd1Operand(w);
	auto rd2=decodeRd2Operand(w);
	
	if(rd1.type()!=Operand::Register) return decodeWord(w);
	if(rd2.type()!=Operand::Direct||rd2.value()!=0) return decodeWord(w);
	
	return "lsb "+str(dst)+", "+str(rd1);
}

std::string Disassembler::decodeLub(Word w) {
	std::ostringstream oss;
	
	auto dst=decodeDstOperand(w);
	auto rd1=decodeRd1Operand(w);
	auto rd2=decodeRd2Operand(w);
	
	if(rd1.type()!=Operand::Register) return decodeWord(w);
	if(rd2.type()!=Operand::Direct||rd2.value()!=0) return decodeWord(w);
	
	return "lub "+str(dst)+", "+str(rd1);
}

std::string Disassembler::decodeLw(Word w) {
	std::ostringstream oss;
	
	auto dst=decodeDstOperand(w);
	auto rd1=decodeRd1Operand(w);
	auto rd2=decodeRd2Operand(w);
	
	if(rd1.type()!=Operand::Register) return decodeWord(w);
	if(rd2.type()!=Operand::Direct||rd2.value()!=0) return decodeWord(w);
	
	return "lw "+str(dst)+", "+str(rd1);
}

std::string Disassembler::decodeMods(Word w) {
	auto rd2=decodeRd2Operand(w);
	if(rd2.type()==Operand::Direct&&rd2.value()==0) return decodeWord(w);
	return decodeSimpleInstruction("mods",w);
}

std::string Disassembler::decodeModu(Word w) {
	auto rd2=decodeRd2Operand(w);
	if(rd2.type()==Operand::Direct&&rd2.value()==0) return decodeWord(w);
	return decodeSimpleInstruction("modu",w);
}

std::string Disassembler::decodeMul(Word w) {
	return decodeSimpleInstruction("mul",w);
}

std::string Disassembler::decodeNop(Word w) {
	if(w!=0) return decodeWord(w);
	return "nop";
}

std::string Disassembler::decodeOr(Word w) {
	return decodeSimpleInstruction("or",w);
}

std::string Disassembler::decodeSb(Word w) {
	std::ostringstream oss;
	
	auto dst=decodeDstOperand(w);
	auto rd1=decodeRd1Operand(w);
	auto rd2=decodeRd2Operand(w);
	
	if(dst.value()!=0) return decodeWord(w);
	if(rd1.type()!=Operand::Register) return decodeWord(w);
	
	return "sb "+str(rd1)+", "+str(rd2);
}

std::string Disassembler::decodeSl(Word w) {
	auto rd2=decodeRd2Operand(w);
	if(rd2.type()==Operand::Direct&&(rd2.value()<0||rd2.value()>31)) return decodeWord(w);
	return decodeSimpleInstruction("sl",w);
}

std::string Disassembler::decodeSrs(Word w) {
	auto rd2=decodeRd2Operand(w);
	if(rd2.type()==Operand::Direct&&(rd2.value()<0||rd2.value()>31)) return decodeWord(w);
	return decodeSimpleInstruction("srs",w);
}

std::string Disassembler::decodeSru(Word w) {
	auto rd2=decodeRd2Operand(w);
	if(rd2.type()==Operand::Direct&&(rd2.value()<0||rd2.value()>31)) return decodeWord(w);
	return decodeSimpleInstruction("sru",w);
}

std::string Disassembler::decodeSub(Word w) {
	std::ostringstream oss;
	
	auto dst=decodeDstOperand(w);
	auto rd1=decodeRd1Operand(w);
	auto rd2=decodeRd2Operand(w);
	
	if(rd1.type()==Operand::Direct&&rd1.value()==0&&_preferAliases)
		oss<<"neg "<<str(dst)<<", "<<str(rd2);
	else
		oss<<"sub "<<str(dst)<<", "<<str(rd1)<<", "<<str(rd2);
	
	return oss.str();
}

std::string Disassembler::decodeSw(Word w) {
	std::ostringstream oss;
	
	auto dst=decodeDstOperand(w);
	auto rd1=decodeRd1Operand(w);
	auto rd2=decodeRd2Operand(w);
	
	if(dst.value()!=0) return decodeWord(w);
	if(rd1.type()!=Operand::Register) return decodeWord(w);
	
	return "sw "+str(rd1)+", "+str(rd2);
}

std::string Disassembler::decodeXor(Word w) {
	std::ostringstream oss;
	
	auto dst=decodeDstOperand(w);
	auto rd1=decodeRd1Operand(w);
	auto rd2=decodeRd2Operand(w);
	
	if(rd2.type()==Operand::Direct&&rd2.value()==-1&&_preferAliases)
		oss<<"not "<<str(dst)<<", "<<str(rd1);
	else
		oss<<"xor "<<str(dst)<<", "<<str(rd1)<<", "<<str(rd2);
	
	return oss.str();
}

std::string Disassembler::decodeWord(Word w) {
	return ".word 0x"+hex(w);
}
