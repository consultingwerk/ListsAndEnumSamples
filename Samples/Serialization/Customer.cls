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
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Mike
    Created     : Sat Jun 06 10:34:27 CEST 2015
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{Consultingwerk/products.i}

USING Consultingwerk.*           FROM PROPATH .
USING Consultingwerk.Assertion.* FROM PROPATH.
USING Samples.Serialization.*    FROM PROPATH .  
USING Progress.Lang.*            FROM PROPATH .

CLASS Samples.Serialization.Customer 
&IF '{&FrameworkSerializationType}' EQ 'XML' OR PROVERSION BEGINS '10.2':U &THEN
    INHERITS XmlSerializable
&ELSE
    INHERITS JsonSerializable
&ENDIF
    :

    {Consultingwerk/JsonSerializableProperty.i Addresses Samples.Serialization.ListAddress} .
    {Consultingwerk/JsonSerializableProperty.i CustNum INTEGER} .
    {Consultingwerk/JsonSerializableProperty.i Name CHARACTER} .
    {Consultingwerk/JsonSerializableProperty.i Contact CHARACTER} .
    {Consultingwerk/JsonSerializableProperty.i Phone CHARACTER} .
    {Consultingwerk/JsonSerializableProperty.i SalesRep CHARACTER} .
    {Consultingwerk/JsonSerializableProperty.i CreditLimit DECIMAL} .
    {Consultingwerk/JsonSerializableProperty.i Balance DECIMAL} .
    {Consultingwerk/JsonSerializableProperty.i Discount INTEGER} .
    {Consultingwerk/JsonSerializableProperty.i Comments CHARACTER} .
    {Consultingwerk/JsonSerializableProperty.i Fax CHARACTER} .
    {Consultingwerk/JsonSerializableProperty.i EmailAddress CHARACTER} .
    {Consultingwerk/JsonSerializableProperty.i Terms Samples.Serialization.TermsEnum} .

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the Customer class
        Notes:
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC Customer ():
        SUPER ().
        THIS-OBJECT:AddSerializableProperties ('{&SerializableProperties}':U) .
        THIS-OBJECT:Addresses = NEW ListAddress () . 

    END CONSTRUCTOR. 

/*------------------------------------------------------------------------------
        Purpose: Constructor for the Customer class
        Notes:   
        @param piCustNum The value for the CustNum
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC Customer (piCustNum AS INTEGER):
        THIS-OBJECT ().
        
        ASSIGN THIS-OBJECT:CustNum = piCustNum .
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the Customer class
        Notes:   
        @param piCustNum The value for the CustNum
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC Customer (phBuffer AS HANDLE):
        DEFINE VARIABLE oAddress AS Address NO-UNDO .         
        
        THIS-OBJECT ().
        
        BufferAssert:IsAvailable (phBuffer) .

        ASSIGN THIS-OBJECT:CustNum      = phBuffer::CustNum 
               THIS-OBJECT:Name         = phBuffer::Name         
               THIS-OBJECT:Contact      = phBuffer::Contact      
               THIS-OBJECT:Phone        = phBuffer::Phone        
               THIS-OBJECT:SalesRep     = phBuffer::SalesRep     
               THIS-OBJECT:CreditLimit  = phBuffer::CreditLimit  
               THIS-OBJECT:Balance      = phBuffer::Balance      
               THIS-OBJECT:Discount     = phBuffer::Discount     
               THIS-OBJECT:Comments     = phBuffer::Comments     
               THIS-OBJECT:Fax          = phBuffer::Fax          
               THIS-OBJECT:EmailAddress = phBuffer::EmailAddress .

        THIS-OBJECT:Terms = TermsEnum:FromString (phBuffer::Terms) .                

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
