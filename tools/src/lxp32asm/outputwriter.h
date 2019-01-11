/*
 * Copyright (c) 2016 by Alex I. Kuznetsov.
 *
 * Part of the LXP32 CPU IP core.
 *
 * This module defines the OutputWriter abstract class and its
 * derived classes. These classes are used to write LXP32 executable
 * code in different formats.
 */

#ifndef OUTPUTWRITER_H_INCLUDED
#define OUTPUTWRITER_H_INCLUDED

#include <fstream>
#include <string>

/*
 * An abstract base class for all writers
 */

class OutputWriter {
	std::size_t _size=0;
public:
	virtual ~OutputWriter() {}
	virtual void write(const char *data,std::size_t n);
	virtual void abort() {}
	void pad(std::size_t size);
	std::size_t size() const;
protected:
	virtual void writeData(const char *data,std::size_t n)=0;
};

/*
 * Write a regular binary file
 */

class BinaryOutputWriter : public OutputWriter {
	std::string _filename;
	std::ofstream _os;
public:
	BinaryOutputWriter(const std::string &filename);
	virtual void abort() override;
protected:
	virtual void writeData(const char *data,std::size_t n) override;
};

/*
 * Write a text file (one word per line)
 */

class TextOutputWriter : public OutputWriter {
public:
	enum Format {Bin,Dec,Hex};
private:
	std::string _filename;
	std::ofstream _os;
	std::string _buf;
	Format _fmt;
public:
	TextOutputWriter(const std::string &filename,Format f);
	~TextOutputWriter();
	virtual void abort() override;
protected:
	virtual void writeData(const char *data,std::size_t n) override;
};

#endif
