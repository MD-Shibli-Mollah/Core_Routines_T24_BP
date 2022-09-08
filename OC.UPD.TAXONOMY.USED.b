* @ValidationCode : MjoxMTUwNDU5NDgzOmNwMTI1MjoxNDg3MDc3ODAyODEzOmhhcnJzaGVldHRncjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE2MTIuMjAxNjExMDItMTE0MjotMTotMQ==
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
* <Rating>-29</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.TAXONOMY.USED(APPL.ID, APPL.REC, FIELD.POS, RET.VAL)
*-----------------------------------------------------------------------------
****<Routine description>
*
*The routine will be attached as a link routine in tx.txn.base.mapping record to
*update the taxonomy.
*
* Incoming parameters:
*
* APPL.ID  - Id of transaction
* APPL.REC  - A dynamic array holding the contract.
* FIELD.POS - Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
* Ret.val - "E"/"U"
*
*Prerequisites:
*
*The field name for Product Identifier should be UNI.PROD.ID as defined in the routine.
*-----------------------------------------------------------------------------
* Modification History :
*
* 12/12/16 - Enhancement 1764033 / Task 1829190
*            Bring sample EMIR mappings into Dev
*
*-----------------------------------------------------------------------------

    $USING EB.SystemTables
    $USING SW.Contract

*-----------------------------------------------------------------------------


    GOSUB INITIALIZE ; *
    GOSUB PROCESS ; *


    RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALIZE>
INITIALIZE:
*** <desc>Initialise the variables </desc>

    RET.VAL = ''
    UNI.PROD.ID=''

    RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>


    BEGIN CASE

        CASE APPL.ID[1,2] EQ "FX" OR APPL.ID[1,2] EQ "ND";*for forex and nd.deal
            RET.VAL = 'E'

        CASE APPL.ID[1,2] = "SW";*for swap


            UNI.PROD.ID = EB.SystemTables.getRNew(SW.Contract.Swap.UniProdId);*fetching the field value

            IF UNI.PROD.ID NE '' THEN;*if the field contains a value
                RET.VAL="U"
            END ELSE
                RET.VAL="E"
            END

    END CASE

    RETURN
*** </region>

    END


