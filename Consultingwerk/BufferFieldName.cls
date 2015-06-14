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
    File        : BufferFieldName
    Purpose     : A structure that can hold all possible components
                  of a buffer field reference database.table.field[index]
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Mon Sep 10 14:09:47 CEST 2012
    Notes       : This class does not perform any validation of the property 
                  values
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{Consultingwerk/products.i}

USING Consultingwerk.*            FROM PROPATH . 
USING Consultingwerk.Exceptions.* FROM PROPATH .  
USING Progress.Lang.*             FROM PROPATH .

CLASS Consultingwerk.BufferFieldName
&IF "{&FrameworkSerializationType}" EQ "XML" OR PROVERSION BEGINS "10.2":U &THEN
    INHERITS XmlSerializable
&ELSE
    INHERITS JsonSerializable
&ENDIF    
    IMPLEMENTS IQueryExpression: 

    /*------------------------------------------------------------------------------
        Purpose: Gets and sets the Database Name component
        Notes:   
    ------------------------------------------------------------------------------*/
    {Consultingwerk/JsonSerializableProperty.i DatabaseName CHARACTER "INIT ?"}

    /*------------------------------------------------------------------------------
        Purpose: Gets and sets the Field Name component
        Notes:   
    ------------------------------------------------------------------------------*/
    {Consultingwerk/JsonSerializableProperty.i FieldName CHARACTER "INIT ?"}

    /*------------------------------------------------------------------------------
        Purpose: Gets and sets the Index component (0 for non EXTENT fields)
        Notes:   
    ------------------------------------------------------------------------------*/
    {Consultingwerk/JsonSerializableProperty.i Index INTEGER "INIT ?"}

    /*------------------------------------------------------------------------------
        Purpose: Gets and sets the Table Name component
        Notes:   
    ------------------------------------------------------------------------------*/
    {Consultingwerk/JsonSerializableProperty.i TableName CHARACTER "INIT ?"}

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the BufferFieldName class
        Notes:   
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC BufferFieldName ():
        SUPER ().
        
        THIS-OBJECT:AddSerializableProperties ("{&SerializableProperties}":U) .

    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the BufferFieldName class
        Notes: 
        @param pcDatabaseName The database name
        @param pcTableName The table name
        @param pcFieldName The field name
        @param piIndex The field index (extent)  
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC BufferFieldName (pcDatabaseName AS CHARACTER,
                                        pcTableName AS CHARACTER,
                                        pcFieldName AS CHARACTER,
                                        piIndex AS INTEGER):
        THIS-OBJECT ().

        THIS-OBJECT:DatabaseName = pcDatabaseName .
        THIS-OBJECT:TableName    = pcTableName .
        THIS-OBJECT:FieldName    = pcFieldName . 
        THIS-OBJECT:Index        = piIndex . 
                    
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the BufferFieldName class
        Notes:  
        @param pcDatabaseName The database name
        @param pcTableName The table name
        @param pcFieldName The field name
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC BufferFieldName (pcDatabaseName AS CHARACTER,
                                        pcTableName AS CHARACTER,
                                        pcFieldName AS CHARACTER):
        THIS-OBJECT ().

        THIS-OBJECT:DatabaseName = pcDatabaseName .
        THIS-OBJECT:TableName    = pcTableName .
        THIS-OBJECT:FieldName    = pcFieldName . 
                
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the BufferFieldName class
        Notes:   
        @param pcTableName The table name
        @param pcFieldName The field name
        @param piIndex The field index (extent)  
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC BufferFieldName (pcTableName AS CHARACTER,
                                        pcFieldName AS CHARACTER,
                                        piIndex AS INTEGER):
        THIS-OBJECT ().

        THIS-OBJECT:TableName = pcTableName .
        THIS-OBJECT:FieldName = pcFieldName . 
        THIS-OBJECT:Index     = piIndex . 
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the BufferFieldName class
        Notes:   
        @param pcTableName The table name
        @param pcFieldName The field name
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC BufferFieldName (pcTableName AS CHARACTER,
                                        pcFieldName AS CHARACTER):
        THIS-OBJECT ().
        
        THIS-OBJECT:TableName = pcTableName .
        THIS-OBJECT:FieldName = pcFieldName . 
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the BufferFieldName class
        Notes:   Supports db.table.field, table.field, field with and without index (extent)
        @param pcFieldName The field name
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC BufferFieldName (pcFieldName AS CHARACTER):
        
        DEFINE VARIABLE iIndex1          AS INTEGER                        NO-UNDO.
        DEFINE VARIABLE iIndex2          AS INTEGER                        NO-UNDO.

        THIS-OBJECT ().
        
        Consultingwerk.Assertion.Assert:NotNullOrEmpty (pcFieldName) .

        CASE NUM-ENTRIES (pcFieldName, ".":U):
            WHEN 1 THEN 
                ASSIGN THIS-OBJECT:FieldName    = ENTRY (1, pcFieldName, ".":U) .
            WHEN 2 THEN 
                ASSIGN THIS-OBJECT:FieldName    = ENTRY (2, pcFieldName, ".":U) 
                       THIS-OBJECT:TableName    = ENTRY (1, pcFieldName, ".":U) .
            WHEN 3 THEN 
                ASSIGN THIS-OBJECT:FieldName    = ENTRY (3, pcFieldName, ".":U) 
                       THIS-OBJECT:TableName    = ENTRY (2, pcFieldName, ".":U) 
                       THIS-OBJECT:DatabaseName = ENTRY (1, pcFieldName, ".":U) .
            OTHERWISE 
                UNDO, THROW NEW InvalidParameterValueException ("pcFieldName":U,
                                                                pcFieldName,
                                                                "Consultingwerk.BufferFieldName":U) .
        END CASE .            

        /* parse EXTENT fields */        
        ASSIGN iIndex1 = INDEX (THIS-OBJECT:FieldName, "[":U) .
        
        IF iIndex1 > 0 THEN DO:
            ASSIGN iIndex2 = INDEX (THIS-OBJECT:FieldName, "]":U, iIndex1) .
            
            IF iIndex2 > 0 THEN 
                ASSIGN THIS-OBJECT:Index     = INTEGER (SUBSTRING (THIS-OBJECT:FieldName, iIndex1 + 1, iIndex2 - iIndex1 - 1))
                       THIS-OBJECT:FieldName = SUBSTRING (THIS-OBJECT:FieldName, 1, iIndex1 - 1) .
            ELSE     
                UNDO, THROW NEW InvalidParameterValueException ("pcFieldName":U,
                                                                pcFieldName,
                                                                "Consultingwerk.BufferFieldName":U) .
        END.

    END CONSTRUCTOR .

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the BufferFieldName class
        Notes:   
        @param phBuffer The handle of the Buffer that contains the field
        @param pcFieldName The name of the Buffer field 
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC BufferFieldName (phBuffer AS HANDLE,
                                        pcFieldName AS CHARACTER):
        THIS-OBJECT ().
        
        Consultingwerk.Assertion.HandleAssert:WidgetType (phBuffer, WidgetTypeEnum:Buffer) .
        Consultingwerk.Assertion.BufferAssert:HasField (phBuffer, pcFieldName) .
        
        THIS-OBJECT:TableName = phBuffer:TABLE .
        THIS-OBJECT:FieldName = pcFieldName . 
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the BufferFieldName class
        Notes:   
        @param phBufferField The Buffer Field to use to populate the buffer field name
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC BufferFieldName (phBufferField AS HANDLE):
        THIS-OBJECT ().
        
        Consultingwerk.Assertion.HandleAssert:WidgetType (phBufferField, WidgetTypeEnum:BufferField) .
        
        THIS-OBJECT:TableName = phBufferField:TABLE .
        THIS-OBJECT:FieldName = phBufferField:NAME . 
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Returns the Expression to be used in a Query String
        Notes:   
        @return The CHARACTER Expression  
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER GetExpression ().
        
        DEFINE VARIABLE cExpression AS CHARACTER NO-UNDO.
        
        Consultingwerk.Assertion.Assert:NotNullOrEmpty (THIS-OBJECT:FieldName,
                                                        "FieldName":U) .
        
        IF THIS-OBJECT:DatabaseName > "":U AND THIS-OBJECT:TableName > "":U THEN 
            ASSIGN cExpression = SUBSTITUTE ("&1.":U, THIS-OBJECT:DatabaseName) .

        IF THIS-OBJECT:TableName > "":U THEN 
            ASSIGN cExpression = cExpression + SUBSTITUTE ("&1.":U, THIS-OBJECT:TableName) .

        ASSIGN cExpression = cExpression + SUBSTITUTE ("&1":U, THIS-OBJECT:FieldName) .
        
        IF THIS-OBJECT:Index > 0 THEN 
            ASSIGN cExpression = cExpression + SUBSTITUTE ("[&1]":U, THIS-OBJECT:Index) .
        
        RETURN cExpression . 
        
    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns a string that represents the current object.
        Notes:   
        @return A string that represents the current object.
    ------------------------------------------------------------------------------*/
    METHOD OVERRIDE PUBLIC CHARACTER ToString ():
        
        RETURN SUBSTITUTE ("Database Name: &1&5Table Name: &2&5Field Name: &3&5Index: &4"{&TRAN},
                           THIS-OBJECT:DatabaseName,
                           THIS-OBJECT:TableName,
                           THIS-OBJECT:FieldName,
                           THIS-OBJECT:Index,
                           "~n":U) . 
    END METHOD .

END CLASS.
