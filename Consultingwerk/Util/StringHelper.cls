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
    File        : StringHelper
    Purpose     : Routines to support string (CHARACTER) operations
    Syntax      : 
    Description : 
    Author(s)   : Mike Fechner / Consultingwerk Ltd.
    Created     : Wed Oct 24 12:34:34 CEST 2012
    Notes       : 
  ----------------------------------------------------------------------*/

ROUTINE-LEVEL ON ERROR UNDO, THROW.

{Consultingwerk/products.i}

USING Consultingwerk.*                       FROM PROPATH .
USING Consultingwerk.Assertion.*             FROM PROPATH .  
USING Consultingwerk.Exceptions.*            FROM PROPATH .
USING Consultingwerk.Framework.Collections.* FROM PROPATH .  
USING Consultingwerk.Util.*                  FROM PROPATH .  
USING Progress.Lang.*                        FROM PROPATH .

CLASS Consultingwerk.Util.StringHelper: 

    /*------------------------------------------------------------------------------
        Purpose: Disallow instance creation
        Notes:   
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PRIVATE StringHelper ():
        SUPER ().
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
        Purpose: CamelCases a string from "Camel case" to "CamelCase"
        Notes:   Does support standard letters (ASCII only), no Umlaute 
        @param pcString The string containing a single word to camelcase
        @return The CamelCased version of the string 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER CamelCaseWords (pcString AS CHARACTER):
        
        DEFINE VARIABLE i      AS INTEGER NO-UNDO.
        DEFINE VARIABLE cEntry AS CHARACTER NO-UNDO.

        DO i = 1 TO NUM-ENTRIES (pcString, " ":U):
            
            ASSIGN cEntry = ENTRY (i, pcString, " ":U) .
            
            IF cEntry > "":U THEN DO:
                cEntry = StringHelper:CamelCaseWord (cEntry) .

                ENTRY (i, pcString, " ":U) = cEntry .
            END . 
        END.

        RETURN REPLACE (pcString, " ":U, "":U) . 

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: CamelCases a string from "Camel case" to "CamelCase"
        Notes:   Does support standard letters (ASCII only), no Umlaute
                 This version of CamelCaseWords does only enforece uppercase on the
                 first letter of each word and does not change the case of any other 
                 character - so existing upper case chars stay upper case (which is 
                 different from the method CamelCaseWords) 
        @param pcString The string containing a single word to camelcase
        @return The CamelCased version of the string 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER CamelCaseWords2 (pcString AS CHARACTER):
    
        DEFINE VARIABLE iAsc   AS INTEGER   NO-UNDO.        
        DEFINE VARIABLE i      AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cEntry AS CHARACTER NO-UNDO.

        DO i = 1 TO NUM-ENTRIES (pcString, " ":U):
            
            ASSIGN cEntry = ENTRY (i, pcString, " ":U) .
            
            ASSIGN iAsc = ASC (SUBSTRING (cEntry, 1, 1)) .
            
            IF iAsc >= 97 AND iAsc <= 122 THEN DO:
                iAsc = iAsc - 32 . 
                SUBSTRING (cEntry, 1, 1) = CHR (iAsc) .
            END. 
            
            ENTRY (i, pcString, " ":U) = cEntry .
        END.

        RETURN REPLACE (pcString, " ":U, "":U) . 

    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: CamelCases a single word
        Notes:   Does support standard letters (ASCII only), no Umlaute 
        @param pcWord The string containing a single word to camelcase
        @return The CamelCased version of the word 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER CamelCaseWord (pcWord AS CHARACTER):

        DEFINE VARIABLE iPos AS INTEGER NO-UNDO.
        DEFINE VARIABLE iAsc AS INTEGER NO-UNDO.
    
        ASSIGN pcWord = TRIM (pcWord) .
    
        Assert:NotNullOrEmpty (pcWord) .        
        ListAssert:NumEntries (pcWord, " ":U, 1) .
        
        iAsc = ASC (SUBSTRING (pcWord, 1, 1)) .
        
        IF iAsc >= 97 AND iAsc <= 122 THEN DO:
            iAsc = iAsc - 32 . 
            SUBSTRING (pcWord, 1, 1) = CHR (iAsc) .
        END. 
        
        DO iPos = 2 TO LENGTH (pcWord):
            iAsc = ASC (SUBSTRING (pcWord, iPos, 1)) .
            
            IF iAsc >= 65 AND iAsc <= 90 THEN DO:
                iAsc = iAsc + 32 . 
                SUBSTRING (pcWord, iPos, 1) = CHR (iAsc) .
            END. 
        END.

        RETURN pcWord . 

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Capitalizes the first letter of a given string 
        Notes:   
        @param pcString The string in which to capitalize the first letter
        @return The string with the first letter capitalized
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER CapitalizeFirstLetter (pcString AS CHARACTER):
        
        DEFINE VARIABLE cFirst AS CHARACTER NO-UNDO.
        
        IF pcString = "":U OR pcString = ? THEN 
            RETURN pcString . 
            
        ASSIGN cFirst = SUBSTRING (pcString, 1, 1) .
        
        IF ASC (cFirst) = ASC (LC (cFirst)) THEN DO: 
            cFirst = CHR (ASC (cFirst) - 32) .
          
            SUBSTRING (pcString, 1, 1) = cFirst .
        END.
        
        RETURN pcString .

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Counts the occurences of the given target string in the source string
        Notes:   Does ignore occurences within quotes
        @param pcTargetString The string to count in the pcSourceString
        @param pcSourceString The string to count in
        @return The number of occurences of the target string within the source string excluding occurences in quotes
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC INTEGER CountOccurencesOf (pcTargetString AS CHARACTER,
                                                    pcSourceString AS CHARACTER):

        DEFINE VARIABLE iCount  AS INTEGER   NO-UNDO .
        DEFINE VARIABLE iPos    AS INTEGER   NO-UNDO INIT 1.
        DEFINE VARIABLE iLength AS INTEGER   NO-UNDO .
        DEFINE VARIABLE cChar   AS CHARACTER NO-UNDO .
        
        Assert:Equals (1, LENGTH (pcTargetString)) .
        
        ASSIGN iLength = LENGTH (pcSourceString) . 
        
        DO WHILE iPos <= iLength ON ERROR UNDO, THROW:
            ASSIGN cChar = SUBSTRING (pcSourceString, iPos, 1) .    
            
            CASE cChar:
                WHEN pcTargetString THEN 
                    iCount = iCount + 1 .
                WHEN "'":U OR WHEN '"':U THEN 
                    ASSIGN iPos = StringHelper:FindClosingQuote (pcSourceString, iPos) .
            END CASE . 
            
            iPos = iPos + 1 .
        END.
        
        RETURN iCount .

    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Returns TRUE when the given source string ends in the ending string 
        Notes:   Equivalint to the ABL BEGINS operator / function
        @param pcSourceString The source string to check if it ends with the ending string
        @param pcEndingString The string to check if the source string ends with
        @return Logical value indicating if the given source string ends in the ending string
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LOGICAL Ends (pcSourceString AS CHARACTER, 
                                       pcEndingString AS CHARACTER):
        
        IF pcSourceString MATCHES SUBSTITUTE ("*&1":U, pcEndingString) THEN 
            RETURN TRUE . 

        RETURN FALSE .

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns the position of the closing bracket for the bracket opened
                 at the given position in the String 
        Notes:   Ignores brackets that are within a quote
        Throws:  Consultingwerk.Exceptions.UnmatchedBracketException, Consultingwerk.Exceptions.InvalidParameterValueException
        @param pcString The LONGCHAR string to locate the closing bracket in 
        @param piPosition The position of the opening bracket in the string
        @return The position of the closing quote
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC INTEGER FindClosingBracket (pcString AS LONGCHAR, 
                                                     piPosition AS INTEGER):
        
        DEFINE VARIABLE cBracket        AS CHARACTER     NO-UNDO INIT "":U.
        DEFINE VARIABLE cClosingBracket AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iPos            AS INTEGER       NO-UNDO .
        DEFINE VARIABLE cChar           AS CHARACTER     NO-UNDO .
        DEFINE VARIABLE iLevel          AS INTEGER       NO-UNDO .

        ASSIGN cBracket = SUBSTRING (pcString, piPosition, 1) .
        
        CASE cBracket:
            WHEN "(":U THEN 
                ASSIGN cClosingBracket = ")":U . 
            WHEN "~{":U THEN 
                ASSIGN cClosingBracket = "}":U . 
            WHEN "[":U THEN 
                ASSIGN cClosingBracket = "]":U . 
            OTHERWISE 
                UNDO, THROW NEW InvalidParameterValueException ("piPosition":U,
                                                                STRING (piPosition),
                                                                "Consultingwerk.Util.StringHelper":U) .
        END CASE . 
        
        DO iPos = piPosition TO LENGTH (pcString):
            ASSIGN cChar = SUBSTRING (pcString, iPos, 1) .

            IF cChar = cBracket THEN 
                ASSIGN iLevel = iLevel + 1 . 
            ELSE IF cChar = cClosingBracket THEN 
                ASSIGN iLevel = iLevel - 1 . 
            ELSE IF cChar = "~"":U OR cChar = "'":U THEN 
                ASSIGN iPos = StringHelper:FindClosingQuote (pcString, iPos) .
        
            IF iLevel = 0 THEN 
                RETURN iPos . 
        END .
        
        UNDO, THROW NEW UnmatchedBracketException (pcString, cBracket, piPosition) .

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns the position of the closing comment for the comment opened
                 at the given position in the String 
        Notes:   Returns the position of a / of the comment terminator star slash, 
                 Comments in quotes are ignored, it is however expected that the 
                 opening comment is not inside a quote
        Throws:  Consultingwerk.Exceptions.UnmatchedCommentException, Consultingwerk.Exceptions.InvalidParameterValueException
        @param pcString The LONGCHAR string to locate the closing bracket in 
        @param piPosition The position of the opening bracket in the string
        @return The position of the closing quote
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC INTEGER FindClosingComment (pcString AS LONGCHAR, 
                                                     piPosition AS INTEGER):
        
        DEFINE VARIABLE cOpeningComment AS CHARACTER     NO-UNDO INIT "":U.
        DEFINE VARIABLE cClosingComment AS CHARACTER     NO-UNDO INIT "*/":U.
        DEFINE VARIABLE iPos            AS INTEGER       NO-UNDO .
        DEFINE VARIABLE cChar           AS CHARACTER     NO-UNDO .
        DEFINE VARIABLE cChar2          AS CHARACTER     NO-UNDO .
        DEFINE VARIABLE iLevel          AS INTEGER       NO-UNDO .

        ASSIGN cOpeningComment = SUBSTRING (pcString, piPosition, 2) .
        
        IF cOpeningComment <> "/*":U THEN  
                UNDO, THROW NEW InvalidParameterValueException ("piPosition":U,
                                                                STRING (piPosition),
                                                                "Consultingwerk.Util.StringHelper":U) .
        
        DO iPos = piPosition TO LENGTH (pcString) - 1:
            ASSIGN cChar  = SUBSTRING (pcString, iPos, 1) 
                   cChar2 = SUBSTRING (pcString, iPos, 2).

            IF cChar2 = cOpeningComment THEN 
                ASSIGN iLevel = iLevel + 1 . 
            ELSE IF cChar2 = cClosingComment THEN 
                ASSIGN iLevel = iLevel - 1 . 
            ELSE IF cChar = "~"":U OR cChar = "'":U THEN 
                ASSIGN iPos = StringHelper:FindClosingQuote (pcString, iPos) .
        
            IF iLevel = 0 THEN 
                RETURN iPos + 1 . 
        END .
        
        UNDO, THROW NEW UnmatchedCommentException (pcString, piPosition) .

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns the position of the closing quote sign (either " or ') in a String 
        Notes:   
        Throws:  Consultingwerk.Exceptions.UnmatchedQuoteException, Consultingwerk.Exceptions.InvalidParameterValueException
        @param pcString The LONGCHAR string to locate the closing quote in 
        @param piPosition The position of the opening quote in the string
        @return The position of the closing quote
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC INTEGER FindClosingQuote (pcString AS LONGCHAR, 
                                                   piPosition AS INTEGER):
        
        DEFINE VARIABLE cQuoteChar AS CHARACTER     NO-UNDO INIT "":U.
        DEFINE VARIABLE iPos       AS INTEGER       NO-UNDO .
        DEFINE VARIABLE cChar      AS CHARACTER     NO-UNDO .
        DEFINE VARIABLE lInQuote   AS LOGICAL       NO-UNDO INIT FALSE .

        ASSIGN cQuoteChar = SUBSTRING (pcString, piPosition, 1) .
        
        IF cQuoteChar <> "~"":U AND cQuoteChar <> "'":U THEN 
            UNDO, THROW NEW InvalidParameterValueException ("piPosition":U,
                                                            STRING (piPosition),
                                                            "Consultingwerk.Util.StringHelper":U) .
        pcString = TRIM (pcString) .
        
        DO iPos = piPosition + 1 TO LENGTH (pcString):
            ASSIGN cChar = SUBSTRING (pcString, iPos, 1) .  

            IF cChar = "~"":U OR 
               cChar = "'":U THEN DO:
                IF cQuoteChar = "":U THEN DO:
                    ASSIGN cQuoteChar = cChar
                           lInQuote   = TRUE .
                END.
                ELSE IF cQuoteChar = cChar THEN DO:
                    ASSIGN lInQuote   = FALSE
                           cQuoteChar = "":U .

                    RETURN iPos . 
                END.
            END. /* " or ' */
        END.

        UNDO, THROW NEW UnmatchedQuoteException (pcString, piPosition) .

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns the first position of any of the given characters in the 
                 source string 
        Notes:   Returns 0 when none of the characters can be found
        @param pcSourceString The source string
        @param pcCharacters The comma-delimited list of characters
        @return The first position of any of the given characters
    ------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC INTEGER FirstOccurenceOf (pcSourceString AS CHARACTER, 
	                                               pcCharacters   AS CHARACTER):
		   
        RETURN StringHelper:FirstOccurenceOf (pcSourceString, pcCharacters, 0) .

	END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns the first position of any of the given characters in the 
                 source string 
        Notes:   Returns 0 when none of the characters can be found
        @param pcSourceString The source string
        @param pcCharacters The comma-delimited list of characters
        @param piStarting An integer that specifies at which left-most position in the string to start the search
        @return The first position of any of the given characters
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC INTEGER FirstOccurenceOf (pcSourceString AS CHARACTER, 
                                                   pcCharacters   AS CHARACTER,
                                                   piStarting     AS INTEGER):
        
        DEFINE VARIABLE i         AS INTEGER NO-UNDO .
        DEFINE VARIABLE iCount    AS INTEGER NO-UNDO .
        DEFINE VARIABLE iPosition AS INTEGER NO-UNDO INIT 0.
        DEFINE VARIABLE iTmp      AS INTEGER NO-UNDO .
        
        ASSIGN iCount = NUM-ENTRIES (pcCharacters) .
    
        DO i = 1 TO iCount:
            IF piStarting > 0 THEN 
                ASSIGN iTmp = INDEX (pcSourceString, ENTRY (i, pcCharacters), piStarting) .
            ELSE 
                ASSIGN iTmp = INDEX (pcSourceString, ENTRY (i, pcCharacters)) .
            
            IF iTmp = 0 THEN 
                NEXT . 
                
            IF iPosition = 0 THEN 
                ASSIGN iPosition = iTmp . 
            ELSE 
                ASSIGN iPosition = MIN (iTmp, iPosition) . 
        END.
    
        RETURN iPosition .

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Fixes the line ending characters of the given longchar 
        Notes:   Line Ending will be set to Consultingwerk.Environment:NewLine
        @param plcString The Longchar to fix the line ending at
        @return The Longchar value with the fixed line ending characters
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR FixLineEnding (plcString AS LONGCHAR):
        

        ASSIGN plcString = REPLACE (plcString, CHR(13), "":U)
               plcString = REPLACE (plcString, CHR(10), Consultingwerk.Environment:NewLine) .

        RETURN plcString.

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns the CHARACTER representation of a new UUID
        Notes:   
        @return The CHARACTER representation of the new UUID
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER GenerateUuid ():
        
        DEFINE VARIABLE rUuid       AS RAW       NO-UNDO .
        DEFINE VARIABLE cBase64Uuid AS CHARACTER NO-UNDO . 
        
        ASSIGN   
            rUuid       = GENERATE-UUID  
            cBase64Uuid = BASE64-ENCODE (rUuid).

        IF cBase64Uuid MATCHES "*==":U THEN 
            RETURN SUBSTRING (cBase64Uuid, 1, LENGTH (cBase64Uuid) - 2) .

        RETURN cBase64Uuid .

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Indents a string by inserting a SPACE character at the beginning 
                 of every line
        Notes:   
        @param pcString The string to indent
        @param piIndent The number of characters to indent the string
        @return The indented string
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER Indent (pcString AS CHARACTER,  
                                           piIndent AS INTEGER):
        
        DEFINE VARIABLE cResult AS CHARACTER NO-UNDO .
        DEFINE VARIABLE i       AS INTEGER   NO-UNDO .
        DEFINE VARIABLE iLines  AS INTEGER   NO-UNDO .
        DEFINE VARIABLE cLine   AS CHARACTER NO-UNDO .

        ASSIGN iLines = NUM-ENTRIES (pcString, CHR (10)) .

        DO i = 1 TO iLines:
            
            ASSIGN cLine = ENTRY (i, pcString, CHR (10)) 
                    
                   cResult = cResult + 
                             FILL (" ":U, piIndent) + 
                             cLine + 
                             (IF i < iLines THEN CHR (10) ELSE "":U) .
        END.

        RETURN cResult.

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Indents a string by inserting a SPACE character at the beginning 
                 of every line
        Notes:   
        @param plcString The string to indent
        @param piIndent The number of characters to indent the string
        @return The indented string
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER Indent (plcString AS LONGCHAR,  
                                           piIndent AS INTEGER):
        
        DEFINE VARIABLE cResult AS CHARACTER NO-UNDO .
        DEFINE VARIABLE i       AS INTEGER   NO-UNDO .
        DEFINE VARIABLE iLines  AS INTEGER   NO-UNDO .
        DEFINE VARIABLE cLine   AS CHARACTER NO-UNDO .

        ASSIGN iLines = NUM-ENTRIES (plcString, CHR (10)) .

        DO i = 1 TO iLines:
            
            ASSIGN cLine = ENTRY (i, plcString, CHR (10)) 
                    
                   cResult = cResult + 
                             FILL (" ":U, piIndent) + 
                             cLine + 
                             (IF i < iLines THEN CHR (10) ELSE "":U) .
        END.

        RETURN cResult.

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Inserts a string into another string at a give position
        Notes:   
        @param pcSourceString The source string, into which you want to insert another string
        @param piPosition The position at which you want to insert the target string
        @param pcTargetString The target string, which will be inserted into the source string
        @return The Source String with the Target string inserted
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER Insert (pcSourceString AS CHARACTER, 
                                           piPosition AS INTEGER, 
                                           pcTargetString AS CHARACTER):
        
        DEFINE VARIABLE cResult AS CHARACTER NO-UNDO.

        IF piPosition > 1 THEN 
            cResult = SUBSTRING (pcSourceString, 1, piPosition - 1) .

        ASSIGN cResult = cResult + 
                         pcTargetString + 
                         SUBSTRING (pcSourceString, piPosition) .

        RETURN cResult . 

    END METHOD .
    
    /*------------------------------------------------------------------------------
        Purpose: Inserts a string into another string at a give position
        Notes:   
        @param pcSourceString The source string, into which you want to insert another string
        @param piPosition The position at which you want to insert the target string
        @param pcTargetString The target string, which will be inserted into the source string
        @return The Source String with the Target string inserted
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR Insert (pcSourceString AS LONGCHAR, 
                                          piPosition AS INTEGER, 
                                          pcTargetString AS CHARACTER):
        
        DEFINE VARIABLE cResult AS LONGCHAR NO-UNDO.

        IF piPosition > 1 THEN 
            cResult = SUBSTRING (pcSourceString, 1, piPosition - 1) .

        ASSIGN cResult = cResult + 
                         pcTargetString + 
                         SUBSTRING (pcSourceString, piPosition) .

        RETURN cResult . 

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns true when the given character is UPPERCASE 
        Notes:   
        @param pcCharacter The character to test
        @return True when the given character is UPPERCASE 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LOGICAL IsLowercaseCharacter (pcCharacter AS CHARACTER):
        
        DEFINE VARIABLE cCharacter AS CHARACTER NO-UNDO.
        
        IF LENGTH (pcCharacter) > 0 THEN . 
        ELSE  
            UNDO, THROW NEW AppError (SUBSTITUTE ("Invalid Character &1."{&TRAN}, pcCharacter), 0) .
        
        ASSIGN cCharacter = SUBSTRING (pcCharacter, 1, 1) .
        
        RETURN ASC (cCharacter) = ASC (LC (cCharacter)) . 

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns true when the given character is UPPERCASE 
        Notes:   
        @param pcCharacter The character to test
        @return True when the given character is UPPERCASE 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LOGICAL IsUppercaseCharacter (pcCharacter AS CHARACTER):
        
        DEFINE VARIABLE cCharacter AS CHARACTER NO-UNDO.
        
        IF LENGTH (pcCharacter) > 0 THEN . 
        ELSE  
            UNDO, THROW NEW AppError (SUBSTITUTE ("Invalid Character &1."{&TRAN}, pcCharacter), 0) .
        
        ASSIGN cCharacter = SUBSTRING (pcCharacter, 1, 1) .
        
        RETURN ASC (cCharacter) = ASC (UPPER (cCharacter)) . 

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Prefixes every line in the given LONGCHAR with a given CHARACTR
        Notes:   Useful for formatted log-file output  
        @param plcLongchar The source LONGCHAR value
        @param pcPrefix The prefix to add to each line from the source LONGCHAR
        @return The new LONGCHAR value
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR PrefixLines (plcLongchar AS LONGCHAR,
                                               pcPrefix AS CHARACTER):
        
        DEFINE VARIABLE cResult AS LONGCHAR  NO-UNDO .
        DEFINE VARIABLE i       AS INTEGER   NO-UNDO .
        DEFINE VARIABLE iLines  AS INTEGER   NO-UNDO .
        DEFINE VARIABLE cLine   AS CHARACTER NO-UNDO .

        IF IS-CODEPAGE-FIXED (plcLongchar) THEN 
            FIX-CODEPAGE (cResult) = GET-CODEPAGE (plcLongchar) . 

        ASSIGN plcLongchar = TRIM (TRIM(plcLongchar, CHR (13)), CHR(10)) . 

        ASSIGN iLines = NUM-ENTRIES (plcLongchar, CHR (10)) .

        DO i = 1 TO iLines:
            
            ASSIGN cLine = TRIM(ENTRY (i, plcLongchar, CHR (10)), CHR(13))  
                    
                   cResult = cResult + 
                             pcPrefix + 
                             cLine + 
                             Consultingwerk.Environment:NewLine .
        END.

        RETURN cResult .

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Returns an CharacterList of the Entries in a delimited String
        Notes:   This method is similar to the ABL ENTRY/NUM-ENTRIES functions, but 
                 does consider " or ' and ( ) when parsing the string
        @param pcString The delimited string
        @return The CharacterList with the entries from the source delimited string
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CharacterList QuoteAndBracketSafeEntriesToList (pcString AS CHARACTER):
        
        RETURN QuoteAndBracketSafeEntriesToList (pcString, ",":U).

    END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Returns an CharacterList of the Entries in a delimited String
        Notes:   This method is similar to the ABL ENTRY/NUM-ENTRIES functions, but 
                 does consider " or ' and ( ) when parsing the string
        @param pcString The delimited string
        @param pcDelimiter The string delimiter (single char)
        @return The CharacterList with the entries from the source delimited string
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CharacterList QuoteAndBracketSafeEntriesToList (pcString AS CHARACTER, 
                                                                         pcDelimiter AS CHARACTER):
        
        DEFINE VARIABLE oList  AS CharacterList NO-UNDO .
        DEFINE VARIABLE iPos   AS INTEGER       NO-UNDO .
        DEFINE VARIABLE iStart AS INTEGER       NO-UNDO INIT 1.
        DEFINE VARIABLE cChar  AS CHARACTER     NO-UNDO .
        DEFINE VARIABLE cPart  AS CHARACTER     NO-UNDO .
    
        IF LENGTH (pcDelimiter) <> 1 THEN 
            UNDO, THROW NEW AppError ("The delimiter must be exactly a single character."{&TRAN}, 0) . 
        
        oList = NEW CharacterList ("":U, CHR(1)) .

        DO iPos = 1 TO LENGTH (pcString):
        
            ASSIGN cChar = SUBSTRING (pcString, iPos, 1) .

            IF cChar = pcDelimiter THEN DO:
            
                ASSIGN cPart = SUBSTRING (pcString, iStart, iPos - iStart) . 
            
                IF cPart = "":U THEN cPart = " ":U . 
        
                oList:Add (cPart) .  
                iStart = iPos + 1 .               
                
                NEXT. 
            END.
            
            IF cChar = "'":U OR cChar = '"':U THEN 
                ASSIGN iPos = StringHelper:FindClosingQuote (pcString, iPos) .
             
            IF cChar = "(":U THEN 
                ASSIGN iPos = StringHelper:FindClosingBracket (pcString, iPos) .
        END. 

        oList:Add (SUBSTRING (pcString, iStart, iPos - iStart)) .

        RETURN oList.

    END METHOD.
    
    /*------------------------------------------------------------------------------
        Purpose: Returns an CharacterList of the Entries in a delimited String
        Notes:   This method is similar to the ABL ENTRY/NUM-ENTRIES functions, but 
                 does consider " or ' when parsing the string
        @param pcString The delimited string
        @return The CharacterList with the entries from the source delimited string
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CharacterList QuoteSafeEntriesToList (pcString AS CHARACTER):
        
        RETURN QuoteSafeEntriesToList (pcString, ",":U).

    END METHOD.

	/*------------------------------------------------------------------------------
	    Purpose: Returns an CharacterList of the Entries in a delimited String
	    Notes:   This method is similar to the ABL ENTRY/NUM-ENTRIES functions, but 
	             does consider " or ' when parsing the string
	    @param pcString The delimited string
	    @param pcDelimiter The string delimiter (single char)
	    @return The CharacterList with the entries from the source delimited string
	------------------------------------------------------------------------------*/
	METHOD PUBLIC STATIC CharacterList QuoteSafeEntriesToList (pcString AS CHARACTER, 
	                                                           pcDelimiter AS CHARACTER):
		
		DEFINE VARIABLE oList  AS CharacterList NO-UNDO .
        DEFINE VARIABLE iPos   AS INTEGER       NO-UNDO .
        DEFINE VARIABLE iStart AS INTEGER       NO-UNDO INIT 1.
        DEFINE VARIABLE cChar  AS CHARACTER     NO-UNDO .
        DEFINE VARIABLE cPart  AS CHARACTER     NO-UNDO .
    
        IF LENGTH (pcDelimiter) <> 1 THEN 
            UNDO, THROW NEW AppError ("The delimiter must be exactly a single character."{&TRAN}, 0) . 
        
        oList = NEW CharacterList ("":U, CHR(1)) .

        DO iPos = 1 TO LENGTH (pcString):
        
            ASSIGN cChar = SUBSTRING (pcString, iPos, 1) .

            IF cChar = pcDelimiter THEN DO:
            
                ASSIGN cPart = SUBSTRING (pcString, iStart, iPos - iStart) . 
            
                IF cPart = "":U THEN cPart = " ":U . 
        
                oList:Add (cPart) .  
                iStart = iPos + 1 .               
                
                NEXT. 
            END.
            
            IF cChar = "'":U OR cChar = '"':U THEN 
                ASSIGN iPos = StringHelper:FindClosingQuote (pcString, iPos) .
        END. 

        oList:Add (SUBSTRING (pcString, iStart, iPos - iStart)) .

		RETURN oList.

	END METHOD.

    /*------------------------------------------------------------------------------
        Purpose: Removes the given prefix at the beginning of the passed in String  
        Notes:   When the String does not begin with the prefix, the original string
                 is returned
        @param pcSourceString The source string to remove the prefix from
        @param pcPrefixString The prefix to remove from the source string
        @return The resulting strging without the prefix
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER RemovePrefix (pcSourceString AS CHARACTER,
                                                 pcPrefixString AS CHARACTER):
        
        IF pcSourceString BEGINS pcPrefixString THEN 
            RETURN SUBSTRING (pcSourceString, LENGTH (pcPrefixString) + 1) .
        
        RETURN pcSourceString . 

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Removes the given suffix at the beginning of the passed in String  
        Notes:   When the String does not begin with the suffix, the original string
                 is returned
        @param pcSourceString The source string to remove the suffix from
        @param pcSuffixString The suffix to remove from the source string
        @return The resulting strging without the suffix
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER RemoveSuffix (pcSourceString AS CHARACTER,
                                                 pcSuffixString AS CHARACTER):
        
        IF StringHelper:Ends (pcSourceString, pcSuffixString) THEN 
            RETURN SUBSTRING (pcSourceString, 1, LENGTH (pcSourceString) - LENGTH (pcSuffixString)) .
        
        RETURN pcSourceString .
    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Removes quotes from a Character String
        Notes:   
        @param pcString The source string to remove quotes
        @return The string without the quotes
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER Unquote (pcString AS CHARACTER):
        
        DEFINE VARIABLE iIndex     AS INTEGER   NO-UNDO .
        DEFINE VARIABLE cQuoteChar AS CHARACTER NO-UNDO .
        
        IF pcString = ? THEN 
            RETURN ? .
        
        ASSIGN pcString = TRIM (pcString) .
            
        IF LENGTH (pcString) < 2 THEN 
            RETURN pcString .
        
        ASSIGN cQuoteChar = SUBSTRING (pcString, 1, 1) .
        
        IF cQuoteChar <> "'":U AND cQuoteChar <> "~"":U THEN 
            RETURN pcString . 
        
        ASSIGN iIndex = R-INDEX (pcString, cQuoteChar) .
        
        IF iIndex > 1 THEN 
            RETURN SUBSTRING (pcString, 2, iIndex - 2) .    
            
        UNDO, THROW NEW AppError ("Unmatched QUOTE Character found in source string."{&TRAN}, 0) .

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Removes quotes from a Longchar String
        Notes:   
        @param pcString The source string to remove quotes
        @return The string without the quotes
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC LONGCHAR Unquote (pcString AS LONGCHAR):
        
        DEFINE VARIABLE iIndex     AS INTEGER   NO-UNDO .
        DEFINE VARIABLE cQuoteChar AS CHARACTER NO-UNDO .
        
        IF pcString = ? THEN 
            RETURN ? .
        
        ASSIGN pcString = TRIM (pcString) .
            
        IF LENGTH (pcString) < 2 THEN 
            RETURN pcString .
        
        ASSIGN cQuoteChar = SUBSTRING (pcString, 1, 1) .
        
        IF cQuoteChar <> "'":U AND cQuoteChar <> "~"":U THEN 
            RETURN pcString . 
        
        ASSIGN iIndex = R-INDEX (pcString, cQuoteChar) .
        
        IF iIndex > 1 THEN 
            RETURN SUBSTRING (pcString, 2, iIndex - 2) .    
            
        UNDO, THROW NEW AppError ("Unmatched QUOTE Character found in source string."{&TRAN}, 0) .

    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Encodes unsafe characters in a URL as per RFC 1738 section 2.2. 
                 http://ds.internic.net/rfc/rfc1738.txt 
        Notes:   See Progress K-Base 000042261, http://knowledgebase.progress.com/articles/Article/000042261
        @param pcValue Character string to encode
        @param pcEnctype Encoding option where "query", "cookie", "default" or any specified string of characters are valid
        @return Encoded string (unkown value is returned as blank) 
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER UrlEncode (pcValue AS CHARACTER,
                                              pcEnctype AS CHARACTER):
        
        DEFINE VARIABLE cHex        AS CHARACTER   NO-UNDO INITIAL "0123456789ABCDEF":U. 
        DEFINE VARIABLE cEncodeList AS CHARACTER   NO-UNDO INITIAL "query":U.
         
        DEFINE VARIABLE iCounter    AS INTEGER     NO-UNDO. 
        DEFINE VARIABLE cChar       AS INTEGER     NO-UNDO. 
         
        /* Unsafe characters that must be encoded in URL's.  See RFC 1738 Sect 2.2. */
        DEFINE VARIABLE cUnsafe   AS CHARACTER NO-UNDO 
               INITIAL " <>~"#%~{}|~\^~~[]`":U.
         
        /* Reserved characters that normally are not encoded in URL's */
        DEFINE VARIABLE cReserved AS CHARACTER NO-UNDO 
               INITIAL "~;/?:@=&":U.
         
        /* Don't bother with blank or unknown */ 
        IF LENGTH(pcValue) = 0 OR pcValue = ? THEN 
            RETURN "":U. 
         
        /* What kind of encoding should be used? */ 
        CASE pcEnctype: 
            WHEN "query":U THEN /* QUERY_STRING name=value parts */ 
                cEncodeList = cUnsafe + cReserved + "+":U. 
            WHEN "cookie":U THEN /* Persistent Cookies */ 
                cEncodeList = cUnsafe + " ,~;":U. 
            WHEN "default":U OR WHEN "":U THEN /* Standard URL encoding */ 
                cEncodeList = cUnsafe. 
            OTHERWISE 
                cEncodeList = cUnsafe + pcEnctype. /* user specified ... */ 
        END CASE. 
         
        /* Loop through entire input string */ 
        iCounter = 0. 
        DO WHILE TRUE: 
            ASSIGN iCounter = iCounter + 1 
                   /* ASCII value of character using single byte codepage */ 
                   cChar = ASC(SUBSTRING(pcValue, iCounter, 1, "RAW":U), 
                               "1252":U, 
                               "1252":U). 
            IF cChar LE 31  OR 
               cChar GE 127 OR 
               INDEX(cEncodeList, CHR(cChar)) GT 0 THEN DO: 
                   /* Replace character with %hh hexidecimal triplet */ 
                   SUBSTRING(pcValue, iCounter, 1, "RAW":U) = "%":U + 
                      SUBSTRING(cHex, INTEGER(TRUNCATE(cChar / 16, 0)) + 1, 1, "RAW":U) + /* high */ 
                      SUBSTRING(cHex, cChar MODULO 16 + 1, 1, "RAW":U). /* low digit */ 
          
                   iCounter = iCounter + 2. /* skip over hex triplet just inserted */ 
            END. 
            IF iCounter EQ LENGTH(pcValue,"RAW":U) THEN LEAVE. 
        END. 

        RETURN pcValue . 
    END METHOD .

    /*------------------------------------------------------------------------------
        Purpose: Turns a CamelCased string into a well formed sentence (Camel Cased) 
        Notes:   
        @param pcSource The source String
        @return The well formed string
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC STATIC CHARACTER WellFormFromCamelCase (pcSource AS CHARACTER):
        
        DEFINE VARIABLE cResult AS CHARACTER NO-UNDO .
        DEFINE VARIABLE i       AS INTEGER   NO-UNDO .
        
        ASSIGN cResult = SUBSTRING (pcSource, 1, 1) .
        
        DO i = 2 TO LENGTH (pcSource):
            
             IF SUBSTRING (pcSource, i, 1) <> " ":U AND 
                SUBSTRING (pcSource, i - 1, 1) <> " ":U AND
                IsUppercaseCharacter (SUBSTRING (pcSource, i, 1)) AND 
                IsLowercaseCharacter (SUBSTRING (pcSource, i - 1, 1)) THEN 
                  
                 cResult = cResult + " ":U . 
        
             ASSIGN cResult = cResult + SUBSTRING (pcSource, i, 1) .
        END .

        RETURN cResult .

    END METHOD .

END CLASS.
