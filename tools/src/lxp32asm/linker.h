/*
 * Copyright (c) 2016 by Alex I. Kuznetsov.
 *
 * Part of the LXP32 CPU IP core.
 *
 * This module defines the Linker class which performs
 * linking of LXP32 binary objects.
 */

#ifndef LINKER_H_INCLUDED
#define LINKER_H_INCLUDED

#include "linkableobject.h"
#include "outputwriter.h"

#include <iostream>
#include <map>
#include <vector>
#include <string>
#include <set>

class Linker {
	struct GlobalSymbolData {
		LinkableObject *obj=nullptr;
		LinkableObject::Word rva=0;
		std::set<const LinkableObject*> refs;
	};
	
	std::vector<LinkableObject*> _objects;
	LinkableObject *_entryObject=nullptr;
	std::map<std::string,GlobalSymbolData> _globalSymbolTable;
	
// Various output options
	LinkableObject::Word _base=0;
	std::size_t _align=4;
	std::size_t _imageSize=0;
	std::size_t _bytesWritten=0;
public:
	void addObject(LinkableObject &obj);
	void link(OutputWriter &writer);
	void setBase(LinkableObject::Word base);
	void setAlignment(std::size_t align);
	void setImageSize(std::size_t size);
	void generateMap(std::ostream &s);
private:
	void buildSymbolTable();
	void placeObjects();
	void relocateObject(LinkableObject *obj);
	void writeObjects(OutputWriter &writer);
	void markAsUsed(const LinkableObject *obj,std::set<const LinkableObject*> &used);
};

#endif
