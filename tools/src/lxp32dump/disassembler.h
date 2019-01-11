/*
 * Copyright (c) 2016 by Alex I. Kuznetsov.
 *
 * Part of the LXP32 CPU IP core.
 *
 * This module defines the Disassembler class which disassembles
 * LXP32 executable code.
 */

#ifndef DISASSEMBLER_H_INCLUDED
#define DISASSEMBLER_H_INCLUDED

#include <iostream>
#include <type_traits>
#include <cstdint>

class Disassembler {
public:
	enum Format {Bin,Textio,Dec,Hex};
	typedef std::uint32_t Word;
private:
	class Operand {
	public:
		enum Type {Register,Direct};
	private:
		Type _type;
		int _value;
	public:
		Operand(Type t,int value);
		Type type() const;
		int value() const;
	};
	
	std::istream &_is;
	std::ostream &_os;
	Format _fmt;
	bool _preferAliases;
	int _lineNumber;
	Word _pos;
public:
	Disassembler(std::istream &is,std::ostream &os);
	void setFormat(Format fmt);
	void setBase(Word base);
	void setPreferAliases(bool b);
	void dump();
	
	template <typename T> static std::string hex(const T &w) {
		static_assert(std::is_integral<T>::value,"Argument must be of integral type");
		const char *hexstr="0123456789ABCDEF";
		std::string res;
		
		res.reserve(sizeof(T)*2);
		
		for(int i=sizeof(T)*8-4;i>=0;i-=4) {
			res.push_back(hexstr[(w>>i)&0x0F]);
		}
		return res;
	}
private:
	bool getWord(Word &w);
	std::string str(const Operand &op);
	static Operand decodeRd1Operand(Word w);
	static Operand decodeRd2Operand(Word w);
	static Operand decodeDstOperand(Word w);
	
	std::string decodeSimpleInstruction(const std::string &op,Word w);
	std::string decodeAdd(Word w);
	std::string decodeAnd(Word w);
	std::string decodeCall(Word w);
	std::string decodeCjmpxx(Word w);
	std::string decodeDivs(Word w);
	std::string decodeDivu(Word w);
	std::string decodeHlt(Word w);
	std::string decodeJmp(Word w);
	std::string decodeLc(Word w,bool &valid,Word &operand);
	std::string decodeLcs(Word w);
	std::string decodeLsb(Word w);
	std::string decodeLub(Word w);
	std::string decodeLw(Word w);
	std::string decodeMods(Word w);
	std::string decodeModu(Word w);
	std::string decodeMul(Word w);
	std::string decodeNop(Word w);
	std::string decodeOr(Word w);
	std::string decodeSb(Word w);
	std::string decodeSl(Word w);
	std::string decodeSrs(Word w);
	std::string decodeSru(Word w);
	std::string decodeSub(Word w);
	std::string decodeSw(Word w);
	std::string decodeXor(Word w);
	std::string decodeWord(Word w);
};

#endif
