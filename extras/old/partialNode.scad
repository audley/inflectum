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

include <../math.scad>
include <../bezier.scad>

/*
	Below are some experiments concerned with creating parts of nodes, using bezier
	curves and cosine interpolation. In particular, these experiments focused on
	creating nodes with different start and end radii.

	BEST RESULT: method 4
*/

$fs = 0.5;

// method 1
union()
{
	translate([0,0])
		node_part([10,10],[10,-10],[0,0]);
	translate([20,0])
		node_part([5,10],[15,-10],[0,0]);
	translate([40,0])
		node_part([20,10],[2.5,-10],[0,0]);
	translate([65,0])
		node_part([0,10],[0,-20],[0,0]);
	translate([100,0])
		node_part([-5,10],[-15,-10],[0,0]);
	translate([120,0])
		node_part([5,5],[10,5],[0,0]);
	translate([140,0])
		node_part([5,10],[25,-10],[0,0]);
	translate([180,0])
		node_part([20,0],[-10,-10],[0,0]);
}

// method 2
union()
{
	translate([0,-35])
		node_part2([10,10],[10,-10],[0,0]);
	translate([20,-35])
		node_part2([5,10],[15,-10],[0,0]);
	translate([40,-35])
		node_part2([20,10],[2.5,-10],[0,0]);
	translate([65,-35])
		node_part2([0,10],[0,-20],[0,0]);
	translate([100,-35])
		node_part2([-5,10],[-15,-10],[0,0]);
	translate([120,-35])
		node_part2([5,5],[10,5],[0,0]);
	translate([140,-35])
		node_part2([5,10],[25,-10],[0,0]);
	translate([180,-35])
		node_part2([20,0],[-10,-10],[0,0]);
}

// method 3
union()
{
	translate([0,-70])
		node_part3([10,10],[10,-10],[0,0]);
	translate([20,-70])
		node_part3([5,10],[15,-10],[0,0]);
	translate([40,-70])
		node_part3([20,10],[2.5,-10],[0,0]);
	translate([65,-70])
		node_part3([0,10],[0,-20],[0,0]);
	translate([100,-70])
		node_part3([-5,10],[-15,-10],[0,0]);
	translate([120,-70])
		node_part3([5,5],[10,5],[0,0]);
	translate([140,-70])
		node_part3([5,10],[25,-10],[0,0]);
	translate([180,-70])
		node_part3([20,0],[-10,-10],[0,0]);
}

// method 4
union()
{
	translate([0,-105])
		node_part4([10,10],[10,-10],[0,0]);
	translate([20,-105])
		node_part4([5,10],[15,-10],[0,0]);
	translate([40,-105])
		node_part4([20,10],[2.5,-10],[0,0]);
	translate([65,-105])
		node_part4([0,10],[0,-20],[0,0]);
	translate([100,-105])
		node_part4([-5,10],[-15,-10],[0,0]);
	translate([120,-105])
		node_part4([5,5],[10,5],[0,0]);
	translate([140,-105])
		node_part4([5,10],[25,-10],[0,0]);
	translate([180,-105])
		node_part4([20,0],[-10,-10],[0,0]);
}

// method 5
union()
{
	translate([0,-140])
		node_part5([10,10],[10,-10],[0,0]);
	translate([20,-140])
		node_part5([5,10],[15,-10],[0,0]);
	translate([40,-140])
		node_part5([20,10],[2.5,-10],[0,0]);
	translate([65,-140])
		node_part5([0,10],[0,-20],[0,0]);
	translate([100,-140])
		node_part5([-5,10],[-15,-10],[0,0]);
	translate([120,-140])
		node_part5([5,5],[10,5],[0,0]);
	translate([140,-140])
		node_part5([5,10],[25,-10],[0,0]);
	translate([180,-140])
		node_part5([20,0],[-10,-10],[0,0]);
}

module node_part5(pA,pB,pN)
{
	function circle_point(pN,angle,radius)
		= pN+radius*[cos(angle),sin(angle)];

	ANGLE_A = angleCorrection(angle(pA-pN),0,"<");
	ANGLE_B = angleCorrection(angle(pB-pN),ANGLE_A,"<");
	ANGLE_DIFF = abs(ANGLE_A-ANGLE_B);
	
	RADIUS_A = norm(pN-pA);
	RADIUS_B = norm(pN-pB);
	
	RADIUS_MID  = (RADIUS_A+RADIUS_B)/2;
	RADIUS_DIFF = RADIUS_B-RADIUS_A;
	
	STEPS = 2*PI*(RADIUS_MID)*(ANGLE_DIFF/360)/$fs;
	
	BEZIER_POINT_A = circle_point(pN,ANGLE_A,RADIUS_A);
	BEZIER_POINT_B = circle_point(pN,ANGLE_B,RADIUS_B);

	BEZIER_POINTS = bezierControlPoints([BEZIER_POINT_A,ANGLE_A-90,BEZIER_POINT_B,ANGLE_B-90]);

	if (ANGLE_DIFF <= 90)

		bezierShape(points1=BEZIER_POINTS,focalLine=[pN,pN]);

	else for (step = [1:STEPS])
		assign(

		bpoint1 = bezierPoint(BEZIER_POINTS,(step-1)/STEPS),
		bpoint2 = bezierPoint(BEZIER_POINTS,step/STEPS))

		assign(

		bradius1 = norm(bpoint1-pN),
		bradius2 = norm(bpoint2-pN))

		assign(
		
		angleA = lookup(step-1,[[0,ANGLE_A],[STEPS,ANGLE_B]]),
		angleB = lookup(  step,[[0,ANGLE_A],[STEPS,ANGLE_B]]),
		
		cradiusA = RADIUS_MID-cos(180*(pow((step-1)/STEPS,1)))*RADIUS_DIFF/2,
		cradiusB = RADIUS_MID-cos(180    *(pow(step/STEPS,1)))*RADIUS_DIFF/2)

		assign(

		radiusA = ANGLE_DIFF>=180 ? cradiusA : bradius1+(cradiusA-bradius1)*pow(ANGLE_DIFF/90-1,1),
		radiusB = ANGLE_DIFF>=180 ? cradiusB : bradius2+(cradiusB-bradius2)*pow(ANGLE_DIFF/90-1,1))

		assign(

		point1 = circle_point(pN,angleA,radiusA),
		point2 = circle_point(pN,angleB,radiusB))

		polygon(
			[pN,point1,point2]);
}

module node_part4(pA,pB,pN)
{
	function circle_point(pN,angle,radius)
		= pN+radius*[cos(angle),sin(angle)];

	ANGLE_A = angleCorrection(angle(pA-pN),0,"<");
	ANGLE_B = angleCorrection(angle(pB-pN),ANGLE_A,"<");
	ANGLE_DIFF = abs(ANGLE_A-ANGLE_B);
	
	RADIUS_A = norm(pN-pA);
	RADIUS_B = norm(pN-pB);
	
	RADIUS_MID  = (RADIUS_A+RADIUS_B)/2;
	RADIUS_DIFF = RADIUS_B-RADIUS_A;
	
	STEPS = 2*PI*(RADIUS_MID)*(ANGLE_DIFF/360)/$fs;
	
	BEZIER_POINT_A = circle_point(pN,ANGLE_A,RADIUS_A);
	BEZIER_POINT_B = circle_point(pN,ANGLE_B,RADIUS_B);

	BEZIER_POINTS = bezierControlPoints([BEZIER_POINT_A,ANGLE_A-90,BEZIER_POINT_B,ANGLE_B-90]);

	if (ANGLE_DIFF <= 90)

		bezierShape(points1=BEZIER_POINTS,focalLine=[pN,pN]);

	else for (step = [1:STEPS])
		assign(
		
		angleA = lookup(step-1,[[0,ANGLE_A],[STEPS,ANGLE_B]]),
		angleB = lookup(  step,[[0,ANGLE_A],[STEPS,ANGLE_B]]),
		
		radiusA = RADIUS_MID-cos(180*(pow((step-1)/STEPS,1)))*RADIUS_DIFF/2,
		radiusB = RADIUS_MID-cos(180    *(pow(step/STEPS,1)))*RADIUS_DIFF/2)

		assign(

		bpoint1 = bezierPoint(BEZIER_POINTS,(step-1)/STEPS),
		bpoint2 = bezierPoint(BEZIER_POINTS,step/STEPS),

		cpoint1 = circle_point(pN,angleA,radiusA),
		cpoint2 = circle_point(pN,angleB,radiusB))

		assign(

		point1_diff = cpoint1-bpoint1,
		point2_diff = cpoint2-bpoint2)

		assign(

		point1 = ANGLE_DIFF>=180 ? cpoint1 : bpoint1+point1_diff*(ANGLE_DIFF/90-1),
		point2 = ANGLE_DIFF>=180 ? cpoint2 : bpoint2+point2_diff*(ANGLE_DIFF/90-1))

		polygon(
			[pN,point1,point2]);

}

module node_part3(pA,pB,pN)
{
	ANGLE_A = angle(pA-pN);
	ANGLE_B = angle(pB-pN);
	ANGLE_DIFF = ANGLE_B-ANGLE_A;

	RADIUS_A = norm(pN-pA);
	RADIUS_B = norm(pN-pB);
	RADIUS_MID = (RADIUS_A+RADIUS_B)/2;

	LEN = 2*PI*RADIUS_MID*(abs(ANGLE_DIFF)/360);
	POINTS = bezierControlPoints([[0,RADIUS_A],0,[LEN,RADIUS_B],0]);
	STEPS = floor(bezierLen(POINTS)/$fs);

	for(step = [1:STEPS])

		assign(POINT1 = bezierPoint(POINTS,(step-1)/STEPS),
		       POINT2 = bezierPoint(POINTS,step/STEPS))
		assign(RPOINT1 = rotate([POINT1[1],0],ANGLE_A+ANGLE_DIFF*POINT1[0]/LEN),
		       RPOINT2 = rotate([POINT2[1],0],ANGLE_A+ANGLE_DIFF*POINT2[0]/LEN))

		polygon([RPOINT1,RPOINT2,pN]);
}

module node_part2(pA,pB,pN)
{
	function circle_point(pN,angle,radius)
		= pN+radius*[cos(angle),sin(angle)];

	ANGLE_A = angleCorrection(angle(pA-pN),0,"<");
	ANGLE_B = angleCorrection(angle(pB-pN),ANGLE_A,"<");

	RADIUS_A = norm(pN-pA);
	RADIUS_B = norm(pN-pB);
	RADIUS_MID = (RADIUS_A+RADIUS_B)/2;

	STEPS = 2*PI*(RADIUS_MID)*(abs(ANGLE_A-ANGLE_B)/360)/$fs;

	POINT_A = circle_point(pN,ANGLE_A,RADIUS_A);
	POINT_B = circle_point(pN,ANGLE_B,RADIUS_B);

	POINTS = bezierControlPoints([POINT_A,ANGLE_A-90,POINT_B,ANGLE_B-90]);

	bezierShape(points1=POINTS,focalLine=[pN,pN],debug=true);

}

module node_part(pA,pB,pN)
{
	function circle_point(pN,angle,radius)
		= pN+radius*[cos(angle),sin(angle)];

	ANGLE_A = angleCorrection(angle(pA-pN),0,"<");
	ANGLE_B = angleCorrection(angle(pB-pN),ANGLE_A,"<");
	RADIUS_A = norm(pN-pA);
	RADIUS_B = norm(pN-pB);
	RADIUS_MID  = (RADIUS_A+RADIUS_B)/2;
	RADIUS_DIFF = RADIUS_B-RADIUS_A;

	STEPS = 2*PI*(RADIUS_MID)*(abs(ANGLE_A-ANGLE_B)/360)/$fs;

	if (abs(ANGLE_A-ANGLE_B)<360)
	
	for (step = [1:STEPS])
		assign(
		angleA = lookup(step-1,[[0,ANGLE_A],[STEPS,ANGLE_B]]),
		angleB = lookup(  step,[[0,ANGLE_A],[STEPS,ANGLE_B]]),
		radiusA = RADIUS_MID-cos(180*(pow((step-1)/STEPS,1)))*RADIUS_DIFF/2,
		radiusB = RADIUS_MID-cos(180    *(pow(step/STEPS,1)))*RADIUS_DIFF/2)
		
		polygon(
			[pN,
			 circle_point(pN,angleA,radiusA),
			 circle_point(pN,angleB,radiusB)]);
}
