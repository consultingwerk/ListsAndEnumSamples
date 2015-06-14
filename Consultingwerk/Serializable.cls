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
    File        : Serializable
    Purpose     : Implements serialization functionality i.e. for parameter 
                  object to be passed around the AppServer boundary
    Syntax      : 
    Description : Serialization based on a property temp-table  
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Wed Sep 15 18:25:22 CEST 2010
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{ Consultingwerk/products.i }

USING Consultingwerk.*            FROM PROPATH .
USING Consultingwerk.Util.*       FROM PROPATH . 
USING Progress.Lang.*             FROM PROPATH .

CLASS Consultingwerk.Serializable 
    IMPLEMENTS ISerializable 
    {&SERIALIZABLE}
    ABSTRACT: 

    DEFINE TEMP-TABLE ttSerializeProperties NO-UNDO
        FIELD PropertyName     AS CHARACTER 
        FIELD PropertyType     AS CHARACTER 
        FIELD CharacterValue   AS CHARACTER
        FIELD DateValue        AS DATE 
        FIELD DateTimeValue    AS DATETIME 
        FIELD DateTime-TZValue AS DATETIME-TZ 
        FIELD DecimalValue     AS DECIMAL
        FIELD IntegerValue     AS INTEGER
        FIELD Int64Value       AS INT64
        FIELD LogicalValue     AS LOGICAL
        FIELD LongCharValue    AS CLOB 
        INDEX PropertyName IS UNIQUE PropertyName . 

    DEFINE TEMP-TABLE ttSerialization NO-UNDO XML-NODE-NAME "Serialization":U 
        FIELD ClassName  AS CHARACTER 
        FIELD Properties AS CLOB . 

    /*------------------------------------------------------------------------------
        Purpose: Deserializes a LONGCHAR representation of an object to a new 
                 instance                                                                      
        Notes:   Uses IDeserializationFactory service to create deserialized object
                 instance    
        @param plcSerializable The serialized representation to be deserialized    
        @return The LONGCHAR representation of the ISerializable objects data                                                                                    
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC ISerializable DeserializeInstance (plcSerializable AS LONGCHAR):
        
        DEFINE VARIABLE oDeserializationFactory AS IDeserializationFactory NO-UNDO . 
        
        oDeserializationFactory = {Consultingwerk/get-service.i Consultingwerk.IDeserializationFactory "NEW Consultingwerk.DeserializationFactory ()"} .
        
        RETURN oDeserializationFactory:DeserializeInstance (plcSerializable) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Deserializes a LONGCHAR representation of the state of the class instance                                                                      
        Notes: 
        @param pcSerializedReprasentation The stored LONGCHAR representation of the objects data                                                                                          
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID Deserialize (INPUT pcSerializedReprasentation AS LONGCHAR):

        DEFINE VARIABLE lcSerialization AS LONGCHAR NO-UNDO .  

        TEMP-TABLE ttSerialization:READ-XML ("LONGCHAR":U, pcSerializedReprasentation, "EMPTY":U, ?, FALSE) . 

        FIND FIRST ttSerialization NO-ERROR .
        
        IF NOT AVAILABLE ttSerialization THEN 
            UNDO, THROW NEW AppError ("Invalid XML serialization."{&TRAN}, 0) . 
            
        IF ttSerialization.ClassName <> THIS-OBJECT:GetClass():TypeName THEN 
            UNDO, THROW NEW AppError ("The XML data does not contain a serialization of this type."{&TRAN}, 0).             

        COPY-LOB FROM ttSerialization.Properties TO lcSerialization . 

        TEMP-TABLE ttSerializeProperties:READ-XML ("LONGCHAR":U, lcSerialization, "EMPTY":U, ?, FALSE) .

        EMPTY TEMP-TABLE ttSerialization .
        
    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns a value from a CHARACTER property in the property store                                                                        
        Notes:  
        @param pcPropertyName The name of the objects property
        @return The property value                                                                      
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED CHARACTER GetCharacterProperty (pcPropertyName AS CHARACTER):
        
        FIND ttSerializeProperties WHERE ttSerializeProperties.PropertyName = pcPropertyName
            NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN 
            RETURN "":U . /* Default */
        ELSE IF ttSerializeProperties.PropertyType <> "CHARACTER":U  THEN 
            UNDO, THROW NEW AppError 
              (SUBSTITUTE ("Property &1 is defined as &2"{&TRAN}, pcPropertyName, 
                                                                  ttSerializeProperties.PropertyType), 
                           0) .
    
        RETURN ttSerializeProperties.CharacterValue . 

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns a value from a DATE property in the property store                                                                      
        Notes:                                                                        
        @param pcPropertyName The name of the objects property
        @return The property value                                                                    
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED DATE GetDateProperty (pcPropertyName AS CHARACTER):
        
        FIND ttSerializeProperties WHERE ttSerializeProperties.PropertyName = pcPropertyName
            NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN 
            RETURN ? . /* Default */
        ELSE IF ttSerializeProperties.PropertyType <> "DATE":U  THEN 
            UNDO, THROW NEW AppError 
              (SUBSTITUTE ("Property &1 is defined as &2"{&TRAN}, pcPropertyName, 
                                                                  ttSerializeProperties.PropertyType), 
                           0) .
    
        RETURN ttSerializeProperties.DateValue . 

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns a value from a DATETIME property in the property store                                                                      
        Notes:                                                                        
        @param pcPropertyName The name of the objects property
        @return The property value                                                                    
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED DATETIME GetDateTimeProperty (pcPropertyName AS CHARACTER):
        
        FIND ttSerializeProperties WHERE ttSerializeProperties.PropertyName = pcPropertyName
            NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN 
            RETURN ? . /* Default */
        ELSE IF ttSerializeProperties.PropertyType <> "DATETIME":U  THEN 
            UNDO, THROW NEW AppError 
              (SUBSTITUTE ("Property &1 is defined as &2"{&TRAN}, pcPropertyName, 
                                                                  ttSerializeProperties.PropertyType), 
                           0) .
    
        RETURN ttSerializeProperties.DateTimeValue . 

    END METHOD.
        
    /*------------------------------------------------------------------------------
        Purpose: Returns a value from a DATETIME-TZ property in the property store                                                                      
        Notes:   
        @param pcPropertyName The name of the objects property
        @return The property value                                                                    
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED DATETIME-TZ GetDateTime-TZProperty (pcPropertyName AS CHARACTER):
        
        FIND ttSerializeProperties WHERE ttSerializeProperties.PropertyName = pcPropertyName
            NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN 
            RETURN ? . /* Default */
        ELSE IF ttSerializeProperties.PropertyType <> "DATETIME-TZ":U  THEN 
            UNDO, THROW NEW AppError 
              (SUBSTITUTE ("Property &1 is defined as &2"{&TRAN}, pcPropertyName, 
                                                                  ttSerializeProperties.PropertyType), 
                           0) .
    
        RETURN ttSerializeProperties.DateTime-TZValue . 

    END METHOD.
            
    /*------------------------------------------------------------------------------
        Purpose: Returns a value from a DECIMAL property in the property store                                                                      
        Notes:
        @param pcPropertyName The name of the objects property
        @return The property value                                                                    
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED DECIMAL GetDecimalProperty (pcPropertyName AS CHARACTER):
        
        FIND ttSerializeProperties WHERE ttSerializeProperties.PropertyName = pcPropertyName
            NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN 
            RETURN 0 . /* Default */
        ELSE IF ttSerializeProperties.PropertyType <> "DECIMAL":U  THEN 
            UNDO, THROW NEW AppError 
              (SUBSTITUTE ("Property &1 is defined as &2"{&TRAN}, pcPropertyName, 
                                                                  ttSerializeProperties.PropertyType), 
                           0) .
    
        RETURN ttSerializeProperties.DecimalValue . 

    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Returns a value from a INTEGER property in the property store                                                                      
        Notes:  
        @param pcPropertyName The name of the objects property
        @return The property value                                                                    
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED INTEGER GetIntegerProperty (pcPropertyName AS CHARACTER):
        
        FIND ttSerializeProperties WHERE ttSerializeProperties.PropertyName = pcPropertyName
            NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN 
            RETURN 0 . /* Default */
        ELSE IF ttSerializeProperties.PropertyType <> "INTEGER":U  THEN 
            UNDO, THROW NEW AppError 
              (SUBSTITUTE ("Property &1 is defined as &2"{&TRAN}, pcPropertyName, 
                                                                  ttSerializeProperties.PropertyType), 
                           0) .
    
        RETURN ttSerializeProperties.IntegerValue . 

    END METHOD.    

    /*------------------------------------------------------------------------------
        Purpose: Returns a value from a INTEGER property in the property store                                                                      
        Notes:         
        @param pcPropertyName The name of the objects property
        @return The property value                                                                    
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED INT64 GetInt64Property (pcPropertyName AS CHARACTER):
        
        FIND ttSerializeProperties WHERE ttSerializeProperties.PropertyName = pcPropertyName
            NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN 
            RETURN 0 . /* Default */
        ELSE IF ttSerializeProperties.PropertyType <> "INT64":U  THEN 
            UNDO, THROW NEW AppError 
              (SUBSTITUTE ("Property &1 is defined as &2"{&TRAN}, pcPropertyName, 
                                                                  ttSerializeProperties.PropertyType), 
                           0) .
    
        RETURN ttSerializeProperties.Int64Value . 

    END METHOD.    

    /*------------------------------------------------------------------------------
        Purpose: Returns a value from a INTEGER property in the property store                                                                      
        Notes:
        @param pcPropertyName The name of the objects property
        @return The property value                                                                    
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED LOGICAL GetLogicalProperty (pcPropertyName AS CHARACTER):
        
        FIND ttSerializeProperties WHERE ttSerializeProperties.PropertyName = pcPropertyName
            NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN 
            RETURN FALSE . /* Default */
        ELSE IF ttSerializeProperties.PropertyType <> "LOGICAL":U  THEN 
            UNDO, THROW NEW AppError 
              (SUBSTITUTE ("Property &1 is defined as &2"{&TRAN}, pcPropertyName, 
                                                                  ttSerializeProperties.PropertyType), 
                           0) .
    
        RETURN ttSerializeProperties.LogicalValue . 

    END METHOD.    
                
    /*------------------------------------------------------------------------------
        Purpose: Returns a value from a LONGCHAR property in the property store                                                                      
        Notes:        
        @param pcPropertyName The name of the objects property
        @return The property value                                                                    
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED LONGCHAR GetLongCharProperty (pcPropertyName AS CHARACTER):
        
        DEFINE VARIABLE lcReturn AS LONGCHAR NO-UNDO.
        
        FIND ttSerializeProperties WHERE ttSerializeProperties.PropertyName = pcPropertyName
            NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN 
            RETURN "":U . /* Default */
        ELSE IF ttSerializeProperties.PropertyType <> "LONGCHAR":U  THEN 
            UNDO, THROW NEW AppError 
              (SUBSTITUTE ("Property &1 is defined as &2"{&TRAN}, pcPropertyName, 
                                                                  ttSerializeProperties.PropertyType), 
                           0) .
    
        COPY-LOB FROM ttSerializeProperties.LongCharValue TO lcReturn .
    
        RETURN lcReturn . 

    END METHOD.                    
                
    /*------------------------------------------------------------------------------
        Purpose: Returns a LONGCHAR representation of the state of the class instance                                                                      
        Notes:   Returns the classname together with the XML serialization of the 
                 temp-table             
        @return The LONGCHAR representation of the ISerializable objects data                                                                               
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LONGCHAR Serialize ():
        
        DEFINE VARIABLE lcReturn AS LONGCHAR NO-UNDO .  
        
        EMPTY TEMP-TABLE ttSerialization .
        
        CREATE ttSerialization.
        ASSIGN ttSerialization.ClassName  = THIS-OBJECT:GetClass():TypeName .
               
        /* Mike Fechner, Consultingwerk Ltd. 10.01.2012
           Bug 2776: Unformatted WRITE-XML causes issues with READ-XML on OpenEdge 11.0 */
        TEMP-TABLE ttSerializeProperties:WRITE-XML ("LONGCHAR":U, lcReturn, TRUE, "utf-8":U, ?, FALSE) .
        
        COPY-LOB FROM lcReturn TO ttSerialization.Properties . 
                                   
        RELEASE ttSerialization .
        
        /* Mike Fechner, Consultingwerk Ltd. 10.01.2012
           Bug 2776: Unformatted WRITE-XML causes issues with READ-XML on OpenEdge 11.0 */
        TEMP-TABLE ttSerialization:WRITE-XML ("LONGCHAR":U, lcReturn, TRUE, "utf-8":U, ?, FALSE) .                                           

        EMPTY TEMP-TABLE ttSerialization .
        
        RETURN lcReturn .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Assigns a CHARACTER property in the property store                                                                        
        Notes:                  
        @param pcPropertyName The name of the objects property
        @param pcValue The value of the objects property
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED VOID SetCharacterProperty (pcPropertyName AS CHARACTER,
                                                pcValue        AS CHARACTER):
        
        FIND ttSerializeProperties WHERE ttSerializeProperties.PropertyName = pcPropertyName
            NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN DO: 
            CREATE ttSerializeProperties .
            ASSIGN ttSerializeProperties.PropertyName = pcPropertyName
                   ttSerializeProperties.PropertyType = "CHARACTER":U .
        END.
        ELSE IF ttSerializeProperties.PropertyType <> "CHARACTER":U  THEN 
            UNDO, THROW NEW AppError 
              (SUBSTITUTE ("Property &1 is already defined as &2"{&TRAN}, pcPropertyName, 
                                                                          ttSerializeProperties.PropertyType), 
                           0) .
    
        ASSIGN ttSerializeProperties.CharacterValue = pcValue . 
        RELEASE ttSerializeProperties .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Assigns a DATE property in the property store                                                                       
        Notes:       
        @param pcPropertyName The name of the objects property
        @param pdaValue The value of the objects property
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED VOID SetDateProperty (pcPropertyName AS CHARACTER,
                                           pdaValue       AS DATE):
        
        FIND ttSerializeProperties WHERE ttSerializeProperties.PropertyName = pcPropertyName
            NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN DO: 
            CREATE ttSerializeProperties .
            ASSIGN ttSerializeProperties.PropertyName = pcPropertyName
                   ttSerializeProperties.PropertyType = "DATE":U .
        END.
        ELSE IF ttSerializeProperties.PropertyType <> "DATE":U  THEN 
            UNDO, THROW NEW AppError 
              (SUBSTITUTE ("Property &1 is already defined as &2"{&TRAN}, pcPropertyName, 
                                                                          ttSerializeProperties.PropertyType), 
                           0) .
    
        ASSIGN ttSerializeProperties.DateValue = pdaValue . 
        RELEASE ttSerializeProperties .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Assigns a DATETIME property in the property store                                                                       
        Notes:
        @param pcPropertyName The name of the objects property
        @param pdtValue The value of the objects property
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED VOID SetDateTimeProperty (pcPropertyName AS CHARACTER,
                                               pdtValue       AS DATETIME):
        
        FIND ttSerializeProperties WHERE ttSerializeProperties.PropertyName = pcPropertyName
            NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN DO: 
            CREATE ttSerializeProperties .
            ASSIGN ttSerializeProperties.PropertyName = pcPropertyName
                   ttSerializeProperties.PropertyType = "DATETIME":U .
        END.
        ELSE IF ttSerializeProperties.PropertyType <> "DATETIME":U  THEN 
            UNDO, THROW NEW AppError 
              (SUBSTITUTE ("Property &1 is already defined as &2"{&TRAN}, pcPropertyName, 
                                                                          ttSerializeProperties.PropertyType), 
                           0) .
    
        ASSIGN ttSerializeProperties.DateTimeValue = pdtValue . 
        RELEASE ttSerializeProperties .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Assigns a DATETIME-TZ property in the property store                                                                       
        Notes:      
        @param pcPropertyName The name of the objects property
        @param pdtValue The value of the objects property
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED VOID SetDateTime-TZProperty (pcPropertyName AS CHARACTER,
                                                  pdtValue       AS DATETIME-TZ):
        
        FIND ttSerializeProperties WHERE ttSerializeProperties.PropertyName = pcPropertyName
            NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN DO: 
            CREATE ttSerializeProperties .
            ASSIGN ttSerializeProperties.PropertyName = pcPropertyName
                   ttSerializeProperties.PropertyType = "DATETIME-TZ":U .
        END.
        ELSE IF ttSerializeProperties.PropertyType <> "DATETIME-TZ":U  THEN 
            UNDO, THROW NEW AppError 
              (SUBSTITUTE ("Property &1 is already defined as &2"{&TRAN}, pcPropertyName, 
                                                                          ttSerializeProperties.PropertyType), 
                           0) .
    
        ASSIGN ttSerializeProperties.DateTime-TZValue = pdtValue . 
        RELEASE ttSerializeProperties .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Assigns a DECIMAL property in the property store                                                                       
        Notes:  
        @param pcPropertyName The name of the objects property
        @param pdeValue The value of the objects property
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED VOID SetDecimalProperty (pcPropertyName AS CHARACTER,
                                              pdeValue       AS DECIMAL):
        
        FIND ttSerializeProperties WHERE ttSerializeProperties.PropertyName = pcPropertyName
            NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN DO: 
            CREATE ttSerializeProperties .
            ASSIGN ttSerializeProperties.PropertyName = pcPropertyName
                   ttSerializeProperties.PropertyType = "DECIMAL":U .
        END.
        ELSE IF ttSerializeProperties.PropertyType <> "DECIMAL":U  THEN 
            UNDO, THROW NEW AppError 
              (SUBSTITUTE ("Property &1 is already defined as &2"{&TRAN}, pcPropertyName, 
                                                                          ttSerializeProperties.PropertyType), 
                           0) .
    
        ASSIGN ttSerializeProperties.DecimalValue = pdeValue . 
        RELEASE ttSerializeProperties .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Assigns a INTEGER property in the property store                                                                       
        Notes:      
        @param pcPropertyName The name of the objects property
        @param piValue The value of the objects property
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED VOID SetIntegerProperty (pcPropertyName AS CHARACTER,
                                              piValue        AS INTEGER):
        
        FIND ttSerializeProperties WHERE ttSerializeProperties.PropertyName = pcPropertyName
            NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN DO: 
            CREATE ttSerializeProperties .
            ASSIGN ttSerializeProperties.PropertyName = pcPropertyName
                   ttSerializeProperties.PropertyType = "INTEGER":U .
        END.
        ELSE IF ttSerializeProperties.PropertyType <> "INTEGER":U  THEN 
            UNDO, THROW NEW AppError 
              (SUBSTITUTE ("Property &1 is already defined as &2"{&TRAN}, pcPropertyName, 
                                                                          ttSerializeProperties.PropertyType), 
                           0) .
    
        ASSIGN ttSerializeProperties.IntegerValue = piValue . 
        RELEASE ttSerializeProperties .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Assigns a INTEGER property in the property store                                                                       
        Notes:            
        @param pcPropertyName The name of the objects property
        @param piValue The value of the objects property
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED VOID SetInt64Property (pcPropertyName AS CHARACTER,
                                            piValue AS INT64):
        
        FIND ttSerializeProperties WHERE ttSerializeProperties.PropertyName = pcPropertyName
            NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN DO: 
            CREATE ttSerializeProperties .
            ASSIGN ttSerializeProperties.PropertyName = pcPropertyName
                   ttSerializeProperties.PropertyType = "INT64":U .
        END.
        ELSE IF ttSerializeProperties.PropertyType <> "INT64":U  THEN 
            UNDO, THROW NEW AppError 
              (SUBSTITUTE ("Property &1 is already defined as &2"{&TRAN}, pcPropertyName, 
                                                                          ttSerializeProperties.PropertyType), 
                           0) .
    
        ASSIGN ttSerializeProperties.Int64Value = piValue . 
        RELEASE ttSerializeProperties .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Assigns a LOGICAL property in the property store                                                                       
        Notes:      
        @param pcPropertyName The name of the objects property
        @param plValue The value of the objects property
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED VOID SetLogicalProperty (pcPropertyName AS CHARACTER,
                                              plValue AS LOGICAL):
        
        FIND ttSerializeProperties WHERE ttSerializeProperties.PropertyName = pcPropertyName
            NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN DO: 
            CREATE ttSerializeProperties .
            ASSIGN ttSerializeProperties.PropertyName = pcPropertyName
                   ttSerializeProperties.PropertyType = "LOGICAL":U .
        END.
        ELSE IF ttSerializeProperties.PropertyType <> "LOGICAL":U  THEN 
            UNDO, THROW NEW AppError 
              (SUBSTITUTE ("Property &1 is already defined as &2"{&TRAN}, pcPropertyName, 
                                                                          ttSerializeProperties.PropertyType), 
                           0) .
    
        ASSIGN ttSerializeProperties.LogicalValue = plValue . 
        RELEASE ttSerializeProperties .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Assigns a LOGICAL property in the property store                                                                       
        Notes:   
        @param pcPropertyName The name of the objects property
        @param plcValue The value of the objects property
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED VOID SetLongcharProperty (pcPropertyName AS CHARACTER,
                                               plcValue       AS LONGCHAR):
        
        FIND ttSerializeProperties WHERE ttSerializeProperties.PropertyName = pcPropertyName
            NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN DO: 
            CREATE ttSerializeProperties .
            ASSIGN ttSerializeProperties.PropertyName = pcPropertyName
                   ttSerializeProperties.PropertyType = "LONGCHAR":U .
        END.
        ELSE IF ttSerializeProperties.PropertyType <> "LONGCHAR":U  THEN 
            UNDO, THROW NEW AppError 
              (SUBSTITUTE ("Property &1 is already defined as &2"{&TRAN}, pcPropertyName, 
                                                                          ttSerializeProperties.PropertyType), 
                           0) .

        COPY-LOB FROM plcValue TO ttSerializeProperties.LongCharValue . 
        RELEASE ttSerializeProperties .

    END METHOD. 
           
END CLASS.
