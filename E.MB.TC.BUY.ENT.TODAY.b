* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-41</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.MB.TC.BUY.ENT.TODAY(ENQ.DATA)
*-----------------------------------------------------------------------------
* This routine is used to check which enquiry is launched accordingly the
* selection criteria is modified.
* Used to check whether it is a Multi book OR Multi company transaction.
* Sets the category according to the enquiry launched and forms the internal
* a/c number as ccy:category:ac.id and returns to the enquiry. Also check if
* it's a multi company and if so then appends the compay mnemonic to the incternal a/c id
*-----------------------------------------------------------------------------
* Modification HIstory
* 21/10/80 - BG_100019949
*            Routine Standardisation
*
* 04/05/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
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

    REQ.CATEGORY = R.TILL.PARAM<AC.ModelBank.TtMb43TcBuyCategory>

    LOCATE "ACCOUNT.NO" IN ENQ.DATA<2,1> SETTING AC.POS THEN
    REQ.AC.ID = ENQ.DATA<4,AC.POS>
    END

    LOCATE "CURRENCY" IN ENQ.DATA<2,1> SETTING CCY.POS THEN
    REQ.CCY = ENQ.DATA<4,CCY.POS>
    ENQ.DATA<2,CCY.POS> = ''
    ENQ.DATA<3,CCY.POS> = ''
    ENQ.DATA<4,CCY.POS> = ''
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
