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
    File        : ListCustomer
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : Mike
    Created     : Fri Jun 05 22:10:22 CEST 2015
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.Framework.Base.* FROM PROPATH .
USING Samples.Enums.*          FROM PROPATH .  
USING Progress.Lang.*                 FROM PROPATH .

CLASS Samples.Enums.ListCustomer 
    INHERITS GenericList: 

    {Consultingwerk/Framework/Base/GenericList.i Customer}
 
END CLASS.

