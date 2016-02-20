/*
 * Copyright (c) 2016 by Alex I. Kuznetsov.
 *
 * Part of the LXP32 CPU IP core.
 *
 * This module implements members of the Range class.
 */

#include "range.h"

#include <stdexcept>

Range::Range(): _valid(false) {}

Range::Range(int h,int l): _high(h),_low(l),_valid(true) {
	if(l>h) throw std::runtime_error("Invalid range");
}

void Range::assign(int h,int l) {
	if(l>h) throw std::runtime_error("Invalid range");
	_high=h;
	_low=l;
	_valid=true;
}

void Range::clear() {
	_valid=false;
}

bool Range::valid() const {
	return _valid;
}

int Range::high() const {
	if(!_valid) throw std::runtime_error("Invalid range");
	return _high;
}

int Range::low() const {
	if(!_valid) throw std::runtime_error("Invalid range");
	return _low;
}

int Range::length() const {
	if(!_valid) throw std::runtime_error("Invalid range");
	return _high-_low+1;
}

std::string Range::toString() const {
	if(!_valid) throw std::runtime_error("Invalid range");
	return std::to_string(_high)+" downto "+std::to_string(_low);
}
