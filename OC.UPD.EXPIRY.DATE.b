* @ValidationCode : MjozMDM0MDQwNjk6Q3AxMjUyOjE1OTI1NzA5NzA2MDk6c3RoZWphc3dpbmk6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwNi4yMDIwMDUyNy0wNDM1OjE2OjE2
* @ValidationInfo : Timestamp         : 19 Jun 2020 18:19:30
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sthejaswini
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 16/16 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-27</Rating>
*-----------------------------------------------------------------------------
$PACKAGE OC.Reporting

SUBROUTINE OC.UPD.EXPIRY.DATE(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
* The routine will be attached as a link routine in TX.TXN.BASE.MAPPING record.
* FOR DX.TRADE - Expiry date is applicable for derivative transactions with option-type
* of characteristic included; LAST.DELIVERY from DX.CONTRACT.MASTER is returned.
*-----------------------------------------------------------------------------
* Modification History :
*
* 11/06/20 - Enhancement 3715903 / Task 3796601
*            MIFID changes for DX - OC changes
*
*-----------------------------------------------------------------------------
*******************************************************************
*
*
* Incoming parameters:
*
* APPL.ID   - Id of transaction
* APPL.REC  - A dynamic array holding the contract.
* FIELD.POS - Current field in OC.MIFID.DATA.
*
* Outgoing parameters:
*
* Ret.val- Variable holding the value of LAST.DELIVERY from DX.CONTRACT.MASTER.
*
*
*******************************************************************

    $USING DX.Trade
    $USING DX.Configuration

*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB PROCESS

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
PROCESS:
*** <desc>PROCESS </desc>


    BEGIN CASE
            
        CASE APPL.ID[1,2] EQ 'DX'
            IF APPL.REC<DX.Trade.Trade.TraMifidReportStatus> EQ 'NEWT' THEN
                ID.CONTRACT = ""
                R.DX.CONTRACT.MASTER = ""
                ID.CONTRACT = APPL.REC<DX.Trade.Trade.TraContractCode>
                R.DX.CONTRACT.MASTER = DX.Configuration.ContractMaster.Read(ID.CONTRACT, '')
                RET.VAL = R.DX.CONTRACT.MASTER<DX.Configuration.ContractMaster.CmLastDelivery>
            END
    END CASE

RETURN
*** </region>

*-----------------------------------------------------------------------------


END
