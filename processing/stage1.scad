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
include <../config.scad>
include <../math.scad>
include <../bezier.scad>

/*
	Stage 1 in processing is concerned with working out the absolute angles
	of the curve starts/ends, and correcting for angle overlap, as well as
	creating the control points for the curve.

	Main Function:
		function process_stage1(data)

	Internal functions:
		function stage1_link_angles(data)
		function stage1_link_final(data)
*/

/******************************************************************************
                  R E G I S T E R E D   F U N C T I O N S
******************************************************************************/

$function0 = "stage1_link_angles";
function $function0(link,index) = stage1_link_angles(link,index);

$function1 = "stage1_link_final";
function $function1(link,index) = stage1_link_final(link,index);

/******************************************************************************
                        S T A G E - 1   F U N C T I O N
******************************************************************************/

// main stage-1 function
function process_stage1(data) = _
(
	// get the current link and node list
	$links = data[dataLinks], $nodes=data[dataNodes],
	// work out the absolute curve-angles for each link
	$links_angles = map("stage1_link_angles",$links),
	// correct angle overlap and create the control points for each link
	$links_final = map("stage1_link_final",$links_angles,$links=$links_angles),
	// return the links with the control points added
	RETURN (data(data=data,links=$links_final))
);

/******************************************************************************
                      I N T E R N A L   F U N C T I O N S
******************************************************************************/

// adds uncorrected absolute node angles to links
function stage1_link_angles(link,index) = _
(
	// next link
	$nextI    = (index>=(length($links)-1)) ? 0 : index+1,
	$nextLink = $links[$nextI],

	// current link nodes
	$node1    = $nodes[link[linkNode]],
	$node2    = $nodes[$nextLink[linkNode]],
	$node1x   = $node1[nodeX],
	$node1y   = $node1[nodeY],
	$node1r   = $node1[nodeRadius],
	$node2x   = $node2[nodeX],
	$node2y   = $node2[nodeY],
	$node2r   = $node2[nodeRadius],

	// current link node angles, and link angle and length
	$angle1   = link[linkAngle1],
	$angle2   = link[linkAngle2],
	$linkAng  = angle([$node2x-$node1x,$node2y-$node1y]),
	$linkLen  = norm([$node2x-$node1x,$node2y-$node1y]),

	// linear angle (specified angles rel to this angle)
	$linear   = -angle([$linkLen,$node1r-$node2r]),

	// calculation of absolute angles (pointing out from nodes)
	$absAng1  = ($angle1+$linear)+$linkAng,
	$absAng2  = -($angle2-$linear)+$linkAng-180,

	// add absolute-angle properties to link
	$data = link(link=link,linkAngle=$linkAng,
		absAngle1=$absAng1,absAngle2=$absAng2),

	RETURN ($data)
);

// corrects angle overlap adds control points to the links
function stage1_link_final(link,index) = _
(
	//////// PREVIOUS/CURRENT/NEXT LINK PROPERTIES ////////

		// previous link (index,link,link-angle)
		$prevI    = (index<=0) ? length($links)-1 : index-1,
		$prevLink = $links[$prevI],
		$pLinkAng = $prevLink[linkLinkAngle],

		// current link (link-angle)
		$cLinkAng = angleCorrection(	link[linkLinkAngle],$pLinkAng+180,"<"),

		// next link (index,link,link-angle)
		$nextI    = (index>=(length($links)-1)) ? 0 : index+1,
		$nextLink = $links[$nextI],
		$nLinkAng = angleCorrection(	$nextLink[linkLinkAngle],$cLinkAng+180,"<"),

		// absolute angles (corrected) for previous, current and next links
		$pAbsAng1 = angleCorrection(	$prevLink[linkAbsAngle2],$pLinkAng,">"),
		$cAbsAng1 = angleCorrection(	link[linkAbsAngle1],$cLinkAng-180,">"),
		$cAbsAng2 = angleCorrection(	link[linkAbsAngle2],$cLinkAng,">"),
		$nAbsAng2 = angleCorrection(	$nextLink[linkAbsAngle1],$nLinkAng-180,">"),
	
	//////// CURRENT LINK NODES ////////

		// current link nodes (nodes, positions, radii)
		$node1  = $nodes[link[linkNode]], $node2  = $nodes[$nextLink[linkNode]],
		$node1x = $node1[nodeX],          $node1y = $node1[nodeY],
		$node2x = $node2[nodeX],          $node2y = $node2[nodeY],
		$node1r = $node1[nodeRadius],     $node2r = $node2[nodeRadius],

	//////// ANGLE OVERLAP CORRECTION ////////

		// tolerance angles
		$tol1 = (CONFIG_MIN_DIST)/(2*PI*$node1r)*360,
		$tol2 = (CONFIG_MIN_DIST)/(2*PI*$node2r)*360,

		// angle diff, overlap status
		$angDiff1 = abs($pAbsAng1-$cAbsAng1),
		$angDiff2 = abs($nAbsAng2-$cAbsAng2),
		$over1    = $angDiff1<=(180+$tol1),
		$over2    = $angDiff2<=(180+$tol2),

		// angle correction
		$newAng1 = IF ($over1==false) ?
			THEN  ($cAbsAng1)
			:ELSE (($pAbsAng1+$cAbsAng1)/2-90-$tol1/2),
		$newAng2 = IF ($over2==false) ?
			THEN  ($cAbsAng2)
			:ELSE 	(($cAbsAng2+$nAbsAng2)/2+90+$tol2/2),

	//////// CONTROL POINT CREATION ////////

		// curve start/end points/angles
		$a1 = $newAng1,
		$a2 = $newAng2-180,
		$x1 = $node1x+$node1r*cos($a1+90),
		$y1 = $node1y+$node1r*sin($a1+90),
		$x2 = $node2x+$node2r*cos($a2+90),
		$y2 = $node2y+$node2r*sin($a2+90),
	
		// work out path and corresponding control points
		$curvePath  = [[$x1,$y1],$a1,[$x2,$y2],$a2],
		$ctrlPoints = bezierControlPoints($curvePath),

	//////// RESULT ////////

		// add curve path and control points to existing link
		RETURN (link(link=link,curvePath=$curvePath,controlPoints=$ctrlPoints))
);
