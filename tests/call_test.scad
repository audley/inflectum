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

use <../test.scad>

/*
   Test Group: call() Function
      function call(name,a0,a1,a2...)
*/

/******************************************************************************
                    C A L L   F U N C T I O N   T E S T
******************************************************************************/

// files which contain the tests
use <files/call1.scad>
use <files/call3.scad>
use <files/call4.scad>

testGroup("call() Function")
{
   testSet("call","indirect test - register and wrap in same file",
   [testCase("two arguments",[],"FUNCTION0: 1,2")])
	testFunction(call1_test1());

	testSet("call","indirect test - register and wrap in same file",
   [testCase("three arguments",[],"FUNCTION1: 3,4,5")])
	testFunction(call1_test2());

	testSet("call","indirect test - register and wrap in same file",
   [testCase("unknown function",[],undef)])
	testFunction(call1_test3());

	testSet("call",
	"indirect test - register and wrap in seperate files",
   [testCase("two arguments",[],"FUNCTION2: 6,7")])
	testFunction(call3_test1());

	testSet("call",
	"indirect test - register and wrap in seperate files",
   [testCase("three arguments",[],"FUNCTION3: 8,9,10")])
	testFunction(call3_test2());

	testSet("call",
	"indirect test - registration with previous registration",
   [testCase("previous function 0 - direct and indirect",[],
	"FUNCTION4: undef; FUNCTION0: 1,2")])
	testFunction(call4_test1());

	testSet("call",
	"indirect test - registration with previous registration",
   [testCase("previous function 0 - direct and indirect",[],
	"FUNCTION5: undef; FUNCTION1: 3,4,5")])
	testFunction(call4_test2());

// end of test group
}
