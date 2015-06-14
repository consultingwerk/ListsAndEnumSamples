&IF 1=0 &THEN
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
    File        : GenericList.i
    Purpose     : Generic List template for type safe Add and GetItem 
                  methods

    Syntax      : { Consultingwerk/Framework/Base/GenericList ItemType }

    Description : 

    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Thu Jan 20 20:52:06 CET 2011
    Notes       :
  ----------------------------------------------------------------------*/
&ENDIF

    /*------------------------------------------------------------------------------
        Purpose: Adds an item to the generic List                                                                      
        Notes:  
        @param poItem And item of the Lists member type
        @return The new Item added to the List                                                    
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC {1} Add (poItem AS {1}):
        
        SUPER:InternalAdd (poItem).

        RETURN poItem . 

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Adds an array of items to the generic List                                                                      
        Notes:  
        @param poItem An array of items of the Lists member type                                                                      
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID Add (poItem AS {1} EXTENT):
        
        SUPER:InternalAdd (poItem).

    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Retrieves an item from the generic List                                                                     
        Notes:   CAST's the element from the underlying Progress.Lang.Object based
                 list 
        @param piIndex The 1 based index of the item to retrieve
        @return The item of the Lists member type
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC {1} GetItem (INPUT piIndex AS INTEGER ):
        
        RETURN CAST (SUPER:InternalGetItem (piIndex), {1}) .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns an Array with the elements of the List                                                                      
        Notes:     
        @return The array of elements of the Lists member type                                                                   
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC {1} EXTENT ToArray ():
        
        DEFINE VARIABLE oArray AS {1}     NO-UNDO EXTENT . 
        DEFINE VARIABLE iCount AS INTEGER NO-UNDO .
        DEFINE VARIABLE i      AS INTEGER NO-UNDO .
        
        ASSIGN iCount = THIS-OBJECT:Count .
        
        IF iCount = 0 THEN DO: 
            EXTENT (oArray) = ? . 
            RETURN oArray . 
        END.
        
        EXTENT (oArray) = iCount . 
        
        DO i = 1 TO iCount:
            oArray[i] = CAST (THIS-OBJECT:InternalGetItem (i), {1}).
        END.
        
        RETURN oArray . 
        
    END METHOD . 
    