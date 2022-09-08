* @ValidationCode : MjotMTUwOTk0MjMxNzpDcDEyNTI6MTU5MjU2OTEyMDk1NTpzdGhlamFzd2luaToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA2LjIwMjAwNTIxLTA2NTU6MTY6MTY=
* @ValidationInfo : Timestamp         : 19 Jun 2020 17:48:40
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sthejaswini
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 16/16 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-12</Rating>
*-----------------------------------------------------------------------------
$PACKAGE OC.Reporting

SUBROUTINE OC.UPD.UNDERLYING.TERM(APPL.ID, APPL.REC, FIELD.POS, RET.VAL)
*-----------------------------------------------------------------------------
*
*<Routine description>
*
* The routine will determine if type of underlying.
* Attached as a link routine in TX.TXN.BASE.MAPPING record to determine
* Term of underlying index.
*
*
* Incoming parameters:
*
* APPL.ID   -   Transaction ID of the contract.
* APPL.REC  -   A dynamic array holding the contract.
* FIELD.POS -   Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
* RET.VAL   -   Term of underlying index
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 11/06/20 - Enhancement 3715903 / Task 3796601
*            MIFID changes for DX - OC changes
*
*-----------------------------------------------------------------------------
    $USING DX.Trade
    $USING DX.Configuration
*----------------------------------------------------------------------------
    GOSUB INITIALIZE ; *
    GOSUB PROCESS ; *
RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALIZE>
INITIALIZE:
*** <desc> </desc>
    RET.VAL=''

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    BEGIN CASE
        CASE APPL.ID[1,2] EQ 'DX'
            IF APPL.REC<DX.Trade.Trade.TraMifidReportStatus> EQ 'NEWT' THEN
                ID.CONTRACT = ""
                R.DX.CONTRACT.MASTER = ""
                ID.CONTRACT = APPL.REC<DX.Trade.Trade.TraContractCode>
                R.DX.CONTRACT.MASTER = DX.Configuration.ContractMaster.Read(ID.CONTRACT, '')
                RET.VAL = R.DX.CONTRACT.MASTER<DX.Configuration.ContractMaster.CmLifeUnderlying>
            END
    END CASE
RETURN
*** </region>

END

