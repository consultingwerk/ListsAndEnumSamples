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
    File        : UniqueIndexRequiredException
    Purpose     : Exception thrown by methods that rely on buffers with unique  
                  indexes
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Tue Feb 10 13:56:49 CET 2015
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{Consultingwerk/products.i}

USING Consultingwerk.Exceptions.* FROM PROPATH .
USING Progress.Lang.*             FROM PROPATH .

CLASS Consultingwerk.Util.Exceptions.UniqueIndexRequiredException 
    INHERITS Exception 
    {&SERIALIZABLE}: 
		
    /*------------------------------------------------------------------------------
        Purpose: Returns the name of the buffer that caused this exception
        Notes:                          
    ------------------------------------------------------------------------------*/
	DEFINE PUBLIC PROPERTY BufferName AS CHARACTER NO-UNDO 
	GET.
	PROTECTED SET. 

    /*------------------------------------------------------------------------------
        Purpose: Returns if the calling method did require a Primary unique index
        Notes:   
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY PrimaryRequired AS LOGICAL NO-UNDO INIT FALSE 
    GET.
    PRIVATE SET. 
    
    /*------------------------------------------------------------------------------
        Purpose: Constructor of the Exception class
        Notes:                          
        @param pcErrorString The error message associated with this Exception object
        @param pcBufferName The name of the Buffer that caused this error
    ------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC UniqueIndexRequiredException (pcErrorString AS CHARACTER,
	                                                 pcBufferName AS CHARACTER):
		SUPER (pcErrorString, 0).
		
		THIS-OBJECT:BufferName = pcBufferName . 
		
	END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor of the Exception class
        Notes:                          
        @param pcErrorString The error message associated with this Exception object
        @param piMessageNumber The error message number associated with this Exception object
        @param pcBufferName The name of the Buffer that caused this error
    ------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC UniqueIndexRequiredException (pcErrorString AS CHARACTER, 
	                                                 piMessageNumber AS INTEGER,
	                                                 pcBufferName AS CHARACTER):
		SUPER (pcErrorString, piMessageNumber).
		
        THIS-OBJECT:BufferName = pcBufferName . 
		
	END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor of the Exception class
        Notes:                          
        @param pcErrorString The error message associated with this Exception object
        @param piMessageNumber The error message number associated with this Exception object
        @param pcBufferName The name of the Buffer that caused this error
        @param plPrimaryRequired Logical value indicating if the method that caused the exception did require a primary unique index         
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC UniqueIndexRequiredException (pcErrorString AS CHARACTER, 
                                                     piMessageNumber AS INTEGER,
                                                     pcBufferName AS CHARACTER,
                                                     plPrimaryRequired AS LOGICAL):
        SUPER (pcErrorString, piMessageNumber).
        
        ASSIGN THIS-OBJECT:BufferName      = pcBufferName 
               THIS-OBJECT:PrimaryRequired = plPrimaryRequired . 
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Builds and returns a unique record identifier composed from field 
                 values of either the primary unique index or the first unqiue index
                 of the table
        Notes:   
        @param pcBufferName The name of the buffer that caused the error
        @param plPrimaryRequired Logical value indicating if the method that caused the exception did require a primary unique index 
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC UniqueIndexRequiredException (pcBufferName AS CHARACTER, 
                                                     plPrimaryRequired AS LOGICAL):
        
        SUPER (SUBSTITUTE ("The buffer &1 does not have a &2unique index"{&TRAN}, 
                           pcBufferName,
                           IF plPrimaryRequired THEN "primary ":U ELSE "":U), 0).
        
        ASSIGN THIS-OBJECT:BufferName      = pcBufferName
               THIS-OBJECT:PrimaryRequired = plPrimaryRequired . 

    END CONSTRUCTOR . 
            
END CLASS.
