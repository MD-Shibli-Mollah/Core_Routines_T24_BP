* @ValidationCode : MjoyMTQ2MzQyMzcxOkNwMTI1MjoxNTMxODI1ODE5Mzk1OmtoYXJpbmk6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTgwNi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 17 Jul 2018 16:40:19
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kharini
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201806.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>219</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CE.CrsReporting
SUBROUTINE CRS.GET.TAG.VALUE(TDY.Xml,TDY.Tag,TDY.TagValue)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
* 17/07/2018 - Enhancement 2644065 / Task 2644112
*              New routine to form the Xml tags for Merging the XML records.
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
*-----------------------------------------------------------------------------
    
    GOSUB INIT
    GOSUB PARSE.XML

RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
    STR.TagValue = ""
    NBR.FldPos   = ""
    TDY.XmlTmp   = TDY.Xml

RETURN
*-----------------------------------------------------------------------------
PARSE.XML:
*-----------------------------------------------------------------------------

    STR.ParentTag  = TDY.Tag<1>
    TDY.ChildTag = TDY.Tag<2>
    
    GOSUB GET.VALUE
    TDY.TagValue   = STR.TagValue

RETURN
*-----------------------------------------------------------------------------
GET.VALUE:
*-----------------------------------------------------------------------------
    STR.TagValue = ""

    CONVERT '<' TO '' IN STR.ParentTag
    CONVERT '>' TO '' IN STR.ParentTag
    
    STR.TagStart  = "<":STR.ParentTag:">"
    STR.TagStart1 = "<":STR.ParentTag:" "
    STR.TagEnd   = "</":STR.ParentTag:">"
    NBR.ParentStPos = INDEX(TDY.XmlTmp,STR.TagStart,1)

    IF NOT(NBR.ParentStPos) THEN
        NBR.ParentStPos = INDEX(TDY.XmlTmp,STR.TagStart1,1)
    END

    IF NBR.ParentStPos THEN
        TDY.XmlTmp = TDY.XmlTmp[NBR.ParentStPos,LEN(TDY.XmlTmp)]
        NBR.ParentEndPos = INDEX(TDY.XmlTmp,STR.TagEnd,1)
        TDY.XmlTmp = TDY.XmlTmp[1,NBR.ParentEndPos-1]
        IF TDY.ChildTag THEN
            LOOP
                REMOVE STR.ChildTag FROM TDY.ChildTag SETTING NBR.ChildTagPos
            WHILE STR.ChildTag:NBR.ChildTagPos
                NBR.MsgLen = 0
                CONVERT '<' TO '' IN STR.ChildTag
                CONVERT '>' TO '' IN STR.ChildTag
                STR.TagStart = "<":STR.ChildTag:">"
                STR.TagStart1= "<":STR.ChildTag:" "
                STR.TagEnd   = "</":STR.ChildTag:">"
                STR.TagEnd1   = "/>"
                NBR.ChildStPos = INDEX(TDY.XmlTmp,STR.TagStart,1)
                IF NOT(NBR.ChildStPos) THEN
                    NBR.ChildStPos = INDEX(TDY.XmlTmp,STR.TagStart1,1)
                    IF NOT(NBR.ChildStPos) THEN
                        TDY.XmlTmp = ''
                        BREAK
                    END
                END

                TDY.XmlTmp = TDY.XmlTmp[NBR.ChildStPos,LEN(TDY.XmlTmp)]
                NBR.ChildEndPos = INDEX(TDY.XmlTmp,STR.TagEnd,1)
                IF NOT(NBR.ChildEndPos) THEN
                    NBR.ChildEndPos = INDEX(TDY.XmlTmp,STR.TagEnd1,1)
                    NBR.MsgLen = LEN(STR.TagEnd1)
                    IF NOT(NBR.ChildEndPos) THEN
                        TDY.XmlTmp = ''
                        BREAK
                    END
                END ELSE
                    NBR.MsgLen = LEN(STR.TagEnd)
                END
                TDY.XmlTmp = TDY.XmlTmp[1,NBR.ChildEndPos-1+NBR.MsgLen]
            REPEAT
        END
    END

    STR.TagValue = TDY.XmlTmp
 
RETURN
*-----------------------------------------------------------------------------
END
*-----------------------------------------------------------------------------
