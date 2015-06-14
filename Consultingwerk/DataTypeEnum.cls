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
    File        : DataTypeEnum
    Purpose     : DATA-TYPE Constants (CHARACTER) 
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Sat Jan 07 23:43:36 CET 2012
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS Consultingwerk.DataTypeEnum: 
    
    DEFINE PUBLIC STATIC PROPERTY BLOB               AS CHARACTER NO-UNDO INIT "BLOB":U                 GET . 
    DEFINE PUBLIC STATIC PROPERTY CHARACTER          AS CHARACTER NO-UNDO INIT "CHARACTER":U            GET . 
    DEFINE PUBLIC STATIC PROPERTY CLOB               AS CHARACTER NO-UNDO INIT "CLOB":U                 GET . 
    DEFINE PUBLIC STATIC PROPERTY COM-HANDLE         AS CHARACTER NO-UNDO INIT "COM-HANDLE":U           GET . 
    DEFINE PUBLIC STATIC PROPERTY DATE               AS CHARACTER NO-UNDO INIT "DATE":U                 GET . 
    DEFINE PUBLIC STATIC PROPERTY DATETIME           AS CHARACTER NO-UNDO INIT "DATETIME":U             GET . 
    DEFINE PUBLIC STATIC PROPERTY DATETIME-TZ        AS CHARACTER NO-UNDO INIT "DATETIME-TZ":U          GET . 
    DEFINE PUBLIC STATIC PROPERTY DECIMAL            AS CHARACTER NO-UNDO INIT "DECIMAL":U              GET . 
    DEFINE PUBLIC STATIC PROPERTY HANDLE             AS CHARACTER NO-UNDO INIT "HANDLE":U               GET . 
    DEFINE PUBLIC STATIC PROPERTY INT64              AS CHARACTER NO-UNDO INIT "INT64":U                GET . 
    DEFINE PUBLIC STATIC PROPERTY INTEGER            AS CHARACTER NO-UNDO INIT "INTEGER":U              GET . 
    DEFINE PUBLIC STATIC PROPERTY LOGICAL            AS CHARACTER NO-UNDO INIT "LOGICAL":U              GET . 
    DEFINE PUBLIC STATIC PROPERTY ProgressLangObject AS CHARACTER NO-UNDO INIT "Progress.Lang.Object":U GET .
    DEFINE PUBLIC STATIC PROPERTY RECID              AS CHARACTER NO-UNDO INIT "RECID":U                GET .
    DEFINE PUBLIC STATIC PROPERTY ROWID              AS CHARACTER NO-UNDO INIT "ROWID":U                GET .
    
END CLASS.
