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
    File        : InvalidValueException
    Purpose     : An error object thrown to signal invalid (parameter) values
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Mon Apr 25 23:20:48 CEST 2011
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{Consultingwerk/products.i}

USING Consultingwerk.Exceptions.* FROM PROPATH .
USING Progress.Lang.*             FROM PROPATH .

CLASS Consultingwerk.Exceptions.InvalidValueException 
    INHERITS Exception
    {&SERIALIZABLE}:  

    /*------------------------------------------------------------------------------
        Purpose: Returns the Descriotion for the Value that caused this InvalidValueException                                                                     
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY Description AS CHARACTER NO-UNDO 
    GET.
    PROTECTED SET. 

    /*------------------------------------------------------------------------------
        Purpose: Returns the Value that caused this InvalidValueException                                                                     
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY Value AS CHARACTER NO-UNDO 
    GET.
    PROTECTED SET. 

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the InvalidValueException class                                                                        
        Notes:          
        @param pcValue The invalid value                                                              
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidValueException (pcValue AS CHARACTER):
        
        SUPER (SUBSTITUTE ("Invalid value ~"&1~".", pcValue), 0).

        THIS-OBJECT:Value = pcValue . 
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the InvalidValueException class                                                                      
        Notes:          
        @param pcValue The invalid value    
        @param pcDescription The description of the invalid value                                                          
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidValueException (pcValue AS CHARACTER,
                                              pcDescription AS CHARACTER):
        
        SUPER (SUBSTITUTE ("Invalid value ~"&1~" for &2.", pcValue, pcDescription), 0).

        THIS-OBJECT:Value = pcValue .
        THIS-OBJECT:Description = pcDescription . 
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the InvalidValueException class                                                                      
        Notes:          
        @param poInnerException The reference to the original error
        @param pcValue The invalid value  
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidValueException (poInnerException AS Error, 
                                              pcValue AS CHARACTER):
        
        SUPER (poInnerException,
               SUBSTITUTE ("Invalid value ~"&1~".", pcValue), 
               0).

        THIS-OBJECT:Value = pcValue . 
        
    END CONSTRUCTOR.
    
    /*------------------------------------------------------------------------------
        Purpose: Constructor for the InvalidValueException class                                                                      
        Notes:          
        @param poInnerException The reference to the original error
        @param pcValue The invalid value  
        @param pcDescription The description of the invalid value                                                          
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidValueException (poInnerException AS Error, 
                                              pcValue AS CHARACTER,
                                              pcDescription AS CHARACTER):
        
        SUPER (poInnerException,
               SUBSTITUTE ("Invalid value ~"&1~" for &2.", pcValue, pcDescription), 
               0).

        THIS-OBJECT:Value = pcValue . 
        THIS-OBJECT:Description = pcDescription . 
        
    END CONSTRUCTOR.    
    
END CLASS.
