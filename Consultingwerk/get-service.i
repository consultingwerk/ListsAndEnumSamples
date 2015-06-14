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
    File        : get-service.i
    Purpose     : Simplify the access of services form the default
                  service container  

    Syntax      : {Consultingwerk/get-service.i <ABL Service Type Name (Class)>} 
                  {Consultingwerk/get-service.i Consultingwerk.BusinessEntityDesigner.Services.IFieldNameGeneratorService}

                  Optinal second parameter: A reference (NEW statament) to the 
                  default service implementation

    Description : Returns a reference to a service of a give type, typically
                  an Interface type. Allows singleton like classes (framework
                  components) that are not tied to an actual class name, but
                  to an interface  

    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Tue Aug 02 14:12:07 CEST 2011
    Notes       : Sess Consultingwerk.Framework.ServiceContainer
  ----------------------------------------------------------------------*/

/* ***************************  Main Block  *************************** */

&IF PROVERSION BEGINS "10" OR PROVERSION EQ "11.0" OR PROVERSION EQ "11.1" OR PROVERSION EQ "11.2" OR PROVERSION EQ "11.3" &THEN

    &IF "{2}":U EQ "":U &THEN
    
    CAST (Consultingwerk.Framework.FrameworkSettings:ServiceContainer:GetService
                    (Progress.Lang.Class:GetClass ("{1}":U)),
                     {1})
         
    &ELSE
    
    (IF VALID-OBJECT (Consultingwerk.Framework.FrameworkSettings:ServiceContainer:GetService
                                (Progress.Lang.Class:GetClass ("{1}":U))) THEN
    
        CAST (Consultingwerk.Framework.FrameworkSettings:ServiceContainer:GetService
                    (Progress.Lang.Class:GetClass ("{1}":U)), {1})
        ELSE
        CAST (Consultingwerk.Framework.FrameworkSettings:ServiceContainer:AddService
                    (Progress.Lang.Class:GetClass ("{1}":U), {2}), {1})
    )
    &ENDIF
&ELSE

    &IF "{2}":U EQ "":U &THEN
    
    CAST (Consultingwerk.Framework.FrameworkSettings:ServiceContainer:GetService
                    (GET-CLASS ({1})),
                     {1})
         
    &ELSE
    
    (IF VALID-OBJECT (Consultingwerk.Framework.FrameworkSettings:ServiceContainer:GetService
                                (GET-CLASS ({1}))) THEN
    
        CAST (Consultingwerk.Framework.FrameworkSettings:ServiceContainer:GetService
                    (GET-CLASS ({1})), {1})
        ELSE
        CAST (Consultingwerk.Framework.FrameworkSettings:ServiceContainer:AddService
                    (GET-CLASS ({1}), {2}), {1})
    )
    &ENDIF



&ENDIF

