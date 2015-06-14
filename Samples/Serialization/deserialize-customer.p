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
USING Consultingwerk.* FROM PROPATH.

DEFINE VARIABLE oCustomer       AS Customer NO-UNDO . 

DEFINE VARIABLE lcSerialization AS LONGCHAR NO-UNDO . 

/* ***************************  Main Block  *************************** */

FIX-CODEPAGE (lcSerialization) = "utf-8" . 

COPY-LOB FROM FILE "Samples\Serialization\customer.json" TO lcSerialization .    

oCustomer = CAST (Consultingwerk.Serializable:DeserializeInstance (lcSerialization),
                  Customer) .

MESSAGE "CustNum"    oCustomer:CustNum SKIP 
        "Name"       oCustomer:Name SKIP
        "Terms"      oCustomer:Terms SKIP 
        "#Addresses" oCustomer:Addresses:Count 
    VIEW-AS ALERT-BOX.
    
    
    