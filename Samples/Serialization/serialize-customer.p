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
    File        : serialize-customer.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Thu Jun 04 11:18:43 CEST 2015
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

USING Consultingwerk.Framework.Base.* FROM PROPATH . 
USING Samples.Serialization.*         FROM PROPATH .

DEFINE VARIABLE oCustomer       AS Customer NO-UNDO . 
DEFINE VARIABLE oInvoiceAddress AS Address  NO-UNDO .

DEFINE VARIABLE lcSerialization AS LONGCHAR NO-UNDO . 

/* ***************************  Main Block  *************************** */

FIND FIRST Customer NO-LOCK . 

oCustomer = NEW Customer (BUFFER Customer:HANDLE) .

/* Add another address to Customer */
oInvoiceAddress = NEW Address () . 
oInvoiceAddress:AddressType = AddressTypeEnum:Invoice .
oInvoiceAddress:Address     = "219 Littleton Road" .
oInvoiceAddress:City        = "Westford" .
oInvoiceAddress:State       = "MA" .
oInvoiceAddress:PostalCode  = "01886" .

oCustomer:Addresses:Add (oInvoiceAddress) .

lcSerialization = oCustomer:Serialize() .

MESSAGE STRING (lcSerialization)
    VIEW-AS ALERT-BOX.
    
COPY-LOB FROM lcSerialization TO FILE "Samples\Serialization\customer.json" .    
    
    