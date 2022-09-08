* @ValidationCode : MjoxNTcxODMxOTc3OmNwMTI1MjoxNDg3MDc4NDk4ODA4OmhhcnJzaGVldHRncjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE2MTIuMjAxNjExMDItMTE0MjotMTotMQ==
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
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.MASTER.AGREEMENT.VERSION(APPL.ID, APPL.REC, FIELD.POS, RET.VAL)
*-----------------------------------------------------------------------------
****
*<Routine desc>
*
*The routine can be attached as LINK routine in tax mapping record
*to update master agreement version of the trade.
*
* Incoming parameters:
*
* APPL.ID  - Id of transaction
* APPL.REC  - A dynamic array holding the contract.
* FIELD.POS - Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
*Ret.val - agreement version returned.
*
* 12/12/16 - Enhancement 1764033 / Task 1829190
*            Bring sample EMIR mappings into Dev
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

    $USING FX.Contract
    $USING SW.Contract

*-----------------------------------------------------------------------------

    GOSUB INITIALISE ; *
    GOSUB PROCESS ; *

    RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>

    RET.VAL=''

    RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>

    BEGIN CASE

        CASE APPL.ID[1,2] EQ 'FX'
            AGREEMENT.TYPE = APPL.REC<FX.Contract.Forex.AgreementType>

        CASE APPL.ID[1,2] EQ 'ND'
            AGREEMENT.TYPE = APPL.REC< FX.Contract.NdDeal.NdDealAgreementType>

        CASE APPL.ID[1,2] EQ 'SW'
            AGREEMENT.TYPE = APPL.REC<SW.Contract.Swap.AgreementType>

    END CASE

    RET.VAL = FIELD(AGREEMENT.TYPE,'//',2)

    RETURN
*** </region>

    END


