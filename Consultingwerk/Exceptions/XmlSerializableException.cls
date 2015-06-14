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
    File        : XmlSerializableException
    Purpose     : Exception thrown by the XmlSerialable class during 
                  serialization and deserialization 
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Sat Mar 14 13:27:00 CET 2015
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW .

USING Consultingwerk.Exceptions.* FROM PROPATH .
USING Progress.Lang.*.

CLASS Consultingwerk.Exceptions.XmlSerializableException    
    INHERITS Exception: 

    /*------------------------------------------------------------------------------
        Purpose: Returns the name of the class that caused the exception  
        Notes:   Returns the name of the actual serializable class (child of 
                 XmlSerializable)                                          
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY ClassName AS CHARACTER NO-UNDO 
    GET.
    PRIVATE SET. 

    /*------------------------------------------------------------------------------
        Purpose: Returns the name of the property that caused the exception  
        Notes:                          
    ------------------------------------------------------------------------------*/
	DEFINE PUBLIC PROPERTY PropertyName AS CHARACTER NO-UNDO 
	GET.
	PRIVATE SET. 

    /*------------------------------------------------------------------------------
        Purpose: Constructor of the XmlSerializableException class
        Notes:                          
        @param poInnerException The reference to the original error
        @param pcErrorString The error message associated with this Exception object
        @param pcClassName The name of the class that caused the exception
        @param pcPropertyName The name of the property that caused the exception
    ------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC XmlSerializableException (poInnerException AS Progress.Lang.Error, 
	                                             pcErrorString AS CHARACTER,
	                                             pcClassName AS CHARACTER,
	                                             pcPropertyName AS CHARACTER):
	                                                 
		SUPER (poInnerException, pcErrorString).
		
        ASSIGN THIS-OBJECT:ClassName    = pcClassName 
               THIS-OBJECT:PropertyName = pcPropertyName .

	END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor of the XmlSerializableException class
        Notes:                          
        @param poInnerException The reference to the original error
        @param pcErrorString The error message associated with this Exception object
        @param piMessageNumber The error message number associated with this Exception object
        @param pcClassName The name of the class that caused the exception
        @param pcPropertyName The name of the property that caused the exception
    ------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC XmlSerializableException (poInnerException AS Progress.Lang.Error, 
	                                             pcErrorString AS CHARACTER, 
	                                             piMessageNumber AS INTEGER,
	                                             pcClassName AS CHARACTER,
                                                 pcPropertyName AS CHARACTER):
                                                     
		SUPER (poInnerException, pcErrorString, piMessageNumber).

        ASSIGN THIS-OBJECT:ClassName    = pcClassName 
               THIS-OBJECT:PropertyName = pcPropertyName .
		
	END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor of the XmlSerializableException class
        Notes:                          
        @param poInnerException The reference to the original error
        @param pcClassName The name of the class that caused the exception
        @param pcPropertyName The name of the property that caused the exception
    ------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC XmlSerializableException (poInnerException AS Progress.Lang.Error,
	                                             pcClassName AS CHARACTER,
                                                 pcPropertyName AS CHARACTER):
                                                     
		SUPER (poInnerException).

        ASSIGN THIS-OBJECT:ClassName    = pcClassName 
               THIS-OBJECT:PropertyName = pcPropertyName .
		
	END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor of the XmlSerializableException class
        Notes:                          
        @param pcErrorString The error message associated with this Exception object
        @param pcClassName The name of the class that caused the exception
        @param pcPropertyName The name of the property that caused the exception
    ------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC XmlSerializableException (pcErrorString AS CHARACTER,
	                                             pcClassName AS CHARACTER,
                                                 pcPropertyName AS CHARACTER):
                                                     
		SUPER (pcErrorString).
		
        ASSIGN THIS-OBJECT:ClassName    = pcClassName 
               THIS-OBJECT:PropertyName = pcPropertyName .

	END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor of the XmlSerializableException class
        Notes:                          
        @param pcErrorString The error message associated with this Exception object
        @param piMessageNumber The error message number associated with this Exception object
        @param pcClassName The name of the class that caused the exception
        @param pcPropertyName The name of the property that caused the exception
    ------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC XmlSerializableException (pcErrorString AS CHARACTER, 
	                                             piMessageNumber AS INTEGER,
	                                             pcClassName AS CHARACTER,
                                                 pcPropertyName AS CHARACTER):
                                                     
		SUPER (pcErrorString, piMessageNumber).

        ASSIGN THIS-OBJECT:ClassName    = pcClassName 
               THIS-OBJECT:PropertyName = pcPropertyName .
		
	END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor of the XmlSerializableException class
        Notes:                          
        @param pcClassName The name of the class that caused the exception
        @param pcPropertyName The name of the property that caused the exception
    ------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC XmlSerializableException (pcClassName AS CHARACTER,
                                                 pcPropertyName AS CHARACTER):
		SUPER ().

        ASSIGN THIS-OBJECT:ClassName    = pcClassName 
               THIS-OBJECT:PropertyName = pcPropertyName .
		
	END CONSTRUCTOR.

END CLASS.
