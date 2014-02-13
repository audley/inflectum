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

include <math.scad>
include <config.scad>
include <list.scad>
include <common.scad>

/*
	This file provides the functions to create cubic bezier control points from
	a path, get a point on a (cubic) bezier curve, get the approximate length of
	a (cubic) bezier curve, and create a list of (2D) points that form the
	(cubic) bezier curve.

	Internal Constants:
		BEZIER_CURVE_FACTOR
	Functions:
		function bezierControlPoints(path1)
		function bezierPoint(ctrlPoints,t)
		function bezierLen(ctrlPoints)
		function bezierPoints(ctrlPoints)
*/

/******************************************************************************
                 F U N C T I O N   R E G I S T R A T I O N
******************************************************************************/

$function5 = "_bezierPoints";
function $function5(step) = _bezierPoints(step);

/******************************************************************************
                             C O N S T A N T S
******************************************************************************/
/*
   Factor used in determining the distance of the control points from the
   endpoint nodes, for a cubic bezier curve. The control-endpoint node distance
   is calculated by multiplying the distance between the endpoints by this
   factor. This factor specifically allows for a close approximation of a
   uniform circle - that is, the curve will approximately lie on an arc of a
   circle.

   For example (on one side), if the angles are pointing in at 45
   degrees, the curve created will fit approximately around a circle of the
   correct radius (given by z/sqrt(2), where z is the distance between curve
   end-points).
*/
BEZIER_CURVE_FACTOR = ((4/3)*(1-1/sqrt(2)));

/******************************************************************************
            C O N T R O L   P O I N T   F U N C T I O N S
******************************************************************************/

/*
	Returns the coordinates of the control points necessary to produce a cubic
   bezier curve from a path. In this case, a path specifies a starting point
	and angle (starting from the x+ axis, going anticlockwise), and an ending
	point and angle - that is:

      path1 = [p1,a1,p2,a2]

   The end points (p0 and p3 from the output points) are just p1 and p2
   respectively, while the inbetween control points are determined from adding
   a distance at an angle from the end points.

	The angles are done so that the curve will go from the start point at the
	start angle, and reach the end point, continuing in the direction given by
	the end angle.
*/
function bezierControlPoints(path) = _
(
	/*
		The distance of the inbetween control points from the end points,
		calculated by multiplying the distance between the end points by a
		special curve factor.
	*/
	$d = norm(path[2]-path[0])*BEZIER_CURVE_FACTOR,

	// separate the path points and angles
	$p1 = path[0], $p2 = path[2],
	$a1 = path[1], $a2 = path[3],

	// work out the control points
	$c0 = $p1,
	$c1 = $p1+[cos($a1),sin($a1)]*$d,
	$c2 = $p2-[cos($a2),sin($a2)]*$d,
	$c3 = $p2,

	// return the four control points as a vector
	RETURN ([$c0,$c1,$c2,$c3])
);

/******************************************************************************
                        B E Z I E R   F U N C T I O N S
******************************************************************************/

/*
   Returns the position of a point on a cubic bezier curve, given 4 control
   points ([[x0,y0],[x1,y1],[x2,y2],[x3,y3]]) and a t parameter (0..1). This
   function uses the Bernstein polynomial form of the bezier curve to find the
	component positions, using matrix multiplication to obtain the two
	coordinates. In this case:

                                                +-  -+
                                                | p0 |
      P = [(1-t)^3  3t(1-t)^2   3t^2(1-t)  t^3] | p1 |
                                                | p2 |
                                                | p3 |
                                                +-  -+

   where P is the position of the curve point ([x,y]), t is a parameter
   (0 <= t <= 1), and p0, p1, p2 and p3 are 4 control points (of the form
   [x,y]), where p0 and p3 are the start and end points respectively.

   Derived from: http://www.thingiverse.com/thing:8443
*/
function bezierPoint(ctrlPoints, t) = _
(
	// to simplify the calculation
	$u = (1-t), $p = ctrlPoints,
	// calculate the point on the cubic bezier curve
	$point = [pow($u,3),3*t*$u*$u,3*t*t*$u,t*t*t]*[$p[0],$p[1],$p[2],$p[3]],

	// return the 2D point
	RETURN ($point)
);

/*
	Returns the approximate length of a bezier curve for 0 < t < 1, given the
	four control points. The approximation is calculated by finding the distance
	of a point, on the curve at a small t value, from the starting point, and
	dividing this distance by the small t value that was used for the point.
*/
function bezierLen(ctrlPoints) = _
(
	// get the point that is a small distance away from the start point
	$deltaP =  bezierPoint(ctrlPoints,CONFIG_T_DELTA),
	// the start point
	$start = ctrlPoints[0],

	/*
		Get the distance between the start point and a point with a small t
		value. This is done by finding the length of the vector given by the
		difference of the point positions.
	*/
	$dist = norm($deltaP-$start),

	/*
		Divide the distance by the difference in the t parameter value between
		these two points to get the approximate length.
	*/
	$length = $dist/CONFIG_T_DELTA,

	// return the approximate length
	RETURN ($length)
);


/******************************************************************************
                  M A I N   B E Z I E R   F U N C T I O N 
******************************************************************************/
/*
	Creates the list of 2D points that form a cubic bezier, given the curve's
	four control points. The output from this function can be concatenated with
	other points, and constructed using polygon(). The detail of the links is
	controlled by the $fs variable.
*/
function bezierPoints(ctrlPoints) = _
(
	// work out the number of steps to use
	$STEPS  = floor(bezierLen(ctrlPoints)/$fs),

	/*
		Assign a dynamic-scoped variable the control points, so that they are
		accessable by the mapped function.
	*/
	$ctrlPoints = ctrlPoints,

	// map a function over the steps, replacing the step numbers with 2D points
	$points = map("_bezierPoints",listFromRange([0:$STEPS])),

	// return the list of 2D points
	RETURN ($points)
);
// sub-function which is mapped over the step-list
function _bezierPoints(step) = bezierPoint($ctrlPoints,step/$STEPS);
