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
    File        : ServiceContainer
    Purpose     : Provides a container for services, default implementation
                  of the IServiceContainer interface 
    Syntax      : 
    Description : General purpose container to manage services by type / class
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Thu Dec 23 13:11:30 CET 2010
    Notes       : An instance is by default accessible from the 
                  Consultingwerk.Framework.FrameworkSettings class
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Consultingwerk.Framework.*            FROM PROPATH .
USING Consultingwerk.Framework.Exceptions.* FROM PROPATH .
USING Progress.Lang.*                       FROM PROPATH .

CLASS Consultingwerk.Framework.ServiceContainer
    IMPLEMENTS IServiceContainer, IServiceContainerDebugging: 

    DEFINE PRIVATE TEMP-TABLE ttServices NO-UNDO 
        FIELD ServiceType   AS CHARACTER    
        FIELD ServiceObject AS Progress.Lang.Object 
        INDEX ServiceType IS UNIQUE ServiceType  
        .

    { Consultingwerk/Framework/ttServiceTable.i }  

    /*------------------------------------------------------------------------------
        Purpose: Adds the specified service to the service container.                                                                      
        Notes:
        @param poClass The reference to the class or interface of the service to add
        @param poObject An instance of the service type to add. This object must implement or inherit from the type indicated by the serviceType parameter
        @return The reference to the service that was added (poObject). This allows fluid style usage of this routine                                                                       
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC Progress.Lang.Object AddService (poClass AS Progress.Lang.Class,
                                                   poObject AS Progress.Lang.Object):

        DEFINE BUFFER ttServices FOR ttServices . 

        Consultingwerk.Assertion.ObjectAssert:IsValid (poClass, "poClass":U) .
        Consultingwerk.Assertion.ObjectAssert:IsValid (poObject, "poObject":U) .

        IF FindService (poClass) THEN 
            UNDO, THROW NEW ServiceAlreadyRegisteredException (poClass) .

        CREATE ttServices . 
        ASSIGN ttServices.ServiceType   = poClass:TypeName
               ttServices.ServiceObject = poObject . 
                                        
        RETURN poObject .                                         
                                        
    END METHOD .                                        

    /*------------------------------------------------------------------------------
        Purpose: Searches the passed in Service Class in the ttService temp-table                                                                        
        Notes:       
        @param poClass The reference to the class or interface of the service that should be located
        @return Logical value indicating if the service is available                                                                 
    ------------------------------------------------------------------------------*/
    METHOD PROTECTED LOGICAL FindService (poClass AS Progress.Lang.Class):
        
        FIND ttServices WHERE ttServices.ServiceType = poClass:TypeName 
            NO-ERROR .
            
        ERROR-STATUS:ERROR = FALSE NO-ERROR . 
            
        RETURN AVAILABLE ttServices .         

    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Gets the service object of the specified type.                                                                        
        Notes:   Throws an ServiceNotRegisteredException when no service of that type 
                 registered 
        @param poClass The reference to the class or interface of the service to return
        @return The reference to the instance of the service of ? when the service is not registered with the service container 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC Progress.Lang.Object GetMandatoryService (poClass AS Progress.Lang.Class).

        DEFINE VARIABLE oInstance AS Progress.Lang.Object NO-UNDO . 
        
        oInstance = THIS-OBJECT:GetService (poClass) .
        
        IF NOT VALID-OBJECT (oInstance) THEN 
            UNDO, THROW NEW ServiceNotRegisteredException (poClass) .

        RETURN oInstance . 

    END METHOD .     

    /*------------------------------------------------------------------------------
        Purpose: Gets the service object of the specified type                                                                        
        Notes:   Returns ? when no service of that type is registered       
        @param poClass The reference to the class or interface of the service to return
        @return The reference to the instance of the service of ? when the service is not registered with the service container 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC Progress.Lang.Object GetService (poClass AS Progress.Lang.Class):

        Consultingwerk.Assertion.ObjectAssert:IsValid (poClass, "poClass":U) .

        IF NOT FindService (poClass) THEN 
            RETURN ? . 
            
        RETURN ttServices.ServiceObject . 
                 
    END METHOD . 

    /*------------------------------------------------------------------------------
        Purpose: Returns the service instances as a ttServiceTable output 
        Notes:   See Consultingwerk/Framework/ttServiceTable.i   
        @param ttServiceTable OUTPUT TABLE The temp-table with the service definitions
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC VOID GetServiceTable (OUTPUT TABLE FOR ttServiceTable):
		
		EMPTY TEMP-TABLE ttServiceTable . 
		
		FOR EACH ttServices:
		    CREATE ttServiceTable . 
		    ASSIGN ttServiceTable.ServiceType     = ttServices.ServiceType
		           ttServiceTable.ServiceInstance = ttServices.ServiceObject:ToString() .
		END.

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Removes the specified service type from the service container.                                                                        
        Notes:          
        @param poClass The reference to the class or interface of the service to remove from the service container.
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID RemoveService (poClass AS Progress.Lang.Class):
        
        Consultingwerk.Assertion.ObjectAssert:IsValid (poClass, "poClass":U) .
        
        IF NOT FindService (poClass) THEN 
            RETURN . 
        
        DELETE ttServices . 
        
    END METHOD .         

END CLASS.
