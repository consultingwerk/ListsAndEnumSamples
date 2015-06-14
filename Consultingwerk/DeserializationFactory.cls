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
    File        : DeserializationFactory
    Purpose     : Default IDeserializationFactory implementation 
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Sat Aug 25 00:03:15 CEST 2012
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{Consultingwerk/products.i}

USING Consultingwerk.*            FROM PROPATH .
USING Consultingwerk.Util.*       FROM PROPATH .   
USING Progress.Json.ObjectModel.* FROM PROPATH . 
USING Progress.Lang.*             FROM PROPATH .

CLASS Consultingwerk.DeserializationFactory IMPLEMENTS IDeserializationFactory: 

    DEFINE STATIC TEMP-TABLE ttDeSerialization NO-UNDO XML-NODE-NAME "Serialization":U
        FIELD ClassName  AS CHARACTER 
        FIELD Properties AS CLOB . 

    /*------------------------------------------------------------------------------
        Purpose: Deserializes a LONGCHAR representation of an object to a new 
                 instance                                                                      
        Notes:   Supports XML and JSON Serialized objects
        @param plcSerializable The serialized representation to be deserialized    
        @return The LONGCHAR representation of the ISerializable objects data                                                                                    
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC ISerializable DeserializeInstance (plcSerializable AS LONGCHAR):
        
        DEFINE VARIABLE oInstance      AS ISerializable     NO-UNDO .
        DEFINE VARIABLE lFromTempTable AS LOGICAL           NO-UNDO .
        DEFINE VARIABLE hDocument      AS HANDLE            NO-UNDO .
        DEFINE VARIABLE hRootNode      AS HANDLE            NO-UNDO .
        DEFINE VARIABLE cClassName     AS CHARACTER         NO-UNDO .
        DEFINE VARIABLE oFormat        AS NumericFormat     NO-UNDO . 
        
/* Mike Fechner, Consultingwerk Ltd. 19.11.2012
   JsonSerialization not available on OpenEdge 10.2B */
&IF NOT PROVERSION EQ "10.2B" &THEN
        DEFINE VARIABLE oJsonInstance AS IJsonSerializable NO-UNDO . 
        DEFINE VARIABLE oJsonObject   AS JsonObject        NO-UNDO . 
        DEFINE VARIABLE oObjectModel  AS ObjectModelParser NO-UNDO . 
        
        IF plcSerializable BEGINS "~{":U THEN DO ON ERROR UNDO, THROW:

            /* SCL-415: Perform JSON Serialization/Deserialization with AMERICAN
                        numeric format to avoid issues with decimal point interpretation */            
            oFormat = SessionHelper:GetNumericFormat() .
            SessionHelper:SetDefaultNumericFormat() .            
            
            oObjectModel = NEW ObjectModelParser () .
        
            oJsonObject = CAST (oObjectModel:Parse (plcSerializable), JsonObject). 
            
            IF NOT oJsonObject:Has ("SerializedType":U) THEN 
                UNDO, THROW NEW AppError ("Invalid JSON serialization."{&TRAN}, 0) . 
            
            oJsonInstance = DYNAMIC-NEW (oJsonObject:GetCharacter ("SerializedType":U)) ().
            oJsonInstance:DeserializeFromJsonObject (oJsonObject) .
            
            oInstance = oJsonInstance .
            
            FINALLY:
                IF VALID-OBJECT (oFormat) THEN 
                    SessionHelper:SetNumericFormat (oFormat) .

                GarbageCollectorHelper:DeleteObject (oObjectModel) .
                GarbageCollectorHelper:DeleteObject (oJsonObject) .     
            END FINALLY.
        END . 
        ELSE 
&ENDIF        
        DO: 
            /* Mike Fechner, Consultingwerk Ltd. 25.02.2013
               Need to test of ttDesecialization Temp-Table is contained in the XML 
               Temp-Table name 'ttDeSerialization' in namespace '' not found in XML Document. (13514) */
            DO ON ERROR UNDO, THROW:
                TEMP-TABLE ttDeSerialization:READ-XML ("LONGCHAR":U, plcSerializable, "EMPTY":U, ?, FALSE) . 
                
                ASSIGN lFromTempTable = TRUE . 
                
                CATCH err AS Progress.Lang.Error:
                    IF err:GetMessageNum (1) = 13514 THEN 
                        lFromTempTable = FALSE . 
                	ELSE 
                	   UNDO, THROW err . 	
                END CATCH.
            END.            
    
            IF lFromTempTable = TRUE THEN DO:
                FIND FIRST ttDeSerialization NO-ERROR .
        
                oInstance = DYNAMIC-NEW (ttDeSerialization.ClassName) () .
    
                oInstance:Deserialize (plcSerializable) .        
            END.
            /* XmlSerializable */
            ELSE DO:
                CREATE X-DOCUMENT hDocument . 
                CREATE X-NODEREF hRootNode . 
                
                hDocument:LOAD ("LONGCHAR":U, plcSerializable, FALSE) .
                hDocument:GET-DOCUMENT-ELEMENT (hRootNode) .
                
                cClassName = THIS-OBJECT:GetClassNameFromNode (hRootNode) .
                
                oInstance = DYNAMIC-NEW (cClassName) () .
                
                CAST (oInstance, XmlSerializable):DeserializeFromNode (hRootNode) .
            END.
        END.
        
        RETURN oInstance . 
        
        FINALLY:
            EMPTY TEMP-TABLE ttDeSerialization .       
            
            GarbageCollectorHelper:DeleteObject (hRootNode) .
            GarbageCollectorHelper:DeleteObject (hDocument) .
        END FINALLY.

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns the ABL Class name that should be used to serialize from 
                 an XML Document (Consultingwerk.XmlSerializable). 
        Notes:   When the node does not contain the SerializedType attribute it may 
                 need to be required to overload this method in a derived class and
                 provide a custom logic to return the class name base on the root node
                 name 
        @param phRootNode The root document element
        @return The class name to be used for the deserialization
    ------------------------------------------------------------------------------*/
	METHOD PROTECTED CHARACTER GetClassNameFromNode (phRootNode AS HANDLE):
		
		RETURN phRootNode:GET-ATTRIBUTE ("SerializedType":U).

	END METHOD .
    
END CLASS.
