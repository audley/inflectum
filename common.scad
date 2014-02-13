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

/*
	Functions:
		function _(value)
		function RETURN(value)
		function IF(expression)
		function THEN(value)
		function ELSE_IF(expression)
		function ELSE(value)
*/

/******************************************************************************
                    G E N E R A L   F U N C T I O N S
******************************************************************************/

/*
	Dummy functions, which return the value of the argument passed. These can
	be used to form module-like structural code whithin functions:

		function someFunction(a,b) = _
		(
			$c = a*b,	$d = a+b,
		
			IF (a>b) ? THEN
			(
				$value = str("a>b,",$c,",",$d),
				RETURN ($value)
			)
			:ELSE_IF (a==b) ? THEN
			(
				$value = str("a==b,",$c,",",$d),
				RETURN ($value)
			)
			:ELSE_IF (a<b) ? THEN
			(
				$value = str("a<b,",$c,",",$d),
				RETURN ($value)
			)
			:ELSE
			(
				$value = str("?,",$a,",",$b),
				RETURN ($value)
			)
		);

	To work with "variables" within the function, dynamic-scope arguments are
	assigned with explicit parameter names (with the $ prefix). In addition,
	commas need to be placed at the end of each line, as the values are really
	being passed around as parameters - commas are not needed on the last line
	though. Nesting can be achieved by using the _() or conditional functions
	within an existing call.
*/
function _(value)            = value;
function RETURN(value)       = value;
function IF(expression)      = expression;
function THEN(value)         = value;
function ELSE_IF(expression) = expression;
function ELSE(value)         = value;
