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
    File        : EnumFromString.i
    Purpose     : Default method to turn a CHARACTER Value into an 
                  Enum member reference

    Syntax      : {Consultingwerk/EnumFromString.i EnumPackage.EnumClassName} 
        
    Description : 

    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Tue Feb 12 16:17:11 CEST 2013
    Notes       :
  ----------------------------------------------------------------------*/
&ENDIF

&IF NOT PROVERSION BEGINS "10.2":U &THEN
    /*------------------------------------------------------------------------------
        Purpose: Returns the reference to the Enum member with the given name
        Notes:   Only supported from OpenEdge 11.0 on 
        @param pcMemberName The name of the Enum member to return
        @return The reference to the Enum member 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC {1} FromString (pcMemberName AS CHARACTER):
        
        RETURN DYNAMIC-PROPERTY ("{1}":U, pcMemberName) .
        
        /* Error handling, when invalid member name was passed in */
        CATCH err AS Progress.Lang.Error:
            RETURN ? .  
        END CATCH.

    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Returns the reference to the Enum member with the given value
        Notes:   Only supported from OpenEdge 11.0 on 
        @param piValue The value of the Enum member to return
        @return The reference to the Enum member 
    ------------------------------------------------------------------------------*/
    METHOD STATIC PUBLIC {1} FromValue (INPUT piValue AS INTEGER):
        
        DEFINE VARIABLE iEntry AS INTEGER NO-UNDO.
        
        ASSIGN iEntry = LOOKUP(STRING(piValue), "{&EnumValues}":U) . 
        
        Consultingwerk.Assertion.Assert:GreaterThanZero (iEntry) .
        
        RETURN {1}:FromString  (ENTRY(iEntry, "{&EnumMembers}":U)).
        
    END  METHOD.
&ENDIF
