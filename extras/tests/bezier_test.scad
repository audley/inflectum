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
include <../bezier.scad>

/*
   Test Group: 2D Bezier Module
      (function bezierSegment(points,t0,t1))
      module bezierShape(points1=false,points2=false,
                         focalLine=false,debug=false)
         Focuses:
            merging points, focus line, debug points
            circle approximation, $fs, segment bad shapes
   Test Group: 3D Extruded Bezier Module
      module bezierShape(points1=false,points2=false,
		                   focalLine=false,debug=false)
         Focuses:
            linear extrude, rotate extrude

   Indirectly tested functions:
      function bezierStatT(points)

*/

/******************************************************************************
                   2 D   B E Z I E R   M O D U L E   T E S T
******************************************************************************/

/*
   Key tests: circle approximation, segment, focal line, debug,
              resolution/detail via $fs, bad shapes
*/

/*
   Some of the constants used in the 2D tests. These shouldn't be changed,
   unless changes are also made to the expected results in the tests.
*/
CA_DIAM     = 30; // circle-approximation test diam
CA_DIST     = CA_DIAM/2*sqrt(2); // dist between circle-approx end-points
CA_OFST     = CA_DIAM/2/sqrt(2)+20; // y ofst of circle from end-point line
PATH1       = [[0,0], 45,[40,0],-45];
PATH2       = [[0,0],-45,[40,0], 45];
PATH3       = [[0,0], 90,[40,0],-90];
PATH4       = [[0, 20],0,[40,-20],0]; // overlapping
PATH5       = [[0,-20],0,[40, 20],0]; // overlapping
PATH6       = [[0,10],45,[40,10],45]; // left -> right
PATH7       = [[40,-10],180+45,[0,-10],180+45]; // right -> left
FOCAL1      = [[0,0],[40,0]];
CA_PATH     = [[0,20],-45,[CA_DIST,20],45];
CA_FOCAL    = [[0,0],[CA_DIST,0]];
POINTS1     = bezierControlPoints(PATH1);
POINTS2     = bezierControlPoints(PATH2);
POINTS3     = bezierControlPoints(PATH3);
POINTS4     = bezierControlPoints(PATH4);
POINTS5     = bezierControlPoints(PATH5);
POINTS6     = bezierControlPoints(PATH6);
POINTS7     = bezierControlPoints(PATH7);
CA_POINTS   = bezierControlPoints(CA_PATH);
POINTS1_SEG = bezierSegment(POINTS1,0.25,0.75);
POINTS2_SEG = bezierSegment(POINTS2,0.25,0.75);

testGroup("2D Bezier Module")
{
   // Focus: merging points, focal line, debug points
   testSet("bezierShape",
      "Test merging points, focus line, debug points",[
      testCase("two curved paths",[POINTS1,POINTS2,false,true],
         str("two-sided curved solid - there should be no warnings, where ",
             "trianges have been used at each end as a result of the points ",
             "on a side merging.")),
      testCase("lower path and focal line 1",
         [POINTS1,false,FOCAL1,true],"half of first solid"),
      testCase("lower path and focal line 2",
         [false,POINTS1,FOCAL1,true],"half of first solid"),
      testCase("upper path and focal line 1",
         [POINTS2,false,FOCAL1,true],"other half of first solid"),
      testCase("upper path and focal line 2",
         [false,POINTS2,FOCAL1,true],"other half of first solid")
   ])testModule([0,0],[50,0])
         bezierShape($value[0],$value[1],$value[2],$value[3]);

   // Focus: circle approximation
   testSet("bezierShape",
      "test circle approximation (as a result of the curve factor)",[
      testCase("circle approximation",
         [CA_POINTS,false,CA_FOCAL,true],"")
   ])testModule([0,-60],[0,0])
   {
      // create curve
      bezierShape($value[0],$value[1],$value[2],$value[3]);
         
      // test with circle
      color("grey",0.5) translate([CA_DIST/2,CA_OFST+0.5])
         circle(CA_DIAM/2);
   }
   
   // Focus: $fs
   testSet("bezierShape",
      "Test fragment size",[
      testCase("tangent start/end angles at 90 degrees",
         [POINTS3,false,FOCAL1,false,2],
         "As $fs->0, the start and end angles should -> +/-90 degrees"),
      testCase("tangent start/end angles at 90 degrees",
         [POINTS3,false,FOCAL1,false,1]),
      testCase("tangent start/end angles at 90 degrees",
         [POINTS3,false,FOCAL1,false,0.5]),
   ])testModule([50,-40],[50,0])
   {
      bezierShape($value[0],$value[1],$value[2],$value[3],$fs=$value[4]);
      color("blue",0.5) translate([0,0,-2.5]) cube([$value[4],$value[4],5]);
   }

   // Focus: segment
   testSet("bezierSegment",
      str("Test bezier segment function inflectumBezierSegment by",
          "overlaying part of a cuve on a complete one"),[
      testCase("bezier segment",
         [POINTS1_SEG,POINTS2_SEG,false,false,POINTS1,POINTS2,false,false],
         "Bezier segment should be part of the original."),
   ])testModule([50,-60],[0,0])
   {
      color("orange") 
         bezierShape(
            $value[0],$value[1],$value[2],$value[3]); // part
      color("yellow",0.25)
         bezierShape(
            $value[4],$value[5],$value[6],$value[7]); // orig
   }

   // Focus: bad shapes
   testSet("bezierShape",
      "Odd / bad (in terms of difficulty) shapes, with overlap",[
      testCase("overlapping sides", [POINTS4,POINTS5,false,true],
         "no pink faces in thrown-together view..."),
      testCase("overlapping sides", [POINTS6,POINTS7,false,true])
   ])
   testModule([100,-80],[50,0])
   {
      bezierShape($value[0],$value[1],$value[2],$value[3]);
   }
// end of test group
}

/******************************************************************************
               3 D   E X T R U D E D   B E Z I E R   M O D U L E
******************************************************************************/

/*
   Some of the constants used in the 3D tests. These shouldn't be changed,
   unless changes are also made to the expected results in the tests.
*/
PATH2_1     = [[0,0], 45,[40,0],-45];
PATH2_2     = [[0,0],-45,[40,0], 45];
PATH2_R1    = [[0,0],45,[0,40], 135];
PATH2_R2    = [[15,0],135,[15,40], 45];
FOCAL2_1    = [[0,0],[40,0]];
FOCAL2_R    = [[0,0],[0,40]];
POINTS2_1   = bezierControlPoints(PATH2_1);
POINTS2_2   = bezierControlPoints(PATH2_2);
POINTS2_R1  = bezierControlPoints(PATH2_R1);
POINTS2_R2  = bezierControlPoints(PATH2_R2);

testGroup("3D Extruded Bezier Module")
{
   // Focus: linear extrude
   testSet("bezierShape","linear extrude",[
      testCase("two curved paths, extruded",
         [POINTS2_1,POINTS2_2,false,true],
         "no pink faces in thrown-together view..."),
      testCase("lower path and focal line 1, extruded",
         [POINTS2_1,false,FOCAL2_1,true],""),
      testCase("lower path and focal line 2, extruded",
         [false,POINTS2_1,FOCAL2_1,true],""),
      testCase("upper path and focal line 1, extruded",
         [POINTS2_2,false,FOCAL2_1,true],""),
      testCase("upper path and focal line 2, extruded",
         [false,POINTS2_2,FOCAL2_1,true],""),
   ])testModule([0,20],[50,0])
      linear_extrude(5)
         bezierShape($value[0],$value[1],$value[2],$value[3]);

   // Focus: rotate extrude
   testSet("bezierShape","rotate extrude",[
      testCase("rotate extrude 1, no cross",
         [POINTS2_R1,false,FOCAL2_R,true],""),
      testCase("rotate extrude 2, no cross",
         [POINTS2_R2,false,FOCAL2_R,true],"")
   ])testModule([-20,20],[-30,0])
      rotate_extrude()
         bezierShape($value[0],$value[1],$value[2],$value[3]);

// end of test group
}
