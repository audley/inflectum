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
include <../list.scad>

/*
   Test Group: List Functions
		function isEmpty(list)
		function length(list)
		function map(fname,list)
		function flatten(list,bounds=undef)
		function flattenNested(list)
		function isRange(range)
		function listFromRange(range,end=undef)
*/

/******************************************************************************
                     L I S T   F U N C T I O N   T E S T S
******************************************************************************/

/*
   Key tests: Undefined items in the lists, undefinded/scalar lists,
              undefined/invalid value/index args, empty lists,
              special values (+/-inf,nan,undef), ranges, START, END
*/

/*
	Functions to test the map(), foldl(), foldr() and filter() functions with.
	These shouldn't be changed, unless changes are also made to the expected
	results in the tests below.
*/
$function0  = "test_map_1";     function $function0(item)       = [item];
$function1  = "test_map_2";     function $function1(item,index) = [item,index];

/*
   Some of the lists to test the functions with. These shouldn't be changed,
   unless changes are also made to the expected results in the tests below.
*/
assign(LIST1 = [3,4,5,6,7],
       LIST2 = [[4,9],[3,8],[5,0],[7,1],[8,4]],
       LIST3 = [3,4,3,6,7,3,9],
       LIST4 = [0,1,2,3,4,5,6,7,8,9],
       LIST5 = [[1,2,3],[4,5,6],[7,8,9]],
       LIST6 = [[1,2,3],[4,5,6],[7,8,9]],
       LIST7 = [[0,0,3],[-1,1,2],[0,1,0]])
testGroup("List Functions")
{
   // LIST1 = [3,4,5,6,7]
   testSet("isEmpty","direct test",[
      testCase(">1 item list",[LIST1],false),
      testCase("1 item list",[[1]],false),
      testCase("undef list",[undef],true),
      testCase("scalar as list",[5],true),
      testCase("empty list",[[]],true)])
   testFunction(isEmpty($value[0]));
   
   // LIST1 = [3,4,5,6,7];
   testSet("length","direct test",[
      testCase("normal list",[LIST1],5),
      testCase("undef list",[undef],0),
      testCase("scalar as list",[5],0),
      testCase("empty list",[[]],0)])
   testFunction(length($value[0]));
   
	// test_map_1(item) = [item]
	// test_map_2(item,index) = [item,index]
	// LIST1 = [3,4,5,6,7];
	testSet("map","direct test",[
      testCase("normal 1",["test_map_1",LIST1],[[3],[4],[5],[6],[7]]),
		testCase("normal 2, with index",["test_map_2",LIST1],
			[[3,0],[4,1],[5,2],[6,3],[7,4]]),
      testCase("undef list",["test_map_1",undef],[]),
		testCase("empty list",["test_map_1",[]],[]),
		testCase("unregistered function",["zzz",LIST1],LIST1)])
   testFunction(map($value[0],$value[1]));

	testSet("flatten","direct test",[
      testCase("lists of numbers",
			[[[1,2,3,4],[5,6,7,8]]],[1,2,3,4,5,6,7,8]),
		testCase("lists of ranges",[[[1:4],[5:8]]],[1,2,3,4,5,6,7,8]),
		testCase("number lists and empty lists",
			[[[1,2],[],[3,4],[]]],[1,2,3,4]),
      testCase("bounded infinite ranges",
			[[[4:END],[START:END]],[0:5]],[4,5,0,1,2,3,4,5]),
      testCase("empty lists",[[[],[],[],[]]],[]),
      testCase("undef list",[undef],[]),
		testCase("scalar list",[5],[]),
		testCase("empty value list",[[]],[])])
   testFunction(flatten($value[0],$value[1]));

	testSet("isRange","direct test",[
      testCase("vector",[[1,2,3,4,5]],false),
		testCase("range",[[1:8]],true),
		testCase("infinite-bounds range",[[START:END]],true),
		testCase("invalid range",[[undef:END]],false),
		testCase("scalar",[5],false),
      testCase("undef",[undef],false),
		testCase("empty",[[]],false)])
   testFunction(isRange($value[0]));

	testSet("listFromRange","direct test",[
      testCase("vector",[[1,2,3,4,5]],[]),
		testCase("range",[[1:8]],[1,2,3,4,5,6,7,8]),
		testCase("range & bad end",[[1:1:-8]],[]),
		testCase("range with explicit step",[[1:3:8]],[1,4,7]),
		testCase("range with negative step",
			[[0:-1:-8]],[0,-1,-2,-3,-4,-5,-6,-7,-8]),
		testCase("range with negative step & bad end",[[0:-1:8]],[]),
		testCase("infinite-bounds range and specified limits",
			[[START:END],[-4:5]],[-4,-3,-2,-1,0,1,2,3,4,5]),
		testCase("infinite-bounds range and specified limits",
			[[END:-1:START],[-4:5]],[5,4,3,2,1,0,-1,-2,-3,-4]),
		testCase("invalid range",[[undef:END]],[]),
		testCase("scalar",[5],[]),
      testCase("undef",[undef],[]),
		testCase("empty",[[]],[])])
   testFunction(listFromRange($value[0],$value[1]));

// end of test group
}
