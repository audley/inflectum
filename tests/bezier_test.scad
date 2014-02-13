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
include <../bezier.scad>

/*
   Test Group: Bezier Points Function
      module bezierPoints(ctrlPoints)
         Focuses: circle approximation, $fs
   Test Group: Extruded Bezier Shapes
      module bezierShape(points1=false,points2=false,
		                   focalLine=false,debug=false)
         Focuses: linear extrude, rotate extrude

   Indirectly tested functions:
      function bezierControlPoints(path1)
      function bezierPoint(points,t)
      function bezierLen(points)
*/

/******************************************************************************
                   B E Z I E R   P O I N T S   F U N C T I O N
******************************************************************************/
/*
   Key tests: circle approximation, resolution/detail via $fs
*/

/*
   Some of the constants used in the 2D tests. These shouldn't be changed,
   unless changes are also made to the expected results in the tests.
*/
CA_DIAM  = 30;                   // circle-approximation test diam
CA_DIST  = CA_DIAM/2*sqrt(2);    // dist between circle-approx end-points
CA_OFST  = CA_DIAM/2/sqrt(2)+20; // y ofst of circle from end-point line
PATH1    = [[0,0], 45,[40,0],-45];
PATH2    = [[0,0],-45,[40,0], 45];
PATH3    = [[0,0], 90,[40,0],-90];
CA_PATH  = [[0,20],-45,[CA_DIST,20],45];
CA_FOCAL = [[0,0],[CA_DIST,0]];
POINTS1   = bezierControlPoints(PATH1);
POINTS2   = bezierControlPoints(PATH2);
POINTS3   = bezierControlPoints(PATH3);
CA_POINTS = bezierControlPoints(CA_PATH);

testGroup("2D Bezier Points Function")
{
   // Focus: merging points, focal line, debug points
   testSet("bezierPoints","test via polygon()",[
      testCase("normal 1",[POINTS1]),
      testCase("normal 2",[POINTS2]),
   ])testModule([0,0],[50,0])
		polygon(bezierPoints($value[0]));

   // Focus: circle approximation
   testSet("bezierPoints",
      "test circle approximation (as a result of the curve factor)",[
      testCase("circle approximation",[CA_POINTS])
   ])testModule([0,-60],[0,0])
   {
      // create curve
      polygon(bezierPoints($value[0]));
      // test with circle
      color("grey",0.5) translate([CA_DIST/2,CA_OFST+0.5])
         circle(CA_DIAM/2);
   }

   // Focus: $fs
   testSet("bezierPoints","Test fragment size",[
      testCase("$fs = 2",[POINTS3,2]),
      testCase("$fs = 1",[POINTS3,1]),
      testCase("$fs = 0.5",[POINTS3,0.5]),
   ])testModule([50,-40],[50,0])
   {
      polygon(bezierPoints($value[0],$fs=$value[1]));
      color("blue",0.5)translate([0,0,-2.5])cube([$value[1],$value[1],5]);
   }

// end of test group
}

/******************************************************************************
               3 D   E X T R U D E D   B E Z I E R   T E S T S
******************************************************************************/

/*
   Some of the constants used in the 3D tests. These shouldn't be changed,
   unless changes are also made to the expected results in the tests.
*/
PATH3_1    = [[0,0], 45,[40,0],-45];
PATH3_2    = [[0,0],-45,[40,0], 45];
PATH3_R1   = [[0,0],45,[0,40], 135];
PATH3_R2   = [[15,0],135,[15,40], 45];
POINTS3_1  = bezierControlPoints(PATH1);
POINTS3_2  = bezierControlPoints(PATH2);
POINTS3_R1 = bezierControlPoints(PATH3_R1);
POINTS3_R2 = bezierControlPoints(PATH3_R2);

testGroup("3D Extruded Bezier Shapes")
{
   // Focus: linear extrude
   testSet("bezierPoints","linear extrude",[
      testCase("normal 1",[POINTS3_1]),
      testCase("normal 2",[POINTS3_2]),
   ])testModule([0,20],[50,0])
      linear_extrude(5) polygon(bezierPoints($value[0]));

   // Focus: rotate extrude
   testSet("bezierPoints","rotate extrude",[
      testCase("normal 1",[POINTS3_R1]),
      testCase("normal 2",[POINTS3_R2])
   ])testModule([-20,20],[-30,0])
      rotate_extrude() polygon(bezierPoints($value[0]));

// end of test group
}
