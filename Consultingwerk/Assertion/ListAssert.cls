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
    File        : ListAssert
    Purpose     : Assertion methods for delimited lists 
    Syntax      : 
    Description : Routines in this class typically raise an error condition
                  when the condition is not met.
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Sun Jul 14 17:36:13 CEST 2013
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{Consultingwerk/products.i}

USING Consultingwerk.Assertion.* FROM PROPATH .  
USING Consultingwerk.Util.*      FROM PROPATH . 
USING Progress.Lang.*            FROM PROPATH .

CLASS Consultingwerk.Assertion.ListAssert: 

    /*------------------------------------------------------------------------------
        Purpose: Validates if an entry is in the given list of values
        Notes:   
        @param pcEntry The entry to locate in the list
        @param pcList The list to locate the entry in 
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC VOID EntryIsInList (pcEntry AS CHARACTER, 
	                                         pcList AS CHARACTER):
		
		IF LOOKUP (pcEntry, pcList) > 0 THEN . 
		ELSE 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("The Entry ~"&1~" is not in the List of ~"&2~".."{&TRAN}, 
                                                         pcEntry, pcList), 
                                             0) . 

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Validates if an entry is in the given list of values
        Notes:   
        @param pcEntry The entry to locate in the list
        @param pcList The list to locate the entry in 
        @param pcDelimiter The list delimiter to use
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID EntryIsInList (pcEntry AS CHARACTER, 
                                             pcList AS CHARACTER,
                                             pcDelimiter AS CHARACTER):
        
        IF LOOKUP (pcEntry, pcList, pcDelimiter) > 0 THEN . 
        ELSE 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("The Entry ~"&1~" is not in the List of ~"&2~".."{&TRAN}, 
                                                         pcEntry, pcList), 
                                             0) . 

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Validates if a list has an even number of entries 
        Notes:   
        Throws: Consultingwerk.Assertion.AssertException  
        @param pcList The list to validate
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID EvenEntries (pcList AS CHARACTER):
        
        DEFINE VARIABLE iEntries AS INTEGER NO-UNDO.
        
        ASSIGN iEntries = NUM-ENTRIES (pcList) .  
        
        IF iEntries MODULO 2 <> 0 THEN 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("List has &1 odd number of entries, but an even number is expected."{&TRAN}, 
                                                         pcList), 
                                             0) . 
    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Validates if a list has an even number of entries 
        Notes:   
        Throws: Consultingwerk.Assertion.AssertException  
        @param pcList The list to validate
        @param pcDelimiter The list delimiter
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID EvenEntries (pcList AS CHARACTER, 
                                           pcDelimiter AS CHARACTER):
        
        DEFINE VARIABLE iEntries AS INTEGER NO-UNDO.
        
        ASSIGN iEntries = NUM-ENTRIES (pcList, pcDelimiter) .  
        
        IF iEntries MODULO 2 <> 0 THEN 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("List has &1 odd number of entries, but an even number is expected."{&TRAN}, 
                                                         pcList), 
                                             0) . 
    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Validates if a list has the expected number of entries 
        Notes:   
        Throws: Consultingwerk.Assertion.AssertException  
        @param pcList The list to validate
        @param pcDelimiter The list delimiter
        @param piEntries The expected number of entries
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC VOID NumEntries (pcList AS CHARACTER, 
	                                      pcDelimiter AS CHARACTER, 
	                                      piEntries AS INTEGER):
		
        DEFINE VARIABLE iEntries AS INTEGER NO-UNDO.
		
		ASSIGN iEntries = NUM-ENTRIES (pcList, pcDelimiter) .  
		
		IF iEntries <> piEntries THEN 
		    UNDO, THROW NEW AssertException (SUBSTITUTE ("List has &1 entries, but expected are &2 entries."{&TRAN}, 
		                                                 iEntries, piEntries), 
		                                     0) . 
	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Validates if a list has the expected number of entries 
        Notes:   Uses the comma as the default list delimiter    
        Throws: Consultingwerk.Assertion.AssertException  
        @param pcList The list to validate
        @param piEntries The expected number of entries
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID NumEntries (pcList AS CHARACTER, 
                                          piEntries AS INTEGER):
        
        DEFINE VARIABLE iEntries AS INTEGER NO-UNDO.
        
        ASSIGN iEntries = NUM-ENTRIES (pcList) .  
        
        IF iEntries <> piEntries THEN 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("List has &1 entries, but expected are &2 entries."{&TRAN}, 
                                                         iEntries, piEntries), 
                                             0) . 
    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Validates if a list has only unique entries 
        Notes:   Based on Consultingwerk.Util.ListHelper:VerifyUniqueEntries 
        Throws: Consultingwerk.Assertion.AssertException  
        @param pcList The list to validate
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID UniqueEntries (pcList AS CHARACTER):
        
        IF ListHelper:VerifyUniqueEntries (pcList) = TRUE THEN . 
        ELSE 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("The list &1 does have non-unique entries."{&TRAN}, pcList), 
                                             0) .  
    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Validates if a list has only unique entries 
        Notes:   Based on Consultingwerk.Util.ListHelper:VerifyUniqueEntries 
        Throws: Consultingwerk.Assertion.AssertException  
        @param pcList The list to validate
        @param pcDelimiter The list delimiter
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC VOID UniqueEntries (pcList AS CHARACTER, 
                                             pcDelimiter AS CHARACTER):
		
		IF ListHelper:VerifyUniqueEntries (pcList, pcDelimiter) = TRUE THEN . 
        ELSE 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("The list &1 does have non-unique entries."{&TRAN}, pcList), 
                                             0) .  
	END METHOD .

END CLASS.
