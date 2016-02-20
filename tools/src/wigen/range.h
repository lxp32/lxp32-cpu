/*
 * Copyright (c) 2016 by Alex I. Kuznetsov.
 *
 * Part of the LXP32 CPU IP core.
 *
 * This module defines the Range class which represents
 * VHDL array ranges.
 */

#ifndef RANGE_H_INCLUDED
#define RANGE_H_INCLUDED

#include <string>

class Range {
	int _high;
	int _low;
	bool _valid;
public:
	Range();
	Range(int h,int l);
	
	void assign(int h,int l);
	void clear();
	
	bool valid() const;
	int high() const;
	int low() const;
	int length() const;
	std::string toString() const;
};

#endif
