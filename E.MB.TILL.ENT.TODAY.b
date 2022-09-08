* @ValidationCode : MjoxNTA5NDEwMDg0OkNwMTI1MjoxNTg5ODc0MzI0MDgwOmJzYXVyYXZrdW1hcjoyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA1LjIwMjAwNTA1LTA0MjY6MzU6MzU=
* @ValidationInfo : Timestamp         : 19 May 2020 13:15:24
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bsauravkumar
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 35/35 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202005.20200505-0426
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-44</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE E.MB.TILL.ENT.TODAY(ENQ.DATA)
*-----------------------------------------------------------------------------
* This is a build routine Used to check whether it is a Multi book OR Multi
* company transaction, forms the internal a/c number as ccy:category:ac.id and
* returns to the enquiry. Also check if it.s a multi company and if so then
* appends the compay mnemonic to the internal a/c id.
*-----------------------------------------------------------------------------
* Modification HIstory
* 21/10/80 - BG_100019949
*            Routine Standardisation
*
* 12/10/11 - EN 99120 Task 156274
*            Improve Statement enquiries - II
*
* 19/12/11 - Defect 325226 / Task 326360
*            Changes reverted as the enquiries are no longer used.
*
* 04/05/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 19/05/20 - Defect 3745048 / Task 3754104
*            Enquiry TILL.ENT.TODAY does not work when currency is given while
*            it works when currency is not provided
*----------------------------------------------------------------------------


    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING AC.ModelBank

    GOSUB INITIALISE
    GOSUB GET.ENQ.VALUES
    GOSUB PROCESS

RETURN

***********
INITIALISE:
***********

    REQ.CATEGORY  = ''
    ACCOUNT.NO = ''
    CURRENCY = ''
    ENQ.NAME = ENQ.DATA<1>

    FN.TILL.PARAM = 'F.TT.MB.ENQ.TILL.ENTRY.PARAM'
    F.TILL.PARAM = ''
    EB.DataAccess.Opf(FN.TILL.PARAM,F.TILL.PARAM)

RETURN

***************
GET.ENQ.VALUES:
***************

    TILL.PARAM.ID = 'SYSTEM'
    EB.DataAccess.FRead(FN.TILL.PARAM,TILL.PARAM.ID,R.TILL.PARAM,F.TILL.PARAM,TILL.PARAM.ERR)

    REQ.CATEGORY = R.TILL.PARAM<AC.ModelBank.TtMb43CashCategory>

    LOCATE "ACCOUNT.NO" IN ENQ.DATA<2,1> SETTING AC.POS THEN
        REQ.AC.ID = ENQ.DATA<4,AC.POS>
    END

    LOCATE "CURRENCY" IN ENQ.DATA<2,1> SETTING CCY.POS THEN
        REQ.CCY = TRIM(ENQ.DATA<4,CCY.POS>, '...', 'B') ;* Use TRIM and removed leading and trailing ... as it comes from UXP browser when contains is used
    END ELSE
        REQ.CCY = EB.SystemTables.getLccy()
    END

    REQ.COMP = EB.SystemTables.getIdCompany()[6,4]

RETURN

********
PROCESS:
********

* verify whether this is Multi company or a Multi Book

    MULTI.BOOK.FLAG = ''
    MULTI.BOOK.FLAG = EB.SystemTables.getCMultiBook()

    IF MULTI.BOOK.FLAG THEN
        REQ.AC.NO = REQ.CCY:REQ.CATEGORY:REQ.AC.ID:REQ.COMP
        ENQ.DATA<4,AC.POS> = REQ.AC.NO
    END ELSE
        REQ.AC.NO = REQ.CCY:REQ.CATEGORY:REQ.AC.ID
        ENQ.DATA<4,AC.POS> = REQ.AC.NO
    END

RETURN
END
