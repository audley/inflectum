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
include <../keywords.scad>

/*
	Stage 1 in processing is concerned with working out the absolute angles
	of the curve starts/ends, and correcting for angle overlap, as well as
	creating the control points for the curve.

	Main Function:
		function process_stage1(data)

	Internal functions:
		function stage1_link_prep(link,index)
		function stage1_link_angles(link,index)
		function stage1_link_radii(link,index)
		function stage1_link_radius(radius,nradius,angle1,angle2,len1,len2)
		function stage1_link_final(link,index)
*/

/******************************************************************************
                  R E G I S T E R E D   F U N C T I O N S
******************************************************************************/

$function0 = "stage1_link_prep";
function $function0(link,index) = stage1_link_prep(link,index);

$function1 = "stage1_link_angles";
function $function1(link,index) = stage1_link_angles(link,index);

$function2 = "stage1_link_radii";
function $function2(link,index) = stage1_link_radii(link,index);

$function3 = "stage1_link_final";
function $function3(link,index) = stage1_link_final(link,index);

/******************************************************************************
                        S T A G E - 1   F U N C T I O N
******************************************************************************/

// main stage-1 function
function process_stage1(data) = _
(
	//////// PREP & ANGLES (1ST PASS) ////////

		// get the current link and node list
		$links = data[dataLinks], $nodes=data[dataNodes],
		// add angle, length, previous-link and next-link properties to links
		$links_prep = map("stage1_link_prep",$links),
		// work out the absolute curve-angles for each link
		$links_angles = map("stage1_link_angles",
			$links_prep,$links=$links_prep),

	//////// AUTO RADIUS ////////

		// get the defaults for the auto-radius
		$autoRadius = data[dataDefaults][defaultsAutoRadius],
		// correct any "auto" radii
		$links_radii = map("stage1_link_radii",
			$links_angles,$links=$links_angles),
		// correct the angles again
		$links_angles2 = map("stage1_link_angles",
			$links_radii,$links=$links_radii),

	//////// ANGLE OVERLAP & CONTROL POINTS ////////

		// correct angle overlap and create the control points for each link
		$links_final = map("stage1_link_final",
			$links_angles2,$links=$links_angles2),

	//////// RESULT ////////

		// return the modified links
		RETURN (data(data=data,links=$links_final))
);

/******************************************************************************
                      I N T E R N A L   F U N C T I O N S
******************************************************************************/

// add angle, length, previous-link and next-link properties to links
function stage1_link_prep(link,index) = _
(
	// previous, next and next-next links
	$prevI    = (index==0) ? (length($links)-1) : index-1,
	$nextI    = (index>=(length($links)-1)) ? 0 : index+1,
	$next2I   = ($next>=(length($links)-1)) ? 0 : $next+1,
	$nextLink = $links[$nextI],

	// current link nodes
	$node1    = $nodes[link[linkNode]],
	$node2    = $nodes[$nextLink[linkNode]],
	$node1Pos = [$node1[nodeX],$node1[nodeY]],
	$node2Pos = [$node2[nodeX],$node2[nodeY]],

	// link angle and length
	$linkAng  = angle($node2Pos-$node1Pos),
	$linkLen  = norm($node2Pos-$node1Pos),

	// add properties to link
	$data = link(link=link,
		linkAngle=$linkAng,linkLength=$linkLen,
		prevLink=$prevI,nextLink=$nextI,next2Link=$next2I),

	RETURN ($data)
);

// adds uncorrected absolute node angles to links
function stage1_link_angles(link,index) = _
(
	// next link
	$nextLink  = $links[link[linkNextLink]],

	// current link nodes
	$node1    = $nodes[link[linkNode]],
	$node2    = $nodes[$nextLink[linkNode]],
	$node1r   = $node1[nodeRadius],
	$node2r   = $node2[nodeRadius],

	// current link details (consider "auto" radii as node radii for now)
	$angle1   = link[linkAngle1],
	$angle2   = link[linkAngle2],
	$radius1_ = link[linkRadius1],
	$radius1  = (number($radius1_)==undef) ? $node1r : $radius1_,
	$radius2_ = link[linkRadius2],
	$radius2  = (number($radius2_)==undef) ? $node2r : $radius2_,
	$linkAng  = link[linkLinkAngle],
	$linkLen  = link[linkLinkLength],

	// linear angle (specified angles rel to this angle)
	$linear   = -angle([$linkLen,$radius1-$radius2]),

	// calculation of reference and absolute angles (pointing out from nodes)
	$refAng1  = $linear+$linkAng,
	$absAng1  = $angle1+$refAng1,
	$refAng2  = $linear+$linkAng-180,
	$absAng2  = -$angle2+$refAng2,

	// add reference-angles and absolute-angles to link
	$data = link(link=link,linkAngle=$linkAng,
		refAngle1=$refAng1,refAngle2=$refAng2,
		absAngle1=$absAng1,absAngle2=$absAng2),

	RETURN ($data)
);

// corrects any "auto" radii
function stage1_link_radii(link,index) = _
(
	// previous, next and next-next link
	$prevLink  = $links[link[linkPrevLink]],
	$nextLink  = $links[link[linkNextLink]],

	// current node radii
	$node1    = $nodes[link[linkNode]],
	$node2    = $nodes[$nextLink[linkNode]],
	$node1Pos = [$node1[nodeX],$node1[nodeY]],
	$node2Pos = [$node2[nodeX],$node2[nodeY]],
	$node1r   = $node1[nodeRadius],
	$node2r   = $node2[nodeRadius],

	// node angles
	$angle0 = $prevLink[linkRefAngle2],
	$angle1 = link[linkRefAngle1],
	$angle2 = link[linkRefAngle2],
	$angle3 = $nextLink[linkRefAngle1],

	// link lengths
	$linkLen0 = $prevLink[linkLinkLength],
	$linkLen1 = link[linkLinkLength],
	$linkLen2 = $nextLink[linkLinkLength],

	// correct each of the two radii
	$radius1 = stage1_link_radius(
		link[linkRadius1],$node1r,$angle0,$angle1,$linkLen0,$linkLen1),
	$radius2 = stage1_link_radius(
		link[linkRadius2],$node2r,$angle2,$angle3,$linkLen1,$linkLen2),

	// set the new radii
	$data = link(link=link,radius1=$radius1,radius2=$radius2),

	RETURN ($data)
);

// corrects a single node radius (specifically "auto" radii)
function stage1_link_radius(radius,nradius,angle1,angle2,len1,len2) = _
(
	// if the radius is a number, use it
	IF (number(radius)!=undef) ? THEN (radius)
	// if the radius is "node", use the node radius
	:ELSE_IF (radius==inflectumNode) ? THEN (nradius)
	// otherwise, if the radius is "auto", work out a suitable radius
	:ELSE
	(
		// get the minimum distance
		$d = $autoRadius[autoRadiusDistance],
		// get the angle difference
		$a=abs(angle1-angleCorrection(angle2,angle1,"<")),
		
		// if the angle difference is 180 degrees or more, just use node radius
		IF ($a>=180-CONFIG_ANGLE_TOL) ? THEN (nradius)

		// otherwise...
		:ELSE
		(
			// calculate the auto radius
			$r    = nradius,
			$x    = $r/sin($a/2),
			$r2   = $d/(2*cos($a/2)),
			$l    = $r2/sin($a/2),
			$z    = $l - $r2,
			$newR = $x + $z,

			// limit to the average length of the links
			$limitMax = (len1+len2)/2,
			// and the radius of the node
			$limitMin = nradius,

			// return limited radius
			RETURN (min($limitMax,max($limitMin,$newR)))
		)
	)
);

// corrects angle overlap adds control points to the links
function stage1_link_final(link,index) = _
(
	//////// PREVIOUS/CURRENT/NEXT LINK PROPERTIES ////////

		// previous link (index,link,link-angle)
		$prevLink = $links[link[linkPrevLink]],
		$pLinkAng = $prevLink[linkLinkAngle],

		// current link (link-angle)
		$cLinkAng = angleCorrection(	link[linkLinkAngle],
			$pLinkAng+180-CONFIG_ANGLE_TOL,"<"),

		// next link (index,link,link-angle)
		$nextLink = $links[link[linkNextLink]],
		$nLinkAng = angleCorrection(	$nextLink[linkLinkAngle],
			$cLinkAng+180-CONFIG_ANGLE_TOL,"<"),

		// absolute angles (corrected) for previous, current and next links
		$pAbsAng1 = angleCorrection(	$prevLink[linkAbsAngle2],$pLinkAng,">"),
		$cAbsAng1 = angleCorrection(	link[linkAbsAngle1],$cLinkAng-180,">"),
		$cAbsAng2 = angleCorrection(	link[linkAbsAngle2],$cLinkAng,">"),
		$nAbsAng2 = angleCorrection(	$nextLink[linkAbsAngle1],$nLinkAng-180,">"),
	
	//////// CURRENT LINK NODES ////////

		// current link nodes (nodes, positions, radii)
		$node1    = $nodes[link[linkNode]],
		$node2    = $nodes[$nextLink[linkNode]],
		$node1Pos = [$node1[nodeX],$node1[nodeY]],
		$node2Pos = [$node2[nodeX],$node2[nodeY]],

		// current link radii
		$radius1 = link[linkRadius1],
		$radius2 = link[linkRadius2],

	//////// ANGLE OVERLAP CORRECTION ////////

		// tolerance angles
		$tol1 = (CONFIG_MIN_DIST)/(2*PI*$radius1)*360,
		$tol2 = (CONFIG_MIN_DIST)/(2*PI*$radius2)*360,

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
		$x1 = $node1Pos[0]+$radius1*cos($a1+90),
		$y1 = $node1Pos[1]+$radius1*sin($a1+90),
		$x2 = $node2Pos[0]+$radius2*cos($a2+90),
		$y2 = $node2Pos[1]+$radius2*sin($a2+90),
	
		// work out path and corresponding control points
		$curvePath  = [[$x1,$y1],$a1,[$x2,$y2],$a2],
		$ctrlPoints = bezierControlPoints($curvePath),

	//////// RESULT ////////

		// add curve path and control points to existing link
		RETURN (link(link=link,curvePath=$curvePath,controlPoints=$ctrlPoints))
);
