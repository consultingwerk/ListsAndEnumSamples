/**********************************************************************
 The MIT License (MIT)
 
 Copyright (c) 2015 Consultingwerk Ltd.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 **********************************************************************/ 
/*------------------------------------------------------------------------
    File        : ServiceNotRegisteredException
    Purpose     : Error thrown from ServiceContainer:GetMandatoryService 
                  when the requested service type is notregistered with 
                  the Service Container
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Thu Jan 15 22:32:24 CEST 2015
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.Exceptions.Exception.


USING Consultingwerk.Framework.Exceptions.* FROM PROPATH .  
USING Progress.Lang.* FROM PROPATH .

{Consultingwerk/products.i}

CLASS Consultingwerk.Framework.Exceptions.ServiceNotRegisteredException
    INHERITS Exception:  

    /*------------------------------------------------------------------------------
        Purpose: Returns the reference to the class or interface of the service that 
                 is not registered
        Notes:   
    ------------------------------------------------------------------------------*/
	DEFINE PUBLIC PROPERTY ServiceClass AS Progress.Lang.Class NO-UNDO 
	GET.
	PRIVATE SET. 

    /*------------------------------------------------------------------------------
        Purpose: Constructor for the ServiceAlreadyRegisteredException class
        Notes:   
        @param poServiceClass The reference to the Class or interface of the service that cannot be added
    ------------------------------------------------------------------------------*/
	CONSTRUCTOR PUBLIC ServiceNotRegisteredException (poServiceClass AS Progress.Lang.Class):
		SUPER (SUBSTITUTE ("The requested service type for ~"&1~" is not registered."{&TRAN}, 
		                   poServiceClass:TypeName), 
		       0) .
		
		THIS-OBJECT:ServiceClass = poServiceClass .
		
	END CONSTRUCTOR.

END CLASS.
