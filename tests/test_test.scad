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

/*
   Test Group: Formatting Function and Module Tests
      function testFormatHTML(value,quotes=true)
      function testFormatList(list,quotes=true)
      function testFormattedStatus(name,clr)
      module testErrorMessage(message)
      module testDetails(name,details)
   Test Group: Empty Test Group
      (focus: no test sets)
   Test Group: Test Group 1
      (focus: empty test set)
      module testSet(name,desc,testCases)
   Test Group: Test Group 2
      (focus: function test)
      module testSet(name,desc,testCases)
      function testCase(desc,values,expect=undef)
      module testFunction(result)
   Test Group: Test Group 3
      (focus: module test)
      module testSet(name,desc,testCases)
      function testCase(desc,values,expect=undef)
      module testModule(offsetStart,offsetStep)
   Test Group: Test Group 4
      (focus: more than one test set)
      module testSet(name,desc,testCases)
      function testCase(desc,values,expect=undef)
      module testFunction(result)
   Test Group: Test Group 4
      (focus: manual checking)
      module testSet(name,desc,testCases)
      function testCase(desc,values,expect=undef)
      module testFunction(result,manual=false)
*/

/******************************************************************************
                               T E S T S
******************************************************************************/

// formatting tests
testGroup("Formatting Function and Module Tests");
{
   echo(str("<b>",testFormatHTML(5),"</b>"));
   echo(str("<b>",testFormatHTML([1,2]),"</b>"));
   echo(str("<b>",testFormatHTML([1,2,"abc",[4,5,6]]),"</b>"));
   echo(str("<b>",testFormatHTML([]),"</b>"));
   echo(str("<b>",testFormatHTML("hello"),"</b>"));
   echo(str("<b>",testFormatHTML("hello",false),"</b>"));
   echo(str("<b>",testFormatHTML(""),"</b>"));
   echo(testFormatList([1,2,3]));
   echo(testFormatList([]));
   echo(testFormattedStatus("OK","green"));
   echo(testFormattedStatus("MANUAL","orange"));
   echo(testFormattedStatus("FAIL","red"));
   testErrorMessage("<error message>");
   testDetails("Name","some details...");
   
}

// empty test group
testGroup("Empty Test Group");

// test group with one empty test set
testGroup("Test Group 1")
{
   testSet("someFunction","(no test cases)");
}

// successful and unsuccessful function result
testGroup("Test Group 2")
{
   testSet("someFunction","some description",[
      testCase("successful test 1",[1,2,3,4,5],[1,2,3,4,5]),
      testCase("unsuccessful test 2",[1,2,3,4,5],"intended failure")
   ]) testFunction($value);
}

// module tests
testGroup("Test Group 3")
{
   testSet("someModule","some description",[
      testCase("test 1",[0,4,8,12,16],"something"),
      testCase("test 1",[10,20,30,40,50],"something different"),
      testCase("test 1",[10,15,20,25,30],"something different again")
   ]) testModule([0,10,0],[0,5,0])
      for (i = $value)
         translate([i*2,0,0]) cube(4);
}

// more than one function test set
testGroup("Test Group 4")
{
   testSet("someFunction1","some description 1",[
      testCase("description 1 1",[1,2,3,4,5],[1,2,3,4,5]),
      testCase("description 1 2",[1,2,3,2,1],[1,2,3,2,1])
   ]) testFunction($value);

   testSet("someFunction2","some description 2",[
      testCase("description 2 1",[5,3],15),
      testCase("description 2 2",[2,6],12)
   ]) testFunction($value[0]*$value[1]);
}

// tolerance test by manual checking
testGroup("Test Group 5")
{
   testSet("someFunction","some description",[
      testCase("exact",[0,0],[0,0]),
      testCase("not whithin tolerance (intended failure)",
         [0,0.1],[0,0]),
      testCase("whithin tolerance",[0,0.001],[0,0])
   ]) testFunction($value,manual=true);
}
