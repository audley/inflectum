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

/*
	This file includes the list functions which make use of the map(), foldl(),
	foldr() and filter() functions (which use call() directly). The names of 
	the functions below are prefixed so that wrapping functions can be used
	to access them (to solve call() registration issues).

	Functions:
		function _slice(list,range)
		function _removeMulti(list,indexes)
		function _listSimplify(list,bounds=undef)
		function _sort(list,descending=false,index=undef,key=undef)
		function _lookupRemoveMulti(keys,table)
		function _lookupFilter(table)
*/

/*
	Main list functions required by the functions below. The external
	dependencies for this file are satisfied by the functions provided by this
	file.
*/
include <main.scad>

// map2(), foldl(), foldr(), filter() and filter2() functions
include <call-functions.scad>

/******************************************************************************
                  F U N C T I O N   R E G I S T R A T I O N
******************************************************************************/

$function0 = "_slice_map";
function $function0(index) = _slice_map(index);

$function1 = "_removeMulti_filter";
function $function1(item,index) = _removeMulti_filter(item,index);

$function2 = "_listSimplify_map";
function $function2(value) = _listSimplify_map(value);

$function3 = "_sort_side";
function $function3(v,i) = _sort_side(v,i);

$function4 = "_lookupRemoveMulti_map";
function $function4(value) = _lookupRemoveMulti_map(value);

$function5 = "_lookupFilter_filter";
function $function5(value) = _lookupFilter_filter(value);

$function6 = "_flatten_foldr";
function $function6(item,acc) = _flatten_foldr(item,acc);

/******************************************************************************
                        L I S T   F U N C T I O N S
******************************************************************************/

/*
	Returns a section of a list, given the list and a range or list of indexes.
	An undefined or below-zero start index will cause the list to start at
	index zero, while an index greater than the length of the list will result
	in an empty list. If the end index is greater than the last index or is
	undefined, all the items from the start index to the end will be selected.
	If the list is undefined or empty, an empty list will be returned.
*/
function _slice(list,range) = 
	(isEmpty(list)) ? []
	:(range==undef) ? list
	:flatten(map("_slice_map", $list=list,
		(isRange(range)) ? listFromRange(range,[-1:length(list)]) : range));
	function _slice_map(index) = 
		(index<0 || index>=length($list)) ? [] : [$list[index]];

/*
   Removes more than one item from a list at given indexes, returning a new list
	without the items. "end" can be used to refer to the last item.

   If the list is empty or invalid, an empty list will be returned. If the list
   only contains one item, an empty list will be returned if any of the indexes
	is 0 or "end".
*/
function _removeMulti(list,indexes) =
	_removeMulti_(list,
		(isRange(indexes)) ? listFromRange(indexes,[0:length(list)-1])
		                   : indexes);
	function _removeMulti_(list,indexes) = 
		filter("_removeMulti_filter",list,
			$indexes=indexes,$lastIndex=(length(list)-1));
		function _removeMulti_filter(item,index) = 
			(length(search(index,$indexes,matches=1))==0)
			&& !(index==$lastIndex && search("end",$indexes));

/*
	Converts any items in a list to vectors if they are ranges. An
	optional boundry range can be specified to control the minimum and
	maximum of the expanded ranges. This only works for the first "layer"
	of a vector - further "simplification" must be done by means of mapping.
*/
function _listSimplify(list,bounds=undef) = 
	map("_listSimplify_map",list,$bounds=bounds);
	function _listSimplify_map(value) = 
		(isRange(value)) ? listFromRange(value,$bounds) : value;

/*
   Returns an ascending- or descending-order sorted list from an unsorted list.
   This function works by using the qsort algorithm, recursively going through
   the list and putting values on the left or right side of a pivot, sorting
   each "branch".

   The priority (and hence start->end order) of special values, regardless of
   the sorting direction, is as follows:

      <number or +/-inf>,<nan>,<undef>

   If the values being sorted are vectors, an index for the sorted component
   must be specified (checkIndex). If the values are lookup tables, a key must
   be provided. If checkIndex is out-of-bounds or the key is not present, the
	original unmodified list will be returned. If the list passed is empty or
   invalid, an empty list will be returned.
*/
function _sort(list,descending=false,index=undef,key=undef) =
   _sort_qsort(list,$descending=descending,$index=index,$key=key);
   // the quicksort algorithm - the first element is used as the pivot
   function _sort_qsort(list) =
      (isEmpty(list)) ? [] // base case check
      :concat(
         // left sorted list
         _sort_qsort(filter("_sort_side",list,$side="left",
					$pivot=_sort_value(list[0]))),
         // pivot (first value)
         [list[0]],
         // right sorted list
         _sort_qsort(filter("_sort_side",list,$side="right",
               $pivot=_sort_value(list[0]))));
		// predicate sub-function to return a side list based on the pivot value
		function _sort_side(v,i) = 
			_sort_side_(_sort_value(v),i);
      	// sub-function to check current item comparison-value
      	function _sort_side_(value,i) = 
         	// return true to include, false to exclude
				(i==0) ? false // don't want to include pivot
	         :(($side=="left")
	            ?(
						($pivot==undef && value==undef) ? false
	               :($pivot==undef) ? true
	               :(value==undef) ? false
	               :(isNan($pivot)) ? true
	               :(isNan(value)) ? false
						:(!isString($pivot) && isString(value)) ? false
						:(isString($pivot) && !isString(value)) ? true
	               :((!$descending)?(value<=$pivot):(value>=$pivot))
	            ):(
						($pivot==undef && value==undef) ? true
	               :($pivot==undef) ? false
	               :(value==undef) ? true
	               :(isNan($pivot)) ? false
	               :(isNan(value)) ? true
						:(!isString($pivot) && isString(value)) ? true
						:(isString($pivot) && !isString(value)) ? false
	               :((!$descending)?(value>$pivot):(value<$pivot))
	            ));
   	/*
	      Sub-function to obtain the value to compare in determining whether an
	      element should be included on a side. Handles the fact that the value
	      may be a vector or a lookup table, where in such a case, a specified
	      component index or key is used.
	   */
	   function _sort_value(value) = 
	      ($index!=undef) ? value[$index]
	      :($key!=undef) ? lookup($key,value)
	      :value;

/******************************************************************************
                       L O O K U P   F U N C T I O N S
******************************************************************************/

/*
   Removes a key-value entry from an existing lookup table, given a key. Only
	the first matching entries for each key will be removed from the table.
*/
function _lookupRemoveMulti(keys,table) = 
   (isEmpty(table)) ? []
	: removeMulti(table,flatten(
		map("_lookupRemoveMulti_map",keys,$table=table)));
	function _lookupRemoveMulti_map(value) = 
		search(($keyValue==true)?value[0]:value,$table,index=0,matches=1);

/*
	Removes entries from a lookup table if the values are undefined. Allows
	lookup tables to be "cleaned".
*/
function _lookupFilter(table) = filter("_lookupFilter_filter",table);
	function _lookupFilter_filter(value) = !(value[1]==undef);
