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
    File        : Environment
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Wed Jan 09 23:02:13 CET 2013
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.* FROM PROPATH .  
USING Progress.Lang.*  FROM PROPATH .

{Consultingwerk/products.i}

CLASS Consultingwerk.Environment: 

    /*------------------------------------------------------------------------------
        Purpose: Returns the NewLine character on the current platform
        Notes:   
    ------------------------------------------------------------------------------*/
	DEFINE PUBLIC STATIC PROPERTY NewLine AS CHARACTER NO-UNDO 
	GET.
	PRIVATE SET. 

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the Environment class
        Notes:   
    ------------------------------------------------------------------------------*/
	CONSTRUCTOR STATIC Environment ():
		
&IF DEFINED (DotNetAccessible) NE 0 &THEN
        /* Mike Fechner, Consultingwerk Ltd. 21.05.2014
           10.2B Windows compiled code running on the AppServer will raise this
           error here when accessing System.Environmet:NewLine
           Error attempting to push run time parameters onto the stack. (984) */
        IF PROVERSION = "10.2B":U AND SESSION:REMOTE THEN 
            ASSIGN Consultingwerk.Environment:NewLine = "~n":U .
        ELSE 
            ASSIGN Consultingwerk.Environment:NewLine = System.Environment:NewLine .
&ELSE
        ASSIGN Consultingwerk.Environment:NewLine = "~n":U .  
&ENDIF		
		
	END CONSTRUCTOR.

END CLASS.
