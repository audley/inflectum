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

include <../list.scad>
include <../common.scad>
include <../config.scad>
include <../structures.scad>
include <../input.scad>
include <../keywords.scad>
use <input.scad>

/*
	The preprocessing stage in processing is concerned with cleaning up the
	inputs. This includes correcting the defaults, nodes and links with
	defaults, removing bad nodes and links, and converting ids to indexes.

	Main Function:
		function process_preprocessing(data)
	Internal Functions:
		function preprocessing_node(node)
		function preprocessing_link(link)
*/

/******************************************************************************
                  R E G I S T E R E D   F U N C T I O N S
******************************************************************************/

$function0 = "preprocessing_node";
function $function0(node) = preprocessing_node(node);

$function1 = "preprocessing_link";
function $function1(link) = preprocessing_link(link);

/******************************************************************************
                 P R E P R O C E S S I N G   F U N C T I O N
******************************************************************************/

// main preprocess function
function process_preprocessing(data) = _
(
	// node, link and auto-radius defaults correction
	$defaults_node = nodeCorrection(
		data[dataDefaults][defaultsNode],
		inflectumNode(undef,undef,CONFIG_MIN_RADIUS)),
	$defaults_link = linkCorrection(
		data[dataDefaults][defaultsLink],
			inflectumLink(undef,0,0,inflectumNode,inflectumNode)),
	$defaults_autoRadius = autoRadiusCorrection(
		data[dataDefaults][defaultsAutoRadius],
			inflectumAutoRadius(CONFIG_MIN_RADIUS)),

	// node correction (defaults) and filtering
	$nodes = data[dataNodes],
	$processed_nodes = flatten(map("preprocessing_node",$nodes)),

	// link correction (defaults), id-->index conversion and filtering
	$links = data[dataLinks],
	$processed_links = flatten(map("preprocessing_link",$links,
		$nodes=$processed_nodes)),

	// get the new data struct with the new defaults and node/link lists
	$data = data(data=data,
		nodes=$processed_nodes,
		links=$processed_links,
		defaults=defaults(defaults=data[dataDefaults],
			node=$defaults_node,link=$defaults_link,
			autoRadius=$defaults_autoRadius)),

	// return the new data
	RETURN ($data)
);

/******************************************************************************
                      I N T E R N A L   F U N C T I O N S
******************************************************************************/

// processes a single node (applied using map())
function preprocessing_node(node) = _
(
	// correct the node (defaults)
	$corrected = nodeCorrection(node,$defaults_node),
	// get whether the node is valid
	$isValid   = nodeIsValid($corrected),
	// return value enclosed in list if valid (will be flattened)
	RETURN (($isValid) ? [$corrected] : [])
);

// processes a single link (applied using map())
function preprocessing_link(link) = _
(
	// correct the link (defaults)
	$corrected = linkCorrection(link,$defaults_link),
	// get the specified node id
	$node      = link[linkNode],
	// find the node index corresponding to the node id
	$nodeIndex = search([$node],$nodes,1,nodeID)[0],
	// get whether the link is valid
	$isValid   = linkIsValid($corrected) && $nodeIndex!=[],
	// the new link will have the node id replaced with an index
	$newLink   = link(link=$corrected,node=$nodeIndex),
	// return value enclosed in list if valid (will be flattened)
	RETURN (IF ($isValid) ? THEN ([$newLink]) :ELSE ([]))
);

