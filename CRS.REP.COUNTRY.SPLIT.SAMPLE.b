* @ValidationCode : MjotMTg3MDEzNTIwNTpDcDEyNTI6MTU4MzMxNDk1Mjg1MTpoYWFyaW5pcjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MTEuMjAxOTEwMTYtMDM1NDotMTotMQ==
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
SUBROUTINE CRS.REP.COUNTRY.SPLIT.SAMPLE(CRS.REPORT.BASE.ID,ACTION,R.CRS.REPORT.BASE,SPARE.1,SPARE.2,SPARE.3)
*-----------------------------------------------------------------------------
* Description    : CRS.REP.COUNTRY.SPLIT is a new api that will split and amend the report base content as required for Guernsey.
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
    $USING EB.Service
    $USING EB.DataAccess
    $USING CE.CrsReporting
    $USING AC.AccountOpening
    $USING CD.CustomerIdentification

    R.CRS.REPORT.BASE.NEW = ''
    R.CRS.REPORT.BASE.NEW = R.CRS.REPORT.BASE
    
    BEGIN CASE
        CASE ACTION EQ 'NEW'
            GOSUB REMOVE.ENTITY.ACCOUNTS   ;* Creating a new CRS.REPORT.BASE record
            GOSUB PROCESS.JURISDICTION
        CASE ACTION EQ 'DELETE'
            GOSUB DELETE.RJ.REPORT.BASES ;* Deleting a CRS.REPORT.BASE record
        CASE ACTION EQ 'AMEND'
            GOSUB DELETE.RJ.REPORT.BASES
            GOSUB REMOVE.ENTITY.ACCOUNTS ;* Amending a CRS.REPORT.BASE record
            GOSUB PROCESS.JURISDICTION
            IF KeyList NE '' THEN
                ListCount = DCOUNT(KeyList,@FM)
                FOR DelCnt = 1 TO ListCount
                    EB.DataAccess.FDelete('F.CRS.REPORT.BASE',KeyList<DelCnt>)
                NEXT DelCnt
            END
    END CASE

*---------------------------------------------------------------------------------------
REMOVE.ENTITY.ACCOUNTS:
*-----------------------------------------------------------------------------------------
* Accounts of related customers must be reported only in the entity record and should not be repeated in CP report base record

    TOTAL.ACCOUNT = DCOUNT(R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbAccount>,@VM)
    FOR ACC.CNT = 1 TO TOTAL.ACCOUNT
        ACC.ID = R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbAccount,ACC.CNT>
        ACCOUNT.ID = FIELD(ACC.ID,"*",1) ;*should return acc.no in case of closed accounts
        ACC.ERR = '' ; R.ACCOUNT = ''
        R.ACCOUNT = AC.AccountOpening.Account.Read(ACCOUNT.ID, ACC.ERR)
        IF ACC.ERR EQ '' THEN
            CUS.ID = FIELD(CRS.REPORT.BASE.ID,".",1)
            IF R.ACCOUNT<AC.AccountOpening.Account.Customer> NE CUS.ID THEN
                R.CRS.CUSTOMER.SUPPLEMENTARY.INFO = ''
                CCSI.ERR = ''
                R.CRS.CUSTOMER.SUPPLEMENTARY.INFO = CD.CustomerIdentification.CrsCustSuppInfo.Read(R.ACCOUNT<AC.AccountOpening.Account.Customer>, CCSI.ERR)
                LOCATE CUS.ID IN R.CRS.CUSTOMER.SUPPLEMENTARY.INFO<CD.CustomerIdentification.CrsCustSuppInfo.CdSiCustomerId,1> SETTING POS THEN
                    LOCATE ACCOUNT.ID IN R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbAccount,1> SETTING AC.POS THEN
                        FOR YY=CE.CrsReporting.CrsReportBase.CrbAccount TO CE.CrsReporting.CrsReportBase.CrbConRcyPymtAmt
                            DEL R.CRS.REPORT.BASE.NEW<YY,AC.POS>
                        NEXT YY
                    END
                END
            END
        END
    NEXT ACC.CNT

RETURN

*-----------------------------------------------------------------------------
PROCESS.JURISDICTION:
*-----------------------------------------------------------------------------
    
    LST.CRS = ''
    TOT.REP.JR = DCOUNT(R.CRS.REPORT.BASE<CE.CrsReporting.CrsReportBase.CrbReportingJurisdiction>,@VM)
    FOR I = 1 TO TOT.REP.JR
        R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbReportingJurisdiction> = R.CRS.REPORT.BASE<CE.CrsReporting.CrsReportBase.CrbReportingJurisdiction,I>
        R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbCrsStatus> = R.CRS.REPORT.BASE<CE.CrsReporting.CrsReportBase.CrbCrsStatus,I>
        
        IF R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbAcctHolderType> = 'CRS102' THEN
            R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbAcctHolderType> = ''     ;* Not required for Guernsey
        END
        
        TOTAL.ACCOUNT = DCOUNT(R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbAccount>,@VM)
        FOR ACC.CTR = 1 TO TOTAL.ACCOUNT
            ACC.ID = R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbAccount,ACC.CTR>
            ACCOUNT.ID = FIELD(ACC.ID,"*",1) ;*should return acc.no in case of closed accounts
            R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbAccAccountRef,ACC.CTR> = 'GG':FIELD(CRS.REPORT.BASE.ID,'.',1):ACCOUNT.ID:R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbReportingJurisdiction>:FIELD(TIMESTAMP(),'.',1):FIELD(TIMESTAMP(),'.',2)
        NEXT ACC.CTR
    
        KEY.CRB.NEW = 'RJ-':CRS.REPORT.BASE.ID:'-':R.CRS.REPORT.BASE.NEW<CE.CrsReporting.CrsReportBase.CrbReportingJurisdiction>:'-JU':I
        IF ACTION EQ "AMEND" THEN
            LOCATE KEY.CRB.NEW IN KeyList SETTING POS THEN
                DEL KeyList<POS>
            END
        END
        CE.CrsReporting.CrsReportBase.Write(KEY.CRB.NEW,R.CRS.REPORT.BASE.NEW)
    NEXT I

RETURN

*--------------------------------------------------------------------------------------
DELETE.RJ.REPORT.BASES:
*--------------------------------------------------------------------------------------

    FnReportBase = 'F.CRS.REPORT.BASE'
    FReportBase = ''
    EB.DataAccess.Opf(FnReportBase, FReportBase)
    SelCmd = 'SELECT ':FnReportBase:' WITH @ID LIKE RJ-':CRS.REPORT.BASE.ID:'...'
    EB.DataAccess.Readlist(SelCmd, KeyList,'', '', '')
    IF ACTION EQ "DELETE" THEN
        TOT.REP.JR = DCOUNT(KeyList,@FM)
        FOR J = 1 TO TOT.REP.JR
            EB.DataAccess.FDelete(FnReportBase,KeyList<J>)
        NEXT J
    END
   
RETURN

END
