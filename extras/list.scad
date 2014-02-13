/*
    This file is part of Inflectum, a curved geometry library for OpenSCAD.
    Copyright (C) 2014 Samuel Dodd
    
    Inflectum is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Inflectum is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Inflectum.  If not, see <http://www.gnu.org/licenses/>.
*/

include <../list.scad>

/*
   The following set of functions are a means to work with lists (vectors).
   These require the existance of the built-in concat() function. The other
	list functions are provided from the main list.scad file.

   To support more dynamic lookup tables, a set of functions have also been
   provided to use and modify lookup tables, allowing etries to be added/
   replaced and removed as necessary. Single, or multiple entries specified as
	a list, can be added/replaced or removed from an existing table. To support
	tables being used in lists, the search() and sort() functions allow a key to
	be passed which determines what to base the search on.

	This file overrides the definition of the lookup() and search() functions.
	Access to these are available through the aliases.

	To use the map(), map2(), filter(), filter2(), foldr() and foldl()
	functions, the functions passed (by name) need to be registered before
	(as per call.scad).

	Aliased Functions: (to allow access to original behaviour)
		function __lookup(key,key_values)
		function __search(value,vector,matches=1,index=0)

   List Functions:
      function head(list)
      function tail(list)
      function slice(list,range)
      function insert(list,index,value)
		function insertMulti(list,index,values)
      function replace(list,index,value)
		function replaceMulti(list,index,values)
		function remove(list,index)
		function removeMulti(list,indexes)
		function filter(fname,list)
		function foldr(fname,start,list)
		function foldl(fname,start,list)
		function map2(fname,listOfLists)
		function filter2(fname,listOfLists)
		function listSimplify(list,bounds=undef)
		function search(value,list,range=undef,index=undef,key=undef)
      function sort(list,descending=false,index=undef,key=undef)

   Lookup Functions:
      function lookup(key,table)
      function lookupSet(keyValue,table,keepOld=false)
		function lookupSetMulti(keyValues,table,keepOld=false)
      function lookupRemove(key,table)
      function lookupRemoveMulti(keys,table)
		function lookupMap(fname,table)
		function lookupFilter(table)

	NOTE: this file must be included using "include".
*/

/******************************************************************************
                     A L I A S E D   F U N C T I O N S
******************************************************************************/

use <list/aliases.scad>

/******************************************************************************
                          L I S T   F U N C T I O N S
******************************************************************************/

// provides main list functions
use <list/wrap-main.scad>

// override map()2, foldl(), foldr(), filter() and filter2() functions in
// this scope
include <list/call-functions.scad>
