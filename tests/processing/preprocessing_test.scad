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
include <../../config.scad>
include <../../structures.scad>
include <../../keywords.scad>
use <../../processing/preprocessing.scad>
use <../../input.scad>

/*
	Test Group: Preprocessing Function
		function process_preprocessing(data)

	Specification Functions:
		function inflectumNode(id,position,radius)
		function inflectumOuterNode(id,node,angle,radius,onOutside,onInside)
		function inflectumLink(node,angle1,angle2)
		function autoRadius(autoRadius=undef,distance)
		function defaults(defaults=undef,node,link,autoRadius)
*/

/******************************************************************************
               P R E P R O C E S S I N G   F U N C T I O N
******************************************************************************/

/*
   Key tests: invalid nodes, invalid links, defaults correction, bad defaults
*/

/*
   Some of the variables and values used in the tests. These shouldn't be
	changed, unless changes are also made to the expected results in the tests.
*/
NODES1 = [
	inflectumNode("node1",[50,50],0),
	inflectumNode("node2",[20,0]),
	inflectumNode("node3"),
	inflectumNode("node4",[30,90],10),
	inflectumNode("node5",[120,120],8)];
LINKS1 = [
	inflectumLink("node1",-45,-45),
	inflectumLink("node2",-45,-30,inflectumNode),
	inflectumLink("node3",10,10,inflectumNode,inflectumNode),
	inflectumLink("node4",-30),
	inflectumLink("node5",undef,-20)];
DEFAULTS1 =
	inflectumDefaults(
	inflectumNode(undef,undef,5),
	inflectumLink(undef,undef,-33),
	inflectumAutoRadius(5));
START1           = data(nodes=NODES1,links=LINKS1,defaults=DEFAULTS1);
PROCESSED1       = process_preprocessing(START1);
P1_DEFAULTS_NODE = PROCESSED1[dataDefaults][defaultsNode];
P1_DEFAULTS_LINK = PROCESSED1[dataDefaults][defaultsLink];
P1_DEFAULTS_AUTO = PROCESSED1[dataDefaults][defaultsAutoRadius];
P1_NODES         = PROCESSED1[dataNodes];
P1_LINKS         = PROCESSED1[dataLinks];

testGroup("Preprocessing Function")
{
   // NORMAL 1:
	// inflectumNode(undef,undef,5),
   // inflectumLink(undef,undef,-33,undef,30)
   testSet("defaults","part of final output",[
      testCase("normal 1 - node",[START1,P1_DEFAULTS_NODE],
			node(id=undef,x=undef,x=undef,radius=5)),
		testCase("normal 1 - link",[START1,P1_DEFAULTS_LINK],
			link(id=undef,angle1=0,angle2=-33,
				radius1=inflectumNode,radius2=inflectumNode)),
		testCase("normal 1 - auto-radius",[START1,P1_DEFAULTS_AUTO],
			autoRadius(distance=5))])
	testFunction($value[1]);

	// NORMAL 1:
	// inflectumNode("node1",[2,5],0),
   // inflectumNode("node2",[2,0]),
   // inflectumNode("node3"),
   // inflectumNode("node4",[3,9],10),
   // inflectumNode("node5",[12,12],8)
	// default = inflectumNode(undef,undef,5)
	testSet("nodes","part of final output",[
      testCase("normal 1",[START1,P1_NODES],
			[node(id="node1",x=50,y=50,radius=CONFIG_MIN_RADIUS),
			 node(id="node2",x=20,y=0,radius=5),
			 node(id="node4",x=30,y=90,radius=10),
			 node(id="node5",x=120,y=120,radius=8)])])
		testFunction($value[1]);

	// NORMAL 1:
	// inflectumLink("node1",-45,-45)
	// inflectumLink("node2",-45,-30,inflectumNode)
	// inflectumLink("node3",10,10,inflectumNode,inflectumNode)
	// inflectumLink("node4",-30)
	// inflectumLink("node5",undef,-20)
	testSet("links","part of final output",[
      testCase("normal 1",[START1,P1_LINKS],
			[link(node=0,angle1=-45,angle2=-45,
				radius1=inflectumNode,radius2=inflectumNode),
			 link(node=1,angle1=-45,angle2=-30,
				radius1=inflectumNode,radius2=inflectumNode),
			 link(node=2,angle1=-30,angle2=-33,
				radius1=inflectumNode,radius2=inflectumNode),
			 link(node=3,angle1=0,angle2=-20,
				radius1=inflectumNode,radius2=inflectumNode)])])
		testFunction($value[1]);

// end of test group
}
