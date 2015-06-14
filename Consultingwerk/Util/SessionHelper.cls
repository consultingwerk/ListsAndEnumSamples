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
    File        : SessionHelper
    Purpose     : 
    Syntax      : Static methods only, private constructor to disallow 
                  instance creation
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Sun Aug 08 21:32:44 CEST 2010
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{ Consultingwerk/products.i }

USING Consultingwerk.*      FROM PROPATH . 
USING Consultingwerk.Util.* FROM PROPATH . 
USING Progress.Lang.*       FROM PROPATH .

CLASS Consultingwerk.Util.SessionHelper: 

    DEFINE PRIVATE STATIC VARIABLE cPatchLevel AS CHARACTER INIT ? . 
    	 
    /*------------------------------------------------------------------------------
        Purpose: Returns the DLC path value
        Notes:   Reads -zdlc Startup Parameter or the current progress.ini file or
                 registry branch                                                                 
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC STATIC PROPERTY DLC AS CHARACTER NO-UNDO 
    GET():
        DEFINE VARIABLE dlcValue AS CHARACTER NO-UNDO.
        
        /* Mike Fechner, Consultingwerk Ltd. 20.06.2014
           SCL-341: Query -zdlc parameter as an override to DLC in progress.ini
                    Typically used for WebClient Application */
        ASSIGN dlcValue = Consultingwerk.Util.StartupParameterHelper:GetStartupParameterValue ("zdlc":U) .
        
        IF dlcValue > "":U THEN 
            RETURN dlcValue .
        
        IF OPSYS = "Win32":U THEN /* Get DLC from Registry */
            GET-KEY-VALUE SECTION "Startup":U KEY "DLC":U VALUE dlcValue.
    
        IF (dlcValue = "":U OR dlcValue = ?) THEN 
            ASSIGN 
                dlcValue = OS-GETENV("DLC":U). /* Get DLC from environment */
        
        RETURN dlcValue .
        
    END GET.

    /*------------------------------------------------------------------------------
        Purpose: Private default constructor. 
        Notes:   There's no need to create instances of the helper classes                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE SessionHelper ():
        SUPER ().
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Returns if the current session allows compilation of ABL source code                                                                      
        Notes:   Compiles a non existing .p file (random file name) and tests the 
                 error message.    
                 ** Compiler is not available in this version of PROGRESS. (494)
        @return Logical value indicating if the current session allows compilation                                                                                    
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LOGICAL AllowsCompile ():
        
        COMPILE VALUE (SUBSTITUTE ("&1.p":U, GUID)) .
        
        RETURN TRUE . 
        
        CATCH e AS Progress.Lang.Error :
            IF e:GetMessageNum (1) = 494 THEN 
                RETURN FALSE . 
            ELSE
                RETURN TRUE . 
        END CATCH.

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns the current working directory                                                                      
        Notes:                                                                    
        @return The current working directory    
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER CurrentDirectory ():
        
        &IF DEFINED (DotNetAccessible) NE 0 &THEN
        RETURN System.Environment:CurrentDirectory .
        &ELSE
        FILE-INFO:FILE-NAME = ".":U . 
        
        RETURN FILE-INFO:FULL-PATHNAME .
        &ENDIF
        
    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns the name of the current method of the caller  
        Notes:   Returns the first entry by space of PROGRAM-NAME(2)
        @return The name of the current method of the caller
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER CurrentMethodName ():
        
        RETURN ENTRY (1, PROGRAM-NAME (2), " ":U).

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns the Progress Version (incl. Service Pack Level)
        Notes:   From src/adecomm/_about.p        
        @return The full progress version string                                                              
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER FullVersionString ():
        
        /* Reads the Version file to see if there is a patch level */
    
        DEFINE VARIABLE i          AS INTEGER   NO-UNDO.
        DEFINE VARIABLE dlcValue   AS CHARACTER NO-UNDO. /* DLC */
        DEFINE VARIABLE inp        AS CHARACTER NO-UNDO. /* hold 1st line of version file */
        
        IF cPatchLevel <> ? THEN 
            RETURN cPatchLevel .
        
        IF OPSYS = "Win32":U THEN /* Get DLC from Registry */
            GET-KEY-VALUE SECTION "Startup":U KEY "DLC":U VALUE dlcValue.
    
        IF (dlcValue = "":U OR dlcValue = ?) THEN 
        DO:
            ASSIGN 
                dlcValue = OS-GETENV("DLC":U). /* Get DLC from environment */
            IF (dlcValue = "":U OR dlcValue = ?) THEN 
            DO: /* Still nothing? */
                RETURN "":U .
            END.
        END.
        FILE-INFO:FILE-NAME = dlcValue + "/version":U.
        IF FILE-INFO:FULL-PATHNAME NE ? THEN 
        DO: /* Read the version file */
            INPUT FROM VALUE(FILE-INFO:FULL-PATHNAME).
            IMPORT UNFORMATTED inp. /* Get the first line */
            INPUT CLOSE.
            /* 
             * As of version 9.1D just append everything from the version file
             * after the version from PROVERSION property
             */
            LEVEL:
            DO i = 2 TO NUM-ENTRIES(inp," ":U):
                IF ENTRY(i,inp," ":U) BEGINS PROVERSION THEN 
                DO:
                    RETURN ENTRY(i,inp," ":U) .
                END.
            END.
        END.   
            
        RETURN "":U .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns the current session date format
        Notes:   
        @return The Consultingwerk.DateFormat with the current session Settings 
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC DateFormat GetDateFormat ():
		
        DEFINE VARIABLE oDateFormat AS DateFormat NO-UNDO . 
        
        ASSIGN oDateFormat = NEW Consultingwerk.DateFormat ()
               oDateFormat:DateFormat = SESSION:DATE-FORMAT
               oDateFormat:YearOffset = SESSION:YEAR-OFFSET .
        
        RETURN oDateFormat .

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns the current session numeric format
        Notes:   
        @return The Consultingwerk.NumericFormat with the current session Settings
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC NumericFormat GetNumericFormat ():
		
		DEFINE VARIABLE oNumericFormat AS NumericFormat NO-UNDO . 
		
		ASSIGN oNumericFormat = NEW Consultingwerk.NumericFormat ()
		       oNumericFormat:NumSeparator = SESSION:NUMERIC-SEPARATOR
		       oNumericFormat:DecimalPoint = SESSION:NUMERIC-DECIMAL-POINT .
		
		RETURN oNumericFormat .

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Reads the Version file to see if there is a patch level                                                                        
        Notes:   From src/adecomm/_about.p                                          
        @return The current patch level                            
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER GetPatchLevel ():
        
        /* Reads the Version file to see if there is a patch level */
        DEFINE VARIABLE patchLevel AS CHARACTER NO-UNDO.
    
        DEFINE VARIABLE i          AS INTEGER   NO-UNDO.
        DEFINE VARIABLE dlcValue   AS CHARACTER NO-UNDO. /* DLC */
        DEFINE VARIABLE inp        AS CHARACTER NO-UNDO. /* hold 1st line of version file */
        
        IF cPatchLevel <> ? THEN 
            RETURN cPatchLevel .
        
        IF OPSYS = "Win32":U THEN /* Get DLC from Registry */
            GET-KEY-VALUE SECTION "Startup":U KEY "DLC":U VALUE dlcValue.
    
        IF (dlcValue = "":U OR dlcValue = ?) THEN 
        DO:
            ASSIGN 
                dlcValue = OS-GETENV("DLC":U). /* Get DLC from environment */
            IF (dlcValue = "":U OR dlcValue = ?) THEN 
            DO: /* Still nothing? */
                RETURN "":U.
            END.
        END.
        FILE-INFO:FILE-NAME = dlcValue + "/version":U.
        IF FILE-INFO:FULL-PATHNAME NE ? THEN 
        DO: /* Read the version file */
            INPUT FROM VALUE(FILE-INFO:FULL-PATHNAME).
            IMPORT UNFORMATTED inp. /* Get the first line */
            INPUT CLOSE.
            /* 
             * As of version 9.1D just append everything from the version file
             * after the version from PROVERSION property
             */
            LEVEL:
            DO i = 2 TO NUM-ENTRIES(inp," ":U):
                IF ENTRY(i,inp," ":U) BEGINS PROVERSION THEN 
                DO:
                    ASSIGN 
                        patchLevel = REPLACE(ENTRY(i,inp," ":U),PROVERSION,"":U).
                    LEAVE LEVEL.
                END.
            END.
        END.   
        ELSE 
            UNDO, THROW NEW AppError ("Unable to detect service pack level without being able to locate the version file."{&TRAN}, 0) .      
            
        ASSIGN cPatchLevel = patchlevel .            
            
        RETURN patchlevel .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns a numeric representation of the progress runtime version 
        Notes:   The return value is built using the major version before the comma
                 and the minor version behind the comma   
        @return The numeric representation of the progress runtime version, e.g. 10,2 or 11,1
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC DECIMAL ProVersionNumeric ():
		
		DEFINE VARIABLE deMinor AS DECIMAL NO-UNDO .
		DEFINE VARIABLE iMinor  AS INTEGER NO-UNDO .
		
		ASSIGN iMinor = INTEGER  (Consultingwerk.IntegerType:NumericString(ENTRY (2, PROVERSION, ".":U))) .
		
	    ASSIGN deMinor = iMinor / 10 .
	
	    DO WHILE deMinor > 1 ON ERROR UNDO, THROW:
	        ASSIGN deMinor = deMinor / 10 .
	    END.
		
        RETURN INTEGER (ENTRY (1, PROVERSION, ".":U)) +
               deMinor . 

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Sets the Sessions date format
        Notes:   
        @param poDateFormat The DateFormat object with the settings for the current session
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC VOID SetDateFormat (poDateFormat AS DateFormat):
		
		ASSIGN SESSION:DATE-FORMAT = poDateFormat:DateFormat
		       SESSION:YEAR-OFFSET = poDateFormat:YearOffset . 

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Sets the ABL default date format (mdy-1950) 
        Notes:   
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC VOID SetDefaultDateFormat ():
		
		SESSION:DATE-FORMAT = "mdy":U .
		SESSION:YEAR-OFFSET = 1950 .

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Sets the ABL default numeric format (AMERICAN) 
        Notes:   
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC VOID SetDefaultNumericFormat ():
		
		SESSION:NUMERIC-FORMAT = "AMERICAN":U . 

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Sets the Sessions numeric format 
        Notes:   
        @param poNumericFormat The NumericFormat object with the settings for the current session
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC VOID SetNumericFormat (poNumericFormat AS NumericFormat):
		
		SESSION:SET-NUMERIC-FORMAT (poNumericFormat:NumSeparator,
		                            poNumericFormat:DecimalPoint) .

	END METHOD .

END CLASS.
