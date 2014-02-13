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
	These functions are "wrapped" by the list.scad to allow access to the
	original lookup() and search() functions, which are overrided by versions
	from main.scad.

	Functions:
		function __lookup(key,key_values)
		function __search(value,vector,matches,index)
*/

/******************************************************************************
                     A L I A S E D   F U N C T I O N S
******************************************************************************/

function __lookup(key,key_values) = lookup(key,key_values);
function __search(value,vector,matches,index) =
	search(value,vector,matches,index);
