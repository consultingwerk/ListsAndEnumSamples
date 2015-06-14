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

USING Consultingwerk.*           FROM PROPATH .
USING Consultingwerk.Assertion.* FROM PROPATH.
USING Samples.Serialization.*    FROM PROPATH .  
USING Progress.Lang.*            FROM PROPATH .

CLASS Samples.Serialization.Address 
&IF '{&FrameworkSerializationType}' EQ 'XML' OR PROVERSION BEGINS '10.2':U &THEN
    INHERITS XmlSerializable
&ELSE
    INHERITS JsonSerializable
&ENDIF
    :
    
    {Consultingwerk/JsonSerializableProperty.i Country CHARACTER} . 
    {Consultingwerk/JsonSerializableProperty.i Address CHARACTER} . 
    {Consultingwerk/JsonSerializableProperty.i Address2 CHARACTER} . 
    {Consultingwerk/JsonSerializableProperty.i City CHARACTER} . 
    {Consultingwerk/JsonSerializableProperty.i State CHARACTER} . 
    {Consultingwerk/JsonSerializableProperty.i PostalCode CHARACTER} . 
    {Consultingwerk/JsonSerializableProperty.i AddressType Samples.Serialization.AddressTypeEnum} . 
    
    /*------------------------------------------------------------------------------
        Purpose: Constructor for the Address class
        Notes:   
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC Address ():
        SUPER ().
        
        THIS-OBJECT:AddSerializableProperties ('{&SerializableProperties}':U) .
        THIS-OBJECT:AddressType = AddressTypeEnum:Unknown . 
        
    END CONSTRUCTOR.

END CLASS.
