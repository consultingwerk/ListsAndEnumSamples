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

USING Samples.Customer.* FROM PROPATH.

DEFINE VARIABLE oCustomers AS Samples.Customer.Customer NO-UNDO EXTENT . 
DEFINE VARIABLE i          AS INTEGER                   NO-UNDO .

DEFINE QUERY qCustomer FOR Customer . 

/* ***************************  Main Block  *************************** */

OPEN QUERY qCustomer 
    PRESELECT EACH Customer WHERE Customer.CustNum < 1000 
                              AND Customer.SalesRep = "HXM" . 
    
EXTENT (oCustomers) = QUERY qCustomer:NUM-RESULTS . 

DO WHILE QUERY qCustomer:GET-NEXT ():
    i = i + 1 . 
    
    oCustomers[i] = NEW Customer (BUFFER Customer:Handle) .
    
END.    


