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
    File        : Const
    Purpose     : Generic framework constants 
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Tue Sep 13 10:42:23 CEST 2011
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS Consultingwerk.Const: 

    /*------------------------------------------------------------------------------
        Purpose: The list of built in ABL data types 
        Notes:   BLOB,CHARACTER,CLOB,COM-HANDLE,DATE,DATETIME,DATETIME-TZ,DECIMAL
                 HANDLE,INT64,INTEGER,LOGICAL,Progress.Lang.Object,RECID,ROWID
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC STATIC PROPERTY ABL_DATA_TYPES AS CHARACTER INITIAL 'BLOB,CHARACTER,CLOB,COM-HANDLE,DATE,DATETIME,DATETIME-TZ,DECIMAL,HANDLE,INT64,INTEGER,LOGICAL,Progress.Lang.Object,RECID,ROWID':U NO-UNDO 
    GET.
     
    /*------------------------------------------------------------------------------
        Purpose: The maximum value a 32 bit integer variable can hold
        Notes:   2147483647
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC STATIC PROPERTY MAX_INTEGER AS INTEGER NO-UNDO INIT 2147483647 
    GET.

    /*------------------------------------------------------------------------------
        Purpose: The maximum value a 64 bit integer variable can hold
        Notes:   9223372036854775807
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC STATIC PROPERTY MAX_INT64 AS INT64 NO-UNDO INIT 9223372036854775807 
    GET.

    /*------------------------------------------------------------------------------
        Purpose: The minimum value a 32 bit integer variable can hold
        Notes:   -2147483648
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC STATIC PROPERTY MIN_INTEGER AS INTEGER NO-UNDO INIT -2147483648 
    GET.
    
    /*------------------------------------------------------------------------------
        Purpose: The minimum value a 64 bit integer variable can hold
        Notes:   -9223372036854775808  
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC STATIC PROPERTY MIN_INT64 AS INT64 NO-UNDO INIT -9223372036854775808 
    GET.

    /*------------------------------------------------------------------------------
        Purpose: The longest possible delimited list pattern for a SUBSTITUTE operation                                                                       
        Notes:   &9 (ampersand 9) represents the list delimiter
                 &1&9&2&9&3&9&4&9&5&9&6&9&7&9&8
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC STATIC PROPERTY DELIMITED_LIST_FOR_SUBSTITUTE AS CHARACTER INITIAL '&1&9&2&9&3&9&4&9&5&9&6&9&7&9&8':U NO-UNDO 
    GET.

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the Const class
        Notes:   Disallow instance creation                                                                     
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE Const ():
        SUPER ().
        
    END CONSTRUCTOR.

END CLASS.
