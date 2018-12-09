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
	else if(_entryObject==nullptr)
		throw std::runtime_error("Entry point not defined: cannot find \"entry\" or \"Entry\" symbol");
	
// Assign virtual addresses
	placeObjects();
	
// Perform relocations
	for(auto &obj: _objects) relocateObject(obj);
	
// Write binary data
	writeObjects(writer);
	_bytesWritten=writer.size();
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
// Calculate the maximum length of a symbol name
	std::size_t len=0;
	for(auto const &obj: _objects) {
		for(auto const &sym: obj->symbols()) {
			if(sym.second.type!=LinkableObject::Imported)
				len=std::max(len,sym.first.size());
		}
	}
	len=std::max(len+3,std::size_t(8)); // width of the first column
	
	s<<"Image base address: "<<Utils::hex(_base)<<std::endl;
	s<<"Object alignment: "<<_align<<std::endl;
	s<<"Image size: "<<(_bytesWritten/4)<<" words"<<std::endl;
	s<<"Number of objects: "<<_objects.size()<<std::endl;
	s<<std::endl;
	
	for(auto const &obj: _objects) {
		s<<"Object \""<<obj->name()<<"\" at address "<<Utils::hex(obj->virtualAddress())<<std::endl;
		s<<std::endl;
		std::multimap<LinkableObject::Word,std::pair<std::string,LinkableObject::SymbolData> > sorted;
		for(auto const &sym: obj->symbols()) sorted.emplace(sym.second.rva,sym);
		for(auto const &sym: sorted) {
			if(sym.second.second.type==LinkableObject::Imported) continue;
			s<<sym.second.first;
			s<<std::string(len-sym.second.first.size(),' ');
			s<<Utils::hex(obj->virtualAddress()+sym.second.second.rva);
			if(sym.second.second.type==LinkableObject::Local) s<<" Local";
			else s<<" Exported";
			s<<std::endl;
		}
		s<<std::endl;
	}
}

/*
 * Private members
 */

void Linker::buildSymbolTable() {
	_globalSymbolTable.clear();
	
// Build a table of exported symbols from all modules
	for(auto const &obj: _objects) {
		auto const &table=obj->symbols();
		for(auto const &item: table) {
			if((item.first=="entry"||item.first=="Entry")&&item.second.type!=LinkableObject::Imported) {
				if(_entryObject) {
					std::ostringstream msg;
					msg<<obj->name()<<": Duplicate definition of the entry symbol ";
					msg<<"(previously defined in "<<_entryObject->name()<<")";
					throw std::runtime_error(msg.str());
				}
				if(item.second.rva!=0) {
					std::ostringstream msg;
					msg<<obj->name()<<": ";
					msg<<"Entry point must refer to the start of the object";
					throw std::runtime_error(msg.str());
				}
				_entryObject=obj;
			}
			if(item.second.type==LinkableObject::Local) continue;
// Insert item to the global symbol table if it doesn't exist yet
			auto it=_globalSymbolTable.emplace(item.first,GlobalSymbolData()).first;

// Check that the symbol has not been already defined in another object
			if(item.second.type==LinkableObject::Exported) {
				if(it->second.obj) {
					std::ostringstream msg;
					msg<<obj->name()<<": Duplicate definition of \""<<item.first;
					msg<<"\" (previously defined in "<<it->second.obj->name()<<")";
					throw std::runtime_error(msg.str());
				}
				it->second.obj=obj;
				it->second.rva=item.second.rva;
			}
			
			if(!item.second.refs.empty()) it->second.refs.insert(obj);
		}
	}
	
// Check that local symbols don't shadow the public ones
	for(auto const &obj: _objects) {
		auto const &table=obj->symbols();
		for(auto const &item: table) {
			if(item.second.type!=LinkableObject::Local) continue;
			auto it=_globalSymbolTable.find(item.first);
			if(it==_globalSymbolTable.end()) continue;
			if(!it->second.obj) continue;
			if(item.first==it->first) {
				std::ostringstream msg;
				msg<<obj->name()<<": Local symbol \""<<item.first<<"\" shadows the public one ";
				msg<<"(defined in "<<it->second.obj->name()<<")";
				throw std::runtime_error(msg.str());
			}
		}
	}
	
// Check that no undefined symbols remain
	for(auto const &item: _globalSymbolTable) {
		if(item.second.obj==nullptr&&!item.second.refs.empty()) {
			std::ostringstream msg;
			msg<<"Undefined symbol: \""<<item.first<<"\"";
			auto const it=item.second.refs.begin();
			msg<<" (referenced from "<<(*it)->name()<<")";
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
				_objects.erase(it);
				break;
			}
		}
		_objects.insert(_objects.begin(),_entryObject);
	}
	
// Remove unreferenced objects
	if(_objects.size()>1) {
		std::set<const LinkableObject*> used;
		markAsUsed(_objects[0],used);
		for(auto it=_objects.begin();it!=_objects.end();) {
			if(used.find(*it)==used.end()) {
				std::cerr<<"Linker warning: skipping an unreferenced object \"";
				std::cerr<<(*it)->name()<<"\""<<std::endl;
				for(auto sym=_globalSymbolTable.begin();sym!=_globalSymbolTable.end();) {
					if(sym->second.obj==*it) sym=_globalSymbolTable.erase(sym);
					else ++sym;
				}
				it=_objects.erase(it);
			}
			else ++it;
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
		LinkableObject::Word addr;
		if(sym.second.refs.empty()) continue;
		
		if(sym.second.type==LinkableObject::Local) addr=obj->virtualAddress()+sym.second.rva;
		else {
			auto it=_globalSymbolTable.find(sym.first);
			assert(it!=_globalSymbolTable.end());
			assert(it->second.obj);
			addr=it->second.obj->virtualAddress()+it->second.rva;
		}
		
		for(auto const &ref: sym.second.refs) {
			if(ref.type==LinkableObject::Regular) obj->replaceWord(ref.rva,addr+ref.offset);
			else {
				auto target=static_cast<LinkableObject::Word>(addr+ref.offset);
				if(target>0xFFFFF&&target<0xFFF00000) {
					std::ostringstream msg;
					msg<<"Address 0x"<<Utils::hex(target)<<" is out of the range for a short reference";
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

void Linker::markAsUsed(const LinkableObject *obj,std::set<const LinkableObject*> &used) {
	if(used.find(obj)!=used.end()) return; // already processed
	used.insert(obj);
	for(auto const &sym: _globalSymbolTable) {
		for(auto const &ref: sym.second.refs) {
			if(ref==obj) markAsUsed(sym.second.obj,used);
		}
	}
}
