* @ValidationCode : MjotMTAyNTcyODQ3OTpjcDEyNTI6MTQ4NzA3ODQ5OTUwNjpoYXJyc2hlZXR0Z3I6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxNjEyLjIwMTYxMTAyLTExNDI6LTE6LTE=
* @ValidationInfo : Timestamp         : 14 Feb 2017 18:51:39
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
* <Rating>-23</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.CLEARED(APPL.ID, APPL.REC, FIELD.POS, RET.VAL)
*-----------------------------------------------------------------------------
* The routine will be attached as a link routine in TX.TXN.BASE.MAPPING record.
* It returns a value of "N"  for Forex contract.
* SWAP - Return is based on the value of Field OC.CLG.STATUS
*-----------------------------------------------------------------------------
* Modification History :
**
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
* Ret.val- Variable holding the value of CLEARED field.
*
*
*******************************************************************
    $USING SW.Contract
    $USING FX.Contract

*-----------------------------------------------------------------------------
    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN
*-----------------------------------------------------------------------------
INITIALISE:

    RET.VAL = ''

    RETURN
*-----------------------------------------------------------------------------
PROCESS:

    BEGIN CASE

            * Returns 'N' for Forex contracts
        CASE APPL.ID[1,2] EQ 'FX'
            RET.VAL = "N"

            * For SW, if the OC.CLG.STATUS is cleared then Y else N
        CASE APPL.ID[1,2] = 'SW'


            OC.CLG.STATUS = APPL.REC<SW.Contract.Swap.OcClgStatus>

            IF OC.CLG.STATUS EQ "CLEARED" THEN
                RET.VAL="Y"
            END ELSE
                RET.VAL="N"
            END

            * For ndf, if the OC.CLG.STATUS is cleared then Y else N
        CASE APPL.ID[1,2] = 'ND'


            OC.CLG.STATUS = APPL.REC<FX.Contract.NdDeal.NdDealOcClgStatus>
            IF OC.CLG.STATUS EQ "CLEARED" THEN
                RET.VAL="Y"
            END ELSE
                RET.VAL="N"
            END


    END CASE

    RETURN
*-----------------------------------------------------------------------------
    END
