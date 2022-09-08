* @ValidationCode : MjoxNzA5NDg1NzA4OmNwMTI1MjoxNDg3MDc3ODAyODY0OmhhcnJzaGVldHRncjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE2MTIuMjAxNjExMDItMTE0MjotMTotMQ==
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
* <Rating>-27</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.PRODUCT.ID.1(APPL.ID, APPL.REC, FIELD.POS, RET.VAL)
*-----------------------------------------------------------------------------
***<Routine description>
*
*The routine will be attached as a link routine in tx.txn.base.mapping record to
*update the product identifier.
*
* Incoming parameters:
*
* APPL.ID  - Id of transaction
* APPL.REC  - A dynamic array holding the contract.
* FIELD.POS - Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
* Ret.val - CU/IR/CO depends on application
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 12/12/16 - Enhancement 1764033 / Task 1829190
*            Bring sample EMIR mappings into Dev
*
*-----------------------------------------------------------------------------

    $USING FX.Contract
*-----------------------------------------------------------------------------

    GOSUB INITIALIZE ; *
    GOSUB PROCESS ; *

    RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALIZE>
INITIALIZE:
*** <desc> initialise the variables</desc>

    RET.VAL = ''

    RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>determine product ids </desc>

    BEGIN CASE

        CASE APPL.ID[1,2] = "ND";*always currency trading
            RET.VAL = "CU"

        CASE APPL.ID[1,2] = "SW"
            RET.VAL = "IR"

        CASE APPL.ID[1,2] = "FX"

            IF APPL.REC<FX.Contract.Forex.Quantity> EQ '' THEN;*for currency forwards
                RET.VAL = "CU"
            END ELSE
                RET.VAL = "CO";*for commodity forwards
            END
    END CASE

    RETURN
*** </region>

    END


