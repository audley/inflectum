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
    along with Inflectum. If not, see <http://www.gnu.org/licenses/>.
*/

include <../../call.scad>

/*
	This file contains the list functions that make use of the call() function
	directly. To allow these functions to be used with registered functions,
	this file MUST be included using "include". This is also because some of
	these functions refer to external functions defined by main.scad and
	flatten.scad, which should be included by the file including this file.

   List Functions:
		function filter(fname,list)
		function foldr(fname,start,list)
		function foldl(fname,start,list)
		function map2(fname,listOfLists)
		function filter2(fname,listOfLists)

	Lookup Functions:
		function lookupMap(fname,table)

   External List Dependencies:
		function length(list)
		function flatten(list,bounds=undef)
*/

/******************************************************************************
                          L I S T   F U N C T I O N S
******************************************************************************/

/*
	Filters a list based on a predicate function. The filtering function may
	be one of the following forms:

		function(item)
		function(item,index)

	where the function returns true for the item to be included in the
	list, or false for the item to be excluded. If the function is not
	registered, the original list (or an empty list if invalid) is returned.
*/
function filter(fname,list) = 
	(!callIsRegistered(fname)) ? (isEmpty(list) ? [] : list)
	: _filter(fname,list);
	// sub-function which returns nested output of filtering
	function _filter(fname,list,i=0) = 
		(i>=length(list)) ? []
		:(call(fname,list[i],i)==true)
			? concat([list[i]],_filter(fname,list,i+1))
			: _filter(fname,list,i+1);

/*
	Right-folds a list using a given (binary) function (name) and starting
	(accumulation) value. An example of the evaluation is as follows:

		f(item[0],f(item[1],f(item[2],f(item[3],start))))

	The function should be one of the following forms:

		function(item,acc)
		function(item,acc,index)

	If the function is not registered or there are no items, the start value
	is returned.
*/
function foldr(fname,start,list) =
	(!callIsRegistered(fname)) ? start
	: _foldr(fname,list,start);
	// sub-function which performs folding
	function _foldr(fname,list,start,i=0) = 
		(i>=length(list)) ? start
		: call(fname,list[i],_foldr(fname,list,start,i+1),i);

/*
	Left-folds a list using a given (binary) function (name) and starting
	(accumulation) value. An example of the evaluation is as follows:

		f(f(f(f(start,item[0]),item[1]),item[2]),item[3])

	The function should be one of the following forms:

		function(acc,item)
		function(acc,item,index)

	If the function is not registered or there are no items, the start value
	is returned.
*/
function foldl(fname,start,list) = 
	(!callIsRegistered(fname)) ? start
	:(isEmpty(list)) ? start
	: _foldl(fname,list,start,i=length(list)-1);
	// sub-function which performs folding
	function _foldl(fname,list,start,i) = 
		(i<0) ? start
		: call(fname,_foldl(fname,list,start,i-1),list[i],i);

/*
	Maps a registered function (given by name) over a list of lists, returning the
	modified list of lists. In this case, the mapping function is called per item
	per list per list. The mapping function may be one of the following forms:

		function(item)
		function(item,index1)
		function(item,index1,index2)

	where index1 is the outermost index, and index2 is the innermost index. The
	function should return the new (replacing) item value. If the function is
	not registered, the original list of lists (or an empty list if invalid)
	is returned.
*/
function map2(fname,listOfLists) =
	(!callIsRegistered(fname)) ? (isEmpty(listOfLists) ? [] : listOfLists)
	: _map2(listOfLists,$fname=fname);
	// sub-function applies another level of mapping
	function _map2(list,index1=0) = 
		(index1>=length(list)) ? []
		:concat([_map2_2(list[index1],$index1=index1)],
			_map2(list,index1+1));
	// sub-function which calls intended map function
	function _map2_2(list,index2=0) = 
		(index2>=length(list)) ? []
		:concat([call($fname,list[index2],$index1,index2)],
			_map2_2(list,index2+1));

/*
	Filters a list of lists based on a predicate function. In this case, the
	filtering function is called per item per list per list. Filtering does
	not occur to the outermost list, only the innermost. The filtering
	function may be one of the following forms:

		function(item)
		function(item,index1)
		function(item,index1,index2)

	where index1 is the outermost index, and index2 is the innermost index.
	The function should return true for the item to be included in the
	list, or false for the item to be excluded. If the function is not
	registered, the original list (or an empty list if invalid) is returned.
*/
function filter2(fname,listOfLists) = 
	(!callIsRegistered(fname)) ? (isEmpty(listOfLists) ? [] : listOfLists)
	: _filter2(listOfLists,$fname=fname);
	// sub-function (mapper) that applies filtering
	function _filter2(list,index1=0) = 
		(index1>=length(list)) ? []
		:concat([_filter2_2(list[index1],$index1=index1)],
			_filter2(list,index1+1));
	// sub-function which returns nested output of filtering
	function _filter2_2(list,index2=0) = 
		(index2>=length(list)) ? []
		:(call($fname,list[index2],$index1,index2)==true)
			? concat([list[index2]],_filter2_2(list,index2+1))
			: _filter2_2(list,index2+1);

/******************************************************************************
                          L O O K U P   F U N C T I O N S
******************************************************************************/

/*
	Maps a registered function (given by name) over the entries in a lookup
	table, returning the modified list. The mapping function should be of form:

		function(key,value)

	where the function returns a new (replacing) value for the entry (keeping
	the key). If the function returns 'undef', the entry is removed. If the
	function is not registered, the original table is returned.
*/
function lookupMap(fname,table) =
	(!callIsRegistered(fname)) ? table
	: flatten(_lookupMap(fname,table));
	// sub-function which returns nested output of mapping
	function _lookupMap(fname,table,i=0) = 
		(i>=length(table)) ? []
		:(length(table[i])!=2) ? [[],_lookupMap(fname,table,i+1)]
		:concat([_lookupMap_check(table[i][0],
				call(fname,table[i][0],table[i][1]))],
			_lookupMap(fname,table,i+1));
	// sub-function to check whether entry is to be added or not
	function _lookupMap_check(key,newValue) = 
		(newValue==undef) ? [] : [[key,newValue]];
