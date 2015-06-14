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
    File        : create-customer.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Thu Jun 04 11:18:43 CEST 2015
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

USING Consultingwerk.Framework.Base.* FROM PROPATH . 
USING Samples.CustomerWithList.*      FROM PROPATH.

DEFINE VARIABLE oCustomers AS List    NO-UNDO . 

DEFINE QUERY qCustomer FOR Customer . 

/* ***************************  Main Block  *************************** */

oCustomers = NEW List () .

OPEN QUERY qCustomer 
    PRESELECT EACH Customer WHERE Customer.CustNum < 1000 
                              AND Customer.SalesRep = "HXM" . 

DO WHILE QUERY qCustomer:GET-NEXT ():
    
    oCustomers:Add (NEW Customer (BUFFER Customer:Handle)) .
    
END.    

MESSAGE "Count" oCustomers:Count
    VIEW-AS ALERT-BOX.

    
    