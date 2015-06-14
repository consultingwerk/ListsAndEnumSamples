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
    File        : Assert
    Purpose     : Provides generic methods for validation of ABL primitive values
    Syntax      : 
    Description : Routines in this class typically raise an error condition
                  when the condition is not met.
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Fri Apr 27 23:31:14 CEST 2012
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{Consultingwerk/products.i}

USING Consultingwerk.Assertion.*  FROM PROPATH . 
USING Consultingwerk.Exceptions.* FROM PROPATH . 
USING Progress.Lang.*             FROM PROPATH .

CLASS Consultingwerk.Assertion.Assert: 
    
    /*------------------------------------------------------------------------------
        Purpose: Disallow instance creation                                                                        
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE Assert ():
        SUPER ().
        
    END CONSTRUCTOR.

	/*------------------------------------------------------------------------------
		Purpose: Validates that two character values are equal 																	  
		Notes:   
		Throws:  Consultingwerk.Assertion.AssertException  											
		@param pcValue1 The first value to compare
		@param pcValue2 The second value to compare						  
	------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC VOID Equals (pcValue1 AS CHARACTER,
	                                  pcValue2 AS CHARACTER):
		
		IF pcValue1 <> pcValue2 THEN 
		    UNDO, THROW NEW AssertException (SUBSTITUTE ("Value &1 does not equal &2"{&TRAN}, 
        		                                         QUOTER (pcValue1), 
        		                                         QUOTER (pcValue2)), 0) .

	END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Validates that two decimal values are equal                                                                    
        Notes:                                              
        Throws:  Consultingwerk.Assertion.AssertException                                           
        @param pdtValue1 The first value to compare
        @param pdtValue2 The second value to compare                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID Equals (pdtValue1 AS DATE,
                                      pdtValue2 AS DATE):
        
        IF pdtValue1 <> pdtValue2 THEN 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("Value &1 does not equal &2"{&TRAN}, 
                                                         QUOTER (pdtValue1), 
                                                         QUOTER (pdtValue2)), 0) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Validates that two decimal values are equal                                                                    
        Notes:                                              
        Throws:  Consultingwerk.Assertion.AssertException                                           
        @param pdeValue1 The first value to compare
        @param pdeValue2 The second value to compare                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID Equals (pdeValue1 AS DECIMAL,
                                      pdeValue2 AS DECIMAL):
        
        IF pdeValue1 <> pdeValue2 THEN 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("Value &1 does not equal &2"{&TRAN}, 
                                                         QUOTER (pdeValue1), 
                                                         QUOTER (pdeValue2)), 0) .

    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Validates that two integer values are equal                                                                    
        Notes:                                              
        Throws:  Consultingwerk.Assertion.AssertException                                           
        @param piValue1 The first value to compare
        @param piValue2 The second value to compare                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID Equals (piValue1 AS INT64,
                                      piValue2 AS INT64):
        
        IF piValue1 <> piValue2 THEN 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("Value &1 does not equal &2"{&TRAN}, 
                                                         QUOTER (piValue1), 
                                                         QUOTER (piValue2)), 0) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Validates that handles are equal                                                                    
        Notes:                                              
        Throws:  Consultingwerk.Assertion.AssertException                                           
        @param phValue1 The first value to compare
        @param phValue2 The second value to compare                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID Equals (phValue1 AS HANDLE,
                                      phValue2 AS HANDLE):
        
        IF phValue1 <> phValue2 THEN 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("Value &1 does not equal &2"{&TRAN}, 
                                                         QUOTER (phValue1), 
                                                         QUOTER (phValue2)), 0) .

    END METHOD.
        
    /*------------------------------------------------------------------------------
        Purpose: Validates that two logical values are equal                                                                    
        Notes:                                              
        Throws:  Consultingwerk.Assertion.AssertException                                           
        @param plValue1 The first value to compare
        @param plValue2 The second value to compare                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID Equals (plValue1 AS LOGICAL,
                                      plValue2 AS LOGICAL):
        
        IF plValue1 <> plValue2 THEN 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("Value &1 does not equal &2"{&TRAN}, 
                                                         QUOTER (plValue1), 
                                                         QUOTER (plValue2)), 0) .

    END METHOD.
        
    /*------------------------------------------------------------------------------
        Purpose: Validates that two longchar values are equal                                                                    
        Notes:                                              
        Throws:  Consultingwerk.Assertion.AssertException                                           
        @param plcValue1 The first value to compare
        @param plcValue2 The second value to compare                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID Equals (plcValue1 AS LONGCHAR,
                                      plcValue2 AS LONGCHAR):
        
        IF plcValue1 <> plcValue2 THEN 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("Value &1 does not equal &2"{&TRAN}, 
                                                         QUOTER (STRING(plcValue1)), 
                                                         QUOTER (STRING(plcValue2))), 0) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Validates that two character values are equal based on a raw compare                                                                    
        Notes:                                              
        Throws:  Consultingwerk.Assertion.AssertException                                           
        @param pcValue1 The first value to compare
        @param pcValue2 The second value to compare                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID EqualsCaseSensitive (pcValue1 AS CHARACTER,
                                                   pcValue2 AS CHARACTER):
        
        IF COMPARE (pcValue1, "NE":U, pcValue2, "CASE-SENSITIVE":U) THEN 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("Value &1 does not equal &2"{&TRAN}, 
                                                         QUOTER (pcValue1), 
                                                         QUOTER (pcValue2)), 0) .

    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Validates that two longchar values are equal based on a raw compare                                                                    
        Notes:                                              
        Throws:  Consultingwerk.Assertion.AssertException                                           
        @param plcValue1 The first value to compare
        @param plcValue2 The second value to compare                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID EqualsCaseSensitive (plcValue1 AS LONGCHAR,
                                                   plcValue2 AS LONGCHAR):
        
        IF COMPARE (plcValue1, "NE":U, plcValue2, "CASE-SENSITIVE":U) THEN 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("Value &1 does not equal &2"{&TRAN}, 
                                                         QUOTER (plcValue1), 
                                                         QUOTER (plcValue2)), 0) .

    END METHOD.
    /*------------------------------------------------------------------------------
        Purpose: Validates that two character values are equal based on a raw compare                                                                    
        Notes:                                              
        Throws:  Consultingwerk.Assertion.AssertException                                           
        @param pcValue1 The first value to compare
        @param pcValue2 The second value to compare                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID EqualsRaw (pcValue1 AS CHARACTER,
                                         pcValue2 AS CHARACTER):
        
        IF COMPARE (pcValue1, "NE":U, pcValue2, "RAW":U) THEN 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("Value &1 does not equal &2"{&TRAN}, 
                                                         QUOTER (pcValue1), 
                                                         QUOTER (pcValue2)), 0) .

    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Validates that two longchar values are equal based on a raw compare                                                                    
        Notes:                                              
        Throws:  Consultingwerk.Assertion.AssertException                                           
        @param plcValue1 The first value to compare
        @param plcValue2 The second value to compare                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID EqualsRaw (plcValue1 AS LONGCHAR,
                                         plcValue2 AS LONGCHAR):
        
        IF COMPARE (plcValue1, "NE":U, plcValue2, "RAW":U) THEN 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("Value &1 does not equal &2"{&TRAN}, 
                                                         QUOTER (plcValue1), 
                                                         QUOTER (plcValue2)), 0) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Validates that a LOGICAL Value is FALSE 
        Notes:   
        Throws:  Consultingwerk.Assertion.AssertException                                           
        @param plValue The logical value to validate
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID EqualsFalse (plValue AS LOGICAL):
        
        IF plValue = FALSE THEN . 
        ELSE 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("Value &1 is not FALSE"{&TRAN}, 
                                                         QUOTER (plValue)), 0) .
    END METHOD .
                
    /*------------------------------------------------------------------------------
        Purpose: Validates that a LOGICAL Value is TRUE 
        Notes:   
        Throws:  Consultingwerk.Assertion.AssertException                                           
        @param plValue The logical value to validate
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC VOID EqualsTrue (plValue AS LOGICAL):
		
		IF plValue = TRUE THEN . 
		ELSE 
		    UNDO, THROW NEW AssertException (SUBSTITUTE ("Value &1 is not TRUE"{&TRAN}, 
                                                         QUOTER (plValue)), 0) .
	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Fails unconditionally 
        Notes:   Useful Assertion method when reaching a certain code location is
                 unexpected
        Throws:  Consultingwerk.Assertion.AssertException                
        @param pcMessage The error message to throw                           
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC VOID Fail (pcMessage AS CHARACTER):
		
        UNDO, THROW NEW AssertException (pcMessage, 0) .

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Validates that the first value is GE the second value                                                                     
        Notes:                                              
        Throws:  Consultingwerk.Assertion.AssertException                                           
        @param pdeValue1 The first value to compare
        @param pdeValue2 The second value to compare                       
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC VOID GE (pdeValue1 AS DECIMAL,
                                  pdeValue2 AS DECIMAL):
        
        IF pdeValue1 >= pdeValue2 THEN . 
        ELSE 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("Value &1 is not greater or equal to &2"{&TRAN}, 
                                                         QUOTER (pdeValue1), 
                                                         QUOTER (pdeValue2)), 0) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Validates that the first value is GE the second value                                                                     
        Notes:                                              
        Throws:  Consultingwerk.Assertion.AssertException                                           
        @param piValue1 The first value to compare
        @param piValue2 The second value to compare                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID GE (piValue1 AS INTEGER,
                                  piValue2 AS INTEGER):
        
        IF piValue1 >= piValue2 THEN . 
        ELSE 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("Value &1 is not greater or equal to &2"{&TRAN}, 
                                                         QUOTER (piValue1), 
                                                         QUOTER (piValue2)), 0) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Validates that the first value is GE the second value                                                                     
        Notes:                                              
        Throws:  Consultingwerk.Assertion.AssertException                                           
        @param piValue1 The first value to compare
        @param piValue2 The second value to compare                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID GE (piValue1 AS INT64,
                                  piValue2 AS INT64):
        
        IF piValue1 >= piValue2 THEN . 
        ELSE 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("Value &1 is not greater or equal to &2"{&TRAN}, 
                                                         QUOTER (piValue1), 
                                                         QUOTER (piValue2)), 0) .

    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Validates that the first value is GT the second value                                                                     
        Notes:                                              
        Throws:  Consultingwerk.Assertion.AssertException                                           
        @param pdeValue1 The first value to compare
        @param pdeValue2 The second value to compare                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID GT (pdeValue1 AS DECIMAL,
                                  pdeValue2 AS DECIMAL):
        
        IF pdeValue1 > pdeValue2 THEN . 
        ELSE 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("Value &1 is not greater than &2"{&TRAN}, 
                                                         QUOTER (pdeValue1), 
                                                         QUOTER (pdeValue2)), 0) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Validates that the first value is GT the second value                                                                     
        Notes:                                              
        Throws:  Consultingwerk.Assertion.AssertException                                           
        @param piValue1 The first value to compare
        @param piValue2 The second value to compare                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID GT (piValue1 AS INTEGER,
                                  piValue2 AS INTEGER):
        
        IF piValue1 > piValue2 THEN . 
        ELSE 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("Value &1 is not greater than &2"{&TRAN}, 
                                                         QUOTER (piValue1), 
                                                         QUOTER (piValue2)), 0) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Validates that the first value is GT the second value                                                                     
        Notes:                                              
        Throws:  Consultingwerk.Assertion.AssertException                                           
        @param piValue1 The first value to compare
        @param piValue2 The second value to compare                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID GT (piValue1 AS INT64,
                                  piValue2 AS INT64):
        
        IF piValue1 > piValue2 THEN . 
        ELSE 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("Value &1 is not greater than &2"{&TRAN}, 
                                                         QUOTER (piValue1), 
                                                         QUOTER (piValue2)), 0) .

    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Validates an ABL Integer value so that it is greater than 0   
        Notes:  
        Throws:  Consultingwerk.Exceptions.InvalidValueException 
        @param piValue The Integer value to validate                                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID GreaterThanZero (piValue AS INTEGER):
        
        IF piValue > 0 THEN . 
        ELSE  
            UNDO, THROW NEW InvalidValueException (STRING (piValue)) .

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Validates an ABL Integer value so that it is greater than 0   
        Notes:   
        Throws:  Consultingwerk.Exceptions.InvalidValueException 
        @param piValue The Integer value to validate                                       
        @param pcValueDesc The optional description of the value used in the InvalidValueException
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC VOID GreaterThanZero (piValue AS INTEGER,
                                               pcValueDesc AS CHARACTER):
		
        IF piValue > 0 THEN . 
        ELSE  
            UNDO, THROW NEW InvalidValueException (STRING (piValue), pcValueDesc) .

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Validates that the first value is LE the second value                                                                     
        Notes:                                              
        Throws:  Consultingwerk.Assertion.AssertException                                           
        @param pdeValue1 The first value to compare
        @param pdeValue2 The second value to compare                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID LE (pdeValue1 AS DECIMAL,
                                  pdeValue2 AS DECIMAL):
        
        IF pdeValue1 <= pdeValue2 THEN . 
        ELSE 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("Value &1 is not less or equal to &2"{&TRAN}, 
                                                         QUOTER (pdeValue1), 
                                                         QUOTER (pdeValue2)), 0) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Validates that the first value is LE the second value                                                                     
        Notes:                                              
        Throws:  Consultingwerk.Assertion.AssertException                                           
        @param piValue1 The first value to compare
        @param piValue2 The second value to compare                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID LE (piValue1 AS INTEGER,
                                  piValue2 AS INTEGER):
        
        IF piValue1 <= piValue2 THEN . 
        ELSE 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("Value &1 is not less or equal to &2"{&TRAN}, 
                                                         QUOTER (piValue1), 
                                                         QUOTER (piValue2)), 0) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Validates that the first value is LE the second value                                                                     
        Notes:                                              
        Throws:  Consultingwerk.Assertion.AssertException                                           
        @param piValue1 The first value to compare
        @param piValue2 The second value to compare                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID LE (piValue1 AS INT64,
                                  piValue2 AS INT64):
        
        IF piValue1 <= piValue2 THEN . 
        ELSE 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("Value &1 is not less or equal to &2"{&TRAN}, 
                                                         QUOTER (piValue1), 
                                                         QUOTER (piValue2)), 0) .

    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Validates that the first value is LT the second value                                                                     
        Notes:                                              
        Throws:  Consultingwerk.Assertion.AssertException                                           
        @param pdeValue1 The first value to compare
        @param pdeValue2 The second value to compare                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID LT (pdeValue1 AS DECIMAL,
                                  pdeValue2 AS DECIMAL):
        
        IF pdeValue1 < pdeValue2 THEN . 
        ELSE 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("Value &1 is not less than &2"{&TRAN}, 
                                                         QUOTER (pdeValue1), 
                                                         QUOTER (pdeValue2)), 0) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Validates that the first value is LT the second value                                                                     
        Notes:                                              
        Throws:  Consultingwerk.Assertion.AssertException                                           
        @param piValue1 The first value to compare
        @param piValue2 The second value to compare                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID LT (piValue1 AS INTEGER,
                                  piValue2 AS INTEGER):
        
        IF piValue1 < piValue2 THEN . 
        ELSE 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("Value &1 is not less than &2"{&TRAN}, 
                                                         QUOTER (piValue1), 
                                                         QUOTER (piValue2)), 0) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Validates that the first value is GT the second value                                                                     
        Notes:                                              
        Throws:  Consultingwerk.Assertion.AssertException                                           
        @param piValue1 The first value to compare
        @param piValue2 The second value to compare                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID LT (piValue1 AS INT64,
                                  piValue2 AS INT64):
        
        IF piValue1 < piValue2 THEN . 
        ELSE 
            UNDO, THROW NEW AssertException (SUBSTITUTE ("Value &1 is not less than &2"{&TRAN}, 
                                                         QUOTER (piValue1), 
                                                         QUOTER (piValue2)), 0) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Validates an ABL Logical value so that it is not ? 
        Notes:   
        Throws:  Consultingwerk.Exceptions.InvalidValueException 
        @param plValue The Logical value to validate  
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC VOID NotNull (plValue AS LOGICAL):
		
        IF plValue = ? THEN  
            UNDO, THROW NEW InvalidValueException (STRING (plValue)) .
            
	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Validates an ABL Charcater value so that it is not ? or Empty
        Notes:                              
        Throws:  Consultingwerk.Exceptions.InvalidValueException 
        @param pcValue The Character value to validate                                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID NotNullOrEmpty (pcValue AS CHARACTER):
        
        IF pcValue > "":U THEN . 
        ELSE  
            UNDO, THROW NEW InvalidValueException (pcValue) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Validates an ABL Charcater value so that it is not ? or Empty
        Notes:                              
        Throws:  Consultingwerk.Exceptions.InvalidValueException 
        @param pcValue The Character value to validate                                       
        @param pcValueDesc The optional description of the value used in the InvalidValueException
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID NotNullOrEmpty (pcValue AS CHARACTER,
                                              pcValueDesc AS CHARACTER):
        
        IF pcValue > "":U THEN . 
        ELSE  
            UNDO, THROW NEW InvalidValueException (pcValue, pcValueDesc) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Validates an ABL LONGCHAR value so that it is not ? or Empty
        Notes:                              
        Throws:  Consultingwerk.Exceptions.InvalidValueException 
        @param plcValue The Character value to validate                                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID NotNullOrEmpty (plcValue AS LONGCHAR):
        
        IF plcValue > "":U THEN . 
        ELSE  
            UNDO, THROW NEW InvalidValueException (STRING (plcValue)) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Validates an ABL LONGCHAR value so that it is not ? or Empty
        Notes:                              
        Throws:  Consultingwerk.Exceptions.InvalidValueException 
        @param plcValue The Character value to validate                                       
        @param pcValueDesc The optional description of the value used in the InvalidValueException
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID NotNullOrEmpty (plcValue AS LONGCHAR,
                                              pcValueDesc AS CHARACTER):
        
        IF plcValue > "":U THEN . 
        ELSE  
            UNDO, THROW NEW InvalidValueException (STRING(plcValue), pcValueDesc) .

    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Validates an ABL Integer value so that it is not ? or 0   
        Notes:   
        Throws:  Consultingwerk.Exceptions.InvalidValueException 
        @param piValue The Integer value to validate                                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID NotNullOrZero (piValue AS INTEGER):
        
        IF piValue <> 0 AND piValue <> ? THEN . 
        ELSE  
            UNDO, THROW NEW InvalidValueException (STRING (piValue)) .

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Validates an ABL Integer value so that it is not ? or 0   
        Notes:   
        Throws:  Consultingwerk.Exceptions.InvalidValueException 
        @param piValue The Integer value to validate                                       
        @param pcValueDesc The optional description of the value used in the InvalidValueException
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC VOID NotNullOrZero (piValue AS INTEGER,
                                             pcValueDesc AS CHARACTER):
        
        IF piValue <> 0 AND piValue <> ? THEN . 
        ELSE  
            UNDO, THROW NEW InvalidValueException (STRING (piValue), pcValueDesc) .

    END METHOD .

END CLASS.
