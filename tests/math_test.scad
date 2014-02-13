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
include <../math.scad>
   
/*
   Test Group: Vector Math Functions
      function angle(v)
      function norm(v)
      function rotate(p,angle,origin=[0,0])
   Test Group: Angle Math Functions
      function angleCorrection(angle,refAngle,dir)
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
   testSet("angle","direct test",[
      testCase("null vector",[[0,0]],0), // ***
      testCase("right vector",[[5,0]],0),
      testCase("up vector",[[0,5]],90),
      testCase("left vector",[[-5,0]],180),
      testCase("down vector",[[0,-5]],-90),
      testCase("undef vector",[undef],undef),
      testCase("scalar as vector",[5],undef),
      testCase("empty vector",[[]],undef)]) // ***
   testFunction(angle($value[0]));
   
   testSet("norm","direct test",[
      testCase("null vector",[[0,0]],0),
      testCase("x-component only vector",[[5,0]],5),
      testCase("y-component only vector",[[0,10]],10),
      testCase("45 degree vector",[[5,5]],sqrt(2)*5),
      testCase("135 degree vector",[[-5,5]],sqrt(2)*5),
      testCase("undef vector",[undef],undef),
      testCase("scalar as vector",[5],undef),
      testCase("all undef",[undef,undef],undef),
      testCase("empty vector",[[]],undef)])
   testFunction(norm($value[0]));
   
   testSet("rotate","direct test",[
      testCase("point at [0,0] by 30 degrees",
         [[0,0],30,[0,0],false],[0,0]),
      testCase("point at [5,0] by 45 degrees",
         [[5,0],45,[0,0],true],[5,5]/sqrt(2)),
      testCase("point at [5,0] by 180 degrees",
         [[5,0],180,[0,0],true],[-5,0]),
      testCase("undef vector",[undef,false],undef),
      testCase("scalar as vector",[5,false],undef),
      testCase("empty vector",[[],false],undef)])
   testFunction(rotate(
		$value[0],$value[1],$value[2]),manual=$value[3]);
   
// end of test group
}

/******************************************************************************
                 A N G L E   F U N C T I O N   T E S T S
******************************************************************************/

/*
   Key tests: basic/undef angles
*/

testGroup("Angle Math Functions")
{   
   testSet("angleCorrection","direct test",[
      testCase("45 above 0",[45,0,">"],45),
      testCase("45 below 0",[45,0,"<"],-360+45),
      testCase("90 above 0",[90,0,">"],90),
      testCase("90 below 0",[90,0,"<"],-360+90),
      testCase("135 above 0",[135,0,">"],135),
      testCase("135 below 0",[135,0,"<"],-360+135),
      testCase("180 above 0",[180,0,">"],180),
      testCase("180 below 0",[180,0,"<"],-360+180),
      testCase("225 above 0",[225,0,">"],225),
      testCase("225 below 0",[225,0,"<"],-360+225),
      testCase("270 above 0",[270,0,">"],270),
      testCase("270 below 0",[270,0,"<"],-360+270),
      testCase("360 above 0",[360,0,">"],360),
      testCase("-360 below 0",[360,0,"<"],-360),
      testCase("360+45 above 0",[360+45,0,">"],45),
      testCase("undef angle",[undef],undef)])
   testFunction(angleCorrection($value[0],$value[1],$value[2]));

// end of test group
}
