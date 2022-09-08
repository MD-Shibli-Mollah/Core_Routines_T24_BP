* @ValidationCode : MjotMTgwNTcyNDg3ODpDcDEyNTI6MTQ4Nzg0NjM4MDg3MjpoYXJyc2hlZXR0Z3I6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTcwMi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 23 Feb 2017 16:09:40
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : harrsheettgr
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-27</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.CLEARING.OBLIGATION(APPL.ID, APPL.REC, FIELD.POS, RET.VAL)
*-----------------------------------------------------------------------------
* The routine will be attached as a link routine in TX.TXN.BASE.MAPPING record.
* It returns a value of "X" for Forex contract.
* For Swap Contracts  returns Y if NON.STND.FLAG is Yes else N
*-----------------------------------------------------------------------------
* Modification History :
**
* 12/12/16 - Enhancement 1764033 / Task 1829190
*            Bring sample EMIR mappings into Dev
*
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
* Ret.val- Variable holding the value of CLEARING.OBLIGATION field.
*
*******************************************************************
    $USING SW.Contract
    $USING FX.Contract

*-----------------------------------------------------------------------------


    GOSUB INITIALIZE
    GOSUB PROCESS

    RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALIZE>
INITIALIZE:

    RET.VAL = ''

    RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:

    BEGIN CASE

            * Returns 'X' for Forex contract.
        CASE APPL.ID[1,2] = 'FX'

            RET.VAL = "X"

            * Returns Y if NON.STND.FLAG is Yes else N
        CASE APPL.ID[1,2] = 'SW'

            NON.STND.FLAG = APPL.REC<SW.Contract.Swap.NonStndFlag>;*fetching the field value

            IF NON.STND.FLAG EQ "Y" THEN;*if the field contains a value
                RET.VAL="N"
            END ELSE
                RET.VAL="Y"
            END

            * Returns Y if NON.STND.FLAG is Yes else N
        CASE APPL.ID[1,2] = 'ND'

            NON.STND.FLAG = APPL.REC<FX.Contract.NdDeal.NdDealNonStndFlag>;*fetching the field value

            IF NON.STND.FLAG EQ "Y" THEN;*if the field contains a value
                RET.VAL="N"
            END ELSE
                RET.VAL="Y"
            END
    END CASE

    RETURN
*** </region>

    END

