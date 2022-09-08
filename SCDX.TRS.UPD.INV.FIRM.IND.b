* @ValidationCode : MjoxMDE1NTc2MTM1OkNwMTI1MjoxNjA0ODM3NTAwMTEyOnJkZWVwaWdhOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDkuMjAyMDA4MjgtMTYxNzoyMToyMQ==
* @ValidationInfo : Timestamp         : 08 Nov 2020 17:41:40
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 21/21 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.UPD.INV.FIRM.IND(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine returns the investment firm indicator to update it
* in SCDX.ARM.MIFID.DATA for reporting purpose
* Attached as the link routine in TX.TXN.BASE.MAPPING for updation in
* Database SCDX.ARM.MIFID.DATA
* Incoming parameters:
**********************
* TXN.ID   -   Transaction ID of the contract.
* TXN.REC  -   A dynamic array holding the contract.
* TXN.DATA -   Data passed based on setup done in TX.TXN.BASE.MAPPING
*
* Outgoing parameters:
**********************
* RET.VAL  -  Investment Firm Indicator
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 22/10/2020 - SI - 3754772 / ENH - 3994136 / TASK - 3994144
*              TRS Reporting / Mapping Routines
*
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Inserts and control logic</desc>

    $USING OC.Parameters
    $USING SC.Config
    $USING ST.CompanyCreation
    
*** </region>
*-----------------------------------------------------------------------------

    GOSUB INITIALISE    ; *Initialise the variables required for processing
    GOSUB PROCESS       ; *Process to return the Investment firm indicator
           
RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise the variables required for processing </desc>

    RET.VAL = ''
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>Process to return the investment firm indicator for reporting purpose </desc>

    BEGIN CASE
        CASE TXN.ID[1,6] EQ "SCTRSC"
            SC.PARAM.REC = '' ; SC.PARAM.ERR = ''
            ST.CompanyCreation.EbReadParameter('F.SC.PARAMETER', 'N', '', SC.PARAM.REC, '', '', SC.PARAM.ERR)
            IF SC.PARAM.REC<SC.Config.Parameter.ParamReportingEntityId> THEN
                RET.VAL = "TRUE"
            END
                    
        CASE TXN.ID[1,5] EQ "DXTRA"
            OC.PARAM.REC = '' ; OC.PARAM.ERR = ''
            ST.CompanyCreation.EbReadParameter('F.OC.PARAMETER', 'N', '', OC.PARAM.REC, '', '', OC.PARAM.ERR)
            REGULATORY.CLASS = OC.PARAM.REC<OC.Parameters.OcParameter.ParamRegulatoryClass>
            IF REGULATORY.CLASS EQ "FINANCIAL.COUNTERPARTY" THEN
                RET.VAL = "TRUE"
            END
                            
    END CASE
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
