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

include <../math.scad>
include <../value.scad>

/*
	Functions:
		function intersection(line1,line2)
		function zero(line)
*/

/******************************************************************************
                          M A T H   F U N C T I O N S
******************************************************************************/

/*
	Finds the point where two lines (of the form [[x1,y1],[x2,y2]]) intersect.
	The returned point may not neccessarily be between the points specified.
*/
function intersection(line1,line2) = 
	/*
		Pass to a sub-function the t value of line 1 (as a ray) at which the
		lines (used as rays) intersect, and the points for line 1 so that the
		intersection point can be worked out. This sub-function will return
		a point of the form [x,y].
	*/
	_intersection(
		/*
			Gets the t parameter value for line 1 (as a ray) at which the lines
			intersect.
		*/
		_intersection_t1(
			line1[0]-line2[0],line1[1]-line1[0],line2[1]-line2[0]),
		/*
			Pass line 1's points so that an intersection point can be worked out
			using the t parameter
		*/
		line1);
	/*
		Finds the value for ray 1's t parameter at which the two rays intersect.
		In order for this to work, the lines are considered as rays which start
		at a point (P) and go in a given direction (D):

			r(t) = P + t*D

		where t is a scalar parameter, P is the start position vector (given by
		line.A),	and D is the direction vector (given by line.B-line.A).
	*/
	function _intersection_t1(c,d1,d2) = 
		number((c[0]*d2[1]-c[1]*d2[0])/(d1[1]*d2[0]-d1[0]*d2[1]));
	/*
		Sub-function which finds the intersection point, given the t parameter's
		value at which the intersection occurs, and the points of the line which
		can be used to derive a ray equation.
	*/
	function _intersection(t1,line1) = line1[0] + t1*(line1[1]-line1[0]);

/*
	Finds the x-axis intersection point for a given line (of the form
	[[x1,y1],[x2,y2]]). Returns the value of x when y=0 on the line. This
	is given by the formula:

		x = p1.x - p1.y/slope(p2-p1)
	
	where x is the x-intercept value, p1 is the first point specified in
	the line (with *.x and *.y giving the seperate components), slope() is
	a function returning the gradient of a 2D vector, and p2 is the second
	point specified in the line.
*/
function zero(line) = number(
	line[0][0]-line[0][1]/((line[1][1]-line[0][1])/(line[1][0]-line[0][0])));
