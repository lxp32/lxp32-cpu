/*
 * Copyright (c) 2016 by Alex I. Kuznetsov.
 *
 * Part of the LXP32 CPU IP core.
 *
 * This module implements members of the OutputWriter class
 * and its derived classes.
 */

#include "outputwriter.h"
#include "utils.h"

#include <iostream>
#include <iomanip>
#include <stdexcept>
#include <algorithm>
#include <cassert>
#include <cstdint>
#include <cstdio>

/*
 * OutputWriter members
 */

void OutputWriter::write(const char *data,std::size_t n) {
	writeData(data,n);
	_size+=n;
}

void OutputWriter::pad(std::size_t size) {
	static char zeros[256]; // static objects are zero-initialized
	while(size>0) {
		auto n=std::min<std::size_t>(size,256);
		write(zeros,n);
		size-=n;
	}
}

std::size_t OutputWriter::size() const {
	return _size;
}

/*
 * BinaryOutputWriter members
 */

BinaryOutputWriter::BinaryOutputWriter(const std::string &filename):
	_filename(filename),
	_os(filename,std::ios_base::out|std::ios_base::binary)
{
	if(!_os) throw std::runtime_error("Cannot open \""+filename+"\" for writing");
}

void BinaryOutputWriter::writeData(const char *data,std::size_t n) {
	_os.write(data,n);
}

void BinaryOutputWriter::abort() {
	_os.close();
	std::remove(_filename.c_str());
}

/*
 * TextOutputWriter members
 */

TextOutputWriter::TextOutputWriter(const std::string &filename,Format f):
	_filename(filename),
	_os(filename,std::ios_base::out),
	_fmt(f)
{
	if(!_os) throw std::runtime_error("Cannot open \""+filename+"\" for writing");
}

TextOutputWriter::~TextOutputWriter() {
	if(!_buf.empty()) {
		assert(_buf.size()<4);
		pad(4-_buf.size());
	}
}

void TextOutputWriter::writeData(const char *data,std::size_t n) {
	while(n>0) {
		assert(_buf.size()<4);
		auto count=std::min(4-_buf.size(),n);
		_buf.append(data,count);
		data+=count;
		n-=count;
		
		if(_buf.size()<4) continue;
		
		assert(_buf.size()==4);
		
		std::uint32_t word=(static_cast<unsigned char>(_buf[3])<<24)|
			(static_cast<unsigned char>(_buf[2])<<16)|
			(static_cast<unsigned char>(_buf[1])<<8)|
			static_cast<unsigned char>(_buf[0]);
		
		if(_fmt==Bin) _os<<Utils::bin(word)<<std::endl;
		else if(_fmt==Dec) _os<<word<<std::endl;
		else _os<<Utils::hex(word)<<std::endl;
		_buf.clear();
	}
}

void TextOutputWriter::abort() {
	_os.close();
	std::remove(_filename.c_str());
}
