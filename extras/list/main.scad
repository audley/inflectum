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

include <../../list.scad>
include <../../value.scad>
use <aliases.scad>

/*
	Includes the main functions, excluding those making direct use of the call()
	function (those are included in call-functions.scad). Functions making use
	of the functions which use call() (whose main implementations are in
	registered.scad) are wrapped (to prevent call() registration issues).

   Included Functions:
		function head(list)
		function tail(list)
		function flattenNested(list)
		function insert(list,index,value)
		function insertMulti(list,index,values)
		function replace(list,index,value)
		function replaceMulti(list,index,values)
		function remove(list,index)
		function search(value,list,range=undef,matches=undef,
		                index=undef,key=undef)

   Lookup Functions:
      function lookup(key,table)
      function lookupSet(keyValue,table,keepOld=false)
		function lookupSetMulti(keyValues,table,keepOld=false)
      function lookupRemove(key,table)

	External Dependencies:
		function _slice(list,range)
		function _removeMulti(list,indexes)
		function _listSimplify(list,bounds=undef)
		function _sort(list,descending=false,index=undef,key=undef)
		function _lookupRemoveMulti(keys,table)
		function _lookupFilter(table)
*/

/*
	File which provides the following wrappers:

		Functions:
			function slice(list,range)
			function removeMulti(list,indexes)
			function listSimplify(list,bounds=undef)
			function search(value,list,range=undef,index=undef,key=undef)
			function sort(list,descending=false,index=undef,key=undef)
			function lookupRemoveMulti(keys,table)
			function lookupFilter(table)

	These link to '_'-prefixed functions which are given by registered.scad,
	which is included by the file including this file.
*/
include <wrap.scad>

/*
	General maximum number of supported list items for range expansions.
*/
CONFIG_LIST_MAX = 1000;

/******************************************************************************
                        L I S T   F U N C T I O N S
******************************************************************************/

/*
   Gets the head (first item) of a list.
*/
function head(list) = list[0];

/*
   Gets the tail (item list after the head) of a list. If the tale is not a
   list, an empty list will be returned.
*/
function tail(list) = (length(list)>=1) ? slice(list,[1:END]) : [];

/*
	Concatenates a nested list of lists:

		[1,[2,[3,[4,[5,[6,[]]]]]]] --> [1,2,3,4,5,6]
		[[1,2],[[3,4],[[5,6],[]]]] --> [[1,2],[3,4],[5,6]]

	If an empty or invalid list is passed, an empty list will be returned. The
	nested lists can be terminated by one or zero element vectors:

		[1,[2,[3,[4,[]]]]]   --> OK
		[1,[2,[3,[4]]]]      --> OK
*/
function flattenNested(list) = 
	// if past the end
	IF (isEmpty(list)) ?
		// terminate concatenation with empty list
		THEN  ([])
		// otherwise, concatenate current item and the rest of flattened list
		:ELSE (concat([list[0]],flattenNested(list[1])));

/*
   Returns a list with a value or values inserted at a specified index. Items
	at and after the index will be shifted down (increasing the length).

   If the index is specified as "end", the value/values will be inserted after
	the last item in the list. If the index is out of bounds, the value/values
	will not be added.

   If the list is empty or undefined, the list returned will only contain the
   value/values if the index specified is zero or "end", otherwise an empty
	list is returned.
*/
function insert(list,index,value) = insertMulti(list,index,[value]);
function insertMulti(list,index,values) =
	(isEmpty(values)) ? (isEmpty(list)?[]:list)
   :(index==0) ? concat(values,isEmpty(list)?[]:list)
   :(index=="end") ? concat(isEmpty(list)?[]:list,values)
   :(index < 0 || index >= length(list)) ? (isEmpty(list) ? [] : list)
   : concat(
		(index<=0) ? [] : slice(list,[START:index-1]),values,
		slice(list,[index:END]));

/*
   Returns a list with a value, or more than one value, starting at a specified
	index being changed to another value or values, where the length will only
	change if the replacing items go off the end (although still starting within
	the list).

   If the index is specified as "end", the value/values will replace the last
	item in the list. If the index is out of bounds, no replacement will occur. If
   the list is empty or undefined, an empty list will be returned (no items to
   replace.
*/
function replace(list,index,value) = replaceMulti(list,index,[value]);
function replaceMulti(list,index,values) = 
   (isEmpty(list)) ? []
	:(isEmpty(values)) ? list
   :(index=="end")
		? concat((length(list)<2) ? [] : slice(list,[START:length(list)-2]),values)
   :(index < 0 || index >= length(list)) ? list
   : concat(
		(index<=0) ? [] : slice(list,[START:index-1]),values,
		slice(list,[index+length(values):END]));

/*
   Removes an item from a list at a given index, returning a new list without the
	item. "end" can be used to refer to the last item.

   If the list is empty or invalid, an empty list will be returned. If the list
   only contains one item, an empty list will be returned if the index is 0 or
	"end".
*/
function remove(list,index) = removeMulti(list,[index]);

/*
   Finds the indexes of items which match a given value. This function works
   by recursively going through the list items, finding items with a matching
   value. All the matches will be found if 'matches' is 0 (or less) - the
   matches are returned as a list. If the item is not found, an empty list
   will be returned.

   If the list contains vectors, a check-index must be provided to select which
   component of the vectors to check. If the list contains lookup tables, a
   check-key must be provided to select the property to check when searching.
	Optionally, a checking range can also be provided - step has no effect.

   If an invalid list, index or key is passed, an empty list will be returned.
*/
function search(value,list,range=undef,matches=undef,index=undef,key=undef) =
	_search(i=_search_start(range,list),m=0,$value=value,$list=list,
	$range=range,$matches=(matches<1)?undef:matches,$index=index,
	$key=key,$endIndex = _search_end(range,list));
	// gets the starting index given a range
	function _search_start(range,list) = 
		(!isRange(range)) ? 0
		: min(max(range[0],0),length(list));
	// gets the ending index given a range
	function _search_end(range,list) = 
		(!isRange(range)) ? length(list)-1
		: min(max(range[2],-1),length(list)-1);
	// performs the searching
	function _search(i,m) = 
		(i > $endIndex) ? []
		:(m>=$matches && $matches!=undef) ? []
		:(_search_matches($list[i],$value))
			? concat([i],_search(i+1,m+1))
			: _search(i+1,m);
	// determines if the current item matches the value
	function _search_matches(item,value) = 
		($index!=undef) ? (item[$index] == value)
   	:($key!=undef)  ? (lookup($key,item) == value)
   	: (item == value);

/******************************************************************************
                       L O O K U P   F U N C T I O N S
******************************************************************************/

/*
   Finds the value for a given key in a table. If more than one entry exists
   with the matching key, the first will be used. If the key is not found,
   'undef' will be returned.
*/
function lookup(key,table) = 
   (isEmpty(table)) ? undef
	: table[search(key,table,index=0,matches=1)[0]][1];

/*
   Adds key-value entries to an existing lookup table. If the keepOld flag is
	set to false and the key already exists, the first existing entry will be
	removed and the new entry will be prepended to the start.
*/
function lookupSet(keyValue,table,keepOld=false) =
	lookupSetMulti([keyValue],table,keepOld);
function lookupSetMulti(keyValues,table,keepOld=false) = 
  concat(keyValues,
     (keepOld==true) ? table
     : lookupRemoveMulti(keyValues,table,$keyValue=true));

/*
   Removes a key-value entry from an existing lookup table, given a key. Only
	the first matching entries for each key will be removed from the table.
*/
function lookupRemove(key,table) = lookupRemoveMulti([key],table);
