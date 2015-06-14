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
    File        : JsonSerializable
    Purpose     : Implements serialization functionality i.e. for parameter 
                  object to be passed around the AppServer boundary
    Syntax      : 
    Description : Serialization based on the JSON object model (OpenEdge 11.0)
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Wed Sep 15 18:25:22 CEST 2010
    Notes       : See comments in Consultingwerk/JsonSerializableProperty.i 
                  for usage instructions
                  This class also supports XML output - which is used for 
                  migrating SmartFramework data (e.g. menu functions) from 
                  JSON to XML
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{ Consultingwerk/products.i }

USING Consultingwerk.*                FROM PROPATH .
USING Consultingwerk.Framework.Base.* FROM PROPATH . 
USING Consultingwerk.Util.*           FROM PROPATH . 
USING Progress.Json.ObjectModel.*     FROM PROPATH . 
USING Progress.Lang.*                 FROM PROPATH .

CLASS Consultingwerk.JsonSerializable 
    IMPLEMENTS IJsonSerializable 
    {&SERIALIZABLE}
    ABSTRACT: 

    /*------------------------------------------------------------------------------
        Purpose: Gets and sets the reference to a custom JsonDateTypeFormatter 
        Notes:   Workaround for the fact, that there is no actual standard 
                 for date representation in Json and if may be required to provide
                 custom formatting based on the target system (e.g. JIRA)
    ------------------------------------------------------------------------------*/
	DEFINE PUBLIC PROPERTY JsonDateTypeFormatter AS IJsonDateTypeFormatter NO-UNDO 
	GET.
	SET. 

    /*------------------------------------------------------------------------------
        Purpose: Gets and sets if Null-Values should be serialized                                                                 
        Notes:   Some REST servers may have issues with serializing Null values. 
                 Settings this property to TRUE will keep Null-Values from being
                 Serialized
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY SerializeNullValues AS LOGICAL INITIAL FALSE NO-UNDO 
    GET.
    SET. 

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
        Purpose: Deserializes a LONGCHAR representation of the state of the class instance                                                                      
        Notes: 
        @param pcSerializedReprasentation The stored LONGCHAR representation of the objects data                                                                                          
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID Deserialize (INPUT pcSerializedReprasentation AS LONGCHAR):

        DEFINE VARIABLE oJsonObject  AS JsonObject        NO-UNDO . 
        DEFINE VARIABLE oObjectModel AS ObjectModelParser NO-UNDO . 
        DEFINE VARIABLE oFormat      AS NumericFormat     NO-UNDO . 

        /* SCL-415: Perform JSON Serialization/Deserialization with AMERICAN
                    numeric format to avoid issues with decimal point interpretation */            
        oFormat = SessionHelper:GetNumericFormat() .
        SessionHelper:SetDefaultNumericFormat() .            
                    
        oObjectModel = NEW ObjectModelParser () .
        
        oJsonObject = CAST (oObjectModel:Parse (pcSerializedReprasentation), JsonObject). 

        THIS-OBJECT:DeserializeFromJsonObject (oJsonObject) .

        FINALLY:
            IF VALID-OBJECT (oFormat) THEN 
                SessionHelper:SetNumericFormat (oFormat) .            
            
            GarbageCollectorHelper:DeleteObject (oObjectModel) .
            GarbageCollectorHelper:DeleteObject (oJsonObject) .     
        END FINALLY.

    END METHOD.
                
    /*------------------------------------------------------------------------------
        Purpose: Initializes the object instance based on the passed in JsonObject
                 representation of the object instance                                                                      
        Notes:               
        @param poJsonObject The stored JsonObject representation of the objects data                                                          
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID DeserializeFromJsonObject (poJsonObject AS JsonObject):
        
        DEFINE VARIABLE i               AS INTEGER              NO-UNDO .
        DEFINE VARIABLE cProperty       AS CHARACTER            NO-UNDO .
        DEFINE VARIABLE cType           AS CHARACTER            NO-UNDO .
        
        DO i = 1 TO NUM-ENTRIES (THIS-OBJECT:SerializableProperties) BY 2:
            ASSIGN cProperty = ENTRY (i, THIS-OBJECT:SerializableProperties) 
                   cType     = ENTRY (i + 1, THIS-OBJECT:SerializableProperties).
          
            /* 22/01/2013 - Thomas Hansen, appSolutions a|s
               Only process the property if it is in the JSON object */
            IF NOT poJsonObject:Has (cProperty) THEN 
                NEXT.           

            /* Mike Fechner, Consultingwerk Ltd. 26.01.2013
               Moved to method DeserializeProperty to allow easier overriding of
               individual properties handling */
            THIS-OBJECT:DeserializeProperty (poJsonObject, 
                                             cProperty,
                                             cType) .
          
        END.

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Deserializes a single property value to the current JsonObject
        Notes:   Allows to override the handling of individual properties during the
                 JsonSerialization
        Notes:   
        @param poJsonObject The reference to the source JsonObject
        @param pcProperty The name of the property in the JsonObject
        @param pcType The type of the property
    ------------------------------------------------------------------------------*/
	METHOD PROTECTED VOID DeserializeProperty (poJsonObject AS JsonObject,
                                               pcProperty AS CHARACTER,
                                               pcType AS CHARACTER):
		
        DEFINE VARIABLE iItem           AS INTEGER              NO-UNDO .
        DEFINE VARIABLE cItemType       AS CHARACTER            NO-UNDO .
        
        DEFINE VARIABLE oNestedJson     AS JsonObject           NO-UNDO .
        DEFINE VARIABLE oNestedArray    AS JsonArray            NO-UNDO . 
        DEFINE VARIABLE oNestedInstance AS IJsonSerializable    NO-UNDO .
        DEFINE VARIABLE oList           AS Object               NO-UNDO .  
        DEFINE VARIABLE iIndex          AS INTEGER              NO-UNDO .
        DEFINE VARIABLE iLength         AS INTEGER              NO-UNDO .
        DEFINE VARIABLE oArray          AS Progress.Lang.Object NO-UNDO EXTENT . 
        DEFINE VARIABLE cTempType       AS CHARACTER            NO-UNDO .

		DEFINE VARIABLE oNullReference  AS Progress.Lang.Object NO-UNDO . 
		
        Consultingwerk.Assertion.ObjectAssert:IsValid (poJsonObject, "Json Object":U) .
        
        ASSIGN cTempType = DataTypeHelper:UnabbreviateDataTypeName (pcType) .
        
        IF cTempType <> ? THEN 
            ASSIGN pcType = cTempType . 	

        CASE pcType:
            WHEN "CHARACTER":U THEN 
                DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) = poJsonObject:GetCharacter (pcProperty) .
            WHEN "DATE":U THEN DO:
                IF VALID-OBJECT (THIS-OBJECT:JsonDateTypeFormatter) THEN 
                    DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) = THIS-OBJECT:JsonDateTypeFormatter:GetDate (poJsonObject, pcProperty) . 
                ELSE
                    DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) = poJsonObject:GetDate (pcProperty) .
            END.
            WHEN "DATETIME":U THEN DO:
                IF VALID-OBJECT (THIS-OBJECT:JsonDateTypeFormatter) THEN 
                    DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) = THIS-OBJECT:JsonDateTypeFormatter:GetDateTime (poJsonObject, pcProperty) . 
                ELSE
                    DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) = poJsonObject:GetDateTime (pcProperty) .
            END.
            WHEN "DATETIME-TZ":U THEN DO: 
                IF VALID-OBJECT (THIS-OBJECT:JsonDateTypeFormatter) THEN 
                    DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) = THIS-OBJECT:JsonDateTypeFormatter:GetDateTimeTZ (poJsonObject, pcProperty) . 
                ELSE
                DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) = poJsonObject:GetDateTimeTZ (pcProperty) .
            END.
            WHEN "DECIMAL":U THEN 
                DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) = poJsonObject:GetDecimal (pcProperty) .
            WHEN "INT64":U THEN 
                DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) = poJsonObject:GetInt64 (pcProperty) .
            WHEN "INTEGER":U THEN 
                DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) = poJsonObject:GetInteger (pcProperty) .
            WHEN "LOGICAL":U THEN 
                DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) = poJsonObject:GetLogical (pcProperty) .
            WHEN "LONGCHAR":U THEN 
                DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) = poJsonObject:GetLongchar (pcProperty) .
            WHEN "RAW":U THEN 
                DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) = poJsonObject:GetRaw (pcProperty) .
            WHEN "RECID":U THEN 
                DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) = poJsonObject:GetRecid (pcProperty) .
            WHEN "ROWID":U THEN 
                DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) = poJsonObject:GetRowid (pcProperty) .
            OTHERWISE DO:
                /* extent property */
                IF poJsonObject:Has (pcProperty) AND NOT poJsonObject:IsNull (pcProperty) AND 
                   NUM-ENTRIES (pcType, " ":U) = 2 AND ENTRY (2, pcType, " ":U) = "EXTENT":U THEN DO: 
                    
                    ASSIGN 
                        oNestedArray = poJsonObject:GetJsonArray(pcProperty)
                        iLength      = oNestedArray:Length .
                    
                    IF iLength > 0 THEN DO:
                        
                        EXTENT (oArray) = ?.
                        EXTENT (oArray) = iLength .  
                        
                        DO iIndex = 1 TO iLength:

                            oNestedJson = oNestedArray:GetJsonObject (iIndex) .

                            /* Mike Fechner, Consultingwerk Ltd. 02.01.2013
                               When we are using the type information from the JsonObject,
                               this is a mandatory attribute in the JsonObject. */
                            IF THIS-OBJECT:UseSerializedTypeInformation THEN DO:
                                IF NOT oNestedJson:Has ("SerializedType":U) THEN
                                    UNDO, THROW NEW AppError (SUBSTITUTE ("Unable to deserialize property &1 of &2 as it does not contain a Json Serialized object."{&TRAN},
                                                                          pcProperty,
                                                                          THIS-OBJECT:GetClass ():TypeName), 0) .
                                ELSE 
                                    ASSIGN cItemType = oNestedJson:GetCharacter ("SerializedType":U) . 
                            END. 
                            ELSE 
                                cItemType = ENTRY (1, pcType, " ":U) .

                            oNestedInstance = DYNAMIC-NEW (cItemType) ().
                            oNestedInstance:DeserializeFromJsonObject (oNestedJson) .

                            oArray [iIndex] = oNestedInstance .
                        END.
                        
                        DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) = oArray . 
                    END.  
                END.
                ELSE DO:                    
                    IF poJsonObject:Has (pcProperty) AND NOT poJsonObject:IsNull (pcProperty) THEN DO:                        
                        /* Test for Enum */
                        IF Progress.Lang.Class:GetClass (pcType):IsA ("Consultingwerk.Enum":U) THEN DO:
                            DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) = 
                                DYNAMIC-PROPERTY (pcType, poJsonObject:GetCharacter (pcProperty)) .
                        END. 
                        ELSE IF Progress.Lang.Class:GetClass (pcType):IsA ("Consultingwerk.Framework.Base.IEnumerable":U) THEN DO:
                            oNestedArray = poJsonObject:GetJsonArray (pcProperty) .
                            
                            oList = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) . 
                            
                            DO iItem = 1 TO oNestedArray:Length:
                                oNestedJson = oNestedArray:GetJsonObject (iItem) .
                                
                                IF NOT oNestedJson:Has ("SerializedType":U) THEN 
                                    UNDO, THROW NEW AppError (SUBSTITUTE ("Unable to deserialize property &1 of &2 as it does not contain a Json Serialized object."{&TRAN}, 
                                                                          pcProperty,
                                                                          THIS-OBJECT:GetClass ():TypeName), 0) . 
                        
                                oNestedInstance = DYNAMIC-NEW (oNestedJson:GetCharacter ("SerializedType":U)) ().
                                oNestedInstance:DeserializeFromJsonObject (oNestedJson) .
                                
                                DYNAMIC-INVOKE (oList, "Add":U, oNestedInstance) .
                            END.
                        END.
                        ELSE DO:                                                           
                            oNestedJson = poJsonObject:GetJsonObject (pcProperty) .

                            /* Mike Fechner, Consultingwerk Ltd. 02.01.2013
                               When we are using the type information from the JsonObject,
                               this is a mandatory attribute in the JsonObject. */
                            IF THIS-OBJECT:UseSerializedTypeInformation THEN DO:
                                IF NOT oNestedJson:Has ("SerializedType":U) THEN
                                    UNDO, THROW NEW AppError (SUBSTITUTE ("Unable to deserialize property &1 of &2 as it does not contain a Json Serialized object."{&TRAN},
                                                                          pcProperty,
                                                                          THIS-OBJECT:GetClass ():TypeName), 0) .
                                ELSE 
                                    ASSIGN pcType = oNestedJson:GetCharacter ("SerializedType":U) . 
                            END. 

                            oNestedInstance = DYNAMIC-NEW (pcType) ().
                            oNestedInstance:DeserializeFromJsonObject (oNestedJson) .
                    
                            DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) = oNestedInstance .
                        END.
                    END.
                    ELSE
                        /* Mike Fechner, Consultingwerk Ltd. 21.08.2013
                           OpenEdge 11.3 raises an issue, when assigning ? here, 
                           so we are instead assigning a variable with no object 
                           reference */
                        DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) = oNullReference .
                END. 
            END.
        END CASE . 

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns a LONGCHAR representation of the state of the class instance                                                                      
        Notes:   Returns the classname together with the Json serialization 
        @return The LONGCHAR representation of the ISerializable objects data                                                                               
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LONGCHAR Serialize ():
        
        DEFINE VARIABLE lcReturn    AS LONGCHAR      NO-UNDO .
        DEFINE VARIABLE oJsonObject AS JsonObject    NO-UNDO . 
        DEFINE VARIABLE oFormat     AS NumericFormat NO-UNDO . 

        /* SCL-415: Perform JSON Serialization/Deserialization with AMERICAN
                    numeric format to avoid issues with decimal point interpretation */            
        oFormat = SessionHelper:GetNumericFormat() .
        SessionHelper:SetDefaultNumericFormat() .            
            
        oJsonObject = THIS-OBJECT:ToJsonObject() .

        oJsonObject:Write (INPUT-OUTPUT lcReturn, TRUE)  .

        RETURN lcReturn . 

        FINALLY:
            IF VALID-OBJECT (oFormat) THEN 
                SessionHelper:SetNumericFormat (oFormat) . 
            
            GarbageCollectorHelper:DeleteObject (oJsonObject) .        
        END FINALLY.

    END METHOD.
     
    /*------------------------------------------------------------------------------
        Purpose: Serializes a single property value to the current JsonObject
        Notes:   Allows to override the handling of individual properties during the
                 JsonSerialization
        @param poJsonObject The reference to the target JsonObject
        @param pcProperty The name of the property in the JsonObject
        @param pcType The type of the property
    ------------------------------------------------------------------------------*/
	METHOD PROTECTED VOID SerializeProperty (poJsonObject AS JsonObject,
                                             pcProperty AS CHARACTER,
                                             pcType AS CHARACTER):
		
        DEFINE VARIABLE oJsonArray    AS JsonArray            NO-UNDO .
        DEFINE VARIABLE oJsonItem     AS JsonObject           NO-UNDO .
        DEFINE VARIABLE oList         AS IEnumerable          NO-UNDO . 
                                                                            
        DEFINE VARIABLE cValue        AS CHARACTER            NO-UNDO .
        DEFINE VARIABLE dtValue       AS DATE                 NO-UNDO .
        DEFINE VARIABLE dttValue      AS DATETIME             NO-UNDO .
        DEFINE VARIABLE dtttzValue    AS DATETIME-TZ          NO-UNDO .
        DEFINE VARIABLE deValue       AS DECIMAL              NO-UNDO .
        DEFINE VARIABLE i64Value      AS INT64                NO-UNDO .
        DEFINE VARIABLE iValue        AS INTEGER              NO-UNDO .
        DEFINE VARIABLE lValue        AS LOGICAL              NO-UNDO .
        DEFINE VARIABLE lcValue       AS LONGCHAR             NO-UNDO . 
        DEFINE VARIABLE roValue       AS ROWID                NO-UNDO .
        DEFINE VARIABLE rawValue      AS RAW                  NO-UNDO .
        DEFINE VARIABLE recidValue    AS RECID                NO-UNDO . 

        DEFINE VARIABLE oObject       AS Progress.Lang.Object NO-UNDO .
                                      
        DEFINE VARIABLE cValueExt     AS CHARACTER   EXTENT   NO-UNDO .
        DEFINE VARIABLE dtValueExt    AS DATE        EXTENT   NO-UNDO .
        DEFINE VARIABLE dttValueExt   AS DATETIME    EXTENT   NO-UNDO .
        DEFINE VARIABLE dtttzValueExt AS DATETIME-TZ EXTENT   NO-UNDO .
        DEFINE VARIABLE deValueExt    AS DECIMAL     EXTENT   NO-UNDO .
        DEFINE VARIABLE i64ValueExt   AS INT64       EXTENT   NO-UNDO .
        DEFINE VARIABLE iValueExt     AS INTEGER     EXTENT   NO-UNDO .
        DEFINE VARIABLE lValueExt     AS LOGICAL     EXTENT   NO-UNDO .
        DEFINE VARIABLE lcValueExt    AS LONGCHAR    EXTENT   NO-UNDO . 
        DEFINE VARIABLE roValueExt    AS ROWID       EXTENT   NO-UNDO .
        DEFINE VARIABLE rawValueExt   AS RAW         EXTENT   NO-UNDO .
        DEFINE VARIABLE recidValueExt AS RECID       EXTENT   NO-UNDO . 
                                      
        DEFINE VARIABLE cTempType     AS CHARACTER            NO-UNDO .
        
        ASSIGN cTempType = DataTypeHelper:UnabbreviateDataTypeName (pcType) .
        
        IF cTempType <> ? THEN 
            ASSIGN pcType = cTempType . 
        
		Consultingwerk.Assertion.ObjectAssert:IsValid (poJsonObject, "Json Object":U) .
	
        CASE pcType:
            WHEN "CHARACTER":U THEN DO:
                ASSIGN cValue = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) . 
                
                IF THIS-OBJECT:SerializeNullValues OR cValue > "":U THEN 
                    poJsonObject:Add (pcProperty, cValue) .
            END.
            WHEN "CHARACTER EXTENT":U THEN DO:
                ASSIGN cValueExt = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) . 

                IF THIS-OBJECT:SerializeNullValues OR EXTENT (cValueExt) > 0 THEN DO: 
                    ASSIGN oJsonArray = NEW JsonArray () . 
                
                    oJsonArray:Add (cValueExt) .
                    poJsonObject:Add (pcProperty, oJsonArray) .
                    oJsonArray = ? . 
                END.
            END.
            WHEN "DATE":U THEN DO:
                ASSIGN dtValue = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) . 
                
                IF THIS-OBJECT:SerializeNullValues OR dtValue <> ? THEN 
                    IF VALID-OBJECT (THIS-OBJECT:JsonDateTypeFormatter) THEN 
                        THIS-OBJECT:JsonDateTypeFormatter:Add (poJsonObject, pcProperty, dtValue) .
                    ELSE                          
                        poJsonObject:Add (pcProperty, dtValue) .
            END.
            WHEN "DATE EXTENT":U THEN DO:
                ASSIGN dtValueExt = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) . 

                IF THIS-OBJECT:SerializeNullValues OR EXTENT (dtValueExt) > 0 THEN DO: 
                    ASSIGN oJsonArray = NEW JsonArray () . 
                
                    oJsonArray:Add (dtValueExt) .
                    poJsonObject:Add (pcProperty, oJsonArray) .
                    oJsonArray = ? . 
                END.
            END.
            WHEN "DATETIME":U THEN DO:
                ASSIGN dttValue = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) . 
                
                IF THIS-OBJECT:SerializeNullValues OR dttValue <> ? THEN 
                    IF VALID-OBJECT (THIS-OBJECT:JsonDateTypeFormatter) THEN 
                        THIS-OBJECT:JsonDateTypeFormatter:Add (poJsonObject, pcProperty, dttValue) .
                    ELSE                          
                        poJsonObject:Add (pcProperty, dttValue) .
            END.
            WHEN "DATETIME EXTENT":U THEN DO:
                ASSIGN dttValueExt = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) . 

                IF THIS-OBJECT:SerializeNullValues OR EXTENT (dttValueExt) > 0 THEN DO: 
                    ASSIGN oJsonArray = NEW JsonArray () . 
                
                    oJsonArray:Add (dttValueExt) .
                    poJsonObject:Add (pcProperty, oJsonArray) .
                    oJsonArray = ? . 
                END.
            END.
            WHEN "DATETIME-TZ":U THEN DO:
                ASSIGN dtttzValue = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) . 
                
                IF THIS-OBJECT:SerializeNullValues OR dtttzValue <> ? THEN 
                    IF VALID-OBJECT (THIS-OBJECT:JsonDateTypeFormatter) THEN 
                        THIS-OBJECT:JsonDateTypeFormatter:Add (poJsonObject, pcProperty, dtttzValue) .
                    ELSE                          
                        poJsonObject:Add (pcProperty, dtttzValue) .
            END.
            WHEN "DATETIME-TZ EXTENT":U THEN DO:
                ASSIGN dtttzValueExt = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) . 

                IF THIS-OBJECT:SerializeNullValues OR EXTENT (dtttzValueExt) > 0 THEN DO: 
                    ASSIGN oJsonArray = NEW JsonArray () . 
                
                    oJsonArray:Add (dtttzValueExt) .
                    poJsonObject:Add (pcProperty, oJsonArray) .
                    oJsonArray = ? . 
                END.
            END.
            WHEN "DECIMAL":U THEN DO:
                ASSIGN deValue = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) . 
                
                IF THIS-OBJECT:SerializeNullValues OR deValue <> ? THEN 
                    poJsonObject:Add (pcProperty, deValue) .
            END.
            WHEN "DECIMAL EXTENT":U THEN DO:
                ASSIGN deValueExt = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) . 

                IF THIS-OBJECT:SerializeNullValues OR EXTENT (deValueExt) > 0 THEN DO: 
                    ASSIGN oJsonArray = NEW JsonArray () . 
                
                    oJsonArray:Add (deValueExt) .
                    poJsonObject:Add (pcProperty, oJsonArray) .
                    oJsonArray = ? . 
                END.
            END.
            WHEN "INT64":U THEN DO:
                ASSIGN i64Value = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) . 
                
                IF THIS-OBJECT:SerializeNullValues OR i64Value <> ? THEN  
                    poJsonObject:Add (pcProperty, i64Value) .
            END.
            WHEN "INT64 EXTENT":U THEN DO:
                ASSIGN i64ValueExt = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) . 

                IF THIS-OBJECT:SerializeNullValues OR EXTENT (i64ValueExt) > 0 THEN DO: 
                    ASSIGN oJsonArray = NEW JsonArray () . 
                
                    oJsonArray:Add (i64ValueExt) .
                    poJsonObject:Add (pcProperty, oJsonArray) .
                    oJsonArray = ? . 
                END.
            END.
            WHEN "INTEGER":U THEN DO:
                ASSIGN iValue = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) . 
                
                IF THIS-OBJECT:SerializeNullValues OR iValue <> ? THEN 
                    poJsonObject:Add (pcProperty, iValue) .
            END.
            WHEN "INTEGER EXTENT":U THEN DO:
                ASSIGN iValueExt = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) . 

                IF THIS-OBJECT:SerializeNullValues OR EXTENT (iValueExt) > 0 THEN DO: 
                    ASSIGN oJsonArray = NEW JsonArray () . 
                
                    oJsonArray:Add (iValueExt) .
                    poJsonObject:Add (pcProperty, oJsonArray) .
                    oJsonArray = ? . 
                END.
            END.
            WHEN "LOGICAL":U THEN DO:
                ASSIGN lValue = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) . 
                
                IF THIS-OBJECT:SerializeNullValues OR lValue <> ? THEN 
                    poJsonObject:Add (pcProperty, lValue) .
            END.
            WHEN "LOGICAL EXTENT":U THEN DO:
                ASSIGN lValueExt = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) . 

                IF THIS-OBJECT:SerializeNullValues OR EXTENT (lValueExt) > 0 THEN DO: 
                    ASSIGN oJsonArray = NEW JsonArray () . 
                
                    oJsonArray:Add (lValueExt) .
                    poJsonObject:Add (pcProperty, oJsonArray) .
                    oJsonArray = ? . 
                END.
            END.
            WHEN "LONGCHAR":U THEN DO:
                ASSIGN lcValue  = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) .
               
                IF THIS-OBJECT:SerializeNullValues OR lcValue > "":U THEN 
                    poJsonObject:Add (pcProperty, lcValue) .
            END.
            WHEN "LONGCHAR EXTENT":U THEN DO:
                ASSIGN lcValueExt = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) . 

                IF THIS-OBJECT:SerializeNullValues OR EXTENT (lcValueExt) > 0 THEN DO: 
                    ASSIGN oJsonArray = NEW JsonArray () . 
                
                    oJsonArray:Add (lcValueExt) .
                    poJsonObject:Add (pcProperty, oJsonArray) .
                    oJsonArray = ? . 
                END.
            END.
            WHEN "RAW":U THEN DO:
                ASSIGN rawValue = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) .
                
                IF THIS-OBJECT:SerializeNullValues OR rawValue <> ? THEN 
                    poJsonObject:Add (pcProperty, rawValue) .
            END.
            WHEN "RAW EXTENT":U THEN DO:
                ASSIGN rawValueExt = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) . 

                IF THIS-OBJECT:SerializeNullValues OR EXTENT (rawValueExt) > 0 THEN DO: 
                    ASSIGN oJsonArray = NEW JsonArray () . 
                
                    oJsonArray:Add (rawValueExt) .
                    poJsonObject:Add (pcProperty, oJsonArray) .
                    oJsonArray = ? . 
                END.
            END.
            WHEN "RECID":U THEN DO:
                ASSIGN recidValue = INTEGER (DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty)) .
                
                IF THIS-OBJECT:SerializeNullValues OR recidValue <> ? THEN 
                    poJsonObject:Add (pcProperty, recidValue) .
            END.
            WHEN "RECID EXTENT":U THEN DO:
                ASSIGN recidValueExt = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) . 

                IF THIS-OBJECT:SerializeNullValues OR EXTENT (recidValueExt) > 0 THEN DO: 
                    ASSIGN oJsonArray = NEW JsonArray () . 
                
                    oJsonArray:Add (recidValueExt) .
                    poJsonObject:Add (pcProperty, oJsonArray) .
                    oJsonArray = ? . 
                END.
            END.
            WHEN "ROWID":U THEN DO:
                ASSIGN roValue = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty).
                
                IF THIS-OBJECT:SerializeNullValues OR roValue <> ? THEN 
                    poJsonObject:Add (pcProperty, roValue) .
            END.
            WHEN "ROWID EXTENT":U THEN DO:
                ASSIGN roValueExt = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) . 

                IF THIS-OBJECT:SerializeNullValues OR EXTENT (roValueExt) > 0 THEN DO: 
                    ASSIGN oJsonArray = NEW JsonArray () . 
                
                    oJsonArray:Add (roValueExt) .
                    poJsonObject:Add (pcProperty, oJsonArray) .
                    oJsonArray = ? . 
                END.
            END.
            OTHERWISE DO:
                oObject = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) . 
                
                IF VALID-OBJECT (oObject) THEN DO:
                    IF TYPE-OF (oObject, Enum) THEN DO:
                        IF THIS-OBJECT:SerializeNullValues OR oObject:ToString() > "":U THEN 
                            poJsonObject:Add (pcProperty, oObject:ToString ()) .
                    END.
                    ELSE IF TYPE-OF (oObject, IEnumerable) THEN 
                    DO ON ERROR UNDO, THROW:
                        ASSIGN oJsonArray = NEW JsonArray () 
                               oList      = CAST (oObject, IEnumerable). 

                        {Consultingwerk/foreachABL.i Progress.Lang.Object oItem in oList}
                            IF TYPE-OF (oItem, IJsonSerializable) THEN DO:
                                oJsonItem = CAST (oItem, IJsonSerializable):ToJsonObject () .
                                
                                oJsonArray:Add (oJsonItem) .
                            END.
                            ELSE
                                UNDO, THROW NEW AppError (SUBSTITUTE ("Unable to serialize item in property &1 of &2."{&TRAN},
                                                                      pcProperty, THIS-OBJECT:GetClass():TypeName),
                                                                      0) .
                        END. 

                        FINALLY:
                            IF VALID-OBJECT (oJsonArray) THEN 
                                poJsonObject:Add (pcProperty, oJsonArray) .
                            ELSE 
                                IF THIS-OBJECT:SerializeNullValues THEN 
                                    poJsonObject:AddNull (pcProperty) .
                        END FINALLY.    
                    END.
                    ELSE DO:
                        IF TYPE-OF (oObject, IJsonSerializable) THEN 
                            poJsonObject:Add (pcProperty, CAST (oObject,IJsonSerializable):ToJsonObject()) .
                        ELSE
                            UNDO, THROW NEW AppError (SUBSTITUTE ("Unable to serialize property &1 of &2 as it does not contain to a Json Serializable object."{&TRAN},
                                                                  pcProperty,
                                                                  THIS-OBJECT:GetClass():TypeName), 0) . 
                    END.
                END.    
                ELSE 
                    IF THIS-OBJECT:SerializeNullValues THEN 
                        poJsonObject:AddNull (pcProperty) .
            END.
        END CASE . 
	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns a JsonObject representation of the state of the class instance                                                                      
        Notes:   Returns the classname together with the Json serialization of the 
                 object
        @return The Progress.Json.ObjectModel.JsonObject representation of the ISerializable objects data                                                                               
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC Progress.Json.ObjectModel.JsonObject ToJsonObject ():
        
        DEFINE VARIABLE oJsonObject AS JsonObject NO-UNDO . 
        DEFINE VARIABLE i           AS INTEGER    NO-UNDO .
        DEFINE VARIABLE cProperty   AS CHARACTER  NO-UNDO .
        DEFINE VARIABLE cType       AS CHARACTER  NO-UNDO .

        oJsonObject = NEW JsonObject () .
        
        IF THIS-OBJECT:UseSerializedTypeInformation THEN 
            oJsonObject:Add ("SerializedType":U, THIS-OBJECT:GetClass():TypeName) .

        DO i = 1 TO NUM-ENTRIES (THIS-OBJECT:SerializableProperties) BY 2:
            ASSIGN cProperty = ENTRY (i, THIS-OBJECT:SerializableProperties) 
                   cType     = ENTRY (i + 1, THIS-OBJECT:SerializableProperties).
            
            /* Mike Fechner, Consultingwerk Ltd. 26.01.2013
               Moved to method SerializeProperty to allow easier overriding of
               individual properties handling */
            THIS-OBJECT:SerializeProperty (oJsonObject, 
                                           cProperty, 
                                           cType) . 
            
        END.
        
        RETURN oJsonObject . 
    END.

	/*------------------------------------------------------------------------------
        Purpose: Returns a LONGCHAR representation of the state of the class instance                                                                      
        Notes:   Returns the classname together with the Json serialization
                 This method is a facade to the JsonSerializable:Serialize method 
        @return The LONGCHAR representation of the ISerializable objects data                                                                               
	------------------------------------------------------------------------------*/
	METHOD PUBLIC LONGCHAR WriteJson ():
		
		RETURN THIS-OBJECT:Serialize () .

	END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns an XML LONGCHAR representation of the object instance                                                                        
        Notes:          
        @return The LONGCHAR representation of the ISerializable objects data                                          
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LONGCHAR WriteXml ():

        DEFINE VARIABLE hDocument  AS HANDLE   NO-UNDO.
        DEFINE VARIABLE hRootNode  AS HANDLE   NO-UNDO.
        DEFINE VARIABLE lcDocument AS LONGCHAR NO-UNDO .

        DEFINE VARIABLE oNumericFormat AS Consultingwerk.NumericFormat NO-UNDO . 

        FIX-CODEPAGE (lcDocument) = "utf-8":U  .

        oNumericFormat = SessionHelper:GetNumericFormat () .

        SESSION:NUMERIC-FORMAT = "AMERICAN":U . 

        CREATE X-DOCUMENT hDocument . 
        
        hRootNode = THIS-OBJECT:XmlSerialize (hDocument) .
    
        hDocument:SAVE ("LONGCHAR":U, lcDocument) .
    
        RETURN lcDocument . 

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
    METHOD PUBLIC HANDLE XmlSerialize (phParent AS HANDLE):
        
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

        THIS-OBJECT:XmlSerializeProperties (hRootNode) .
        
        RETURN hRootNode .

    END METHOD .
           
    /*------------------------------------------------------------------------------
        Purpose: Serializes the properties of this object instance as child nodes of 
                 the given node
        Notes:   
        @param phObjectNode The reference to the X-NODEREF object that represents the node for the current instance
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID XmlSerializeProperties (phObjectNode AS HANDLE):
        
        DEFINE VARIABLE i AS INTEGER NO-UNDO.
        
        DO i = 1 TO NUM-ENTRIES (THIS-OBJECT:SerializableProperties) BY 2:
            
            THIS-OBJECT:XmlSerializeProperty (phObjectNode,
                                              ENTRY (i, THIS-OBJECT:SerializableProperties),
                                              ENTRY (i + 1, THIS-OBJECT:SerializableProperties)) .
        END.

    END METHOD .
           
    /*------------------------------------------------------------------------------
        Purpose: Serializes a single property value to the current parent XmlNode
        Notes:   Allows to override the handling of individual properties during the
                 XmlSerialization
        @param phParentNode The reference to the parent XML Node
        @param pcProperty The name of the property in the JsonObject
        @param pcType The type of the property
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED VOID XmlSerializeProperty (phParentNode AS HANDLE,
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
                ASSIGN cValue = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) .
  
                hValueNode = XmlHelper:InsertTextNode (hPropertyNode, cValue) .
            END.
            WHEN "DATE":U THEN DO:
                ASSIGN dtValue = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) .
  
                hValueNode = XmlHelper:InsertTextNode (hPropertyNode, STRING (dtValue)) .
            END.
            WHEN "DATETIME":U THEN DO:
                ASSIGN dttValue = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) .
  
                hValueNode = XmlHelper:InsertTextNode (hPropertyNode, STRING (dttValue)) .
            END.
            WHEN "DATETIME-TZ":U THEN DO:
                ASSIGN dtttzValue = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) .
  
                hValueNode = XmlHelper:InsertTextNode (hPropertyNode, STRING (dtttzValue)) .
            END.
            WHEN "DECIMAL":U THEN DO:
                ASSIGN deValue = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) .
  
                hValueNode = XmlHelper:InsertTextNode (hPropertyNode, STRING (deValue)) .
            END.
            WHEN "INT64":U THEN DO:
                ASSIGN i64Value = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) .
  
                hValueNode = XmlHelper:InsertTextNode (hPropertyNode, STRING (i64Value)) .
            END.
            WHEN "INTEGER":U THEN DO:
                ASSIGN iValue = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) .
  
                hValueNode = XmlHelper:InsertTextNode (hPropertyNode, STRING (iValue)) .
            END.
            WHEN "LOGICAL":U THEN DO:
                ASSIGN lValue = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) .
  
                hValueNode = XmlHelper:InsertTextNode (hPropertyNode, STRING (lValue)) .
            END.
            WHEN "LONGCHAR":U THEN DO:
                ASSIGN lcValue = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) .
  
                hValueNode = XmlHelper:InsertTextNode (hPropertyNode, lcValue) .
            END.
            WHEN "RAW":U THEN DO:
                ASSIGN rValue = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) .
                
                IF LENGTH (rValue) > 0 THEN 
                    hValueNode = XmlHelper:InsertTextNode (hPropertyNode, rValue) .
            END.
            OTHERWISE DO:
                
                oObject = DYNAMIC-PROPERTY (THIS-OBJECT, pcProperty) .                
                
                IF VALID-OBJECT (oObject) THEN DO:
                    IF TYPE-OF (oObject, Enum) THEN DO:
                        IF THIS-OBJECT:SerializeNullValues OR oObject:ToString() > "":U THEN 
                            hValueNode = XmlHelper:InsertTextNode (hPropertyNode, oObject:ToString ()) .
                    END.
                    ELSE IF TYPE-OF (oObject, IEnumerable) THEN 
                    DO ON ERROR UNDO, THROW:
                        ASSIGN oList = CAST (oObject, IEnumerable). 

                        {Consultingwerk/foreachABL.i Progress.Lang.Object oItem in oList}
                            IF TYPE-OF (oItem, JsonSerializable) THEN DO:
                                hValueNode = CAST (oItem, JsonSerializable):XmlSerialize (hPropertyNode) .
                            END.
                            ELSE
                                UNDO, THROW NEW AppError (SUBSTITUTE ("Unable to serialize item in property &1 of &2"{&TRAN},
                                                                      pcProperty, THIS-OBJECT:GetClass():TypeName),
                                                                      0) .
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
           
END CLASS.
