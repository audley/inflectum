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

include <value.scad>
include <common.scad>

/*
	To test some of the complex functions and modules, the following set of
	modules and functions were created. The main output of these modules is just
	console output (via echo()). Color coding and formatting tags have been used
	to enhance the output appearance. For the testing of modules, objects will
	be created, with the checks done manually.

	Functions:
		function testCase(desc,values,expect=undef)
		function testFormatHTML(value,quotes=true)
		function testFormatList(list,quotes=true)
		function testFormattedStatus(name,clr)
	Modules:
		module testErrorMessage(message)
		module testDetails(name,details)
		module testGroup(name)
		module testSet(name,desc,testCases)
		module testFunction(result)
		module testModule(offsetStart,offsetStep)

	//////// OVERVIEW ////////

	To start off, tests must be whithin a test group. There can be more than
	one group if need be. The tests are passed as children to testGroup():

		testGroup(<name>)
		{
			// tests...
		}

	Each test group must be given a name. To allow functions and modules to be
	tested multiple times with different arguments, test cases are used. To do
	so, a test-case set must be created using testSet(). Such a set must be
	part of a test group:

		testGroup(...)
		{
			testSet(<name>,<description>,<test cases>)
				// ...
		}

	More than test set can be present in a test group. Each set must be given
	the name of the function/module being tested, a short description, and a
	list of test cases. The test cases are passed to the testSet() module,
	passed as a vector of cases, where each case must be created by testCase():

		testGroup(...)
		{
			testSet(...,
				[testCase(<description>,<values>,<expect>),
				 testCase(...),...])
				// ...
		}

	The testCase() function must be given a unique short description
	(as a way to identify the individual test case), the values of the
	arguments to use (specified as a vector of values), and an expected value
	(for a function) or description of what is expected (for a module).

	Arguments do not strictly have to be used for the module/function being
	tested. Other functions may be used for the arguments, or the main function
	may be used as an argument for another function or a module. For functions,
	the expected value will be compared to the value passed to the
	testFunction() module (which does not have to be directly from the main
	function being tested), and a message showing OK/FAIL will be displayed
	according to whether the values matched or not. For modules, the expected-
	description applies to the final output, which may be as a result of parent
	modules using the main module being tested, or children being passed.

	To get the test set to test a function, testFunction() must be passed as a
	child to testSet():

		testGroup(...)
		{
			testSet(...,
				[testCase(...),testCase(...),...])
				testFunction(<result>);
		}

	To check the function, the result must be passed as an argument to
	testFunction(). The result does not directly have to be as a result of the
	function being tested. The arguments for the function must be obtained by
	accessing the $value vector, which contains a list of values (corresponding
	to the values for the test case):

		testGroup(...)
		{
			testSet(...,[testCase(...),testCase(...),...])
				testFunction(someFunction($value[0],$value[1],...));
		}

	If the result of the function does not match the expected value for a test
	case, a FAIL status will be shown, along with the details on what values
	were passed, the value returned and the expected value. Otherwise, if the
	result matches, an OK status is shown.

	To get a test set to test a module, testModule() must be passed as a child to
	testSet():

		testGroup(...)
		{
			testSet(...,[testCase(...),testCase(...),...])
				testModule(<offset start>,<offset step>)
				{
					// ...
				}
		}

	Because the result of calling testModule() will be the construction of
	geometry, a start and stepping amount for offsets must be passed to
	testModule() so that the constructed objects do not overlap and are
	spaced out. These offsets can be for 2D or 3D translation. The arguments
	for the module must be obtained by accessing the $value vector:

		testGroup(...)
		{
			testSet(...,[testCase(...),testCase(...),...])
				testModule([...],[...])
				{
					someModule($value[0],$value[1],...);
				}
		}

	Checks must be done manually to check whether module tests were successful
	or not. Using testModule(), the values and expected-result description are
	displayed (in the console) to help with the process. Additional geometry may
	also be used as a form of reference geometry.
*/

/******************************************************************************
                 F O R M A T T I N G   F U N C T I O N S
******************************************************************************/

/*
	A function to replace any special html characters with escaped versions in a
	given string, or return a value as a string. If the value is a string, an
	extra argument (set to false) can be passed to make the returned string
	exclude surrounding quotation marks.

	Character replacement is as follows:

		 character | escaped-form replacement
		-----------+---------------------------------
		    <      |  &lt;     (less than)
		    >      |  &gt;     (greater than)
		  (space)  |  &nbsp;   (non-breaking space)

	Escape sequences are allowed.
*/
function testFormatHTML(value,quotes=true) = _
(
	// if the value is not a vector or string
	/*
		If the value is not a vector or string, return the string form of the
		value. No special html characters should be present in the value.
	*/
	IF (len(value)==undef) ? THEN (str(value))
	/*
		If the value is a vector
	*/
	:ELSE_IF (len(value)>=0 && !isString(value)) ? 
		/*
			Go through and connect together each formatted element (with
			separating commas) with enclosing brackets added
		*/
		THEN (str("[",testFormatList(value,quotes),"]"))

	// otherwise, if the value is a string
	:ELSE (

		// if quotation marks are to be included
		IF (quotes) ?
			// format the string with added quotation marks (escaped form)
			THEN (str("&quot;",_testFormatHTML(value,0),"&quot;"))
		// otherwise, if quotation marks are not to be included
		:ELSE
			// format the string with no added quotation marks
			(_testFormatHTML(value,0))
	)
);
/*
	Sub-function which goes through a string and replaces special html
	characters with escaped forms. This includes replacing spaces with
	non-breaking spaces. Escape sequences (&...;) are allowed though.
*/
function _testFormatHTML(string,i) = _
(
	// if we have gone past the last character, finish off with a null
	// character
	IF (i>=len(string)) ? THEN ("")

	// otherwise, if we are not past the end yet
	:ELSE
	(
		// get the processed/replaced character
		$processed = _
		(
			// if less-than sign, use escaped form
			IF (string[i] == "<") ? THEN ("&lt;")
			// if greater-than sign, use escaped form
			:ELSE_IF (string[i] == ">") ? THEN ("&gt;")
			// if space, replace with non-breaking space (escaped form)
			:ELSE_IF (string[i] == " ") ? THEN ("&nbsp;")
			// otherwise, if not a special character, just use character
			:ELSE (string[i])
		),
		// return the modified character prepended to the rest
		RETURN (str($processed,_testFormatHTML(string,i+1)))
	)
);

/*
	A function to return a formatted string showing a list of values (from a
	vector) in the form:

		value1,value2,...,valueN

	If any of the elements are a string, quotes can be made to be left out
	(not added) by setting the 'quotes' parameter to false.

	Any special HTML characters are replaced with escape sequences. Escape
	sequences are allowed.
*/
function testFormatList(list,quotes=true) = _
(
	// if the list is empty or invalid, return an null string
	IF (!(len(list)>0)) ? THEN ("")
	// otherwise, if there is at least item in the list
	:ELSE
		/*
			Pass the list to a sub-function which will go through each element
			and concatenate the string versions of the values seperated with a
			comma.
		*/
		(_testFormatList(list,quotes,0))
);
/*
	Sub-function which goes through each of the elements in the list,
	creating a formatted string.
*/
function _testFormatList(list,quotes,i) = _
(
	// if this is not the last element
	IF (i<(len(list)-1)) ?

		// add the element, a comma, and the rest of the list
		THEN (str(testFormatHTML(list[i],quotes),",",
			_testFormatList(list,quotes,i+1)))

	// otherwise, if this is the last element
	:ELSE
		// add the element only
		(str(testFormatHTML(list[i],quotes)))
);

/*
	Returns a string containing html tags to format a status indication
	(OK/MANUAL/FAIL). Takes the message that will be shown and the color
	to show it in.
*/
function testFormattedStatus(name,clr) = 
	str("<font color=",clr,"><big><b>",name,"</b></big></font>");

/*
	Module to display an error message.
*/
module testErrorMessage(message)
{
	echo(str("<font color=red><b>ERROR: ",
		testFormatHTML(message,quotes=false),"</b></font>"));
}

/*
	Module to display extra details (such as information to help fix a FAIL or
	provide details on what was passed and is expected). Shows the details
	in a blue font with an added line prefix.
*/
module testDetails(name,details)
{
	echo(str("<font color=blue>&gt;&gt; ",
		name,":<code> ",details,"</code></font>"));
}

/******************************************************************************
            T E S T I N G   M O D U L E S   &   F U N C T I O N S
******************************************************************************/

/*
	Creates a test group of a given name, where the children passed to this
	module would be test sets. The main role of this module is to group a
	collection of sets, where this module creates a group header (console
	output), and goes through each of the child test sets, adding empty lines
	to space-out/separate console-output.
*/
module testGroup(name)
{
	// print test-group header
	echo();
	echo(str("<big><b><u>*** Test Group: ",name," ***</u></b></big>"));
	echo();

	// create the children
	children();
}

/*
	A module to run a series of tests for a function/module, given the function/
	module's name, a description, and the test cases. The test cases are
	specified as a vector of cases, where each case can be constructed using the
	testCase() function.

	This module sets up some dynamic-scoped variables (automatically passed on
	to the child test module), including those for each test case, passing along
	the input values, case description and expected result.
*/
module testSet(name,desc,testCases)
{
	// create sub-title and display description for the test set
	echo(str("<b>Test Set for<code> ",name,"<code></b>"));
	echo(str("<i>Description: ",desc,"</i>"));

	// if there are any test cases
	if (len(testCases)>0)

		// go through the test cases
		for (i = [0:len(testCases)-1])
	
			// set some args that will be passed to the child (automatically)
			assign($testIndex  = i,                    // number of test
			       $value      = testCases[i][1],      // value list
			       $expected   = testCases[i][2],      // expected result
			       $desc       = testCases[i][0],      // case description
                $valueStr   = testFormatList(testCases[i][1]))
	
			// create/run test case
			child(0);

	// leave empty line at end of set output
	echo();
	
}

/*
	Function which constructs a test case, for use in the vector passed to the
	testSet() function. Each case must be given a small description
	(desc) and the values (as a vector) that will be used as arguments. The
	expected value must also be specified, where for functions this would be
	the intended value returned by the function, or a description of the
	intended constructed geometry for a module. The expected result
	description for modules is optional.
*/
function testCase(desc,values,expect=undef) = [desc,values,expect];

/*
	A test module to compare the result returned from the function with the
	expected value, and report the details via console output (echo()). This
	module deals with printing the success-status of the function call, and
	displaying further details to help fix any problems. 

	Because the values from the test case are passed down (from the
	testSet() module) due to their dynamic scope, the function can
	retrieve the values to use as arguments by using the $value list:

		testFunction(someFunction($value[0],$value[1]))

	where someFunction is the function being tested, and $value[0] and $value[1]
	are the first and second arguments for the function respectively. Any
	number of arguments can be taken from the $value list, as long as they
	are specified in the test case. If something needs to be optionally omitted,
	use the default value for the parameter, or use 'undef'.

	This module obtains the result from the function as an explicit parameter.
	On the other hand, it gets the expected result (as well as the parameter
	name and value list) implicitly from the dynamicaly-scoped variables
	that are passed on from the testSet() function.

	Because some calculations may not result in exactly the same value as
	expected, an optional boolean flag may be set to true to force a manual
	check. 
*/
module testFunction(result,manual=false)
{
	// constants to help construction of the messages displayed
	SUCCESSFUL = result == $expected; // was the function successful?
	STATUS =
		// if the check is manual, use a "manual" message
		(manual==true) ? testFormattedStatus("MANUAL","orange")
		// if the result was successful, use a "OK" message
		:(SUCCESSFUL) ? testFormattedStatus("OK","green")
		// otherwise, if the result was unsuccessful, use "FAIL" message
	   : testFormattedStatus("FAIL","red");

	// display whether the function was a success or not
	echo(str("Testing - ",$desc,"... ",STATUS));

	// if the test failed or manual checking is being used
	if (SUCCESSFUL==false || manual==true)
	{
		// display the values, result and what the result should of been
		if (manual==false) testDetails("Values",$valueStr);
		testDetails("Result",testFormatHTML(result));
		testDetails("Expected",testFormatHTML($expected));
	}
}

/*
	A test module to compare the geometry produced by a module for each of the
	test cases. This module displays the list of values used for the test case
	and a description of what output is expected, as well as constructing the
	child geometry. 

	Because the values of the test case are passed down (from the testSet()
	module) due to their dynamic scope, the module being tested (as a child of
	testModule()) can retrieve the arguments by using the $value list, like the
	following:

		testModule(<offset start>,<offset step>)
		{
			someModule($value[0],$value[1]);
			//...
		}

	where someModule is the module being tested, and $value[0] and $value[1]
	are the first and second arguments for the module respectively. Any
	number of arguments can be taken from the $value list, as long as they
	are specified in the test case. If something needs to be optionally omitted,
	use the default value for the parameter, or use 'undef'.

	This module is passed a starting and step offset that are used to space out
	the output of the tests. Additional geometry (reference geometry) can be
	created in addition to the main geometry being tested. Using colors
	(via color()) may also help in testing the modules.
*/
module testModule(offsetStart,offsetStep)
{
	// work out the offset to use
	OFFSET = offsetStart + offsetStep*$testIndex;

	// if the offset is not a 2D or 3D offset
	if (!(len(OFFSET)==2 || len(OFFSET)==3))

		// show an error message
		testErrorMessage("bad offset.");

	// otherwise, if the offset is ok...
	else translate(OFFSET)
	{
		// display a "testing" message
		echo(str("Testing - ",$desc,"..."));
	
		// display the values, display position (offset), and expected result
		testDetails("Values",$valueStr);
		testDetails("Offset",OFFSET);
		if (len($expected)>0) testDetails("Expected",$expected);
	
		// create geom for current test case
		children();
	}
}
