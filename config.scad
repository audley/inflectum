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
	Config constants:
		CONFIG_T_DELTA
		CONFIG_MIN_RADIUS
		CONFIG_MIN_DIST
		CONFIG_LIST_MAX
*/

/******************************************************************************
                               C O N S T A N T S
******************************************************************************/
/*
	Small t parameter value used to help approximate the length of a bezier
	curve, which is used to work out the number of steps/divisions to use when
	creating the curves.
*/
CONFIG_T_DELTA = 0.001;

/*
	This is used to set the minimum node radius.
*/
CONFIG_MIN_RADIUS = 0.5;

/*
	This is used to help determine the closest distance that two curve
	end-points can meet at.
*/
CONFIG_MIN_DIST = 0.01;

/*
	General maximum number of supported list items for range expansions.
*/
CONFIG_LIST_MAX = 1000;
