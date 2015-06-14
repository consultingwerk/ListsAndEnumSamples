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
    File        : HandleAssert
    Purpose     : Static class that provide standarized validation routines
                  for (WIDGET-)HANDLE parameters.
    Syntax      : Static methods only, private constructor to disallow 
                  instance creation 
    Description : Routines in this class typically raise an error condition
                  when the condition is not met.
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Thu Apr 28 13:05:38 CEST 2011
    Notes       : Static methods, throw error on failed test.
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{Consultingwerk/products.i} 

USING Consultingwerk.Assertion.*  FROM PROPATH .
USING Consultingwerk.Exceptions.* FROM PROPATH .
USING Consultingwerk.Util.*       FROM PROPATH .
USING Progress.Lang.*             FROM PROPATH .

CLASS Consultingwerk.Assertion.HandleAssert: 
    
    /*------------------------------------------------------------------------------
        Purpose: Disallow instance creation                                                                       
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE HandleAssert ():
        SUPER ().
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Validates that a (WIDGET-)HANDLE has the given property (writable)                                                                       
        Notes:                                              
        Throws: Consultingwerk.Exceptions.AssertException
        @param phHandle The (WIDGET-)HANDLE to validate
        @param pcProperty The name of the property                            
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID CanQuery (phHandle AS HANDLE,
                                        pcProperty AS CHARACTER):
        
        HandleAssert:ValidHandle (phHandle) . 
        
        IF NOT CAN-QUERY (phHandle, pcProperty) THEN  
            UNDO, THROW NEW AssertException (SUBSTITUTE ("Property &1 can not be queried."{&TRAN}, 
                                                         pcProperty), 0) .

    END METHOD.

	/*------------------------------------------------------------------------------
		Purpose: Validates that a (WIDGET-)HANDLE has the given property (writable)  																	  
		Notes:  											
	    Throws: Consultingwerk.Exceptions.AssertException
	    @param phHandle The (WIDGET-)HANDLE to validate
	    @param pcProperty The name of the property  						  
	------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC VOID CanSet (phHandle AS HANDLE,
	                                  pcProperty AS CHARACTER):
		
        HandleAssert:ValidHandle (phHandle) . 
        
		IF NOT CAN-SET (phHandle, pcProperty) THEN  
            UNDO, THROW NEW AssertException (SUBSTITUTE ("Property &1 can not be set."{&TRAN}, 
                                                         pcProperty), 0) .

	END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Validates a (WIDGET-)HANDLE and raises an InvalidHandleException
                 when the widget is invalid                                                                      
        Notes:                              
        Throws: Consultingwerk.Exceptions.InvalidHandleException
        @param phHandle The (WIDGET-)HANDLE to validate                                          
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID ValidHandle (phHandle AS HANDLE):
        
        IF NOT VALID-HANDLE (phHandle) THEN 
            UNDO, THROW NEW InvalidHandleException () .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Validates a (WIDGET-)HANDLE and raises an InvalidHandleException
                 when the widget is invalid                                                                   
        Notes:                              
        Throws: Consultingwerk.Exceptions.InvalidHandleException
        @param phHandle The (WIDGET-)HANDLE to validate
        @param pcHandleDesc The optional description of the HANDLE used in the InvalidHandleException                                                                        
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID ValidHandle (phHandle AS HANDLE, pcHandleDesc AS CHARACTER):
        
        IF NOT VALID-HANDLE (phHandle) THEN 
            UNDO, THROW NEW InvalidHandleException (pcHandleDesc) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Validates the type of the given widget                                                                       
        Notes:                                                                  
        Throws:  Consultingwerk.Exceptions.InvalidTypeException
        @param phHandle The (WIDGET-)HANDLE to validate
        @param pcType The expected Widget TYPE      
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID WidgetType (phHandle AS HANDLE, pcType AS CHARACTER):
        
        ValidHandle (phHandle, StringHelper:CamelCaseWord (pcType)) .
        
        IF phHandle:TYPE <> pcType THEN 
            UNDO, THROW NEW InvalidTypeException (pcType, phHandle:TYPE) .

    END METHOD.

END CLASS.
