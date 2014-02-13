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

include <../../test.scad>
include <../nestedList.scad>

/*
	Test Group: List Functions
		function nestedPrepend(value,list)
		function nestedAppend(list,value)
		function nestedHead(list)
		function nestedTail(list)
		function nestedFromVec(vector)
		function nestedIsEnd(list)
		function nestedIsPastEnd(list)
		function nestedIsEmpty(list)
		function nestedMid(list,start=0,end=-1)
		function nestedInsert(list,value,index)
		function nestedLen(list)
		function nestedGet(list,index)
		function nestedSearch(list,value,matchCount=0,checkIndex=undef)
		function nestedRemove(list,index)
		function nestedFindMin(list,checkIndex=undef)
		function nestedFindMax(list,checkIndex=undef)
		function nestedSort(list,descending=false,checkIndex=undef)
	Test Group: List Modules
		module nestedForEach(list)
	Test Group: Lookup Functions and List Search Functions Using Keys
		function nestedLookup(table,key)
		function nestedLookupCreate(vector)
		function nestedLookupAdd(table,keyValueVector,keepOld=false)
		function nestedLookupRemove(table,keyVector)
		function nestedSearch(list,value,matchCount=0,checkKey=undef)
		function nestedFindMin(list,checkKey=undef)
		function nestedFindMax(list,checkKey=undef)
		function nestedSort(list,descending=false,checkKey=undef)
*/

/******************************************************************************
                   L I S T   F U N C T I O N   T E S T S
******************************************************************************/

/*
	Key tests: Undefined items/elements in the lists/vectors,
	           undefinded lists/vectors, scalar-passed lists/vectors,
	           undefined value/index args, empty lists, bad lists (bad format),
	           bad key, single/multi add/remove, new/old keys, keepOld.
*/

/*
	Some of the lists/vectors to test the functions/modules with. These
	shouldn't be changed, unless changes are also made to the expected results
	in the tests.
*/
LIST1  = [3,[4,[5,[6,[7,[]]]]]];   // normal list
LIST2  = [3,[4,[5,6,[7,[8,[]]]]]]; // bad list
LIST3  = [[4,9],[[3,8],[[5,0],[[7,1],[[8,4],[]]]]]];
LIST4  = [3,[4,[3,[6,[7,[3,[9,[]]]]]]]];
VEC1   = [0,1,2,3,4,5,6,7];
VEC_A  = [0,[1,2],[3,4,5]];
LIST_A = [0,[[1,2],[[3,4,5],[]]]];

testGroup("List Functions")
{
	// LIST1  = [3,[4,[5,[6,[7,[]]]]]];
	// LIST2  = [3,[4,[5,6,[7,[8,[]]]]]];
	testSet("nestedPrepend","direct test",[
		testCase("normal",[1,LIST1],[1,LIST1]),
		testCase("undef value",[undef,LIST1],[undef,LIST1]),
		testCase("undef list",[1,undef],[1,[]]),
		testCase("scalar as list",[1,5],[1,[]]),
		testCase("all undef",[undef,undef],[undef,[]]),
		testCase("empty list",[1,[]],[1,[]]),
		testCase("bad list",[1,LIST2],[1,LIST2])])
	testFunction(nestedPrepend($value[0],$value[1]));
	
	// LIST1  = [3,[4,[5,[6,[7,[]]]]]];
	// LIST2  = [3,[4,[5,6,[7,[8,[]]]]]];
	testSet("nestedAppend","direct test",[
		testCase("normal",[LIST1,1],[3,[4,[5,[6,[7,[1,[]]]]]]]),
		testCase("undef value",[LIST1,undef],
			[3,[4,[5,[6,[7,[undef,[]]]]]]]),
		testCase("undef list",[undef,1],[1,[]]),
		testCase("scalar as list",[5,1],[1,[]]),
		testCase("all undef",[undef,undef],[undef,[]]),
		testCase("empty list",[[],1],[1,[]]),
		testCase("bad list",[LIST2,1],[3,[4,[5,[1,[]]]]])])
	testFunction(nestedAppend($value[0],$value[1]));
	
	// LIST1  = [3,[4,[5,[6,[7,[]]]]]];
	testSet("nestedHead","direct test",[
		testCase("normal",[LIST1],3),
		testCase("undef list",[undef],undef),
		testCase("scalar as list",[5],undef),
		testCase("undef first item",[[undef,[2,[3,[]]]]],undef),
		testCase("empty list",[[]],undef)])
	testFunction(nestedHead($value[0]));
	
	// LIST1  = [3,[4,[5,[6,[7,[]]]]]];
	testSet("nestedTail","direct test",[
		testCase("normal",[LIST1],[4,[5,[6,[7,[]]]]]),
		testCase("undef list",[undef],[]),
		testCase("undef last item",[[1,[2,[undef,[]]]]],[2,[undef,[]]]),
		testCase("undef tail",[[1,undef]],[]),
		testCase("scalar tail",[[1,5]],[]),
		testCase("empty list",[[]],[])])
	testFunction(nestedTail($value[0]));
	
	// VEC_A  = [0,[1,2],[3,4,5]];
	// LIST_A = [0,[[1,2],[[3,4,5],[]]]];
	testSet("nestedFromVec","direct test",[
		testCase("normal",[VEC1],[0,[1,[2,[3,[4,[5,[6,[7,[]]]]]]]]]),
		testCase("undef vector",[undef],[]),
		testCase("scalar as vector",[5],[]),
		testCase("undef first elem",[[undef,1,2]],[undef,[1,[2,[]]]]),
		testCase("empty vector",[[]],[]),
		testCase("vector with vectors",[VEC_A],LIST_A)])
	testFunction(nestedFromVec($value[0]));
	
	// LIST1  = [3,[4,[5,[6,[7,[]]]]]];
	testSet("nestedIsEnd","direct test",[
		testCase(">1 item list",[LIST1],false),
		testCase("1 item list",[[1]],true),
		testCase("undef list",[undef],true),
		testCase("scalar as list",[5],true),
		testCase("bad list",[[1,2]],true),
		testCase("empty list",[[]],true)])
	testFunction(nestedIsEnd($value[0]));
	
	// LIST1  = [3,[4,[5,[6,[7,[]]]]]];
	testSet("nestedIsPastEnd","direct test",[
		testCase(">1 item list",[LIST1],false),
		testCase("1 item list",[[1]],false),
		testCase("undef list",[undef],true),
		testCase("scalar as list",[5],true),
		testCase("bad list",[[1,2]],false),
		testCase("empty list",[[]],true)])
	testFunction(nestedIsPastEnd($value[0]));
	
	// LIST1  = [3,[4,[5,[6,[7,[]]]]]];
	testSet("nestedIsEmpty","direct test",[
		testCase(">1 item list",[LIST1],false),
		testCase("1 item list",[[1]],false),
		testCase("undef list",[undef],false),
		testCase("scalar as list",[5],false),
		testCase("bad list",[[1,2]],false),
		testCase("empty list",[[]],true)])
	testFunction(nestedIsEmpty($value[0]));
	
	// LIST1  = [3,[4,[5,[6,[7,[]]]]]];
	// LIST2  = [3,[4,[5,6,[7,[8,[]]]]]];
	testSet("nestedMid","direct test",[
		testCase("normal, all",[LIST1,0,-1],LIST1),
		testCase("normal, first three",[LIST1,0,3],[3,[4,[5,[]]]]),
		testCase("normal, index 2 - 4",[LIST1,2,4],[5,[6,[7,[]]]]),
		testCase("normal, index 1 - 3",[LIST1,1,3],[4,[5,[6,[]]]]),
		testCase("normal, from index 2",[LIST1,2,-1],[5,[6,[7,[]]]]),
		testCase("normal, from index -5",[LIST1,-5,-1],[]),
		testCase("bad, all",[LIST2,0,-1],[3,[4,[5,[]]]]),
		testCase("bad, first two",[LIST2,0,2],[3,[4,[]]]),
		testCase("bad, index 2 - 4",[LIST2,2,4],[5,[]]),
		testCase("bad, index 1 - 3",[LIST2,1,3],[4,[5,[]]]),
		testCase("bad, from index 2",[LIST2,2,-1],[5,[]]),
		testCase("bad, from index -5",[LIST2,-5,-1],[]),
		testCase("undef list",[undef,0,-1],[]),
		testCase("scalar as list",[5,0,-1],[]),
		testCase("empty list",[[],0,-1],[])])
	testFunction(nestedMid($value[0],$value[1],$value[2]));

	// LIST1  = [3,[4,[5,[6,[7,[]]]]]];
	// LIST2  = [3,[4,[5,6,[7,[8,[]]]]]];
	testSet("nestedInsert","direct test",[
		testCase("start",[LIST1,"*",0],["*",[3,[4,[5,[6,[7,[]]]]]]]),
		testCase("middle",[LIST1,"*",2],[3,[4,["*",[5,[6,[7,[]]]]]]]),
		testCase("last",[LIST1,"*",4],[3,[4,[5,[6,["*",[7,[]]]]]]]),
		testCase("end",[LIST1,"*","end"],[3,[4,[5,[6,[7,["*",[]]]]]]]),
		testCase("end, bad list",[LIST2,"*","end"],[3,[4,[5,["*",[]]]]]),
		testCase("out of bounds",[LIST1,"*",20],LIST1),
		testCase("undef at middle",[LIST1,undef,2],
			[3,[4,[undef,[5,[6,[7,[]]]]]]]),
		testCase("undef list",[undef,"*",0],["*",[]]),
		testCase("scalar as list",[5,"*",0],["*",[]]),
		testCase("undef index",[LIST1,"*",undef],LIST1),
		testCase("undef list & index",[undef,"*",undef],[]),
		testCase("start of empty list",[[],"*",0],["*",[]]),
		testCase("end of empty list",[[],"*","end"],["*",[]]),
		testCase("out of bounds, empty list",[[],"*",20],[])])
	testFunction(nestedInsert($value[0],$value[1],$value[2]));
	
	// LIST1  = [3,[4,[5,[6,[7,[]]]]]];
	// LIST2  = [3,[4,[5,6,[7,[8,[]]]]]];
	testSet("nestedLen","direct test",[
		testCase("normal list",[LIST1],5),
		testCase("bad list",[LIST2],3),
		testCase("undef list",[undef],0),
		testCase("scalar as list",[5],0),
		testCase("empty list",[[]],0)])
	testFunction(nestedLen($value[0]));
	
	// LIST1  = [3,[4,[5,[6,[7,[]]]]]];
	// LIST2  = [3,[4,[5,6,[7,[8,[]]]]]];
	testSet("nestedGet","direct test",[
		testCase("from start",[LIST1,0],3),
		testCase("from middle",[LIST1,2],5),
		testCase("from last",[LIST1,4],7),
		testCase("from 'end'",[LIST1,"end"],7),
		testCase("from middle, undef value",[[3,[undef,[5]]],1],undef),
		testCase("from middle, bad list",[LIST2,2],5),
		testCase("from lst, bad list",[LIST2,5],undef),
		testCase("out of bounds",[LIST1,20],undef),
		testCase("undef index",[LIST1,undef],undef),
		testCase("scalar as list",[5,0],undef),
		testCase("undef list",[undef,0],undef),
		testCase("undef list & index",[undef,undef],undef),
		testCase("start of empty list",[[],0],undef),
		testCase("out of bounds, empty list",[[],20],undef)])
	testFunction(nestedGet($value[0],$value[1]));
	
	// LIST1  = [3,[4,[5,[6,[7,[]]]]]];
	// LIST2  = [3,[4,[5,6,[7,[8,[]]]]]];
	// LIST3  = [[4,9],[[3,8],[[5,0],[[7,1],[[8,4],[]]]]]];
	// LIST4  = [3,[4,[3,[6,[7,[3,[9,[]]]]]]]];
	testSet("nestedSearch","direct test",[
		testCase("normal, at start",[LIST1,3,0,undef],[0,[]]),
		testCase("normal, at middle",[LIST1,5,0,undef],[2,[]]),
		testCase("normal, at end",[LIST1,7,0,undef],[4,[]]),
		testCase("bad, at start",[LIST2,3,0,undef],[0,[]]),
		testCase("bad, at middle",[LIST2,5,0,undef],[2,[]]),
		testCase("bad, at end",[LIST2,8,0,undef],[]),
		testCase("normal, out-of-bounds check-index",[LIST1,3,0,1],[]),
		testCase("normal, undef check-index",[LIST1,3,0,undef],[0,[]]),
		testCase("list of vec2, at middle, check-index 0",
			[LIST3,5,0,0], [2,[]]),
		testCase("list of vec2, at middle, check-index 1",
			[LIST3,1,0,1], [3,[]]),
		testCase("list of vec2, out-of-bounds check-index",
			[LIST3,1,0,2], []),
		testCase("normal, no match",[LIST1,20,0,undef],[]),
		testCase("bad, no match",[LIST2,20,0,undef],[]),
		testCase("multi",[LIST4,3,0,undef],[0,[2,[5,[]]]]),
		testCase("multi, first match only",[LIST4,3,1,undef],[0,[]]),
		testCase("multi, first two matches",[LIST4,3,2,undef],[0,[2,[]]]),
		testCase("multi, undef match count",[LIST4,3,undef,undef],[0,[2,[5,[]]]]),
		testCase("scalar as list",[5,3,0,undef],[]),
		testCase("undef list",[undef,3,0,undef],[]),
		testCase("finding undef in list with undef",
			[[0,[undef,[2,[undef]]]],undef,0,undef], [1,[3,[]]]),
		testCase("finding undef in list without undef",
			[[0,[1,[2,[3]]]],undef,0,undef], []),
		testCase("empty list",[[],3,0,undef],[])])
	testFunction(nestedSearch(
		$value[0],$value[1],$value[2],$value[3]));
	
	// LIST1  = [3,[4,[5,[6,[7,[]]]]]];
	// LIST2  = [3,[4,[5,6,[7,[8,[]]]]]];
	testSet("nestedRemove","direct test",[
		testCase("start",[LIST1,0],[4,[5,[6,[7,[]]]]]),
		testCase("middle",[LIST1,2],[3,[4,[6,[7,[]]]]]),
		testCase("last",[LIST1,4],[3,[4,[5,[6,[]]]]]),
		testCase("end",[LIST1,"end"],[3,[4,[5,[6,[]]]]]),
		testCase("middle, undef value",[[3,[undef,[5,[]]]],1],[3,[5,[]]]),
		testCase("from middle, bad list",[LIST2,2],[3,[4,[]]]),
		testCase("from end, bad list",[LIST2,5],[3,[4,[5,[]]]]),
		testCase("out of bounds",[LIST1,20],LIST1),
		testCase("undef index",[LIST1,undef],LIST1),
		testCase("scalar as list",[5,0],[]),
		testCase("undef list",[undef,0],[]),
		testCase("undef list & index",[undef,undef],[]),
		testCase("start of empty list",[[],0],[]),
		testCase("start of 1 item list",[[1],0],[]),
		testCase("out of bounds, empty list",[[],20],[])])
	testFunction(nestedRemove($value[0],$value[1]));
	
	// LIST1  = [3,[4,[5,[6,[7,[]]]]]];
	// LIST2  = [3,[4,[5,6,[7,[8,[]]]]]];
	// LIST3  = [[4,9],[[3,8],[[5,0],[[7,1],[[8,4],[]]]]]];
	testSet("nestedFindMin","direct test",[
		testCase("normal, ordered",[LIST1,undef],0),
		testCase("bad, ordered",[LIST2,undef],0),
		testCase("mixed",[[6,[2,[5,[3,[9,[]]]]]],undef],1),
		testCase("mixed, bad",[[6,[8,[5,3,1,[10,[9,[]]]]]],undef],2),
		testCase("list of vec2, check-index 0",[LIST3,0],1),
		testCase("list of vec2, check-index 1",[LIST3,1],2),
		testCase("middle undef value",[[3,[undef,[5,[]]]],undef],0),
		testCase("out of bounds check-index, scalar list",
			[LIST1,20], undef),
		testCase("out of bounds check-index, vec2 list",
			[LIST3,20], undef),
		testCase("scalar as list",[5,undef],undef),
		testCase("undef list",[undef,undef],undef),
		testCase("empty list",[[],undef],undef),
		testCase("1 item list",[[1],undef],0),
		testCase("1 item list, undef",[[undef],undef],undef)])
	testFunction(nestedFindMin($value[0],$value[1]));
	
	// LIST1  = [3,[4,[5,[6,[7,[]]]]]];
	// LIST2  = [3,[4,[5,6,[7,[8,[]]]]]];
	// LIST3  = [[4,9],[[3,8],[[5,0],[[7,1],[[8,4],[]]]]]];
	testSet("nestedFindMax","direct test",[
		testCase("normal, ordered",[LIST1,undef],4),
		testCase("bad, ordered",[LIST2,undef],2),
		testCase("mixed",[[6,[2,[5,[3,[9,[]]]]]],undef],4),
		testCase("mixed, bad",[[6,[8,[5,3,1,[10,[9,[]]]]]],undef],1),
		testCase("list of vec2, check-index 0",[LIST3,0],4),
		testCase("list of vec2, check-index 1",[LIST3,1],0),
		testCase("middle undef value",[[3,[undef,[5,[]]]],undef],2),
		testCase("out of bounds check-index, scalar list",
			[LIST1,20],undef),
		testCase("out of bounds check-index, vec2 list",
			[LIST3,20],undef),
		testCase("scalar as list",[5,undef],undef),
		testCase("undef list",[undef,undef],undef),
		testCase("empty list",[[],undef],undef),
		testCase("1 item list",[[1],undef],0),
		testCase("1 item list, undef",[[undef],undef],undef)])
	testFunction(nestedFindMax($value[0],$value[1]));
	
	// LIST1  = [3,[4,[5,[6,[7,[]]]]]];
	// LIST2  = [3,[4,[5,6,[7,[8,[]]]]]];
	// LIST3  = [[4,9],[[3,8],[[5,0],[[7,1],[[8,4],[]]]]]];
	testSet("nestedSort","direct test",[
		testCase("normal, ascending",[LIST1,false,undef],LIST1),
		testCase("normal, decending",[LIST1,true,undef],
			[7,[6,[5,[4,[3,[]]]]]]),
		testCase("bad, ascending",[LIST2,false,undef],[3,[4,[5,[]]]]),
		testCase("bad, descending",[LIST2,true,undef],[5,[4,[3,[]]]]),
		testCase("mixed, ascending",
			[[6,[2,[5,[3,[9,[]]]]]],false,undef],[2,[3,[5,[6,[9,[]]]]]]),
		testCase("mixed, descending",
			[[6,[2,[5,[3,[9,[]]]]]],true,undef],[9,[6,[5,[3,[2,[]]]]]]),
		testCase("mixed, bad, ascending",
			[[6,[8,[5,3,1,[10,[9,[]]]]]],false,undef],[5,[6,[8,[]]]]),
		testCase("mixed, bad, descending",
			[[6,[8,[5,3,1,[10,[9,[]]]]]],true,undef],[8,[6,[5,[]]]]),
		testCase("vec2, index 0, ascending",
			[LIST3,false,0],[[3,8],[[4,9],[[5,0],[[7,1],[[8,4],[]]]]]]),
		testCase("vec2, index 0, descending",
			[LIST3,true,0],[[8,4],[[7,1],[[5,0],[[4,9],[[3,8],[]]]]]]),
		testCase("vec2, index 1, ascending",
			[LIST3,false,1],[[5,0],[[7,1],[[8,4],[[3,8],[[4,9],[]]]]]]),
		testCase("vec2, index 1, descending",
			[LIST3,true,1],[[4,9],[[3,8],[[8,4],[[7,1],[[5,0],[]]]]]]),
		testCase("middle undef value, ascending",
			[[3,[undef,[5]]],false,undef],[3,[5,[undef,[]]]]),
		testCase("middle undef value, descending",
			[[3,[undef,[5]]],true,undef],[5,[3,[undef,[]]]]),
		testCase("out of bounds checkIndex, scalar list, ascending",
			[LIST1,false,20],LIST1),
		testCase("out of bounds check-index, vec2 list, ascending",
			[LIST3,false,20],LIST3),
		testCase("scalar as list",[5,false,undef],[]),
		testCase("undef list",[undef,false,undef],[]),
		testCase("empty list",[[],false,undef],[]),
		testCase("empty list, out-of-bounds check-index",
			[[],false,20],[]),
		testCase("1 item list",[[1],false,undef],[1,[]]),
		testCase("1 item list, undef",
			[[undef,[]],false,undef],[undef,[]])])
	testFunction(nestedSort($value[0],$value[1],$value[2]));

// end of test group
}

/******************************************************************************
                     L I S T   M O D U L E   T E S T S
******************************************************************************/

testGroup("List Modules")
{
	testSet("nestedForEach","nested test with a child",[
		testCase("nested with null",[[10,[20,[30,[]]]]],
			"3x3 array of 5x5x5 cubes on x-y plane"),
		testCase("nested without null",[[10,[20,[30]]]],
			"3x3 array of 5x5x5 cubes on x-y plane"),
		testCase("undef list",[undef],"nothing"),
		testCase("empty list",[[]],"nothing")])
	testModule([0,0,0],[50,0,0])
	{
		// module being tested: nestedForEach()
		nestedForEach($value[0]) translate([$item,0,0])
			nestedForEach($value[0]) translate([0,$item,0])
				cube(5);
	}
// end of test group
}

/******************************************************************************
                   L I S T   L O O K U P   T E S T S
******************************************************************************/

/*
	Some of the list/vector tables used to test the functions with. These
	shouldn't be changed, unless changes are also made to the expected results
	in the tests.
*/
LOOKUP_V1 = [["a",1],["b",2],["c",3]];
LOOKUP_V2 = [["d",4],["e",5],["f",6],["g",7]];
LOOKUP_V3 = [["h",4],["i",5],["j",6],["k",7],["l",8]];
LOOKUP1   = [["a",1],[["b",2],[["c",3],[]]]];
LOOKUP2   = [["d",4],[["e",5],[["f",6],[["g",7],[]]]]];
LOOKUP3   = [["h",4],[["i",5],[["j",6],[["k",7],[["l",8],[]]]]]];
LOOKUP4   = [["a",4],[["i",5],[["a",6],[["k",7],[["a",8],[]]]]]];
LOOKUP_A  = [["a",5],[["b",2],[["c",3],[]]]];
LOOKUP_B  = [["a",2],[["b",9],[["c",12],[]]]];
LOOKUP_C  = [["a",1],[["b",0],[["c",8],[]]]];
LIST_ABC  = [LOOKUP_A,[LOOKUP_B,[LOOKUP_C,[]]]];
testGroup("Lookup Functions and List Search Functions Using Keys")
{
	// LOOKUP_V1 = [["a",1],["b",2],["c",3]]
	// LOOKUP_V2 = [["d",4],["e",5],["f",6],["g",7]]
	// LOOKUP_V3 = [["h",4],["i",5],["j",6],["k",7],["l",8]]
	// LOOKUP1   = [["a",1],[["b",2],[["c",3],[]]]]
	// LOOKUP2   = [["d",4],[["e",5],[["f",6],[["g",7],[]]]]]
	// LOOKUP3   = [["h",4],[["i",5],[["j",6],[["k",7],[["l",8],[]]]]]]
	testSet("nestedLookupCreate","direct test",[
		testCase("normal 1",[LOOKUP_V1],LOOKUP1),
		testCase("normal 2",[LOOKUP_V2],LOOKUP2),
		testCase("normal 3",[LOOKUP_V3],LOOKUP3),
		testCase("undef vector",[undef],[]),
		testCase("scalar as vector",[5],[]),
		testCase("empty vector",[[]],[])])
	testFunction(nestedLookupCreate($value[0]));

	// LOOKUP1   = [["a",1],[["b",2],[["c",3],[]]]]
	// LOOKUP2   = [["d",4],[["e",5],[["f",6],[["g",7],[]]]]]
	// LOOKUP3   = [["h",4],[["i",5],[["j",6],[["k",7],[["l",8],[]]]]]]
	testSet("nestedLookup","direct test",[
		testCase("normal 1, first",[LOOKUP1,"a"],1),
		testCase("normal 1, middle",[LOOKUP1,"b"],2),
		testCase("normal 1, last",[LOOKUP1,"c"],3),
		testCase("normal 1, unknown",[LOOKUP1,"z"],undef),
		testCase("normal 2",[LOOKUP2,"f"],6),
		testCase("normal 3",[LOOKUP3,"k"],7),
		testCase("undef table",[undef,"a"],undef),
		testCase("undef all",[undef,undef],undef),
		testCase("scalar as table",[5,"a"],undef),
		testCase("empty table",[[],"a"],undef)])
	testFunction(nestedLookup($value[0],$value[1]));

	// LOOKUP1   = [["a",1],[["b",2],[["c",3],[]]]]
	// LOOKUP4   = [["a",4],[["i",5],[["a",6],[["k",7],[["a",8],[]]]]]]
	testSet("nestedLookupAdd","direct test",[
		testCase("new, single",
			[LOOKUP1,[["z",42]],false],[["z",42],LOOKUP1]),
		testCase("new, multi",
			[LOOKUP1,[["x",24],["z",42]],false],[["z",42],[["x",24],LOOKUP1]]),
		testCase("replace, remove single trace",
			[LOOKUP1,[["a",99]],false],[["a",99],[["b",2],[["c",3],[]]]]),
		testCase("replace 2, remove single trace",
			[LOOKUP1,[["c",99]],false],[["c",99],[["a",1],[["b",2],[]]]]),
		testCase("replace, remove multiple traces",
			[LOOKUP4,[["a",99]],false],[["a",99],[["i",5],[["k",7],[]]]]),
		testCase("replace, keep old",
			[LOOKUP1,[["a",99]],true],[["a",99],[["a",1],[["b",2],[["c",3],[]]]]]),
		testCase("undef table",[undef,[["a",1]],false],[["a",1],[]]),
		testCase("undef table and entry",[undef,[undef],false],[undef,[]]),
		testCase("scalar as table",[5,[["a",1]],false],[["a",1],[]]),
		testCase("empty table",[[],[["a",1]],false],[["a",1],[]])])
	testFunction(nestedLookupAdd($value[0],$value[1],$value[2]));

	// LOOKUP1   = [["a",1],[["b",2],[["c",3],[]]]]
	// LOOKUP4   = [["a",4],[["i",5],[["a",6],[["k",7],[["a",8],[]]]]]]
	testSet("nestedLookupRemove","direct test",[
		testCase("single 1",
			[LOOKUP1,["a"]],[["b",2],[["c",3],[]]]),
		testCase("single 2",
			[LOOKUP1,["b"]],[["a",1],[["c",3],[]]]),
		testCase("single 3",
			[LOOKUP1,["c"]],[["a",1],[["b",2],[]]]),
		testCase("multi 1",
			[LOOKUP1,["a","b"]],[["c",3],[]]),
		testCase("multi 2",
			[LOOKUP1,["b","c"]],[["a",1],[]]),
		testCase("multi 3",
			[LOOKUP1,["c","a"]],[["b",2],[]]),
		testCase("all",
			[LOOKUP1,["a","b","c"]],[]),
		testCase("multiple traces",
			[LOOKUP4,["a"]],[["i",5],[["k",7],[]]]),
		testCase("unknown key",
			[LOOKUP4,["z"]],LOOKUP4),
		testCase("undef table",[undef,["a"]],[]),
		testCase("undef key",[LOOKUP1,[undef]],LOOKUP1),
		testCase("undef table and key",[undef,[undef]],[]),
		testCase("scalar as table",[5,["a"]],[]),
		testCase("scalar as vector",[LOOKUP1,5],LOOKUP1),
		testCase("empty table",[[],["a"]],[])])
	testFunction(nestedLookupRemove($value[0],$value[1]));

	// LOOKUP_A  = [["a",5],[["b",2],[["c",3],[]]]],
	// LOOKUP_B  = [["a",2],[["b",9],[["c",12],[]]]],
	// LOOKUP_C  = [["a",1],[["b",0],[["c",8],[]]]])
	// LIST_ABC  = [LOOKUP_A,[LOOKUP_B,[LOOKUP_C,[]]]])
	testSet("nestedSearch","direct test (using key)",[
		testCase("property 1 value 1",[LIST_ABC,5,"a"],[0,[]]),
		testCase("property 1 value 2",[LIST_ABC,2,"a"],[1,[]]),
		testCase("property 1 value 3",[LIST_ABC,1,"a"],[2,[]]),
		testCase("property 2 value 1",[LIST_ABC,2,"b"],[0,[]]),
		testCase("property 2 value 2",[LIST_ABC,9,"b"],[1,[]]),
		testCase("property 2 value 3",[LIST_ABC,0,"b"],[2,[]]),
		testCase("property 3 value 1",[LIST_ABC,3,"c"],[0,[]]),
		testCase("property 3 value 2",[LIST_ABC,12,"c"],[1,[]]),
		testCase("property 3 value 3",[LIST_ABC,8,"c"],[2,[]]),
		testCase("unknown key",[LIST_ABC,8,"z"],[]),
		testCase("no matching value",[LIST_ABC,20,"a"],[]),
		testCase("undef list",[undef,8,"a"],[]),
		testCase("scalar as list",[5,8,"a"],[]),
		testCase("empty list",[[],8,"a"],[])])
	testFunction(nestedSearch($value[0],$value[1],checkKey=$value[2]));

	// LOOKUP_A  = [["a",5],[["b",2],[["c",3],[]]]],
	// LOOKUP_B  = [["a",2],[["b",9],[["c",12],[]]]],
	// LOOKUP_C  = [["a",1],[["b",0],[["c",8],[]]]])
	// LIST_ABC  = [LOOKUP_A,[LOOKUP_B,[LOOKUP_C,[]]]])
	testSet("nestedFindMin","direct test (using key)",[
		testCase("property 1",[LIST_ABC,"a"],2),
		testCase("property 2",[LIST_ABC,"b"],2),
		testCase("property 3",[LIST_ABC,"c"],0),
		testCase("unknown key",[LIST_ABC,"z"],undef),
		testCase("undef list",[undef,"a"],undef),
		testCase("scalar as list",[5,"a"],undef),
		testCase("empty list",[[],"a"],undef)])
	testFunction(nestedFindMin($value[0],checkKey=$value[1]));

	// LOOKUP_A  = [["a",5],[["b",2],[["c",3],[]]]],
	// LOOKUP_B  = [["a",2],[["b",9],[["c",12],[]]]],
	// LOOKUP_C  = [["a",1],[["b",0],[["c",8],[]]]])
	// LIST_ABC  = [LOOKUP_A,[LOOKUP_B,[LOOKUP_C,[]]]])
	testSet("nestedFindMax","direct test (using key)",[
		testCase("property 1",[LIST_ABC,"a"],0),
		testCase("property 2",[LIST_ABC,"b"],1),
		testCase("property 3",[LIST_ABC,"c"],1),
		testCase("unknown key",[LIST_ABC,"z"],undef),
		testCase("undef list",[undef,"a"],undef),
		testCase("scalar as list",[5,"a"],undef),
		testCase("empty list",[[],"a"],undef)])
	testFunction(nestedFindMax($value[0],checkKey=$value[1]));

	// LOOKUP_A  = [["a",5],[["b",2],[["c",3],[]]]],
	// LOOKUP_B  = [["a",2],[["b",9],[["c",12],[]]]],
	// LOOKUP_C  = [["a",1],[["b",0],[["c",8],[]]]])
	// LIST_ABC  = [LOOKUP_A,[LOOKUP_B,[LOOKUP_C,[]]]])
	testSet("nestedSort","direct test (using key)",[
		testCase("property 1, ascending",[LIST_ABC,false,"a"],
			[LOOKUP_C,[LOOKUP_B,[LOOKUP_A,[]]]]),
		testCase("property 1, descending",[LIST_ABC,true,"a"],
			[LOOKUP_A,[LOOKUP_B,[LOOKUP_C,[]]]]),
		testCase("property 2, ascending",[LIST_ABC,false,"b"],
			[LOOKUP_C,[LOOKUP_A,[LOOKUP_B,[]]]]),
		testCase("property 2, descending",[LIST_ABC,true,"b"],
			[LOOKUP_B,[LOOKUP_A,[LOOKUP_C,[]]]]),
		testCase("property 3, ascending",[LIST_ABC,false,"c"],
			[LOOKUP_A,[LOOKUP_C,[LOOKUP_B,[]]]]),
		testCase("property 3, descending",[LIST_ABC,true,"c"],
			[LOOKUP_B,[LOOKUP_C,[LOOKUP_A,[]]]]),
		testCase("unknown key",[LIST_ABC,false,"z"],LIST_ABC),
		testCase("undef list",[undef,false,"a"],[]),
		testCase("scalar as list",[5,false,"a"],[]),
		testCase("empty list",[[],false,"a"],[])])
	testFunction(nestedSort(
		$value[0],$value[1],checkKey=$value[2]));

// end of test group
}
