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
    File        : XmlSerializable
    Purpose     : Implements serialization functionality i.e. for parameter 
                  object to be passed around the AppServer boundary
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Mon Feb 11 13:52:21 CET 2013
    Notes       : This is a more lightweight XML serializaion as the 
                  Consultingwerk.Serializable and it's also supposed to 
                  provide compatibility with the .NET XML serializer
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{Consultingwerk/products.i}

USING Consultingwerk.*                       FROM PROPATH .  
USING Consultingwerk.Exceptions.*            FROM PROPATH .  
USING Consultingwerk.Framework.Base.*        FROM PROPATH .
USING Consultingwerk.Framework.Collections.* FROM PROPATH .
USING Consultingwerk.Util.*                  FROM PROPATH .
USING Progress.Lang.*                        FROM PROPATH .

CLASS Consultingwerk.XmlSerializable 
    IMPLEMENTS ISerializable 
    {&SERIALIZABLE} 
    ABSTRACT
    USE-WIDGET-POOL: 

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
        FIELD ObjectValue      AS Progress.Lang.Object
        FIELD RawValue         AS RAW 
        INDEX PropertyName IS UNIQUE PropertyName . 

    /*------------------------------------------------------------------------------
        Purpose: Gets and sets the list of Serializable Properties                                                                      
        Notes:   Required as a workaround to full reflection only. We *may* remove this 
                 property once Progress Software has implemented full reflection
                 You are not supposed to use the SerializableProperties 
                 for other purposes than using it in the JsonSerializable
                 base class - as we may be changing the format of this 
                 property without warning.
    ------------------------------------------------------------------------------*/
    DEFINE PRIVATE PROPERTY SerializableProperties AS CHARACTER NO-UNDO 
    GET.
    SET. 

    /*------------------------------------------------------------------------------
        Purpose: Gets and sets if Null-Values should be serialized                                                                 
        Notes:   
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY SerializeNullValues AS LOGICAL INITIAL FALSE NO-UNDO 
    GET.
    SET. 
    
    /*------------------------------------------------------------------------------
        Purpose: Determines if the Serialization Routine will read and write the 
                 SerializedType attribute
        Notes:   
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY UseSerializedTypeInformation AS LOGICAL INITIAL TRUE NO-UNDO 
    GET.
    SET. 
    
    /*------------------------------------------------------------------------------
        Purpose: Add a list of Serializable Properties to the SerializableProperties property                                                                       
        Notes:   Required as a workaround to full reflection only. We *may* remove this 
                 method once Progress Software has implemented full reflection                                                                    
        @param pcSerializableProperties A comma delimited list of serializable properties 
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED VOID AddSerializableProperties (pcSerializableProperties AS CHARACTER):
        
        ASSIGN THIS-OBJECT:SerializableProperties = TRIM (THIS-OBJECT:SerializableProperties + 
                                                          ",":U +
                                                          pcSerializableProperties, ",":U)  .

    END METHOD.
        
    /*------------------------------------------------------------------------------
        Purpose: Initializes the object instance based on the passed in LONGCHAR
                 representation of the object instance                                                                      
        Notes:               
        @param pcSerializedReprasentation The stored LONGCHAR representation of the objects data                                                          
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC VOID Deserialize (INPUT pcSerializedReprasentation AS LONGCHAR):
		 
		DEFINE VARIABLE hDocument AS HANDLE NO-UNDO .
		DEFINE VARIABLE hRootNode AS HANDLE NO-UNDO .
		
        CREATE X-DOCUMENT hDocument . 
        CREATE X-NODEREF hRootNode . 
        
        hDocument:LOAD ("LONGCHAR":U, pcSerializedReprasentation, FALSE) .
        hDocument:GET-DOCUMENT-ELEMENT (hRootNode) .
        
        THIS-OBJECT:DeserializeFromNode (hRootNode) .

        CATCH err AS Progress.Lang.Error:
            IF TYPE-OF (err, XmlSerializableException) THEN 
                UNDO, THROW err .
             
            IF err:NumMessages > 0 THEN 
                UNDO, THROW NEW XmlSerializableException (err,
                                                          err:GetMessage(1),
                                                          err:GetMessageNum (1),
                                                          THIS-OBJECT:GetClass():TypeName,
                                                          ?) .
            ELSE 
                UNDO, THROW NEW XmlSerializableException (err,
                                                          THIS-OBJECT:GetClass():TypeName,
                                                          ?) .
                                                                                    
        END CATCH.

        FINALLY:
            GarbageCollectorHelper:DeleteObject (hRootNode) .
            GarbageCollectorHelper:DeleteObject (hDocument) .     
        END FINALLY.

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Deserializes the object instance based on the passed in X-NODEREF
                 instance 
        Notes:   
        @param phRootNode The root node with the properties for this object
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC VOID DeserializeFromNode (phRootNode AS HANDLE):
		
        DEFINE VARIABLE hChildNode AS HANDLE  NO-UNDO .
        DEFINE VARIABLE iCount     AS INTEGER NO-UNDO .
        DEFINE VARIABLE i          AS INTEGER NO-UNDO .
	
	    CREATE X-NODEREF hChildNode .
	
	    ASSIGN iCount = phRootNode:NUM-CHILDREN . 
	
	    DO i = 1 TO iCount:
	        phRootNode:GET-CHILD (hChildNode, i) . 
	
		    THIS-OBJECT:DeserializeProperty (hChildNode,
		                                     hChildNode:NAME,
		                                     THIS-OBJECT:PropertyType (hChildNode:NAME)) .
        END.

        CATCH err AS Progress.Lang.Error:
            IF TYPE-OF (err, XmlSerializableException) THEN 
                UNDO, THROW err .
             
            IF err:NumMessages > 0 THEN 
                UNDO, THROW NEW XmlSerializableException (err,
                                                          err:GetMessage(1),
                                                          err:GetMessageNum (1),
                                                          THIS-OBJECT:GetClass():TypeName,
                                                          ?) .
            ELSE 
                UNDO, THROW NEW XmlSerializableException (err,
                                                          THIS-OBJECT:GetClass():TypeName,
                                                          ?) .
                                                                               		
        END CATCH.

        FINALLY:
            GarbageCollectorHelper:DeleteObject (hChildNode) .		
        END FINALLY.

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Deserializes a single property value to the current Object
        Notes:   Allows to override the handling of individual properties during the
                 XmlSerialization
        Notes:   
        @param phPropertyNode reference to the source XML Node
        @param pcProperty The name of the property 
        @param pcType The type of the property
    ------------------------------------------------------------------------------*/
	METHOD PROTECTED VOID DeserializeProperty (phPropertyNode AS HANDLE,
                                               pcProperty AS CHARACTER,
                                               pcType AS CHARACTER):
	
	    DEFINE VARIABLE hChildObject    AS HANDLE               NO-UNDO .
        DEFINE VARIABLE oNestedInstance AS XmlSerializable      NO-UNDO .
        DEFINE VARIABLE oList           AS Progress.Lang.Object NO-UNDO .  
        DEFINE VARIABLE iIndex          AS INTEGER              NO-UNDO .
        DEFINE VARIABLE iLength         AS INTEGER              NO-UNDO .
        DEFINE VARIABLE iItem           AS INTEGER              NO-UNDO .
        DEFINE VARIABLE cItemType       AS CHARACTER            NO-UNDO .
	    DEFINE VARIABLE mptr            AS MEMPTR               NO-UNDO . 
	    DEFINE VARIABLE rRaw            AS RAW                  NO-UNDO . 
	    DEFINE VARIABLE cNodeValue      AS CHARACTER            NO-UNDO .
	
	    Consultingwerk.Assertion.HandleAssert:WidgetType (phPropertyNode,
	                                                      WidgetTypeEnum:XNodeRef) .
	
	    CASE pcType:
	       WHEN "CHARACTER":U THEN 
	           THIS-OBJECT:SetCharacterProperty (pcProperty, 
	                                             XmlHelper:GetCharacterValueInNode (phPropertyNode)) .
           WHEN "DATE":U THEN 
               THIS-OBJECT:SetDateProperty (pcProperty, 
                                            DATE(XmlHelper:GetCharacterValueInNode (phPropertyNode))) .
           WHEN "DATETIME":U THEN 
               THIS-OBJECT:SetDateTimeProperty (pcProperty, 
                                                DATETIME(XmlHelper:GetCharacterValueInNode (phPropertyNode))) .
           WHEN "DATETIME-TZ":U THEN 
               THIS-OBJECT:SetDateTime-TZProperty (pcProperty, 
                                                   DATETIME-TZ(XmlHelper:GetCharacterValueInNode (phPropertyNode))) .
           WHEN "DECIMAL":U THEN 
               THIS-OBJECT:SetDecimalProperty (pcProperty, 
                                               DECIMAL(XmlHelper:GetCharacterValueInNode (phPropertyNode))) .
           WHEN "INT64":U THEN 
               THIS-OBJECT:SetInt64Property (pcProperty, 
                                             INT64(XmlHelper:GetCharacterValueInNode (phPropertyNode))) .
           WHEN "INTEGER":U THEN 
               THIS-OBJECT:SetIntegerProperty (pcProperty, 
                                               INTEGER(XmlHelper:GetCharacterValueInNode (phPropertyNode))) .
           WHEN "LOGICAL":U THEN 
               THIS-OBJECT:SetLogicalProperty (pcProperty, 
                                               LOGICAL(XmlHelper:GetCharacterValueInNode (phPropertyNode))) .
           WHEN "LONGCHAR":U THEN 
               THIS-OBJECT:SetLongcharProperty (pcProperty, 
                                                XmlHelper:GetLongCharValueInNode (phPropertyNode)) .
           WHEN "RAW":U THEN DO ON ERROR UNDO, THROW:
               mptr = BASE64-DECODE (XmlHelper:GetLongCharValueInNode (phPropertyNode)) .
               
               rRaw = GET-BYTES (mptr, 1, GET-SIZE (mptr)) .
               
               THIS-OBJECT:SetRawProperty (pcProperty, 
                                           rRaw) .
                                           
               FINALLY:
                   	SET-SIZE (mptr) = 0 . 	
               END FINALLY.
            END.
            
            OTHERWISE DO:
                IF Progress.Lang.Class:GetClass (pcType):IsA ("Consultingwerk.Enum":U) THEN DO:
                    ASSIGN cNodeValue = XmlHelper:GetCharacterValueInNode (phPropertyNode) . 
                    
                    IF cNodeValue > "":U THEN  
                        THIS-OBJECT:SetObjectProperty (pcProperty,
                                                       DYNAMIC-INVOKE (pcType,  
                                                                       "FromString":U, 
                                                                       cNodeValue)) .
                    ELSE 
                        THIS-OBJECT:SetObjectProperty (pcProperty, ?) . 
                END. 
                ELSE IF Progress.Lang.Class:GetClass (pcType):IsA ("Consultingwerk.Framework.Base.IEnumerable":U) THEN DO:
                    
                    oList = THIS-OBJECT:GetObjectProperty (pcProperty) .
                    
                    CREATE X-NODEREF hChildObject .
                    
                    DO iItem = 1 TO phPropertyNode:NUM-CHILDREN:
                        phPropertyNode:GET-CHILD (hChildObject, iItem) .

                        cItemType = hChildObject:GET-ATTRIBUTE ("SerializedType":U) .                        
                        
                        IF CharacterType:IsNullOrEmpty (cItemType) THEN 
                            UNDO, THROW NEW XmlSerializableException (SUBSTITUTE ("Unable to deserialize property &1 of &2 as it does not contain a XML Serialized object."{&TRAN}, 
                                                                                  pcProperty,
                                                                                  THIS-OBJECT:GetClass ():TypeName), 0,
                                                                      THIS-OBJECT:GetClass ():TypeName,
                                                                      pcProperty) . 
                        oNestedInstance = DYNAMIC-NEW (cItemType) ().

                        oNestedInstance:DeserializeFromNode(hChildObject) .
                        
                        DYNAMIC-INVOKE (oList, "Add":U, oNestedInstance) .
                    END.
                END.
                ELSE DO:                                                           
                    /* Mike Fechner, Consultingwerk Ltd. 02.01.2013
                       When we are using the type information from the JsonObject,
                       this is a mandatory attribute in the JsonObject. */
                    IF THIS-OBJECT:UseSerializedTypeInformation THEN DO:
                        pcType = phPropertyNode:GET-ATTRIBUTE ("SerializedType":U) .
                        
                        IF CharacterType:IsNullOrEmpty (pcType) THEN
                            UNDO, THROW NEW XmlSerializableException (SUBSTITUTE ("Unable to deserialize property &1 of &2 as it does not contain a XML Serialized object."{&TRAN},
                                                                                  pcProperty,
                                                                                  THIS-OBJECT:GetClass ():TypeName), 0,
                                                                      THIS-OBJECT:GetClass ():TypeName,
                                                                      pcProperty) .
                    END. 

                    oNestedInstance = DYNAMIC-NEW (pcType) ().
                    oNestedInstance:DeserializeFromNode (phPropertyNode) .
            
                    THIS-OBJECT:SetObjectProperty (pcProperty, oNestedInstance) .
                END.
            END.

	    END CASE . 
	       
	    FINALLY:
            GarbageCollectorHelper:DeleteObject (hChildObject) .		
        END FINALLY.
	       
	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns a value from a CHARACTER property in the property store                                                                        
        Notes:  
        @param pcPropertyName The name of the objects property
        @return The property value                                                                      
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED CHARACTER GetCharacterProperty (pcPropertyName AS CHARACTER):
        
        FIND ttSerializeProperties WHERE ttSerializeProperties.PropertyName = pcPropertyName
            NO-ERROR . 
            
        ERROR-STATUS:ERROR = FALSE NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN 
            RETURN "":U . /* Default */
        ELSE IF ttSerializeProperties.PropertyType <> "CHARACTER":U  THEN 
            UNDO, THROW NEW XmlSerializableException 
                      (SUBSTITUTE ("Property &1 is defined as &2. Cannot return as Character."{&TRAN}, 
                                   pcPropertyName, 
                                   ttSerializeProperties.PropertyType), 
                       0,
                       THIS-OBJECT:GetClass():TypeName,
                       pcPropertyName) .
    
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
            
        ERROR-STATUS:ERROR = FALSE NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN 
            RETURN ? . /* Default */
        ELSE IF ttSerializeProperties.PropertyType <> "DATE":U  THEN 
            UNDO, THROW NEW XmlSerializableException 
                      (SUBSTITUTE ("Property &1 is defined as &2. Cannot return as Date."{&TRAN}, 
                                   pcPropertyName, 
                                   ttSerializeProperties.PropertyType), 
                       0,
                       THIS-OBJECT:GetClass():TypeName,
                       pcPropertyName) .
    
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

        ERROR-STATUS:ERROR = FALSE NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN 
            RETURN ? . /* Default */
        ELSE IF ttSerializeProperties.PropertyType <> "DATETIME":U  THEN 
            UNDO, THROW NEW XmlSerializableException 
                      (SUBSTITUTE ("Property &1 is defined as &2. Cannot return as DateTime."{&TRAN}, 
                                   pcPropertyName, 
                                   ttSerializeProperties.PropertyType), 
                       0,
                       THIS-OBJECT:GetClass():TypeName,
                       pcPropertyName) .
    
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
            
        ERROR-STATUS:ERROR = FALSE NO-ERROR .             
            
        IF NOT AVAILABLE ttSerializeProperties THEN 
            RETURN ? . /* Default */
        ELSE IF ttSerializeProperties.PropertyType <> "DATETIME-TZ":U  THEN 
            UNDO, THROW NEW XmlSerializableException 
                      (SUBSTITUTE ("Property &1 is defined as &2. Cannot return as DateTime-TZ."{&TRAN}, 
                                   pcPropertyName, 
                                   ttSerializeProperties.PropertyType), 
                       0,
                       THIS-OBJECT:GetClass():TypeName,
                       pcPropertyName) .
    
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
            
        ERROR-STATUS:ERROR = FALSE NO-ERROR . 

        IF NOT AVAILABLE ttSerializeProperties THEN 
            RETURN 0 . /* Default */
        ELSE IF ttSerializeProperties.PropertyType <> "DECIMAL":U  THEN 
            UNDO, THROW NEW XmlSerializableException 
                      (SUBSTITUTE ("Property &1 is defined as &2. Cannot return as Decimal."{&TRAN}, 
                                   pcPropertyName, 
                                   ttSerializeProperties.PropertyType), 
                       0,
                       THIS-OBJECT:GetClass():TypeName,
                       pcPropertyName) .
    
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
            
        ERROR-STATUS:ERROR = FALSE NO-ERROR . 

        IF NOT AVAILABLE ttSerializeProperties THEN 
            RETURN 0 . /* Default */
        ELSE IF ttSerializeProperties.PropertyType <> "INTEGER":U  THEN 
            UNDO, THROW NEW XmlSerializableException 
                      (SUBSTITUTE ("Property &1 is defined as &2. Cannot return as Integer."{&TRAN}, 
                                   pcPropertyName, 
                                   ttSerializeProperties.PropertyType), 
                       0,
                       THIS-OBJECT:GetClass():TypeName,
                       pcPropertyName) .
    
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
            
        ERROR-STATUS:ERROR = FALSE NO-ERROR . 

        IF NOT AVAILABLE ttSerializeProperties THEN 
            RETURN 0 . /* Default */
        ELSE IF ttSerializeProperties.PropertyType <> "INT64":U  THEN 
            UNDO, THROW NEW XmlSerializableException 
                      (SUBSTITUTE ("Property &1 is defined as &2. Cannot return as Int64."{&TRAN}, 
                                   pcPropertyName, 
                                   ttSerializeProperties.PropertyType), 
                       0,
                       THIS-OBJECT:GetClass():TypeName,
                       pcPropertyName) .
    
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

        ERROR-STATUS:ERROR = FALSE NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN 
            RETURN FALSE . /* Default */
        ELSE IF ttSerializeProperties.PropertyType <> "LOGICAL":U  THEN 
            UNDO, THROW NEW XmlSerializableException 
                      (SUBSTITUTE ("Property &1 is defined as &2. Cannot return as Logical."{&TRAN}, 
                                   pcPropertyName, 
                                   ttSerializeProperties.PropertyType), 
                       0,
                       THIS-OBJECT:GetClass():TypeName,
                       pcPropertyName) .
    
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
            
        ERROR-STATUS:ERROR = FALSE NO-ERROR . 

        IF NOT AVAILABLE ttSerializeProperties THEN 
            RETURN "":U . /* Default */
        ELSE IF ttSerializeProperties.PropertyType <> "LONGCHAR":U  THEN 
            UNDO, THROW NEW XmlSerializableException 
                      (SUBSTITUTE ("Property &1 is defined as &2. Cannot return as Longchar."{&TRAN}, 
                                   pcPropertyName, 
                                   ttSerializeProperties.PropertyType), 
                       0,
                       THIS-OBJECT:GetClass():TypeName,
                       pcPropertyName) .
    
        COPY-LOB FROM ttSerializeProperties.LongCharValue TO lcReturn .
    
        RETURN lcReturn . 

    END METHOD.                    

    /*------------------------------------------------------------------------------
        Purpose: Returns a value from a Progress.Lang.Object property in the property store                                                                      
        Notes:        
        @param pcPropertyName The name of the objects property
        @return The property value (object reference)                                                                    
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED Progress.Lang.Object GetObjectProperty (pcPropertyName AS CHARACTER):
        
        DEFINE VARIABLE lcReturn AS LONGCHAR NO-UNDO.
        
        FIND ttSerializeProperties WHERE ttSerializeProperties.PropertyName = pcPropertyName
            NO-ERROR . 
            
        ERROR-STATUS:ERROR = FALSE NO-ERROR . 

        IF NOT AVAILABLE ttSerializeProperties THEN 
            RETURN ? . /* Default */
        ELSE IF ttSerializeProperties.PropertyType <> "OBJECT":U  THEN 
            UNDO, THROW NEW XmlSerializableException 
                      (SUBSTITUTE ("Property &1 is defined as &2. Cannot return as Object."{&TRAN}, 
                                   pcPropertyName, 
                                   ttSerializeProperties.PropertyType), 
                       0,
                       THIS-OBJECT:GetClass():TypeName,
                       pcPropertyName) .

        RETURN ttSerializeProperties.ObjectValue .
    
    END METHOD.  
    
    /*------------------------------------------------------------------------------
        Purpose: Returns a value from a RAW property in the property store                                                                      
        Notes:        
        @param pcPropertyName The name of the objects property
        @return The property value                                                                    
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED RAW GetRawProperty (pcPropertyName AS CHARACTER):
        
        DEFINE VARIABLE lcReturn AS LONGCHAR NO-UNDO.
        
        FIND ttSerializeProperties WHERE ttSerializeProperties.PropertyName = pcPropertyName
            NO-ERROR . 
            
        ERROR-STATUS:ERROR = FALSE NO-ERROR . 

        IF NOT AVAILABLE ttSerializeProperties THEN 
            RETURN ? . /* Default */
        ELSE IF ttSerializeProperties.PropertyType <> "RAW":U  THEN 
            UNDO, THROW NEW XmlSerializableException 
                      (SUBSTITUTE ("Property &1 is defined as &2. Cannot return as Raw."{&TRAN}, 
                                   pcPropertyName, 
                                   ttSerializeProperties.PropertyType), 
                       0,
                       THIS-OBJECT:GetClass():TypeName,
                       pcPropertyName) .
    
        RETURN ttSerializeProperties.RawValue . 

    END METHOD.                    
    
    /*------------------------------------------------------------------------------
        Purpose: Returns the type of a property
        Notes:   Throws an error, when the property is unknown
        @param pcProperty The name of the property
        @return The type of the property
    ------------------------------------------------------------------------------*/
	METHOD PROTECTED CHARACTER PropertyType (pcProperty AS CHARACTER):
		
        DEFINE VARIABLE i               AS INTEGER              NO-UNDO .
        DEFINE VARIABLE cProperty       AS CHARACTER            NO-UNDO .
        DEFINE VARIABLE cType           AS CHARACTER            NO-UNDO .
        
        DO i = 1 TO NUM-ENTRIES (THIS-OBJECT:SerializableProperties) BY 2:
            ASSIGN cProperty = ENTRY (i, THIS-OBJECT:SerializableProperties) 
                   cType     = ENTRY (i + 1, THIS-OBJECT:SerializableProperties).
		
		    IF pcProperty = cProperty THEN 
		        RETURN cType . 
		END.

        UNDO, THROW NEW XmlSerializableException 
                  (SUBSTITUTE ("Property &1 is unknown in &2."{&TRAN}, 
                               pcProperty, 
                               THIS-OBJECT:GetClass():TypeName), 
                   0,
                   THIS-OBJECT:GetClass():TypeName,
                   pcProperty) .

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns an LONGCHAR representation of the object instance                                                                        
        Notes:          
        @return The LONGCHAR representation of the ISerializable objects data                                          
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC LONGCHAR Serialize ():

        DEFINE VARIABLE hDocument  AS HANDLE   NO-UNDO.
        DEFINE VARIABLE hRootNode  AS HANDLE   NO-UNDO.
        DEFINE VARIABLE lcDocument AS LONGCHAR NO-UNDO .

        DEFINE VARIABLE oNumericFormat AS Consultingwerk.NumericFormat NO-UNDO . 

        FIX-CODEPAGE (lcDocument) = "utf-8":U  .

        oNumericFormat = SessionHelper:GetNumericFormat () .

        SESSION:NUMERIC-FORMAT = "AMERICAN":U . 

        CREATE X-DOCUMENT hDocument . 
        
        hRootNode = THIS-OBJECT:Serialize (hDocument) .
    
        hDocument:SAVE ("LONGCHAR":U, lcDocument) .
    
        RETURN lcDocument . 

        CATCH err AS Progress.Lang.Error:
            IF TYPE-OF (err, XmlSerializableException) THEN 
                UNDO, THROW err .
             
            IF err:NumMessages > 0 THEN 
                UNDO, THROW NEW XmlSerializableException (err,
                                                          err:GetMessage(1),
                                                          err:GetMessageNum (1),
                                                          THIS-OBJECT:GetClass():TypeName,
                                                          ?) .
            ELSE 
                UNDO, THROW NEW XmlSerializableException (err,
                                                          THIS-OBJECT:GetClass():TypeName,
                                                          ?) .
                                                                                    
        END CATCH.

        FINALLY:
            GarbageCollectorHelper:DeleteObject (hRootNode) .       
            GarbageCollectorHelper:DeleteObject (hDocument) . 
            
            SessionHelper:SetNumericFormat (oNumericFormat) .
        END FINALLY.

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Serializes the properties of the current object instance to 
                 an existing X-NODEREF object
        Notes:   
        @param phParent The reference to the parent XML Node or Document
        @return The X-NODEREF with the properties of the serialized object
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC HANDLE Serialize (phParent AS HANDLE):
		
        DEFINE VARIABLE hRootNode AS HANDLE NO-UNDO.
        DEFINE VARIABLE hDocument AS HANDLE NO-UNDO.
		
		IF phParent:TYPE = WidgetTypeEnum:XDocument THEN 
		    hDocument = phParent . 
		ELSE 
		    hDocument = phParent:OWNER-DOCUMENT . 
		
		CREATE X-NODEREF hRootNode . 
		
        hDocument:CREATE-NODE (hRootNode, 
                               ClassHelper:ShortClassName(THIS-OBJECT:GetClass()), 
                               "ELEMENT":U).
                               
        phParent:APPEND-CHILD (hRootNode) .

        IF THIS-OBJECT:UseSerializedTypeInformation THEN 
            XmlHelper:InsertNodeAttribute (hRootNode,
                                           "SerializedType":U,
                                           THIS-OBJECT:GetClass():TypeName). 

        THIS-OBJECT:SerializeProperties (hRootNode) .
				
        RETURN hRootNode .

        CATCH err AS Progress.Lang.Error:
            IF TYPE-OF (err, XmlSerializableException) THEN 
                UNDO, THROW err .
             
            IF err:NumMessages > 0 THEN 
                UNDO, THROW NEW XmlSerializableException (err,
                                                          err:GetMessage(1),
                                                          err:GetMessageNum (1),
                                                          THIS-OBJECT:GetClass():TypeName,
                                                          ?) .
            ELSE 
                UNDO, THROW NEW XmlSerializableException (err,
                                                          THIS-OBJECT:GetClass():TypeName,
                                                          ?) .
                                                                                    
        END CATCH.

        FINALLY:
            IF VALID-HANDLE (hRootNode) THEN 
                DELETE OBJECT hRootNode .		
        END FINALLY.

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Serializes the properties of this object instance as child nodes of 
                 the given node
        Notes:   
        @param phObjectNode The reference to the X-NODEREF object that represents the node for the current instance
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC VOID SerializeProperties (phObjectNode AS HANDLE):
		
        FOR EACH ttSerializeProperties ON ERROR UNDO, THROW:

            THIS-OBJECT:SerializeProperty (phObjectNode,
                                           ttSerializeProperties.PropertyName,
                                           ttSerializeProperties.PropertyType) .
        END.

        CATCH err AS Progress.Lang.Error:
            IF TYPE-OF (err, XmlSerializableException) THEN 
                UNDO, THROW err .
             
            IF err:NumMessages > 0 THEN 
                UNDO, THROW NEW XmlSerializableException (err,
                                                          err:GetMessage(1),
                                                          err:GetMessageNum (1),
                                                          THIS-OBJECT:GetClass():TypeName,
                                                          ?) .
            ELSE 
                UNDO, THROW NEW XmlSerializableException (err,
                                                          THIS-OBJECT:GetClass():TypeName,
                                                          ?) .
                                                                                    
        END CATCH.

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Serializes a single property value to the current parent XmlNode
        Notes:   Allows to override the handling of individual properties during the
                 XmlSerialization
        @param phParentNode The reference to the parent XML Node
        @param pcProperty The name of the property in the JsonObject
        @param pcType The type of the property
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED VOID SerializeProperty (phParentNode AS HANDLE,
                                             pcProperty AS CHARACTER,
                                             pcType AS CHARACTER):
    		
        DEFINE VARIABLE hPropertyNode AS HANDLE               NO-UNDO.
        DEFINE VARIABLE hValueNode    AS HANDLE               NO-UNDO.

        DEFINE VARIABLE cValue        AS CHARACTER            NO-UNDO .
        DEFINE VARIABLE dtValue       AS DATE                 NO-UNDO .
        DEFINE VARIABLE dttValue      AS DATETIME             NO-UNDO .
        DEFINE VARIABLE dtttzValue    AS DATETIME-TZ          NO-UNDO .
        DEFINE VARIABLE deValue       AS DECIMAL              NO-UNDO .
        DEFINE VARIABLE i64Value      AS INT64                NO-UNDO .
        DEFINE VARIABLE iValue        AS INTEGER              NO-UNDO .
        DEFINE VARIABLE lValue        AS LOGICAL              NO-UNDO .
        DEFINE VARIABLE lcValue       AS LONGCHAR             NO-UNDO .
        DEFINE VARIABLE oObject       AS Progress.Lang.Object NO-UNDO .
        DEFINE VARIABLE rValue        AS RAW                  NO-UNDO . 
        DEFINE VARIABLE oList         AS IEnumerable          NO-UNDO .
        
        hPropertyNode = XmlHelper:InsertElementNode (phParentNode, pcProperty) .

        CASE pcType:
            WHEN "CHARACTER":U THEN DO:
                ASSIGN cValue = THIS-OBJECT:GetCharacterProperty (pcProperty) .
  
                hValueNode = XmlHelper:InsertTextNode (hPropertyNode, cValue) .
            END.
            WHEN "DATE":U THEN DO:
                ASSIGN dtValue = THIS-OBJECT:GetDateProperty (pcProperty) .
  
                hValueNode = XmlHelper:InsertTextNode (hPropertyNode, STRING (dtValue)) .
            END.
            WHEN "DATETIME":U THEN DO:
                ASSIGN dttValue = THIS-OBJECT:GetDateTimeProperty (pcProperty) .
  
                hValueNode = XmlHelper:InsertTextNode (hPropertyNode, STRING (dttValue)) .
            END.
            WHEN "DATETIME-TZ":U THEN DO:
                ASSIGN dtttzValue = THIS-OBJECT:GetDateTime-TZProperty (pcProperty) .
  
                hValueNode = XmlHelper:InsertTextNode (hPropertyNode, STRING (dtttzValue)) .
            END.
            WHEN "DECIMAL":U THEN DO:
                ASSIGN deValue = THIS-OBJECT:GetDecimalProperty (pcProperty) .
  
                hValueNode = XmlHelper:InsertTextNode (hPropertyNode, STRING (deValue)) .
            END.
            WHEN "INT64":U THEN DO:
                ASSIGN i64Value = THIS-OBJECT:GetInt64Property (pcProperty) .
  
                hValueNode = XmlHelper:InsertTextNode (hPropertyNode, STRING (i64Value)) .
            END.
            WHEN "INTEGER":U THEN DO:
                ASSIGN iValue = THIS-OBJECT:GetIntegerProperty (pcProperty) .
  
                hValueNode = XmlHelper:InsertTextNode (hPropertyNode, STRING (iValue)) .
            END.
            WHEN "LOGICAL":U THEN DO:
                ASSIGN lValue = THIS-OBJECT:GetLogicalProperty (pcProperty) .
  
                hValueNode = XmlHelper:InsertTextNode (hPropertyNode, STRING (lValue)) .
            END.
            WHEN "LONGCHAR":U THEN DO:
                ASSIGN lcValue = THIS-OBJECT:GetLongCharProperty (pcProperty) .
  
                hValueNode = XmlHelper:InsertTextNode (hPropertyNode, lcValue) .
            END.
            WHEN "RAW":U THEN DO:
                ASSIGN rValue = THIS-OBJECT:GetRawProperty (pcProperty) .
                
                IF LENGTH (rValue) > 0 THEN 
                    hValueNode = XmlHelper:InsertTextNode (hPropertyNode, rValue) .
            END.
            OTHERWISE DO:
                
                oObject = THIS-OBJECT:GetObjectProperty (pcProperty) .                
                
                IF VALID-OBJECT (oObject) THEN DO:
                    IF TYPE-OF (oObject, Enum) THEN DO:
                        IF THIS-OBJECT:SerializeNullValues OR oObject:ToString() > "":U THEN 
                            hValueNode = XmlHelper:InsertTextNode (hPropertyNode, oObject:ToString ()) .
                    END.
                    ELSE IF TYPE-OF (oObject, IEnumerable) THEN 
                    DO ON ERROR UNDO, THROW:
                        ASSIGN oList = CAST (oObject, IEnumerable). 

                        {Consultingwerk/foreachABL.i Progress.Lang.Object oItem in oList}
                            IF TYPE-OF (oItem, XmlSerializable) THEN DO:
                                hValueNode = CAST (oItem, XmlSerializable):Serialize (hPropertyNode) .
                            END.
                            ELSE
                                UNDO, THROW NEW XmlSerializableException (SUBSTITUTE ("Unable to serialize item in property &1 of &2.~nProperty is not a XmlSerializable object."{&TRAN},
                                                                                      pcProperty, 
                                                                                      THIS-OBJECT:GetClass():TypeName),
                                                                          0,
                                                                          THIS-OBJECT:GetClass():TypeName,
                                                                          pcProperty) .
                        END. 
                    END.
                    ELSE IF TYPE-OF (oObject, XmlSerializable) THEN DO:
                        IF THIS-OBJECT:UseSerializedTypeInformation THEN 
                            XmlHelper:InsertNodeAttribute (hPropertyNode,
                                                           "SerializedType":U,
                                                           oObject:GetClass():TypeName). 
                        
                        CAST (oObject, XmlSerializable):SerializeProperties (hPropertyNode) .
                    END.
                END.    
            END.
        END.        

        FINALLY:
            GarbageCollectorHelper:DeleteObject (hPropertyNode) .		
            GarbageCollectorHelper:DeleteObject (hValueNode) .       
        END FINALLY.

	END METHOD .

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
            
        ERROR-STATUS:ERROR = FALSE NO-ERROR . 

        IF NOT AVAILABLE ttSerializeProperties THEN DO: 
            CREATE ttSerializeProperties .
            ASSIGN ttSerializeProperties.PropertyName = pcPropertyName
                   ttSerializeProperties.PropertyType = "CHARACTER":U .
        END.
        ELSE IF ttSerializeProperties.PropertyType <> "CHARACTER":U  THEN 
            UNDO, THROW NEW XmlSerializableException 
                      (SUBSTITUTE ("Property &1 is already defined as &2. Cannot assign as Character."{&TRAN}, 
                                   pcPropertyName, 
                                   ttSerializeProperties.PropertyType), 
                       0,
                       THIS-OBJECT:GetClass():TypeName,
                       pcPropertyName) .
    
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
            
        ERROR-STATUS:ERROR = FALSE NO-ERROR . 

        IF NOT AVAILABLE ttSerializeProperties THEN DO: 
            CREATE ttSerializeProperties .
            ASSIGN ttSerializeProperties.PropertyName = pcPropertyName
                   ttSerializeProperties.PropertyType = "DATE":U .
        END.
        ELSE IF ttSerializeProperties.PropertyType <> "DATE":U  THEN 
            UNDO, THROW NEW XmlSerializableException 
                      (SUBSTITUTE ("Property &1 is already defined as &2. Cannot assign as Date."{&TRAN}, 
                                   pcPropertyName, 
                                   ttSerializeProperties.PropertyType), 
                       0,
                       THIS-OBJECT:GetClass():TypeName,
                       pcPropertyName) .
    
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
            
        ERROR-STATUS:ERROR = FALSE NO-ERROR . 

        IF NOT AVAILABLE ttSerializeProperties THEN DO: 
            CREATE ttSerializeProperties .
            ASSIGN ttSerializeProperties.PropertyName = pcPropertyName
                   ttSerializeProperties.PropertyType = "DATETIME":U .
        END.
        ELSE IF ttSerializeProperties.PropertyType <> "DATETIME":U  THEN 
            UNDO, THROW NEW XmlSerializableException 
                      (SUBSTITUTE ("Property &1 is already defined as &2. Cannot assign as DateTime."{&TRAN}, 
                                   pcPropertyName, 
                                   ttSerializeProperties.PropertyType), 
                       0,
                       THIS-OBJECT:GetClass():TypeName,
                       pcPropertyName) .
    
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
            
        ERROR-STATUS:ERROR = FALSE NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN DO: 
            CREATE ttSerializeProperties .
            ASSIGN ttSerializeProperties.PropertyName = pcPropertyName
                   ttSerializeProperties.PropertyType = "DATETIME-TZ":U .
        END.
        ELSE IF ttSerializeProperties.PropertyType <> "DATETIME-TZ":U  THEN 
            UNDO, THROW NEW XmlSerializableException 
                      (SUBSTITUTE ("Property &1 is already defined as &2. Cannot assign as DateTime-TZ."{&TRAN}, 
                                   pcPropertyName, 
                                   ttSerializeProperties.PropertyType), 
                       0,
                       THIS-OBJECT:GetClass():TypeName,
                       pcPropertyName) .
    
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

        ERROR-STATUS:ERROR = FALSE NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN DO: 
            CREATE ttSerializeProperties .
            ASSIGN ttSerializeProperties.PropertyName = pcPropertyName
                   ttSerializeProperties.PropertyType = "DECIMAL":U .
        END.
        ELSE IF ttSerializeProperties.PropertyType <> "DECIMAL":U  THEN 
            UNDO, THROW NEW XmlSerializableException 
                      (SUBSTITUTE ("Property &1 is already defined as &2. Cannot assign as Decimal."{&TRAN}, 
                                   pcPropertyName, 
                                   ttSerializeProperties.PropertyType), 
                       0,
                       THIS-OBJECT:GetClass():TypeName,
                       pcPropertyName) .
    
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

        ERROR-STATUS:ERROR = FALSE NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN DO: 
            CREATE ttSerializeProperties .
            ASSIGN ttSerializeProperties.PropertyName = pcPropertyName
                   ttSerializeProperties.PropertyType = "INTEGER":U .
        END.
        ELSE IF ttSerializeProperties.PropertyType <> "INTEGER":U  THEN 
            UNDO, THROW NEW XmlSerializableException 
                      (SUBSTITUTE ("Property &1 is already defined as &2. Cannot assign as Integer."{&TRAN}, 
                                   pcPropertyName, 
                                   ttSerializeProperties.PropertyType), 
                       0,
                       THIS-OBJECT:GetClass():TypeName,
                       pcPropertyName) .
    
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
            
        ERROR-STATUS:ERROR = FALSE NO-ERROR . 

        IF NOT AVAILABLE ttSerializeProperties THEN DO: 
            CREATE ttSerializeProperties .
            ASSIGN ttSerializeProperties.PropertyName = pcPropertyName
                   ttSerializeProperties.PropertyType = "INT64":U .
        END.
        ELSE IF ttSerializeProperties.PropertyType <> "INT64":U  THEN 
            UNDO, THROW NEW XmlSerializableException 
                      (SUBSTITUTE ("Property &1 is already defined as &2. Cannot assign as Int64."{&TRAN}, 
                                   pcPropertyName, 
                                   ttSerializeProperties.PropertyType), 
                       0,
                       THIS-OBJECT:GetClass():TypeName,
                       pcPropertyName) .
    
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

        ERROR-STATUS:ERROR = FALSE NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN DO: 
            CREATE ttSerializeProperties .
            ASSIGN ttSerializeProperties.PropertyName = pcPropertyName
                   ttSerializeProperties.PropertyType = "LOGICAL":U .
        END.
        ELSE IF ttSerializeProperties.PropertyType <> "LOGICAL":U  THEN 
            UNDO, THROW NEW XmlSerializableException 
                      (SUBSTITUTE ("Property &1 is already defined as &2. Cannot assign as Logical."{&TRAN}, 
                                   pcPropertyName, 
                                   ttSerializeProperties.PropertyType), 
                       0,
                       THIS-OBJECT:GetClass():TypeName,
                       pcPropertyName) .
    
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

        ERROR-STATUS:ERROR = FALSE NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN DO: 
            CREATE ttSerializeProperties .
            ASSIGN ttSerializeProperties.PropertyName = pcPropertyName
                   ttSerializeProperties.PropertyType = "LONGCHAR":U .
        END.
        ELSE IF ttSerializeProperties.PropertyType <> "LONGCHAR":U  THEN 
            UNDO, THROW NEW XmlSerializableException 
                      (SUBSTITUTE ("Property &1 is already defined as &2. Cannot assign as Longchar."{&TRAN}, 
                                   pcPropertyName, 
                                   ttSerializeProperties.PropertyType), 
                       0,
                       THIS-OBJECT:GetClass():TypeName,
                       pcPropertyName) .

        COPY-LOB FROM plcValue TO ttSerializeProperties.LongCharValue . 
        RELEASE ttSerializeProperties .

    END METHOD. 
    
    /*------------------------------------------------------------------------------
        Purpose: Assigns a Progress.Lang.Object property in the property store                                                                       
        Notes:      
        @param pcPropertyName The name of the objects property
        @param poValue The object reference as the value of the objects property
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED VOID SetObjectProperty (pcPropertyName AS CHARACTER,
                                             poValue AS Progress.Lang.Object):
        
        FIND ttSerializeProperties WHERE ttSerializeProperties.PropertyName = pcPropertyName
            NO-ERROR . 

        ERROR-STATUS:ERROR = FALSE NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN DO: 
            CREATE ttSerializeProperties .
            ASSIGN ttSerializeProperties.PropertyName = pcPropertyName
                   ttSerializeProperties.PropertyType = "OBJECT":U .
        END.
        ELSE IF ttSerializeProperties.PropertyType <> "OBJECT":U  THEN 
            UNDO, THROW NEW XmlSerializableException 
                      (SUBSTITUTE ("Property &1 is already defined as &2. Cannot assign as Object."{&TRAN}, 
                                   pcPropertyName, 
                                   ttSerializeProperties.PropertyType), 
                       0,
                       THIS-OBJECT:GetClass():TypeName,
                       pcPropertyName) .
    
        ASSIGN ttSerializeProperties.ObjectValue = poValue . 
        RELEASE ttSerializeProperties .

    END METHOD.
        
    /*------------------------------------------------------------------------------
        Purpose: Assigns a RAW property in the property store                                                                       
        Notes:      
        @param pcPropertyName The name of the objects property
        @param prValue The value of the objects property
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED VOID SetRawProperty (pcPropertyName AS CHARACTER,
                                          prValue AS RAW):
        
        FIND ttSerializeProperties WHERE ttSerializeProperties.PropertyName = pcPropertyName
            NO-ERROR . 

        ERROR-STATUS:ERROR = FALSE NO-ERROR . 
            
        IF NOT AVAILABLE ttSerializeProperties THEN DO: 
            CREATE ttSerializeProperties .
            ASSIGN ttSerializeProperties.PropertyName = pcPropertyName
                   ttSerializeProperties.PropertyType = "RAW":U .
        END.
        ELSE IF ttSerializeProperties.PropertyType <> "RAW":U  THEN 
            UNDO, THROW NEW XmlSerializableException 
                      (SUBSTITUTE ("Property &1 is already defined as &2. Cannot assign as Raw."{&TRAN}, 
                                   pcPropertyName, 
                                   ttSerializeProperties.PropertyType), 
                       0,
                       THIS-OBJECT:GetClass():TypeName,
                       pcPropertyName) .
    
        ASSIGN ttSerializeProperties.RawValue = prValue . 

        RELEASE ttSerializeProperties .

    END METHOD.

	/*------------------------------------------------------------------------------
        Purpose: Returns an LONGCHAR representation of the object instance                                                                        
        Notes:   This method is a facade to the XmlSerializable:Serialize method          
        @return The LONGCHAR representation of the ISerializable objects data                                          
	------------------------------------------------------------------------------*/
	METHOD PUBLIC LONGCHAR WriteXml ():
		
		RETURN THIS-OBJECT:Serialize () . 

	END METHOD.
        
END CLASS.
