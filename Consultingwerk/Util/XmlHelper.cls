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
    File        : XmlHelper
    Purpose     : Provides supporting routines for XML Processing
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Thu Nov 08 16:17:13 CET 2012
    Notes       : Static methods only
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.Util.* FROM PROPATH .  
USING Progress.Lang.*       FROM PROPATH .

CLASS Consultingwerk.Util.XmlHelper: 

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the XmlHelper class
        Notes:   Disallow instance creation
    ------------------------------------------------------------------------------*/
	CONSTRUCTOR PRIVATE XmlHelper ():
		SUPER ().
		
	END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Returns the CHARACTER Value of the Text node that is the first child
                 of an XML Element
        Notes:   Returns an Empty String when the node does not have a Text Child
        @param phXmlNode The XML Element to return the text for
        @return The CHARACTER Value
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC CHARACTER GetCharacterValueInNode (phXmlNode AS HANDLE):

        DEFINE VARIABLE hTextNode AS HANDLE NO-UNDO.		

        Consultingwerk.Assertion.HandleAssert:WidgetType (phXmlNode,
                                                          Consultingwerk.WidgetTypeEnum:XNodeRef) .
    
        IF phXmlNode:NUM-CHILDREN > 0 THEN DO:
            CREATE X-NODEREF hTextNode .
            
            phXmlNode:GET-CHILD (hTextNode, 1) .
            
            IF hTextNode:SUBTYPE = "TEXT":U THEN 
                RETURN hTextNode:NODE-VALUE .
        END.

        RETURN "":U .

        FINALLY:
            GarbageCollectorHelper:DeleteObject (hTextNode) .		
        END FINALLY.

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns the LONGCHAR Value of the Text node that is the first child
                 of an XML Element
        Notes:   Returns an Empty String when the node does not have a Text Child
        @param phXmlNode The XML Element to return the text for
        @return The LONGCHAR Value
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR GetLongcharValueInNode (phXmlNode AS HANDLE):

        DEFINE VARIABLE hTextNode AS HANDLE   NO-UNDO.        
        DEFINE VARIABLE lcReturn  AS LONGCHAR NO-UNDO .

        FIX-CODEPAGE (lcReturn) = "utf-8":U.

        Consultingwerk.Assertion.HandleAssert:WidgetType (phXmlNode,
                                                          Consultingwerk.WidgetTypeEnum:XNodeRef) .
    
        IF phXmlNode:NUM-CHILDREN > 0 THEN DO:
            CREATE X-NODEREF hTextNode .
            
            phXmlNode:GET-CHILD (hTextNode, 1) .
            
            IF hTextNode:SUBTYPE = "TEXT":U THEN DO: 
                hTextNode:NODE-VALUE-TO-LONGCHAR (lcReturn) .
                
                RETURN lcReturn .
            END.
        END.

        RETURN "":U .

        FINALLY:
            GarbageCollectorHelper:DeleteObject (hTextNode) .       
        END FINALLY.

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Adds an Element node to a X-NODEREF 
        Notes:   The caller is responsible for cleaning up the created X-NODEREF
        @param phParentNode The parent X-NODEREF 
        @param pcNodeName The name of the node to add to the parent X-NODEREF
        @return The Element X-NODEREF
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC HANDLE InsertElementNode (phParentNode AS HANDLE,
                                                   pcNodeName AS CHARACTER):

        DEFINE VARIABLE hDocument    AS HANDLE NO-UNDO.
        DEFINE VARIABLE hElementNode AS HANDLE NO-UNDO.
        
        Consultingwerk.Assertion.HandleAssert:WidgetType (phParentNode,
                                                          Consultingwerk.WidgetTypeEnum:XNodeRef) .
        
        ASSIGN hDocument = phParentNode:OWNER-DOCUMENT .

        CREATE X-NODEREF hElementNode .
    
        hDocument:CREATE-NODE (hElementNode, 
                               pcNodeName,
                               "ELEMENT":U).        

        phParentNode:APPEND-CHILD (hElementNode) .

        RETURN hElementNode .
        
    END METHOD . 
        
    /*------------------------------------------------------------------------------
        Purpose: Inserts an Attribute Node to an exiting XML Node 
        Notes:   
        @param phParentNode The parent X-NODEREF 
        @param pcAttributeName The name of the attribute to add to the parent X-NODEREF
        @param pcAttributeValue The value of the attribute to add to the parent X-NODEREF
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC VOID InsertNodeAttribute (phParentNode AS HANDLE,
	                                               pcAttributeName AS CHARACTER,
	                                               pcAttributeValue AS CHARACTER):
		
        DEFINE VARIABLE hDocument      AS HANDLE NO-UNDO.
        DEFINE VARIABLE hAttributeNode AS HANDLE NO-UNDO.

        Consultingwerk.Assertion.HandleAssert:WidgetType (phParentNode,
                                                          Consultingwerk.WidgetTypeEnum:XNodeRef) .

        ASSIGN hDocument = phParentNode:OWNER-DOCUMENT .

        CREATE X-NODEREF hAttributeNode .

        hDocument:CREATE-NODE (hAttributeNode,
                               pcAttributeName,
                               "ATTRIBUTE":U).

        phParentNode:SET-ATTRIBUTE-NODE (hAttributeNode) .

        hAttributeNode:NODE-VALUE = pcAttributeValue .

        FINALLY:
            GarbageCollectorHelper:DeleteObject (hAttributeNode) .		
        END FINALLY.

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Adds a Text node to a X-NODEREF 
        Notes:   The caller is responsible for cleaning up the created X-NODEREF
        @param phParentNode The parent X-NODEREF 
        @param pcText The text to add to the parent X-NODEREF
        @return The Text X-NODEREF
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC HANDLE InsertTextNode (phParentNode AS HANDLE,
	                                            pcText AS CHARACTER):
		
		DEFINE VARIABLE hDocument AS HANDLE NO-UNDO.
		DEFINE VARIABLE hTextNode AS HANDLE NO-UNDO.
		
		IF pcText = ? THEN RETURN ? . 
		
        Consultingwerk.Assertion.HandleAssert:WidgetType (phParentNode,
                                                          Consultingwerk.WidgetTypeEnum:XNodeRef) .
        
        ASSIGN hDocument = phParentNode:OWNER-DOCUMENT .

        CREATE X-NODEREF hTextNode .
    
        hDocument:CREATE-NODE (hTextNode, 
                               "":U,
                               "TEXT":U).        

        hTextNode:NODE-VALUE = pcText .

        phParentNode:APPEND-CHILD (hTextNode) .

        RETURN hTextNode .

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Adds a Text node to a X-NODEREF 
        Notes:   The caller is responsible for cleaning up the created X-NODEREF
        @param phParentNode The parent X-NODEREF 
        @param plcText The text to add to the parent X-NODEREF
        @return The Text X-NODEREF
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC HANDLE InsertTextNode (phParentNode AS HANDLE,
                                                plcText AS LONGCHAR):
        
        DEFINE VARIABLE hDocument AS HANDLE NO-UNDO.
        DEFINE VARIABLE hTextNode AS HANDLE NO-UNDO.
        
        IF plcText = ? THEN RETURN ? . 
        
        Consultingwerk.Assertion.HandleAssert:WidgetType (phParentNode,
                                                          Consultingwerk.WidgetTypeEnum:XNodeRef) .
        
        ASSIGN hDocument = phParentNode:OWNER-DOCUMENT .

        CREATE X-NODEREF hTextNode .
    
        hDocument:CREATE-NODE (hTextNode, 
                               "":U,
                               "TEXT":U).        

        hTextNode:LONGCHAR-TO-NODE-VALUE (plcText) .

        phParentNode:APPEND-CHILD (hTextNode) .

        RETURN hTextNode .

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Adds a base64-encoded Text node for RAW value to a X-NODEREF 
        Notes:   The caller is responsible for cleaning up the created X-NODEREF
        @param phParentNode The parent X-NODEREF 
        @param prValue The RAW value to encode and add to the parent X-NODEREF
        @return The Text X-NODEREF
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC HANDLE InsertTextNode (phParentNode AS HANDLE,
                                                prValue AS RAW):
        
        DEFINE VARIABLE lcEncoded AS LONGCHAR NO-UNDO.
        
        IF LENGTH (prValue) > 0 THEN . 
            ELSE RETURN ? .
        
        lcEncoded = BASE64-ENCODE (prValue) .

        RETURN XmlHelper:InsertTextNode (phParentNode, lcEncoded) .

    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Verifies of the physical structure of the passed in Longchar is a 
                 valid (well-formed) XML Document
        Notes:   
        @param pcXmlString The Xml String to varify
        @return Logical value indicating if the value contains a well-formed XML document 
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC LOGICAL IsWellFormed (pcXmlString AS LONGCHAR):
		
        DEFINE VARIABLE hXmlDoc AS HANDLE  NO-UNDO .
        DEFINE VARIABLE lgValid AS LOGICAL NO-UNDO .
      
        CREATE X-DOCUMENT hXmlDoc .
      
        ASSIGN lgValid = hXmlDoc:LOAD ("LONGCHAR":U, 
                                       pcXmlString, 
                                       FALSE) NO-ERROR .
      
        RETURN lgValid . 
        
        FINALLY:
            GarbageCollectorHelper:DeleteObject (hXmlDoc) .
        END.
	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Sanitizes the passed in Character value as an XML Document
        Notes:   
        @param pcXmlString The Xml String to sanitize
        @return The sanitized XML String 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER Sanitize (pcXmlString AS CHARACTER):
        
        ASSIGN pcXmlString = REPLACE(pcXmlString, "&":U,  "&amp;":U)
               pcXmlString = REPLACE(pcXmlString, "~"":U,  "&quot;":U)
               pcXmlString = REPLACE(pcXmlString, "~'":U, "&apos;":U)
               pcXmlString = REPLACE(pcXmlString, "<":U,  "&lt;":U)
               pcXmlString = REPLACE(pcXmlString, ">":U,  "&gt;":U).
             
        RETURN pcXmlString.
      
    END METHOD.
  
    /*------------------------------------------------------------------------------
        Purpose: Sanitizes the passed in Longchar value as an XML Document
        Notes:   
        @param pcXmlString The Xml String to sanitize
        @return The sanitized XML String 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR Sanitize (pcXmlString AS LONGCHAR):
    
        ASSIGN pcXmlString = REPLACE(pcXmlString, "&":U,  "&amp;":U)
               pcXmlString = REPLACE(pcXmlString, "~"":U,  "&quot;":U)
               pcXmlString = REPLACE(pcXmlString, "~'":U, "&apos;":U)
               pcXmlString = REPLACE(pcXmlString, "<":U,  "&lt;":U)
               pcXmlString = REPLACE(pcXmlString, ">":U,  "&gt;":U).
             
        RETURN pcXmlString.
          
    END METHOD.

END CLASS.
