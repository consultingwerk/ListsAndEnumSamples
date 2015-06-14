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
    File        : AddressTypeEnum
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Mike
    Created     : Sat Jun 06 09:42:28 CEST 2015
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.*                       FROM PROPATH .
USING Consultingwerk.Framework.Collections.* FROM PROPATH .
USING Samples.Serialization.*                FROM PROPATH .  
USING Progress.Lang.*                        FROM PROPATH .

CLASS Samples.Serialization.AddressTypeEnum INHERITS Enum: 

    {Consultingwerk/EnumMember.i Unknown 0 AddressTypeEnum}
    {Consultingwerk/EnumMember.i Office 1 AddressTypeEnum}
    {Consultingwerk/EnumMember.i Private 2 AddressTypeEnum}
    {Consultingwerk/EnumMember.i Shipping 3 AddressTypeEnum}
    {Consultingwerk/EnumMember.i Invoice 4 AddressTypeEnum}

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the AddressTypeEnum members
        Notes:
        @param piValue The internal (numeric) representation of the Enumeration member
        @param pcLabel The text label of the Enumaration member
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE AddressTypeEnum (piValue AS INTEGER, pcLabel AS CHARACTER):
        SUPER ().
 
        ASSIGN THIS-OBJECT:Value = piValue
               THIS-OBJECT:Label = pcLabel .
 
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: Returns a CharacterList with the names of the Enum members
        Notes:   
        @return The CharacterList with the names of the Enum members
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CharacterList GetNames ():
 
        DEFINE VARIABLE oReturn AS CharacterList NO-UNDO . 
 
        RETURN NEW CharacterList ('{&EnumMembers}':U).
 
    END METHOD .
	
    {Consultingwerk/EnumFromString.i Samples.Enums.AddressTypeEnum} 

END CLASS.
