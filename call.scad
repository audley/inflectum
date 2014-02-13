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

/*
	This file provides a way to call functions by name, provided that they are
	"registered" before use. To call functions by name, this file needs to be
	included (using 'include') by the file that is "registering" the functions.
	To ensure that the registered functions are not overrided by further
	registration, the file, which registers the functions and includes this
	file, needs to included by other files using 'use' rather than 'include'.

	To register a function, include this file and assign the names of the
	functions and define the functions like so:
	
		// file1.scad
		include <function.scad>

		// registration
		$function0 = "someFunction0";
		function $function0(a0,a1,...) = someFunction0(a0,a1,...);
		$function1 = "someFunction1";
		function $function1(a0,a1,a2,...) = someFunction1(a0,a1,a2,...);
		...

		// functions
		function someFunction0(a0,a1,...) = ...
		function someFunction1(a0,a1,a2,...) = ...
		...

	Then, within the same file (scope), the functions which make use of the
	call() function are also declared. Alternatively, the file can be included
	by another file which calls the functions (as long as no overriding functions
	are registered). To include the file which registers functions into another
	file which registers its own functions, the file must be included using "use":

		// file2.scad
		include <function.scad>
		use <file1.scad> // must be "use"
		...

	In this case, call() cannot be used to access to registered functions of the
	included file in the file including the file.

	To check whether a function is registered (within the current scope), use the
	callIsRegistered() function.
*/

/*******************************************************************************
                      M A I N   C A L L   F U N C T I O N
*******************************************************************************/

/*
	Calls a "registered" function via its name with given arguments. This
	function must be declared within the module-scope of the functions being
	"registered" (by "including" this file).
*/
function call(name,a0,a1,a2,a3,a4,a5) =
	IF (name==undef) ? THEN (undef)
	:ELSE_IF ($function0  == name) ? THEN ($function0(a0,a1,a2,a3,a4,a5))
	:ELSE_IF ($function1  == name) ? THEN ($function1(a0,a1,a2,a3,a4,a5))
	:ELSE_IF ($function2  == name) ? THEN ($function2(a0,a1,a2,a3,a4,a5))
	:ELSE_IF ($function3  == name) ? THEN ($function3(a0,a1,a2,a3,a4,a5))
	:ELSE_IF ($function4  == name) ? THEN ($function4(a0,a1,a2,a3,a4,a5))
	:ELSE_IF ($function5  == name) ? THEN ($function5(a0,a1,a2,a3,a4,a5))
	:ELSE_IF ($function6  == name) ? THEN ($function6(a0,a1,a2,a3,a4,a5))
	:ELSE_IF ($function7  == name) ? THEN ($function7(a0,a1,a2,a3,a4,a5))
	:ELSE_IF ($function8  == name) ? THEN ($function8(a0,a1,a2,a3,a4,a5))
	:ELSE_IF ($function9  == name) ? THEN ($function9(a0,a1,a2,a3,a4,a5))
	:ELSE_IF ($function10 == name) ? THEN ($function10(a0,a1,a2,a3,a4,a5))
	:ELSE_IF ($function11 == name) ? THEN ($function11(a0,a1,a2,a3,a4,a5))
	:ELSE_IF ($function12 == name) ? THEN ($function12(a0,a1,a2,a3,a4,a5))
	:ELSE_IF ($function13 == name) ? THEN ($function13(a0,a1,a2,a3,a4,a5))
	:ELSE_IF ($function14 == name) ? THEN ($function14(a0,a1,a2,a3,a4,a5))
	:ELSE (undef);

/*******************************************************************************
              R E G I S T E R - C H E C K   F U N C T I O N
*******************************************************************************/

/*
	Returns true if the function (given by name) is registered, otherwise if it
	is unknown, false is returned.
*/
function callIsRegistered(name) = 
	   ($function0  == name) || ($function1  == name) || ($function2  == name)
	|| ($function3  == name) || ($function4  == name) || ($function5  == name)
	|| ($function6  == name) || ($function7  == name) || ($function8  == name)
	|| ($function9  == name) || ($function10 == name) || ($function11 == name)
	|| ($function12 == name) || ($function13 == name) || ($function14 == name);
