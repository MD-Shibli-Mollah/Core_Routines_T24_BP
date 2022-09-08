* @ValidationCode : MjotMjU2MTg5MjczOkNwMTI1MjoxNTM3NTI4MzU5MTA1OnN2YW1zaWtyaXNobmE6MjowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE4MDkuMjAxODA4MjEtMDIyNDoyMToxMg==
* @ValidationInfo : Timestamp         : 21 Sep 2018 16:42:39
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : svamsikrishna
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 12/21 (57.1%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201809.20180821-0224
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-2</Rating>
*-----------------------------------------------------------------------------
$PACKAGE ST.Customer
SUBROUTINE OC.CUSTOMER.CHECK(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)

******************************************************************
* Modification History:
*
*
* 18/03/15 - EN 1047936 / Task 1252419
*            FX - Mapping & COB scheduling
*
* 06/04/15 - EN 1177301 / Task 1284514
*            FRA - Mapping & COB scheduling
*
* 22/04/15 - EN 1177300 / Task 1320631
*            NDF - Mapping & COB scheduling
*
* 05/08/15 - Enhancement 1179782 / Task 1179788
*            Swap clearing phase 1 - Template changes  - DX
*
* 30/12/15 - EN_1226121 / Task 1568411
*            Incorporation of the routine
*
* 15/02/16 - EN 1573781 / Task 1630758
*            OC Valid Unit Test Failures
*
* 21/09/18 - En 2773096 / Task 2773151
*            Routine is moved from OC to ST as the table will be used for LEI validations
*
******************************************************************


*The purpose of the routine is to check whether the counterparty of deal is a valid OC.CUSTOMER.If not,return parameter will be set to 0.
*OC.TRADE.DATA will get updated only when the DEAL Counterparty is a valid OC.CUSTOMER.


*Incoming parameters:

*Appl.id - Id of application linked to tax engine.
*Appl.rec - Application record.
*Field.pos-Decision field name

*Outcoming parameters

* Ret.val - Return value

******************************************************************



    $USING EB.SystemTables
    $USING EB.API
    $USING FX.Contract
    $USING FR.Contract
    $USING SW.Contract
    $USING DX.Trade
    $USING OC.Parameters
    $USING EB.DataAccess

    PRI.CUS.NO = ''

    BEGIN CASE
        CASE APPL.ID[1,2] = 'FX'
            COUNTERPARTY = APPL.REC<FX.Contract.Forex.Counterparty>;*get deal counterparty
        CASE APPL.ID[1,2] = 'FR'
            COUNTERPARTY = APPL.REC<FR.Contract.FraDeal.FrdCounterparty>
        CASE APPL.ID[1,2] = 'ND'
            COUNTERPARTY = APPL.REC<FX.Contract.NdDeal.NdDealCounterparty>
        CASE APPL.ID[1,2] = 'SW'
            COUNTERPARTY = APPL.REC<SW.Contract.Swap.Customer>
        CASE APPL.ID[1,2] = 'DX'
            PRI.CUS.NO   = APPL.REC<DX.Trade.Trade.TraPriCustNo>
            COUNTERPARTY = PRI.CUS.NO<1,1>

    END CASE

    R.OC.CUSTOMER = ST.Customer.OcCustomer.Read(COUNTERPARTY, READ.ERR);*read oc.customer record
* Before incorporation : CALL F.READ('F.OC.CUSTOMER',COUNTERPARTY,R.OC.CUSTOMER,F.OC.CUSTOMER,READ.ERR);*read oc.customer record

    IF NOT(READ.ERR) THEN
        RET.VAL = 1
    END ELSE
        RET.VAL=0
    END

RETURN
