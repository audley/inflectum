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

include <common.scad>
include <config.scad>
include <value.scad>
include <call.scad>

/*
   The following set of functions are a means to work with lists (vectors).
	This requires the existance of the built-in concat() function.

	To use the map() function, the functions passed (by name) need to be
	registered before use (as per call.scad).

	Constants: (for ranges)
		START
		END
   List Functions:
		function isEmpty(list)
		function length(list)
		function map(fname,list)
		function flatten(list,bounds=undef)
		function isRange(range)
		function listFromRange(range,bounds=undef)
*/

/******************************************************************************
                     R A N G E   C O N S T A N T S
******************************************************************************/

// for use with ranges -- handled by listFromRange()
START = -inf; END = inf;

/******************************************************************************
                        L I S T   F U N C T I O N S
******************************************************************************/

/*
	Function which determines if a list is empty ([]) or invalid. Strings are
	counted as empty - they're more of a value.
*/
function isEmpty(list) = (!(len(list)>0) || isString(list));

/*
   Finds the length of a given list. If an undefined/scalar or empty list is
   passed, zero will be returned.
*/
function length(list) = IF (isEmpty(list)) ? THEN (0) :ELSE (len(list));

/*
	Maps a registered function (given by name) over a list, returning the
	modified list. The mapping function may be one of the following forms:

		function(item)
		function(item,index)

	where the function returns a new (replacing) item value. If the function is
	not registered, the original list (or an empty list if invalid) is returned.
*/
function map(fname,list) =
	// if the function is unknown
	IF (!callIsRegistered(fname)) ? THEN
	(
		// if the list is empty/invalid
		IF (isEmpty(list)) ?
			// return an empty list
			THEN ([])
			// otherwise, return the original list
			:ELSE (list)
	)
	// otherwise, if function is known, start the recursion
	:ELSE (_map(fname,list),$len=length(list));
	// sub-function which returns nested output of mapping
	function _map(fname,list,i=0) = 
		// if past the end of the list
		IF (i>=length(list)) ?
			// terminate with an empty list
			THEN  ([])
			// otherwise, apply the function and append the rest
			:ELSE (concat([call(fname,list[i],i)],_map(fname,list,i+1)));

/*
	Returns true if the value passed is a range (ie. [a : b : c]), otherwise
	the function returns false. This check is done by seeing whether the
	length of the range is undefined (len(<range>)==undef) and whether the
	start is defined.
*/
function isRange(range) = (len(range)==undef && range[0]!=undef);

/*
	Converts a given range to a regular list/vector. If the value passed is
	not a range (which includes lists), an empty list will be returned.
	
	The start and end values will be limited to the values specifed for the
	bounds (also a range, although the step-value is ignored), if the bounds
	are specified. This allows the START and END constants to be used.
*/
function listFromRange(range,bounds=undef) = 
	IF (!(isRange(range))) ? THEN ([])
	:ELSE
	(
		// limit the range to the bounds if provided
		$startIndex = 
			IF (isRange(bounds)) ? 
				THEN (min(max(range[0],bounds[0]),bounds[2]))
				:ELSE (range[0]),

		// limit the range to the bounds if provided
		$endIndex = 
			IF (isRange(bounds)) ? 
				THEN (min(max(range[2],bounds[0]),bounds[2]))
				:ELSE (range[2]),

		// get the expanded range
		$list = _listFromRange($startIndex,range[1],$endIndex),

		RETURN ($list)
	);
	// sub-function which returns a nested list from a range
	function _listFromRange(start,step,end,last=undef,i=0) = 
		IF (i>CONFIG_LIST_MAX) ? THEN ([])
		// if at the start of the expansion
		:ELSE_IF (i==0) ? THEN
		(
			// if the start and end indexes are the same, return with one value
			IF (start==end) ? THEN ([start])
			
			// if the start and end values need to be flipped, return an empty list
			:ELSE_IF ((start>end&&sign(step)==1)||(start<end&&sign(step)==-1))?
				THEN ([])

			// otherwise, append start value onto rest of expanded range
			:ELSE (concat([start], _listFromRange(start,step,end,start,i+1)))
		)
		:ELSE
		(
			// if this is the last item
			IF (((last+step+step)>end && sign(step)==1)
			|| ((last+step+step)<end && sign(step)==-1)) ?
				// terminate with the last value
				THEN ([last+step])
			// otherwise, if not the last item
			:ELSE
				// add current and append the rest
				(concat([last+step],_listFromRange(start,step,end,last+step,i+1)))
		);

/*
	Concatenates a list of lists together:

		[[1,2,3],[4,5,6]]          --> [1,2,3,4,5,6]
		[[[1,2],3],[4,[5,6]]]      --> [[1,2],3,4,[5,6]]
		[[],[],[]]                 --> []

	If an empty or invalid list is passed, an empty list will be returned.
	Ranges are also supported by this function, and are expanded when they are
	concatenated:

		[[1:5],[3:3:15]] --> [1,2,3,4,5,3,6,9,12,15]

	If any of the ranges have infinite values (from using START or END), a
	boundry range (bounds) should also be specified to limit the values.
*/
function flatten(list,bounds=undef) =
	IF (isEmpty(list)) ? THEN ([])
	:ELSE (_flatten_foldr(list,bounds));
	// sub-function which performs right-folding
	function _flatten_foldr(list,bounds,i=0) = _
	(
		IF (i>=length(list)) ? THEN ([])
		:ELSE
		(
			// get the current item - account for ranges and non-vectors
			$item = _
			(
				IF (isRange(list[i])) ? THEN (listFromRange(list[i],bounds))
				:ELSE_IF (length(list[i])==0) ? THEN ([])
				:ELSE (list[i])
			),
			RETURN (concat($item,_flatten_foldr(list,bounds,i+1)))
		)
	);
