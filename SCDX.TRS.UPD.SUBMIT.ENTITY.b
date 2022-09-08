* @ValidationCode : MjoyMDc1MDg4NjYxOkNwMTI1MjoxNjA0ODM3NDk5NTkzOnJkZWVwaWdhOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDkuMjAyMDA4MjgtMTYxNzozMDozMA==
* @ValidationInfo : Timestamp         : 08 Nov 2020 17:41:39
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rdeepiga
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 30/30 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.20200828-1617
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SctTrading
SUBROUTINE SCDX.TRS.UPD.SUBMIT.ENTITY(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)
*-----------------------------------------------------------------------------
* This routine fetches the Submitting Entity Id for DX transactions
* to update it in SCDX.ARM.MIFID.DATA for reporting purpose
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
* RET.VAL  -  Submitting Entity (LEI)
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
    $USING ST.CompanyCreation
    $USING DX.Trade
    $USING ST.Customer
    
*** </region>
*-----------------------------------------------------------------------------

    GOSUB INITIALISE    ; *Initialise the variables required for processing
    GOSUB PROCESS       ; *Process to fetch the Submitting Entity id
           
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
*** <desc>Process to fetch the Submitting Entity Id for reporting purpose </desc>

    BEGIN CASE
        CASE TXN.ID[1,5] EQ "DXTRA"
            REPORTING.ENTITY = TXN.REC<DX.Trade.Trade.TraReportingEntity>
        
    END CASE
    
    OC.PARAM.REC = ''; OC.PARAM.ERR = ''
    ST.CompanyCreation.EbReadParameter('F.OC.PARAMETER', 'N', '', OC.PARAM.REC, '', '', OC.PARAM.ERR)
    IF OC.PARAM.REC THEN
        THIRD.PARTY.REPORTING = OC.PARAM.REC<OC.Parameters.OcParameter.ParamThirdPartyReporting>
        IF THIRD.PARTY.REPORTING EQ "YES" THEN
            GOSUB GET.DATA.FROM.OC.CUSTOMER
        END ELSE
            RET.VAL = OC.PARAM.REC<OC.Parameters.OcParameter.ParamBankLei>
        END
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= GET.DATA.FROM.OC.CUSTOMER>
GET.DATA.FROM.OC.CUSTOMER:
*** <desc> Get the LEI from the Reporting Entity</desc>

    IF NOT(REPORTING.ENTITY) THEN
        RETURN
    END

    OC.CUS.ERR = ''
    OC.CUS.REC = ST.Customer.OcCustomer.CacheRead(REPORTING.ENTITY, OC.CUS.ERR)
    LEI.ID = OC.CUS.REC<ST.Customer.OcCustomer.CusLegalEntityId>
    IF LEI.ID THEN
        RET.VAL = LEI.ID
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

END
