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
	To handle lists in recursive functions, lists of the following form can be
	used:

		[a,[b,[c,[d,...[]...]]]]]

	This form is easily made by a recursive function. The following set of
	functions and modules are a means to use such lists.

	Empty lists ([]) can be passed to the functions. Each list can either end
	with or without an an empty list (like a null character). Empty lists are
	regarded as being past the end of the list.

	To support more dynamic lookup tables, a set of functions have also been
	provided to create, use, and modify nested lookup tables, allowing etries
	to be added/replaced and removed as necessary. Tables must be created
	with a table specified as a vector. Multiple entries, specified as a vector,
	can be added/replaced or removed from an existing table. To support tables
	being used in lists, all the searching functions (nestedSearch(),
	nestedFindMin(),nestedFindMax(),nestedSort()) allow a key to be passed
	(instead of a vector index) which determines what to base the search on.

	Functions:
		function nestedPrepend(value,list)
		function nestedAppend(list,value)
		function nestedHead(list)
		function nestedTail(list)
		function nestedFromVec(vector)
		function nestedIsEnd(list)
		function nestedIsPastEnd(list)
		function nestedIsEmpty(list)
		function nestedMid(list,start=0,end=-1)
		function nestedInsert(list,value,index)
		function nestedLen(list)
		function nestedGet(list,index)
		function nestedSearch(list,value,matchCount=0,
		                             checkIndex=undef,checkKey=undef)
		function nestedRemove(list,index)
		function nestedFindMin(list,checkIndex=undef,checkKey=undef)
		function nestedFindMax(list,checkIndex=undef,checkKey=undef)
		function nestedSort(list,descending=false,
		                           checkIndex=undef,checkKey=undef)
		function nestedLookup(table,key)
		function nestedLookupCreate(vector)
		function nestedLookupAdd(table,keyValueVector,keepOld=false)
		function nestedLookupRemove(table,keyVector)
	Modules:
		module nestedForEach(list)
*/

/******************************************************************************
                       L I S T   F U N C T I O N S
******************************************************************************/

/*
	Prepends a value onto a list. Note that the value is specified first. If the
	list is undefined, the value will be prepended to an empty list.
*/
function nestedPrepend(value,list) =
	/*
		If the list is empty or not a valid list (eg. undefined)...

		This check is done by seeing whether we have gone past the end of the list,
		which returns true if the list is 'undef', a scalar value or empty.
	*/
	(nestedIsPastEnd(list))
		// prepend to an empty list
		? [value,[]]
	// otherwise, if the list is defined
		// prepend the value to the list
		: [value,list];

/*
	Appends a value to a list. Uses the nestedInsert() function to do so.
	If the list is empty or invalid (undef or scalar), the returned list will
	contain the value with a terminating empty list.
*/
function nestedAppend(list,value) =
	nestedInsert(list,value,"end");

/*
	Gets the head (first item) of a list
*/
function nestedHead(list) = list[0];

/*
	Gets the tail (item list after the head) of a list. If the tale is not a
	list, an empty list will be returned.
*/
function nestedTail(list) = 
	// If the tail is an empty list or is invalid...
	(!(len(list[1])>0))
		// return an empty list
		? []
	// otherwise, if valid/non-empty list
		// return the tail
		: list[1];

/*
	Converts a vector to a list. Only needed if the vector needs to be used with
	these functions.
*/
function nestedFromVec(vector) = 
	/*
		Check whether the vector is really a vector, or whether the vector is
		empty, so that infinite recursion wont occur.
	*/
	// if not a vector or the vector is empty, simply return an empty list
	(!(len(vector)>0)) ? []

	// otherwise, if a non-empty vector
		/*
			Pass to a recursive sub-function the original vector, the length of
			the vector, and a starting index (0). The function will return a
			(nested) list.
		*/
		: _nestedFromVec(vector,len(vector),0);
	/*
		Recursive sub-function to go through the vector, constructing a list,
		until the the end of the vector has been reached.
	*/
	function _nestedFromVec(vector,length,i) = 

		// if we have gone past the end of the vector
		(i>=length)

			// terminate with an empty list
			? []

		// otherwise, if we are not past the end yet
			/*
				Add the current element and the rest of the vector, by letting this
				function call itself again with an incremented index.
			*/
			: nestedPrepend(
				// (value)
				vector[i],
				// (rest of list)
				_nestedFromVec(vector,length,i+1));

/*
	Function to determine whether this is the end of a list. Because this is to
	be used in a recursive function which passes the tail of the list to itself
	again, this determines whether the current item is the last item before the
	terminating null/empty list.

	To see whether this is the last item, the length of the tail is checked. If
	this is the last item, the list is of the form [value,[]], as compared to
	[value,[...]] when it is not the end. Trying to access the length of the tail
	of [value,[]] or a badly-terminated list of the form [value,<scalar>] will
	result in a value not greater than zero.
	
	This function, to help prevent unwanted recursion occuring, also acts true
	for when the list is past the end (ie. empty, undefined or a scalar).

	Empty lists ([]) terminate lists, and are counted as being past the end (as
	the last item has been passed).
*/
function nestedIsEnd(list) = !(len(nestedTail(list))>0);

/*
	Function to determine whether the end of a list has been passed. Because
	this is to be used in a recursive function which passes the tail of the list
	to itself again, this determines whether the tail list is an empty or
	invalid list.

	To see whether the end of the list has been passed, the length of the list
	is checked. If this is past the last item, the list will either be empty,
	'undef' or some scalar value (if a badly formatted list was used). As a
	result, to detect whether the end has been passed, the length of the list
	is checked, and if it is not greater than zero, we are past the end of the list.
*/
function nestedIsPastEnd(list) = !(len(list)>0);

/*
	Function which determines if a list is empty ([]).
*/
function nestedIsEmpty(list) = (len(list)==0);

/*
	Returns a section of a list, given the start index (inclusive) and the number
	of items. An undefined or out-of-bounds start index will result in an empty list.
	If the number of items is invalid or too many, all the items from the start index
	to the end will be selected. If the list is undefined or empty, an empty list will
	be returned.
*/
function nestedMid(list,start=0,n=-1) = 
	
	// if this is an empty or invalid list
	(nestedIsPastEnd(list))
		// return an empty list
		? []
	// otherwise, if the list is non-empty and valid
		/*
			Pass to a sub-function the list, which will go through the items
			until the start index has been reached, at which point a number
			of items are selected.
		*/
		:_nestedMid_findstart(list,start,n,0);
	/*
		Sub-function which will go through the items in the list until the
		start index has been found, at which point iteration through the list
		is done by another sub-function which will do the "selecting".
	*/
	function _nestedMid_findstart(list,start,n,i) = 

		// if we are past the end of the list
		(nestedIsPastEnd(list))

			// start index was not found - just return empty list
			? []

		// otherwise, if we have not gone past the end yet
		:(
			// if the index does not match the start index
			(i!=start)

				// keep going through the list
				? _nestedMid_findstart(
					nestedTail(list),start,n,i+1)

			// otherwise, if the index does match the start index
				/*
					Pass the list onto another sub-function which will select
					a number of items.
				*/
				: _nestedMid_findend(list,n,1)
		);
	/*
		Sub-function which selects a portion of a list.
	*/
	function _nestedMid_findend(list,n,i) = 

		// if we are past the end of the list or item count
		(nestedIsPastEnd(list) || (i>n && n>=0))

			// finish with empty list
			? []

		// otherwise, if we are not past the end of the list or item count
			// prepend the current item onto the rest
			: nestedPrepend(
				nestedHead(list),
				_nestedMid_findend(
					nestedTail(list),n,i+1));

/*
	Returns a list with a value inserted at a specified index. Items at and
	after the index will be shifted down (increasing the length).

	If the index is specified as "end", the value will be inserted after the
	last item in the list. If the index is out of bounds, the value will not be
	added.

	If the list is empty or undefined, the list returned will only contain the
	value (and a terminating empty list) if the index specified is zero or "end",
	otherwise an empty list is returned.
*/
function nestedInsert(list,value,index) = 
	// if the list is empty or invalid
	(nestedIsPastEnd(list))
	?(
		// if the index specified is zero or the end
		(index==0 || index=="end")
			// return the value in a list terminated with an empty list
			? nestedPrepend(value,[])
		// otherwise, if the index specified is out of bounds
			// just return an empty list
			: []
	// otherwise, if the list is valid and not empty
	)
		/*
			Pass to a recursive sub-function the original arguments. The function
			will return a (nested) list.
		*/
		: _nestedInsert_check(list,value,index,0);
	/*
		Recursive sub-function to go through the list until the index has been
		found, at which point the value is inserted (after the previous items)
		and the rest of the list is appended.
	*/
	function _nestedInsert_check(list,value,index,i) =

		// if this item is not the insertion point (or index="end")
		(i!=index)
		?(
			//	if this is not the last item
			(!nestedIsEnd(list))
				/*
					Add the current and next items, by prepending the head to the
					list returned by this function calling itself again.
				*/
				? nestedPrepend(
					// (value)
					nestedHead(list),
					// (list)
					_nestedInsert_check(
						nestedTail(list),value,index,i+1))

			// otherwise, if this is the last item
			:(
				// if the index is specified as "end"
				(index=="end")
					/*
						Insert the value (at the "end") after the last item, by
						prepending the value (put into a list) with the original
						item (at the end, given by the head).
					*/
					? nestedPrepend(nestedHead(list),
						nestedPrepend(value,[]))

				// otherwise, if the index was not specified as "end"
					// just add this last item
					: nestedPrepend(nestedHead(list),[])
			)
		// otherwise, if this item is the insertion point
		)
			// prepend the value onto the rest of the list
			: nestedPrepend(value,list);

/*
	Finds the length of a given list. Works by calling a sub-function to
	recursively go through each item until the end is reached, summing the
	number of items found.

	If an undefined/scalar or empty list is passed, zero will be returned.
*/
function nestedLen(list) = 
	// if this is a empty or invalid list
	(nestedIsPastEnd(list))
		// terminate sum by adding zero
		? 0
	// otherwise, if the list is valid
		// add one to the sum and the rest of the sum (through recursion)
		: 1 + nestedLen(nestedTail(list));

/*
	Gets an item from a list, given the item's index. This function works by
	recursively going through each item until the index matches. If the index
	is out of bounds, 'undef' will be returned. If "end" is specified as the
	index, the last item will be retrieved.
*/
function nestedGet(list,index) = 
	/*
		Pass to a recursive sub-function the original arguments and a starting
		index (0). The function will return a single value.
	*/
	_nestedGet_check(list,index,0);
	/*
		Recursive sub-function to go through the list until the index has been
		found, at which point the value is returned.
	*/
	function _nestedGet_check(list,index,i) = 

		// if we are past the end of the list
		nestedIsPastEnd(list)
			/*
				No index match was found, hence the index was out of bounds. Simply
				return 'undef' to signify that the item was not retrieved.
			*/
			? undef

		// otherwise, if we have not gone past the end yet
		:(
			// if this is the correct index
			(i==index || (index=="end" && nestedIsEnd(list)))

				// return this item's value
				? nestedHead(list)

			// otherwise, if this is not the correct index
				/*
					Keep going through the list, by calling this function again,
					passing the list tail and an incremented current-index.
				*/
				: _nestedGet_check(nestedTail(list),index,i+1)
		);
/*
	Finds the indexes of an item which matches a given value. This function works
	by recursively going through the list items, finding items with a matching
	value. All the matches will be found if matchCount is 0 - the matches are
	returned as a list. If the item is not found, an empty list will be returned.

	If the list contains vectors, a check-index must be provided to select which
	component of the vectors to check. If the list contains lookup tables, a
	check-key must be provided to select the property to check when searching.

	If an invalid list, checkIndex or checkKey is passed, an empty list will be
	returned.
*/
function nestedSearch(list,value,matchCount=0,
                             checkIndex=undef,checkKey=undef) =
	/*
		Pass to a recursive sub-function the original arguments and a starting
		index (0) and match count (0). The function will return an index list.
	*/
	_nestedSearch_check(list,value,matchCount,0,0,checkIndex,checkKey);
	/*
		Recursive sub-function to go through the list and find all the matching
		items until the end of the list has been reached, at which point the
		index list is returned.
	*/
	function _nestedSearch_check(
		list,value,matchCount,i,m,checkIndex,checkKey) = 

		// if we have gone past the end or match-count has been satisfied...
		(nestedIsPastEnd(list) || (m>=matchCount && matchCount>0))
			
			// finish off with an empty list
			? []

		// otherwise
		:(
			// if the current list item matches the value being searched for
			(_nestedSearch_value(
				nestedHead(list),checkIndex,checkKey)==value)

				// prepend this index to the rest of the index list
				? nestedPrepend(i,
					_nestedSearch_check(
						nestedTail(list),value,matchCount,
						i+1,m+1,checkIndex,checkKey))

			// otherwise, if value does not match
				/*
					Keep searching, by calling this function again, passing the
					list tail and an incremented current-index.
				*/
				: _nestedSearch_check(
					nestedTail(list),value,matchCount,
					i+1,m,checkIndex,checkKey)
		);
	/*
		Sub-function to obtain the value to check against in finding the
		matching value. Handles the fact that the value may be a vector, where
		in such a case, a specified component index is used.
	*/
	function _nestedSearch_value(value,checkIndex,checkKey) = 
		// if a checkIndex is provided, use it
		(checkIndex!=undef) ? value[checkIndex]
		// if a checkKey is provided, use it
		:(checkKey!=undef) ? nestedLookup(value,checkKey)
		// otherwise, simply use value
		:value;
		
/*
	Removes an item from a list at a given index, returning a new list
	without the item. This function works by recursively going through the list
	items until the index has been reached, at which point the item is omitted
	by placing the next item in its place. If the index is out of bounds, an
	unmodified list will be returned. The index can be given as "end" to remove
	the last item.

	If the list is empty or invalid, an empty list will be returned. If the list
	only contains one item, an empty list will be returned if the index is 0
	or "end", otherwise, the original one-item list will be returned.
*/
function nestedRemove(list,index) = 

	// if the list is empty or invalid
	(nestedIsPastEnd(list))
		// return an empty list
		? []
	// otherwise, if the list valid and not empty
		/*
			Pass to a recursive sub-function the original arguments and a starting
			index (0). The function will return a list.
		*/
		:_nestedRemove_check(list,index,0);
	/*
		Recursive sub-function to go through the list until the index has been
		found, at which point the item at that index is "skipped/left-out".
	*/
	function _nestedRemove_check(list,index,i) = 

		// if we have gone past the end
		(nestedIsPastEnd(list))
			// terminate with an empty list
			? []
		// otherwise, if we have not gone past the end yet
		:(
			// if this item is to be skipped
			(i==index || (nestedIsEnd(list) && index=="end"))
				// skip this item and use the rest, by using the remaining tail
				? nestedTail(list)
			// otherwise, if this item is not to be skipped
				/*
					Add the current and rest of the checked items, by prepending
					the current head to the rest of the checked list, given by this
					function calling itself again, with the tail of the list and an
					incremented current-index.
				*/
				: nestedPrepend(nestedHead(list),
					_nestedRemove_check(
						nestedTail(list),index,i+1))
		);

/*
	Functions to find the minimum and maximum value of a list. If the item
	values are simply scalars, the minimum of their values is found. If they are
	vectors, the index of the component to compare must be specified. If the
	items are lookup tables, the key of the property to compare must be specified.

	If the only items present in the list are 'undef' values, 'undef' will be
	returned. If the list is invalid or empty, 'undef' will be returned.
*/
function nestedFindMin(list,checkIndex=undef,checkKey=undef) = 

	// use "min" mode to find smaller value
	_nestedFindMinOrMax_check(list,"min",checkIndex,checkKey);

function nestedFindMax(list,checkIndex=undef,checkKey=undef) = 

	// use "max" mode to find larger value
	_nestedFindMinOrMax_check(list,"max",checkIndex,checkKey);

	/*
		Sub-function to check the list passed. Only if the list is valid and non-
		empty will it be passed to the recursive sub-function.
	*/
	function _nestedFindMinOrMax_check(list,mode,checkIndex,checkKey) = 
		// if the list is invalid or empty
		(nestedIsPastEnd(list))
			// return 'undef'
			? undef
		// otherwise if the list is valid and non-empty
			// return the result of the recursive sub-function.
			: _nestedFindMinOrMax(list,0,undef,mode,checkIndex,checkKey);
	/*
		Recursive sub-function to go through the list, comparing the current
		min/max value and updating as necessary (with the index attached) until
		the end of the list has been reached, at which point the index for the
		last min/max value is returned.
	*/
	function _nestedFindMinOrMax(
		list,index,cvalue_index,mode,checkIndex,checkKey) = 

		// if we have gone past the end of the list
		nestedIsPastEnd(list)

			// return the index of the smallest/largest value
			? cvalue_index[1]

		// otherwise, if not past end yet
		:(
			// if current value is smaller than cvalue and mode is minimum
			((mode=="min")&&
				(_nestedFindMinOrMax_value(list[0],checkIndex,checkKey)
				 <_nestedFindMinOrMax_value(
					cvalue_index[0],checkIndex,checkKey))

			// if current value is larger than cvalue and mode is maximum
			||(mode=="max")&&
				(_nestedFindMinOrMax_value(list[0],checkIndex,checkKey)
				 >_nestedFindMinOrMax_value(
					cvalue_index[0],checkIndex,checkKey))

			// or if cvalue is undef and the current value is not undefined
			|| (cvalue_index==undef))
				&&(_nestedFindMinOrMax_value(
					list[0],checkIndex,checkKey)!=undef)

				// set new current min/max and continue going through elements
				? _nestedFindMinOrMax(
					list[1],index+1,[list[0],index],mode,checkIndex,checkKey)

			// otherwise, if current value is bigger/smaller

				// continue using old min/max
				: _nestedFindMinOrMax(
					list[1],index+1,cvalue_index,mode,checkIndex,checkKey)
		);
	/*
		Sub-function to obtain the value to compare in finding the min/max.
		Handles the fact that the value may be a vector, where in such a case,
		a specified component index is used.
	*/
	function _nestedFindMinOrMax_value(value,checkIndex,checkKey) = 
		// if a checkIndex is provided, use it
		(checkIndex!=undef) ? value[checkIndex]
		// if a checkKey is provided, use it
		:(checkKey!=undef) ? nestedLookup(value,checkKey)
		// otherwise, simply use value
		:value;

/*
	Returns an ascending- or descending-order sorted list from an unsorted list.
	This function works by recursively going through the list and ordering each
	item one index/position at a time. This is done using a sub-function which
	finds the min/max for a list and uses this value as the head of a new list,
	with the rest (given by the list with the min/max removed) appended. 'undef'
	values will be shifted to the end.

	If the values being sorted are vectors, an index for the sorted component
	must be specified (checkIndex). If the values are lookup tables, a key must
	be provided. If checkIndex is out-of-bounds or the key is not present, the
	original unmodified list will be returned. If the list passed is empty or
	invalid, an empty list will be returned.
*/
function nestedSort(list,descending=false,
                           checkIndex=undef,checkKey=undef) =
	// if the list is empty or invalid
	(nestedIsPastEnd(list))
		// return an empty list
		? []
	// otherwise, if the list is valid and non-empty
		/*
			Pass to a recursive sub-function the original arguments. The function
			will return a sorted list.
		*/
		: _nestedSort_foreach(list,descending,checkIndex,checkKey);
	/*
		Recursive sub-function to go through the list, finding the min/max item
		index, and passing this to another sub-function, which will construct the
		sorted list.
	*/
	function _nestedSort_foreach(list,descending,checkIndex,checkKey) = 

		// sub-function which will construct the sorted list
		_nestedSort_sort(

			// pass the original arguments
			list,descending,checkIndex,checkKey,

			// pass the index of the min/max based on the order
			descending==false?nestedFindMin(list,checkIndex,checkKey) 
			                 :nestedFindMax(list,checkIndex,checkKey));

	/*
		Sub-function which constructs the sorted list. This function works by
		prepending the min/max item to the rest of the list, which is given by the
		sorted form of the list with the min/max item removed.
	*/
	function _nestedSort_sort(list,descending,
	                                 checkIndex,checkKey,mIndex) = 

		// if min/max finding was unsuccessful (undef index)
		(mIndex==undef)

			// just finish with the rest of the list (which may have 'undef's)
			? list

		// if we have gone past the last item
		:(nestedIsPastEnd(list))

			// just finish the sorted list with an empty list
			? []

		// otherwise, if we are not past the last item yet
			// we want to prepend the min/max item onto the rest of the sorting
			: nestedPrepend(

				// use the min/max item as the head (prepend value)
				nestedGet(list,mIndex),
				/*
					Use the sorted list (as the tail / list being prepended to)
					given by calling the "foreach" function again, passing it the
					list with the min/max item removed.
				*/
				_nestedSort_foreach(
					nestedRemove(list,mIndex),
					descending,checkIndex,checkKey));

/******************************************************************************
                       L O O K U P   F U N C T I O N S
******************************************************************************/

/*
	Finds the value for a given key in a table. If more than one entry exists
	with the matching key, the first will be used. If the key is not found,
	'undef' will be returned.

	The table is a NESTED lookup table produced from nestedLookupCreate().
*/
function nestedLookup(table,key) =
	// want to get the value from a found index
	nestedGet(table,
		// search for the key
		nestedSearch(table,key,matchCount=1,checkIndex=0)
		// return the first match
		[0])
	// get the second element (first is key, we want the value)
	[1];

/*
	Creates a lookup table from a lookup table passed as a vector. This is
	simply a wrapper.
*/
function nestedLookupCreate(vector) = 
	// convert table to nested form
	nestedFromVec(vector);

/*
	Adds key-value entries to an existing lookup table. The new additions are
	passed as a vector, to allow more than one. If the keepOld flag is set to
	false and the key already exists, the existing entry will be removed and the
	new entry will be prepended to the start.
*/
function nestedLookupAdd(table,keyValueVector,keepOld=false) = 

	// if not a vector or the vector is empty, simply return an empty list
	(!(len(keyValueVector)>0)) ? []
	/*
		Pass to a sub-function the table with the existing matching-key entries
		optionally removed, the key-value vector, and a starting index and 
		vector length. This function will recursively go through the key-value
		vector and add the new entries to the table, returning the final table.
	*/
	:_nestedLookupAdd(
		// if the old matching entries are to be kept
		(keepOld)
			/*
				Pass the unmodified table. nestedLookup() uses the first match
				it finds - this means that any old entries with a matching key
				will be ignored.
			*/ 
			? table
		// otherwise, if the old matching entries are to be removed
			// pass the table with the matching entries removed
			: nestedLookupRemove(table,keyValueVector,$keyValue=true),

		// pass the key-value vector	
		keyValueVector,

		// pass the vector length and starting index
		len(keyValueVector),0);

	// sub-function to recursively go through the vector and add to the table
	function _nestedLookupAdd(table,keyValueVector,length,i) = 
	
		// if we have gone past the end of the vector
		(i>=length)

			// finish by returning the final modified table
			? table

		// otherwise, if we have elements to go through still
			/*
				Pass this function (in a recursive manner) the modified table, and
				incremented index.
			*/
			:_nestedLookupAdd(
				// we want to prepend the new entry to the table
				nestedPrepend(keyValueVector[i],table),
				// pass original vector and length
				keyValueVector,length,
				// pass incremented index
				i+1);

/*
	Removes key-value entries from an existing lookup table, given the keys
	specified as a vector. All matching entries, including those for keys with
	multiple entries, will be removed -- that is, all traces of the specified
	keys will be removed from the table.
*/
function nestedLookupRemove(table,keyVector) = 

	// if not a vector or the vector is empty, simply return original table
	(!(len(keyVector)>0)) ? (nestedIsPastEnd(table)?[]:table)
	/*
		Pass to a sub-function the table, the key vector, and a starting index
		and vector length. This function will recursively go through the key
		vector and remove the matching entries in the table, returning the final
		table.
	*/
	:_nestedLookupRemove(
		// the table (use [] if invalid)
		nestedIsPastEnd(table)?[]:table,
		// rest of the args
		keyVector,len(keyVector),0);

	// sub-function to recursively go through the key vector and remove entries
	function _nestedLookupRemove(table,keyVector,length,i) = 

		// if we have gone past the end of the vector
		(i>=length)

			// finish by returning the final modified table
			? table

		// otherwise, if we have elements to go through still

			// pass to a sub-function the first index of the matching key
			: _nestedLookupRemove_remove(
				// pass the original table, vector, length and index
				table,keyVector,length,i,
				// pass the first key-matching entry index
				nestedSearch(
					// the table to search through
					table,
					// the key to search for
					$keyValue==false ? keyVector[i] : keyVector[i][0],
					// only need to search for one index
					matchCount=1,
					// key is element 0 in each entry
					checkIndex=0)
					// use the first match
					[0]);
	/*
		Sub-function which removes a matching entry from the table. This sub-
		will call the _nestedLookupRemove() again (in a recursive manner),
		incrementing the index only if no matches were found. This allows all
		the matching entries for a key to be removed.
	*/
	function _nestedLookupRemove_remove(table,keyVector,
	                                       length,i,matchIndex) = 
		// if there was a match
		(matchIndex != undef)
			/*
				Call the original sub-function (_nestedLookupRemove())to check
				for more matches, passing it the table with the entry removed.
			*/
			? _nestedLookupRemove(
				// table with matching entry removed
				nestedRemove(table,matchIndex),
				// original arguments (with same index)
				keyVector,length,i)
		// otherwise, if there was not a match
			/*
				Call the original sub-function (_nestedLookupRemove()) to go
				through the other keys, passing an incremented index.
			*/
			: _nestedLookupRemove(table,keyVector,length,i+1);


/******************************************************************************
                         L I S T   M O D U L E S
******************************************************************************/

/*
	Module to allow simple iteration through a list. This module works by
	going through each item in the list and assigning a special variable $item
	with the current item, constructing the children each iteration. This works
	because variables prefixed with '$' have dynamic scope, and are "effectively
	automatically passed onward as arguments" (OpenSCAD User Manual).

	NOTE: To have more than one child passed to this module, it must be within a
	union() or some other block.
*/
module nestedForEach(list)
{
	// if we are not past the last item
	if (!nestedIsPastEnd(list))

		// assign the item value to the dynamic-scoped variable
		assign($item = nestedHead(list))
		{
			// create the child
			child(0);

			// call this module again, but passing it the tail of the list
			nestedForEach(nestedTail(list))

				// and pass it the original child
				child(0);
		}
}
