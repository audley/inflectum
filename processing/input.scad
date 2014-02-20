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

include <../common.scad>
include <../structures.scad>
include <../value.scad>
include <../keywords.scad>

/*
	This file contains functions to fill empty node/link/autoRadius properties
	with properties from default specifications, and functions to check whether
	a node/link/autoRadius is valid.

	Default-Correction Functions:
		function nodeCorrection(node,default)
		function linkCorrection(link,default)
		function autoRadiusCorrection(autoRadius,default)
	Verification Functions:
		function nodeIsValid(node)
		function linkIsValid(link)
		function autoRadiusIsValid(autoRadius)
*/

/******************************************************************************
            D E F A U L T - C O R R E C T I O N   F U N C T I O N S
******************************************************************************/

/*
	Replaces any undefined node properties with default values, returning the
	"corrected" node. A default node containing the default values must be
	provided.
*/
function nodeCorrection(node,default) =
	node(node=default,
		id=node[nodeID],x=node[nodeX],y=node[nodeY],radius=node[nodeRadius]);

/*
	Replaces any undefined link properties with default values, returning the
	"corrected" link. A default link containing the default values must be
	provided.
*/
function linkCorrection(link,default) = 
	link(link=default,
		node=link[linkNode],angle1=link[linkAngle1],angle2=link[linkAngle2],
		radius1=link[linkRadius1],radius2=link[linkRadius2]);

/*
	Replaces any undefined auto-radius properties with default values,
	returning the "corrected" auto-radius-specification. A default specification
	containing the default values must be provided.
*/
function autoRadiusCorrection(autoRadius,default) = 
	autoRadius(autoRadius=default,distance=autoRadius[autoRadiusDistance]);

/******************************************************************************
             V E R I F I C A T I O N   F U N C T I O N S
******************************************************************************/
/*
	Returns true if the node is valid, otherwise false. A node is valid when all
	of its properties are fully defined.
*/
function nodeIsValid(node) = _
(
	// obtain the separate minimal properties
	$id     = node[nodeID],
	$x      = node[nodeX],
	$y      = node[nodeY],
	$rad    = node[nodeRadius],

	// determine whether the node is valid
	$valid = !(!isString($id)||$x==undef||$y==undef||$rad==undef),

	// return the result
	RETURN ($valid)
);

/*
	Returns true if the link is valid, otherwise false. A link is valid when all
	of its properties are fully defined.
*/
function linkIsValid(link) = _
(
	// obtain the separate minimal properties
	$node    = link[linkNode],
	$angle1  = link[linkAngle1],
	$angle2  = link[linkAngle2],
	$radius1 = link[linkRadius1],
	$radius2 = link[linkRadius2],

	// determine whether the link is valid
	$radius1_OK = $radius1==inflectumNode
		||$radius1==inflectumAuto||number($radius1)!=undef,
	$radius2_OK = $radius2==inflectumNode
		||$radius2==inflectumAuto||number($radius2)!=undef,
	$valid = !(!isString($node)||$angle1==undef||$angle2==undef
		||!$radius1_OK||!$radius2_OK),

	// return the result
	RETURN ($valid)
);

/*
	Returns true if the auto-radius-specification is valid, otherwise false. An
	auto-radius-specificaiton is valid when all of its properties are
	fully defined.
*/
function autoRadiusIsValid(autoRadius) = _
(
	// obtain the separate minimal properties
	$distance = autoRadius[autoRadiusDistance],

	// determine whether the auto-radius-specification is valid
	$valid = !($distance==undef),

	// return the result
	RETURN ($valid)
);
