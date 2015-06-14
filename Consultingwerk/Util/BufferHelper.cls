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
    File        : BufferHelper
    Purpose     : 
    Syntax      : Static methods only, private constructor to disallow 
                  instance creation
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Wed Sep 30 14:43:37 CEST 2009
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{Consultingwerk/products.i}

USING Consultingwerk.*                       FROM PROPATH .
USING Consultingwerk.Assertion.*             FROM PROPATH . 
USING Consultingwerk.Exceptions.*            FROM PROPATH .
USING Consultingwerk.Framework.Collections.* FROM PROPATH .  
USING Consultingwerk.Util.*                  FROM PROPATH . 
USING Consultingwerk.Util.Exceptions.*       FROM PROPATH .
USING Progress.Lang.*                        FROM PROPATH .

CLASS Consultingwerk.Util.BufferHelper: 

    /*------------------------------------------------------------------------------
        Purpose: Private default constructor. 
        Notes:   There's no need to create instances of the helper classes                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE BufferHelper ():
        SUPER ().
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Adds the fields from the given Buffer Handle to the given ListNameValuePair                                                                       
        Notes:   Raises an error, when no record is available in the Buffer Handle
                 Does not add BLOB fields
        @param phBuffer Then HANDLE of the Buffer that holds the record to log
        @param poList The reference to an instance of the ListNameValuePair class
        @param plPrefixWithBuffer Logical value indicating if field names should be prefixed with the table name                                                                        
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID AddBufferFieldsToList (phBuffer AS HANDLE, 
                                                     poList AS Consultingwerk.ListNameValuePair,
                                                     plPrefixWithBuffer AS LOGICAL):
        
        DEFINE VARIABLE hField AS HANDLE NO-UNDO.
        DEFINE VARIABLE i      AS INTEGER NO-UNDO.

        Consultingwerk.Assertion.BufferAssert:IsAvailable (phBuffer) .

        DO i = 1 TO phBuffer:NUM-FIELDS:
            ASSIGN hField = phBuffer:BUFFER-FIELD (i) . 
            
            IF hField:DATA-TYPE <> Consultingwerk.DataTypeEnum:BLOB THEN 
                NEXT . 
                
            IF plPrefixWithBuffer THEN 
                poList:Add (SUBSTITUTE ("&1.&2":U,
                                        phBuffer:NAME,
                                        hField:NAME), 
                            STRING (hField:BUFFER-VALUE)) NO-ERROR .
            ELSE 
                poList:Add (hField:NAME, 
                            STRING (hField:BUFFER-VALUE)) NO-ERROR .    
        END.

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns a comma-delimited list of the buffer column names
        Notes:                                                              
        @param phBuffer The buffer handle
        @return The comma-delimited list of the buffer's column names      
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER AllFieldNames (phBuffer AS HANDLE):
        
        DEFINE VARIABLE iField  AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cField  AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cFields AS CHARACTER NO-UNDO.               

        Consultingwerk.Assertion.HandleAssert:WidgetType (phBuffer, "BUFFER":U) .

        DO iField = 1 TO phBuffer:NUM-FIELDS:
            ASSIGN cField = phBuffer:BUFFER-FIELD (iField):NAME
                   cFields = cFields + cField + ",":U . 
        END.        

        RETURN TRIM (cFields, ",":U) .         

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns the result of a SUBSTITUTE function based on fields of a 
                 buffer handle                                                                        
        Notes:                                                                        
        @param phBuffer The Buffer handle that contains the fields
        @param pcFields The comma delimited list of the fields
        @param pcSubstitute The pattern for the SUBSTITUTE function
        @return The resulting string
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER BufferFieldSubstitute (phBuffer AS HANDLE,
                                                          pcFields AS CHARACTER, 
                                                          pcSubstitute AS CHARACTER):
                                                         
        DEFINE VARIABLE cValue AS CHARACTER NO-UNDO EXTENT 9.
        DEFINE VARIABLE i      AS INTEGER   NO-UNDO.                                                               
        
        DO i = 1 TO NUM-ENTRIES (pcFields):
            ASSIGN cValue [i] = phBuffer:BUFFER-FIELD (ENTRY (i, pcFields)):STRING-VALUE .
        END. 

        RETURN SUBSTITUTE (pcSubstitute, 
                           cValue[1],
                           cValue[2],
                           cValue[3],
                           cValue[4],
                           cValue[5],
                           cValue[6],
                           cValue[7],
                           cValue[8],
                           cValue[9]) .
    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns the result of a SUBSTITUTE function based on formatted fields of a 
                 buffer handle                                                  
        Notes:                                                                        
        @param phBuffer The Buffer handle that contains the fields
        @param pcFields The comma delimited list of the fields
        @param pcSubstitute The pattern for the SUBSTITUTE function
        @param pcFormats The formats to apply to the fields, delimited by the Tilde 
        @return The resulting string
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER BufferFieldSubstituteFormatted (phBuffer AS HANDLE,
                                                                   pcFields AS CHARACTER, 
                                                                   pcSubstitute AS CHARACTER,
                                                                   pcFormats AS CHARACTER):
                                                         
        DEFINE VARIABLE cValue  AS CHARACTER NO-UNDO EXTENT 9.
        DEFINE VARIABLE cFormat AS CHARACTER NO-UNDO.
        DEFINE VARIABLE i       AS INTEGER   NO-UNDO.                                                               
        
        DO i = 1 TO NUM-ENTRIES (pcFields):
            IF NUM-ENTRIES (pcFormats, CHR (126) /*"~~":U*/) >= i THEN
                cFormat = ENTRY (i, pcFormats, CHR (126) /*"~~":U*/) .
            ELSE cFormat = ? . 
                        
            IF cFormat > "":U THEN 
                ASSIGN cValue [i] = TRIM(STRING (phBuffer:BUFFER-FIELD (ENTRY (i, pcFields)):BUFFER-VALUE,
                                                 cFormat)) .        
            ELSE 
                ASSIGN cValue [i] = phBuffer:BUFFER-FIELD (ENTRY (i, pcFields)):STRING-VALUE .
        END. 

        RETURN SUBSTITUTE (pcSubstitute, 
                           cValue[1],
                           cValue[2],
                           cValue[3],
                           cValue[4],
                           cValue[5],
                           cValue[6],
                           cValue[7],
                           cValue[8],
                           cValue[9]) .
                           
    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns the handle to the database buffer referenced by the 
                 BufferFieldName object
        Notes:   
        @param poBufferFieldName The reference to the BufferFieldName object
        @return The handle to the buffer references by the BufferFieldName object 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC HANDLE BufferHandle (poBufferFieldName AS BufferFieldName):
        
        DEFINE VARIABLE hBuffer AS HANDLE NO-UNDO.
        
        IF poBufferFieldName:DatabaseName > "":U AND poBufferFieldName:TableName > "":U THEN 
            CREATE BUFFER hBuffer FOR TABLE SUBSTITUTE ("&1.&2":U,
                                                        poBufferFieldName:DatabaseName,
                                                        poBufferFieldName:TableName) . 
        ELSE 
            CREATE BUFFER hBuffer FOR TABLE poBufferFieldName:TableName . 
        
        RETURN hBuffer.

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Creates and returns a dynamic buffer based on a BufferFieldName object 
        Notes:   The caller is expected to delete the buffer object handle when it's 
                 no longer needed  
        @param poBufferFieldName The BufferFieldName reference 
        @return The handle of the dynamic buffer
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC HANDLE CreateBuffer (poBufferFieldName AS BufferFieldName):
		
		DEFINE VARIABLE hBuffer AS HANDLE NO-UNDO.
		
        IF poBufferFieldName:DatabaseName > "":U THEN
            CREATE BUFFER hBuffer FOR TABLE SUBSTITUTE ("&1.&2":U, 
                                                        poBufferFieldName:DatabaseName,
                                                        poBufferFieldName:TableName) . 
        ELSE 
            CREATE BUFFER hBuffer FOR TABLE poBufferFieldName:TableName . 
		
		RETURN hBuffer.

	END METHOD .

	/*------------------------------------------------------------------------------
	    Purpose: Creates a Dynamic buffer on the fly
	    Notes:   Useful to pass a new buffer handle without the need to define a 
	             variable upfront (e.g. ProDataset:ADD-BUFFER, etc.)
	    @param phTable The handle of the table or existing buffer which can specify the source for which to create the buffer object
	    @return The handle of the new dynamic buffer
	------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC HANDLE CreateBuffer (phTable AS HANDLE):
		
		DEFINE VARIABLE hBuffer AS HANDLE NO-UNDO.
		
		HandleAssert:ValidHandle (phTable) .
		
		CREATE BUFFER hBuffer FOR TABLE phTable . 

        RETURN hBuffer .

	END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Finds the before buffer's after-buffer record
        Notes:   
        @param phBeforeBuffer The handle of the before buffer
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC VOID FindAfterBuffer (phBeforeBuffer AS HANDLE):
		
		BufferAssert:IsDatasetBuffer (phBeforeBuffer) .
		
		phBeforeBuffer:AFTER-BUFFER:FIND-BY-ROWID (phBeforeBuffer:AFTER-ROWID) .

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Finds the after buffer's before-buffer record
        Notes:   
        @param phAfterBuffer The handle of the after buffer
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID FindBeforeBuffer (phAfterBuffer AS HANDLE):
        
        BufferAssert:IsDatasetBuffer (phAfterBuffer) .
        
        phAfterBuffer:BEFORE-BUFFER:FIND-BY-ROWID (phAfterBuffer:BEFORE-ROWID) .

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns the name and extent of the field name                                                                      
        Notes:                                                
        @param pcField The field name, including extent if present
        @param pcFieldName OUTPUT Just the field name portion
        @param piExtent OUTPUT The field extent or 0 when the field name did not contain extent information                        
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID GetFieldNameAndExtent (pcField AS CHARACTER,     
                                                     OUTPUT pcFieldName AS CHARACTER,
                                                     OUTPUT piExtent AS INTEGER):
        
        DEFINE VARIABLE cExtent AS CHARACTER   NO-UNDO.

        IF INDEX (pcField, "[":U) > 0 THEN 
            ASSIGN pcFieldName = SUBSTRING (pcField, 1, INDEX (pcField, "[":U) - 1) 
                   cExtent     = SUBSTRING (pcField, INDEX (pcField, "[":U) + 1) 
                   piExtent    = INTEGER (SUBSTRING(cExtent, 1, LENGTH (cExtent) - 1))
                        .
        ELSE 
            ASSIGN pcFieldName = pcField 
                   piExtent    = 0 . 
        

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Tests if the passed in buffer handle has a field with the 
                 given name                                                                       
        Notes:   Verifies that a valid buffer is passed in first.
        @param phBuffer The Buffer handle to test
        @param pcFieldName The name of the buffer field                                                                  
        @return Logical value indicating if the field exists
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LOGICAL HasField (phBuffer AS HANDLE,
                                           pcFieldName AS CHARACTER):
        
        DEFINE VARIABLE hField AS HANDLE NO-UNDO.
        
        Consultingwerk.Assertion.HandleAssert:ValidHandle (phBuffer, "BUFFER":U) .

        hField = phBuffer:BUFFER-FIELD (pcFieldName) NO-ERROR .
        
        RETURN VALID-HANDLE (hField) .
        
        FINALLY:
            ERROR-STATUS:ERROR = FALSE NO-ERROR . 		
        END FINALLY.

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns TRUE when the passed in Buffer Handle is a buffer handle for 
                 a database table  
        Notes:   
        @param phBuffer The buffer handle to test
        @return Logical value indicating if the buffer handle is for a database buffer
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC LOGICAL IsDatabaseBuffer (phBuffer AS HANDLE):
		
        HandleAssert:WidgetType (phBuffer, WidgetTypeEnum:Buffer) .
		
        IF CharacterType:IsNullOrEmpty (phBuffer:DBNAME) OR 
           CharacterType:IsNullOrEmpty (DBTYPE (phBuffer:DBNAME)) THEN 

            RETURN FALSE . 
        ELSE 
            RETURN TRUE . 		

	END METHOD .

	/*------------------------------------------------------------------------------
		Purpose: Nullify (?) all unique index field values  																	  
		Notes:   This methods can be used when creating records, but there is already 
		         a record in the table, that uses the default values of some index fields  		
        @param phBuffer The buffer handle
	------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC VOID NullifyUniqueIndexFields (phBuffer AS HANDLE):
		
        DEFINE VARIABLE iIndex       AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cIndex       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iField       AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cField       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE hField       AS HANDLE    NO-UNDO.
        
        IF NOT VALID-HANDLE (phBuffer) OR phBuffer:TYPE <> "BUFFER":U THEN 
            UNDO, THROW NEW AppError ("The method NullifyUniqueIndexFields needs to be executed using a valid buffer handle."{&TRAN}, 0) .
        
        indexloop: REPEAT ON ERROR UNDO, THROW:
            ASSIGN iIndex = iIndex + 1
                   cIndex = phBuffer:INDEX-INFORMATION (iIndex) .
                   
            IF cIndex > "":U THEN . 
            ELSE LEAVE .

            IF ENTRY(2, cIndex) <> "1":U /* unique */ OR 
               ENTRY(4, cIndex) <> "0":U /* word */ THEN 
               NEXT .                          
        
            DO iField = 5 TO NUM-ENTRIES (cIndex) BY 2 ON ERROR UNDO, THROW:
                ASSIGN cField = ENTRY(iField, cIndex)  
                       hField = phBuffer:BUFFER-FIELD (cField)
                        
                       hField:BUFFER-VALUE = ? . 
            END.        
        END.

	END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Assigns buffer field values from SAX-ATTRIBUTES
        Notes:   
        @param phBuffer The handle to the buffer to assign the field values to
        @param phSaxAttributes The handle of the SAX-ATTRIBUTES widget
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID ParseSaxAttributesToBuffer (phBuffer AS HANDLE,
                                                          phSaxAttributes AS HANDLE):
        
        DEFINE VARIABLE i      AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cName  AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cValue AS CHARACTER NO-UNDO.
        
        Consultingwerk.Assertion.HandleAssert:WidgetType (phBuffer, WidgetTypeEnum:Buffer) .
        Consultingwerk.Assertion.HandleAssert:WidgetType (phSaxAttributes, WidgetTypeEnum:SaxAttributes) .

        DO i = 1 TO phSaxAttributes:NUM-ITEMS:
            ASSIGN cName  = phSaxAttributes:GET-QNAME-BY-INDEX (i)
                   cValue = phSaxAttributes:GET-VALUE-BY-INDEX (i) . 
            
            Consultingwerk.Assertion.BufferAssert:HasField (phBuffer, cName) .
            
            ASSIGN phBuffer:BUFFER-FIELD (cName):BUFFER-VALUE = cValue .  
        END.

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Parses a field name
        Notes:   Supports db.table.field, table.field, field with and without index (extent)
        @param pcFieldName The field name to parse
        @return The Consultingwerk.BufferFieldName struct describing the field name
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC BufferFieldName ParseFieldName (pcFieldName AS CHARACTER):
        
        RETURN NEW BufferFieldName (pcFieldName) .

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns the qualified table name of a buffer 
        Notes:   For a DB buffer the qualified table name is prefixed with the database name
                 For a temp-table buffer the qualified table name is the same as the temp-table name
        @param phBuffer The handle of the buffer
        @return The qualified table name 
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC CHARACTER QualifiedTableName (phBuffer AS HANDLE):

        HandleAssert:WidgetType (phBuffer, "BUFFER":U) .
		
		IF BufferHelper:IsDatabaseBuffer (phBuffer) THEN 
		    RETURN SUBSTITUTE ("&1.&2":U,
		                       phBuffer:DBNAME,
		                       phBuffer:TABLE) .
		ELSE 
		    RETURN phBuffer:TABLE .
		
	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Shows buffer field values on the screen using the MESSAGE statement 
        Notes:   Defaults to show the first 15 fields
        @param phBuffer The handle of the Buffer to output
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC VOID ShowBuffer (phBuffer AS HANDLE):

        DEFINE VARIABLE iField AS INTEGER NO-UNDO.
		
        BufferHelper:ShowBuffer (phBuffer, 15) .		

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Shows buffer field values on the screen using the MESSAGE statement 
        Notes:   When number of fields is 0 all fields will be shown
        @param phBuffer The handle of the Buffer to output
        @param piNumFields The maximum number of fields to show
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID ShowBuffer (phBuffer AS HANDLE,
                                          piNumFields AS INTEGER):

        DEFINE VARIABLE iField  AS INTEGER NO-UNDO INIT 1.
        DEFINE VARIABLE iExtent AS INTEGER NO-UNDO .
        DEFINE VARIABLE hField  AS HANDLE  NO-UNDO .
        DEFINE VARIABLE cValue  AS CHARACTER NO-UNDO.

        DEFINE VARIABLE cMessage AS CHARACTER NO-UNDO.
        
        HandleAssert:WidgetType (phBuffer, WidgetTypeEnum:Buffer) .     

        IF NOT phBuffer:AVAILABLE THEN DO:
            MESSAGE SUBSTITUTE ("Buffer &1: <no record is available>"{&TRAN},
                                phBuffer:NAME) VIEW-AS ALERT-BOX INFORMATION . 
            
            RETURN . 
        END.
        
        ASSIGN cMessage = SUBSTITUTE ("Buffer &1: record with ROWID &2~n~n"{&TRAN}, 
                                      phBuffer:NAME, 
                                      phBuffer:ROWID) . 

        REPEAT:
            ASSIGN hField = phBuffer:BUFFER-FIELD (iField) .
    
            IF hField:EXTENT >= 1 THEN DO:
                DO iExtent = 1 TO hField:EXTENT:
                    CASE hField:DATA-TYPE:
                        WHEN "BLOB":U THEN 
                            ASSIGN cValue = SUBSTITUTE ("Length: &1"{&TRAN}, LENGTH (hField:BUFFER-VALUE(iExtent))) .

                        WHEN "CLOB":U THEN 
                            ASSIGN cValue = SUBSTITUTE ("Length: &1"{&TRAN}, LENGTH (hField:BUFFER-VALUE)) .
                        
                        OTHERWISE 
                            ASSIGN cValue = STRING (hField:BUFFER-VALUE(iExtent)) . 
                    
                    END.
                    
                    cMessage = cMessage + SUBSTITUTE ("&1.&2[&5] <&3>:    &4~n":U,
                                                      phBuffer:NAME, 
                                                      hField:NAME,
                                                      hField:DATA-TYPE,
                                                      cValue,
                                                      iExtent) .
                END.
            END.
            ELSE DO:
                CASE hField:DATA-TYPE:
                    WHEN "BLOB":U THEN 
                        ASSIGN cValue = SUBSTITUTE ("Length: &1"{&TRAN}, LENGTH (hField:BUFFER-VALUE)) .

                    WHEN "CLOB":U THEN 
                        ASSIGN cValue = SUBSTITUTE ("Length: &1"{&TRAN}, LENGTH (hField:BUFFER-VALUE)) .
                    
                    OTHERWISE 
                        ASSIGN cValue = STRING (hField:BUFFER-VALUE) . 
                
                END.
                
                cMessage = cMessage + SUBSTITUTE ("&1.&2 <&3>:    &4~n":U,
                                                  phBuffer:NAME, 
                                                  hField:NAME,
                                                  hField:DATA-TYPE,
                                                  cValue) .
            END.            
            
            ASSIGN iField = iField + 1 .
            
            IF iField > phBuffer:NUM-FIELDS THEN LEAVE . 
            
            IF piNumFields > 0 AND iField > piNumFields THEN 
                LEAVE .  
        END.

        MESSAGE cMessage
            VIEW-AS ALERT-BOX INFORMATION .

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns the total number of fields in a Buffer including Array 
                 fields as individual columns                                                                        
        Notes:         
        @param phBuffer The handle to the buffer
        @return The total number of columns, including array extents
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC INTEGER TotalNumberOfFields (phBuffer AS HANDLE):
        
        DEFINE VARIABLE i      AS INTEGER NO-UNDO.
        DEFINE VARIABLE iTotal AS INTEGER NO-UNDO.
        DEFINE VARIABLE hField AS HANDLE NO-UNDO.

        Consultingwerk.Assertion.HandleAssert:WidgetType (phBuffer, "BUFFER":U) .

        DO i = 1 TO phBuffer:NUM-FIELDS:
            
            ASSIGN hField = phBuffer:BUFFER-FIELD (i) . 
            
            IF hField:EXTENT = 0 THEN  
                ASSIGN iTotal = iTotal + 1 . 
            ELSE 
                ASSIGN iTotal = iTotal + phBuffer:EXTENT .             
        END. 

        RETURN iTotal . 
        
    END METHOD.

     /*------------------------------------------------------------------------------
        Purpose: Returns the fields of the Unique Primary of the table                                                                        
        Notes:   Same as UniqueKeyFields (phBuffer, FALSE)
        @param phBuffer The Buffer Handle     
        @return The a comma-delimited list of the unique fields of the table                                                                  
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER UniqueKeyFields (phBuffer AS HANDLE):
        
        RETURN BufferHelper:UniqueKeyFields (phBuffer, TRUE, FALSE) .
        
    END METHOD . 

     /*------------------------------------------------------------------------------
        Purpose: Returns the fields of the Unique Primary of the table                                                                        
        Notes: 
        @param phBuffer The Buffer Handle                              
        @param plPrimaryOnly Only return the fields of a primary unique index
        @return The a comma-delimited list of the unique fields of the table                                                                  
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER UniqueKeyFields (phBuffer AS HANDLE,
                                                    plPrimaryOnly AS LOGICAL):
                                                        
        RETURN BufferHelper:UniqueKeyFields (phBuffer, plPrimaryOnly, FALSE) .                 
                                                        
    END METHOD .                                                         
                                                        
     /*------------------------------------------------------------------------------
        Purpose: Returns the fields of the Unique Primary of the table                                                                        
        Notes: 
        @param phBuffer The Buffer Handle                              
        @param plPrimaryOnly Only return the fields of a primary unique index
        @param plPrefixWithTable Prefix field names with Table/Buffer name
        @return The a comma-delimited list of the unique fields of the table                                                                  
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER UniqueKeyFields (phBuffer AS HANDLE,
                                                    plPrimaryOnly AS LOGICAL,
                                                    plPrefixWithTable AS LOGICAL):
                                                                
        DEFINE VARIABLE iIndex       AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cIndex       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iField       AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cField       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE hField       AS HANDLE    NO-UNDO.
        DEFINE VARIABLE cFields      AS CHARACTER NO-UNDO.
               
        IF NOT VALID-HANDLE (phBuffer) OR phBuffer:TYPE <> "BUFFER":U THEN 
            UNDO, THROW NEW AppError ("The method UniqueKeyFields needs to be executed using a valid buffer handle."{&TRAN}, 0) .
        
        indexloop: REPEAT ON ERROR UNDO, THROW:
            ASSIGN iIndex = iIndex + 1
                   cIndex = phBuffer:INDEX-INFORMATION (iIndex) .
                   
            IF cIndex > "":U THEN . 
            ELSE LEAVE .

            IF plPrimaryOnly THEN DO:
                IF ENTRY(2, cIndex) <> "1":U /* unique */ OR 
                   ENTRY(3, cIndex) <> "1":U /* primary */ THEN 
               NEXT .
            END.                          
            ELSE IF ENTRY(2, cIndex) <> "1":U /* unique */ THEN 
                NEXT . 
        
            DO iField = 5 TO NUM-ENTRIES (cIndex) BY 2 ON ERROR UNDO, THROW:
                IF plPrefixWithTable THEN 
                    ASSIGN cField = SUBSTITUTE ("&1.&2":U, phBuffer:NAME, ENTRY(iField, cIndex))   
                           cFields = cFields + cField + ",":U . 
                ELSE 
                    ASSIGN cField = ENTRY(iField, cIndex)  
                           cFields = cFields + cField + ",":U . 
            END.        

            RETURN TRIM (cFields, ",":U) . 
        END.

        RETURN "":U . 

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Builds and returns a unique record identifier composed from field 
                 values of either the primary unique index or the first unqiue index
                 of the table
        Notes:   Calls UniqueRecordIdentifier (phBuffer, TRUE, CHR(1))
        @param phBuffer The handle of the buffer that contains the record
        @return An identifier for the records based on unique index values
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER UniqueRecordIdentifier (phBuffer AS HANDLE):
                                                               
        RETURN UniqueRecordIdentifier (phBuffer, TRUE, CHR(1)) .
                                                                       
    END METHOD . 
                                                                   
	/*------------------------------------------------------------------------------
	    Purpose: Builds and returns a unique record identifier composed from field 
	             values of either the primary unique index or the first unqiue index
	             of the table
	    Notes:   The purpose of this method is to build a unique reusable identifier 
	             for a record that is not dependent on a ROWID (temp-table ROWID's are 
	             no suited record identifiers)
	    @param phBuffer The handle of the buffer that contains the record
	    @param plPrimaryOnly Logical value indicating if only the primary index should be used
	    @param pcDelimiter The delimiter to use for the field values
	    @return An identifier for the records based on unique index values 
	------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC CHARACTER UniqueRecordIdentifier (phBuffer AS HANDLE, 
	                                                       plPrimaryOnly AS LOGICAL,
	                                                       pcDelimiter AS CHARACTER):
		
        DEFINE VARIABLE iIndex       AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cIndex       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iField       AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cField       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE hField       AS HANDLE    NO-UNDO.
        DEFINE VARIABLE cIdentifier  AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lFound       AS LOGICAL   NO-UNDO.
        DEFINE VARIABLE hIndexBuffer AS HANDLE    NO-UNDO.
               
        HandleAssert:WidgetType (phBuffer, WidgetTypeEnum:Buffer) .
        BufferAssert:IsAvailable (phBuffer) .

        /* Mike Fechner, Consultingwerk Ltd. 26.11.2010
           When we are working on the BEFORE-BUFFER, the BEFORE-BUFFER has no
           indexes, then use the AFTER-BUFFER for the indexes */
        IF VALID-HANDLE (phBuffer:AFTER-BUFFER) THEN hIndexBuffer = phBuffer:AFTER-BUFFER . 
        ELSE hIndexBuffer = phBuffer .
                      
        indexloop: REPEAT ON ERROR UNDO, THROW:
            ASSIGN iIndex = iIndex + 1
                   cIndex = hIndexBuffer:INDEX-INFORMATION (iIndex) .
                   
            IF cIndex > "":U THEN . 
            ELSE LEAVE .

            IF ENTRY(2, cIndex) <> "1":U /* unique */ OR 
               ENTRY(3, cIndex) <> "1":U /* primary */ THEN 
               NEXT .                          
        
            DO iField = 5 TO NUM-ENTRIES (cIndex) BY 2 ON ERROR UNDO, THROW:
                ASSIGN cField = ENTRY(iField, cIndex)  
                       hField = phBuffer:BUFFER-FIELD (cField) . 
                       
                IF iField > 5 THEN  
                    ASSIGN cIdentifier = cIdentifier + pcDelimiter .   
                
                ASSIGN cIdentifier = cIdentifier + STRING (hField:BUFFER-VALUE).              
            END.  
            
            RETURN cIdentifier . 
        END.

        /* Mike Fechner, Consultingwerk Ltd. 08.01.2012
           If we get here , the table does not have a primary unique 
           index, so try the first unique index */
        IF NOT plPrimaryOnly THEN DO:
            iIndex = 0 . 
            
            indexloop: REPEAT ON ERROR UNDO, THROW:
                ASSIGN iIndex = iIndex + 1
                       cIndex = hIndexBuffer:INDEX-INFORMATION (iIndex) .
                       
                IF cIndex > "":U THEN . 
                ELSE LEAVE .
    
                IF ENTRY(2, cIndex) <> "1":U /* unique */ THEN 
                   NEXT .                          
            
                DO iField = 5 TO NUM-ENTRIES (cIndex) BY 2 ON ERROR UNDO, THROW:
                    ASSIGN cField = ENTRY(iField, cIndex)  
                           hField = phBuffer:BUFFER-FIELD (cField) . 
                           
                    IF iField > 5 THEN  
                        ASSIGN cIdentifier = cIdentifier + pcDelimiter .   
                    
                    ASSIGN cIdentifier = cIdentifier + STRING (hField:BUFFER-VALUE).              
                END.              
            
                RETURN cIdentifier .
            END.   
        END.
        
        UNDO, THROW NEW UniqueIndexRequiredException (phBuffer:NAME, 
                                                      plPrimaryOnly) .        

	END METHOD.

END CLASS.
