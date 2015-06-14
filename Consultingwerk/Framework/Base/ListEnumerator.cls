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
    File        : ListEnumerator
    Purpose     : Provides enumeration for the List class
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Fri Jan 20 20:52:23 CET 2012
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.Framework.Base.*       FROM PROPATH .
USING Consultingwerk.Framework.Exceptions.* FROM PROPATH .
USING Progress.Lang.*                       FROM PROPATH .

CLASS Consultingwerk.Framework.Base.ListEnumerator 
    IMPLEMENTS IEnumerator: 

    DEFINE VARIABLE hBuffer   AS HANDLE    NO-UNDO.
    DEFINE VARIABLE hQuery    AS HANDLE    NO-UNDO.
    DEFINE VARIABLE cListHash AS CHARACTER NO-UNDO.

    /*------------------------------------------------------------------------------
        Purpose: Returns the current item in the List
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY Current AS Progress.Lang.Object NO-UNDO 
    GET:
        Consultingwerk.Assertion.HandleAssert:ValidHandle (hBuffer, "Enumeration":U) .
        Consultingwerk.Assertion.BufferAssert:IsAvailable (hBuffer) .
        
        RETURN hBuffer::ListItem .
        
    END GET . 

    /*------------------------------------------------------------------------------
        Purpose: Returns the List enumerated by this ListEnumerator instance 
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY List AS IEnumerable NO-UNDO 
    GET.
    PROTECTED SET. 

    /*------------------------------------------------------------------------------
        Purpose: Returns if the List has changed and the Enumerator needs to be Reset() 
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY ListChanged AS LOGICAL NO-UNDO INIT FALSE 
    GET.
    PROTECTED SET. 

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the ListEnumerator class                                                                       
        Notes:                                                      
        @param poList The reference to an implementation of the IEnumerable instance that is enumerated by this object instance
        @param phQuery The query handle create by the IEnumerable instance for this ListEnumerator instance
        @param phBuffer The buffer handle created by the IEnumerable instance for this ListEnumerator instance                  
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC ListEnumerator (poList AS IEnumerable,
                                       phQuery AS HANDLE, 
                                       phBuffer AS HANDLE):
        SUPER ().
        
        Consultingwerk.Assertion.ObjectAssert:IsValid (poList, "IEnumerable":U) .
        Consultingwerk.Assertion.HandleAssert:WidgetType (phQuery, Consultingwerk.WidgetTypeEnum:Query) .
        Consultingwerk.Assertion.HandleAssert:WidgetType (phBuffer, Consultingwerk.WidgetTypeEnum:Buffer) .
        Consultingwerk.Assertion.BufferAssert:HasField (phBuffer, "ListItem":U) .

        ASSIGN THIS-OBJECT:List = poList 
               hQuery           = phQuery 
               hBuffer          = phBuffer .

        THIS-OBJECT:Reset () .
               
        IF NOT TYPE-OF (poList, ISupportsListHash) AND TYPE-OF (poList, ISupportsListChanged) THEN
            CAST (poList, ISupportsListChanged):ListChanged:Subscribe (ListChangedHandler) .
               
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Event handler for the ListChanged event of the IEnumerable instance                                                                        
        Notes:   Requires the ISupportsListChanged interface to by implemented by the List                                  
        @param sender The sender of the event
        @param e The ListChangedEventArgs object instance with the data of the ListChanged event                                                                  
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED VOID ListChangedHandler (sender AS Progress.Lang.Object, 
                                              e AS ListChangedEventArgs):
        
        THIS-OBJECT:ListChanged = TRUE . 

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Moves the enumerator to the next item                                                                        
        Notes:                      
        @return True when the next item is available, false when not.                                                 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL MoveNext ():
        
        IF TYPE-OF (THIS-OBJECT:List, ISupportsListHash) AND 
           CAST (THIS-OBJECT:List, ISupportsListHash):ListHash <> cListHash THEN 
            UNDO, THROW NEW Consultingwerk.Framework.Exceptions.CannotMoveNextOnChangedList () . 
        
        IF THIS-OBJECT:ListChanged THEN 
            UNDO, THROW NEW Consultingwerk.Framework.Exceptions.CannotMoveNextOnChangedList () . 

        hQuery:GET-NEXT () .

        IF hQuery:QUERY-OFF-END THEN 
            RETURN FALSE . 
        ELSE
            RETURN TRUE . 

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Resets the Enumerator (starts enumerating from the first item on)                                                                    
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID Reset ():
        
        hQuery:QUERY-OPEN () .
        
        THIS-OBJECT:ListChanged = FALSE . 

        IF TYPE-OF (THIS-OBJECT:List, ISupportsListHash) THEN 
            ASSIGN cListHash = CAST (THIS-OBJECT:List, ISupportsListHash):ListHash .

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Destructor for the ListEnumerator class                                                                      
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DESTRUCTOR PUBLIC ListEnumerator ():
        IF VALID-HANDLE (hQuery) THEN DO:
            hQuery:QUERY-CLOSE () .
            DELETE OBJECT hQuery . 
        END.
        
        IF VALID-HANDLE (hBuffer) THEN 
            DELETE OBJECT hBuffer .
            
    END DESTRUCTOR.

END CLASS.
