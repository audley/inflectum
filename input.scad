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
    along with Inflectum.  If not, see <http://www.gnu.org/licenses/>.
*/

include <common.scad>
include <config.scad>
include <value.scad>
include <structures.scad>
include <keywords.scad>

/*
	These functions are used to construct the input nodes, links and defaults
	passed to the main inflectum module.

	Functions:
		function inflectumNode(id,position,radius)
		function inflectumOuterNode(id,node,angle,radius,onOutside,onInside)
		function inflectumLink(node,angle1,angle2,radius1,radius2)
		function inflectumAutoRadius(distance)
		function inflectumDefaults(node,link,autoRadius)
*/

/******************************************************************************
                S P E C I F I C A T I O N   F U N C T I O N S
******************************************************************************/

/*
	Creates a basic node (specification). This (along with inflectumOuterNode())
	should be used to create the nodes for the list passed to the main module.
	The specification is stored as a formatted structure.

	The node must be given an id, and optionally a position and radius. If the
	position or radius is omitted, the undef values will be replaced with
	defaults (in the processing).

		id = <string>
		position = <2D vector>
			(undef components will be replaced with defaults)
		radius = <number>
			(minimum = CONFIG_MIN_RADIUS)
	
		(-inf,inf and nan values will be counted as undef)

	id:
		The id used by the links to refer to the node.
	position:
		The position of the center of the circular node.
	radius:
		The radius of the circular node.

	If the defaults used to fill in unspecified properties contain undef
	values (on purpose) or the id is invalid (defaults cannot be used for ids),
	the node is invalid and will be omitted.
*/
function inflectumNode(id,position,radius) = _
(
	// filter the position components to be normal numbers
	$pos = [number(position[0]),number(position[1])],
	// filter the radius, and limit to the minimum radius 
	$radius = max(number(radius),CONFIG_MIN_RADIUS),

	// construct the node
	$node = node(id=string(id),x=$pos[0],y=$pos[1],radius=$radius),

	// return the node
	RETURN ($node)
);

/*
	Creates an outer node, that is, a node placed relative to another node.
	This (along with inflectumNode()) should be used to create the nodes for
	the list passed to the main module. The specification is stored as a
	formatted structure.

	The node must be given an id and the node to be relative to (the actual
	node, not an ID), and optionally an angle, radius and one "flag" to do
	with whether it is placed on the inside or outside. If the position or
	radius of the node passed is undef (unspecified/invalid), or the angle
	is unspecified/invalid, the node will use the default position.

		id = <string>
		node = <node>
			(created using inflectumNode() or inflectumOuterNode())
		angle = <angle>
		radius = <number>
			(minimum = CONFIG_MIN_RADIUS)
		onOutside = true OR false
		onInside = true OR false
	
		(-inf,inf and nan values will be counted as undef)

	id:
		The id used by the links to refer to the node.
	node:
		The node to be relative to.
	angle:
		The angle that gives the position of the node relative to the node
		passed. The angle goes in an anticlockwise direction from the +x axis,
		relative to the center of the node passed.
	radius:
		The radius of the circular node.
	onOutside and onInside:
		Sets whether the node is placed on the outside or inside of the node
		passed. Both default to false. If both are at the same time false/
		invalid or true, the node's center is placed on the base-node's
		border.
*/
function inflectumOuterNode(id,node,angle,radius,onOutside,onInside) = _
(
	// filter the provided angle and flags
	$angle = number(angle),
	$onOutside = boolean(onOutside),
	$onInside = boolean(onInside),

	// filter the radius, and limit to the minimum radius
	$radius = max(number(radius),CONFIG_MIN_RADIUS),

	// work out the radius offset (to account for the flags)
	$rOffset = _
	(
		// if both are of same condition, place node on boundary
		IF (($onOutside==$onInside)
			|| ($onOutside==undef && $onInside==false)
			|| ($onOutside==false && $onInside==undef)) ? THEN (0)
		// if to be placed outside, place node outside boundary
		:ELSE_IF ($onOutside==true) ? THEN ($radius)
		// if to be placed inside, place node inside boundary
		:ELSE (-$radius)
	),

	// find the radius and position of the node to be relative to
	$rnRadius = node[nodeRadius], $rnPos = [node[nodeX],node[nodeY]],
	// calculate the position of the new node
	$pos = $rnPos+($rnRadius+$rOffset)*[cos($angle),sin($angle)],

	// construct the node
	$node = node(id=string(id),x=$pos[0],y=$pos[1],radius=$radius),

	// return the node
	RETURN ($node)
);

/*
	Creates a link specification. Should be used to create the links for the
	list passed to the main module. The specification is stored as a formatted
	structure.

	The link must be given the id of a node, for which the link starts from
	(the link ends on the node given by the next link), and optionally the
	relative start and end angles, and overriding start and end radii. Omitted/
	undef angles will be replaced by defaults in the processing.

		node = <string>
			(an id from the node list)
		angle1 = <number>
		angle2 = <number>
		radius1 = <number> or inflectumNode or inflectumAuto
			(minimum <number> = CONFIG_MIN_RADIUS)
		radius1 = <number> or inflectumNode or inflectumAuto
			(minimum <number> = CONFIG_MIN_RADIUS)

	node:
		The id of the starting node for this link to connect to. The ending
		node is given by the node from the next link (which may be the first
		link if the link is at the end).
	angle1 and angle2:
		The node-relative angles to use for each node in the link. All
		angles are relative to the "linear" angle (formed from the line
		between the sides of the nodes). These angles are not strictly
		enforced, and may be changed to correct overlapping angles,
		averaging the angles if necessary. Negative angles point inwards,
		while positive angles point outwards.
	radius1,radius2:
		Overriding start and end node radii. This allows two or more different
		radii to be used on a single node (consine/bezier interpolation is used
		when necessary). If inflectumNode is used, the radius is given by the
		original node. If inflectumAuto is used, an automatic radius is used, and
		is configured by passing an auto-radius specification to the defaults-
		constructor.
		
	If the node id is unknown or invalid, the link will not be constructed.
*/
function inflectumLink(node,angle1,angle2,radius1,radius2) = 
	link(id=node,node=string(node),angle1=number(angle1),angle2=number(angle2),
		radius1=_inflectumLink_autoRadius(radius1),
		radius2=_inflectumLink_autoRadius(radius2));
	function _inflectumLink_autoRadius(radius) = 
		IF (radius==inflectumNode || radius==inflectumAuto) ?
			THEN  (radius)
			:ELSE (max(number(radius),CONFIG_MIN_RADIUS));

/*
	Creates an auto-radius specification that allows auto-radii to be configured.
	This is passed to the defaults-constructor.

	To configure auto-radii, a minimum distance between the links must be given.
	Through use of a formula (taking into account this distance, the angle between
	the links), an "auto"matic radius is found.

		distance = <number>
			(minimum = CONFIG_MIN_RADIUS)
	
	distance:
		The minimum distance between the sides of two close links.
*/
function inflectumAutoRadius(distance) =
	autoRadius(distance=max(number(distance),CONFIG_MIN_RADIUS));

/*
	Creates a default specification, given default node, link and optional
	auto-radius specifications. The node and link defaults will be used for
	unspecified (undef) properties for the nodes and links, while the auto-radius
	specification is used to configure automatic radii. Just in case these defaults
	are unspecified or invalid values have been used, the following are the
	hard-coded defaults for the defaults (corrected in preprocessing):

		node:
			position  = [undef,undef]
			radius    = CONFIG_MIN_RADIUS
		link:
			angle1  = 0
			angle2  = 0
			radius1 = inflectumNode
			radius2 = inflectumNode
		autoRadius:
			distance = CONFIG_MIN_RADIUS
		
	For nodes, some of the hard-coded defaults are undef, so if these
	properties are left unspecified and the defaults for these properties are
	also undef, the node will be invalid and will not be created.
*/
function inflectumDefaults(node,link,autoRadius) = 
	defaults(node=node,link=link,autoRadius=autoRadius);
