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
    File        : BufferAssert
    Purpose     : Provides generic methods for validating of BUFFER object handles
    Syntax      : 
    Description : Routines in this class typically raise an error condition
                  when the condition is not met.
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Wed Jul 20 00:41:51 CEST 2011
    Notes       : Static methods, throw error on failed test.
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{Consultingwerk/products.i}

USING Consultingwerk.*            FROM PROPATH . 
USING Consultingwerk.Assertion.*  FROM PROPATH .
USING Consultingwerk.Exceptions.* FROM PROPATH .
USING Consultingwerk.Util.*       FROM PROPATH . 
USING Progress.Lang.*             FROM PROPATH .

CLASS Consultingwerk.Assertion.BufferAssert: 
    
    /*------------------------------------------------------------------------------
        Purpose: Disallow instance creation.                                                                       
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE BufferAssert ():
        SUPER ().
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Verifies the data type of a buffer field 
        Notes:   Verifies first, that the buffer field exists  
        @param phBuffer The Buffer handle to test
        @param pcFieldName The name of the buffer field                                                                  
        @param pcDataTypes The comma delimited list of valid data type 
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC VOID FieldDataType (phBuffer AS HANDLE,
                                             pcFieldName AS CHARACTER,
                                             pcDataTypes AS CHARACTER):
		
		DEFINE VARIABLE hField AS HANDLE NO-UNDO.
		
        BufferAssert:HasField (phBuffer, pcFieldName) .

        ASSIGN hField = phBuffer:BUFFER-FIELD (pcFieldName) .

        IF NOT ListHelper:EntryIsInList (hField:DATA-TYPE, pcDataTypes) THEN 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("The buffer field &1.&2 is not of type &3."{&TRAN},
                                                         phBuffer:NAME, 
                                                         pcFieldName,
                                                         pcDataTypes), 
                                             0) .

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Verifies that the passed in buffer handle has a field with the 
                 given name                                                                       
        Notes:   Verifies that a valid buffer is passed in first.
        Throws:  Consultingwerk.Assertion.AssertException 
        @param phBuffer The Buffer handle to test
        @param pcFieldName The name of the buffer field                                                                  
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID HasField (phBuffer AS HANDLE,
                                        pcFieldName AS CHARACTER):
        
        HandleAssert:WidgetType (phBuffer, WidgetTypeEnum:Buffer) .

        IF NOT Consultingwerk.Util.BufferHelper:HasField (phBuffer, 
                                                          pcFieldName) THEN
                                                          
            UNDO, THROW NEW AssertException (SUBSTITUTE ("The buffer &1 has no field named &2."{&TRAN},
                                                         phBuffer:NAME, 
                                                         pcFieldName), 
                                             0) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Verifies the a record is available in that Buffer                                                                        
        Notes:   Verifies that a valid buffer is passed in first.                                                      
        Throws:  Consultingwerk.Assertion.AssertException 
        @param phBuffer The handle of the Buffer to verify                  
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID IsAvailable (phBuffer AS HANDLE):
        
        HandleAssert:WidgetType (phBuffer, WidgetTypeEnum:Buffer) .

        IF NOT phBuffer:AVAILABLE THEN 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("No record is available in buffer &1."{&TRAN},
                                                         phBuffer:NAME),
                                             0) .  
    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Verifies that the passed in buffer handle is a buffer for a database
                 table (not a temp-table buffer)                                                                        
        Notes:                  
        Throws:  Consultingwerk.Assertion.AssertException 
        @param phBuffer The Buffer handle to verify                                                   
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC VOID IsDatabaseBuffer (phBuffer AS HANDLE):
		
        HandleAssert:WidgetType (phBuffer, WidgetTypeEnum:Buffer) .
		
        IF NOT BufferHelper:IsDatabaseBuffer (phBuffer) THEN 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("The Buffer &1 is not a database buffer."{&TRAN}, 
                                                         phBuffer:NAME),
                                             0) .

	END METHOD .

	/*------------------------------------------------------------------------------
		Purpose: Verifies that the passed in buffer handle belongs to a ProDataset 
		         member buffer  																	  
		Notes:  				
        Throws:  Consultingwerk.Assertion.AssertException 
		@param phBuffer The Buffer handle to verify													  
	------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC VOID IsDatasetBuffer (phBuffer AS HANDLE):
		
        HandleAssert:WidgetType (phBuffer, WidgetTypeEnum:Buffer) .

        IF NOT VALID-HANDLE (phBuffer:DATASET) THEN 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("The Buffer &1 is not member of a ProDataset."{&TRAN}, 
                                                         phBuffer:NAME),
                                             0) .
        
	END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Verifies that the passed in buffer handle belongs to a temp-table                    
        Notes:                  
        Throws:  Consultingwerk.Assertion.AssertException 
        @param phBuffer The Buffer handle to verify                                                   
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID IsTempTableBuffer (phBuffer AS HANDLE):
        
        HandleAssert:WidgetType (phBuffer, WidgetTypeEnum:Buffer) .

        IF NOT VALID-HANDLE (phBuffer:TABLE-HANDLE) THEN 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("The Buffer &1 is not buffer of a temp-table."{&TRAN}, 
                                                         phBuffer:NAME),
                                             0) .
        
    END METHOD.
    
END CLASS.
