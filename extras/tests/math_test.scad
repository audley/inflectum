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

include <../../test.scad>
include <../math.scad>
   
/*
   Test Group: Vector Math Functions
      function zero(line)
      function intersection(line1,line2)
*/

/******************************************************************************
                  V E C T O R   F U N C T I O N   T E S T S
******************************************************************************/

/*
   Key tests: basic vectors, null/undef/scalar/empty vectors/lines,
              coincident lines
*/

testGroup("Vector Math Functions")
{
   testSet("zero","direct test",[
      testCase("point",[[[0,0],[0,0]]],undef),
      testCase("line through origin",[[[5,2],[-5,-2]]],0),
      testCase("line through x=2",[[[7,2],[-3,-2]]],2),
      testCase("vertical line not crossing y=0",[[[10,3],[10,2]]],10),
      testCase("vertical line crossing y=0",[[[8,3],[8,-1]]],8),
      testCase("undef line",[undef],undef),
      testCase("scalar as line",[5],undef),
      testCase("empty line",[[]],undef)])
   testFunction(zero($value[0]));
   
   testSet("intersection","direct test",[
      testCase("coincident lines",
         [[[0,0],[40,0]],[[0,0],[40,0]]],undef),
      testCase("perpendicular lines, crossing",
         [[[10,10],[40,10]],[[20,30],[20,-10]]],[20,10]),
      testCase("perpendicular lines, not crossing",
         [[[10,10],[15,10]],[[20,30],[20,-10]]],[20,10]), // ***
      testCase("X",[[[-10,10],[10,-10]],[[10,10],[-10,-10]]],[0,0]),
      testCase("single undef line",[undef,[[10,10],[-10,-10]]],undef),
      testCase("scalar as line",[5, [[10,10],[-10,-10]]],undef),
      testCase("empty line",[[],[[10,10],[-10,-10]]],undef)])
   testFunction(intersection($value[0],$value[1]));

// end of test group
}
