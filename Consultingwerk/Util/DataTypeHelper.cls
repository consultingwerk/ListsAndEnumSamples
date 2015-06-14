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
    File        : DataTypeHelper
    Purpose     : 
    Syntax      : Static methods only, private constructor to disallow 
                  instance creation
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Wed Dec 01 16:49:22 CET 2010
    Notes       : This file is intended for GUI for .NET only
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{ Consultingwerk/products.i }

USING Consultingwerk.*                 FROM PROPATH . 
USING Consultingwerk.Assertion.*       FROM PROPATH.
USING Consultingwerk.Exceptions.*      FROM PROPATH .
USING Consultingwerk.Util.*            FROM PROPATH . 
USING Consultingwerk.Util.Exceptions.* FROM PROPATH . 
USING Progress.Lang.*                  FROM PROPATH .

CLASS Consultingwerk.Util.DataTypeHelper: 

    /*------------------------------------------------------------------------------
        Purpose: Disallow instance creation                                                                        
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE DataTypeHelper ():
        SUPER ().
        
    END CONSTRUCTOR.
    
    /*------------------------------------------------------------------------------
       Purpose: Returns the ABL Default Format for the given data type
       Notes:   Creates a single field temp-table and returns the format of the field
       @param pcDataType The ABL DataType
       @return The default format for the data type
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER DefaultFormat (pcDataType AS CHARACTER):
        
        DEFINE VARIABLE hTable AS HANDLE NO-UNDO.

        CREATE TEMP-TABLE hTable. 
        hTable:ADD-NEW-FIELD ("test":U, pcDataType) . 
        hTable:TEMP-TABLE-PREPARE ("ttTest":U) .

        RETURN hTable:DEFAULT-BUFFER-HANDLE:BUFFER-FIELD (1):FORMAT .

        FINALLY:
            GarbageCollectorHelper:DeleteObject (hTable) .		
        END FINALLY.

    END METHOD.

    /*------------------------------------------------------------------------------
       Purpose: Returns the XML default data-type for the given ABL data type
       Notes:   Creates a single field temp-table and returns the XML-DATA-TYPE of the field
       @param pcDataType The ABL DataType
       @return The default XML data type for the data type
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER DefaultXmlSchemaType (pcDataType AS CHARACTER):
        
        DEFINE VARIABLE hTable AS HANDLE NO-UNDO.

        CREATE TEMP-TABLE hTable. 
        hTable:ADD-NEW-FIELD ("test":U, pcDataType) . 
        hTable:TEMP-TABLE-PREPARE ("ttTest":U) .

        RETURN hTable:DEFAULT-BUFFER-HANDLE:BUFFER-FIELD (1):XML-DATA-TYPE .

        FINALLY:
            GarbageCollectorHelper:DeleteObject (hTable) .      
        END FINALLY.

    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Returns true when the passed in data type name is an ABL primitive type
        Notes:   
        @param pcDataType An Character value that should be tested for a valid ABL data type
        @return True when the passed in data type name is an ABL primitive type
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LOGICAL IsAblDataType (pcDataType AS CHARACTER):
        
        IF LOOKUP (pcDataType, Consultingwerk.Const:ABL_DATA_TYPES) > 0 THEN 
            RETURN TRUE . 
        ELSE 
            RETURN FALSE . 

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns an INTEGER value from a CHARACTER value 
        Notes:   Does return ? on invalid value
        @param pcString The string value 
        @return The integer value
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC DECIMAL ToDecimal (pcString AS CHARACTER):
        
        DEFINE VARIABLE deValue AS DECIMAL NO-UNDO.
        
        ASSIGN deValue = DECIMAL (pcString) .
        
        RETURN deValue .
        
        CATCH err AS Progress.Lang.Error :
            RETURN ?.   
        END CATCH.

    END METHOD .
        
    /*------------------------------------------------------------------------------
        Purpose: Returns an INT64 value from a CHARACTER value 
        Notes:   Does return ? on invalid value
        @param pcString The string value 
        @return The int64 value 
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC INT64 ToInt64 (pcString AS CHARACTER):
		
        DEFINE VARIABLE iValue AS INT64 NO-UNDO.
        
        ASSIGN iValue = INT64 (pcString) .
        
        RETURN iValue .
        
        CATCH err AS Progress.Lang.Error :
            RETURN ?.   
        END CATCH.

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns an INTEGER value from a CHARACTER value 
        Notes:   Does return ? on invalid value
        @param pcString The string value 
        @return The integer value
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC INTEGER ToInteger (pcString AS CHARACTER):
		
		DEFINE VARIABLE iValue AS INTEGER NO-UNDO.
		
        ASSIGN iValue = INTEGER (pcString) .
        
        RETURN iValue .
        
        CATCH err AS Progress.Lang.Error :
        	RETURN ?. 	
        END CATCH.

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Converts common string representations to a logical value (true/false/?)                                                                        
        Notes:                                                                        
        @param pcValue The CHARACTER expression to parse
        @return The equivalent LOGICAL value                                                           
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LOGICAL ToLogical (pcValue AS CHARACTER):

        IF pcValue = "TRUE":U OR pcValue = "YES":U OR pcValue = "1":U OR pcValue = "JA":U OR pcValue = "WAHR":U OR pcValue = "+":U THEN
            RETURN TRUE  .

        IF pcValue = "FALSE":U OR pcValue = "NO":U OR pcValue = "0":U OR pcValue = "NEIN":U OR pcValue = "FALSCH":U OR pcValue = "-":U THEN
            RETURN FALSE  .

        RETURN ? .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns the unabbreviated ABL Data Type Name
        Notes:   Returns ? when the data type name is not an unabbreviated ABL data 
                 type name
        @param pcDataType The potentially abbreviated data type name
        @return The unabbreviated data type name or ? when the data type is not a valid abbreviation of an ABL data type name
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER UnabbreviateDataTypeName (pcDataType AS CHARACTER):
        
        DEFINE VARIABLE cTypeName AS CHARACTER NO-UNDO EXTENT 15
            INIT ["BLOB":U, "CHARACTER":U, "CLOB":U, "COM-HANDLE":U, "DATE":U, 
                  "DATETIME":U, "DATETIME-TZ":U, "DECIMAL":U, "HANDLE":U, "INT64":U, 
                  "INTEGER":U, "LOGICAL":U, "RECID":U, "ROWID":U, "RAW":U] .

        DEFINE VARIABLE iMinAbbr AS INTEGER NO-UNDO EXTENT 15
            INIT [4, 4, 4, 10, 4,
                  8, 11, 3, 6, 5, 
                  3, 7, 5, 5, 3].
        
        DEFINE VARIABLE i AS INTEGER NO-UNDO.
        DEFINE VARIABLE j AS INTEGER NO-UNDO.

        DO i = 1 TO EXTENT (cTypeName):           
            
            IF pcDataType BEGINS SUBSTRING (cTypeName[i], 1, iMinAbbr[i]) THEN DO:
            
                DO j = iMinAbbr[i] TO LENGTH (pcDataType):
    
                    IF pcDataType = SUBSTRING (cTypeName[i], 1, j) THEN 
                        RETURN cTypeName[i] .
                END.
            END.
        END.
    
        RETURN ? . 

    END METHOD.

END CLASS.
