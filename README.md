Inflectum
=========

Inflectum is a library for use with OpenSCAD, which provides the ability to create 2D, smoothly-curved, filled shapes, made up of nodes and connecting links. Nodes are specified with an ID, position and radius, and links with a node ID, start angle, and end angle. Links can be specified in a clockwise order to create an outer fill shape, or anticlockwise to create a suitable shape for subtraction to create holes. Any undefined node or link properties (excluding IDs) are replaced with defaults. Nodes can also be created relative in position to another node. This, with the correct angles, can produce circle approximations.

Included along with the main library are extra modules and functions, which can be used separately from the main functionality of the library. These are “left-overs” from the development stage which are not used by the main part of the library. Such extras include functions and modules concerned with lists, cubic bezier curves, mathematics and polygons.

This library is licensed under the GNU General Public License version 3.

Requirements
------------
Inflectum requires the built-in concatenation function to work, which requires OpenSCAD 2014.0x or newer. The concat feature may need to be enabled.

Using the library
-----------------
To install the library, just copy the inflectum folder into your OpenSCAD library folder. The correct folder depends on your system – please check out http://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Libraries#Library_Locations.

To use the main module and constructor functions, include inflectum.scad into your file:

```
include <Inflectum/inflectum.scad>
```

The main module which creates the filled shape has the form:

```
module inflectumShape(nodes,links,defaults)
```

where 'nodes' is a list of nodes constructed using inflectumNode() or inflectumOuterNode(), 'links' is a list of links constructed using inflectumLink(), and 'defaults' (optional) is the default node and link specification, created using inflectumDefaults().

The node constructor functions have the form:

```
function inflectumNode(id,position,radius)
function inflectumOuterNode(id,node,angle,radius,onOutside,onInside)
```

where 'id' is a string identifier (to allow links to refer to the node), 'position' is a 2D vector to position the center of the node, 'radius' gives the radius of the node (of which the minimum is set in inflectum/config.scad), 'node' is a node constructed using inflectumNode() or inflectumOuterNode(), 'angle' gives the position relative to the provided node (anticlockwise from +x axis), and 'onOutside' and 'onInside' (specify one or neither set to true) are flags to set whether the node is placed on the inside or outside of the provided reference node. inflectumNode() allows a node to be positioned by a position vector, while inflectumOuterNode() allows a node to be positioned at a given radius and angle relative to another node.

The link constructor function has the form:

```
function inflectumLink(node,angle1,angle2)
```

where 'node' is the string identifier of the node to use, and 'angle1' and 'angle2' are the start and end angles of the link respectively. The angles are relative to the linear angle that is formed from a line connecting the sides of the current and next node in the chain, where a negative angle points inwards and a positive angle points outwards.

The defaults constructor function has the form:

```
function inflectumDefaults(node,link)
```

where 'node' is a node constructed using inflectumNode(), and 'link' is a link constructed using inflectumLink(). The node and link passed to this constructor contain property values that will replace any undefined properties (except node IDs) for the nodes and links passed as lists. If any of the default properties provided are undefined, they will be replaced with hard-coded defaults. Invalid nodes or links will be omitted.

Example
--------

```
include <Inflectum/inflectum.scad>

// configuration
SIDE_LENGTH = 60;
NODE_DIAM = 30;
CURVE_ANGLE = -45;

// create the nodes, links and defaults
NODES = [
	inflectumNode("bottom-left", [-SIDE_LENGTH/2,0]),
	inflectumNode("bottom-right",[ SIDE_LENGTH/2,0]),
	inflectumNode("top-center", [ 0,sqrt(3)/2*SIDE_LENGTH])];
LINKS = [
	inflectumLink("bottom-left"),
	inflectumLink("top-center"),
	inflectumLink("bottom-right")];
DEFAULTS = inflectumDefaults(
	inflectumNode(radius=NODE_DIAM/2),
	inflectumLink(angle1=CURVE_ANGLE,angle2=CURVE_ANGLE));

// create the shape
inflectumShape(NODES,LINKS,DEFAULTS);
```

Please check out the tests located within the inflectum library folder: inflectum/tests/inflectum_test.scad.

Tests
-----
Most of the base functions that were created to support the library have corresponding tests within the test folder (inflectum/test). Most of these produce only console output (HTML tags are used to format the text). The inflectum test file (inflectum/tests/inflectum_test.scad) contains tests for the main module, also acting as a source of examples.

Base Functions and Modules
--------------------------
Extra funcitons and modules that were created but not used by the main part of the library are included in the extras folder (inflectum/extras) – some of these also have their own tests (inflectum/extras/tests). Most of these, along with those used by the main part of the library, would probably be better suited to being shifted into a separate library.

As part of the base and extra components, there are list functions to work with nested lists (insert, replace, remove, sort, search, lookup tables (set remove) etc.) and non-nested lists (map, flatten, list-from-range, replace, insert, remove, filter, foldl, foldr, lookup tables (set, remove, map, filter) etc.). To support functions like map(), a system was devised to allow functions to be called by name, provided they are registered before use. There are limitations to this though.

Apart from lists there are also bezier functions (control-points, point, length, points, segment, stationary-point) and a module to create bezier shapes. There are also math functions (angle, norm, rotate, angle-correction, intersection, zero) and polygon functions (simplify – an animation test is available for this). In addition, there are functions (within value.scad) to filter values to be certain types (strings, booleans, number), including functions to detect and work with special values (+/-inf and nan).
