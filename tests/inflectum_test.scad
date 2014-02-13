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
include <../inflectum.scad>

/*	
	Test Group: Main Inflectum Module
		module inflectumShape(nodes,links,defaults)

	Specification Functions:
		function inflectumNode(id,position,radius)
		function inflectumOuterNode(id,node,angle,radius,onOutside,onInside)
		function inflectumLink(node,angle1,angle2)
		function inflectumDefaults(node,link)
*/

/******************************************************************************
                     M A I N   M O D U L E   T E S T S
******************************************************************************/

$fs = 3;

/*
   Key tests: angle overlap and miss,
	           linear angle for two different-radii nodes,
	           outer nodes (relational),
	           undefined link/node lists and defaults,
	           holes (using difference())
*/

/*
   Some of the variables and values used in the test. These shouldn't be
	changed, unless changes are also made to the expected results in the tests.
*/
NODES1 = [
	inflectumNode("center",[0,0]),
	inflectumNode("top-left",[-100,100]),
	inflectumNode("top-right",[100,100])];
NODES2 = NODES1;
NODES3 = NODES1;
NODES4 = NODES1;
NODES5 = [
	inflectumNode("0",[0,0]),
	inflectumNode("1",[-60,60]),
	inflectumNode("2",[-100,120]),
	inflectumNode("3",[-60,180]),
	inflectumNode("4",[0,240]),
	inflectumNode("5",[60,180]),
	inflectumNode("6",[100,120]),
	inflectumNode("7",[60,60])];
NODES6 = [
	inflectumNode("center",[0,0],0),
	inflectumNode("left",[-100,0]),
	inflectumNode("right",[100,0])];
NODES7_CENTER = inflectumNode("center",[0,0],100);
NODES7 = [
	inflectumOuterNode("bottom-left",NODES7_CENTER,-135,30,onOutside=true),
	inflectumOuterNode("bottom-center-th",NODES7_CENTER,-90,5,onOutside=true),
	inflectumOuterNode("bottom-right",NODES7_CENTER,-45,30,onOutside=true),
	inflectumOuterNode("middle-right-th",NODES7_CENTER,0,5,onOutside=true),
	inflectumOuterNode("top-right",NODES7_CENTER,45,30,onOutside=true)];
NODES8 = [
	inflectumNode("left",[-100,0],30),
	inflectumNode("right",[100,0],70)];
NODES9 = [
	inflectumNode("center",[0,0]),
	inflectumNode("top-left",[-100,100]),
	inflectumNode("top-right",[100,100]),
	inflectumNode("bottom-right",[100,-100]),
	inflectumNode("bottom-left",[-100,-100])];
NODES_ALPHA_1 = [
	inflectumNode("top-left",[-15,15]*5,5*5),
	inflectumNode("top-right",[15,15]*5,5*5),
	inflectumNode("center",[0,0]*5,5*5),
	inflectumNode("bottom",[0,-15]*5,5*5)];
NODES_ALPHA_2 = [
	inflectumNode("center",[0,0]*5,5*5),
	inflectumNode("top-left",[-15,15]*5,10*5),
	inflectumNode("top-right",[15,15]*5,10*5),
	inflectumNode("bottom-right",[15,-15]*5,10*5),
	inflectumNode("bottom-left",[-15,-15]*5,10*5)];
NODES_ALPHA_3 = NODES_ALPHA_2;
LINKS1 = [
	inflectumLink("center"),
	inflectumLink("top-left",undef,-50),
	inflectumLink("center",-50),
	inflectumLink("top-right")];
LINKS2 = [
	inflectumLink("center"),
	inflectumLink("top-left"),
	inflectumLink("center"),
	inflectumLink("top-right")];
LINKS3 = [
	inflectumLink("center"),
	inflectumLink("top-left"),
	inflectumLink("top-right")];
LINKS4 = LINKS3;
LINKS5 = [
	inflectumLink("0"),inflectumLink("1"),
	inflectumLink("2"),inflectumLink("3"),
	inflectumLink("4"),inflectumLink("5"),
	inflectumLink("6"),inflectumLink("7")];
LINKS6 = [
	inflectumLink("center",90),
	inflectumLink("left",undef,90),
	inflectumLink("center",90),
	inflectumLink("right",undef,90)];
LINKS7 = [
	inflectumLink("bottom-left",-45),
	inflectumLink("bottom-right",undef,-45),
	inflectumLink("top-right"),
	inflectumLink("middle-right-th"),
	inflectumLink("bottom-right"),
	inflectumLink("bottom-center-th")];
LINKS8 = [
	inflectumLink("left"),
	inflectumLink("right")];
LINKS9 = [
	inflectumLink("center"),
	inflectumLink("top-left"),
	inflectumLink("center"),
	inflectumLink("top-right"),
	inflectumLink("center"),
	inflectumLink("bottom-right"),
	inflectumLink("center"),
	inflectumLink("bottom-left")];
LINKS_ALPHA_1 = [
	inflectumLink("center"),
	inflectumLink("top-left"),
	inflectumLink("center"),
	inflectumLink("top-right"),
	inflectumLink("center"),
	inflectumLink("bottom")];
LINKS_ALPHA_2 = [
	inflectumLink("top-left",45,45),
	inflectumLink("top-right",45,45),
	inflectumLink("bottom-right",45,45),
	inflectumLink("bottom-left",45,45)];
LINKS_ALPHA_2_S1 = [
	inflectumLink("center"),
	inflectumLink("top-right",-135,-135),
	inflectumLink("top-left")];
LINKS_ALPHA_2_S2 = [
	inflectumLink("center"),
	inflectumLink("bottom-right",-135,-135),
	inflectumLink("top-right")];
LINKS_ALPHA_2_S3 = [
	inflectumLink("center"),
	inflectumLink("bottom-left",-135,-135),
	inflectumLink("bottom-right")];
LINKS_ALPHA_2_S4 = [
	inflectumLink("center"),
	inflectumLink("top-left",-135,-135),
	inflectumLink("bottom-left")];
LINKS_ALPHA_3 = [
	inflectumLink("top-left",-80,-80),
	inflectumLink("top-right",-45,-45),
	inflectumLink("bottom-right",-45,-45),
	inflectumLink("bottom-left",-45,-45)];
LINKS_ALPHA_3_S1 = [
	inflectumLink("top-right"),
	inflectumLink("top-left"),
	inflectumLink("bottom-left"),
	inflectumLink("bottom-right")];
DEFAULTS1 = inflectumDefaults(
	inflectumNode(undef,undef,40),
	inflectumLink(undef,-45,-45));
DEFAULTS2 = inflectumDefaults(
	inflectumNode(undef,undef,40),
	inflectumLink(undef,0,0));
DEFAULTS3 = DEFAULTS2;
DEFAULTS4 = inflectumDefaults(
	inflectumNode(undef,undef,40),
	inflectumLink(undef,-95,-95));
DEFAULTS5 = inflectumDefaults(
	inflectumNode(undef,undef,20),
	inflectumLink(undef,90,0));
DEFAULTS6 = DEFAULTS2;
DEFAULTS7 = DEFAULTS2;
DEFAULTS8 = DEFAULTS2;
DEFAULTS9 = DEFAULTS2;
DEFAULTS_ALPHA_1 = DEFAULTS2;
DEFAULTS_ALPHA_2 = DEFAULTS2;
DEFAULTS_ALPHA_3 = DEFAULTS2;
DATA = [
	[NODES1,LINKS1,DEFAULTS1],
	[NODES2,LINKS2,DEFAULTS2],
	[NODES3,LINKS3,DEFAULTS3],
	[NODES4,LINKS4,DEFAULTS4],
	[NODES5,LINKS5,DEFAULTS5],
	[NODES6,LINKS6,DEFAULTS6],
	[NODES7,LINKS7,DEFAULTS7],
	[NODES8,LINKS8,DEFAULTS8],
	[NODES9,LINKS9,DEFAULTS9],
	[NODES3,LINKS3,undef],
	[undef,LINKS1,DEFAULTS1],
	[NODES1,undef,DEFAULTS1],
	[undef,undef,DEFAULTS1],
	[undef,undef,undef]];
DATA_ALPHA = [
	[NODES_ALPHA_1,LINKS_ALPHA_1,DEFAULTS_ALPHA_1],
	[NODES_ALPHA_2,LINKS_ALPHA_2,DEFAULTS_ALPHA_2,
		[LINKS_ALPHA_2_S1,LINKS_ALPHA_2_S2,
		 LINKS_ALPHA_2_S3,LINKS_ALPHA_2_S4]],
	[NODES_ALPHA_3,LINKS_ALPHA_3,DEFAULTS_ALPHA_3,[LINKS_ALPHA_3_S1]]];

testGroup("Main Inflectum Module")
{
   testSet("inflectumShape","direct test (extruded)",[
      testCase("no angle overlap, -45 degree node angles",[0],
			"3 nodes, curves angled inwards"),
		testCase("single angle overlap, 0 degree node angles",[1],
			"3 nodes, linear outside curves, curves meet correctly inside"),
		testCase("no overlap, triangle formation",[2],
			"triange with round corners"),
		testCase("polygon formation",[4],
			"8 nodes, correctly-connecting curves"),
		testCase("0 center radius (close to)",[5],
			"no overlapping curves at center"),
		testCase("circle approximation",[6],
			"approximate circle within the three nodes, no crossing curves"),
		testCase("linear angle",[7],
			"linear lines between node edges"),
		testCase("X formation",[8],
			"4 outer nodes & center node, no curve overlapping"),
		testCase("undefined defaults",[9],
			"triangle with slightly rounded corners"),
		testCase("undefined nodes",[10],
			"warning messages (after this text), no constructed geometry"),
		testCase("undefined links",[11],"nothing"),
		testCase("undefined nodes and links",[12],"nothing"),
		testCase("undefined nodes, links and defauts",[13],"nothing"),
	])testModule([0,0],[300,0])
		linear_extrude(50) inflectumShape(
			DATA[$value[0]][0],DATA[$value[0]][1],DATA[$value[0]][2]);

	 testSet("inflectumShape - alpha tests",
		str("direct test using designs from old implementation tests which used ",
		    "double-sided links (from extras/old/inflectumLinks.scad)"),[
      testCase("Y formation",[0]),
		testCase("circle with bell-like holes",[1]),
		testCase("4-cornered object with center hole",[2]),
	])testModule([0,-300],[300,0])
		linear_extrude(50) difference()
		{
			// add main fill (links are specified in a clockwise order)
			inflectumShape(
				DATA_ALPHA[$value[0]][0],DATA_ALPHA[$value[0]][1],DATA_ALPHA[$value[0]][2]);

			// subtract holes (links are specified in an anticlockwise order)
			for (sub_links = DATA_ALPHA[$value[0]][3])
				inflectumShape(
				DATA_ALPHA[$value[0]][0],sub_links,DATA_ALPHA[$value[0]][2]);
		}

// end of test group
}
