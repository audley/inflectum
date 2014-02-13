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
	This file is included by list.scad using "use". This file, while including
	the main list funcitons (main.scad), specifically binds wrapper functions
	from wrap.scad to the functions provided by registered.scad. This wrapping
	is done to prevent any call() register issues.
*/

/******************************************************************************
                        L I S T   F U N C T I O N S
******************************************************************************/

/*
	To include main list functions. External dependencies include:

		function _slice(list,range)
		function _removeMulti(list,indexes)
		function _listSimplify(list,bounds=undef)
		function _sort(list,descending=false,index=undef,key=undef)
		function _lookupRemoveMulti(keys,table)
		function _lookupFilter(table)

	These dependencies are satisfied by 'registered.scad'.
*/
include <main.scad>

/*
	To wrap around list functions making direct use of map(), foldl(), foldr()
	and filter(). External dependencies include:

		function _slice(list,range)
		function _removeMulti(list,indexes)
		function _listSimplify(list,bounds=undef)
		function _sort(list,descending=false,index=undef,key=undef)
		function _lookupRemoveMulti(keys,table)
		function _lookupFilter(table)

	These dependencies are satisfied by 'registered.scad'.
*/
include <wrap.scad>

/*
	Provides the functions which are wrapped. These are scoped to this file.
*/
use <registered.scad>
