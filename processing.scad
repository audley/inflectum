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

include <structures.scad>
use <processing/preprocessing.scad>
use <processing/stage1.scad>
use <processing/stage2.scad>

/*
	This file provides the main process() function which takes the input nodes,
	links and defaults, and returns the points of the final shape. This
	function calls the processing functions in the correct order, and only
	returns the final points.

	Functions:
		function process(nodes,links,defaults)
*/

/******************************************************************************
                    P R O C E S S I N G   F U N C T I O N
******************************************************************************/

// main front-end processing function - returns the list of points
function process(nodes,links,defaults) = 
	process_stage2(
	process_stage1(
	process_preprocessing(
	data(nodes=nodes,links=links,defaults=defaults))))[dataPoints];
