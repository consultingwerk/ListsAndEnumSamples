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
    File        : InvalidParameterValueException
    Purpose     : An error object thrown to signal invalid parameter values 
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwer Ltd.
    Created     : Sun Feb 17 09:48:56 CET 2008
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW .

{Consultingwerk/products.i}

USING Consultingwerk.Exceptions.* FROM PROPATH .
USING Progress.Lang.*             FROM PROPATH .

CLASS Consultingwerk.Exceptions.InvalidParameterValueException 
    INHERITS Exception 
    {&SERIALIZABLE}: 
    
    /*------------------------------------------------------------------------------
        Purpose: Returns the name of the invalid parameter
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY ParameterName AS CHARACTER 
    GET.
    PRIVATE SET.
    
    /*------------------------------------------------------------------------------
        Purpose: Returns the value of the invalid parameter
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY ParameterValue AS CHARACTER 
    GET.
    PRIVATE SET.

    /*------------------------------------------------------------------------------
        Purpose: Returns the class name that caused the InvalidParameterException
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY ClassName AS CHARACTER 
    GET.
    PRIVATE SET.    
    
    /*------------------------------------------------------------------------------
        Purpose: Constructor of the InvalidParameterException class
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidParameterValueException ():

        SUPER ("The parameter value is invalid."{&TRAN}, 0).
    
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor of the InvalidParameterException class
        Notes:                                                                        
        @param poInnerException The reference to the original error
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidParameterValueException (poInnerException AS Error):

        SUPER (poInnerException,
               "The parameter value is invalid."{&TRAN}, 
               0).
    
    END CONSTRUCTOR.

    
    /*------------------------------------------------------------------------------
        Purpose: Constructor of the InvalidParameterException class
        Notes:                                                                        
        @param pcParameterName The name of the invalid parameter
        @param pcValue The invalid parameter name
        @param pcClassName The name of the class that caused the InvalidParameterException
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidParameterValueException (pcParameterName AS CHARACTER,
                                                       pcValue         AS CHARACTER,
                                                       pcClassName     AS CHARACTER ):

        SUPER (SUBSTITUTE("The parameter value '&2' for &1 in &3 is invalid."{&TRAN}, 
                          pcParameterName, pcValue, pcClassName), 0).
           
        ASSIGN ParameterName  = pcParameterName
               ParameterValue = pcValue 
               ClassName      = pcClassName .           
           
    END CONSTRUCTOR.
    
    /*------------------------------------------------------------------------------
        Purpose: Constructor of the InvalidParameterException class
        Notes:                                                                        
        @param poInnerException The reference to the original error
        @param pcParameterName The name of the invalid parameter
        @param pcValue The invalid parameter name
        @param pcClassName The name of the class that caused the InvalidParameterException
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC InvalidParameterValueException (poInnerException AS Error,
                                                       pcParameterName  AS CHARACTER,
                                                       pcValue          AS CHARACTER,
                                                       pcClassName      AS CHARACTER ):

        SUPER (SUBSTITUTE("The parameter value '&2' for &1 in &3 is invalid."{&TRAN}, 
                          pcParameterName, pcValue, pcClassName), 0).
           
        ASSIGN ParameterName  = pcParameterName
               ParameterValue = pcValue 
               ClassName      = pcClassName .           
           
    END CONSTRUCTOR.

END CLASS.
