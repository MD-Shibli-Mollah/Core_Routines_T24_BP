* @ValidationCode : MjotMTc1MjI0NzU2NjpDcDEyNTI6MTU5OTU2NzA1MjYxOTprYmhhcmF0aHJhajo5OjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA4LjIwMjAwNzMxLTExNTE6NTM6NTA=
* @ValidationInfo : Timestamp         : 08 Sep 2020 17:40:52
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kbharathraj
* @ValidationInfo : Nb tests success  : 9
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 50/53 (94.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.REP.ENTITY(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
*
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* to populate Logic to be written as if THIRD.PARTY.REPORTING field in OC.PARAMETER is set to Yes, then use LEGAL.ENTITY.ID from the OC.CUSTOMER record which is specified in REPORTING.ENTITY field in the application which is defaulted from OC.PARAMETER; if not then LEI code of the T24 bank as stored in OC.PARAMETER
*
* Incoming parameters:
*
* APPL.ID   -   Transaction ID of the contract.
* APPL.REC  -   A dynamic array holding the contract.
* FIELD.POS -   Current field in OC.MIFID.DATA.
*
* Outgoing parameters:
*
* RET.VAL   - LEI.ID or NULL
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 31/03/20 - Enhancement 3660945 / Task 3660948
*            CI#4 - Mapping Routines - Part II
*
* 02/04/2020 - Enhancement - 3661737 / Task - 3661740
*              CI#3 Mapping Routines Part-2
*
* 14/04/20 - Enhancement 3689608 / Task 3689612
*            CI#4 - Mapping routines - Part III
*
* 11/06/20 - Enhancement 3715903 / Task 3796601
*            MIFID changes for DX - OC changes
*
* 27/08/20 - Enhancement 3793940 / Task 3793943
*            CI#3 - Mapping routines - Part II
*-----------------------------------------------------------------------------

    $USING ST.CompanyCreation
    $USING EB.SystemTables
    $USING OC.Parameters
    $USING FX.Contract
    $USING FR.Contract
    $USING SW.Contract
    $USING ST.Customer
    $USING DX.Trade
    
    GOSUB INITIALIZE ; *
    GOSUB PROCESS ; *
RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALIZE>
INITIALIZE:
*** <desc> </desc>
    RET.VAL = ''
    OcParamId = ''
    OcParamRec = ''
    ThirdPartyReporting= ''
    ReportingEntity = ''
    OcCusRec = ''
    LeiIdFromOcParam = ''
    LeiId = ''
    NationalId = ''
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
                        
    OcParamId = EB.SystemTables.getIdCompany()
    OcParamErr = ''
    ST.CompanyCreation.EbReadParameter('F.OC.PARAMETER', '', '', OcParamRec, OcParamId, '', OcParamErr)
    IF OcParamRec THEN
        ThirdPartyReporting = OcParamRec<OC.Parameters.OcParameter.ParamThirdPartyReporting>
        IF ThirdPartyReporting EQ "YES" THEN
            GOSUB GET.REPORTING.ENTITY.FROM.APP ; *
        END ELSE
            LeiIdFromOcParam = OcParamRec<OC.Parameters.OcParameter.ParamBankLei>
            RET.VAL = LeiIdFromOcParam
        END
    END

    
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.DATA.FROM.OC.CUSTOMER>
GET.DATA.FROM.OC.CUSTOMER:
*** <desc> </desc>
    OcCusErr = ''
    OcCusRec = ST.Customer.OcCustomer.CacheRead(ReportingEntity, Error)
    IF OcCusRec THEN
        LeiId = OcCusRec<ST.Customer.OcCustomer.CusLegalEntityId>
        IF LeiId THEN
            RET.VAL = LeiId
        END
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= GET.REPORTING.ENTITY.FROM.APP>
GET.REPORTING.ENTITY.FROM.APP:
*** <desc> </desc>
    BEGIN CASE
        CASE APPL.ID[1,2] EQ 'ND'
            ReportingEntity = APPL.REC<FX.Contract.NdDeal.NdDealReportingEntity>
            GOSUB GET.DATA.FROM.OC.CUSTOMER ; *
            
        CASE APPL.ID[1,2] EQ 'SW'
            ReportingEntity = APPL.REC<SW.Contract.Swap.ReportingEntity>
            GOSUB GET.DATA.FROM.OC.CUSTOMER ; *
            
        CASE APPL.ID[1,2] EQ 'FR'
            ReportingEntity = APPL.REC<FR.Contract.FraDeal.FrdReportingEntity>
            GOSUB GET.DATA.FROM.OC.CUSTOMER ; *
                        
        CASE APPL.ID[1,2] EQ 'DX'
            ReportingEntity = APPL.REC<DX.Trade.Trade.TraReportingEntity>
            GOSUB GET.DATA.FROM.OC.CUSTOMER ; *
            
        CASE APPL.ID[1,2] EQ 'FX'
            ReportingEntity = APPL.REC<FX.Contract.Forex.ReportingEntity>
            GOSUB GET.DATA.FROM.OC.CUSTOMER ; *
    END CASE
RETURN
*** </region>

END






