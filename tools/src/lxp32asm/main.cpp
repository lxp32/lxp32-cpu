/*
 * Copyright (c) 2016 by Alex I. Kuznetsov.
 *
 * Part of the LXP32 CPU IP core.
 *
 * Main translation unit for the LXP32 assembler/linker.
 */

#include "assembler.h"
#include "linker.h"
#include "utils.h"

#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <exception>
#include <utility>
#include <memory>
#include <cstdlib>
#include <cstring>
#include <cassert>

struct Options {
	enum OutputFormat {Bin,Textio,Dec,Hex};
	
	bool compileOnly=false;
	std::string outputFileName;
	std::string mapFileName;
	std::vector<std::string> includeSearchDirs;
	LinkableObject::Word base=0;
	std::size_t align=4;
	std::size_t imageSize=0;
	OutputFormat fmt=Bin;
};

static void displayUsage(std::ostream &os,const char *program) {
	os<<std::endl;
	os<<"Usage:"<<std::endl;
	os<<"    "<<program<<" [ option(s) | input file(s) ]"<<std::endl<<std::endl;
	
	os<<"Options:"<<std::endl;
	os<<"    -a <align>   Object alignment (default: 4)"<<std::endl;
	os<<"    -b <addr>    Base address (default: 0)"<<std::endl;
	os<<"    -c           Compile only (don't link)"<<std::endl;
	os<<"    -f <fmt>     Output file format (see below)"<<std::endl;
	os<<"    -h, --help   Display a short help message"<<std::endl;
	os<<"    -i <dir>     Add directory to the list of directories used to search"<<std::endl;
	os<<"                 for included files (multiple directories can be specified)"<<std::endl;
	os<<"    -m <file>    Generate map file"<<std::endl;
	os<<"    -o <file>    Output file name"<<std::endl;
	os<<"    -s <size>    Output image size"<<std::endl;
	os<<"    --           Do not interpret subsequent arguments as options"<<std::endl;
	os<<std::endl;
	os<<"Object alignment must be a power of two and can't be less than 4."<<std::endl;
	os<<"Base address must be a multiple of object alignment."<<std::endl;
	os<<"Image size must be a multiple of 4."<<std::endl;
	os<<std::endl;
	
	os<<"Output file formats:"<<std::endl;
	os<<"    bin          Raw binary image (default)"<<std::endl;
	os<<"    textio       Text representation of binary data. Supported by"<<std::endl;
	os<<"                 std.textio (VHDL) and $readmemb (Verilog)"<<std::endl;
	os<<"    dec          Text format, one word per line (decimal)"<<std::endl;
	os<<"    hex          Text format, one word per line (hexadecimal)"<<std::endl;
}

static bool isLinkableObject(const std::string &filename) {
	static const char *id="LinkableObject";
	static std::size_t idSize=std::strlen(id);
	
	std::ifstream in(filename,std::ios_base::in);
	if(!in) return false;
	if(in.tellg()==static_cast<std::ifstream::pos_type>(-1))
		return false; // the stream is not seekable
	
	std::vector<char> buf(idSize);
	in.read(buf.data(),idSize);
	if(static_cast<std::size_t>(in.gcount())!=idSize) return false;
	if(std::memcmp(buf.data(),id,idSize)) return false;
	return true;
}

int main(int argc,char *argv[]) try {
	std::vector<std::string> inputFiles;
	Options options;
	bool alignmentSpecified=false;
	bool baseSpecified=false;
	bool formatSpecified=false;
	bool noMoreOptions=false;
	
	std::cout<<"LXP32 Platform Assembler and Linker"<<std::endl;
	std::cout<<"Copyright (c) 2016-2019 by Alex I. Kuznetsov"<<std::endl;
	
	if(argc<=1) {
		displayUsage(std::cout,argv[0]);
		return 0;
	}
	
	for(int i=1;i<argc;i++) {
		if(argv[i][0]!='-'||noMoreOptions) inputFiles.push_back(argv[i]);
		else if(!strcmp(argv[i],"--")) noMoreOptions=true;
		else if(!strcmp(argv[i],"-a")) {
			if(++i==argc) {
				displayUsage(std::cerr,argv[0]);
				return EXIT_FAILURE;
			}
			try {
				options.align=std::stoul(argv[i],nullptr,0);
				if(!Utils::isPowerOf2(options.align)) throw std::exception();
				if(options.align<4) throw std::exception();
				alignmentSpecified=true;
			}
			catch(std::exception &) {
				throw std::runtime_error("Invalid object alignment");
			}
		}
		else if(!strcmp(argv[i],"-b")) {
			if(++i==argc) {
				displayUsage(std::cerr,argv[0]);
				return EXIT_FAILURE;
			}
			try {
				options.base=std::stoul(argv[i],nullptr,0);
				baseSpecified=true;
			}
			catch(std::exception &) {
				throw std::runtime_error("Invalid base address");
			}
		}
		else if(!strcmp(argv[i],"-c")) {
			options.compileOnly=true;
		}
		else if(!strcmp(argv[i],"-f")) {
			if(++i==argc) {
				displayUsage(std::cerr,argv[0]);
				return EXIT_FAILURE;
			}
			if(!strcmp(argv[i],"bin")) options.fmt=Options::Bin;
			else if(!strcmp(argv[i],"textio")) options.fmt=Options::Textio;
			else if(!strcmp(argv[i],"dec")) options.fmt=Options::Dec;
			else if(!strcmp(argv[i],"hex")) options.fmt=Options::Hex;
			else throw std::runtime_error("Unrecognized output format");
			formatSpecified=true;
		}
		else if(!strcmp(argv[i],"-h")||!strcmp(argv[i],"--help")) {
			displayUsage(std::cout,argv[0]);
			return 0;
		}
		else if(!strcmp(argv[i],"-i")) {
			if(++i==argc) {
				displayUsage(std::cerr,argv[0]);
				return EXIT_FAILURE;
			}
			options.includeSearchDirs.push_back(argv[i]);
		}
		else if(!strcmp(argv[i],"-m")) {
			if(++i==argc) {
				displayUsage(std::cerr,argv[0]);
				return EXIT_FAILURE;
			}
			options.mapFileName=argv[i];
		}
		else if(!strcmp(argv[i],"-o")) {
			if(++i==argc) {
				displayUsage(std::cerr,argv[0]);
				return EXIT_FAILURE;
			}
			options.outputFileName=argv[i];
		}
		else if(!strcmp(argv[i],"-s")) {
			if(++i==argc) {
				displayUsage(std::cerr,argv[0]);
				return EXIT_FAILURE;
			}
			try {
				options.imageSize=std::stoul(argv[i],nullptr,0);
				if(options.imageSize%4!=0||options.imageSize==0) throw std::exception();
			}
			catch(std::exception &) {
				throw std::runtime_error("Invalid image size");
			}
		}
		else throw std::runtime_error(std::string("Unrecognized option: \"")+argv[i]+"\"");
	}
	
	if(options.base%options.align!=0)
		throw std::runtime_error("Base address must be a multiple of object alignment");
	
	if(options.compileOnly) {
		if(alignmentSpecified)
			std::cerr<<"Warning: Object alignment is ignored in compile-only mode"<<std::endl;
		if(baseSpecified)
			std::cerr<<"Warning: Base address is ignored in compile-only mode"<<std::endl;
		if(formatSpecified)
			std::cerr<<"Warning: Output format is ignored in compile-only mode"<<std::endl;
		if(options.imageSize>0)
			std::cerr<<"Warning: Image size is ignored in compile-only mode"<<std::endl;
		if(!options.mapFileName.empty())
			std::cerr<<"Warning: Map file is not generated in compile-only mode"<<std::endl;
	}
	
	if(inputFiles.empty())
		throw std::runtime_error("No input files were specified");
	
	if(options.compileOnly&&inputFiles.size()>1&&!options.outputFileName.empty())
		throw std::runtime_error("Output file name cannot be specified "
			"for multiple files in compile-only mode");
	
	std::vector<Assembler> assemblers;
	std::vector<LinkableObject> rawObjects;
	
	for(auto const &filename: inputFiles) {
		if(options.compileOnly||!isLinkableObject(filename)) {
			Assembler as;
			for(auto const &dir: options.includeSearchDirs) as.addIncludeSearchDir(dir);
			try {
				as.processFile(filename);
			}
			catch(std::exception &ex) {
				std::cerr<<"Assembler error in "<<as.currentFileName();
				if(as.line()>0) std::cerr<<":"<<as.line();
				std::cerr<<": "<<ex.what()<<std::endl;
				return EXIT_FAILURE;
			}
			if(!options.compileOnly) assemblers.push_back(std::move(as));
			else {
				std::string outputFileName=options.outputFileName;
				if(outputFileName.empty()) {
					outputFileName=filename;
					auto pos=outputFileName.find_last_of('.');
					if(pos!=std::string::npos) outputFileName.erase(pos);
					outputFileName+=".lo";
				}
				as.object().serialize(outputFileName);
			}
		}
		else {
			LinkableObject lo;
			try {
				lo.deserialize(filename);
			}
			catch(std::exception &ex) {
				std::cerr<<"Error reading object file "<<filename<<": "<<ex.what()<<std::endl;
				return EXIT_FAILURE;
			}
			rawObjects.push_back(std::move(lo));
		}
	}
	
	if(options.compileOnly) return 0;
	
	Linker linker;
	for(auto &lo: rawObjects) linker.addObject(lo);
	for(auto &as: assemblers) linker.addObject(as.object());
	linker.setBase(options.base);
	linker.setAlignment(options.align);
	linker.setImageSize(options.imageSize);
	
	std::string outputFileName=options.outputFileName;
	if(outputFileName.empty()) {
		outputFileName=inputFiles[0];
		auto pos=outputFileName.find_last_of('.');
		if(pos!=std::string::npos) outputFileName.erase(pos);
		if(options.fmt==Options::Bin) outputFileName+=".bin";
		else outputFileName+=".txt";
	}
	
	std::unique_ptr<OutputWriter> writer;
	
	switch(options.fmt) {
	case Options::Bin:
		writer=std::unique_ptr<OutputWriter>(new BinaryOutputWriter(outputFileName));
		break;
	case Options::Textio:
		writer=std::unique_ptr<OutputWriter>(new TextOutputWriter(outputFileName,TextOutputWriter::Bin));
		break;
	case Options::Dec:
		writer=std::unique_ptr<OutputWriter>(new TextOutputWriter(outputFileName,TextOutputWriter::Dec));
		break;
	case Options::Hex:
		writer=std::unique_ptr<OutputWriter>(new TextOutputWriter(outputFileName,TextOutputWriter::Hex));
		break;
	default:
		assert(false);
	}
	
	try {
		linker.link(*writer);
	}
	catch(std::exception &ex) {
		writer->abort();
		std::cerr<<"Linker error: "<<ex.what()<<std::endl;
		return EXIT_FAILURE;
	}
	
	std::cout<<writer->size()/4<<" words written"<<std::endl;
	
	if(!options.mapFileName.empty()) {
		std::ofstream out(options.mapFileName);
		if(!out) throw std::runtime_error("Cannot open file \""+options.mapFileName+"\" for writing");
		linker.generateMap(out);
	}
}
catch(std::exception &ex) {
	std::cerr<<"Error: "<<ex.what()<<std::endl;
	return EXIT_FAILURE;
}
