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
    File        : IJsonDateTypeFormatter
    Purpose     : Provides custom Json Date/DateTime/DateTime-TZ formatting
                  for the Json object mode. 
    Syntax      : 
    Description : Workaround for the fact, that there is no actual standard 
                  for date representation in Json and if may be required to provide
                  custom formatting based on the target system (e.g. JIRA)
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Fri Jan 25 23:34:14 CET 2013
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Json.ObjectModel.* FROM PROPATH .
USING Progress.Lang.*             FROM PROPATH .

INTERFACE Consultingwerk.IJsonDateTypeFormatter:  
  
    /*------------------------------------------------------------------------------
        Purpose: Adds a ABL Date property to the JsonObject 
        Notes:   
        @param poJsonObject The reference to the source JsonObject
        @param pcProperty The name of the property in the JsonObject
        @param pdtDate The date value
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC VOID Add (poJsonObject AS JsonObject,
                            pcProperty AS CHARACTER,
                            pdtDate AS DATE).

    /*------------------------------------------------------------------------------
        Purpose: Adds a ABL Date property to the JsonObject 
        Notes:   
        @param poJsonObject The reference to the source JsonObject
        @param pcProperty The name of the property in the JsonObject
        @param pdtDate The datetime value
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID Add (poJsonObject AS JsonObject,
                            pcProperty AS CHARACTER,
                            pdtDate AS DATETIME).

    /*------------------------------------------------------------------------------
        Purpose: Adds a ABL Date property to the JsonObject 
        Notes:   
        @param poJsonObject The reference to the source JsonObject
        @param pcProperty The name of the property in the JsonObject
        @param pdtDate The datetime-tz value
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID Add (poJsonObject AS JsonObject,
                            pcProperty AS CHARACTER,
                            pdtDate AS DATETIME-TZ).

    /*------------------------------------------------------------------------------
        Purpose: Returns the ABL Date value for a Json property                                                                       
        Notes:      
        @param poJsonObject The reference to the source JsonObject
        @param pcProperty The name of the property in the JsonObject
        @return The resulting DATE value                                                                  
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC DATE GetDate (poJsonObject AS JsonObject,
                                pcProperty AS CHARACTER).

    /*------------------------------------------------------------------------------
        Purpose: Returns the ABL DateTime value for a Json property                                                                       
        Notes:                                                                        
        @param poJsonObject The reference to the source JsonObject
        @param pcProperty The name of the property in the JsonObject
        @return The resulting DATETIME value                                                                  
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC DATETIME GetDateTime (poJsonObject AS JsonObject,
                                        pcProperty AS CHARACTER).

    /*------------------------------------------------------------------------------
        Purpose: Returns the ABL DateTime-TZ value for a Json property                                                                       
        Notes:                                                                        
        @param poJsonObject The reference to the source JsonObject
        @param pcProperty The name of the property in the JsonObject
        @return The resulting DATETIME-TZ value                                                                  
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC DATETIME-TZ GetDateTimeTz (poJsonObject AS JsonObject,
                                             pcProperty AS CHARACTER).

END INTERFACE.
