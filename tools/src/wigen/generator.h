/*
 * Copyright (c) 2016 by Alex I. Kuznetsov.
 *
 * Part of the LXP32 CPU IP core.
 *
 * This module defines the Generator class which generates
 * WISHBONE interconnect VHDL description based on provided
 * parameters.
 */

#ifndef GENERATOR_H_INCLUDED
#define GENERATOR_H_INCLUDED

#include "range.h"

#include <iostream>
#include <string>

class Generator {
	int _masters;
	int _slaves;
	int _addrWidth;
	int _slaveAddrWidth;
	int _portSize;
	int _portGranularity;
	
	std::string _entityName;
	bool _pipelinedArbiter;
	bool _registeredFeedback;
	bool _unsafeDecoder;
	
	Range _mastersRange;
	Range _slavesRange;
	Range _addrRange;
	Range _slaveAddrRange;
	Range _slaveDecoderRange;
	Range _dataRange;
	Range _selRange;
	
	bool _fallbackSlave;
	
public:
	Generator();

	void setMasters(int i);
	void setSlaves(int i);
	void setAddrWidth(int i);
	void setSlaveAddrWidth(int i);
	void setPortSize(int i);
	void setPortGranularity(int i);
	void setEntityName(const std::string &str);
	void setPipelinedArbiter(bool b);
	void setRegisteredFeedback(bool b);
	void setUnsafeDecoder(bool b);
	
	int masters() const;
	int slaves() const;
	int addrWidth() const;
	int slaveAddrWidth() const;
	int portSize() const;
	int portGranularity() const;
	std::string entityName() const;
	bool pipelinedArbiter() const;
	bool registeredFeedback() const;
	bool unsafeDecoder() const;
	
	void generate(const std::string &filename);

private:
	void prepare();
	void writeBanner(std::ostream &os);
	void writePreamble(std::ostream &os);
	void writeEntity(std::ostream &os);
	void writeArchitecture(std::ostream &os);
	
	void writeArbiter(std::ostream &os);
	void writeMasterMux(std::ostream &os);
	void writeMasterDemux(std::ostream &os);
	void writeSlaveMux(std::ostream &os);
	void writeSlaveDemux(std::ostream &os);

	static std::string binaryLiteral(int value,int n);	
	static std::string decodedLiteral(int value,int n);
};

#endif
