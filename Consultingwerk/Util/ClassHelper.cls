/**********************************************************************
 The MIT License (MIT)
 
 Copyright (c) 2015 Consultingwerk Ltd.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 **********************************************************************/ 
/*------------------------------------------------------------------------
    File        : ClassHelper
    Purpose     : Class contains generic supporting routines to work 
                  with classes
    Syntax      : Static methods only, private constructor to disallow 
                  instance creation
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Mon Jul 12 20:31:09 CEST 2010
    Notes       : This file is intended for GUI for .NET only
                  The result temp-table description is in Consultingwerk/Util/TempTables/ttClassNames.i
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{ Consultingwerk/products.i }

USING Consultingwerk.Assertion.* FROM PROPATH .
USING Consultingwerk.Util.*      FROM PROPATH .  
USING Progress.Lang.*            FROM PROPATH . 

CLASS Consultingwerk.Util.ClassHelper: 
    
    /*------------------------------------------------------------------------------
        Purpose: Constructor for the ClassHelper class
        Notes:   Private default constructor                   
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE ClassHelper():
        SUPER ().
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Returns the ShortClassName for the given Class object
        Notes:   The short name is the class name without the package
        @param poClass The class to return the short name for
        @return The short name of the class
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC CHARACTER ShortClassName (poClass AS Progress.Lang.Class):
		
		DEFINE VARIABLE cFullName AS CHARACTER NO-UNDO.
		
		Consultingwerk.Assertion.ObjectAssert:IsValid (poClass, "Class":U) .
		
		ASSIGN cFullName = poClass:TypeName .
		
		RETURN ENTRY (NUM-ENTRIES (cFullName, ".":U), cFullName, ".":U) . 

	END METHOD .

END CLASS.
