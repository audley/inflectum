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
include <../list.scad>

/*
   Test Group: List Functions
      function head(list)
      function tail(list)
		function flattenNested(list)
      function slice(list,range)
      function insert(list,index,value)
		function insertMulti(list,index,values)
      function replace(list,index,value)
		function replaceMulti(list,index,values)
		function remove(list,index)
		function removeMulti(list,indexes)
		function filter(fname,list)
		function foldr(fname,start,list)
		function foldl(fname,start,list)
		function map2(fname,listOfLists)
		function filter2(fname,listOfLists)
		function listSimplify(list,bounds=undef)
      function search(value,list,range=undef,matches=undef,index=undef)
      function sort(list,descending=false,index=undef)

   Test Group: Lookup Functions and List Functions Using Keys
      function lookup(key,table)
      function lookupSet(keyValue,table,keepOld=false)
		function lookupSetMulti(keyValues,table,keepOld=false)
      function lookupRemove(key,table)
      function lookupRemoveMulti(keys,table)
		function lookupMap(fname,table)
		function lookupFilter(table)
		function search(value,list,range=undef,key=undef)
      function sort(list,descending=false,key=undef)
*/

/******************************************************************************
                     L I S T   F U N C T I O N   T E S T S
******************************************************************************/

/*
   Key tests: Undefined items in the lists, undefinded/scalar lists,
              undefined/invalid value/index args, empty lists,
              special values (+/-inf,nan,undef), ranges, START, END
*/

/*
	Functions to test the map(), foldl(), foldr() and filter() functions with.
	These shouldn't be changed, unless changes are also made to the expected
	results in the tests below.
*/
$function0 = "test_filter_1";  function $function0(item)       = item>5;
$function1 = "test_filter_2";  function $function1(item,index) = item>index;
$function2 = "test_foldr_1";   function $function2(item,acc)   = item+acc;
$function3 = "test_foldr_2";   function $function3(v,a,i)      = [[v,i],a];
$function4 = "test_foldl_1";   function $function4(acc,item)   = acc+item;
$function5 = "test_foldl_2";   function $function5(a,v,i)      = [a,[v,i]];
$function6 = "test_map2_1";    function $function6(item)       = [item];
$function7 = "test_map2_2";    function $function7(v,i1,i2)    = [v,i1,i2];
$function8 = "test_filter2_1"; function $function8(v)          = v>5;
$function9 = "test_filter2_2"; function $function9(v,i1,i2)    = v>i2;

/*
   Some of the lists to test the functions with. These shouldn't be changed,
   unless changes are also made to the expected results in the tests below.
*/
LIST1 = [3,4,5,6,7];
LIST2 = [[4,9],[3,8],[5,0],[7,1],[8,4]];
LIST3 = [3,4,3,6,7,3,9];
LIST4 = [0,1,2,3,4,5,6,7,8,9];
LIST5 = [[1,2,3],[4,5,6],[7,8,9]];
LIST6 = [[1,2,3],[4,5,6],[7,8,9]];
LIST7 = [[0,0,3],[-1,1,2],[0,1,0]];
testGroup("List Functions")
{
   // LIST1 = [3,4,5,6,7]
   testSet("head","direct test",[
      testCase("normal",[LIST1],3),
      testCase("undef list",[undef],undef),
      testCase("scalar as list",[5],undef),
      testCase("undef first item",[[undef,[2,[3,[]]]]],undef),
      testCase("empty list",[[]],undef)])
   testFunction(head($value[0]));
   
   // LIST1 = [3,4,5,6,7]
   testSet("tail","direct test",[
      testCase("normal",[LIST1],[4,5,6,7]),
      testCase("undef list",[undef],[]),
      testCase("undef last item",[[1,2,undef]],[2,undef]),
      testCase("no tail",[[1]],[]),
      testCase("empty list",[[]],[])])
   testFunction(tail($value[0]));

	testSet("flattenNested","direct test",[
      testCase("list of numbers",
			[[1,[2,[3,[4,[5,[6,[7,[8]]]]]]]]],[1,2,3,4,5,6,7,8]),
		testCase("list of numbers, null terminated",
			[[1,[2,[3,[4,[5,[6,[7,[8,[]]]]]]]]]],[1,2,3,4,5,6,7,8]),
		testCase("lists of ranges",[[[1:4],[[5:8],[[2:5]]]]],
			[[1:4],[5:8],[2:5]]),
		testCase("numbers and empty lists",
			[[1,[[],[2,[[],[3]]]]]],[1,[],2,[],3]),
      testCase("undef list",[undef],[]),
		testCase("scalar list",[5],[]),
		testCase("empty value list",[[]],[])])
   testFunction(flattenNested($value[0]));
   
   // LIST1 = [3,4,5,6,7]
   testSet("slice","direct test",[
      testCase("normal, all",[LIST1,undef],LIST1),
      testCase("normal, first three",[LIST1,[0:2]],[3,4,5]),
      testCase("normal, index 2 - 4",[LIST1,[2:4]],[5,6,7]),
      testCase("normal, index 1 - 3",[LIST1,[1:3]],[4,5,6]),
      testCase("normal, from index 2",[LIST1,[2:END]],[5,6,7]),
      testCase("normal, from index -5",[LIST1,[-5:END]],[3,4,5,6,7]),
		testCase("normal, too high index",[LIST1,[20:END]],[]),
      testCase("undef list",[undef,[0:END]],[]),
      testCase("scalar as list",[5,[0:END]],[]),
      testCase("empty list",[[],[0:END]],[])])
   testFunction(slice($value[0],$value[1]));

	// LIST1 = [3,4,5,6,7]
   testSet("insert","direct test",[
      testCase("start",[LIST1,0,"*"],["*",3,4,5,6,7]),
      testCase("middle",[LIST1,2,"*"],[3,4,"*",5,6,7]),
      testCase("last",[LIST1,4,"*"],[3,4,5,6,"*",7]),
      testCase("end",[LIST1,"end","*"],[3,4,5,6,7,"*"]),
      testCase("out of bounds",[LIST1,20,"*"],LIST1),
      testCase("undef at middle",[LIST1,2,undef],[3,4,undef,5,6,7]),
      testCase("undef list",[undef,0,"*"],["*"]),
      testCase("scalar as list",[5,0,"*"],["*"]),
      testCase("undef index",[LIST1,undef,"*"],LIST1),
      testCase("undef list & index",[undef,undef,"*"],[]),
      testCase("start of empty list",[[],0,"*"],["*"]),
      testCase("end of empty list",[[],"end","*"],["*"]),
      testCase("out of bounds, empty list",[[],20,"*"],[])])
   testFunction(insert($value[0],$value[1],$value[2]));

	// LIST1 = [3,4,5,6,7]
   testSet("insertMulti","direct test",[
      testCase("start",[LIST1,0,["A","B"]],["A","B",3,4,5,6,7]),
      testCase("middle",[LIST1,2,["A","B","C"]],[3,4,"A","B","C",5,6,7]),
      testCase("end",[LIST1,"end",["A","B","C","D"]],
			[3,4,5,6,7,"A","B","C","D"]),
      testCase("undef value list",[LIST1,0,undef],LIST1),
		testCase("scalar value list",[LIST1,0,5],LIST1),
		testCase("empty value list",[LIST1,0,[]],LIST1)])
   testFunction(insertMulti($value[0],$value[1],$value[2]));

   // LIST1 = [3,4,5,6,7]
   testSet("replace","direct test",[
      testCase("start",[LIST1,0,"*"],["*",4,5,6,7]),
      testCase("middle",[LIST1,2,"*"],[3,4,"*",6,7]),
      testCase("last",[LIST1,4,"*"],[3,4,5,6,"*"]),
      testCase("end",[LIST1,"end","*"],[3,4,5,6,"*"]),
      testCase("out of bounds",[LIST1,20,"*"],LIST1),
      testCase("undef at middle",[LIST1,2,undef],[3,4,undef,6,7]),
      testCase("undef list",[undef,0,"*"],[]),
      testCase("scalar as list",[5,0,"*"],[]),
      testCase("undef index",[LIST1,undef,"*"],LIST1),
      testCase("undef list & index",[undef,undef,"*"],[]),
      testCase("start of empty list",[[],0,"*"],[]),
      testCase("end of empty list",[[],"end","*"],[]),
      testCase("out of bounds, empty list",[[],20,"*"],[])])
   testFunction(replace($value[0],$value[1],$value[2]));

	// LIST1 = [3,4,5,6,7]
   testSet("replaceMulti","direct test",[
      testCase("start",[LIST1,0,["A","B"]],["A","B",5,6,7]),
      testCase("middle, to end",[LIST1,2,["A","B","C"]],[3,4,"A","B","C"]),
      testCase("end",[LIST1,"end",["A","B","C","D"]],
			[3,4,5,6,"A","B","C","D"]),
      testCase("undef value list",[LIST1,0,undef],LIST1),
		testCase("scalar value list",[LIST1,0,5],LIST1),
		testCase("empty value list",[LIST1,0,[]],LIST1)])
   testFunction(replaceMulti($value[0],$value[1],$value[2]));
   
	// LIST4 = [0,1,2,3,4,5,6,7,8,9]
   testSet("remove","direct test",[
      testCase("start",[LIST4,0],[1,2,3,4,5,6,7,8,9]),
      testCase("middle",[LIST4,4],[0,1,2,3,5,6,7,8,9]),
      testCase("last",[LIST4,9],[0,1,2,3,4,5,6,7,8]),
      testCase("end",[LIST4,"end"],[0,1,2,3,4,5,6,7,8]),
      testCase("middle, undef value",[[3,undef,5],1],[3,5]),
      testCase("out of bounds",[LIST4,20],LIST4),
      testCase("undef index",[LIST4,undef],LIST4),
      testCase("scalar as list",[5,0],[]),
      testCase("undef list",[undef,0],[]),
      testCase("undef list & index",[undef,undef],[]),
      testCase("start of empty list",[[],0],[]),
      testCase("start of 1 item list",[[1],0],[]),
      testCase("out of bounds, empty list",[[],20],[])])
   testFunction(remove($value[0],$value[1]));

	// LIST4 = [0,1,2,3,4,5,6,7,8,9]
   testSet("removeMulti","direct test",[
      testCase("start, range",[LIST4,[0:2]],[3,4,5,6,7,8,9]),
		testCase("start, specific",[LIST4,[0,1,2]],[3,4,5,6,7,8,9]),
      testCase("middle, to end",[LIST4,[4:END]],[0,1,2,3]),
      testCase("odd indexes, specific",[LIST4,[1,3,5,7,9]],[0,2,4,6,8]),
		testCase("odd indexes, by range",[LIST4,[1:2:9]],[0,2,4,6,8]),
		testCase("multiple indexes, with 'end'",
			[LIST4,[1,3,"end"]],[0,2,4,5,6,7,8]),
		testCase("duplicated indexes",[LIST4,[1,1,5,5]],[0,2,3,4,6,7,8,9]),
      testCase("undef value list",[LIST4,undef],LIST4),
		testCase("scalar value list",[LIST4,5],LIST4),
		testCase("empty value list",[LIST4,[]],LIST4)])
   testFunction(removeMulti($value[0],$value[1]));

   // test_filter_1(item) = item>5
	// test_filter_2(item,index) = item>index
	testSet("filter","direct test",[
      testCase("normal 1",["test_filter_1",[1,7,3,9,20,8]],[7,9,20,8]),
		testCase("normal 2, with index",
			["test_filter_2",[1,2,2,5,5,6,7,2,9]],[1,2,5,5,6,7,9]),
      testCase("undef list",["test_filter_1",undef],[]),
		testCase("empty list",["test_filter_1",[]],[]),
		testCase("unregistered function",["zzz",[1,2]],[1,2])])
   testFunction(filter($value[0],$value[1]));

	// test_foldr_1(item,acc) = item+acc
	// test_foldr_2(value,acc,index) = [[value,index],acc]
	testSet("foldr","direct test",[
      testCase("sum",["test_foldr_1",0,[2,4,8,16,32]],62),
		testCase("nesting, with index",
			["test_foldr_2",[],[1,2,3,4]],[[1,0],[[2,1],[[3,2],[[4,3],[]]]]]),
      testCase("undef list",["test_foldr_1",[],undef],[]),
		testCase("empty list",["test_foldr_1",[]],[]),
		testCase("unregistered function",["zzz",[],[1,2]],[])])
   testFunction(foldr($value[0],$value[1],$value[2]));

	// test_foldl_1(item,acc) = acc+item
	// test_foldl_2(acc,value,index) = [acc,[value,index]]
	testSet("foldl","direct test",[
      testCase("sum",["test_foldl_1",0,[2,4,8,16,32]],62),
		testCase("nesting, with index",
			["test_foldl_2",[],[1,2,3,4]],[[[[[],[1,0]],[2,1]],[3,2]],[4,3]]),
      testCase("undef list",["test_foldl_1",[],undef],[]),
		testCase("empty list",["test_foldl_1",[]],[]),
		testCase("unregistered function",["zzz",[],[1,2]],[])])
   testFunction(foldl($value[0],$value[1],$value[2]));

	// test_map2_1(item) = [item]
	// test_map2_2(item,index1,index2) = [item,index1,index2]
	// LIST5 = [[1,2,3],[4,5,6],[7,8,9]],
	testSet("map2","direct test",[
      testCase("normal 1",["test_map2_1",LIST5],
			[[[1],[2],[3]],[[4],[5],[6]],[[7],[8],[9]]]),
		testCase("normal 2, with indexes",["test_map2_2",LIST5],
			[[[1,0,0],[2,0,1],[3,0,2]],[[4,1,0],[5,1,1],[6,1,2]],
			 [[7,2,0],[8,2,1],[9,2,2]]]),
      testCase("undef list",["test_map2_1",undef],[]),
		testCase("empty list",["test_map2_1",[]],[]),
		testCase("unregistered function",["zzz",LIST5],LIST5)])
   testFunction(map2($value[0],$value[1]));

	// test_filter2_1(item) = item>5
	// test_filter2_2(item,index1,index2) = item>index2
	// LIST6 = [[1,2,3],[4,5,6],[7,8,9]]
   // LIST7 = [[0,0,3],[-1,1,2],[0,1,0]]
	testSet("filter2","direct test",[
      testCase("normal 1",["test_filter2_1",LIST6],[[],[6],[7,8,9]]),
		testCase("normal 2, with index",
			["test_filter2_2",LIST7],[[3],[],[]]),
      testCase("undef list",["test_filter2_1",undef],[]),
		testCase("empty list",["test_filter2_1",[]],[]),
		testCase("unregistered function",
			["zzz",[[1,2],[2,3]]],[[1,2],[2,3]])])
   testFunction(filter2($value[0],$value[1]));

   	testSet("listSimplify","direct test",[
      testCase("numbers",[[1,2,3,4,5]],[1,2,3,4,5]),
		testCase("ranges",[[[1:4],[2:4],[5:-1:3]]],[[1,2,3,4],[2,3,4],[5,4,3]]),
		testCase("ranges with infinite bounds, with limit",
			[[[1:END],[5:-1:START],[START:END]],[-2:6]],
			[[1,2,3,4,5,6],[5,4,3,2,1,0,-1,-2],[-2,-1,0,1,2,3,4,5,6]]),
		testCase("invalid range",[[[undef:END],[1:4]]],[undef,[1,2,3,4]]),
		testCase("scalar list",[5],[]),
      testCase("undef list",[undef],[]),
		testCase("empty list",[[]],[])])
   testFunction(listSimplify($value[0],$value[1]));

	// LIST1 = [3,4,5,6,7];
   // LIST2 = [[4,9],[3,8],[5,0],[7,1],[8,4]];
   // LIST3 = [3,4,3,6,7,3,9];
   testSet("search","direct test",[
      testCase("normal, at start",[3,LIST1,undef,undef],[0]),
      testCase("normal, at middle",[5,LIST1,undef,undef],[2]),
      testCase("normal, at end",[7,LIST1,undef,undef],[4]),
      testCase("normal, out-of-bounds check-index",[3,LIST1,0,1],[]),
      testCase("normal, undef check-index",[3,LIST1,0,undef],[0]),
      testCase("list of vec2, at middle, check-index 0",
         [5,LIST2,0,0], [2]),
      testCase("list of vec2, at middle, check-index 1",
         [1,LIST2,0,1], [3]),
      testCase("list of vec2, out-of-bounds check-index",
         [1,LIST2,0,2], []),
      testCase("normal, no match",[20,LIST1,0,undef],[]),
      testCase("multi",[3,LIST3,0,undef],[0,2,5]),
      testCase("multi, searching range",[3,LIST3,[1:4],undef],[2]),
		testCase("multi, first match only",[3,LIST3,undef,undef,1],[0]),
		testCase("multi, first two matches",[3,LIST3,undef,undef,2],[0,2]),
		testCase("multi, too small match count",[3,LIST3,undef,undef,-5],[0,2,5]),
      testCase("scalar as list",[3,5,undef,undef],[]),
      testCase("undef list",[3,undef,0,undef],[]),
      testCase("finding undef in list with undef",
         [undef,[0,undef,2,undef],undef,undef],[1,3]),
      testCase("finding undef in list without undef",
         [undef,[0,1,2,3],undef,undef], []),
      testCase("empty list",[3,[],undef,undef],[])])
   testFunction(search(
      $value[0],$value[1],range=$value[2],index=$value[3], matches=$value[4]));

   // LIST1 = [3,4,5,6,7];
   // LIST2 = [[4,9],[3,8],[5,0],[7,1],[8,4]];
   testSet("sort","direct test",[
      testCase("normal, ascending",[LIST1,false,undef],LIST1),
      testCase("normal, decending",[LIST1,true,undef],[7,6,5,4,3]),
      testCase("mixed, ascending",
         [[6,2,9,3,5],false,undef],[2,3,5,6,9]),
      testCase("mixed, descending",
         [[6,2,5,3,9],true,undef],[9,6,5,3,2]),
      testCase("vec2, index 0, ascending",
         [LIST2,false,0],[[3,8],[4,9],[5,0],[7,1],[8,4]]),
      testCase("vec2, index 0, descending",
         [LIST2,true,0],[[8,4],[7,1],[5,0],[4,9],[3,8]]),
      testCase("vec2, index 1, ascending",
         [LIST2,false,1],[[5,0],[7,1],[8,4],[3,8],[4,9]]),
      testCase("vec2, index 1, descending",
         [LIST2,true,1],[[4,9],[3,8],[8,4],[7,1],[5,0]]),
      testCase("start undef value, ascending",
         [[undef,3,5],false,undef],[3,5,undef]),
      testCase("start undef value, descending",
         [[undef,3,5],true,undef],[5,3,undef]),
      testCase("middle undef value, ascending",
         [[3,undef,5],false,undef],[3,5,undef]),
      testCase("middle undef value, descending",
         [[3,undef,5],true,undef],[5,3,undef]),
      testCase("end undef value, ascending",
         [[3,5,undef],false,undef],[3,5,undef]),
      testCase("end undef value, descending",
         [[3,5,undef],true,undef],[5,3,undef]),
      testCase("all undef values, ascending",
         [[undef,undef,undef,undef],false,undef],[undef,undef,undef,undef]),
      testCase("all undef values, descending",
         [[undef,undef,undef,undef],true,undef],[undef,undef,undef,undef]),
      testCase("special values 1, ascending",
         [[undef,0/0,1/0,-1/0],false,undef,true],[-1/0,1/0,0/0,undef]),
      testCase("special values 1, descending",
         [[undef,0/0,1/0,-1/0],true,undef,true],[1/0,-1/0,0/0,undef]),
      testCase("special values 2, ascending",
         [[undef,1/0,-1/0,0/0],false,undef,true],[-1/0,1/0,0/0,undef]),
      testCase("special values 2, descending",
         [[undef,1/0,-1/0,0/0],true,undef,true],[1/0,-1/0,0/0,undef]),
      testCase("special values 3, ascending",
         [[1/0,-1/0,0/0,undef],false,undef,true],[-1/0,1/0,0/0,undef]),
      testCase("special values 3, descending",
         [[1/0,-1/0,0/0,undef],true,undef,true],[1/0,-1/0,0/0,undef]),
      testCase("out of bounds checkIndex, scalar list, ascending",
         [LIST1,false,20],LIST1),
      testCase("out of bounds check-index, vec2 list, ascending",
         [LIST2,false,20],LIST2),
      testCase("scalar as list",[5,false,undef],[]),
      testCase("undef list",[undef,false,undef],[]),
      testCase("empty list",[[],false,undef],[]),
      testCase("empty list, out-of-bounds check-index",
         [[],false,20],[]),
      testCase("1 item list",[[1],false,undef],[1]),
      testCase("1 item list, undef",
         [[undef],false,undef],[undef])])
   testFunction(sort(
      $value[0],$value[1],$value[2]),manual=$value[3]);

// end of test group
}

/******************************************************************************
       L O O K U P   F U N C T I O N S   A N D   R E L A T E D   T E S T S
******************************************************************************/

/*
   Key tests: Undefined items in the tables, undefinded/scalar entries,
              empty tables, bad keys, single/multi add/remove,
              new/old keys, keepOld.

	NOTE: warning messages are expected.
*/

/*
	Functions to test the lookupMap() function with. These shouldn't be changed,
	unless changes are also made to the expected results in the tests below.
*/
$function12 = "test_lookupMap1";
	function $function12(key,value) = value*2;
$function13 = "test_lookupMap2";
	function $function13(key,value) = (value<5) ? undef : value/2;

/*
   Some of the tables used to test the functions with. These shouldn't be
   changed, unless changes are also made to the expected results in the tests.
*/
LOOKUP1  = [["a",1],["b",2],["c",3]];
LOOKUP2  = [["d",4],["e",5],["f",6],["g",7]];
LOOKUP3  = [["h",4],["i",5],["j",6],["k",7],["l",8]];
LOOKUP4  = [["a",4],["i",5],["a",6],["k",7],["a",8]];
LOOKUP5  = [[10,4],[20,5],[30,6],[40,7],[50,8]];
LOOKUP6  = [[10,3],[20,7],[30,4],[40,6],[50,5]];
LOOKUP7  = [[10,3],[20,undef],[30,4],[40,undef],[50,5]];
LOOKUP_A = [["a",5],["b",2],["c",3]];
LOOKUP_B = [["a",2],["b",9],["c",12]];
LOOKUP_C = [["a",1],["b",0],["c",8]];
LIST_ABC = [LOOKUP_A,LOOKUP_B,LOOKUP_C];
testGroup("Lookup Functions and List Search Functions Using Keys")
{
   // LOOKUP1   = [["a",1],["b",2],["c",3]]
   // LOOKUP2   = [["d",4],["e",5],["f",6],["g",7]]
   // LOOKUP3   = [["h",4],["i",5],["j",6],["k",7],["l",8]]
   // LOOKUP5   = [[10,4],[20,5],[30,6],[40,7],[50,8]]
   //
   // Message expected: WARNING: search term not found: "z"
   //
   testSet("lookup","direct test",[
      testCase("normal 1, first",["a",LOOKUP1],1),
      testCase("normal 1, middle",["b",LOOKUP1],2),
      testCase("normal 1, last",["c",LOOKUP1],3),
      testCase("normal 1, unknown",["z",LOOKUP1],undef),
      testCase("normal 2",["f",LOOKUP2],6),
      testCase("normal 3",["k",LOOKUP3],7),
      testCase("numeric keys 1",[10,LOOKUP5],4),
      testCase("numeric keys 2",[20,LOOKUP5],5),
      testCase("numeric keys 3",[30,LOOKUP5],6),
      testCase("numeric keys 4",[40,LOOKUP5],7),
      testCase("numeric keys 5",[50,LOOKUP5],8),
      testCase("undef table",["a",undef],undef),
      testCase("undef all",[undef,undef],undef),
      testCase("scalar as table",["a",5],undef),
      testCase("empty table",["a",[]],undef)])
   testFunction(lookup($value[0],$value[1]));

   // LOOKUP1   = [["a",1],["b",2],["c",3]]
   // LOOKUP4   = [["a",4],["i",5],["a",6],["k",7],["a",8]]
   testSet("lookupSet","direct test",[
      testCase("new",
         [["z",42],LOOKUP1,false],[["z",42],["a",1],["b",2],["c",3]]),
      testCase("replace, remove single trace",
         [["a",99],LOOKUP1,false],[["a",99],["b",2],["c",3]]),
      testCase("replace again, remove single trace",
         [["c",99],LOOKUP1,false],[["c",99],["a",1],["b",2]]),
      testCase("replace, keep old",
         [["a",99],LOOKUP1,true],[["a",99],["a",1],["b",2],["c",3]]),
      testCase("undef table",[["a",1],undef,false],[["a",1]]),
      testCase("undef table and entry",[undef,undef,false],[undef]),
      testCase("scalar as table",[["a",1],5,false],[["a",1]]),
      testCase("empty table",[["a",1],[],false],[["a",1]])])
   testFunction(lookupSet($value[0],$value[1],keepOld=$value[2]));

	// LOOKUP1   = [["a",1],["b",2],["c",3]]
   // LOOKUP4   = [["a",4],["i",5],["a",6],["k",7],["a",8]]
   testSet("lookupSetMulti","direct test",[
      testCase("new, multi",
         [[["x",24],["z",42]],LOOKUP1,false],
         [["x",24],["z",42],["a",1],["b",2],["c",3]]),
      testCase("two replacements, remove single trace",
         [[["a",99],["b",88]],LOOKUP1,false],[["a",99],["b",88],["c",3]]),
		testCase("two replacements, keep old",
         [[["a",99],["b",88]],LOOKUP1,true],
			[["a",99],["b",88],["a",1],["b",2],["c",3]]),
      testCase("undef table",[[["a",1]],undef,false],[["a",1]]),
      testCase("undef table and entry",[[undef],undef,false],[undef]),
      testCase("scalar as table",[[["a",1]],5,false],[["a",1]]),
      testCase("empty table",[[["a",1]],[],false],[["a",1]])])
   testFunction(lookupSetMulti($value[0],$value[1],$value[2]));

   // LOOKUP1   = [["a",1],["b",2],["c",3]]
   // LOOKUP4   = [["a",4],["i",5],["a",6],["k",7],["a",8]]
   testSet("lookupRemove","direct test",[
      testCase("single 1",
         ["a",LOOKUP1],[["b",2],["c",3]]),
      testCase("single 2",
         ["b",LOOKUP1],[["a",1],["c",3]]),
      testCase("single 3",
         ["c",LOOKUP1],[["a",1],["b",2]]),
      testCase("unknown key",
         ["z",LOOKUP4],LOOKUP4),
      testCase("undef table",["a",undef],[]),
      testCase("undef key",[undef,LOOKUP1],LOOKUP1),
      testCase("undef table and key",[undef,undef],[]),
      testCase("scalar as table",["a",5],[]),
      testCase("empty table",["a",[]],[])])
   testFunction(lookupRemove($value[0],$value[1]));

	// LOOKUP1   = [["a",1],["b",2],["c",3]]
   // LOOKUP4   = [["a",4],["i",5],["a",6],["k",7],["a",8]]
   testSet("lookupRemoveMulti","direct test",[
      testCase("multi 1",
         [["a","b"],LOOKUP1],[["c",3]]),
      testCase("multi 2",
         [["b","c"],LOOKUP1],[["a",1]]),
      testCase("multi 3",
         [["c","a"],LOOKUP1],[["b",2]]),
      testCase("all",
         [["a","b","c"],LOOKUP1],[]),
      testCase("unknown key",
         [["z"],LOOKUP4],LOOKUP4),
      testCase("undef table",[["a"],undef],[]),
      testCase("undef key",[undef,LOOKUP1],LOOKUP1),
      testCase("undef table and key",[undef,undef],[]),
      testCase("scalar as table",[["a"],5],[]),
      testCase("scalar as key list",[5,LOOKUP1],LOOKUP1),
      testCase("empty table",[["a"],[]],[])])
   testFunction(lookupRemoveMulti($value[0],$value[1]));

	// test_lookupMap1(key,value) = value*2
	// test_lookupMap2(key,value) = (value<5) ? undef : value/2;
	// LOOKUP6   = [[10,3],[20,7],[30,4],[40,6],[50,5]]
	testSet("lookupMap","direct test",[
      testCase("normal 1",["test_lookupMap1",LOOKUP6],
			[[10,6],[20,14],[30,8],[40,12],[50,10]]),
		testCase("normal 2, with removals",["test_lookupMap2",LOOKUP6],
			[[20,3.5],[40,3],[50,2.5]]),
      testCase("undef table",["test_lookupMap1",undef],[]),
		testCase("empty table",["test_lookupMap1",[]],[]),
		testCase("unregistered function",["zzz",LOOKUP6],LOOKUP6)])
   testFunction(lookupMap($value[0],$value[1]));

	// LOOKUP7 = [[10,3],[20,undef],[30,4],[40,undef],[50,5]]
	testSet("lookupFilter","direct test",[
      testCase("normal",[LOOKUP7],[[10,3],[30,4],[50,5]]),
      testCase("undef table",[undef],[]),
		testCase("empty table",[[]],[])])
   testFunction(lookupFilter($value[0]));

	// LOOKUP_A  = [["a",5],["b",2],["c",3]]
   // LOOKUP_B  = [["a",2],["b",9],["c",12]]
   // LOOKUP_C  = [["a",1],["b",0],["c",8]]
   // LIST_ABC  = [LOOKUP_A,LOOKUP_B,LOOKUP_C]
   //
   // Messages expected: WARNING: search term not found: "z"
   //
   testSet("search","direct test (using key)",[
      testCase("property 1 value 1",[5,LIST_ABC,"a"],[0]),
      testCase("property 1 value 2",[2,LIST_ABC,"a"],[1]),
      testCase("property 1 value 3",[1,LIST_ABC,"a"],[2]),
      testCase("property 2 value 1",[2,LIST_ABC,"b"],[0]),
      testCase("property 2 value 2",[9,LIST_ABC,"b"],[1]),
      testCase("property 2 value 3",[0,LIST_ABC,"b"],[2]),
      testCase("property 3 value 1",[3,LIST_ABC,"c"],[0]),
      testCase("property 3 value 2",[12,LIST_ABC,"c"],[1]),
      testCase("property 3 value 3",[8,LIST_ABC,"c"],[2]),
      testCase("unknown key",[8,LIST_ABC,"z"],[]),
      testCase("no matching value",[20,LIST_ABC,"a"],[]),
      testCase("undef list",[8,undef,"a"],[]),
      testCase("scalar as list",[8,5,"a"],[]),
      testCase("empty list",[8,[],"a"],[])])
   testFunction(search($value[0],$value[1],key=$value[2]));

   // LOOKUP_A  = [["a",5],["b",2],["c",3]]
   // LOOKUP_B  = [["a",2],["b",9],["c",12]]
   // LOOKUP_C  = [["a",1],["b",0],["c",8]]
   // LIST_ABC  = [LOOKUP_A,LOOKUP_B,LOOKUP_C]
   //
   // Messages expected: WARNING: search term not found: "z"
   //
   testSet("sort","direct test (using key)",[
      testCase("property 1, ascending",[LIST_ABC,false,"a"],
         [LOOKUP_C,LOOKUP_B,LOOKUP_A]),
      testCase("property 1, descending",[LIST_ABC,true,"a"],
         [LOOKUP_A,LOOKUP_B,LOOKUP_C]),
      testCase("property 2, ascending",[LIST_ABC,false,"b"],
         [LOOKUP_C,LOOKUP_A,LOOKUP_B]),
      testCase("property 2, descending",[LIST_ABC,true,"b"],
         [LOOKUP_B,LOOKUP_A,LOOKUP_C]),
      testCase("property 3, ascending",[LIST_ABC,false,"c"],
         [LOOKUP_A,LOOKUP_C,LOOKUP_B]),
      testCase("property 3, descending",[LIST_ABC,true,"c"],
         [LOOKUP_B,LOOKUP_C,LOOKUP_A]),
      testCase("unknown key",[LIST_ABC,false,"z"],LIST_ABC),
      testCase("undef list",[undef,false,"a"],[]),
      testCase("scalar as list",[5,false,"a"],[]),
      testCase("empty list",[[],false,"a"],[])])
   testFunction(sort($value[0],$value[1],key=$value[2]));

// end of test group
}
