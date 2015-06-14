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
    File        : Enum
    Purpose     : Abstract base type for Enum classes
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Wed Aug 25 10:30:24 CEST 2010
    Notes       : http://blog.consultingwerk.de/consultingwerkblog/2010/08/a-pattern-for-enums
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Progress.Lang.*.

CLASS Consultingwerk.Enum ABSTRACT: 

    /*------------------------------------------------------------------------------
        Purpose: Returns the character label associated with an enum member instance                                                                       
        Notes:   Instance member
    ------------------------------------------------------------------------------*/
    DEFINE PROTECTED PROPERTY Label AS CHARACTER NO-UNDO
    GET.
    SET.
    
    /*------------------------------------------------------------------------------
        Purpose: Returns the integer value associated with an enum member instance 
        Notes:   Instance member
    ------------------------------------------------------------------------------*/    
    DEFINE PUBLIC PROPERTY Value AS INTEGER NO-UNDO 
    GET.
    PROTECTED SET. 

    /*------------------------------------------------------------------------------
        Purpose: Compares this Enum member to another member of this Enum by Value                                                                        
        Notes:   Returns FALSE when the passed in object reference is not of this
                 Enum type  
        @param poParam The object to compare by value and type with the current enum member
        @return Logical value indicating if the two compared enum members are euqally
    ------------------------------------------------------------------------------*/
    METHOD OVERRIDE PUBLIC LOGICAL Equals (INPUT poParam AS Progress.Lang.Object):
        
        /* Mike Fechner, Consultingwerk Ltd. 24.03.2011
           When poParam is invalid, Euquals returns FALSE */
        IF (NOT VALID-OBJECT (poParam)) OR (NOT poParam:GetClass() = THIS-OBJECT:GetClass()) THEN 
            RETURN FALSE . 
        
        RETURN CAST (poParam, Consultingwerk.Enum):Value = THIS-OBJECT:Value .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns a CHARACTER representation (human readable) of the 
                 Enum member                                                                      
        Notes:          
        @return The CHARACTER representation of the enum member, identically to the Label property                                                              
    ------------------------------------------------------------------------------*/
    METHOD OVERRIDE PUBLIC CHARACTER ToString ():
        
        RETURN THIS-OBJECT:Label .

    END METHOD.

END CLASS.