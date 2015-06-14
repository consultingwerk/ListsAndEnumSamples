/**********************************************************************
 * Copyright (C) 2006-2013 by Consultingwerk Ltd. ("CW") -            *
 * www.consultingwerk.de and other contributors as listed             *
 * below.  All Rights Reserved.                                       *
 *                                                                    *
 *  Software is distributed on an "AS IS", WITHOUT WARRANTY OF ANY    *
 *   KIND, either express or implied.                                 *
 *                                                                    *
 *  Contributors:                                                     *
 *                                                                    *
 **********************************************************************/
/*------------------------------------------------------------------------
    File        : IEnumerator
    Purpose     : Interface for Enumerators of Lists, Collections or Dictionaries
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Fri Jan 20 20:46:18 CET 2012
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

INTERFACE Consultingwerk.Framework.Base.IEnumerator:  
  
    /*------------------------------------------------------------------------------
        Purpose: Returns the current item of the enumeration                                                                     
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY Current AS Progress.Lang.Object NO-UNDO 
    GET.
     
    /*------------------------------------------------------------------------------
        Purpose: Moves the enumerator to the next item                                                                        
        Notes:                      
        @return True when the next item is available, false when not.                                                  
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL MoveNext ().

    /*------------------------------------------------------------------------------
        Purpose: Resets the Enumerator (starts enumerating from the first item on)                                                                       
        Notes:                                                                        
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID Reset ().

END INTERFACE.