/*
 * Copyright (c) 2016 by Alex I. Kuznetsov.
 *
 * Part of the LXP32 CPU IP core.
 *
 * Main translation unit for the WISHBONE interconnect generator.
 */

#include "generator.h"

#include <iostream>
#include <string>
#include <stdexcept>
#include <cstring>
#include <cstdlib>

static void displayUsage(std::ostream &os,const char *program) {
	os<<std::endl;
	os<<"Usage:"<<std::endl;
	os<<"    "<<program<<" [ option(s) ] <nm> <ns> <ma> <sa> <ps> [ <pg> ]"<<std::endl<<std::endl;
	os<<"    <nm>         Number of masters"<<std::endl;
	os<<"    <ns>         Number of slaves"<<std::endl;
	os<<"    <ma>         Master address width"<<std::endl;
	os<<"    <sa>         Slave address width"<<std::endl;
	os<<"    <ps>         Port size"<<std::endl;
	os<<"    <pg>         Port granularity, default: port size"<<std::endl;
	os<<std::endl;
	
	os<<"Options:"<<std::endl;
	os<<"    -e <entity>  Entity name, default: \"intercon\""<<std::endl;
	os<<"    -h, --help   Display a short help message"<<std::endl;
	os<<"    -o <file>    Output file name, default: \"<entity>.vhd\""<<std::endl;
	os<<"    -p           Generate pipelined arbiter"<<std::endl;
	os<<"    -r           Generate registered feedback signals"<<std::endl;
	os<<"    -u           Generate unsafe slave decoder"<<std::endl;
}

int main(int argc,char *argv[]) try {
	std::cout<<"WISHBONE interconnect generator"<<std::endl;
	std::cout<<"Copyright (c) 2016 by Alex I. Kuznetsov"<<std::endl;
	
	if(argc<=1) {
		displayUsage(std::cout,argv[0]);
		return 0;
	}
	
	Generator gen;
	std::string outputFileName;
	int mainArg=0;
	
	for(int i=1;i<argc;i++) {
		if(argv[i][0]=='-') {
			if(!strcmp(argv[i],"-e")) {
				if(++i==argc) {
					displayUsage(std::cerr,argv[0]);
					return EXIT_FAILURE;
				}
				gen.setEntityName(argv[i]);
			}
			else if(!strcmp(argv[i],"-h")||!strcmp(argv[i],"--help")) {
				displayUsage(std::cout,argv[0]);
				return 0;
			}
			else if(!strcmp(argv[i],"-o")) {
				if(++i==argc) {
					displayUsage(std::cerr,argv[0]);
					return EXIT_FAILURE;
				}
				outputFileName=argv[i];
			}
			else if(!strcmp(argv[i],"-p")) {
				gen.setPipelinedArbiter(true);
			}
			else if(!strcmp(argv[i],"-r")) {
				gen.setRegisteredFeedback(true);
			}
			else if(!strcmp(argv[i],"-u")) {
				gen.setUnsafeDecoder(true);
			}
			else throw std::runtime_error(std::string("Unrecognized option: \"")+argv[i]+"\"");
		}
		else {
			if(mainArg>5) throw std::runtime_error("Too many arguments");
			
			int value;
			
			try {
				value=std::stoi(argv[i],nullptr,0);
			}
			catch(std::exception &) {
				throw std::runtime_error("Invalid value");
			}
			
			switch(mainArg) {
			case 0:
				gen.setMasters(value);
				break;
			case 1:
				gen.setSlaves(value);
				break;
			case 2:
				gen.setAddrWidth(value);
				break;
			case 3:
				gen.setSlaveAddrWidth(value);
				break;
			case 4:
				gen.setPortSize(value);
				break;
			case 5:
				gen.setPortGranularity(value);
				break;
			}
			mainArg++;
		}
	}
	
	if(mainArg<5) throw std::runtime_error("Too few arguments");
	if(mainArg==5) gen.setPortGranularity(gen.portSize());
	
	if(outputFileName.empty()) outputFileName=gen.entityName()+".vhd";
	
	gen.generate(outputFileName);
}
catch(std::exception &ex) {
	std::cerr<<"Error: "<<ex.what()<<std::endl;
	return EXIT_FAILURE;
}
