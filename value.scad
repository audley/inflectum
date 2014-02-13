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
	This file contains special-number constants, functions to check for
	special numbers, functions to check if a value is a certain type, and
	functions to filter values.

	Special-Number Constants:
		inf
		nan
	Number Functions:
		function isPosInf(value)
		function isNegInf(value)
		function isNan(value)
		function isNumber(value)
		function number(value)
	String Functions:
		function isString(value)
		function string(value)
	Boolean Functions:
		function isBoolean(value)
		function boolean(value)
*/

/******************************************************************************
             S P E C I A L - N U M B E R   C O N S T A N T S
******************************************************************************/

/*
	Positive 'inf' can be given by a positive non-zero number divided by zero.
	Can be negated to give -inf.
*/
inf = (1/0);

/*
	'nan' can be given by zero divided by zero.
*/
nan = (0/0);

/******************************************************************************
                     N U M B E R   F U N C T I O N S
******************************************************************************/

/*
	Returns true if the value passed is positive infinity. This check works
	because two '+inf' values can be compared.
*/
function isPosInf(value) = (value==inf);

/*
	Returns true if the value passed is negative infinity. This check works
	because two '-inf' values can be compared.
*/
function isNegInf(value) = (value==-inf);

/*
	Returns true if the value passed is 'nan'. Because 'nan' cannot be compared
	with another nan, the value is determined to be 'nan' if it is not below,
	equal to or above zero. 

	Vector values are made to return false. An extra check for 'undef', vector/
	string and boolean values is also performed.
*/
function isNan(value) =
	!(value<0) && !(value>0) && !(value==0)
		&& len(value)==undef && value!=undef && isBoolean(value)==false;

/*
	Returns true if the value passed is a normal number (not inf or nan),
	otherwise the function returns false.
*/
function isNumber(value) = 
	(len(value)!=undef) ? false
	:(value==undef) ? false
	:(isBoolean(value)) ? false
	:(isPosInf(value)||isNegInf(value)||isNan(value)) ? false
	: true;
/*
	Returns undef if a given value is +/-inf, nan or a vector. Otherwise, the
	original number is returned. Allows special values to be filtered out and
	treated as normal undefs.
*/
function number(value) = isNumber(value) ? value : undef;

/******************************************************************************
                        S T R I N G   F U N C T I O N S
******************************************************************************/

/*
	Returns true if the value passed is a string, otherwise returns false. This
	check is done by seeing whether the string form of the value is the same as
	the value.
*/
function isString(value) = str(value)==value;

/*
	Returns undef if the value is not a string, otherwise the value is returned.
*/
function string(value) = isString(value) ? value : undef;

/******************************************************************************
                       B O O L E A N   F U N C T I O N S
******************************************************************************/

/*
	Returns true if the value passed is a boolean, otherwise returns false.
*/
function isBoolean(value) = value==true || value==false;

/*
	Returns undef if the value is not a boolean, otherwise the boolean value is
	returned.
*/
function boolean(value) = isBoolean(value) ? value : undef;
