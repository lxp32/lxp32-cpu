/*
 * Copyright (c) 2016 by Alex I. Kuznetsov.
 *
 * Part of the LXP32 CPU IP core.
 *
 * This module declares the members of the Utils namespace.
 */

#ifndef UTILS_H_INCLUDED
#define UTILS_H_INCLUDED

#include <string>
#include <type_traits>

namespace Utils {
	template <typename T> std::string hex(const T &w) {
		static_assert(std::is_integral<T>::value,"Argument must be of integral type");
		const char *hexstr="0123456789ABCDEF";
		std::string res;
		
		res.reserve(sizeof(T)*2);
		
		for(int i=sizeof(T)*8-4;i>=0;i-=4) {
			res.push_back(hexstr[(w>>i)&0x0F]);
		}
		return res;
	}
	
	template <typename T> std::string bin(const T &w) {
		static_assert(std::is_integral<T>::value,"Argument must be of integral type");
		std::string res;
		
		res.reserve(sizeof(T)*8);
		
		for(int i=sizeof(T)*8-1;i>=0;i--) {
			if(((w>>i)&1)!=0) res.push_back('1');
			else res.push_back('0');
		}
		return res;
	}
	
	std::string urlEncode(const std::string &str);
	std::string urlDecode(const std::string &str);
	
	std::string normalizeSeparators(const std::string &path);
	std::string nativeSeparators(const std::string &path);
	bool isAbsolutePath(const std::string &path);
	bool fileExists(const std::string &path);
	std::string relativePath(const std::string &from,const std::string &to);
	
	std::string dequoteString(const std::string &str);
	
	bool ishexdigit(char ch);
	bool isoctdigit(char ch);
	
	template <typename T> bool isPowerOf2(const T &x) {
		static_assert(std::is_integral<T>::value,"Argument must be of integral type");
		return (x!=0)&&((x&(x-1))==0);
	}
}

#endif
