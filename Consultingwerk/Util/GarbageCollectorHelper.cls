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
    File        : GarbageCollectorHelper
    Purpose     : 
    Syntax      : Static methods only, private constructor to disallow 
                  instance creation
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Wed Jan 13 23:36:38 CET 2010
    Notes       : This file is intended for GUI for .NET only
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{ Consultingwerk/products.i }

USING Consultingwerk.Util.*           FROM PROPATH . 
&IF DEFINED (DotNetAccessible) NE 0 &THEN
USING Infragistics.Win.UltraWinTree.* FROM ASSEMBLY .
USING Progress.Lang.*                 FROM ASSEMBLY .
&ENDIF

CLASS Consultingwerk.Util.GarbageCollectorHelper: 

    /*------------------------------------------------------------------------------
        Purpose: Private default constructor. 
        Notes:   There's no need to create instances of the helper classes                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE GarbageCollectorHelper ():
        SUPER ().
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Deletes an Widget handle, if valid                                                                     
        Notes:                 
        @param phWidget The handle of the widget to delete                                                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID DeleteObject (phWidget AS HANDLE):
        
        IF VALID-HANDLE (phWidget) THEN 
            DELETE OBJECT phWidget NO-ERROR .

    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Deletes an Object instance, if valid                                                                        
        Notes:  
        @param poObject The reference to the object to delete                                                                      
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID DeleteObject (poObject AS Progress.Lang.Object):
        
        IF VALID-OBJECT (poObject) THEN 
            DELETE OBJECT poObject NO-ERROR .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Deletes Object instances from an Array                                                                       
        Notes:   We have noticed a potential regression in OE11.4 CQC documented in 
                 SCL-392. It appears that passing an initialized Object[] to this method 
                 raises the runtime error: Uninitialized array used as source of assignment. 
                 (14906). We will investigate the issue in probably have to log a ticket 
                 with PSC when the issue is still present in 11.4 FCS. At this time 
                 we do not recomment to use this method.
        @param poObjects The ABL array of objects to delete                                                                     
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID DeleteObject (poObjects AS Progress.Lang.Object EXTENT):
        
        DEFINE VARIABLE i AS INTEGER NO-UNDO.
        
        DO i = 1 TO EXTENT (poObjects):
            GarbageCollectorHelper:DeleteObject (poObjects [i]) . 
        END .

    END METHOD.
    
END CLASS.
