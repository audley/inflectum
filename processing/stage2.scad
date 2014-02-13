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
include <../list.scad>
include <../structures.scad>
include <../bezier.scad>

/*
	Stage 2 in processing is concerned with generating the complete list of
	points that form the inflectum shape. As a result, this stage deals with
	generating lists of points for each link and partial node, and joining them
	together into one large list.

	Main Function:
		function process_stage2(data)

	Internal functions:
		function stage2_link(data)
		function stage2_closeLink(data)
*/

/******************************************************************************
                  R E G I S T E R E D   F U N C T I O N S
******************************************************************************/

$function0 = "stage2_link";
function $function0(link,index) = stage2_link(link,index);

$function1 = "stage2_nod";
function $function1(step) = stage2_nod(step);

/******************************************************************************
                        S T A G E - 2   F U N C T I O N
******************************************************************************/

// main stage-2 function
function process_stage2(data) = _
(
	// get the current link and node list
	$links = data[dataLinks], $nodes=data[dataNodes],
	// go through each link and create the curve and NOD points
	$points = flatten(map("stage2_link",$links)),
	// return the data struct with the points set
	RETURN (data(data=data,points=$points))
);

/******************************************************************************
                      I N T E R N A L   F U N C T I O N S
******************************************************************************/

/*
	Function which is mapped over the links, returning a list of points formed
	from the bezier curve and partial node (for Node On Demand). Node 2 (the
	ending node of the link) is used for the partial node.
*/
function stage2_link(link,index) = _
(
	// the next link
	$nextLinkI = (index>=(length($links)-1)) ? 0 : index+1,
	$nextLink  = $links[$nextLinkI],

	// current and next control points
	$ctrlPoints = link[linkControlPoints],
	$nextCtrlPoints = $nextLink[linkControlPoints],

	// start and end points for partial node (NOD)
	$pA = $ctrlPoints[3],
	$pB = $nextCtrlPoints[0],

	// node center for partial node (NOD)
	$node2 = $nodes[$nextLink[linkNode]],
	$pN    = [$node2[nodeX],$node2[nodeY]],
	
	// work out the start and end angles for the partial node (NOD)
	$angleA = angle($pA-$pN),
	$angleB = angleCorrection(angle($pB-$pN),$angleA,"<"),
	$angleDiff = abs($angleA-$angleB),
	
	// work out the start and end radii for the partial node (NOD)
	$radiusA = norm($pN-$pA),
	$radiusB = norm($pN-$pB),
	$maxRad  = max($radiusA,$radiusB),
	
	// determine the number of steps to use for the partial node
	$STEPS = max(0,floor(2*PI*$maxRad*($angleDiff/360)/$fs)),

	// create the points for the partial node and curve
	$nodePoints = 
		IF ($STEPS<2) ? THEN ([])
		:ELSE (map("stage2_nod",listFromRange([1:$STEPS-1]))),
	$curvePoints = bezierPoints($ctrlPoints),

	// return the points concatenated together
	RETURN (concat($curvePoints,$nodePoints))
);

/*
	Function which is mapped over the steps for partial node creation,
	replacing the step number with a 2D point, forming part of the
	partial node.
*/
function stage2_nod(step) = _
(
	// calculate the angle and radius for the current step
	$angle  = lookup(step,[[0,$angleA],[$STEPS,$angleB]]),
	$radius = lookup(step,[[0,$radiusA],[$STEPS,$radiusB]]),

	// find the current point
	$point  = $pN+$radius*[cos($angle),sin($angle)],

	// return the partial node point
	RETURN ($point)
);
