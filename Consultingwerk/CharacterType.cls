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
    File        : CharacterType
    Purpose     : Contains supporting routines for ABL CHARACTER Variables
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd. 
    Created     : Sat Jun 02 10:58:12 CEST 2012
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.* FROM PROPATH .  
USING Progress.Lang.*  FROM PROPATH .

CLASS Consultingwerk.CharacterType: 

    /*------------------------------------------------------------------------------
        Purpose: Disallow instance creation
        Notes:   
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE CharacterType ():
        SUPER ().
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Verifies if the passed in character string is not unknown value
                 or empty 
        Notes:   
        @param pcCharacter The character to compare
        @return True when the passed in character value is not ? or Empty 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LOGICAL IsNotNullOrEmpty (pcCharacter AS CHARACTER):
        
        RETURN pcCharacter > "":U.

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Verifies if the passed in character string is the unknown value
                 or empty 
        Notes:   
        @param pcCharacter The character to compare
        @return True when the passed in character value is ? or Empty 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LOGICAL IsNullOrEmpty (pcCharacter AS CHARACTER):
        
        RETURN pcCharacter = ? OR pcCharacter = "":U.

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Parses a String for unknown value, returning ? for "?"
        Notes:   
        @param pcValue The character string to parse
        @return The character value of ? when the string was "?"
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER ParseUnknownValue (pcValue AS CHARACTER):
            
        IF pcValue = "?":U THEN 
            RETURN ? . 
        ELSE 
            RETURN pcValue . 

    END METHOD .

END CLASS.
