/*
 * Copyright (c) 2016 by Alex I. Kuznetsov.
 *
 * Part of the LXP32 CPU IP core.
 *
 * This module defines the Assembler class which performs
 * compilation of LXP32 assembly source files.
 */

#ifndef ASSEMBLER_H_INCLUDED
#define ASSEMBLER_H_INCLUDED

#include "linkableobject.h"

#include <vector>
#include <map>
#include <string>
#include <cstdint>

class Assembler {
	typedef std::vector<std::string> TokenList;
	typedef std::int_least64_t Integer;
	enum LexerState {
		Initial,
		Word,
		StringLiteral,
		BlockComment
	};
	struct Operand {
		enum Type {Null,Register,Identifier,NumericLiteral};
		Type type=Null;
		std::string str;
		Integer i=0;
		std::uint8_t reg=0;
	};
	
	LinkableObject _obj;
	std::map<std::string,TokenList> _macros;
	LexerState _state;
	int _line;
	std::vector<std::string> _currentLabels;
	std::string _currentFileName;
	std::vector<std::string> _includeSearchDirs;
	std::vector<std::string> _exportedSymbols;
public:
	void processFile(const std::string &filename);
	
	void addIncludeSearchDir(const std::string &dir);
	
	int line() const;
	std::string currentFileName() const;
	
	LinkableObject &object();
	const LinkableObject &object() const;
private:
	void processFileRecursive(const std::string &filename);
	TokenList tokenize(const std::string &str);
	void expand(TokenList &list);
	void elaborate(TokenList &list);
	
	void elaborateDirective(TokenList &list);
	LinkableObject::Word elaborateDataDefinition(TokenList &list);
	LinkableObject::Word elaborateInstruction(TokenList &list);
	
	static bool validateIdentifier(const std::string &str);
	static Integer numericLiteral(const std::string &str);
	static std::vector<Operand> getOperands(const TokenList &list);
	
// LXP32 instructions
	void encodeDstOperand(LinkableObject::Word &word,const Operand &arg);
	void encodeRd1Operand(LinkableObject::Word &word,const Operand &arg);
	void encodeRd2Operand(LinkableObject::Word &word,const Operand &arg);
	
	void encodeAdd(const TokenList &list);
	void encodeAnd(const TokenList &list);
	void encodeCall(const TokenList &list);
	void encodeCjmpxx(const TokenList &list);
	void encodeDivs(const TokenList &list);
	void encodeDivu(const TokenList &list);
	void encodeHlt(const TokenList &list);
	void encodeJmp(const TokenList &list);
	void encodeIret(const TokenList &list);
	void encodeLc(const TokenList &list);
	void encodeLcs(const TokenList &list);
	void encodeLsb(const TokenList &list);
	void encodeLub(const TokenList &list);
	void encodeLw(const TokenList &list);
	void encodeMods(const TokenList &list);
	void encodeModu(const TokenList &list);
	void encodeMov(const TokenList &list);
	void encodeMul(const TokenList &list);
	void encodeNeg(const TokenList &list);
	void encodeNop(const TokenList &list);
	void encodeNot(const TokenList &list);
	void encodeOr(const TokenList &list);
	void encodeRet(const TokenList &list);
	void encodeSb(const TokenList &list);
	void encodeSl(const TokenList &list);
	void encodeSrs(const TokenList &list);
	void encodeSru(const TokenList &list);
	void encodeSub(const TokenList &list);
	void encodeSw(const TokenList &list);
	void encodeXor(const TokenList &list);
};

#endif
