&IF 1=0 &THEN
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
    File        : SerializableProperty.i
    Purpose     : Defines a Serializable Property in a child class of 
                  Consultingwerk.Serializable or Consultingwerk.XmlSerializable

    Syntax      : {Consultingwerk/SerializableProperty.i Name Data-Type "Other Definition"}
                  The third parameter (Other Definition) is optional

    Description : 

    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Fri Sep 17 14:18:14 CEST 2010
    Notes       : The XmlSerializable class does also support nested objects, 
                  where the second parameter does not equal a built in ABL
                  primitive data type, the Consultingwerk.Serializable class
                  however does 
  ----------------------------------------------------------------------*/
&ENDIF
&IF "{2}" = "CHARACTER" OR
    "{2}" = "DATE" OR
    "{2}" = "DATETIME" OR
    "{2}" = "DATETIME-TZ" OR
    "{2}" = "DECIMAL" OR
    "{2}" = "INT64" OR
    "{2}" = "INTEGER" OR
    "{2}" = "LOGICAL" OR
    "{2}" = "LONGCHAR" OR 
    "{2}" = "RAW" &THEN
    DEFINE PUBLIC PROPERTY {1} AS {2} NO-UNDO {3} 
    GET():
        RETURN THIS-OBJECT:Get{2}Property ("{1}":U) .
    END GET.
    SET(INPUT arg AS {2}):
        THIS-OBJECT:Set{2}Property ("{1}":U, arg) .                
    END SET.
&ELSE
    DEFINE PUBLIC PROPERTY {1} AS {2} NO-UNDO {3} 
    GET():
        RETURN CAST (THIS-OBJECT:GetObjectProperty ("{1}":U),
                     {2}) .
    END GET.
    SET(INPUT arg AS {2}):
        THIS-OBJECT:SetObjectProperty ("{1}":U, arg) .                
    END SET.
&ENDIF

&IF "{&SerializableProperties}":U NE "":U &THEN
&GLOBAL-DEFINE SerializableProperties {&SerializableProperties},{1},{2}
&ELSE
&GLOBAL-DEFINE SerializableProperties {1},{2}
&ENDIF
    