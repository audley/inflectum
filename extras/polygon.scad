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

include <math.scad>
include <config.scad>

/*
	Given four (2D) points that form a quadrilateral, this function returns
	either the:

		1.	original points to form a quadrilateral,
		2.	three points to form a triangle,
		3.	an empty list for a null shape, or
		4.	six points to make the appearance of lines crossing.

	This is done so that when the points are used with polygon(), valid shapes
	are created, and no pink faces are shown in thrown-together view. What is
	returned by this function depends on whether any of the:

		1.	points can be merged together (when they are within a small enough
			distance)
		2.	lines are approximately coincident, or
		3.	lines overlap/cross each other.

	The points should be specified in relation to the following quad diagram:

		             (side 2)
		      p2 +--------------+ p3
		         |              |
		         |              |
		(side 1) |              | (side 3)
		         |              |
		         |              |
		      p1 +--------------+ p4
		             (side 4)

	The distance at which two points are merged is given by configTolerance().
	The merging rules are as follows:

		1.	If any of the diagonally opposite points are merged, the area will be
			zero, and hence a null shape will be returned.
		2.	If for any two sides the points are merged, the area will also be
			zero, and a null shape will be returned.
		3.	If for only one side two points are merged, a triangle will be formed
			and three points will be returned.

	If after all these checks no points are merged, further checks are done
	based on the following rules:

		1.	If any two lines that are on opposite sides are coincident, the area
			will be zero, and hence a null shape will be returned.

			                                                  1 +
		2. If a point lies on the line formed by two           |
			other points, a triangle will be formed, and      4 +--+ 3
			three points will be returned. In the example       | /
			on the right, 1-4 is left out.                    2 +'
				                                               
		3. If the lines cross, two extra points are added to make the appearance
			of crossing, although not actually doing so. These points are at a
			close distance apart (given by the constant). An example of this is
			shown below:

				1 +-----+ 4         1 +------+ 6
				   \   /               \    /
				    \ /                 \  /
				     X       --->      2 )( 5       2 & 5 are close together
				    / \                 /  \        at a distance given by
				   /   \               /    \       configTolerance()
				3 +-----+ 2         3 +------+ 4
				
	If after all these checks the points are not merged and no points are added,
	the original four points are returned.		
*/
function simplifyQuad(points) = 

	// pass to a sub-function the individual points (easier to work with)
	_simplifyQuad(points[0],points[1],points[2],points[3]);

	/*
		A sub-function which passes the original points and the distances between
		them to another sub-function, which works out the merged points.
		Additionally the tolerance distance is passed for convenience (shorter
		to refer to).
	*/
	function _simplifyQuad(p1,p2,p3,p4) = 

		// pass points, distances and tolerance to another sub-function
		_simplifyQuad_check(

			// pass the original seperated points
			p1,p2,p3,p4,

			// pass the distances between the points
         norm(p1-p2),norm(p1-p3),norm(p1-p4),
         norm(p2-p3),norm(p2-p4),norm(p3-p4),

			// pass the tolerance distance
			CONFIG_TOLERANCE);
	/*
		A sub-function which determines which points are to be merged, returning
		the resulting point list. If no points are merged, they are given to
		another sub-function which will do further checks relating to crossing
		and coincident lines and points.
	*/
	function _simplifyQuad_check(p1,p2,p3,p4,p1_2,p1_3,p1_4,p2_3,p2_4,p3_4,tol)= 
		// if diagonally-opposite points are approx the same, return null shape
		((p1_3<tol) || (p2_4<tol)) ? []
		// if points on sides merge to one point for two sides, return null shape
		:((p1_2<tol && p3_4<tol) || (p2_3<tol && p1_4<tol)) ? []
		// if side 1 points are approx the same, return triangle
		:(p1_2<tol) ? [p1,p3,p4]
		// if side 2 points are approx the same, return triangle
		:(p2_3<tol) ? [p1,p3,p4]
		// if side 3 points are approx the same, return triangle
		:(p3_4<tol) ? [p1,p2,p3]
		// if side 4 points are approx the same, return triangle
		:(p1_4<tol) ? [p1,p2,p3]
		/*
			Otherwise, if no points have been merged, pass the tolerance, points
			and the p1-p4 & p1-p2 reference angles to another sub-function.
		*/
		:_simplifyQuad2(tol,p1,p2,p3,p4,angle(p4-p1),angle(p2-p1));
	/*
		A sub-function which works out the relative position of the points
		relative to the reference lines p1-p4 and p1-p2, passing these relative
		points onto another sub-function.
	*/
	function _simplifyQuad2(tol,p1,p2,p3,p4,angle14,angle12) =
		/*
			Pass the original and reference-line relative points to another sub-
			function that will calculate further things based on the relative
			points.
		*/
		_simplifyQuad2_check(
			
			// pass the tolerance and original points
			tol,p1,p2,p3,p4,

			// pass the p1-p4 relative points
			rotate(p2-p1,-angle14),
			rotate(p3-p1,-angle14),
			rotate(p4-p1,-angle14),

			// pass the p1-p2 relative points
			rotate(p2-p1,-angle12),
			rotate(p3-p1,-angle12),
			rotate(p4-p1,-angle12),

			// pass the original reference-line angles
			angle14,angle12);
	/*
		A sub-function which works out the zeros (x when y=0) of the relative
		lines potentially crossing the reference line (with the reference line
		relatively at y=0), absolute intersection points of the potentially-
		crossing lines (used to determine where to place the "close" points), and
		the angles of the potentially-crossing lines (used to work out the
		direction the "close" points move away from the meeting point).
	*/
	function _simplifyQuad2_check(tol,p1,p2,p3,p4,
		r14_p2,r14_p3,r14_p4,r12_p2,r12_p3,r12_p4,angle14,angle12) =
		/*
			Pass to another sub-function the tolerance and original and relative
			points and angles, as well as the zeros, intersection points and
			relative angles of the potentially-crossing lines. The sub-function
			will check the points and lines.
		*/
		_simplifyQuad2_check_(
	
			// pass tolerance, original/relative points and reference angles
			tol,p1,p2,p3,p4,r14_p2,r14_p3,r14_p4,
			r12_p2,r12_p3,r12_p4,angle14,angle12,
	
			// pass zeros of potentially-crossing relative lines p2-p3 and p3-4
			zero([r14_p2,r14_p3]),zero([r12_p3,r12_p4]),
	
			// pass intersection points (absolute) of potentially-crossing lines
			intersection([p1,p4],[p2,p3]),
			intersection([p1,p2],[p3,p4]),
	
			// pass the relative angles of the potentially-crossing lines
			angle(r14_p2-r14_p3),angle(r12_p4-r12_p3));
	/*
		Sub-function which will check if the points are on or coincident on any
		lines, if any lines cross, and if any lines cross to close to a point.
	*/
	function _simplifyQuad2_check_(tol,p1,p2,p3,p4,r14_p2,r14_p3,
		r14_p4,r12_p2,r12_p3,r12_p4,angle14,angle12,zero14_r23,zero12_r34,
		int14_23,int12_34,angle14_r32,angle12_r34) = 

		//////// POINTS IN A LINE ////////
		/*
			If p2 and p3, relative to p1-p4, are both too close to the ref line,
			return a null shape
		*/
		(abs(r14_p2[1])<tol && abs(r14_p3[1])<tol) ? []
		/*
			If p3 and p4, relative to p1-p2, are both too close to the ref line,
			return a null shape
		*/
		:(abs(r12_p3[1])<tol && abs(r12_p4[1])<tol) ? []
	
		//////// ONE POINT ON A LINE ////////
		/*
			If p2, relative to p1-p4, is too close to the ref line (and p3 is
			not), return a triangle formed from p2-p3-p4. (p1-p2 approximately
			coincident on p1-p4)
		*/
		:(abs(r14_p2[1])<tol) ? [p2,p3,p4]
		/*
			If p3, relative to p1-p4, is too close to the ref line (and p2 is
			not), return a triangle formed from p1-p2-p3. (p3-p4 approximately
			coincident on p1-p4)
		*/
		:(abs(r14_p2[1])<tol) ? [p1,p2,p3]
		/*
			If p3, relative to p1-p2, is too close to the ref line (and p4 is
			not), return a triangle formed from p1-p3-p4. (p3-p2 approximately
			coincident on p1-p2)
		*/
		:(abs(r14_p2[1])<tol) ? [p2,p3,p4]
		/*
			If p4, relative to p1-p2, is too close to the ref line (and p3 is
			not), return a triangle formed from p2-p3-p4. (p1-p4 approximately
			coincident on p1-p2)
		*/
		:(abs(r14_p2[1])<tol) ? [p2,p3,p4]

		//////// P2-P3 POTENTIALLY CROSSING P1-P4 ////////
		/*
			If the line p2-p3, relative to p1-p4, possibly crosses the
			reference line...
	
			This check is done by checking whether the 2-3-relative points are
			on different sides of the axis - that is, whether they have different
			signs.
		*/
		:(sign(r14_p2[1])!=sign(r14_p3[1]))
		?(
			//////// CROSSING LINES TOO CLOSE TO A POINT ////////
			/*
				If zero (y=0) of p2-p3, relative to p1-p4, is too close to p1
				([0,0] in relative coords), return a triangle formed from p1-p3-p4.
				(p1-p2 approximately coincident on p2-p3)
			*/
			(abs(zero14_r23[0])<tol) ? [p1,p3,p4]
			/*
				If zero (y=0) of p2-p3, relative to p1-p4, is too close to p4
				(relative), return a triangle formed from p1-p2-p4. (p3-p4
				approximately coincident on p2-p3)
			*/
			:(abs(zero14_r23-r14_p4[0])<tol) ? [p1,p2,p4]
	
			//////// LINE CROSSES P1-P4  ////////
			/*
				If the zero for p2-p3 (on p1-p4) remains whithin the line (p1-p4),
				and hence if p2-p3 crosses p1-p4 (not too close to p1 or p4)...
			*/
			:(zero14_r23>0 && zero14_r23<=r14_p4[0])
				/*
					Return a 6-point polygon, creating two points at the 
					ntersection point that are close together to make it look like
					the lines cross, from a distance.
				*/
				?[
					// original points p1 and p2 (p1-p2 does not cross)
					p1,p2,
					// point near crossing lines (on side of p2 and p4)
					int14_23+rotate([tol/2,0],angle14_r32/2+angle14),
					// original points p4 and p3
					p4,p3,
					// point near crossing lines (on side of p1 and p3)
					int14_23+rotate([tol/2,0],angle14_r32/2+angle14+180)
				]
			//////// NON-CROSSING LINE ////////
			/*
				Otherwise, if the zero for p2-p3 (on p1-p4) remains outside the
				line (p1-p4), and hence if p2-p3 does not cross p1-p4 ...
			*/
				// use the original points
				:[p1,p2,p3,p4]
		)
		//////// P3-P4 POTENTIALLY CROSSING P1-P2 ////////
		/*
			If the line p3-p4, relative to p1-p2, possibly crosses the reference
			line...
	
			This check is done by checking whether the points are on different
			sides of the axis - that is, whether they have different signs.
		*/
		:(sign(r12_p3[1])!=sign(r12_p4[1]))
		?(
			/*
				If zero (y=0) of p3-p4, relative to p1-p2, is too close to p1
				([0,0] in relative coords), return a triangle formed from p1-p2-p3.
				(p1-p4 approximately coincident on p3-p4)
			*/
			(abs(zero12_r34)<tol) ? [p1,p2,p3]
			/*
				If zero (y=0) of p3-p4, relative to p1-p2, is too close to p2
				(relative), return a triangle formed from p1-p2-p4. (p2-p3
				approximately coincident on p3-p4)
			*/
			:(abs(zero12_r34-r12_p2[0])<tol) ? [p1,p2,p4]

			//////// LINE CROSSES P1-P2  ////////
			/*
				If the zero for p3-p4 (on p1-p2) remains whithin the line (p1-p2),
				and hence if p3-p4 crosses p1-p2 (not too close to p1 or p2)...
			*/
			:(zero12_r34>0 && zero12_r34<=r12_p2[0])
				/*
					Return a 6-point polygon, creating two points at the
					intersection point that are close together to make it look like
					the lines cross, from a distance.
				*/
				?[
					// original point p1
					p1,
					// point near crossing lines (on side of p1 and p3)
					int12_34+rotate([tol/2,0],angle12_r34/2+angle12+180),
					// original points p3 and p2
					p3,p2,
					// point near crossing lines (on side of p4 and p2)
					int12_34+rotate([tol/2,0],angle12_r34/2+angle12),
					// original point p4
					p4
				]
			//////// NON-CROSSING LINE ////////
			/*
				Otherwise, if the zero for p3-p4 (on p1-p2) remains outside the
				line (p1-p2), and hence if p3-p4 does not cross p1-p2 ...
			*/
				// use the original points
				:[p1,p2,p3,p4]
		)
		/*
			Otherwise, if there are no crossing lines and the points are not on a
			line...
		*/
			// use the original points
			:[p1,p2,p3,p4];