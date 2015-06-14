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
    File        : InvalidReferenceException
    Purpose     : An error object thrown to signal an invalid widget handle
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Fri Jan 20 07:17:13 CEST 2012
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{Consultingwerk/products.i}

USING Consultingwerk.Exceptions.* FROM PROPATH .
USING Progress.Lang.*             FROM PROPATH .

CLASS Consultingwerk.Exceptions.InvalidReferenceException 
    INHERITS Exception
    {&SERIALIZABLE}: 

    /*------------------------------------------------------------------------------
        Purpose: Returns the optional description of the invalid handle                                                                       
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY ReferenceDescription AS CHARACTER NO-UNDO INIT ?
    GET.
    PROTECTED SET. 

    /*------------------------------------------------------------------------------
        Purpose: Default constructor of the InvalidReferenceException class                                                                       
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidReferenceException ():
        
        SUPER ("Invalid object reference."{&TRAN}, 0) .
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor of the InvalidReferenceException class                                                                      
        Notes:                                                                        
        @param pcDescription The Description of the invalid handle to be used in the error message
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidReferenceException (pcDescription AS CHARACTER):
        
        SUPER (SUBSTITUTE ("Invalid &1 object reference."{&TRAN}, pcDescription), 0) .
        
        THIS-OBJECT:ReferenceDescription = pcDescription .
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Default constructor of the InvalidReferenceException class                                                                       
        Notes:        
        @param poInnerException The reference to the original error
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidReferenceException (poInnerException AS Error):
        
        SUPER (poInnerException, 
               "Invalid object reference."{&TRAN}, 
               0) .
        
    END CONSTRUCTOR.
    
    /*------------------------------------------------------------------------------
        Purpose: Constructor of the InvalidReferenceException class                                                                      
        Notes:                                                                        
        @param poInnerException The reference to the original error
        @param pcDescription The Description of the invalid handle to be used in the error message
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidReferenceException (poInnerException AS Error,
                                                  pcDescription AS CHARACTER):
        
        SUPER (poInnerException, SUBSTITUTE ("Invalid &1 object reference."{&TRAN}, pcDescription), 0) .
        
        THIS-OBJECT:ReferenceDescription = pcDescription .
        
    END CONSTRUCTOR.
    
END CLASS.
