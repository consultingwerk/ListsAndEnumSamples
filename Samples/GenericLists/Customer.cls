/**********************************************************************
 * Copyright (C) 2006-2015 by Consultingwerk Ltd. ("CW") -            *
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
    File        : Customer
    Purpose     : Simple value object for Customer
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Thu Jun 04 11:19:03 CEST 2015
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Progress.Lang.*            FROM PROPATH .
USING Samples.Customer.*         FROM PROPATH .  
USING Consultingwerk.Assertion.* FROM PROPATH.
USING Consultingwerk.Framework.Base.* FROM PROPATH .
USING Samples.GenericLists.* FROM PROPATH.

CLASS Samples.GenericLists.Customer: 

    /*------------------------------------------------------------------------------
        Purpose: References the address of the customer
        Notes:   
    ------------------------------------------------------------------------------*/
	DEFINE PUBLIC PROPERTY Addresses AS ListAddress NO-UNDO 
	GET.
	SET. 

    /*------------------------------------------------------------------------------
        Purpose: 
        Notes:   
    ------------------------------------------------------------------------------*/
	DEFINE PUBLIC PROPERTY CustNum AS INTEGER NO-UNDO 
	GET.
	PRIVATE SET. 

    /*------------------------------------------------------------------------------
        Purpose: 
        Notes:   
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY Name AS CHARACTER NO-UNDO 
    GET.
    SET.

    /*------------------------------------------------------------------------------
        Purpose: 
        Notes:   
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY Contact AS CHARACTER NO-UNDO 
    GET.
    SET.

    /*------------------------------------------------------------------------------
        Purpose: 
        Notes:   
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY Phone AS CHARACTER NO-UNDO 
    GET.
    SET.

    /*------------------------------------------------------------------------------
        Purpose: 
        Notes:   
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY SalesRep AS CHARACTER NO-UNDO 
    GET.
    SET.

    /*------------------------------------------------------------------------------
        Purpose: 
        Notes:   
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY CreditLimit AS DECIMAL NO-UNDO 
    GET.
    SET.

    /*------------------------------------------------------------------------------
        Purpose: 
        Notes:   
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY Balance AS DECIMAL NO-UNDO 
    GET.
    SET.

    /*------------------------------------------------------------------------------
        Purpose: 
        Notes:   
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY Terms AS CHARACTER NO-UNDO 
    GET.
    SET.

    /*------------------------------------------------------------------------------
        Purpose: 
        Notes:   
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY Discount AS INTEGER NO-UNDO 
    GET.
    SET.

    /*------------------------------------------------------------------------------
        Purpose: 
        Notes:   
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY Comments AS CHARACTER NO-UNDO 
    GET.
    SET.

    /*------------------------------------------------------------------------------
        Purpose: 
        Notes:   
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY Fax AS CHARACTER NO-UNDO 
    GET.
    SET.

    /*------------------------------------------------------------------------------
        Purpose: 
        Notes:   
    ------------------------------------------------------------------------------*/
    DEFINE PUBLIC PROPERTY EmailAddress AS CHARACTER NO-UNDO 
    GET.
    SET.

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the Customer class
        Notes:   
        @param piCustNum The value for the CustNum
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC Customer (piCustNum AS INTEGER):
        SUPER ().
        
        ASSIGN THIS-OBJECT:CustNum = piCustNum .
        
        ASSIGN THIS-OBJECT:Addresses = NEW ListAddress () .
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the Customer class
        Notes:   
        @param piCustNum The value for the CustNum
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC Customer (phBuffer AS HANDLE):
        DEFINE VARIABLE oAddress AS Address NO-UNDO .         
        
        SUPER ().
        
        BufferAssert:IsAvailable (phBuffer) .

        ASSIGN THIS-OBJECT:Addresses = NEW ListAddress () .
        
        ASSIGN THIS-OBJECT:CustNum      = phBuffer::CustNum 
               THIS-OBJECT:Name         = phBuffer::Name         
               THIS-OBJECT:Contact      = phBuffer::Contact      
               THIS-OBJECT:Phone        = phBuffer::Phone        
               THIS-OBJECT:SalesRep     = phBuffer::SalesRep     
               THIS-OBJECT:CreditLimit  = phBuffer::CreditLimit  
               THIS-OBJECT:Balance      = phBuffer::Balance      
               THIS-OBJECT:Terms        = phBuffer::Terms        
               THIS-OBJECT:Discount     = phBuffer::Discount     
               THIS-OBJECT:Comments     = phBuffer::Comments     
               THIS-OBJECT:Fax          = phBuffer::Fax          
               THIS-OBJECT:EmailAddress = phBuffer::EmailAddress .

        oAddress = NEW Address () .
        
        THIS-OBJECT:Addresses:Add (oAddress) .
        
        ASSIGN oAddress:Country      = phBuffer::Country      
               oAddress:Address      = phBuffer::Address      
               oAddress:Address2     = phBuffer::Address2     
               oAddress:City         = phBuffer::City         
               oAddress:State        = phBuffer::State        
               oAddress:PostalCode   = phBuffer::PostalCode .
                  
    END CONSTRUCTOR.

END CLASS.
