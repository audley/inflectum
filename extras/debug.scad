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
	Constants:
		DEBUG_NODE_RADIUS
		DEBUG_NODE_FS
		DEBUG_NODE_ALPHA
		DEBUG_COLORS
	Modules:
		module debugNode(type,position)
*/

/******************************************************************************
                            C O N S T A N T S
******************************************************************************/

/*
	Radius of the debug nodes. Typical values include: 1, 0.5 and 0.25.
*/
DEBUG_NODE_RADIUS = 0.5;

/*
	Minimum size of the fragments used for debug nodes. Affects the number of
	faces present on the debug nodes in relation to their radius.
*/
DEBUG_NODE_FS = 0.1;

/*
	The alpha level of the debug nodes (0..1). 1.0 is opaque.
*/
DEBUG_NODE_ALPHA = 0.5;

/*
	The colors to use for particular debug nodes. The colors are stored as a
	lookup table, where the string key identifies the purpose, and the string
	value identifies the color to use (refer to the OpenSCAD manual for
	available colors). Known keys include:

		"bezier.control.p0"  -- for bezier curve control point 0
		"bezier.control.p1"  --  "    "      "      "      "   1
		"bezier.control.p2"  --  "    "      "      "      "   2
		"bezier.control.p3"  --  "    "      "      "      "   3
		"bezier.stationary"  -- for the stationary point of a bezier curve
		"bezier.focal.a"     -- for the start of a focal line (bezier)
		"bezier.focal.b"     --  "   "   end   " "   "    "      "
		"node.center"        -- for the center of a node
*/
DEBUG_COLORS = 
	[["bezier.control.p0","Red"      ],
	 ["bezier.control.p1","Orange"   ],
	 ["bezier.control.p2","Yellow"   ],
	 ["bezier.control.p3","LimeGreen"],
	 ["bezier.stationary","White"    ],
	 ["bezier.focal.a",   "Magenta"  ],
	 ["bezier.focal.b",   "DeepPink" ],
	 ["node.center",      "Blue"     ]];

/******************************************************************************
                                  M O D U L E S
******************************************************************************/

/*
	Creates a 2D debug node, for a particular purpose (given by 'type', which is
	a string from the keys specified in INFLECTUM_DEBUG_COLORS table), at a
	given position. A type must be specified so that an appropriate color can
	be picked. If the type is unknown (not in the INFLECTUM_DEBUG_COLORS table),
	a warning message of the following form will show:

		WARNING: search term not found: <key>

	where <key> is the type being looked up. This is a result of search() not
	finding the key.

	Because the preview operator (%) is used when creating the node, debug nodes
	will only be visible using "compile" and not "compile and render". To support
	preservation of manually set colors (using %), a new enough version of
	OpenSCAD should be used (ie. >= 2013.06).
*/
module debugNode(type,position)
{
	// get the node color
	NODE_COLOR  = DEBUG_COLORS[search([type],DEBUG_COLORS)[0]][1];

	// create the 2D debug node of given position and color (+alpha)
	%translate([0,0,0.1]) translate(position)
		color(NODE_COLOR,DEBUG_NODE_ALPHA)
			circle(r=DEBUG_NODE_RADIUS,$fs=DEBUG_NODE_FS);
}
