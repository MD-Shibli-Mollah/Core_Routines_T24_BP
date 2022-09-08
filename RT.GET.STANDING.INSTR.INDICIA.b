* @ValidationCode : MjotMTMwMjkxMDgzOkNwMTI1MjoxNjExODMwMTQ4OTAzOmpheWFsYWtzaG1pbnI6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEyLjE6LTE6LTE=
* @ValidationInfo : Timestamp         : 28 Jan 2021 16:05:48
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jayalakshminr
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202012.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE RT.BalanceAggregation
SUBROUTINE RT.GET.STANDING.INSTR.INDICIA(CUSTOMER.ID, REGULATION, RES.IN.1, RES.IN.2, INDICIA, RES.OUT.1, RES.OUT.2, RES.OUT.3)
*-----------------------------------------------------------------------------
* Sample API to check Standing instruction indicia
* Arguments:
*------------
* CUSTOMER.ID                (IN)    - Customer ID for which indicia is to be calculated
*
* REGULATION                 (IN)    - CRS/FATCA, for which regulation indicia is to be checked
*
* RES.IN1, RES.IN2           (IN)    - Incoming Reserved Arguments
*
* INDICIA                    (OUT)   - Jurisdiction if indicia is met
*
* RES.OUT1,RES.OUT2,RES.OUT3 (OUT)   - Outgoing Reserved Arguments
*-----------------------------------------------------------------------------
* Modification History :
*
* 14/09/2020    - Enhancement 3972430 / Task 3972443
*                 Sample API to check Standing instruction indicia
*
* 02/11/2020    - Enhancement 3436134 / Task 4059536
*                 Considering fiscal jurisdiction for indicia calculation
*
* 06/01/2021    - Enhancement 4175618 / Task 4139716
*                 Standing instruction indicia processing - get payment countries
*                 from RT.INDICIA.DETS table
*
* 28/01/2021    - Task 4200079
*                 Running Identify Indicia service Online.
*-----------------------------------------------------------------------------
    $USING RT.BalanceAggregation
    $USING EB.SystemTables
    $USING CD.Config
    $USING ST.CompanyCreation
    $USING ST.Config
    $USING RT.IndiciaChecks
*-----------------------------------------------------------------------------
    
    GOSUB INITIALISE
    GOSUB PROCESS
    
RETURN
*-----------------------------------------------------------------------------
INITIALISE:
    
    INDICIA = ''    ;* reset the argument
    JURISDICTION = ''
    R.INDICIA.DETS = ''
    IND.ERR = ''
    
RETURN
*-----------------------------------------------------------------------------
PROCESS:
    
    R.INDICIA.DETS = RT.BalanceAggregation.getRtIndiciaDets()
    IF NOT(R.INDICIA.DETS) THEN
        R.INDICIA.DETS = RT.IndiciaChecks.RtIndiciaDets.Read(CUSTOMER.ID, IND.ERR)
    END
    
    TOT.APP.CNT = DCOUNT(R.INDICIA.DETS<RT.IndiciaChecks.RtIndiciaDets.ApplnId>,@VM)
    FOR AP.CNT = 1 TO TOT.APP.CNT
        IF R.INDICIA.DETS<RT.IndiciaChecks.RtIndiciaDets.EffectiveDate,AP.CNT> LE EB.SystemTables.getToday() THEN  ;* even if eff date is null, condition passes
            GOSUB GET.BEN.CTRIES
        END
    NEXT AP.CNT
        
    IF JURISDICTION THEN
        INDICIA = LOWER(JURISDICTION)
    END
          
RETURN
*-----------------------------------------------------------------------------
GET.BEN.CTRIES:
    
    FATCA.CTRY = ''
    CRS.CTRY = ''
    TOT.BEN.CNT = DCOUNT(R.INDICIA.DETS<RT.IndiciaChecks.RtIndiciaDets.BenId,AP.CNT>,@SM)
    FOR BN.CNT = 1 TO TOT.BEN.CNT
        FATCA.CTRY = R.INDICIA.DETS<RT.IndiciaChecks.RtIndiciaDets.FatcaBenCountry,AP.CNT,BN.CNT>
        IF FATCA.CTRY AND (REGULATION EQ 'FATCA') THEN
            LOCATE FATCA.CTRY IN JURISDICTION SETTING POS ELSE  ;* to avoid duplicates
                JURISDICTION<-1> = FATCA.CTRY
            END
        END
        CRS.CTRY = R.INDICIA.DETS<RT.IndiciaChecks.RtIndiciaDets.CrsBenCountry,AP.CNT,BN.CNT>
        IF CRS.CTRY AND (REGULATION EQ 'CRS') THEN
            LOCATE CRS.CTRY IN JURISDICTION SETTING POS ELSE  ;* to avoid duplicates
                JURISDICTION<-1> = CRS.CTRY
            END
        END
    NEXT BN.CNT
    
RETURN
*-----------------------------------------------------------------------------
END

