&IF 1=0 &THEN
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
    File        : products.i
    Purpose     : Contains compile time flags indicating the available
                  Consultingwerk framework products / developer toolkits  

    Syntax      : include file

    Description : 

    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Thu Feb 03 21:35:47 CET 2011
    Notes       : OERASI preprocessor controls the default path to the 
                  service interface procedures in include files. Used 
                  in the ServiceAdapter class and the proSI... procedures
                  
                  The comments in this file are excluded from the preprocessed
                  source code to avoid incluencing the class documentation 
                  tools which work on preprocessed source code
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Mike Fechner, Consultingwerk Ltd. 08.08.2011
   The GUI for .NET products do require compilation on 
   MS Windows anyhow - so this seems like a good practice */
&ENDIF   
   
&IF "{&WINDOW-SYSTEM}":U BEGINS "MS-WIN":U &THEN  
&IF 1=0 &THEN 
/*&GLOBAL-DEFINE Dynamics4NET */
/*&GLOBAL-DEFINE SmartComponentLibrary*/
/*&GLOBAL-DEFINE WinKit*/
&ENDIF
&ENDIF

&IF 1=0 &THEN 
/*&GLOBAL-DEFINE SmartFramework*/
/*&GLOBAL-DEFINE OpenEdgeBPM*/
/*&GLOBAL-DEFINE WinKitDemo*/
&ENDIF

&IF 1=0 &THEN
/* Mike Fechner, Consultingwerk Ltd. 28.02.2014
   SmartFrameworkBackend switch allows access to SmartFramework functionality on the 
   Backend, e.g. ISecurityService */
&GLOBAL-DEFINE SmartFrameworkBackend
&ENDIF

&IF 1=0 &THEN
/* Mike Fechner, Consultingwerk Ltd. 15.12.2011
   The use of the SimpleDynamicsRepositoryService is optional, requires an ICFDB */
&ENDIF
&GLOBAL-DEFINE UseSimpleDynamicsRepositoryService 

&IF 1=0 &THEN
/* default path to OERA Service Interface */
&ENDIF
&GLOBAL-DEFINE OERASI OERA/support 

&IF 1=0 &THEN
/* Support for custom include files for the OERA/support/proSI...
   procedures. These include files can be in any directory, but 
   by convention need to be called: 
        proSIfetchDatasetCustom.i
        proSIinvokeMethodCustom.i
        proSIinvokeTaskCustom.i
        proSIretrieveCustom.i
        proSIsubmitCustom.i
        proSIvalidateEntityNameCustom.i   
   */
/*&GLOBAL-DEFINE ProSIcustomIncludeDirectory OERA/Custom*/
&ENDIF

&IF 1=0 &THEN
/* Mike Fechner, Consultingwerk Ltd. 12.02.2015
   SCL-577 : Allow to disable the handling of ERORR-STATUS:ERROR in the 
             service interface procedure - causing issues when 
             FIND <record> WHERE ... NO-ERROR was the last statement
             executed with NO-ERROR before returning to the Service Interface
             Some customers may rely on this... */
&GLOBAL-DEFINE IgnoreErrorStatusErrorInServiceInterfaceProcedure
&ENDIF

&IF 1=0 &THEN
/* Compilation allowed that accesses .NET classes?
   In 10.2B it would be sufficient to test for
   "{&WINDOW-SYSTEM}". For OE11 support for .NET 
   on the AppServer Character client is announced.
   Currently we do expect that in OE11 the test 
   for "{&WINDOW-SYSTEM} would not be sufficient 
   to know if .NET assemblies are accesible. */
&ENDIF
&IF "{&WINDOW-SYSTEM}":U BEGINS "MS-WIN":U &THEN   
&GLOBAL-DEFINE DotNetAccessible 
&ENDIF

&IF 1=0 &THEN
/* Include conditional compilation for Infragistics Controls, aka OpenEdge UltraControls */
&ENDIF
&GLOBAL-DEFINE Infragistics

&IF 1=0 &THEN
/* Include conditional compilation for Telerik Rad Controls, aka UI for WinForms */
&ENDIF
&GLOBAL-DEFINE TelerikRadControls

&IF 1=0 &THEN
/* Include conditional compilation for Telerik Kendo UI */
&ENDIF
&GLOBAL-DEFINE TelerikKendoUI

&IF 1=0 &THEN
/* Ability to exclude procedural OERA from prosi... procedures.

   The support for the procedural OERA is now optional in the 
   service interface. To disable the support, please set the 
   ExcludeProceduralOERA in Consultingwerk/products.i. When set, 
   Business Entity Names without a . (dot) will be considered 
   object-oriented. It's no longer required to deploy beSupport.p, 
   daSupport.p and service.p when using this option. 

   Note, the use of the procedural business entities is still 
   supported. However we've received requests from customers just 
   using the OO versions of the business entities that this is 
   considered unnecessary legacy code... As the OO OERA backend 
   has more functionality (e.g. FindOnServer, backwards batching) 
   we do not intend to implement an "ExcludeObjectOrientedOERA" 
   switch for customers that are not (yet) using OO business 
   entities. */
/*&GLOBAL-DEFINE ExcludeProceduralOERA*/
&ENDIF 
 
&IF 1=0 &THEN
/* Mike Fechner, Consultingwerk Ltd. 03.01.2012
   Title of the Progress IDE (OpenEdge Architect 
   or Progress Developer Studio for OpenEdge */
&ENDIF
&IF PROVERSION GE "11" &THEN
&GLOBAL-DEFINE ProgressIDE Progress Developer Studio for OpenEdge
&ELSE 
&GLOBAL-DEFINE ProgressIDE OpenEdge Architect 
&ENDIF 

&IF 1=0 &THEN
/* Mike Fechner, Consultingwerk Ltd. 12.06.2012
   Ability to customize the Consultingwerk.Forms.BaseForm and 
   Consultingwerk.WindowIntegrationKit.Forms.EmbeddedWindowBaseForm
   classes without having to modify the actual classes itself */
&ENDIF
&GLOBAL-DEFINE CustomBaseFormImplements   
&GLOBAL-DEFINE CustomBaseFormInherits 
&GLOBAL-DEFINE CustomBaseFormIncludeFile 
&GLOBAL-DEFINE CustomBaseFormConstructorInclude 
&GLOBAL-DEFINE CustomBaseFormDestructorInclude 
&GLOBAL-DEFINE CustomBaseFormUsingInclude 

&GLOBAL-DEFINE CustomEmbeddedWindowBaseFormImplements   
&GLOBAL-DEFINE CustomEmbeddedWindowBaseFormIncludeFile
&GLOBAL-DEFINE CustomEmbeddedWindowBaseFormConstructorInclude 
&GLOBAL-DEFINE CustomEmbeddedWindowBaseFormDestructorInclude 
&GLOBAL-DEFINE CustomEmbeddedWindowBaseFormUsingInclude

&IF 1=0 &THEN
/* Mike Fechner, Consultingwerk Ltd. 27.01.2012
   Support for Actional Instrumentation, only with OpenEdge 11.0, no longer supported on OpenEdge 11.1 */
&ENDIF
&IF PROVERSION EQ "11.0" &THEN
&GLOBAL-DEFINE ActionalInstrumentation   
&ENDIF   

&IF 1=0 &THEN
/* Mike Fechner, Consultingwerk Ltd. 24.11.2012
   Optional Support for ZeroMQ for inter process communication */
&ENDIF
&GLOBAL-DEFINE UseZeroMQ

&IF 1=0 &THEN
/* Mike Fechner, Consultingwerk Ltd. 12.02.2013
   Debug option */
&ENDIF
{Consultingwerk/debug.i}
   
&IF 1=0 &THEN
/* Mike Fechner, Consultingwerk Ltd. 25.08.2013
   Optionally enforce the use of XML Serialization for the SmartFramework parameter types.
   This was introduced to allow the usage of the SmartFramework backend on an OpenEdge 
   10.2B AppServer. Note that to support this the actual serializable class needs to 
   test for the FrameworkSerializationType preprocessor. Values should be JSON or XML */
&ENDIF
&IF PROVERSION GE "11" &THEN
&GLOBAL-DEFINE FrameworkSerializationType JSON
&ELSE
&GLOBAL-DEFINE FrameworkSerializationType XML
&ENDIF

&IF 1=0 &THEN
/* Mike Fechner, Consultingwerk Ltd. 03.09.2013
   Avoid the usage of statics in hybrids, to avoid the issues with 
   the combination of static and hybrids on 11.2 and 11.3, OE defect OE00240707  
   http://knowledgebase.progress.com/articles/Article/000042229?popup=true */
&ENDIF
&IF PROVERSION BEGINS "11.2":U OR PROVERSION BEGINS "11.3" &THEN
&GLOBAL-DEFINE NoStaticsInHybrids
&ENDIF

&IF 1=0 &THEN
/* Mike Fechner, Consultingwerk Ltd. 16.01.2014
   Ability to activate a workaround for OpenEdge core issues, where (still at one 
   customer) on OpenEdge 11.3.1 the usage of static methods/properties/events in 
   hybrid classes and/or the overriding of .NET event methods (On... methods) 
   using an ABL method may cause a Progress.Lang.SysError with no message when 
   starting the Form the first time */
/*&GLOBAL-DEFINE RetryFormLaunchingOnProgressLangSysError*/
&ENDIF

&IF 1=0 &THEN
/* Mike Fechner, Consultingwerk Ltd. 18.09.2013
   A preprocessor to conditionally enable :U or :T for SmartComponent Library 
   error messages/debug information. This still allows customers to use 
   Translation Manager for these strings when the &GLOBAL-DEFINE is not 
   set - or set to :T */
&ENDIF
&GLOBAL-DEFINE TRAN :U

&IF 1=0 &THEN
/* Mike Fechner, Consultingwerk Ltd. 09.11.2013
   Optional ability to define a default batch size for use by the 
   SmartBusinessEntityAdapter queries*/
&ENDIF
&GLOBAL-DEFINE DefaultBatchSize 100   
   
&IF 1=0 &THEN
/* Mike Fechner, Consultingwerk Ltd. 09.11.2013
   Optional ability to define a default value for the STOP-AFTER
   behaviour of the Service Adapter */
&ENDIF
&GLOBAL-DEFINE DefaultStopAfter 15   
   
&IF 1=0 &THEN
/* Mike Fechner, Consultingwerk Ltd. 26.02.2014
   The list and label major version to use. This controls the cmllxx.i 
   Include file to be used to declare the list and label DLL functions. */
&ENDIF
&GLOBAL-DEFINE ListAndLabelVersion 18   

&IF 1=0 &THEN
/* Mike Fechner, Consultingwerk Ltd. 13.03.2014
   SCL-204: Ability to delay the deletion of the BaseForm instance during
   OnFormClosed by using a Timer event. Resolved crashes while closing some
   SmartComponent Library Forms at Interbos/Dynamics4.NET on Windows 8/Windows
   Server 2012 only */
/*&GLOBAL-DEFINE DelayFormDeletionOnFormClosed*/
&ENDIF

&IF 1=0 &THEN
/* Mike Fechner, Consultingwerk Ltd. 19.03.2014
   Clear the Tools Collection of a ToolbarsManager in the BaseForm OnFormClosed
   method , to workaround error: Attempt to use an object that has been 
   explicitly deleted (15580) when closing a Form that is using a 
   ControlContainerTool hosting an UltraNumericEditor, issue experienced by one
   customer on OpenEdge 11.3 */
/*&GLOBAL-DEFINE ClearToolsCollectionOnFormClosed*/
&ENDIF

&IF 1=0 &THEN
/* Mike Fechner, Consultingwerk Ltd. 19.05.2014
   SCL-283: Optionally do not register the BusinessEntityDesignerForm in the 
   ServiceContainer while starting the Business Entity Designer. This is to 
   workaround crashes occuring under 10.2B at a single customer only. */
/*&GLOBAL-DEFINE DoNotRegisterBusinessEntityDesignerForm*/
&ENDIF

&IF 1=0 &THEN
/* Mike Fechner, Consultingwerk Ltd. 25.09.2014
   SCL-475: Customers integrating legacy code in unit tests may require the 
            definition of NEW SHARED Variables or Buffers in the Unit Test
            runner Consultingwerk\SmartUnit\runtest.p */
&GLOBAL-DEFINE TestRunnerDefinition Name/And/Path/To/Your/include.i
&ENDIF

&IF 1=0 &THEN
/* Mike Fechner, Consultingwerk Ltd. 25.09.2014
   SCL-490: Support for serializable classes (e.g. errors) on OpenEdge 11.4 */
&ENDIF
&IF PROVERSION BEGINS "10" OR PROVERSION BEGINS "11.0" OR PROVERSION BEGINS "11.1" OR PROVERSION BEGINS "11.2" OR PROVERSION BEGINS "11.3" &THEN
&GLOBAL-DEFINE SERIALIZABLE
&ELSE
&GLOBAL-DEFINE SERIALIZABLE SERIALIZABLE 
&ENDIF

&IF 1=0 &THEN
/* Mike Fechner, Consultingwerk Ltd. 10.12.2014
   SCL-103: Trial version mode */
/*&GLOBAL-DEFINE TrialVersionMode*/
&ENDIF

&IF 1=0 &THEN
/* Mike Fechner, Consultingwerk Ltd. 19.02.2015
   SCL-665: Ability to turn the first version of the ICustomTypeDescriptor
            implementation back on. By default this implementation is disabled now,
            but can be turned on by cusotmers that still require if for custom 
            controls. The new ICustomTypeDescriptor implementation is based on the 
            Consultingwerk.SmartComponents.TypeDescriptor package. */
/*&GLOBAL-DEFINE LegacyCustomTypeDescriptorImplementation */
&ENDIF

&IF 1=0 &THEN
/* Mike Fechner, Consultingwerk Ltd. 25.09.2014
   SCL-489: Support for PASOE from OpenEdge 11.5 on */
&ENDIF
&IF PROVERSION BEGINS "10" OR PROVERSION BEGINS "11.0" OR PROVERSION BEGINS "11.1" OR PROVERSION BEGINS "11.2" OR PROVERSION BEGINS "11.3" OR PROVERSION BEGINS "11.4" &THEN
&GLOBAL-DEFINE NoPacificAppServer
&ELSE
&GLOBAL-DEFINE PacificAppServer
&ENDIF
