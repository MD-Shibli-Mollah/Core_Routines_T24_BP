* @ValidationCode : MjoyMTQxNDMxMDQxOkNwMTI1MjoxNTk5NTY3MDY3NDUzOmtiaGFyYXRocmFqOjY6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDguMjAyMDA3MzEtMTE1MTozMjozMg==
* @ValidationInfo : Timestamp         : 08 Sep 2020 17:41:07
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kbharathraj
* @ValidationInfo : Nb tests success  : 6
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 32/32 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.CPARTY.CORP.SECTOR(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
* The routine will be attached as a link routine in TX.TXN.BASE.MAPPING record.
* It returns CORPORATE.SECTOR field value from the table OC.PARAMETER.
* This is applicable for the FRA.DEAL,ND and SWAP
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
* Ret.val- returns CORPORATE.SECTOR field value from the table OC.PARAMETER.
*
*
*******************************************************************
* Modification History :
*
* 31/01/2020 - Enhancement 3562849 / Task 3562851
*              CI #3 - Mapping Routines
*
* 02/03/2020 - Enhancement 3572828 / Task 3572830
*              EMIR-ND CI #3 - Mapping Routines
*
* 08/06/2020 - Enhancement 3715904 / Task 3786684
*              EMIR changes for DX
*
* 27/08/2020 - Enhancement 3793940 / Task 3793943
*              CI#3 - Mapping routines - Part II
*-----------------------------------------------------------------------------


    $USING OC.Parameters
    $USING FR.Contract
    $USING EB.SystemTables
    $USING ST.CompanyCreation

    GOSUB INITIALISE ; *
    GOSUB PROCESS ; *

RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc> </desc>
    RET.VAL = ""
    OcParamId = ""
    OcParamRec = ""
    CorporateSector = ""
    CorporateSectorCount = ""
    CorpSec = ""
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    IF (APPL.ID[1,2] EQ 'FR') OR (APPL.ID[1,2] EQ 'ND') OR (APPL.ID[1,2] EQ 'SW') OR (APPL.ID[1,2] EQ 'DX') OR (APPL.ID[1,2] EQ 'FX') THEN
        OcParamId = EB.SystemTables.getIdCompany()
        OcParamErr = ''
        ST.CompanyCreation.EbReadParameter('F.OC.PARAMETER', '', '', OcParamRec, OcParamId, '', OcParamErr)
         
        IF OcParamRec THEN
            CorporateSector = OcParamRec<OC.Parameters.OcParameter.ParamCorporateSector>
            CorporateSectorCount = DCOUNT(CorporateSector,@VM)
           
            IF CorporateSector AND CorporateSectorCount EQ 1 THEN
                RET.VAL = CorporateSector
            END ELSE
                GOSUB UPDATE.MULT.CORP.SECTOR
            END
        END
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= UPDATE.MULT.CORP.SECTOR>
UPDATE.MULT.CORP.SECTOR:
*** <desc> </desc>
    IF CorporateSector AND CorporateSectorCount GT 1 THEN
        RET.VAL = CorporateSector<1,1>
        FOR CorpSec=2 TO CorporateSectorCount
            RET.VAL = RET.VAL:"-":CorporateSector<1,CorpSec>
        NEXT CorpSec
    END

RETURN

END


