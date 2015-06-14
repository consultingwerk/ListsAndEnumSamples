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
    File        : StartupParameterHelpery
    Purpose     : Supporting routines to parse AVM startup parameters
    Syntax      : Static methods only, private constructor to disallow 
                  instance creation
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Sun Aug 08 19:33:08 CEST 2010
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.Util.* .
USING Progress.Lang.*.

CLASS Consultingwerk.Util.StartupParameterHelper: 

    /*------------------------------------------------------------------------------
        Purpose: Private default constructor. 
        Notes:   There's no need to create instances of the helper classes                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE StartupParameterHelper (  ):
        SUPER ().
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Returns the vlaue of the -IOEverywhere startup parameter or the
                 valid default 
        Notes:   From OpenEdge 11.0 on the default value is 1, on anything earlier 
                 the default value is 0 (this rule is also value returned for OpenEdge 
                 versions prior to 10.2B02 that don't know about this startup parameter                                                                           
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC STATIC PROPERTY IOEverywhere AS INTEGER NO-UNDO 
    GET():
        DEFINE VARIABLE cValue AS CHARACTER NO-UNDO.
        
        ASSIGN cValue = StartupParameterHelper:GetStartupParameterValue("IOEverywhere":U) .
        
        /* When parameter is set, return value */
        IF cValue > "":U THEN 
            RETURN INTEGER (cValue) .
        
        /* From OpenEdge 11.0 on the default value is 1, on anything earlier 
           the default value is 0 (this rule is also value returned for OpenEdge versions 
           prior to 10.2B02 that don't know about this startup parameter*/
        IF INTEGER (ENTRY (1, PROVERSION, ".":U)) >= 11 THEN 
            RETURN 1 . 
        ELSE 
            RETURN 0 .
        
    END GET.

    /*------------------------------------------------------------------------------
        Purpose: Returns an ABL Array of startup parameters                                                              
        Notes:   Populated in the static constructor                                                                       
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC STATIC PROPERTY StartupParameterList AS CHARACTER EXTENT NO-UNDO 
    GET.
    PRIVATE SET. 

    /*------------------------------------------------------------------------------
        Purpose: Transforms startup parameter from a comma-delimited list into an
                 ABL array                                                                       
        Notes:   Removed on of .pf entries                                                                  
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR STATIC StartupParameterHelper ():
        
        DEFINE VARIABLE i                  AS INTEGER   NO-UNDO.
        DEFINE VARIABLE iPFCount           AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cStartupParameters AS CHARACTER NO-UNDO EXTENT CASE-SENSITIVE .
        DEFINE VARIABLE cTemp              AS CHARACTER NO-UNDO.
        
        ASSIGN cTemp = SESSION:STARTUP-PARAMETERS . 
        
        DO i = 1 TO NUM-ENTRIES (cTemp):
            
            IF ENTRY (i, cTemp) = "(end .pf)":U THEN 
                iPFCount = iPFCount + 1 . 
        END.

        ASSIGN EXTENT (cStartupParameters) = NUM-ENTRIES (cTemp) - iPFCount 
               iPFCount = 0 . 
        
        DO i = 1 TO NUM-ENTRIES (cTemp):
            
            IF ENTRY (i, cTemp) = "(end .pf)":U THEN DO:
                ASSIGN iPFCount = iPFCount + 1 .
                NEXT .
            END.

            ASSIGN cStartupParameters[i - iPFCount] = ENTRY (i, cTemp) .            
        END.

        ASSIGN StartupParameterHelper:StartupParameterList = cStartupParameters .
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Parses the session startup parameters list for the passed in 
                 startup parameter and returns the parameter and it's value                                                                       
        Notes:    
        @param pcParameter The startup parameter to return the value for
        @return The value of the startup parameter                                                                    
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER GetStartupParameter (pcParameter AS CHARACTER):
        
        DEFINE VARIABLE cStartupParameters AS CHARACTER NO-UNDO EXTENT CASE-SENSITIVE .
        DEFINE VARIABLE i                  AS INTEGER   NO-UNDO.
        
        ASSIGN pcParameter        = TRIM (pcParameter) 
               cStartupParameters = StartupParameterHelper:StartupParameterList .
        
        IF NOT pcParameter BEGINS "-":U THEN 
            ASSIGN pcParameter = "-":U + pcParameter .

        DO i = 1 TO EXTENT (cStartupParameters):
            
            IF cStartupParameters[i] = pcParameter OR 
               cStartupParameters[i] BEGINS pcParameter + " ":U THEN 
               
               RETURN cStartupParameters[i] .
        END.

        RETURN ? .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Parses the session startup parameters list for the passed in 
                 startup parameter and returns the parameters value                                                                       
        Notes: 
        @param pcParameter The startup parameter to return the value for
        @return The value of the startup parameter                                                                    
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER GetStartupParameterValue (pcParameter AS CHARACTER):
        
        DEFINE VARIABLE cParameter AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iIndex     AS INTEGER   NO-UNDO.
        
        ASSIGN cParameter = StartupParameterHelper:GetStartupParameter (pcParameter) .

        IF cParameter = ? THEN 
            RETURN ? .         
        
        ASSIGN iIndex = INDEX (cParameter, " ":U) . 
        
        IF iIndex > 0 THEN 
            RETURN SUBSTRING (cParameter, iIndex + 1) . 
        
        RETURN "":U.

    END METHOD.

END CLASS.
