* @ValidationCode : MjoyMTM5ODQ1MDkyOmNwMTI1MjoxNDg3MDc4NDk4OTU0OmhhcnJzaGVldHRncjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE2MTIuMjAxNjExMDItMTE0MjotMTotMQ==
* @ValidationInfo : Timestamp         : 14 Feb 2017 18:51:38
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
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.DELIVERY.TYPE (APPL.ID, APPL.REC, FIELD.POS, RET.VAL)
*-----------------------------------------------------------------------------
*
* <Routine desc>
*
*The routine will be attached as the link routine in tax mapping record
*to update the delivery types for OC applications.
**
* Incoming parameters:
*
* APPL.ID  - Id of transaction
* APPL.REC  - A dynamic array holding the contract.
* FIELD.POS - Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
*Ret.val - "C" - for swap,nd.deal and currency FX.
*        - "P" -for commodity FX
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

    GOSUB INITIALIZE

    GOSUB PROCESS

    RETURN

*-----------------------------------------------------------------------------


INITIALIZE:

    RET.VAL = ''

    RETURN

*-----------------------------------------------------------------------------


PROCESS:

    BEGIN CASE

        CASE APPL.ID[1,2] = "SW" OR APPL.ID[1,2] = "ND"
            RET.VAL = "C"

        CASE APPL.ID[1,2] = "FX"
            IF APPL.REC<FX.Contract.Forex.Quantity> EQ '' THEN;*for currency forex
                RET.VAL = "C"
            END ELSE
                RET.VAL = "P";*commodity forex
            END

    END CASE

    RETURN

*-----------------------------------------------------------------------------


    END
