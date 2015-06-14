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
    File        : IServiceContainer
    Purpose     : Provides a container for services. 
    Syntax      : 
    Description : General purpose interface to manage services by type / class
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Thu Dec 23 13:01:38 CET 2010
    Notes       : see System.ComponentModel.Design.IServiceContainer
                  http://msdn.microsoft.com/en-us/library/system.componentmodel.design.iservicecontainer.aspx
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

INTERFACE Consultingwerk.Framework.IServiceContainer:  
  
    /*------------------------------------------------------------------------------
        Purpose: Adds the specified service to the service container.                                                                      
        Notes:
        @param poClass The reference to the class or interface of the service to add
        @param poObject An instance of the service type to add. This object must implement or inherit from the type indicated by the serviceType parameter
        @return The reference to the service that was added (poObject). This allows fluid style usage of this routine                                                                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC Progress.Lang.Object AddService (poClass AS Progress.Lang.Class,
                                                   poObject AS Progress.Lang.Object).

    /*------------------------------------------------------------------------------
        Purpose: Gets the service object of the specified type.                                                                        
        Notes:   Throws an ServiceNotRegisteredException when no service of that type 
                 registered 
        @param poClass The reference to the class or interface of the service to return
        @return The reference to the instance of the service of ? when the service is not registered with the service container 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC Progress.Lang.Object GetMandatoryService (poClass AS Progress.Lang.Class).

    /*------------------------------------------------------------------------------
        Purpose: Gets the service object of the specified type.                                                                        
        Notes:   Returns ? when no service of that type is registered       
        @param poClass The reference to the class or interface of the service to return
        @return The reference to the instance of the service of ? when the service is not registered with the service container 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC Progress.Lang.Object GetService (poClass AS Progress.Lang.Class).

    /*------------------------------------------------------------------------------
        Purpose: Removes the specified service type from the service container.                                                                        
        Notes:          
        @param poClass The reference to the class or interface of the service to remove from the service container.
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID RemoveService (poClass AS Progress.Lang.Class).

END INTERFACE.