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

// call2.scad - registration only
// ANY CHANGES TO THIS FILE MAY NEED TO BE REFLECTED IN call_test.scad

include <../../call.scad>

// registration
$function0 = "FUNCTION2"; function $function0(a1,a2)    = FUNCTION2(a1,a2);
$function1 = "FUNCTION3"; function $function1(a1,a2,a3) = FUNCTION3(a1,a2,a3);

// functions
function FUNCTION2(a1,a2)    = str("FUNCTION2: ",a1,",",a2);
function FUNCTION3(a1,a2,a3) = str("FUNCTION3: ",a1,",",a2,",",a3);

