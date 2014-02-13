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

/*
	This file contains functions to fill empty node and link properties with
	properties from default nodes/links, and functions to check whether a
	node/link is valid.

	Default-Correction Functions:
		function nodeCorrection(node,default)
		function linkCorrection(link,default)
	Verification Functions:
		function nodeIsValid(node)
		function linkIsValid(node)
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
		node=link[linkNode],angle1=link[linkAngle1],angle2=link[linkAngle2]);

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
	$node   = link[linkNode],
	$angle1 = link[linkAngle1],
	$angle2 = link[linkAngle2],

	// determine whether the link is valid
	$valid = !(!isString($node)||$angle1==undef||$angle2==undef),

	// return the result
	RETURN ($valid)
);
