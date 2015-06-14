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
    File        : ISerializable
    Purpose     : Interface describing methods of Objects that can be 
                  used to Serialize and Deserialize Object to potentially
                  carry them across an AppServer boundary or store them 
                  in a persistent storage
                  Serialization is done to a LONGCHAR to allow various
                  implementations  
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Wed Sep 15 18:07:54 CEST 2010
    Notes       : 
  ----------------------------------------------------------------------*/

INTERFACE Consultingwerk.ISerializable:  
  
    /*------------------------------------------------------------------------------
        Purpose: Returns an LONGCHAR (potentially XML) representation of the 
                 object instance                                                                        
        Notes:          
        @return The LONGCHAR representation of the ISerializable objects data                                          
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LONGCHAR Serialize ().

    /*------------------------------------------------------------------------------
        Purpose: Initializes the object instance based on the passed in LONGCHAR
                 (potentially XML) representation of the object instance                                                                      
        Notes:               
        @param pcSerializedReprasentation The stored LONGCHAR representation of the objects data                                                          
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID Deserialize (pcSerializedReprasentation AS LONGCHAR).

END INTERFACE.
