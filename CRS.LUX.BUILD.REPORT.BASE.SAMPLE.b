* @ValidationCode : MjotMTIyNjk3MjcwODpDcDEyNTI6MTU4MzMxNDk1Mjc2ODpoYWFyaW5pcjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MTEuMjAxOTEwMTYtMDM1NDotMTotMQ==
* @ValidationInfo : Timestamp         : 04 Mar 2020 15:12:32
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : haarinir
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201911.20191016-0354
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE CE.CrsReporting
SUBROUTINE CRS.LUX.BUILD.REPORT.BASE.SAMPLE(CRS.REPORT.BASE.ID,ACTION,R.CRS.REPORT.BASE,SPARE.1,SPARE.2,SPARE.3)
*-----------------------------------------------------------------------------
* Description    : CRS.LUX.BUILD.REPORT.BASE is a new api that will amend the report base content as required for Luxembourg.
*                  This will be attached to CRS.REPORTING.PARAMETER as COUNTRY.RTN
*
* In Parameter   :
*
* CRS.REPORT.BASE.ID = Record ID of CRS.REPORT.BASE being created/modified or deleted
* ACTION             = NEW , DELETE or AMEND
*
* In/Out Parameter  :
*
* R.CRS.REPORT.BASE  = Incoming report base record
* SPARE.1            = Reserved.1
* SPARE.2            = Reserved.2
* SPARE.3            = Reserved.3
 
*-----------------------------------------------------------------------------
* Modification History :
*
* 03/4/2020- Defect 3475316/Task 3475391
*            Changing F.WRITE to COMPONENT.TABLE.WRITE
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------

    $USING EB.API
    $USING EB.Utility
    $USING EB.DataAccess
    $USING CD.Config
    $USING EB.SystemTables
    $USING CD.CustomerIdentification


    BEGIN CASE
        CASE ACTION EQ 'NEW'
            GOSUB ProcessJurisdiction    ;* Creating a new CRS.REPORT.BASE record
            GOSUB ProcessEntity
        CASE ACTION EQ 'DELETE'
            GOSUB DeleteLuxReportBases ;* Deleting a CRS.REPORT.BASE record
        CASE ACTION EQ 'AMEND'
            GOSUB DeleteLuxReportBases ;*delete records before amendment
            GOSUB ProcessJurisdiction ;* Amending a CRS.REPORT.BASE record
            GOSUB ProcessEntity
            IF KeyList NE '' THEN
                ListCount = DCOUNT(KeyList,@FM)
                FOR DelCnt = 1 TO ListCount
                    EB.DataAccess.FDelete('F.CRS.REPORT.BASE',KeyList<DelCnt>)
                NEXT DelCnt
            END
    END CASE
    
RETURN
*---------------------------------------------------------------------------------
*** <region name= ProcessJurisdiction>
*** <desc>Preocess split report base records based on jurisdiction</desc>

*** </region>

ProcessJurisdiction:

    LST.CRS = ''
    TOT.REP.JR = DCOUNT(R.CRS.REPORT.BASE<CE.CrsReporting.CrsReportBase.CrbReportingJurisdiction>,@VM)
    FOR I = 1 TO TOT.REP.JR
        R.CRS.REPORT.BASE.NEW = ''
        R.CRS.REPORT.BASE.NEW = R.CRS.REPORT.BASE
        R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbReportingJurisdiction> = R.CRS.REPORT.BASE<CE.CrsReporting.CrsReportBase.CrbReportingJurisdiction,I>
        R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbCrsStatus> = R.CRS.REPORT.BASE<CE.CrsReporting.CrsReportBase.CrbCrsStatus,I>
        IF R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbClientType> = 'INDIVIDUAL' THEN
            R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbNationality> = ''  ;* For Individuals, Nationality should be null.
* Last Name not updated in Customer file, so it has to be split from the Name field. As Last name is mandatory for Individuals.
            IF R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbNameTwo> = '' THEN
                TOT.NAMES = COUNT(R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbNameOne>,SPACE(1))
                IF TOT.NAMES GT 1 THEN
                    IF R.CRS.REPORT.BASE<CE.CrsReporting.CrsReportBase.CrbNameOne>[SPACE(1),TOT.NAMES+1,1] = '' THEN
                        TOT.NAMES = TOT.NAMES - 1
                    END
                    R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbNameOne> = R.CRS.REPORT.BASE<CE.CrsReporting.CrsReportBase.CrbNameOne>[SPACE(1),1,TOT.NAMES]
                    R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbNameTwo> = R.CRS.REPORT.BASE<CE.CrsReporting.CrsReportBase.CrbNameOne>[SPACE(1),TOT.NAMES+1,1]
                END ELSE
                    R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbNameOne> = R.CRS.REPORT.BASE<CE.CrsReporting.CrsReportBase.CrbNameOne>[SPACE(1),1,1]
                    R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbNameTwo> = R.CRS.REPORT.BASE<CE.CrsReporting.CrsReportBase.CrbNameOne>[SPACE(1),2,1]
                END
            END
        END ELSE
            R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbNationality> = ''
            TOT.CP.CUST = DCOUNT(R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbCpCust>,@VM)
            FOR WW = 1 TO TOT.CP.CUST
                IF R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbCpCustNameTwo,WW> = '' THEN
                    TOT.NAMES = COUNT(R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbCpCustNameOne,WW>,SPACE(1))
                    IF TOT.NAMES GT 1 THEN
                        IF R.CRS.REPORT.BASE<CE.CrsReporting.CrsReportBase.CrbCpCustNameOne,WW>[SPACE(1),TOT.NAMES+1,1] = '' THEN
                            TOT.NAMES = TOT.NAMES - 1
                        END
                        R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbCpCustNameOne,WW> = R.CRS.REPORT.BASE<CE.CrsReporting.CrsReportBase.CrbCpCustNameOne,WW>[SPACE(1),1,TOT.NAMES]
                        R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbCpCustNameTwo,WW> = R.CRS.REPORT.BASE<CE.CrsReporting.CrsReportBase.CrbCpCustNameOne,WW>[SPACE(1),TOT.NAMES+1,1]
                    END ELSE
                        R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbCpCustNameOne,WW> = R.CRS.REPORT.BASE<CE.CrsReporting.CrsReportBase.CrbCpCustNameOne,WW>[SPACE(1),1,1]
                        R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbCpCustNameTwo,WW> = R.CRS.REPORT.BASE<CE.CrsReporting.CrsReportBase.CrbCpCustNameOne,WW>[SPACE(1),2,1]
                    END
                END
            NEXT WW
        END

        LOCATE R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbReportingJurisdiction> IN R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbCpTinCountry,I> SETTING POS THEN
            R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbCpTinCountry> = R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbCpTinCountry,POS>
            R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbTinCode> = R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbTinCode,POS>
            IF R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbTinCode> = '' THEN
                R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbTinCode> = '#NTA001#'
            END
        END ELSE
            R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbCpTinCountry> =  R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbReportingJurisdiction>
            R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbTinCode> = '#NTA001#'
        END

        GOSUB UpdateMessageRef
               
        KEY.CRB.NEW = 'LU-':CRS.REPORT.BASE.ID:'-':R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbReportingJurisdiction>:'-LU':I
        IF ACTION EQ "AMEND" THEN
            LOCATE KEY.CRB.NEW IN KeyList SETTING POS THEN
                DEL KeyList<POS>
            END
        END
        CE.CrsReporting.CrsReportBase.Write(KEY.CRB.NEW,R.CRS.REPORT.BASE.NEW)
        LST.CRS<-1> = KEY.CRB.NEW
    NEXT I
    
RETURN

ProcessEntity:
    
    IF R.CRS.REPORT.BASE<CE.CrsReporting.CrsReportBase.CrbClientType> = 'ORGANISATION' AND R.CRS.REPORT.BASE<CE.CrsReporting.CrsReportBase.CrbCpCust> # '' THEN

        R.CCSI = '' ; CCSI.ERR = '' ; TAX.RES.ARRAY = ''
        ID.CCSI = FIELD(CRS.REPORT.BASE.ID,".",1)
        R.CCSI = CD.CustomerIdentification.CrsCustSuppInfo.Read(ID.CCSI, CCSI.ERR)

;* Get list of all unique RT.TAX.RESIDENCE and the respective CP customers & their tax IDs.
        TOT.CTRLPERSON = DCOUNT(R.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiRoleType>,@VM)
        FOR I = 1 TO TOT.CTRLPERSON
            TOTAL.TAX.RES = DCOUNT(R.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiRtTaxResidence,I>,@SM)
            FOR J = 1 TO TOTAL.TAX.RES
                LOCATE R.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiRtTaxResidence,I,J> IN TAX.RES.ARRAY<1,1> SETTING TAX.RES.POS THEN ;*TO CHECK FOR DUPLICATE
                    TAX.RES.ARRAY<2,TAX.RES.POS,-1> = R.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiCustomerId,I>
                    IF R.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiTin,I,J> NE '' THEN
                        TAX.RES.ARRAY<3,TAX.RES.POS,-1> = R.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiTin,I,J>
                    END ELSE
                        TAX.RES.ARRAY<3,TAX.RES.POS,-1> = '#NTA001#'
                    END
                END ELSE
                    TAX.RES.ARRAY<1,-1> = R.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiRtTaxResidence,I,J>
                    TAX.RES.ARRAY<2,-1> = R.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiCustomerId,I>
                    IF R.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiTin,I,J> NE '' THEN
                        TAX.RES.ARRAY<3,TAX.RES.POS,-1> = R.CCSI<CD.CustomerIdentification.CrsCustSuppInfo.CdSiTin,I,J>
                    END ELSE
                        TAX.RES.ARRAY<3,TAX.RES.POS,-1> = '#NTA001#'
                    END
                END
            NEXT J
        NEXT I

        TAX.RES.LIST = TAX.RES.ARRAY<1>
        CRB.FOR.REM.CP = ''

        TOT.RECS = DCOUNT(LST.CRS,@FM)
        FOR K = 1 TO TOT.RECS
            KEY.REPORT.BASE = LST.CRS<K>
            R.CRB = CE.CrsReporting.CrsReportBase.Read(KEY.REPORT.BASE, STR.READERR)
            CRB.FOR.REM.CP = R.CRB

;*For Controlling Person
            LOCATE R.CRB<CE.CrsReporting.CrsReportBase.CrbReportingJurisdiction> IN TAX.RES.ARRAY<1,1> SETTING TAX.RES.POS1 THEN
                R.CRB.NEW = ''
                TOTAL.RES.CP = ''
                R.CRB.NEW = R.CRB
                R.CRB.NEW<CE.CrsReporting.CrsReportBase.CrbAcctHolderType> = 'CRS101'

                FOR YY = CE.CrsReporting.CrsReportBase.CrbCpCust TO CE.CrsReporting.CrsReportBase.CrbAccReserved1
                    R.CRB.NEW<YY> = ''
                NEXT YY

                TOTAL.RES.CP = DCOUNT(TAX.RES.ARRAY<2,TAX.RES.POS1>,@SM)

                FOR RES.CP.CNT = 1 TO TOTAL.RES.CP
                    LOCATE TAX.RES.ARRAY<2,TAX.RES.POS1,RES.CP.CNT> IN R.CRB<CE.CrsReporting.CrsReportBase.CrbCpCust,1> SETTING CP.POS THEN
                        FOR FLD.CNT = CE.CrsReporting.CrsReportBase.CrbCpCust TO CE.CrsReporting.CrsReportBase.CrbAccReserved1
                            BEGIN CASE
                                CASE FLD.CNT = CE.CrsReporting.CrsReportBase.CrbCpCustTin
                                    R.CRB.NEW<FLD.CNT,-1> = TAX.RES.ARRAY<3,TAX.RES.POS1,RES.CP.CNT>

                                CASE FLD.CNT = CE.CrsReporting.CrsReportBase.CrbCpTinCountry
                                    R.CRB.NEW<FLD.CNT,-1> = TAX.RES.ARRAY<1,TAX.RES.POS1>

                                CASE 1
                                    R.CRB.NEW<FLD.CNT,-1> = R.CRB<FLD.CNT,CP.POS>

                            END CASE
                        NEXT FLD.CNT
                    END
                NEXT RES.CP.CNT

                TAX.RES.LIST<1,TAX.RES.POS1> = ''
                R.CRB.NEW<CE.CrsReporting.CrsReportBase.CrbReportingJurisdiction> = TAX.RES.ARRAY<1,TAX.RES.POS1>
                ID.CRB.NEW = KEY.REPORT.BASE:'-CP-':R.CRB.NEW<CE.CrsReporting.CrsReportBase.CrbReportingJurisdiction>
                R.CRS.REPORT.BASE.NEW = R.CRB.NEW
                GOSUB UpdateMessageRef
                R.CRB.NEW = R.CRS.REPORT.BASE.NEW
                IF ACTION EQ "AMEND" THEN
                    LOCATE ID.CRB.NEW IN KeyList SETTING POS THEN
                        DEL KeyList<POS>
                    END
                END
                CE.CrsReporting.CrsReportBase.Write(ID.CRB.NEW,R.CRB.NEW)
            END ELSE

;*For Entity
                R.CRB.NEW = R.CRB
                ID.CRB.NEW = KEY.REPORT.BASE:'-ENTITY'
                FOR Y = CE.CrsReporting.CrsReportBase.CrbCpCust TO CE.CrsReporting.CrsReportBase.CrbAccReserved1
                    R.CRB.NEW<Y> = ''
                NEXT Y
                IF R.CRB.NEW<CE.CrsReporting.CrsReportBase.CrbAcctHolderType> NE 'CRS103' THEN
                    R.CRB.NEW<CE.CrsReporting.CrsReportBase.CrbAcctHolderType> = 'CRS103'
                END
                IF ACTION EQ "AMEND" THEN
                    LOCATE ID.CRB.NEW IN KeyList SETTING POS THEN
                        DEL KeyList<POS>
                    END
                END
                CE.CrsReporting.CrsReportBase.Write(ID.CRB.NEW,R.CRS.REPORT.BASE.NEW)
            END
            EB.DataAccess.FDelete('F.CRS.REPORT.BASE',KEY.REPORT.BASE)

        NEXT K
    
        TEMP.LIST = TAX.RES.LIST
        CONVERT @VM TO '' IN TEMP.LIST
        IF TEMP.LIST NE '' THEN
            GOSUB BuildForRemainingCp
        END

    END
RETURN
*-----------------------------------------------------------------------------
BuildForRemainingCp:
*-----------------------------------------------------------------------------
    TOTAL.REMAINING.RT.COUNTRY = DCOUNT(TAX.RES.LIST,@VM)

    FOR REM.RT.CNT = 1 TO TOTAL.REMAINING.RT.COUNTRY
        R.CRB = CRB.FOR.REM.CP
        LOCATE TAX.RES.LIST<1,REM.RT.CNT> IN TAX.RES.ARRAY<1,1> SETTING TAX.RES.POS1 THEN
            R.CRB.NEW = ''
            TOTAL.RES.CP = ''
            R.CRB.NEW = R.CRB
            R.CRB.NEW<CE.CrsReporting.CrsReportBase.CrbAcctHolderType>         = 'CRS101'

            FOR YY = CE.CrsReporting.CrsReportBase.CrbCpCust TO CE.CrsReporting.CrsReportBase.CrbAccReserved1
                R.CRB.NEW<YY> = ''
            NEXT YY

            TOTAL.RES.CP = DCOUNT(TAX.RES.ARRAY<2,TAX.RES.POS1>,@SM)

            FOR RES.CP.CNT = 1 TO TOTAL.RES.CP
                LOCATE TAX.RES.ARRAY<2,TAX.RES.POS1,RES.CP.CNT> IN R.CRB<CE.CrsReporting.CrsReportBase.CrbCpCust,1> SETTING CP.POS THEN
                    FOR FLD.CNT = CE.CrsReporting.CrsReportBase.CrbCpCust TO CE.CrsReporting.CrsReportBase.CrbAccReserved1
                        BEGIN CASE
                            CASE FLD.CNT = CE.CrsReporting.CrsReportBase.CrbCpCustTin
                                R.CRB.NEW<FLD.CNT,-1> = TAX.RES.ARRAY<3,TAX.RES.POS1,RES.CP.CNT>

                            CASE FLD.CNT = CE.CrsReporting.CrsReportBase.CrbCpTinCountry
                                R.CRB.NEW<FLD.CNT,-1> = TAX.RES.ARRAY<1,TAX.RES.POS1>

                            CASE 1
                                R.CRB.NEW<FLD.CNT,-1> = R.CRB<FLD.CNT,CP.POS>

                        END CASE
                    NEXT FLD.CNT
                END
            NEXT RES.CP.CNT
            R.CRB.NEW<CE.CrsReporting.CrsReportBase.CrbReportingJurisdiction> = TAX.RES.ARRAY<1,TAX.RES.POS1>
            R.CRB.NEW<CE.CrsReporting.CrsReportBase.CrbTinCountry> = R.CRB.NEW<CE.CrsReporting.CrsReportBase.CrbReportingJurisdiction>
            R.CRB.NEW<CE.CrsReporting.CrsReportBase.CrbTinCode> = '#NTA001#'
            ID.CRB.NEW = KEY.REPORT.BASE:'-CP-':R.CRB.NEW<CE.CrsReporting.CrsReportBase.CrbReportingJurisdiction>
            R.CRS.REPORT.BASE.NEW = R.CRB.NEW
            GOSUB UpdateMessageRef
            R.CRB.NEW = R.CRS.REPORT.BASE.NEW
            IF ACTION EQ "AMEND" THEN
                LOCATE ID.CRB.NEW IN KeyList SETTING POS THEN
                    DEL KeyList<POS>
                END
            END
            CE.CrsReporting.CrsReportBase.Write(ID.CRB.NEW,R.CRB.NEW)
        END
    NEXT REM.RT.CNT

RETURN

*-----------------------------------------------------------------------------------
*** <region name= UpdateMessageRef>
*** <desc> update msg.ref.id and account.ref</desc>

*** </region>

UpdateMessageRef:
   
    UNIQUE.TIME = ''
    EB.API.AllocateUniqueTime(UNIQUE.TIME)
    UNIQUE.TIME=FIELD(UNIQUE.TIME,'.',1):FIELD(UNIQUE.TIME,'.',2)
    JULDATE = ''
    GregorianDate = EB.SystemTables.getRDates(EB.Utility.Dates.DatLastWorkingDay)
    EB.API.Juldate(GregorianDate, JULDATE)
*
;*read CRS.PARAMETER

    YERR = ''
    R.CRS.PARAMETER = ''
    CRS.PARAMETER.ID = EB.SystemTables.getIdCompany()
    R.CRS.PARAMETER = CD.Config.CrsParameter.CacheRead(CRS.PARAMETER.ID, YERR)


*;*update MSG.REF.ID and CORRECTED.MSG.REF.ID
*
    SEQ.NO  = 'LU':R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbReportingYear>:R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbReportingJurisdiction>:'_RF_':R.CRS.PARAMETER<CD.Config.CrsParameter.CdCpEin>:'_':JULDATE:UNIQUE.TIME

    
;*append seq.no for lux with msg ref
    
    IF ACTION EQ "AMEND" THEN
        RecId = 'LU-':CRS.REPORT.BASE.ID:'-':R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbReportingJurisdiction>:'-LU':I
        R.CRS.REPORT.BASE.LUX = CE.CrsReporting.CrsReportBase.CacheRead(RecId, Error)
        LUX.REFERENCE = FIELD(R.CRS.REPORT.BASE.LUX<CE.CrsReporting.CrsReportBase.CrbMsgRefId>,'*',2)
        R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbCrctdMsgRefId> = LUX.REFERENCE
        R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbMsgRefId> = R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbMsgRefId>['*',1,1]:'*':SEQ.NO

    END

    IF ACTION EQ "NEW" THEN
        R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbMsgRefId> = R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbMsgRefId>['*',1,1]:'*':SEQ.NO
    
    END

;*update ACCOUNT.REF
    
    TOT.ACT = DCOUNT(R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbAccount>,@VM)
    FOR J = 1 TO TOT.ACT
        UNIQUE.TIME = ''
        EB.API.AllocateUniqueTime(UNIQUE.TIME)
        UNIQUE.TIME=FIELD(UNIQUE.TIME,'.',1):FIELD(UNIQUE.TIME,'.',2)
        AV.SEQ.NO = 'LU':R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbReportingYear>:R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbReportingJurisdiction>:'_AR_':R.CRS.PARAMETER<CE.CrsReporting.CrsReportBase.CrbEin>:'_':JULDATE:UNIQUE.TIME
        R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbAccAccountRef,J> = AV.SEQ.NO
    NEXT J

RETURN

*** <region name= DeleteLuxReportBases>
*** <desc> </desc>

*** </region>
*-----------------------------------------------------------------------------

DeleteLuxReportBases:
    
    FnReportBase = 'F.CRS.REPORT.BASE'
    FReportBase = ''
    EB.DataAccess.Opf(FnReportBase, FReportBase)
    SelCmd = 'SELECT ':FnReportBase:' WITH @ID LIKE LU-':CRS.REPORT.BASE.ID:'...'
    EB.DataAccess.Readlist(SelCmd, KeyList,'', '', '')
    IF ACTION EQ "DELETE" THEN
        TOT.REP.JR = DCOUNT(KeyList,@FM)
        FOR J = 1 TO TOT.REP.JR
            EB.DataAccess.FDelete(FnReportBase,KeyList<J>)
        NEXT J
    END
RETURN

*------------------------------------------------------------------------------
END
