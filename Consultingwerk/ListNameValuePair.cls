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
    File        : ListNameValuePair
    Purpose     : List of NameValuePair implementations
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Thu Mar 31 20:39:40 CEST 2011
    Notes       : Simplified dictionary implementation
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{Consultingwerk/products.i}

USING Progress.Lang.*.
USING Consultingwerk.Framework.Base.GenericList.
USING Consultingwerk.NameValuePair.

CLASS Consultingwerk.ListNameValuePair 
    INHERITS GenericList
    {&SERIALIZABLE}: 

    { Consultingwerk/Framework/Base/GenericList.i NameValuePair }

    /*------------------------------------------------------------------------------
        Purpose: Returns if the ListNameValuePair contains a pair this the given Name 
        Notes:   
        @param pcName The Name value to search
        @return True, when the ListNameValuePair contains a pair this the given Name 
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC LOGICAL ContainsName (pcName AS CHARACTER):
		
        {Consultingwerk/foreachABL.i NameValuePair oPair in THIS-OBJECT}
        
             IF oPair:Name = pcName THEN 
                RETURN TRUE .  
        END.

		RETURN FALSE .

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Finds a NameValuePair by it's Name                                                                      
        Notes:   Performs a FIND-FIRST, does not verify if there is a second pair
                 with the same name                     
        @param pcName The Name value to search
        @return The matching NameValuePair or ? when no Pair has been found                                                     
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC NameValuePair FindByName (pcName AS CHARACTER):
        
        {Consultingwerk/foreachABL.i NameValuePair oPair in THIS-OBJECT}
        
             IF oPair:Name = pcName THEN 
                RETURN oPair .  
        END.
        
        RETURN ? .
    END.

    /*------------------------------------------------------------------------------
        Purpose: Adds a NameValuePair to the List                                                                      
        Notes:      
        @param pcName The Name value
        @param pcValue The value              
        @return The new NameValuePair added to the List                                                    
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC NameValuePair Add (pcName AS CHARACTER, pcValue AS CHARACTER):
        
        DEFINE VARIABLE oItem AS NameValuePair NO-UNDO . 
        
        oItem = NEW NameValuePair (pcName, pcValue) . 
        
        THIS-OBJECT:InternalAdd (oItem).

        RETURN oItem . 
    
    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns the value for the given Name 
        Notes:   When the Name is used in the List more than once, the first occurence
                 is returned   
        @param pcName The Name value to search
        @return The Value of the Pair with the given Name or ? when no pair was found 
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC CHARACTER GetValueByPair (pcName AS CHARACTER):
		
		DEFINE VARIABLE oPair AS NameValuePair NO-UNDO.
		
		ASSIGN oPair = THIS-OBJECT:FindByName (pcName) .
		
		IF VALID-OBJECT (oPair) THEN 
		    RETURN oPair:Value .
        ELSE 
            RETURN ? .

	END METHOD .

END CLASS.
