* @ValidationCode : MjotMTMzNDcwMDIxOmNwMTI1MjoxNDg3MzI3MDA0MDk0OmluZGh1bWF0aHlzOjI6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxNzAxLjA6Mjk6Mjk=
* @ValidationInfo : Timestamp         : 17 Feb 2017 15:53:24
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : indhumathys
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 29/29 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201701.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-40</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CM.Contract
    SUBROUTINE DE.UPD.CM.HOLDING.QUEUE(HEADER.ID, HEADER.REC, UPD.ERR)
*-----------------------------------------------------------------------------
*
* Routine to check for the transaction reference of DE.O.HEADER. If
* CONF.BY.CUST or CONF.BY.CPARTY has been defined as One-sided in MM or FX
* repesctively, CM.HOLDING.QUEUE should not be writeen.
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------
* 15/02/17 - Defect 2004246 / Task 2021101
*            Hook routine to check for the fields CONF.BY.CUST or CONF.BY.CPARTY
*            is set to ONESIDED in MM or FX respectively and update the error accordingly.
*-----------------------------------------------------------------------------

    $USING DE.Config
    $USING MM.Contract
    $USING FX.Contract

*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN

*-----------------------------------------------------------------------------

INITIALISE:


    RETURN

*-----------------------------------------------------------------------------

PROCESS:

* Get the transaction reference from the DE.O.HEADER record passed and read
* the correcsponding MM or FX record.

* If CONF.BY.CUST of MM record or CONF.BY.CPARTY field of FX record is set to
* ONESIDED, then error variable is set to '1' preventing messages writing to
* CM.HOLDING.QUEUE

    TRANS.REF = HEADER.REC<DE.Config.OHeader.HdrTransRef>

    BEGIN CASE

        CASE TRANS.REF[1,2] EQ 'MM'
            GOSUB READ.MM

        CASE TRANS.REF[1,2] EQ 'FX'
            GOSUB READ.FX

    END CASE

    IF REQ.FIELD EQ 'ONESIDED' THEN
        UPD.ERR = '1'
    END


    RETURN

*-----------------------------------------------------------------------------

READ.MM:

* Read MM record and get the value of the field CONF.BY.CUST

    MM.REC = ''
    MM.ERR = ''

    MM.REC = MM.Contract.MoneyMarket.Read(TRANS.REF, MM.ERR)
    IF NOT(MM.ERR) THEN
        REQ.FIELD = MM.REC<MM.Contract.MoneyMarket.ConfByCust>
    END


    RETURN

*-----------------------------------------------------------------------------

READ.FX:

* Read FX record and get the value of the field CONF.BY.CPARTY

    FX.REC = ''
    FX.ERR = ''

    FX.REC = FX.Contract.Forex.Read(TRANS.REF, FX.ERR)
    IF NOT(FX.ERR) THEN
        REQ.FIELD = FX.REC<FX.Contract.Forex.ConfByCparty>
    END

    RETURN

*-----------------------------------------------------------------------------


    END
