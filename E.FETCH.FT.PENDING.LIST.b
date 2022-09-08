* @ValidationCode : MjotMjA5ODA0NjMzNDpDcDEyNTI6MTQ5ODEyODg3MTg3NzphcmNoYW5hcmFnaGF2aTotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxNzA0LjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 22 Jun 2017 16:24:31
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : archanaraghavi
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201704.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-48</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ST.ModelBank

    SUBROUTINE E.FETCH.FT.PENDING.LIST(ENQ.DATA)
*-----------------------------------------------------------------------------
*
* Subroutine Type : BUILD Routine
* Attached to     : STO.LIST.PENDING.FTS
* Attached as     : Build Routine
* Primary Purpose : We need a way of retrieving all the pending FT for the
*                   given STO id.
* Incoming:
* ---------
*      ENQ.DATA
* Outgoing:
* ---------
*      ENQ.DATA
*************************************************************************
* Modification Log:
* =================

* 02/07/14 - Enhancement 959497 / Task 1047115
*             We need a way of retrieving all the pending FT for the given STO id
*             but the INWARD.PAY.TYPE field contains the STO-STOTYPE-CUSTOMER-REFNO ,
*             hence this routine reads the STO read from the given STO ID and forms the INWARD.PAY.TYPE  .
*
* 23/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 02/05/17 - Enhancement 1765879 / Task 2106068
*            Routine is not processed if AC product is not installed in the current company
*
*-----------------------------------------------------------------------------
    $USING AC.StandingOrders
    $USING EB.API
    $USING EB.Reports

    acInstalled = ''
    EB.API.ProductIsInCompany('AC', acInstalled)

    IF NOT(acInstalled) THEN
        EB.Reports.setEnqError('EB-PRODUCT.NOT.INSTALLED':@FM:"AC")
        RETURN
    END

    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB PROCESS

    RETURN          ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:
* Form the INWARD.PAY.TYPE of the FT record from the given STO id.

    LOCATE 'INWARD.PAY.TYPE' IN ENQ.DATA<2,1> SETTING STO.POS THEN
    Y.STO.ID = ENQ.DATA<4,STO.POS>
    Y.CUS.ID = FIELD(Y.STO.ID,'.',1,1)
    Y.REF = FIELD(Y.STO.ID,'.',2,1)
    R.STO = AC.StandingOrders.tableStandingOrder(Y.STO.ID,ERR)
    IF NOT(ERR) THEN
        Y.TYPE = R.STO<AC.StandingOrders.StandingOrder.StoType>
        ENQ.DATA<2,STO.POS> = 'INWARD.PAY.TYPE'
        ENQ.DATA<3,STO.POS> = 'EQ'
        ENQ.DATA<4,STO.POS> = 'STO':'-':Y.TYPE:'-':Y.CUS.ID:'-':Y.REF ;* Form the INWARD.PAY.TYPE from the inputted
        *STO ID as STO-STO.TYPE-CUSTNO-REFNO
    END
    END
    RETURN
*-----------------------------------------------------------------------------------
OPEN.FILES:

* Open the STO file.

    RETURN

*-----------------------------------------------------------------------------------
INITIALISE:

* INITIALISE the variables

    Y.STO.ID = ''

    RETURN
*-----------------------------------------------------------------------------------
    END
