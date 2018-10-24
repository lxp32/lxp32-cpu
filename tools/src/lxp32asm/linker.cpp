/*
 * Copyright (c) 2016 by Alex I. Kuznetsov.
 *
 * Part of the LXP32 CPU IP core.
 *
 * This module implements members of the Linker class.
 */

#include "linker.h"

#include "linkableobject.h"
#include "utils.h"

#include <iostream>
#include <fstream>
#include <sstream>
#include <map>
#include <stdexcept>
#include <cassert>
#include <algorithm>

void Linker::addObject(LinkableObject &obj) {
	_objects.push_back(&obj);
}

void Linker::link(OutputWriter &writer) {
	if(_objects.empty()) throw std::runtime_error("Object set is empty");
	
// Merge symbol tables
	buildSymbolTable();
	
// Determine entry point
	if(_objects.size()==1) _entryObject=_objects[0];
	else {
		auto const it=_globalSymbolTable.find("entry");
		if(it==_globalSymbolTable.end())
			throw std::runtime_error("Entry point not defined: cannot find \"entry\" symbol");
		if(it->second.rva!=0)
			throw std::runtime_error(it->second.obj->name()+": Entry point must refer to the start of the object");
		_entryObject=it->second.obj;
	}
	
// Assign virtual addresses
	placeObjects();
	
// Perform relocations
	for(auto &obj: _objects) relocateObject(obj);
	
// Write binary data
	writeObjects(writer);
}

void Linker::setBase(LinkableObject::Word base) {
	_base=base;
}

void Linker::setAlignment(std::size_t align) {
	_align=align;
}

void Linker::setImageSize(std::size_t size) {
	_imageSize=size;
}

void Linker::generateMap(std::ostream &s) {
// Calculate length of the first column
	std::size_t len=0;
	for(auto const &obj: _objects) len=std::max(len,obj->name().size());
	for(auto const &sym: _globalSymbolTable) len=std::max(len,sym.first.size());
	len+=3;
	
	s<<"Objects:"<<std::endl;
	for(auto const &obj: _objects) {
		s<<obj->name();
		s<<std::string(len-obj->name().size(),' ');
		s<<Utils::hex(obj->virtualAddress());
		s<<std::endl;
	}
	
	s<<std::endl;
	
	s<<"Symbols:"<<std::endl;
	for(auto const &sym: _globalSymbolTable) {
		assert(sym.second.obj);
		s<<sym.first;
		s<<std::string(len-sym.first.size(),' ');
		s<<Utils::hex(sym.second.obj->virtualAddress()+sym.second.rva);
		s<<std::endl;
	}
}

/*
 * Private members
 */

void Linker::buildSymbolTable() {
	_globalSymbolTable.clear();
	
	for(auto const &obj: _objects) {
		auto const &table=obj->symbols();
		for(auto const &item: table) {
// Insert item to the global symbol table if it doesn't exist yet
			auto it=_globalSymbolTable.emplace(item.first,GlobalSymbolData()).first;

// If the symbol is local, check that it has not been already defined in another object
			if(item.second.type==LinkableObject::Local) {
				if(it->second.obj) {
					std::ostringstream msg;
					msg<<obj->name()<<": Duplicate definition of \""<<item.first;
					msg<<"\" (previously defined in "<<it->second.obj->name()<<")";
					throw std::runtime_error(msg.str());
				}
				it->second.obj=obj;
				it->second.rva=item.second.rva;
			}

// Merge reference tables
			for(auto const &ref: item.second.refs) it->second.refs.emplace(obj,ref.rva);
		}
	}
	
// Check that no undefined symbols remain
	for(auto const &item: _globalSymbolTable) {
		if(item.second.obj==nullptr&&!item.second.refs.empty()) {
			std::ostringstream msg;
			msg<<"Undefined symbol: \""<<item.first<<"\"";
			auto const it=item.second.refs.begin();
			msg<<" (referenced from "<<it->first->name()<<")";
			throw std::runtime_error(msg.str());
		}
	}
}

void Linker::placeObjects() {
	auto currentBase=_base;
	
// Make entry object the first
	if(_objects.size()>1) {
		for(auto it=_objects.begin();it!=_objects.end();++it) {
			if(*it==_entryObject) {
				std::swap(*it,_objects[0]);
				break;
			}
		}
	}
	
// Set base addresses
	for(auto it=_objects.begin();it!=_objects.end();++it) {
		(*it)->setVirtualAddress(currentBase);
		if(it+1!=_objects.end()) (*it)->addPadding(_align);
		else (*it)->addPadding();
		currentBase+=static_cast<LinkableObject::Word>((*it)->codeSize());
	}
}

void Linker::relocateObject(LinkableObject *obj) {
	for(auto const &sym: obj->symbols()) {
		auto it=_globalSymbolTable.find(sym.first);
		assert(it!=_globalSymbolTable.end());
		if(it->second.refs.empty()) continue;
		assert(it->second.obj);
		auto addr=it->second.obj->virtualAddress()+it->second.rva;
		for(auto const &ref: sym.second.refs) {
			if(ref.type==LinkableObject::Regular) obj->replaceWord(ref.rva,addr+ref.offset);
			else {
				auto target=static_cast<LinkableObject::Word>(addr+ref.offset);
				if(target>0xFFFFF&&target<0xFFF00000) {
					std::ostringstream msg;
					msg<<"Value \""<<target<<"\" is out of the range for a signed 21-bit constant";
					msg<<" (referenced from "<<ref.source<<":"<<ref.line<<")";
					throw std::runtime_error(msg.str());
				}
				target&=0x1FFFFF;
				auto w=obj->getWord(ref.rva);
				w|=(target&0xFFFF);
				w|=((target<<8)&0x1F000000);
				obj->replaceWord(ref.rva,w);
			}
		}
	}
}

void Linker::writeObjects(OutputWriter &writer) {
	std::size_t currentSize=0;
// Write entry object
	writer.write(reinterpret_cast<const char*>(_entryObject->code()),_entryObject->codeSize());
	currentSize+=_entryObject->codeSize();
// Write other objects
	for(auto const &obj: _objects) {
		if(obj==_entryObject) continue;
		writer.write(reinterpret_cast<const char*>(obj->code()),obj->codeSize());
		currentSize+=obj->codeSize();
	}
	
// Pad file if requested
	if(_imageSize>0) {
		if(currentSize>_imageSize)
			throw std::runtime_error("Image size exceeds the specified value");
		else if(currentSize<_imageSize) writer.pad(_imageSize-currentSize);
	}
}
