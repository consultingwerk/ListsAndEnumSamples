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
    File        : InvalidTypeException
    Purpose     : An error object thrown to signal invalid types
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Thu Apr 28 14:04:34 CEST 2011
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{Consultingwerk/products.i}

USING Consultingwerk.Exceptions.* FROM PROPATH .
USING Progress.Lang.*             FROM PROPATH .

CLASS Consultingwerk.Exceptions.InvalidTypeException 
    INHERITS Exception 
    {&SERIALIZABLE}: 

    /*------------------------------------------------------------------------------
        Purpose: Returns the (WIDGET-)TYPE that was expected by the code raising this
                 error                                                                      
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY ExpectedType AS CHARACTER NO-UNDO 
    GET.
    PROTECTED SET. 

    /*------------------------------------------------------------------------------
        Purpose: Returns the (WIDGET-)TYPE that was received by the code raising this
                 error                                                                      
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY Type AS CHARACTER NO-UNDO 
    GET.
    PROTECTED SET. 

    /*------------------------------------------------------------------------------
        Purpose: Constructor of the InvalidTypeException class                                                                       
        Notes:                                                  
        @param pcExpectedType The expected type
        @param pcType The current type                      
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidTypeException (pcExpectedType AS CHARACTER,
                                             pcType AS CHARACTER):
        
        SUPER (SUBSTITUTE ("Type &1 should be &2."{&TRAN}, pcType, pcExpectedType), 0).
        
        ASSIGN THIS-OBJECT:ExpectedType = pcExpectedType 
               THIS-OBJECT:Type         = pcType
               . 
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor of the InvalidTypeException class                                                                    
        Notes:                                                  
        @param poInnerException The reference to the original error
        @param pcExpectedType The expected type
        @param pcType The current type                    
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidTypeException (poInnerException AS Error,
                                             pcExpectedType AS CHARACTER,
                                             pcType AS CHARACTER):
        
        SUPER (poInnerException,
               SUBSTITUTE ("Type &1 should be &2."{&TRAN}, 
                           pcType, 
                           pcExpectedType), 
               0).
        
        ASSIGN THIS-OBJECT:ExpectedType = pcExpectedType 
               THIS-OBJECT:Type         = pcType
               . 
        
    END CONSTRUCTOR.

END CLASS.
