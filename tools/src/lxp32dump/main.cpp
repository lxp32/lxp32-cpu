/*
 * Copyright (c) 2016 by Alex I. Kuznetsov.
 *
 * Part of the LXP32 CPU IP core.
 *
 * Main translation unit for the LXP32 disassembler.
 */

#ifdef _MSC_VER
	#define _CRT_SECURE_NO_WARNINGS
#endif

#include "disassembler.h"

#include <iostream>
#include <fstream>
#include <string>
#include <stdexcept>
#include <cstring>
#include <cstdlib>
#include <cstdio>
#include <ctime>

static void displayUsage(std::ostream &os,const char *program) {
	os<<std::endl;
	os<<"Usage:"<<std::endl;
	os<<"    "<<program<<" [ option(s) | input file ]"<<std::endl<<std::endl;
	
	os<<"Options:"<<std::endl;
	os<<"    -b <addr>    Base address (for comments only)"<<std::endl;
	os<<"    -f <fmt>     Input format (bin, textio, dec, hex), default: autodetect"<<std::endl;
	os<<"    -h, --help   Display a short help message"<<std::endl;
	os<<"    -na          Do not use instruction and register aliases"<<std::endl;
	os<<"    -o <file>    Output file name, default: standard output"<<std::endl;
	os<<"    --           Do not interpret subsequent arguments as options"<<std::endl;
}

static Disassembler::Format detectInputFormat(std::istream &in) {
	static const std::size_t Size=256;
	static const char *textio="01\r\n \t";
	static const char *dec="0123456789\r\n \t";
	static const char *hex="0123456789ABCDEFabcdef\r\n \t";
	
	char buf[Size];
	in.read(buf,Size);
	auto s=static_cast<std::size_t>(in.gcount());
	in.clear();
	in.seekg(0);
	
	Disassembler::Format fmt=Disassembler::Textio;
	
	for(std::size_t i=0;i<s;i++) {
		if(fmt==Disassembler::Textio&&!strchr(textio,buf[i])) fmt=Disassembler::Dec;
		if(fmt==Disassembler::Dec&&!strchr(dec,buf[i])) fmt=Disassembler::Hex;
		if(fmt==Disassembler::Hex&&!strchr(hex,buf[i])) {
			fmt=Disassembler::Bin;
			break;
		}
	}
	
	return fmt;
}

int main(int argc,char *argv[]) try {
	std::string inputFileName,outputFileName;
	
	std::cerr<<"LXP32 Platform Disassembler"<<std::endl;
	std::cerr<<"Copyright (c) 2016-2019 by Alex I. Kuznetsov"<<std::endl;
	
	Disassembler::Format fmt=Disassembler::Bin;
	bool noMoreOptions=false;
	bool formatSpecified=false;
	Disassembler::Word base=0;
	bool noAliases=false;
	
	if(argc<=1) {
		displayUsage(std::cout,argv[0]);
		return 0;
	}
	
	for(int i=1;i<argc;i++) {
		if(argv[i][0]!='-'||noMoreOptions) {
			if(inputFileName.empty()) inputFileName=argv[i];
			else throw std::runtime_error("Only one input file name can be specified");
		}
		else if(!strcmp(argv[i],"--")) noMoreOptions=true;
		else if(!strcmp(argv[i],"-b")) {
			if(++i==argc) {
				displayUsage(std::cerr,argv[0]);
				return EXIT_FAILURE;
			}
			try {
				base=std::stoul(argv[i],nullptr,0);
				if(base%4!=0) throw std::exception();
			}
			catch(std::exception &) {
				throw std::runtime_error("Invalid base address");
			}
		}
		else if(!strcmp(argv[i],"-f")) {
			if(++i==argc) {
				displayUsage(std::cerr,argv[0]);
				return EXIT_FAILURE;
			}
			if(!strcmp(argv[i],"bin")) fmt=Disassembler::Bin;
			else if(!strcmp(argv[i],"textio")) fmt=Disassembler::Textio;
			else if(!strcmp(argv[i],"dec")) fmt=Disassembler::Dec;
			else if(!strcmp(argv[i],"hex")) fmt=Disassembler::Hex;
			else throw std::runtime_error("Unrecognized input format");
			formatSpecified=true;
		}
		else if(!strcmp(argv[i],"-h")||!strcmp(argv[i],"--help")) {
			displayUsage(std::cout,argv[0]);
			return 0;
		}
		else if(!strcmp(argv[i],"-na")) {
			noAliases=true;
		}
		else if(!strcmp(argv[i],"-o")) {
			if(++i==argc) {
				displayUsage(std::cerr,argv[0]);
				return EXIT_FAILURE;
			}
			outputFileName=argv[i];
		}
		else throw std::runtime_error(std::string("Unrecognized option: \"")+argv[i]+"\"");
	}
	
	if(!formatSpecified) { // auto-detect input file format
		std::ifstream in(inputFileName,std::ios_base::in|std::ios_base::binary);
		fmt=detectInputFormat(in);
	}
	
	std::ifstream in;
	
	if(fmt==Disassembler::Bin) in.open(inputFileName,std::ios_base::in|std::ios_base::binary);
	else in.open(inputFileName,std::ios_base::in);
	if(!in) throw std::runtime_error("Cannot open \""+inputFileName+"\"");
	
	std::ofstream out;
	std::ostream *os=&std::cout;
	if(!outputFileName.empty()) {
		out.open(outputFileName,std::ios_base::out);
		if(!out) throw std::runtime_error("Cannot open \""+outputFileName+"\"");
		os=&out;
	}
	
	auto t=std::time(NULL);
	char szTime[256];
	auto r=std::strftime(szTime,256,"%c",std::localtime(&t));
	if(r==0) szTime[0]='\0';
	
	*os<<"/*"<<std::endl;
	*os<<" * Input file: "<<inputFileName<<std::endl;
	*os<<" * Input format: ";
	
	switch(fmt) {
	case Disassembler::Bin:
		*os<<"bin";
		break;
	case Disassembler::Textio:
		*os<<"textio";
		break;
	case Disassembler::Dec:
		*os<<"dec";
		break;
	case Disassembler::Hex:
		*os<<"hex";
		break;
	default:
		break;
	}
	
	if(!formatSpecified) *os<<" (autodetected)";
	*os<<std::endl;
	*os<<" * Base address: 0x"<<Disassembler::hex(base)<<std::endl;
	*os<<" * Disassembled by lxp32dump at "<<szTime<<std::endl;
	*os<<" */"<<std::endl<<std::endl;
	
	Disassembler disasm(in,*os);
	disasm.setFormat(fmt);
	disasm.setBase(base);
	disasm.setPreferAliases(!noAliases);
	
	try {
		disasm.dump();
	}
	catch(std::exception &) {
		if(!outputFileName.empty()) {
			out.close();
			std::remove(outputFileName.c_str());
		}
		throw;
	}
}
catch(std::exception &ex) {
	std::cerr<<"Error: "<<ex.what()<<std::endl;
	return EXIT_FAILURE;
}
