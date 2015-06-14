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
    File        : JsonSerializableProperty.i
    Purpose     : Defines a Serializable Property in a child class of 
                  Consultingwerk.JsonSerializable

    Syntax      : {Consultingwerk/JsonSerializableProperty.i Name Data-Type "Other Definition"}
    
                  Dynamic extent Array-Support, currently only for array's of objects, not primitives:
                  {Consultingwerk/JsonSerializableProperty.i Name "Data-Type EXTENT" "Other Definition"}
    
                  The third parameter (Other Definition) is optional

    Description : 

    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Fri Jun 29 19:32:14 CEST 2012
    Notes       : You are not supposed to use the SerializableProperties 
                  for other purposes than using it in the JsonSerializable
                  base class - as we may be changing the format of this 
                  property without warning.
  ----------------------------------------------------------------------*/
&ENDIF

&IF "{&FrameworkSerializationType}" EQ "XML" &THEN
{Consultingwerk/SerializableProperty.i "{1}" "{2}"}
&ELSE


    DEFINE PUBLIC PROPERTY {1} AS {2} NO-UNDO {3} 
    GET.
    SET.
    
&IF "{&SerializableProperties}":U NE "":U &THEN
&GLOBAL-DEFINE SerializableProperties {&SerializableProperties},{1},{2}
&ELSE
&GLOBAL-DEFINE SerializableProperties {1},{2}
&ENDIF

&ENDIF