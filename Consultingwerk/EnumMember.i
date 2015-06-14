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
    File        : EnumMember.i
    Purpose     : Defines an Enum Member property in an Enum class

    Syntax      : {Consultingwerk/EnumMember.i Label Value TypeName}

    Description : 

    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Wed Aug 25 12:24:36 CEST 2010
    Notes       :
  ----------------------------------------------------------------------*/
&ENDIF

    DEFINE PUBLIC STATIC PROPERTY {1} AS {3} NO-UNDO 
    GET:
        IF NOT VALID-OBJECT ({3}:{1}) THEN 
            {3}:{1} = NEW {3} ({2}, "{1}":U) .
            
        RETURN {3}:{1} .           
    END GET . 
    PRIVATE SET. 
    
&IF "{&EnumMembers}":U NE "":U &THEN
&GLOBAL-DEFINE EnumMembers {&EnumMembers},{1}
&ELSE
&GLOBAL-DEFINE EnumMembers {1}
&ENDIF

&IF "{&EnumValues}":U NE "":U &THEN
&GLOBAL-DEFINE EnumValues {&EnumValues},{2}
&ELSE
&GLOBAL-DEFINE EnumValues {2}
&ENDIF

&GLOBAL-DEFINE {1} {2}
