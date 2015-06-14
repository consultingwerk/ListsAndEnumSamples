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
    File        : IJsonSerializable
    Purpose     : Specialization of the ISerializable Interface
                  Describes methods required for Json Serialization
                  The Interface is required for nesting Json Objects during 
                  the serialization (non-primitive properties)
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Fri Jun 29 23:11:10 CEST 2012
    Notes       : 
  ----------------------------------------------------------------------*/

USING Consultingwerk.*            FROM PROPATH .
USING Progress.Json.ObjectModel.* FROM PROPATH .
USING Progress.Lang.*             FROM PROPATH .

INTERFACE Consultingwerk.IJsonSerializable 
    INHERITS ISerializable:  
  
    /*------------------------------------------------------------------------------
        Purpose: Returns a JsonObject representation of the state of the class instance                                                                      
        Notes:   Returns the classname together with the Json serialization of the 
                 object
        @return The Progress.Json.ObjectModel.JsonObject representation of the ISerializable objects data                                                                               
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC Progress.Json.ObjectModel.JsonObject ToJsonObject () .  
  
    /*------------------------------------------------------------------------------
        Purpose: Initializes the object instance based on the passed in JsonObject
                 representation of the object instance                                                                      
        Notes:               
        @param poJsonObject The stored JsonObject representation of the objects data                                                          
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID DeserializeFromJsonObject (poJsonObject AS JsonObject) .
    
END INTERFACE.
