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

include <value.scad>
include <common.scad>

/*
	Functions:
		function angle(v)
		function norm(v)
		function rotate(p,angle,origin=[0,0])
		function angleCorrection(angle,refAngle,dir)
*/

/******************************************************************************
                          V E C T O R   F U N C T I O N S
******************************************************************************/

/*
   Returns the angle of a 2D vector.
*/
function angle(v) = number(atan2(v[1],v[0]));

/*
   Returns the Euclidean norm / length of a 2D vector.
*/
function norm(v) = number(sqrt(v[0]*v[0]+v[1]*v[1]));

/*
	Rotates a 2D point around the origin or a specified point.
*/
function rotate(p,angle,origin=[0,0]) = _
(
	// get the components of the point relative to the origin
	$relPointX = p[0]-origin[0],
	$relPointY = p[1]-origin[1],

	/*
		Find the rotated points. The formulae are as follows:

			x' = x cos f - y sin f
			y' = y cos f + x sin f

		where x' and y' are the new rotated point coordinates, x and y are the
		original point coordinates, and f is the angle of rotation (around the
		origin).
	*/
	$rotPointX = number($relPointX*cos(angle) - $relPointY*sin(angle)),
	$rotPointY = number($relPointY*cos(angle) + $relPointX*sin(angle)),

	// obtain the new point be adding the origin to the rotated point
	$newPoint = [$rotPointX,$rotPointY]+origin,

	// return the rotated point
	RETURN ($newPoint)
);

/******************************************************************************
                          A N G L E   F U N C T I O N S
******************************************************************************/

/*
	Corrects a given angle to be closest to a selected side of a given reference
	angle. If the direction given (dir) is "<" (smaller-than), the angle will be
	adjusted (although equivilently the same) so that it is the largest angle
	smaller than the reference angle (refAngle). On the other hand, if the
	direction is ">" (greater-than), the angle returned will be the smallest
	angle greater than the reference angle.
*/
function angleCorrection(angle,refAngle,dir) = _
(
	// check arguments (prevents excessive recursion)
	IF (angle==undef || refAngle==undef || !(dir==">"||dir=="<")) ? THEN (undef)
	:ELSE
	(
		// to help ensure that the angle returned is correct
		$startAngle = (angle % 360) + (dir=="<" ? 360 : -360),

		// find the corrected angle (call a sub-function)
		$correctedAngle = number(_angleCorrection($startAngle,refAngle,dir)),

		// return the corrected angle
		RETURN ($correctedAngle)
	)
);
// sub-function to correct the angle
function _angleCorrection(angle,refAngle,dir) = _
(
	// if the angle is undefined, return an undefined value
	IF (angle==undef) ? THEN (undef)

	// otherwise, if the angle is defined

	// if in greater-than direction
	:ELSE_IF (dir == ">") ? THEN
	(
		// if the angle is smaller than or same as reference angle
		IF (angle <= refAngle) ?
			// add 360 degrees and recheck
			THEN (_angleCorrection(angle+360,refAngle,dir))
		// otherwise, just use angle
		:ELSE (angle)

	// otherwise, if in less-than direction
	) :ELSE (
		// if the angle is bigger than or same as reference angle
		(angle >= refAngle) ? 
			// subtract 360 degrees and recheck
			THEN (_angleCorrection(angle-360,refAngle,dir))
		// otherwise, just use angle
		:ELSE (angle)
	)
);
