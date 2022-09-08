* @ValidationCode : MjozODU2MjQ0ODQ6Q3AxMjUyOjE1ODEwNzY5MDUyNTE6YnNhdXJhdmt1bWFyOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDIuMjAyMDAxMTctMjAyNjo1NTo0Ng==
* @ValidationInfo : Timestamp         : 07 Feb 2020 17:31:45
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bsauravkumar
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 46/55 (83.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>223</Rating>
*-----------------------------------------------------------------------------
$PACKAGE LI.ModelBank

SUBROUTINE E.LIM.CUST.NO
*-------------------------------------------------
*
* This subroutine will be used to obtain a list
* of customer numbers that apply to the limit
* key passed.
*
* The fields used are as follows:-
*
* INPUT   ID              Id of the LIMIT.DAILY.OS record
*                         being processed.
*
*         R.RECORD        LIMIT.DAILY.OS record.
*
*         VC              Pointer to the current
*                         multi-value set being
*                         processed.
*
*         S               Pointer to the current
*                         sub-value set being
*                         processed.
*         O.DATA          Initially set to the ID of the line
*
*
* OUTOUT O.DATA           List of customer numbers to be passed
*                         to the  next enquiry .
*
*-----------------------------------------------------------------------------
* Modification History:
* ---------------------
*
* 21/08/17 - EN 2205157 / Task 2234593
*            use API instead of direct I/O for LIMIT related files
*            LIMIT.LINES
*
* 07/02/20 - Enhancement 3498204 / Task 3498206
*            Support for new limits for FX
*-------------------------------------------------Insert statements
    $USING LI.Config
    $USING EB.Reports

*----------------------------------------------------Check if customer number in key
    YLKEY = EB.Reports.getId()
    EB.Reports.setOData("")
    LIMIT.ID.COMPONENTS = ""
    LIMIT.ID.COMPOSED = ""
    RET.ERR = ""
    LI.Config.LimitIdProcess(YLKEY, LIMIT.ID.COMPONENTS, LIMIT.ID.COMPOSED, "", RET.ERR)
    YLCUST = LIMIT.ID.COMPONENTS<4>
    IF YLCUST <> "" THEN
        EB.Reports.setOData(YLCUST)
    END ELSE
*----------------------------------------------------Initialise variables
        YLLIAB = LIMIT.ID.COMPONENTS<1>
        YLREF = LIMIT.ID.COMPONENTS<2>
        YLSER = LIMIT.ID.COMPONENTS<3>
        IF YLKEY[1,2] EQ "LI" THEN
            EB.Reports.setOData(YLLIAB)
            GOTO PROG.EXIT
        END
        YLMATCH = FIELD(YLKEY,".",1,3)
        YLWORK = YLREF * 1
        IF LEN(YLWORK) > 4 THEN
            YLREF = YLREF[1,3]:"0000"
        END ELSE
            YLREF = YLREF[1,5]:"00"
        END
*-----------------------------------------------------Get limit line record
        YKEY = YLLIAB:".":YLREF:".":YLSER
        YREC = ""
        YERR = ""
        LI.Config.LimitLinesRead(YKEY, YREC, YERR)
        IF YERR <> "" THEN
            EB.Reports.setOData(YLLIAB)
            GOTO PROG.EXIT
        END
*----------------------------------------Find customer numbers
        YLCOUNT = COUNT(YREC,@FM) + 1
        O.DATA.VALUE = ''
        FOR YLOOP = 1 TO YLCOUNT
            YLLINE3 = FIELD(YREC<YLOOP>,".",1,3)
            IF YLLINE3 = YLMATCH THEN
                YLLINCUST = FIELD(YREC<YLOOP>,".",4)
                IF O.DATA.VALUE = "" THEN
                    O.DATA.VALUE = YLLINCUST
                END ELSE
                    O.DATA.VALUE := " ":YLLINCUST
                END
            END ELSE
                IF YLLINE3 > YLMATCH THEN
                    YLOOP = YLCOUNT
                END
            END
        NEXT YLOOP
        IF O.DATA.VALUE = "" THEN
            O.DATA.VALUE = YLLIAB
        END
        EB.Reports.setOData(O.DATA.VALUE)
    END
PROG.EXIT:
RETURN
END
