/*
 * Copyright (c) 2016 by Alex I. Kuznetsov.
 *
 * Part of the LXP32 CPU IP core.
 *
 * This module implements members of the Utils namespace.
 */

#include "utils.h"

#include <iostream>
#include <fstream>
#include <algorithm>
#include <stdexcept>
#include <cstring>

std::string Utils::urlEncode(const std::string &str) {
	std::string res;
	for(std::size_t i=0;i<str.size();i++) {
		char ch=str[i];
		if(ch>='A'&&ch<='Z') res.push_back(ch);
		else if(ch>='a'&&ch<='z') res.push_back(ch);
		else if(ch>='0'&&ch<='9') res.push_back(ch);
		else if(ch=='-'||ch=='_'||ch=='.'||ch=='~') res.push_back(ch);
		else res+="%"+hex(ch);
	}
	return res;
}

std::string Utils::urlDecode(const std::string &str) {
	std::string res;
	for(std::size_t i=0;i<str.size();i++) {
		char ch=str[i];
		if(ch!='%') res.push_back(ch);
		else {
			auto hexcode=str.substr(i+1,2);
			i+=hexcode.size();
			try {
				if(hexcode.size()!=2) throw std::exception();
				auto u=static_cast<unsigned char>(std::stoul(hexcode,nullptr,16));
				res.push_back(static_cast<char>(u));
			}
			catch(std::exception &) {
				throw std::runtime_error("Ill-formed URL-encoded string");
			}
		}
	}
	return res;
}

std::string Utils::normalizeSeparators(const std::string &path) {
	std::string str(path);
#ifdef _WIN32
	std::replace(str.begin(),str.end(),'\\','/');
#endif
	return str;
}

std::string Utils::nativeSeparators(const std::string &path) {
	std::string str(path);
#ifdef _WIN32
	std::replace(str.begin(),str.end(),'/','\\');
#endif
	return str;
}

bool Utils::isAbsolutePath(const std::string &path) {
	auto native=nativeSeparators(path);
	if(native.empty()) return false;
	if(native[0]=='/') return true;
#ifdef _WIN32
	if(native.size()>1&&native[1]==':') return true;
#endif
	return false;
}

bool Utils::fileExists(const std::string &path) {
	std::ifstream in(nativeSeparators(path),std::ios_base::in);
	if(!in) return false;
	return true;
}

std::string Utils::relativePath(const std::string &from,const std::string &to) {
// Normalize directory separators
	auto nfrom=normalizeSeparators(from);
	auto nto=normalizeSeparators(to);
	
	if(nto.empty()) return std::string();
	
// If "nto" is an absolute path, just return it
	if(isAbsolutePath(nto)) return nativeSeparators(nto);

// Process relative path
	auto pos=nfrom.find_last_of('/');
	if(pos==std::string::npos) return nativeSeparators(nto);
	else return nativeSeparators(nfrom.substr(0,pos+1)+nto);
}

std::string Utils::dequoteString(const std::string &str) {
	if(str.size()<2) throw std::runtime_error("String literal expected");
	if(str.front()!='\"'||str.back()!='\"') throw std::runtime_error("String literal expected");
	return str.substr(1,str.size()-2);
}

bool Utils::ishexdigit(char ch) {
	static const char *digits="0123456789ABCDEFabcdef";
	return (std::strchr(digits,ch)!=NULL);
}

bool Utils::isoctdigit(char ch) {
	static const char *digits="01234567";
	return (std::strchr(digits,ch)!=NULL);
}
