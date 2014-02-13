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

include <../bezier.scad>
include <polygon.scad>
include <debug.scad>

/*
	Functions:
		function bezierSegment(points,t0,t1)
		function bezierStatT(points)
	Modules:
		module bezierShape(points1=false,points2=false,
		                   focalLine=false,debug=false)
*/

/******************************************************************************
                          B E Z I E R   F U N C T I O N S
******************************************************************************/

/*
   Returns the control points for a segment of a bezier curve, given 4 control
   points and the start and end parameters t0 and t1.

   Derived from:
      http://stackoverflow.com/questions/11703283/cubic-bezier-curve-segment
*/
function bezierSegment(points,t0,t1) = 

	// pass expanded arguments to sub-function to simplify calculations
	_bezierSegment(

		// pass the points seperately
		points[0], points[1], points[2], points[3],

		// pass the start (*0) and end (*1) t and u (t-1) parameters
		1-t0, t0, 1-t1, t1);

	// sub-function which works out the control points for a curve segment
	function _bezierSegment(p0,p1,p2,p3,u0,t0,u1,t1) = 
	[p0*u0*u0*u0+p1*3*t0*u0*u0+p2*3*t0*t0*u0+p3*t0*t0*t0,
	 p0*u0*u0*u1+p1*(2*t0*u0*u1+u0*u0*t1)+p2*(t0*t0*u1+2*u0*t0*t1)+p3*t0*t0*t1,
	 p0*u0*u1*u1+p1*(t0*u1*u1+2*u0*t1*u1)+p2*(2*t0*t1*u1+u0*t1*t1)+p3*t0*t1*t1,
	 p0*u1*u1*u1+p1*3*t1*u1*u1+p2*3*t1*t1*u1+p3*t1*t1*t1];

/*
	Returns the value of the t parameter, for a bezier curve of given control
   points, where the stationary point (min/max point) of the curve occurs
   (dy/dx = 0), where 0 <= t <= 1. Two values will be returned, for the two
   possible solutions. One or both of the solutions may be given as 'undef' if
   it does not exist or was out of bounds.
*/
function bezierStatT(points) =
	/*
		The results from the calculation are checked before being returned, to
		see whether the values are out of the allowable range. If this is the
		case for a solution, the undef value is used.
	*/
	_bezierCurveStatT_check(
		/*
			The calculation sub-function (_inflectumCurveStatT()) returns a
			vector containing two values, those being the two possible solutions
			of where the stationary point (dx/dy = 0) occurs.
		*/
		_bezierCurveStatT(
		
			// pass the y-components of the control points only
			points[0][1],points[1][1],points[2][1],points[3][1]));

	// sub function which checks the two solutions (in the solution vector)
	function _bezierCurveStatT_check(values) = 
		/*
			If the solution (for each t) is within the allowable range (0..1),
			return the solution, otherwise use 'undef'.
		*/
		[(values[0]>=0 && values[0]<=1 && values[0]!=undef) ? values[0]:undef,
		 (values[1]>=0 && values[1]<=1 && values[1]!=undef) ? values[1]:undef];

	/*
		Sub-function which finds the two stationary-point solutions. The solution
		is from solving a quadratic (given by dy/dx = 0).
	*/
	function _bezierCurveStatT(y0,y1,y2,y3) = 

		// if the demonimator (2a) is not zero
		((y0 - 3*y1 + 3*y2 - y3)!=0)

			// obtain the solutions from solving a quadratic
			?[
				// solution 1
				number(
				(y0-2*y1+y2+sqrt(y1*y1-y1*y2-y3*y1+y2*y2-y0*y2+y0*y3))
					/(y0 - 3*y1 + 3*y2 - y3)),
		
				// solution 2
				number(
				(y0-2*y1+y2-sqrt(y1*y1-y1*y2-y3*y1+y2*y2-y0*y2+y0*y3))
					/(y0 - 3*y1 + 3*y2 - y3))
			]
		// otherwise, if the denominator is zero
			// just use t = 0.5
			: [0.5,undef];

/******************************************************************************
                          B E Z I E R   M O D U L E S
******************************************************************************/

/*
	Creates a 2D shape formed from two sets of four bezier curve control points
   for its two sides, or from one set of control points and a focal line. The
	points are of the form [p0,p1,p2,a3] where p*=[x*,y*], while the focal
   line is of the form [[x1,y1],[x2,y2]].

	Optionally, the debug mode can be set, which creates coloured nodes which
	point out the control points and extrema - these nodes are only viewable in
	"compile" and not "compile and render". Curve/bezier resolution is also
	controlled by the special variable $fs.

   Derived from: http://www.thingiverse.com/thing:8443
*/
module bezierShape(points1=false,points2=false,focalLine=false,debug=false)
{
	/*
	   Gets the corresponding point on the focal line given a t parameter.
	*/
	function focal_point(line,t) = (line[1]-line[0])*t+line[0];

	/*
		Sub-module to create debug points for a bezier curve, given the four
		control points.
	*/
	module debug_points(points,steps)
	{
		/*
			Find the values of the t parameter at which a stationary point
			(dy/dx=0) occurs - may be two, one or no solutions.
		*/
		STAT_POINTS_T = bezierStatT(points);

		// (for each of the debug points)
		for (p = [

			// four control points (end nodes & curve control points)
			[points[0],"bezier.control.p0"],
			[points[1],"bezier.control.p1"],         
			[points[2],"bezier.control.p2"],
			[points[3],"bezier.control.p3"],

			// stationary debug points
			[bezierPoint(points,STAT_POINTS_T[0]),"bezier.stationary"], 
			[bezierPoint(points,STAT_POINTS_T[1]),"bezier.stationary"]])

			/*
				Only add the debug point if its position is defined. Helps
				ensure that the stationary points which are undefined aren't
				shown, as they would be placed at [0,0].
			*/
			if (p[0]!=undef)

				// add the debug node
				debugNode(type=p[1],position=p[0]);
	}

	/*
		Small sub-function used in working out the correct number of steps, given
		the number of steps for the two curved sides, and the number of steps for
		the focal line. This function finds the maximum of these, taking into
		account that one of them will be undefined.
	*/
	function find_steps(steps1,steps2,stepsF) =
		// if all steps are undef, return undef
		(steps1==undef&&steps2==undef&&stepsF==undef) ? undef
		// if steps1 is defined, get max starting with steps1
		:(steps1!=undef) ? max(max(steps1,steps2),stepsF)
		// if steps2 is defined and steps1 is not, get max starting with steps2
		:(steps2!=undef) ? max(steps2,stepsF)
		// otherwise, if only stepsF is defined, use stepsF
		:stepsF;
		

	/*
		Work out the number of steps/divisions to use, affecting the resolution
		of the curves produced. This is worked out by finding the number of steps
		required for each side and using the minimum. The steps per side is
		worked out by dividing the approximate curve length by the special
		variable $fs, which is the minimum size of a fragment (of an arc).
	*/
	STEPS = find_steps(

		// steps for side 1
		floor(bezierLen(points1)/$fs),

		// steps for side 2
		floor(bezierLen(points2)/$fs),

		// steps for focal line
		floor(norm(focalLine[1]-focalLine[0])/$fs));

	/*
		Place down curve debug nodes. Because the preview operator (%) is used
		by inflectumDebugNode2(), these will only be visible using "compile"
		and not "compile and render". To support preservation of manually set
		colors (using %), a new enough version of OpenSCAD should be used
		(ie. >= 2013.06).
	*/
	if (debug)
	{
		// if side 1 points are specified, place down side 1 debug nodes
		if (points1 != false) debug_points(points1,STEPS);
			
		// if side 2 points are specified, place down side 2 debug nodes
		if (points2 != false) debug_points(points2,STEPS);

		// if the focal line is present, put down nodes at each end-point
		if (focalLine != false)

			// go through both end points
			for (p = [

				// start (A) and end (B) points
				[focalLine[0],"bezier.focal.a"],[focalLine[1],"bezier.focal.b"]])

				// create the debug node
				debugNode(type=p[1],position=p[0]);
	}

	/*
		Fill between both sides. This part of the module creates the main 2D
		shape, using either a line or bezier curve for each of the two sides.
		The geometry is constructed by creating many quadrilaterals, using the
		points for the previous and current t parameter.
	*/
	for(step = [1:STEPS])

		// work out all bezier/focal-line points
		assign(FPOINT_1 = focal_point(focalLine,(step-1)/STEPS),
		       POINT1_1 = bezierPoint(points1,(step-1)/STEPS),
		       POINT2_1 = bezierPoint(points2,(step-1)/STEPS),
		       FPOINT_2 = focal_point(focalLine,step/STEPS),
		       POINT2_2 = bezierPoint(points2,step/STEPS),
		       POINT1_2 = bezierPoint(points1,step/STEPS))

		// work out which points will be used
		assign(P1 = points1==false ? FPOINT_1 : POINT1_1,
		       P2 = points2==false ? FPOINT_1 : POINT2_1,
		       P3 = points2==false ? FPOINT_2 : POINT2_2,
		       P4 = points1==false ? FPOINT_2 : POINT1_2)

		// create the quad/triangle
		polygon(simplifyQuad([P1,P2,P3,P4]));
}
