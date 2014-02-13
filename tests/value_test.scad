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

include <../test.scad>
include <../value.scad>
   
/*
   Test Group: Number Functions
      function isPosInf(value)
      function isNegInf(value)
      function isNan(value)
		function isNumber(value)
      function number(value)
   Test Group: String Functions
		function isString(value)
		function string(value)
	Test Group: Boolean Functions
		function isBoolean(value)
		function boolean(value)
*/

/******************************************************************************
                      N U M B E R   F U N C T I O N S
******************************************************************************/

/*
   Key tests: special and normal values, non-numbers & vectors.
*/

testGroup("Number Functions")
{
   testSet("isPosInf","direct test",[
      testCase("vector",[[0,0]],false),
		testCase("boolean true",[true],false),
		testCase("boolean false",[false],false),
      testCase("number",[5],false),
      testCase("positive inf",[inf],true),
      testCase("negative inf",[-inf],false),
      testCase("nan",[nan],false),
      testCase("undef",[undef],false),
		testCase("string",["abc"],false),
		testCase("empty string",[""],false)])
   testFunction(isPosInf($value[0]));

   testSet("isNegInf","direct test",[
      testCase("vector",[[0,0]],false),
		testCase("boolean true",[true],false),
		testCase("boolean false",[false],false),
      testCase("number",[5],false),
      testCase("positive inf",[inf],false),
      testCase("negative inf",[-inf],true),
      testCase("nan",[nan],false),
      testCase("undef",[undef],false),
		testCase("string",["abc"],false),
		testCase("empty string",[""],false)])
   testFunction(isNegInf($value[0]));

   testSet("isNan","direct test",[
      testCase("vector",[[0,0]],false),
		testCase("boolean true",[true],false),
		testCase("boolean false",[false],false),
      testCase("number",[5],false),
      testCase("positive inf",[inf],false),
      testCase("negative inf",[-inf],false),
      testCase("nan",[nan],true),
      testCase("undef",[undef],false),
		testCase("string",["abc"],false),
		testCase("empty string",[""],false)])
   testFunction(isNan($value[0]));

	testSet("isNumber","direct test",[
      testCase("vector",[[0,0]],false),
		testCase("boolean true",[true],false),
		testCase("boolean false",[false],false),
      testCase("number",[5],true),
      testCase("positive inf",[inf],false),
      testCase("negative inf",[-inf],false),
      testCase("nan",[nan],false),
      testCase("undef",[undef],false),
		testCase("string",["abc"],false),
		testCase("empty string",[""],false)])
   testFunction(isNumber($value[0]));

   testSet("number","direct test",[
      testCase("vector",[[0,0]],undef),
		testCase("boolean true",[true],undef),
		testCase("boolean false",[false],undef),
      testCase("positive number",[5],5),
      testCase("negative number",[-5],-5),
      testCase("positive inf",[inf],undef),
      testCase("negative inf",[-inf],undef),
      testCase("nan",[nan],undef),
      testCase("undef",[undef],undef),
		testCase("string",["abc"],undef),
		testCase("empty string",[""],undef)])
   testFunction(number($value[0]));

// end of test group
}

/******************************************************************************
                      S T R I N G   F U N C T I O N S
******************************************************************************/

/*
   Key tests: normal string, empty string, non-strings & vectors.
*/

testGroup("String Functions")
{
   testSet("isString","direct test",[
      testCase("vector",[[0,0]],false),
		testCase("boolean true",[true],false),
		testCase("boolean false",[false],false),
      testCase("number",[5],false),
      testCase("positive inf",[inf],false),
      testCase("negative inf",[-inf],false),
      testCase("nan",[nan],false),
      testCase("undef",[undef],false),
		testCase("string",["abc"],true),
		testCase("empty string",[""],true)])
   testFunction(isString($value[0]));

	testSet("string","direct test",[
      testCase("vector",[[0,0]],undef),
		testCase("boolean true",[true],undef),
		testCase("boolean false",[false],undef),
      testCase("number",[5],undef),
      testCase("positive inf",[inf],undef),
      testCase("negative inf",[-inf],undef),
      testCase("nan",[nan],undef),
      testCase("undef",[undef],undef),
		testCase("string",["abc"],"abc"),
		testCase("empty string",[""],"")])
   testFunction(string($value[0]));

// end of test group
}

/******************************************************************************
                      B O O L E A N   F U N C T I O N S
******************************************************************************/

/*
   Key tests: true & false, non-booleans & vectors.
*/

testGroup("Boolean Functions")
{
   testSet("isString","direct test",[
      testCase("vector",[[0,0]],false),
		testCase("boolean true",[true],true),
		testCase("boolean false",[false],true),
      testCase("number",[5],false),
      testCase("positive inf",[inf],false),
      testCase("negative inf",[-inf],false),
      testCase("nan",[nan],false),
      testCase("undef",[undef],false),
		testCase("string",["abc"],false),
		testCase("empty string",[""],false)])
   testFunction(isBoolean($value[0]));

	testSet("string","direct test",[
      testCase("vector",[[0,0]],undef),
		testCase("boolean true",[true],true),
		testCase("boolean false",[false],false),
      testCase("number",[5],undef),
      testCase("positive inf",[inf],undef),
      testCase("negative inf",[-inf],undef),
      testCase("nan",[nan],undef),
      testCase("undef",[undef],undef),
		testCase("string",["abc"],undef),
		testCase("empty string",[""],undef)])
   testFunction(boolean($value[0]));

// end of test group
}
