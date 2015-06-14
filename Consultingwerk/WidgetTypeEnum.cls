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
    File        : WidgetTypeEnum
    Purpose     : Widget TYPE Constants (CHARACTER) 
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Sun Aug 28 16:05:31 CEST 2011
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Progress.Lang.*.

CLASS Consultingwerk.WidgetTypeEnum: 

    DEFINE PUBLIC STATIC PROPERTY AsyncRequest       AS CHARACTER NO-UNDO INIT "ASYNC-REQUEST":U        GET . 
    DEFINE PUBLIC STATIC PROPERTY Browse             AS CHARACTER NO-UNDO INIT "BROWSE":U               GET .  
    DEFINE PUBLIC STATIC PROPERTY BrowseColumn       AS CHARACTER NO-UNDO INIT "BROWSE-COLUMN":U        GET . 
    DEFINE PUBLIC STATIC PROPERTY Buffer             AS CHARACTER NO-UNDO INIT "BUFFER":U               GET . 
    DEFINE PUBLIC STATIC PROPERTY BufferField        AS CHARACTER NO-UNDO INIT "BUFFER-FIELD":U         GET . 
    DEFINE PUBLIC STATIC PROPERTY Button             AS CHARACTER NO-UNDO INIT "BUTTON":U               GET .  
    DEFINE PUBLIC STATIC PROPERTY ComboBox           AS CHARACTER NO-UNDO INIT "COMBO-BOX":U            GET .  
    DEFINE PUBLIC STATIC PROPERTY ControlFrame       AS CHARACTER NO-UNDO INIT "CONTROL-FRAME":U        GET .  
    DEFINE PUBLIC STATIC PROPERTY DataRelation       AS CHARACTER NO-UNDO INIT "DATA-RELATION":U        GET . 
    DEFINE PUBLIC STATIC PROPERTY Dataset            AS CHARACTER NO-UNDO INIT "DATASET":U              GET . 
    DEFINE PUBLIC STATIC PROPERTY DataSource         AS CHARACTER NO-UNDO INIT "DATA-SOURCE":U          GET . 
    DEFINE PUBLIC STATIC PROPERTY DialogBox          AS CHARACTER NO-UNDO INIT "DIALOG-BOX":U           GET .  
    DEFINE PUBLIC STATIC PROPERTY Editor             AS CHARACTER NO-UNDO INIT "EDITOR":U               GET .  
    DEFINE PUBLIC STATIC PROPERTY FillIn             AS CHARACTER NO-UNDO INIT "FILL-IN":U              GET .  
    DEFINE PUBLIC STATIC PROPERTY FieldGroup         AS CHARACTER NO-UNDO INIT "FIELD-GROUP":U          GET .  
    DEFINE PUBLIC STATIC PROPERTY Frame              AS CHARACTER NO-UNDO INIT "FRAME":U                GET .  
    DEFINE PUBLIC STATIC PROPERTY Image              AS CHARACTER NO-UNDO INIT "IMAGE":U                GET .  
    DEFINE PUBLIC STATIC PROPERTY Literal            AS CHARACTER NO-UNDO INIT "LITERAL":U              GET .
    DEFINE PUBLIC STATIC PROPERTY Menu               AS CHARACTER NO-UNDO INIT "MENU":U                 GET .  
    DEFINE PUBLIC STATIC PROPERTY MenuItem           AS CHARACTER NO-UNDO INIT "MENU-ITEM":U            GET .  
    DEFINE PUBLIC STATIC PROPERTY RadioSet           AS CHARACTER NO-UNDO INIT "RADIO-SET":U            GET .  
    DEFINE PUBLIC STATIC PROPERTY Procedure          AS CHARACTER NO-UNDO INIT "PROCEDURE":U            GET . 
    DEFINE PUBLIC STATIC PROPERTY Query              AS CHARACTER NO-UNDO INIT "QUERY":U                GET . 
    DEFINE PUBLIC STATIC PROPERTY Rectangle          AS CHARACTER NO-UNDO INIT "RECTANGLE":U            GET .  
    DEFINE PUBLIC STATIC PROPERTY SaxAttributes      AS CHARACTER NO-UNDO INIT "SAX-ATTRIBUTES":U       GET . 
    DEFINE PUBLIC STATIC PROPERTY SaxReader          AS CHARACTER NO-UNDO INIT "SAX-READER":U           GET . 
    DEFINE PUBLIC STATIC PROPERTY Server             AS CHARACTER NO-UNDO INIT "SERVER":U               GET . 
    DEFINE PUBLIC STATIC PROPERTY ServerSocket       AS CHARACTER NO-UNDO INIT "SERVER-SOCKET":U        GET . 
    DEFINE PUBLIC STATIC PROPERTY SelectionList      AS CHARACTER NO-UNDO INIT "SELECTION-LIST":U       GET .  
    DEFINE PUBLIC STATIC PROPERTY Slider             AS CHARACTER NO-UNDO INIT "SLIDER":U               GET .  
    DEFINE PUBLIC STATIC PROPERTY SoapFault          AS CHARACTER NO-UNDO INIT "SOAP-FAULT":U           GET . 
    DEFINE PUBLIC STATIC PROPERTY SoapFaultDetail    AS CHARACTER NO-UNDO INIT "SOAP-FAULT-DETAIL":U    GET . 
    DEFINE PUBLIC STATIC PROPERTY SoapHeader         AS CHARACTER NO-UNDO INIT "SOAP-HEADER":U          GET . 
    DEFINE PUBLIC STATIC PROPERTY SoapHeaderEntryRef AS CHARACTER NO-UNDO INIT "SOAP-HEADER-ENTRYREF":U GET . 
    DEFINE PUBLIC STATIC PROPERTY Socket             AS CHARACTER NO-UNDO INIT "SOCKET":U               GET . 
    DEFINE PUBLIC STATIC PROPERTY Stream             AS CHARACTER NO-UNDO INIT "STREAM":U               GET . 
    DEFINE PUBLIC STATIC PROPERTY SubMenu            AS CHARACTER NO-UNDO INIT "SUB-MENU":U             GET .  
    DEFINE PUBLIC STATIC PROPERTY TempTable          AS CHARACTER NO-UNDO INIT "TEMP-TABLE":U           GET . 
    DEFINE PUBLIC STATIC PROPERTY Text               AS CHARACTER NO-UNDO INIT "TEXT":U                 GET .  
    DEFINE PUBLIC STATIC PROPERTY ToggleBox          AS CHARACTER NO-UNDO INIT "TOGGLE-BOX":U           GET .  
    DEFINE PUBLIC STATIC PROPERTY Window             AS CHARACTER NO-UNDO INIT "WINDOW":U               GET .  
    DEFINE PUBLIC STATIC PROPERTY XDocument          AS CHARACTER NO-UNDO INIT "X-DOCUMENT":U           GET . 
    DEFINE PUBLIC STATIC PROPERTY XNodeRef           AS CHARACTER NO-UNDO INIT "X-NODEREF":U            GET . 

    /*------------------------------------------------------------------------------
        Purpose: Disallow instance creation                                                                       
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE WidgetTypeEnum ():
        SUPER ().
        
    END CONSTRUCTOR.

END CLASS.