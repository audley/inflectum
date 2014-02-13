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
	This file contains wrappers for functions which use the map(), map2(),
	foldl(), foldr(), filter() and filter2() functions (the functions which
	require sub-functions to be registered). This file is included by main.scad
	to satisfy the dependencies of the functions. This file is also included
	by wrap-main.scad (which is "used" by list.scad) to provide files, which
	include list.scad, with access to these functions.

   Functions:
		function slice(list,range)
		function removeMulti(list,indexes)
		function listSimplify(list,bounds=undef)
		function sort(list,descending=false,index=undef,key=undef)
		function lookupRemoveMulti(keys,table)
		function lookupFilter(table)
*/

/******************************************************************************
                        L I S T   F U N C T I O N S
******************************************************************************/

function slice(list,range) = _slice(list,range);
function removeMulti(list,indexes) = _removeMulti(list,indexes);
function listSimplify(list,bounds=undef) = _listSimplify(list,bounds);
function sort(list,descending=false,index=undef,key=undef) =
	_sort(list,descending,index,key);

/******************************************************************************
                       L O O K U P   F U N C T I O N S
******************************************************************************/

function lookupRemoveMulti(keys,table) = _lookupRemoveMulti(keys,table);
function lookupFilter(table) = _lookupFilter(table);
