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

/*
	This file contains keys and functions to obtain and set values for a variety
	of structures used in the inflectum library.

	Useful Functions:
		function isDefined(value)
	Input Constructors:
		function node(node=undef,id,x,y,radius)
		function link(link=undef,
              node,angle1,angle2,linkAngle,absAngle1,absAngle2,
              curvePath,controlPoints,points,nodPoints)
		function defaults(defaults=undef,node,link)
	Processing Constructors:
		function data(data=undef,nodes,links,defaults)
		
*/

/******************************************************************************
                   U S E F U L   F U N C T I O N S
******************************************************************************/

// returns true if the value is not 'undef', otherwise false
function isDefined(value) = (value!=undef);

/******************************************************************************
                   I N P U T   S T R U C T U R E S
******************************************************************************/

// contructs a node, optionally with a base/derived node
function node(node=undef,id,x,y,radius) = 
	[isDefined(id)     ? id     : node[nodeID],
	 isDefined(x)      ? x      : node[nodeX],
	 isDefined(y)      ? y      : node[nodeY],
	 isDefined(radius) ? radius : node[nodeRadius]];
// index keys to access node properties
nodeID = 0; nodeX = 1; nodeY = 2; nodeRadius = 3;

// constructs a link, optionally with a base/derived link
function link(link=undef,
              node,angle1,angle2,linkAngle,absAngle1,absAngle2,
              curvePath,controlPoints) = 

	[isDefined(node)          ? node          : link[linkNode],
	 isDefined(angle1)        ? angle1        : link[linkAngle1],
	 isDefined(angle2)        ? angle2        : link[linkAngle2],
	 isDefined(linkAngle)     ? linkAngle     : link[linkLinkAngle],
	 isDefined(absAngle1)     ? absAngle1     : link[linkAbsAngle1],
	 isDefined(absAngle2)     ? absAngle2     : link[linkAbsAngle2],
	 isDefined(curvePath)     ? curvePath     : link[linkCurvePath],
	 isDefined(controlPoints) ? controlPoints : link[linkControlPoints]];

// index keys to access link properties
linkNode=0; linkAngle1=1; linkAngle2=2; linkLinkAngle=3; linkAbsAngle1=4;
linkAbsAngle2=5; linkCurvePath=6; linkControlPoints=7;

// contructs a defaults specification, optionally with a base/derived default
function defaults(defaults=undef,node,link) = 
	[isDefined(node) ? node : defaults[defaultsNode],
	 isDefined(link) ? link : defaults[defaultsLink]];
// index keys to access defaults-spec properties
defaultsNode = 0; defaultsLink = 1;

/******************************************************************************
                   P R O C E S S I N G    S T R U C T U R E S
******************************************************************************/

// constructs the data structure passed arround in the processing
function data(data=undef,nodes,links,defaults,points) = 
	[isDefined(nodes)    ? nodes    : data[dataNodes],
	 isDefined(links)    ? links    : data[dataLinks],
	 isDefined(defaults) ? defaults : data[dataDefaults],
	 isDefined(points)   ? points   : data[dataPoints]];
// index keys to access data-struct components
dataNodes = 0; dataLinks = 1; dataDefaults = 2; dataPoints = 3;
