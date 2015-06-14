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
    File        : EventArgs
    Purpose     : Generic event argument class
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Sat Dec 19 15:09:13 CET 2009
    Notes       : The SmartComponent Library does as of February 2012
                  by default use the .NET System.EventArgs instead of 
                  Consultingwerk.EventArgs as in OpenEdge 11.0 the Visual 
                  Designer causes serious issues when editing components 
                  that use non .NET derived objects as event arguments.
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Progress.Lang.* FROM PROPATH .

CLASS Consultingwerk.EventArgs:

    DEFINE PRIVATE STATIC VARIABLE oEmpty AS Consultingwerk.EventArgs NO-UNDO . 

    /*------------------------------------------------------------------------------
        Purpose: Returns the default instance of the Consultingwerk.EventArgs class                                                                     
        Notes:   
    ------------------------------------------------------------------------------*/    
    DEFINE PUBLIC STATIC PROPERTY Empty AS Consultingwerk.EventArgs NO-UNDO 
    GET:
        IF NOT VALID-OBJECT (oEmpty) THEN
            oEmpty = NEW Consultingwerk.EventArgs () .
             
        RETURN oEmpty . 
    END GET.

END CLASS.
