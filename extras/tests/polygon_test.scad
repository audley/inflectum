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
include <../polygon.scad>

/*
   Test Group: Quad Animation
      function simplifyQuad(points)
   Test Group: Quad (4-point) Simplification Function
      function simplifyQuad(points)
         Focuses: 
            normal, merge tests, p2-p3 crossing over p1-p4
            p3-p4 crossing over p1-p2, no-area
*/

/******************************************************************************
                    Q U A D   A N I M A T I O N   T E S T
******************************************************************************/

testGroup("Quad Animation")
{
   testSet("simplifyQuad",
      "Test the function simplifyQuad() using polygon()",
   [
      testCase("normal, radius = side lengths",
         [[[0,0],[0,3],[3,3],(3)*[cos($t*360),sin($t*360)]]]),
      testCase("normal, diagonal radius",
         [[[0,0],[0,3],[3,3],(sqrt(2)*3)*[cos($t*360),sin($t*360)]]]),
      testCase("normal, longer radius",
         [[[0,0],[0,3],[3,3],(6)*[cos($t*360),sin($t*360)]]]),
      testCase("cross-over, normal radius",
         [[[0,0],[0,3],(3)*[cos($t*360),sin($t*360)],[3,3]]]),
      testCase("cross-over, diagonal radius",
         [[[0,0],[0,3],(3*sqrt(2))*[cos($t*360),sin($t*360)],[3,3]]]),
      testCase("cross-over, longer radius",
         [[[0,0],[0,3],(6)*[cos($t*360),sin($t*360)],[3,3]]]),
      testCase("random",
         [[rands(-3,3,2),rands(-3,3,2),rands(-3,3,2),rands(-3,3,2)]])

   ])testModule([0,0],[10,0])
      polygon(simplifyQuad($value[0]));

// end of test group
}

/******************************************************************************
      Q U A D   S I M P L I F I C A T I O N   F U N C T I O N   T E S T
******************************************************************************/

/*
   Key tests: merging points, crossing lines, null-shapes
*/

testGroup("Quad (4-point) Simplification Function")
{
   testSet("simplifyQuad",
      "test the function simplifyQuad() using polygon()",
   [
      // normal
      testCase("normal rect, clockwise",
         [[[0,0],[0,3],[3,3],[3,0]]]),
      testCase("normal rect, anticlockwise",
         [[[0,0],[3,0],[3,3],[0,3]]]),

      // merge tests
      testCase("p2=p1",[[[0,0],[0,0],[3,3],[3,0]]]),
      testCase("p1=p2",[[[0,3],[0,3],[3,3],[3,0]]]),
      testCase("p3=p2",[[[0,0],[0,3],[0,3],[3,0]]]),
      testCase("p2=p3",[[[0,0],[3,3],[3,3],[3,0]]]),
      testCase("p4=p3",[[[0,0],[0,3],[3,3],[3,3]]]),
      testCase("p3=p4",[[[0,0],[0,3],[3,0],[3,0]]]),
      testCase("p1=p4",[[[3,0],[0,3],[3,3],[3,0]]]),
      testCase("p4=p1",[[[0,0],[0,3],[3,3],[0,0]]]),
      
      // p2-p3 crossing over p1-p4
      testCase("p2-3 crosses p1-4",
         [[[0,3],[0,0],[3,3],[3,0]]]),
      testCase("p2-3 crosses p1-4, reverse",
         [[[3,0],[3,3],[0,0],[0,3]]]),
      testCase("p2-3 crosses p1-4, h-line-flip",
         [[[0,0],[0,3],[3,0],[3,3]]]),
      testCase("p2-3 crosses p1-4, v-line-flip",
         [[[3,3],[3,0],[0,3],[0,0]]]),
      testCase("p2-3 crosses p1-4, angled",
         [[[0,3],[0,0],[3,3+5],[3,0+5]]]),
      
      // p3-p4 crossing over p1-p2
      testCase("p3-4 crosses p1-2",
         [[[0,0],[3,3],[0,3],[3,0]]]),
      testCase("p3-4 crosses p1-2, reverse",
         [[[3,0],[0,3],[3,3],[0,0]]]),
      testCase("p3-4 crosses p1-2, h-line-flip",
         [[[3,0],[0,3],[3,3],[0,0]]]),
      testCase("p3-4 crosses p1-2, v-line-flip",
         [[[0,3],[3,0],[0,0],[3,3]]]),
      testCase("p3-4 crosses p1-2, angled",
         [[[0,0],[3+5,3],[0+5,3],[3,0]]]),

      // no-area tests
      testCase("p2-3 crosses p1-4, top-merge (no area)",
         [[[1.5,3],[0,0],[1.5,3],[3,0]]]),
      testCase("p3-4 crosses p1-2, left merge (no area)",
         [[[0,1.5],[3,3],[0,1.5],[3,0]]]),
      testCase("normal, diagonal merge",
         [[[1.5,1.5],[0,3],[1.5,1.5],[3,0]]])

   ])testModule([0,-10],[5,0])
   assign(result = simplifyQuad($value[0])){
      polygon(result); echo(str("result = ",result));
   }
// end of test group
}
