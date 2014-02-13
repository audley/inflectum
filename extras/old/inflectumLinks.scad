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

include <../bezier.scad>
include <../debug.scad>
include <../math.scad>

/*
	Functions:
		function inflectumNode(v=false,x=0,y=0,r=0)
		function inflectumLink(n1=undef,n2=undef,angles=false,
		                       a11=undef,a12=undef,a21=undef,a22=undef)
	Modules:
		module inflectumLinks(nodes,links,steps,debug=false)

	Internal Constants:
		INFLECTUM_EPSILON
		INFLECTUM_PI
	Internal Functions:
		function _inflectumGet(obj,property,number=false,node=false,side=false)
		function inflectumModifiedLink(link,refnode)
		function inflectumLinkAngle(nodes,link)
		function inflectumLinkLength(nodes,link)
		function inflectumClosestLinkIndex(nodes,links,linkIndex,node,side)
		function inflectumLinkType(link)
		function inflectumLinkSideType(link,side)
		function inflectumLinkNodeAngles(nodes,links,linkIndex,node,side)
		function inflectumLinearNodeAngle(nodes,link,node)
*/

// Y formation
translate([0,0])
inflectumLinks(
	nodes=[
		inflectumNode(x=-15, y= 15, r=5),
		inflectumNode(x= 15, y= 15, r=5),
		inflectumNode(x=  0, y=  0, r=5),
		inflectumNode(x=  0, y=-15, r=5)],
	links=[
		inflectumLink(n1=0,n2=2),
		inflectumLink(n1=2,n2=1),
		inflectumLink(n1=3,n2=2)],
	steps=10,debug=true);

// circle with bell-like holes
translate([50,0])
inflectumLinks(
	nodes=[
		inflectumNode(x=0,  y=0,  r=5),
		inflectumNode(x=-15,y=15, r=10),
		inflectumNode(x=15, y=15, r=10),
		inflectumNode(x=15, y=-15,r=10),
		inflectumNode(x=-15,y=-15,r=10)],
	links=[
		inflectumLink(n1=0,n2=1,a21=0,a22=0),
		inflectumLink(n1=0,n2=2,a21=0,a22=0),
		inflectumLink(n1=0,n2=3,a21=0,a22=0),
		inflectumLink(n1=0,n2=4,a21=0,a22=0),
		inflectumLink(n1=1,n2=2,a12=45),
		inflectumLink(n1=2,n2=3,a12=45),
		inflectumLink(n1=3,n2=4,a12=45),
		inflectumLink(n1=4,n2=1,a12=45)],
	steps=10,debug=true);

// 4-cornered object with center hole
translate([110,0])
inflectumLinks(
	nodes=[
		inflectumNode(x=0,  y=0,  r=5),
		inflectumNode(x=-15,y=15, r=10),
		inflectumNode(x=15, y=15, r=10),
		inflectumNode(x=15, y=-15,r=10),
		inflectumNode(x=-15,y=-15,r=10)],
	links=[
		inflectumLink(n1=1,n2=2,a12=-80),
		inflectumLink(n1=2,n2=3,a22=-45),
		inflectumLink(n1=3,n2=4,a12=-45),
		inflectumLink(n1=4,n2=1,a12=-45)],
	steps=10,debug=true);

/******************************************************************************
               I N F L E C T U M - L I N K S   M O D U L E
******************************************************************************/

/*
	This module creates given links between specified nodes. The number of curve
	divisions (steps) must also be specified, and optionally the debug mode can
	be set, which causes small debug nodes to be placed at particular points on
	the curves produced.

	NOT IMPLEMENTED: link thickness support
*/
module inflectumLinks(nodes,links,steps,debug=false)
{
	// determines whether a link is valid or not
	function is_valid_link(nodes,link) = 
	((_inflectumGet(link,"node1")!=undef
			&& _inflectumGet(link,"node2")!=undef)
		&&(_inflectumGet(link,"node1")<len(nodes)
			&&_inflectumGet(link,"node2")<len(nodes)));

	// place down debug nodes
	%if (debug) for (i = [0 : len(nodes)-1])
		debugNode("node.center",_inflectumGet(nodes[i],"location"));

	// place down links
	for (i = [0:len(links)-1])
		if (is_valid_link(nodes,links[i]))
			_inflectumLink(nodes,links,i,steps,debug);
}

// module to create a single link between two nodes - used internally
module _inflectumLink(nodes,links,index,steps,debug)
{
	/*
		Sub-function to return the position of a point on a node circle, given
		the node's radius, the angle (link-relative) and the side number. This
		is used to obtain the start and end points of the curve when the
		tangent angles (relative to link) and node radii are known.
	*/
	function node_point(radius,angle,side)
		= radius*[cos(angle-90+(side==2?180:0)),
		          sin(angle-90+(side==2?180:0))];
	/*
		Sub-module to create part of a node, given the node's center position,
		and the start (pA) and end (pB) points. This module is used to fill the
		gap between the node points from the main-link and "close" link. This is
		part of on-demand node creation (or Node On Demand - NOD).
	*/
	module node_part(pA,pB,pN,steps,debug)
	{
		/*
			Sub-function to obtain a point that lies on the node circle (at
			center point pN) of given radius at a given angle around the center.
		*/
		function circle_point(pN,angle,radius)
			= pN+radius*[cos(angle),sin(angle)];
		/*
			The final product of this module will be part of a circle (which may
			be non-uniform due to the potential for different radii). To start
			off, the start and end angles from the points provided must be
			calculated.

			The start angle is obtained from the vector given by 'pA-pN', where pA
			is the first (start) point, and pN is the (center) position of the
			node.
		*/
		ANGLE_A = angleCorrection(angle(pA-pN),0,"<");
		/*
			The end angle is obtained similarly to the start angle, except it is
			made to be smaller than the start angle.
		*/
		ANGLE_B = angleCorrection(angle(pB-pN),ANGLE_A,"<");
		/*
			The start and end radii are obtained by finding the distance between
			the node and the points, done by finding the length of the vectors
			'pN-pA' and 'pN-pB'.

			Because the points may be at different distances from the node, having
			two different radii is possible. Just like the angles, the radii will
			be interpolated, although not linearly, so that the ends will still
			meet the link-curves at parallel angles.
		*/
		RADIUS_A = norm(pN-pA);
		RADIUS_B = norm(pN-pB);
		/*
			To create the non-linear radii interpolation, the negative of the
			cosine function will be used. To make the radii at the midpoint
			between the angles the radius midpoint, the average radii and
			difference between the radii must be calculated.
		*/
		RADIUS_MID  = (RADIUS_A+RADIUS_B)/2;
		RADIUS_DIFF = RADIUS_B-RADIUS_A;
		/*
			Work out the number of steps / divisions to use. This will affect the
			detail-level of the curve/circle produced. The number is a portion of
			the originally specified number of steps for the link-curves. The
			ratio is given by the assumption that 90 degrees (half a circle) will
			contain the number of originally-specified steps.
		*/
		STEPS = ceil(steps*(abs(ANGLE_A-ANGLE_B)/90));
		/*
		*/
		if (abs(ANGLE_A-ANGLE_B)<360)
		/*
			The circle/node part will be constructed by triangles, using the center
			point and the points on the circle from the previous and current steps
			(with the points in a clockwise direction to ensure openscad-friendly
			geometry).

			We need to go through each triangle by going through all the steps,
			starting from step 1 (index starts at 0), as step 0 will be used for the
			the first triangle anyway.
		*/
		for (step = [1:STEPS])
			assign(
			/*
				Calculate the previous and current step angles, using linear
				interpolation (done using the lookup() function).
			*/
			angleA = lookup(step-1,[[0,ANGLE_A],[STEPS,ANGLE_B]]),
			angleB = lookup(  step,[[0,ANGLE_A],[STEPS,ANGLE_B]]),
			/*
				Calculate the previous and current step radii, using non-linear
				interpolation. The radii are worked out by using the negative of
				cosine, for which the values will range from -1 to 1. Multiplying
				the cosine (whose angle is 180*t, where t is a parameter [0..1])
				by the amplitude (RADIUS_DIFF/2), and raising the value by the
				normal/center height (RADIUS_MID), the radii can be obtained.
			*/
			radiusA = RADIUS_MID-cos(180*(step-1)/step)*RADIUS_DIFF/2,
			radiusB = RADIUS_MID-cos(180    *step/step)*RADIUS_DIFF/2)
			/*
				The triangle is constructed from the points given by the:

					- node center,
					- previous-step circle point, and
					- current-step circle point.

				These are (or should be) arranged in a clockwise order, to help
				ensure that the geometry can be extruded properly.
			*/
			polygon(
				[pN,
				 circle_point(pN,angleA,radiusA),
				 circle_point(pN,angleB,radiusB)]);
	}

	// get the current link, and its angle and length
	LINK       = links[index];
	LINK_ANGLE = inflectumLinkAngle(nodes,LINK);
	LINK_LEN   = inflectumLinkLength(nodes,LINK);

	// get the current link node indexes and nodes
	N1_INDEX = _inflectumGet(LINK,"node1");
	N2_INDEX = _inflectumGet(LINK,"node2");
	N1       = nodes[N1_INDEX];
	N2       = nodes[N2_INDEX];

	// determine final radii
	N1_R1 = _inflectumGet(N1,"radius");
	N1_R2 = _inflectumGet(N1,"radius");
	N2_R1 = _inflectumGet(N2,"radius");
	N2_R2 = _inflectumGet(N2,"radius");

	// get the link-relative node angles (for each node and side)
	N1_ANGLES_1 = inflectumLinkNodeAngles(nodes,links,index,1,1);
	N1_ANGLES_2 = inflectumLinkNodeAngles(nodes,links,index,1,2);
	N2_ANGLES_1 = inflectumLinkNodeAngles(nodes,links,index,2,1);
	N2_ANGLES_2 = inflectumLinkNodeAngles(nodes,links,index,2,2);

	// get the main-link node angles (relative to the link)
	N1_A1 = N1_ANGLES_1[0]; N1_A2 = N1_ANGLES_2[0];
	N2_A1 = N2_ANGLES_1[0]; N2_A2 = N2_ANGLES_2[0];

	// get the close-link node angles (relative to the link)
	C_N1_A1 = N1_ANGLES_1[1]; C_N1_A2 = N1_ANGLES_2[1];
	C_N2_A1 = N2_ANGLES_1[1]; C_N2_A2 = N2_ANGLES_2[1];

	// calculate node start/end points for main-link
	N1_1_PA = node_point(N1_R1,N1_A1,1)+[0,0];
	N1_2_PA = node_point(N1_R2,N1_A2,2)+[0,0];
	N2_1_PB = node_point(N2_R1,N2_A1,1)+[LINK_LEN,0];
	N2_2_PB = node_point(N2_R2,N2_A2,2)+[LINK_LEN,0];

	// calculate start/end points for Nodes-On-Demand
	NOD_N1_1_RP_A  = N1_1_PA;
	NOD_N2_2_RP_A  = N2_2_PB;
	_NOD_N1_1_RP_B = node_point(N1_R1,C_N1_A1,1);
	_NOD_N2_2_RP_B = node_point(N2_R2,C_N2_A2,2)+[LINK_LEN,0];
	NOD_N1_1_RP_B  = _NOD_N1_1_RP_B==[undef,undef]?N1_2_PA:_NOD_N1_1_RP_B;
	NOD_N2_2_RP_B  = _NOD_N2_2_RP_B==[undef,undef]?N2_1_PB:_NOD_N2_2_RP_B;
	// create a final link specification
	F_LINK = inflectumLink(n1=N1_INDEX,a11=N1_A1,a12=N1_A2,n2=N2_INDEX,a21=N2_A1,a22=N2_A2);

	NOD_N1_A1   = angleCorrection(N1_A1,180,"<");
	NOD_C_N1_A1 = angleCorrection(C_N1_A1,180,"<");
	NOD_1_OVER  = NOD_C_N1_A1>NOD_N1_A1;

	NOD_N2_A2   = angleCorrection(N2_A2,180,"<");
	NOD_C_N2_A2 = angleCorrection(C_N2_A2,180,"<");
	NOD_2_OVER  = NOD_C_N2_A2>NOD_N2_A2;

	// find t split-point
	T_SPLIT_1 = 0.5; T_SPLIT_2 = 0.5; T_SPLIT = (T_SPLIT_1+T_SPLIT_2)/2;

	// find control-points for the two parts (link is divided)
	POINTS_1 = 
		// if the side is linear or curved
		(inflectumLinkSideType(F_LINK,1)=="linear"
		 || inflectumLinkSideType(F_LINK,1)=="curved")
			// use linear/curved path
			? bezierControlPoints([N1_1_PA,N1_A1,N2_1_PB,N2_A1])
		// otherwise, if a thickness node is involved
		: undef;
	POINTS_2 = 
		// if the side is linear or curved
		(inflectumLinkSideType(F_LINK,2)=="linear"
		 || inflectumLinkSideType(F_LINK,2)=="curved")
			// use linear/curved path
			? bezierControlPoints([N1_2_PA,N1_A2,N2_2_PB,N2_A2])
		// otherwise, if a thickness node is involved
		: undef;

	// find control-points for if there are two parts
	POINTS_1A = 
		// if side is linear or curved
		(inflectumLinkSideType(F_LINK,1)=="linear"
		 || inflectumLinkSideType(F_LINK,1)=="curved")
	 		// use part of continuous path
			? bezierSegment(POINTS_1,0,T_SPLIT)
		// otherwise, if a thickness node is involved
		: undef;
	POINTS_2A = 
		// if side is linear or curved
		(inflectumLinkSideType(F_LINK,2)=="linear"
		 || inflectumLinkSideType(F_LINK,2)=="curved")
	 		// use part of continuous path
			? bezierSegment(POINTS_2,0,T_SPLIT)
		// otherwise, if a thickness node is involved
		: undef;
	POINTS_1B = 
		// if side is linear or curved
		(inflectumLinkSideType(F_LINK,1)=="linear"
		 || inflectumLinkSideType(F_LINK,1)=="curved")
	 		// use part of continuous path
			? bezierSegment(POINTS_1,T_SPLIT,1)
		// otherwise, if a thickness node is involved
		: undef;
	POINTS_2B = 
		// if side is linear or curved
		(inflectumLinkSideType(F_LINK,2)=="linear"
		 || inflectumLinkSideType(F_LINK,2)=="curved")
	 		// use part of continuous path
			? bezierSegment(POINTS_2,T_SPLIT,1)
		// otherwise, if a thickness node is involved
		: undef;

	// create the link
	translate(_inflectumGet(N1,"location")) rotate(LINK_ANGLE)
	{
		// create part A
		bezierShape(points1=POINTS_1A,points2=POINTS_2A,steps=steps,debug=debug);
		// create part B
		bezierShape(points1=POINTS_1B,points2=POINTS_2B,steps=steps,debug=debug);

		/*
			Create the triangle for node 1, for node construction on demand (NOD).
			This creates a triangle between the node 1 curve-start-points and node
			1's center, forming part of the node.
		*/
			polygon(points=[N1_1_PA,[0,0],N1_2_PA]);
		/*
			Create the triangle for node 2, for node construction on demand (NOD).
			This is done similarly to the triangle for node 1.
		*/
			polygon(points=[N2_1_PB,N2_2_PB,[LINK_LEN,0]]);
		/*
			Create a part of node 1 located between the curve-points (of the main
			and "close" link) located on node 1 side 1. This is part of node
			construction on demand (NOD).

			Because more than one link may connect to a node, a rule must be used
			to ensure that another link does not go over an already created node
			part. The rule in this case is to only fill between the links in a
			clockwise direction - hence the parts are only created on
			node-1-side-1 and node-2-side-2.

			........
		*/
		if (NOD_1_OVER==false)
			node_part(NOD_N1_1_RP_A,NOD_N1_1_RP_B,[0,0],steps,debug);
		/*
			Node 2's side 2 filler is created in a similar way to Node 1's filler.

			.....
		*/
		if (NOD_2_OVER==false)
			node_part(NOD_N2_2_RP_A,NOD_N2_2_RP_B,[LINK_LEN,0],steps,debug);
	}
}

/******************************************************************************
                             C O N S T A N T S
******************************************************************************/

/*
	Small distance to use to help produce correct geometry.
*/
INFLECTUM_EPSILON = 0.001;

/*
	Approximate PI value.
*/
INFLECTUM_PI = 3.141592654;

/******************************************************************************
      N O D E  &   L I N K   S P E C I F I C A T I O N   F U N C T I O N S
******************************************************************************/

/*
	Function to allow construction of a node specification. This function should
	be used per node in the list passed to the inflectumShape() function. The
	function returns a lookup table, suitable for use with _inflectumGet().

	For this constructor function, the position of the node can be specified as
	a vector ('v'), or as its seperate components ('x' and 'y'). The radius is
	given	by 'r'. The defaults values are zeros if they are not specified.
*/
function inflectumNode(v=false,x=0,y=0,r=0) = 
	[["x",      (v != false) ? v[0] : x],
	 ["y",      (v != false) ? v[1] : y],
	 ["radius", r                      ]];

/*
	Function to allow construction of a link specification. This function should
	be used per link in the list passed to the inflectumShape() function. The
	function returns a lookup table, suitable for use with _inflectumGet().

	For this constructor function, the node angles can be specified as a list
	('angles'), or individually ('a*'). The default value for unspecified
	properties is 'undef'.

	Node angles are named in the form: a*%, where * is the node number (1 or 2),
	and % is the side number (1 or 2).
*/
function inflectumLink(n1=undef,n2=undef,angles=false,a11=undef,a12=undef,
                       a21=undef,a22=undef) = 
	[["node1",    n1                                ],
	 ["node2",    n2                                ],
	 ["angle11", (angles != false) ? angles[0] : a11],
	 ["angle12", (angles != false) ? angles[1] : a12],
	 ["angle21", (angles != false) ? angles[2] : a21],
	 ["angle22", (angles != false) ? angles[3] : a22],
	 // TODO
	 ["thickness",undef]];

/*
	Function to retrieve properties from node or link specifications. This
	function can be used to get the position, indexes and angles from the node
	and link specifications, which are usually passed to the inflectumShape()
	module.

	The names of the properties (passed as strings) are as follows:

		Node Properties: x, y, radius, location
		Link Properties: node1, node2, angle11, angle12, angle21, angle22,
		                 node, angle

	For node objects, the position of the node can be retrieved as a vector
	using the "location" property, or as the individual components using "x" and
	"y". For link objects, the node indexes can be retrieved using the seperate
	properties "node1" and "node2", or by using "node" and giving a value to the
	'number' parameter. In addition, the angles can be retrieved seperately, or
	by using the "angle" proeprty and providing values for the 'node' and
	'side' parameters.

*/
function _inflectumGet(obj,property,number=false,node=false,side=false) =

	/*
		Check if the object is not defined. This is done so that values are not
		looked up in a undefined table, which would result in warnings regarding
		the search term not being found.
	*/
	(obj==undef)

		// return undef
		? undef

	// otherwise, if object is defined
	:(
		// if the property is a non-extended type
		(__inflectumGet_isExtended(property)==false)
	
			// simply lookup the value
			? obj[search([property],obj)[0]][1]
	
		// otherwise, if property is extended type
		:(
			// if property is "location" (for node)
			(property=="location")
	
				// return the location of the node as a vector
				? [_inflectumGet(obj,"x"),_inflectumGet(obj,"y")]
	
			// otherwise
			:(
				// if property is "node" (for link)
				(property=="node")
	
					// return the respective node index
					? _inflectumGet(obj,number!=2?"node1":"node2")
	
				// otherwise
				:(
					// if property is "angle" (for link)
					(property=="angle")
					?(
						// if for node 1
						(node!=2)
	
							// return respective node
							? _inflectumGet(obj,side!=2?"angle11":"angle12")
	
						// otherwise, if for node 2
	
							// return respective node
							: _inflectumGet(obj,side!=2?"angle21":"angle22")
	
					// otherwise...
					):undef
				)
			)
		)
	);
	// sub-function to determine if property is of extended type
	function __inflectumGet_isExtended(property) = 

		// check if property is equal to any of the extended property names
		(property=="location") || (property=="node") || (property=="angle");


/******************************************************************************
                            L I N K   F U N C T I O N S
******************************************************************************/

/*
	Returns a link with a specified node (index) used as the reference node
	(first node). If the reference node (index) is the same as the first node
	(index), the original link is returned. If the reference node (index) is
	the same as the second node (index), the returned link has the nodes and
	sides flipped/swapped, to have the second node (index) as the first. If the
	reference node (index) is not present in the link, 'undef' is returned to
	signify that the link cannot be modified to use the reference node.
*/
function inflectumModifiedLink(link,refnode) = 
	// if link is undefined
	(link==undef)
		// return undef
		? undef
	// otherwise, if link is defined
	:(
		// if first node is the reference node
		(_inflectumGet(link,"node1")==refnode)
			// just use original link
			? link
		// otherwise, if first node not reference node
		:(
			// if second node is the reference node
			(_inflectumGet(link,"node2")==refnode)
				// swap nodes and sides around
				? inflectumLink(
					n1  = _inflectumGet(link,"node2"),
					a11 = _inflectumGet(link,"angle22"),
					a12 = _inflectumGet(link,"angle21"),
					n2  = _inflectumGet(link,"node1"),
					a21 = _inflectumGet(link,"angle12"),
					a22 = _inflectumGet(link,"angle11"))
	     // otherwise, if second node is also not ref node
	        // simply return undef, because the node is not present
	        : undef
		)
	);

/*
	Returns the absolute angle of the link passed. The angle starts from (is 0
	degrees at) the +x axis, increasing in a anticlockwise direction. The
	function finds this angle by using the angle() function (which
	uses the atan2() function), passing it a vector given by:
	
		v = N2 - N1

	where N2 and N1 are the positions ([x,y]) of the second and first nodes
	respectively.
*/
function inflectumLinkAngle(nodes,link) =
	// get the angle of the vector (given by node 2 minus node 1's position)
	angle(
		// (node 2 position)
		_inflectumGet(nodes[_inflectumGet(link,"node2")],"location")
		// (minus node 1 position)
		-_inflectumGet(nodes[_inflectumGet(link,"node1")],"location"));

/*
	Returns the length of the link passed (given the node list). The function
	finds this angle by using the norm() function, passing it a vector
	given by:

		v = N2 - N1

	where N2 and N1 are the positions ([x,y]) of the second and first nodes
	respectively.
*/
function inflectumLinkLength(nodes,link) = 
	// get the length of the vector (given by node 2 minus node 1's position)
	norm(
		// (node 2 position)
		_inflectumGet(nodes[_inflectumGet(link,"node2")],"location")
		// (minus node 1 position)
		-_inflectumGet(nodes[_inflectumGet(link,"node1")],"location"));

/*
   Finds the index of a link at an angle closest to the specified link (by
   index), for the specified node (1 or 2, corresponding to the nodes specified
   in the link being compared against) and side (1 or 2), given a list of nodes
   and links, and the index of the link to find the closest to.

   The function works by recursively going through each link, finding the angle
   for each and determining the one which is closest to the specified side,
   remembering to skip links that do not contain the reference node (given by
   the link and node number), and to skip the link being compared to. It will
   return 'undef' if a link was not found.
*/
function inflectumClosestLinkIndex(nodes,links,linkIndex,node,side) = 
	/*
		We want to go through each link and find the closest angled link. This is
		done using the recursive _inflectumCLF() sub-function.
	*/
	_inflectumCLF(

		// pass the node and link lists
		nodes,links,
		/*
			We only need the angle of the link. If the reference node is the
			second node in the link, 180 degrees must be added to correct the
			angle.
		*/
		(inflectumLinkAngle(nodes,links[linkIndex])+(node==2?180:0)),
		/*
			We also need the index of the reference node. This node will be used
			as the origin-point, for which angles are calculated from.
		*/
		_inflectumGet(links[linkIndex],"node",number=node),
		/*
			We also need the direction for the link from the angle. In this case,
			greater-than (">") means that the matching-link must have an angle
			greater than the link. On the other hand, less-than ("<") means that
			the matching link must have an angle smaller than the link.

			Absolute angles are used, starting from the +x axis, increasing in an
			anticlockwise direction.
		*/
		(node==1 ? (side==1 ? "<" : ">")
		         : (side==1 ? ">" : "<")),
		/*
			The first index to start at is zero. The function will keep calling
			its self, incrementing this index each time, until the end of the link
			list has been reached, at which point it returns 'undef'.
		*/
		0,
		// we need to skip the link being angle-compared. 
		linkIndex)
		/*
		   The recursive match function works with / returns angle-index pairs,
		   hence to only return the index, the second element must be retrieved.
		*/
		[1];
	/*
		Recursive function to go through the links and the find closest angled-
		link to the base-link, for a given side. The function recursively calls
		its self, passing a comparison function the reference angle (from the
		base-link), current (direction corrected) angle, and the next angle (by
		calling its self again with an incremented index, to access the next
		link).
	*/
	function _inflectumCLF(nodes,links,angle,nodeIndex,dir,i,skip) = 
		/*
			If the index is out of bounds, return 'undef'. This condition is
			reached when the end of the link-list has been reached.
		*/
		(i >= len(links)) ? undef

		// otherwise, if index is in range
			/*
				Return the closest-angled link angle-index pair, by passing a
				comparison function the current and next link. The next link is
				obtained by having this function call its self again, but with the
				index (i) incremented.

				The comparison function is passed the angle-index pairs for the
				current and next links. These pairs	allow the angle to be compared,
				with the index of the link kept associated with it. The value
				returned will be the winning angle-index pair.
			*/
			: _inflectumCLF_C(
				/*
					Determine whether this link must be skipped. This may be because
					it is the link being compared to (whose index is given by
					'skip'), it does not contain the reference node (given by
					nodeIndex), or one of the node indexes is undefined.
				*/
				// if this link must be skipped because it is being compared to
				((i==skip)

				// or if this link does not contain the reference node
				|| (_inflectumGet(links[i],"node1")!=nodeIndex
				  &&_inflectumGet(links[i],"node2")!=nodeIndex)

				// or if this link has at least one undefined node index
				|| (_inflectumGet(links[i],"node1")==undef
				  || _inflectumGet(links[i],"node2")==undef))

					// use an undefined value to skip this link
					? undef

				// otherwise, if not to be skipped
					/*
						Use the link, passing a angle-index pair to the comparison
						function. The angle function (_inflectumCLF_A()) retrieves
						the direction-corrected angle of the link, taking into
						account which of the nodes in the link is the reference node
						(the node common to both the original and "close" link).
					*/
		       	:[_inflectumCLF_A(nodes,links[i],nodeIndex,dir,angle),i],
				/*
					Compare with next link angle, by passing the comparison function
					the next-link's angle. This is done by getting this function to
					call its self again with a different index. The function will
					itself return an angle-index pair.
				*/
				_inflectumCLF(nodes,links,angle,nodeIndex,dir,i+1,skip),
				/*
					The direction must also be passed to the comparison function, to
					let it know whether to return the smaller or larger angle.
				*/
				dir);
	/*
		Sub-function to find the corrected angle for the specified link in the
		recursive iteration. It uses the angleCorrection() function to
		make the angle easily comparable to the base-link angle. It also uses the
		inflectumModifiedLink() function to make the link use the common node
		as the reference node, where inflectumLinkAngle() is used to take the
		angle of this modified link.
	*/
	function _inflectumCLF_A(nodes,link,nodeIndex,dir,angle) = 
		// return the corrected angle
		angleCorrection(

				// get the angle of the reference-node-modified link
				inflectumLinkAngle(nodes,inflectumModifiedLink(link,nodeIndex)),

				// correction requires reference angle and direction
				angle,dir);
	/*
		Comparison sub-function which returns the closest of the two angles to
		the base angle, based on a given direction. The two angles being compared
		are given as angle-index pairs, so that the index of the link is
		associated with its angle. The function also takes	into account
		undefined angle-index pairs and undefined angles.

		Because the angles have already been corrected to be smaller or
		greater than the base/reference angle, the comparison only needs to
		be done between the two angles, finding the minimum or maximum based
		on the direction.
	*/
	function _inflectumCLF_C(angle_index1,angle_index2,dir) = 
		// if the first value or its angle is undefined
		(angle_index1==undef||angle_index1[0]==undef)

			// return the second value
			? angle_index2

		// otherwise
		:(
			// if the second value or its angle is undefined
			(angle_index2==undef||angle_index2[0]==undef)

				// return the first value
				? angle_index1

			// otherwise
			:(
				// if finding closest angle greater than reference angle
				(dir==">")
					/*
						Return the angle-index pair with the smallest angle. The
						angles have already been made greater than the reference
						angle (from using angleCorrection()).
					*/
					?((angle_index1[0] < angle_index2[0])
					   ? angle_index1 : angle_index2)

				// otherwise, if finding closest angle smaller than ref angle
					/*
						Return the angle-index pair with the largest angle. The
						angles have already been made smaller than the reference
						angle (from using angleCorrection()).
					*/
					: ((angle_index1[0] > angle_index2[0])
					   ? angle_index1 : angle_index2)
			)
		);

/*
	Finds the type of a given link, based on what details (angles, thickness)
	have been provided (defined or undefined values). The types are as follows:

		"angles"              -- angles only
		"thickness"           -- thickness only
		"thickness+angles"    -- thickness and at least 1 angle per side
		"thickness+angleSide" -- thickness and one or both angles for one side
*/
function inflectumLinkType(link) = 

	// if no thickness has been specified
	(_inflectumGet(link,"thickness") == undef)

		// this is a thickness-less link (angles only)
		? "angles"

	// otherwise, if thickness specified
	:(
		// if no angles have been defined
		(_inflectumGet(link,"angle11")==undef
		 && _inflectumGet(link,"angle12")==undef
		 && _inflectumGet(link,"angle21")==undef
		 && _inflectumGet(link,"angle22")==undef)

			// this is a thickness-only link
			? "thickness"

		// otherwise, if there is at least one angle specified
		:(
			// if there is at least one angle specified per side
			((_inflectumGet(link,"angle11")!=undef
			  ||_inflectumGet(link,"angle21")!=undef)
			 && (_inflectumGet(link,"angle12")!=undef
			  ||_inflectumGet(link,"angle22")!=undef))

				// this is a thickness and all-angles link
				? "thickness+angles"

			// otherwise, if only one side has at least one angle specified

				// this is a thickness and a single side with angles
				: "thickness+angleSide"));

/*
	Finds the type of a given link side, based on what details (angles,
	thickness) have been provided (defined or undefined values). The types
	are as follows:

		"curved"            -- basic curve, independent of thickness node
		"linear"            -- linear line between nodes (straight curve)
		"centeredThickness" -- for when only thickness is specified for link
		"forcedThickness"   -- for angles and forced thickness node insertion
		"forcedCurve"       -- for when curve depends on other side's curve
*/
function inflectumLinkSideType(link,side) = 

	// if link is only angles
	(inflectumLinkType(link)=="angles")
	?(
		// if selected side has at least one angle specified
		(_inflectumGet(link,"angle",node=1,side=side)!=undef
		 ||_inflectumGet(link,"angle",node=2,side=side)!=undef)

			// this is a basic curve side
			? "curved"

		// otherwise, if selected side has no angles specified

			// this is a linear side
			: "linear"

	// otherwise, if link has thickness specified
	):(
		// if only a thickness is specified
		(inflectumLinkType(link)=="thickness")

			// this is a centered thickness-node side
			? "centeredThickness"

		// otherwise, if at least one angle has been specified
		:(
			// if at least one angle has been specified per side
			(inflectumLinkType(link)=="thickness+angles")

				// this is a non-centered & forced thickness-node side
				? "forcedThickness"

			// otherwise, if one side has no angles specified
			:(
				// if this side has at least one angle specified
				(_inflectumGet(link,"angle",node=1,side=side)!=undef
				 ||_inflectumGet(link,"angle",node=2,side=side)!=undef)

					// this is a forced curve side
					? "forcedCurve"

				// otherwise, if this side has no angles specified

					// this is a basic curve side
					: "curved"
			)
		)
	);

/*
	Finds the link-relative angles for a node for a selected side, given a list
	of nodes and links, the index of the link the angle is for (the main link),
	and the selected node and side numbers. This function actually returns two
	angles, the first being the link-relative node angle (the main-link/desired
	angle), and the second being the angle for the "close" link (still relative
	to the main link).

	The function works by finding the relative (to the selected link) angles
	for the selected node/side of the link and "closest" link, and correcting the
	final angles if overlap occurs. It makes use of a sub-function which gets
	the relative angle for a selected node without taking into account
	overlap - the rest / other sub-functions deal with the overlap instead.
*/
function inflectumLinkNodeAngles(nodes,links,linkIndex,node,side) = 
	/*
		Call a sub-function. Sub-functions for this function are used to deal
		with working out variables/values which depend on previous calculations.
		Splitting these calculations up into seperate functions allows such
		dependencies to be handled.
	*/
	_inflectumLNA_1(

		// pass the nodes list and the link
		nodes=nodes, LINK = links[linkIndex],

		// pass the selected node and side
		node=node,side=side,
		/*
			Find the closest link for the selected node and side. This is done by
			using the inflectumClosestLinkIndex() function, and using this index
			to	retrieve the link from the link-list. In addition, the reference
			node of the link is modified to be the node common to both links, by
			using the inflectumModifiedLink() function.
		*/
		CLOSE_LINK = inflectumModifiedLink(

			// get the actual link from the index
			links[

				// find the index of the closest link for the selected side and node
				inflectumClosestLinkIndex(nodes,links,linkIndex,node,side)
			],
			// change the reference node
			_inflectumGet(links[linkIndex],"node",number=node)));

	// another sub-function which does part of the calculations
	function _inflectumLNA_1(nodes,LINK,node,side,CLOSE_LINK) = 
		// call a sub-function which will do more of the calculations...
		_inflectumLNA_2(

			// pass selected node and side spec
			node=node, side=side,

			// get the current link's angle
			LINK_ANGLE = inflectumLinkAngle(nodes,LINK),
			/*
				Get the angle for the "closest" link. Because the reference node of
				this "close" link is modified, this angle will be the angle of the
				common (reference) node to the other node.
			*/
			CLOSE_ANGLE = inflectumLinkAngle(nodes,CLOSE_LINK),

			// get the relative angle for the node on the main link
			LINK_N_RA  = _inflectumNA(nodes,LINK,node,side),
			/*
				Get the relative angle for the (common) node on the "close" link.
				Because the reference node is made to be the common node, the angle
				will come from only node 1, for either side 1 or 2.
			*/
			CLOSE_N_RA = _inflectumNA(nodes,CLOSE_LINK,1,(node==side?2:1)),
			/*
				Get the original angle specified for the main-link node. This is the
				angle which has not been substituted with an angle if one was not
				provided - the value may actually be undefined. This is used to help
				determine what the overlap-correction angle should be.
			*/
			ORIG_LINK_N_RA  = _inflectumGet(LINK,"angle",node=node,side=side),
			/*
				Get the original angle specified for the "close"-link node. Again,
				because the reference node is changed, only the angles for node 1
				need to be used.
			*/
			ORIG_CLOSE_N_RA = _inflectumGet(CLOSE_LINK,"angle",
			                               node=1,side=(node==side?2:1)),
			//	Get the radius of the node.
			NODE_RADIUS = _inflectumGet(
				nodes[_inflectumGet(LINK,"node",number=node)],
				"radius"));

	// another sub-function which does part of the calculations
	function _inflectumLNA_2(node,side,LINK_ANGLE,CLOSE_ANGLE,LINK_N_RA,
	                         CLOSE_N_RA,ORIG_LINK_N_RA,ORIG_CLOSE_N_RA,
	                         NODE_RADIUS) =

		// call a sub-function which will do more of the calculations...
		_inflectumLNA_3(

			// pass selected node and side spec
			node=node, side=side,
			/*
				Get the main-link node angle for the common node relative to the
				main link. The equations for the different angles (for the two
				nodes and two sides) are as follows:

					N1_A1      = -N1_RA1; // node 1 side 1
					N1_A2      =  N1_RA2; //  "   1   "  2
					N2_A1      =  N2_RA1; //  "   2   "  1
					N2_A2      = -N2_RA2; //  "   2   "  2

				where N*_A* is the node angle relative to the main/current link, and
				N*_RA* is the relative node angle of the node/side. A compressed
				version of these is used to determine the main-link-relative
				main-link node angle.
			*/
			LINK_N_A = LINK_N_RA*(node==side?-1:1),
			/*
				Get the close-link node angle for the common node relative to the
				main link. The equations for the different angles are as follows:

					C_N1_A1 = z(C_N11_ANGLE-LINK_ANGLE+180, 180,"<")+C_N1_RA1;
					C_N1_A2 = z(C_N12_ANGLE-LINK_ANGLE+180,-180,">")-C_N1_RA2;
					C_N2_A1 = z(C_N21_ANGLE-LINK_ANGLE,    -180,">")-C_N2_RA1;
					C_N2_A2 = z(C_N22_ANGLE-LINK_ANGLE,     180,"<")+C_N2_RA2;

				where C_*N*_A* is the close-link node angle relative to the main
				link, z is the angle correction function, C_N**_ANGLE is the angle
				of the close-link, LINK_ANGLE is the angle of the main link, and
				C_N*_RA* is the relative node angle of the close-link. A compressed
				version of these is used to determine the main-link-relative
				close-link node angle.
			*/
			CLOSE_N_A = angleCorrection(
				  CLOSE_ANGLE-LINK_ANGLE+(node==1?180:0),
				  180*(node==side?1:-1),((node==side)?"<":">"))
				+CLOSE_N_RA*(node==side?1:-1),

			// pass original angle specs
			ORIG_LINK_N_RA=ORIG_LINK_N_RA, ORIG_CLOSE_N_RA=ORIG_CLOSE_N_RA,

			// pass node radius
			NODE_RADIUS=NODE_RADIUS);

	// another sub-function which does part of the calculations
	function _inflectumLNA_3(node,side,LINK_N_A,CLOSE_N_A,
	                         ORIG_LINK_N_RA,ORIG_CLOSE_N_RA,NODE_RADIUS) = 
		/*
			Call the last sub-function, which will deal with the presence of
			overlap and the corrected angle, returning the desired
			node/side-relative node angle.
		*/
		_inflectumLNA_final(

			// pass selected node and side numbers
			node=node, side=side,
			/*
				Determine whether there is angle overlap between the main and
				"close" link. The condition is worked out as follows for the
				different angles:

				N1_A1_OVERLAP = C_N1_A1 > -N1_A1;   // node 1 side 1
				N1_A2_OVERLAP =   N1_A2 >  C_N1_A2; //  "   1  "   2
				N2_A1_OVERLAP =  -N2_A1 >  C_N2_A1; //  "   2  "   1
				N2_A2_OVERLAP = C_N2_A2 >  N2_A2;   //  "   2  "   2

				where N*_A*_OVERLAP is the overlap state (true/false), C_N*_A*
				is the node angle from the "close" link (relative to the main
				link), and N*_A* is the node angle from the main link. A
				compressed version of these is used to determine the overlap
				state	for the selected main-link node angle.
			*/
			LINK_N_A_OVER = ((node==side) ? CLOSE_N_A
			                              : LINK_N_A*(node==2?-1:1))
			              > ((node==side) ? LINK_N_A*(node==1?-1:1)
			                              : CLOSE_N_A),

			// pass link and close-link node angles
			LINK_N_A=LINK_N_A,CLOSE_N_A=CLOSE_N_A,
			/*
				Determine the average angle between the close-link and main-link
				node angles (relative to the main-link). This will only be used if
				the originally-specified angles are both defined or both undefined,
				and there is overlap.
			*/
			LINK_N_A_AVE = (LINK_N_A + CLOSE_N_A)/2,

			// pass original angle specs
			ORIG_LINK_N_RA=ORIG_LINK_N_RA, ORIG_CLOSE_N_RA=ORIG_CLOSE_N_RA,

			// pass node radius
			NODE_RADIUS=NODE_RADIUS);

	/*
		Sub-function to determine final angle to use. The final angle will depend
		on the overlap status of the node angle (LINK_N_A_OVER), as well as which
		of the links (main or "close") originally provides a defined/undefined
		node angle (ORIG_LINK_N_RA and ORIG_CLOSE_N_RA). The average between the
		angles (LINK_N_A_AVE) may be used depending on which angles were
		originally specified.

		The function returns a vector containing the node angle (relative to the
		link) for the selected link, and the node angle (still relative to the
		selected link) for the "close" link.
	*/
	function _inflectumLNA_final(node,side,LINK_N_A_OVER,
	                             LINK_N_A,CLOSE_N_A,LINK_N_A_AVE,
	                             ORIG_LINK_N_RA,ORIG_CLOSE_N_RA,NODE_RADIUS) = 

		// if there is no angle overlap
		(LINK_N_A_OVER == false)

			// simply use original angles (with geom-correction offset)
			? [LINK_N_A +_inflectumOA(NODE_RADIUS,node,side),
			   CLOSE_N_A+_inflectumOA(NODE_RADIUS,node==1?2:1,side)]

		// otherwise, if there is overlap
		:(
			// if both of the angles are equally originally defined or undefined
			((ORIG_LINK_N_RA == undef && ORIG_CLOSE_N_RA == undef)
			 ||(ORIG_LINK_N_RA != undef && ORIG_CLOSE_N_RA != undef))

				// use average angle (with geom-correction offset)
				? [LINK_N_A_AVE+_inflectumOA(NODE_RADIUS,node,side),
				   LINK_N_A_AVE+_inflectumOA(NODE_RADIUS,node==1?2:1,side)]

			// otherwise, if one of the angles is defined
			:(
				// if the main link has the angle defined
				(ORIG_LINK_N_RA!=undef)

					// use the main link angle
					? [LINK_N_A+_inflectumOA(NODE_RADIUS,node,side),
					   LINK_N_A+_inflectumOA(NODE_RADIUS,node==1?2:1,side)]

				// otherwise, if the "close" link has the angle defined

					// use the close link angle
					: [CLOSE_N_A+_inflectumOA(NODE_RADIUS,node,side),
					   CLOSE_N_A+_inflectumOA(NODE_RADIUS,node==1?2:1,side)]
			)
		);
	/*
		Sub-function to return an angle-offset suitable for helping to ensure
		that geometry issues do not occur.

		Because this offset angle is relative to the link and not the node, the
		angle needs to be correctly negated, which is why the 'node' and 'side'
		parameters must be given. The node-relative angle offset is given as:

			EPSILON/(2*PI*R)*360

		where EPSILON is the small offset length on the circumference circle,
		and R is the radius of the node. This angle offset is intended to make
		the curve point more outwards from the link (hence it is positive).
		This allows overlap to occur.

		For the node-relative angle to be made relative to the link, negation
		is done as per the following:

			N1_A1 = -REL_ANGLE_11     // node 1 side 1
			N1_A2 =  REL_ANGLE_12     //  "   1  "   2
			N2_A1 =  REL_ANGLE_21     //  "   2  "   1
			N2_A2 = -REL_ANGLE_22     //  "   2  "   2

		where N*_A* is the link-relative angle, and REL_ANGLE_** is the node-
		relative angle.
	*/
	function _inflectumOA(radius,node,side) = 
		INFLECTUM_EPSILON/(2*INFLECTUM_PI*radius)*360*(node==side?-1:1);
	/*
		An important sub-function wich works out the relative node angle of a
		link, given the node list, the link to which the angle is from, and the
		selected node and side (numbers). The angle returned from this function
		generally does not take into account any angle-overlap - that is handled
		by the other sub-functions.
	*/
	function _inflectumNA(nodes,link,node,side) =
		// if this is a straight-line side
		(inflectumLinkSideType(link,side)=="linear")

			/*
				Use the angle of the tangent line on the side of the nodes. This
				allows a straight bezier-curve (line) to be produced.
			*/
			? -inflectumLinearNodeAngle(nodes,link,node)

		// otherwise, if not a straight side
		:(
			// if this is a curved side
			(inflectumLinkSideType(link,side)=="curved")
			?(
				// if angle is defined for selected node
				(_inflectumGet(link,"angle",node=node,side=side)!=undef)

					// use angle
					? _inflectumGet(link,"angle",node=node,side=side)

				// otherwise, if angle not defined for selected node

					// use same relative angle from other node on same side
					: _inflectumGet(link,"angle",node=(node==1?2:1),side=side)

			// otherwise, if not a curved side
			):(
				// side type is currently unsupported...
				undef

				//TODO: add thickness support
			)
		);

/*
	Returns the angle of the tangent line on the side of the nodes for a linear
	connection. This allows a straight bezier-curve (line) to be produced.

	The angle is given by a vector, whose x component is given by the
	distance between the node centers, and y component given by the
	radius of the first node minus the radius of the second. If the
	relative angle is for the second node, it is flipped (negated).
*/
function inflectumLinearNodeAngle(nodes,link,node) = 
	-angle([

			// x component (length of link) - use vector n2-n1
			norm(

				// node 2 position
				_inflectumGet(nodes[_inflectumGet(link,"node2")],"location")

				// minus node 1 position
				-_inflectumGet(nodes[_inflectumGet(link,"node1")],"location")
			),
			// y component (difference in node radii) - given by r1-r2
			_inflectumGet(nodes[_inflectumGet(link,"node1")],"radius")
			-_inflectumGet(nodes[_inflectumGet(link,"node2")],"radius")])

	// node angle correction - if node 2, flip (negate)
	*(node==2?-1:1);
