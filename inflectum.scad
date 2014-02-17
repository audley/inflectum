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

use <processing.scad>
use <input.scad>

/*
	This file contains the main inflectum module which creates a flat 2D
	shape given a list of nodes, links and defaults. Included by this file are
	the constructor functions for nodes, links and defaults (from input.scad).
	The detail level of the constructed shape depends on the value of $fs.

	IMPORTANT NOTE:
	To create links that form the outside of the fill region, the links must be
	specified in a clockwise order. To create links that are to be on the
	inside (which can be subtracted from the main fill to make the shape have
	holes), the links must be specified in a anticlockwise order.

	Modules:
		module inflectumShape(nodes,links,defaults)
	Functions: (from input.scad)
		function inflectumNode(id,position,radius)
		function inflectumOuterNode(id,node,angle,radius,onOutside,onInside)
		function inflectumLink(node,angle1,angle2)
		function inflectumDefaults(node,link)
*/

/******************************************************************************
                M A I N   I N F L E C T U M   M O D U L E
******************************************************************************/

/*
	The main inflectum module. Creates a 2D shape from the specified nodes,
	links and defaults provided. If no links or nodes are provided, nothing will
	be created. If defaults are not provided, hard-coded defaults will be used.

	This function uses the process() function to generate a list of 2D points
	which are then constructed using the polygon() module.
*/
module inflectumShape(nodes,links,defaults)
{
	// generate the points
	POINTS = process(nodes,links,defaults);

	// create the 2D shape
	polygon(POINTS);
}
