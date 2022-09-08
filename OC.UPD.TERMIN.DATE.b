* @ValidationCode : MjotMTcxOTM2NTA3NzpjcDEyNTI6MTQ4NzA3NzgwMjgwMjpoYXJyc2hlZXR0Z3I6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxNjEyLjIwMTYxMTAyLTExNDI6LTE6LTE=
* @ValidationInfo : Timestamp         : 14 Feb 2017 18:40:02
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : harrsheettgr
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201612.20161102-1142
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-25</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.TERMIN.DATE(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
* The routine will be attached as a link routine in TX.TXN.BASE.MAPPING record.
* FOREX- Conditionally populated when the action type is changed to C ( cancelled)
* This is applicable only when there are multiple deliveries under FWSR or FWMR
* contracts where the entire amount is delivered before the maturity date.
* The last delivery should change the action type to C and at that point of time of
* this field should be updated with last multi value of Delivery date.
*-----------------------------------------------------------------------------
* Modification History :
*
* 12/12/16 - Enhancement 1764033 / Task 1829190
*            Bring sample EMIR mappings into Dev
*
*-----------------------------------------------------------------------------
*******************************************************************
*
*
* Incoming parameters:
*
* APPL.ID   - Id of transaction
* APPL.REC  - A dynamic array holding the contract.
* FIELD.POS - Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
* Ret.val- Variable holding the value of TERMINATION Date.
*
*
*******************************************************************

    $USING FX.Contract

*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB DETERMINE.FOR.T24.BANK

    RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>INITIALISE </desc>

    RET.VAL=''

    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS>
DETERMINE.FOR.T24.BANK:
*** <desc>PROCESS </desc>

* FOREX - last multi value of delivery date is returned when Action Type is 'C'
    BEGIN CASE
        CASE APPL.ID[1,2] EQ 'FX'
            IF APPL.REC<FX.Contract.Forex.ActionType> EQ 'C' THEN
                CNT = DCOUNT(APPL.REC<FX.Contract.Forex.DelDateBuy>,@VM)
                IF CNT GE 1 THEN
                    DEL.DATE.BUY = APPL.REC<FX.Contract.Forex.DelDateBuy,CNT>
                    RET.VAL = DEL.DATE.BUY
                END
            END
    END CASE

    RETURN
*** </region>

*-----------------------------------------------------------------------------
    END
