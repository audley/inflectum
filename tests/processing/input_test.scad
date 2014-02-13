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
include <../../input.scad>
use <../../processing/input.scad>

/*
	Test Group: Correction Functions
		function nodeCorrection(node,default)
		function linkCorrection(link,default)
	Test Group: Defaults Constructor Function
		function inflectumDefaults(node=undef,link=undef)
	Test Group: Verification Functions
		function nodeIsValid(node)
		function linkIsValid(node)

	Indirectly-tested Functions:
		function inflectumNode(id,position,radius)
		function inflectumOuterNode(id,node,angle,radius,onOutside,onInside)
		function inflectumLink(node,angle1,angle2)
		function inflectumDefaults(node,link)
*/

/******************************************************************************
            C O R R E C T I O N   F U N C T I O N   T E S T S
******************************************************************************/

/*
   Key tests: specified and unspecified properties, constructors, correctors,
	           invalid values.
*/

/*
   Some of the variables and values used in the test. These shouldn't be
	changed, unless changes are also made to the expected results in the tests.
*/
NODE1   = inflectumNode("node1",[2,5],5);
NODE2   = inflectumNode("node2",[undef,5]);
NODE3   = inflectumNode("node3",undef,-5);
NODE4   = inflectumNode("node5");
ONODE1  = inflectumOuterNode("onode1",NODE1,0,5,onInside=true);
ONODE2  = inflectumOuterNode("onode2",NODE1,0,5,onOutside=true);
ONODE3  = inflectumOuterNode("onode3",NODE1,0,5);
ONODE4  = inflectumOuterNode("onode4",NODE1,180,5);
ONODE5  = inflectumOuterNode("onode5",NODE3,0,5);
ONODE6  = inflectumOuterNode("onode6",undef,0,5);
DEFNODE = inflectumNode(position=[20,25],radius=10);
LINK1   = inflectumLink("1",-45,10);
LINK2   = inflectumLink("5");
DEFLINK = inflectumLink(undef,-30,-30,false,5);
testGroup("Correction Functions")
{
   testSet("nodeCorrection","direct test",[

		// nodes
      testCase("complete",[NODE1,DEFNODE],
			node(id="node1",x=2,y=5,radius=5)),
      testCase("unspec/undef x component and radius",[NODE2,DEFNODE],
			node(id="node2",x=20,y=5,radius=10)),
      testCase("too-small radius",[NODE3,DEFNODE],
			node(id="node3",x=20,y=25,radius=CONFIG_MIN_RADIUS)),
      testCase("completely defaults",[NODE4,DEFNODE],
         node(id="node5",x=20,y=25,radius=10)),

		// outer nodes
      testCase("outer-node, inside",[ONODE1,DEFNODE],
			node(id="onode1",x=2,y=5,radius=5)),
      testCase("outer-node, outside",[ONODE2,DEFNODE],
			node(id="onode2",x=12,y=5,radius=5)),
      testCase("outer-node, on border",[ONODE3,DEFNODE],
			node(id="onode3",x=7,y=5,radius=5)),
      testCase("outer-node, angle=180",[ONODE4,DEFNODE,true],
         node(id="onode4",x=-3,y=5,radius=5)),
		testCase("outer-node, reference node with undef position",
			[ONODE5,DEFNODE],node(id="onode5",x=20,y=25,radius=5)),
		testCase("outer-node, undef ref node",[ONODE6,DEFNODE],
         node(id="onode6",x=20,y=25,radius=5))

	])testFunction(nodeCorrection($value[0],$value[1]),manual=$value[2]);

	testSet("linkCorrection","direct test",[
      testCase("completely specified",[LINK1,DEFLINK],
			link(node="1",angle1=-45,angle2=10,isIndep=true,thickness=10)),
      testCase("only node specified",[LINK2,DEFLINK],
			link(node="5",angle1=-30,angle2=-30,isIndep=false,thickness=5))])
		testFunction(linkCorrection($value[0],$value[1]));

// end of test group
}

/******************************************************************************
            V E R I F I C A T I O N   F U N C T I O N   T E S T S
******************************************************************************/

/*
   Key tests: specified and unspecified properties, bad values
*/

/*
   Some of the variables and values used in the test. These shouldn't be
	changed, unless changes are also made to the expected results in the tests.
*/
NODE2_1 = inflectumNode("node1",[2,5],5);
NODE2_2 = inflectumNode("node2",[undef,5]);
NODE2_3 = inflectumNode("node3",[1,1],-5);
NODE2_4 = inflectumNode("node5");
LINK2_1 = inflectumLink("1",-45,10,true,10);
LINK2_2 = inflectumLink("5",undef,undef,false,10);
LINK2_3 = inflectumLink("7");
testGroup("Verification Functions")
{
   testSet("nodeIsValid","direct test",[
      testCase("complete",[NODE2_1],true),
      testCase("unspec/undef x component and radius",[NODE2_2],false),
      testCase("too-small radius (corrected)",[NODE2_3],true),
      testCase("id only",[NODE2_4],false)])
		testFunction(nodeIsValid($value[0]));

	testSet("linkIsValid","direct test",[
      testCase("completely specified",[LINK2_1],true),
      testCase("unspecified angles",[LINK2_2],false),
      testCase("only nodes specified",[LINK2_3],false)])
		testFunction(linkIsValid($value[0]));

// end of test group
}
