* @ValidationCode : MjoxOTY0MzUxNzcyOkNwMTI1MjoxNTkyNTcwNTgxMzYxOnN0aGVqYXN3aW5pOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjctMDQzNToxNjoxNg==
* @ValidationInfo : Timestamp         : 19 Jun 2020 18:13:01
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

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.UNIQUE.UND.PROD.ID(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
* Populate the value only when MIFID.REPORT.STATUS as "NEWT".
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* Populate UNDERLYING field from DX.CONTRACT.MASTER, i.e ISIN of the underlying Instrument.
* Incoming parameters:
*
* APPL.ID   -   Transaction ID of the contract.
* APPL.REC  -   A dynamic array holding the contract.
* FIELD.POS -   Current field in OC.MIFID.DATA.
*
* Outgoing parameters:
*
* RET.VAL   - UNDERLYING field from DX.CONTRACT.MASTER
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
                RET.VAL = R.DX.CONTRACT.MASTER<DX.Configuration.ContractMaster.CmUnderlying>
            END
    END CASE
RETURN
*** </region>

END



