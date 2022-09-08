* @ValidationCode : MjoxMjY0ODczOTQ4OkNwMTI1MjoxNTg0NjE1NTUxMDQyOnJ2YXJhZGhhcmFqYW46MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMy4wOjkwOTo1NDQ=
* @ValidationInfo : Timestamp         : 19 Mar 2020 16:29:11
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rvaradharajan
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 544/909 (59.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE SC.SccEventNotification
SUBROUTINE SC.OFS.SEEV036.MAPPING
*-----------------------------------------------------------------------------
* Modification History :
*
* 09/01/17 - Enhancement-1545934/Sub-Enhancement-1957585
*            Task:1957590
*            MT566 MX Post process xml
*
* 10/01/17 - Enhancement-1545934/Sub-Enhancement-1957599
*            Task:1957603
*            MT566 MX Mapping
*
* 10/02/17 - Enhancement-1545934/Defect:2015105,Task:2015190
*            Stock reconciliation not performed for STOCK.CASH diary
*            when cash received first and then stock
*
* 15/05/2018 - Task - 2589571
*             changes related to SC.CA.ERROR.LOG id based on field CA.LOG.ID of SC.CA.PARAMETER - DIARY
*
* 03/02/2020 - Enhancement 3568228 / Task 3569215
*            Changing reference of routines that have been moved from ST to CG
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.Utility
    $USING SC.SccConfig
    $USING SC.ScoSecurityMasterMaintenance
    $USING ST.CompanyCreation
    $USING SC.SccEventCapture
    $USING SC.SctTaxes
    $USING EB.API
    $USING EB.Foundation
    $USING SC.STP
    $USING EB.Interface
    $USING SC.Config
    $USING EB.DataAccess
    $USING EB.Logging
    $USING ST.ExchangeRate
    $USING DE.Config
    $USING EB.Security
    $USING SC.SccEntitlements
    $USING DE.Inward
    $USING DE.ModelBank
    $USING DE.Outward
    $USING EB.Browser
    $USING EB.ErrorProcessing
    $USING SC.SccEventNotification

    GOSUB INITIALISATION
    GOSUB MAIN.PROCESSING
    GOSUB GENERATE.OFS

    $INSERT I_DAS.DIARY

RETURN
*** <region name= initialise>
*------------------------------------------------------------------------
INITIALISATION:

    R.SC.PRE.DIARY = ''
    EB.SystemTables.setEtext("")
    ID.INWARD = DE.Inward.getRKey() ;*Inward Deliver ID
    R.INWARD = ''
    R.SWIFT = '' ;*Not used
    MESSAGE.TYPE = 'SEEV036' ;*Randomly assigned
    R.DE.MESSAGE = ''
    OFS.MESSAGE = ''
    OFS.KEY = ''
    YERR=''
    DE.MSG.FLAG = ''

    GOSUB MX.PROCESS          ;*Convert the SEEV036 MX message to MT 566 message

    R.DIARY = ''
    ERR.DET = ''
    WARN.DET = ''
*
    R.CA.PARAMETER = ''
    R.CA.PARAMETER = SC.SccConfig.CaParameter.CacheRead('DIARY', '')
    TOLERANCE.PCT = R.CA.PARAMETER<SC.SccConfig.CaParameter.ScCaTolerancePct>
    TOLERANCE.CCY = R.CA.PARAMETER<SC.SccConfig.CaParameter.ScCaToleranceCcy>
    TOLERANCE.AMT = R.CA.PARAMETER<SC.SccConfig.CaParameter.ScCaToleranceAmt>

* fetch the version from SC.CA.PARAMETER to authorise the entitlement in case of client segrgated accounts
    R.ENT.CA.PARAMETER = ''
    R.ENT.CA.PARAMETER = SC.SccConfig.CaParameter.CacheRead('ENTITLEMENT','')
    ENT.VERSION = R.ENT.CA.PARAMETER<SC.SccConfig.CaParameter.ScCaOfsVersion>

    F.SC.PRE.DIARY.NAU = ''
    F.DIARY.NAU = ''
    R.DIARY.TYPE = ''

    TRUE = 1
    FALSE = 0

    ER = ''
    R.SC.PARAMETER = ''
    ST.CompanyCreation.EbReadParameter('F.SC.PARAMETER','N','',R.SC.PARAMETER,'','',ER)
* checks if corporate action events involve segregated account processing
    SEGREGATED.ACCOUNT.PROCESSING = R.SC.PARAMETER<SC.Config.Parameter.ParamSegregatedAcc>
*
    RECONCILIATION.PENDING = ''
    UNBLOCK.CODE = ''   ;* remove this during unblock of MT566 authorisation without MT564

* Initialise necessary variables here related to changes in SC.CA.ERROR.LOG id.
    CA.LOG.ID = ''
    TXN.ID = ''
    CORPREF = ''
    DEPO.ID = ''
    SM.ID = ''
    LOG.ID.FORMAT = ''
    CALOG.WITH.SUBACC = ''
    CALOG.WITHOUT.SUBACC = ''
    
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name = MessageProcessing>
MAIN.PROCESSING:


    CONVERT ',' TO '.' IN R.INWARD
*SLNARAYANNAN    CONVERT @SM TO @VM IN R.INWARD
    GOSUB GET.REFERENCE       ;*Get corp and Seme reference

    GOSUB GET.RATE.DATE.AMT   ;*Get rate,date and amount details from message
    GOSUB GET.EVENT.INDICATOR ;* Get the event type from CAEV tag

    GOSUB GET.SECURITY.MASTER ;* Determine security code
    GOSUB SECMOVE.PSTA.PROCESS

    GOSUB GET.QUANTITY        ;*Get eligible and loan quantity
    DIARY.ID = ''
    GOSUB GET.DEPOSITORY      ;*Get depository from safe account
    COMMON.ERRORS = ERR.DET   ;* Common errors that are to be applied for all Diary
    COMMON.WARNINGS = WARN.DET          ;* Common warnings that are to be applied for all Diary

    ERR.DET = ''    ;* Re-initialise to assign specific errors
    WARN.DET = ''   ;* Re-initialise to assign specific warnings
    GOSUB CREATE.DIARY        ;*Diary creation process

RETURN

********************
GET.SECURITY.MASTER:
*************************
    IDENT.SECURITY = ''
* SWIFT field 35B Identification of Securities
    FIND.ALTER.IDX = FALSE
    FIND.FILE = FALSE
    INDEX.NAME = 'I.S.I.N.'
    SECURITY.NO = ''
    ISIN.POS = DCOUNT(R.INWARD<12>,@VM)
    IF NOT(ISIN.POS) THEN
        ISIN.POS = 1
    END
    FOR ISIN.CNT = 1 TO ISIN.POS
        IF R.INWARD<12,ISIN.CNT>[1,4] = 'ISIN' THEN
            IDENT.SECURITY = R.INWARD<12,ISIN.CNT>[1,25]
        END ELSE
            IDENT.SECURITY = R.INWARD<12,ISIN.CNT>
        END
        IF IDENT.SECURITY THEN
            ISIN.CNT = ISIN.POS + 1
        END
    NEXT ISIN.CNT
    GOSUB READ.SECURITY.MASTER
    ORIG.SEC.LIST = R.CONCAT.REC1

    IF DCOUNT(ORIG.SEC.LIST,@FM) GT 1 THEN
        WARN.DET<1,1,-1> = 'MULTIPLE SECURITY FOR ISIN ':IDENT.SECURITY
    END

RETURN
********************
READ.SECURITY.MASTER:
********************
* Get security number from security.master index
* input  - SECURITY.ISIN - 'ISIN US1730341096'
* output - SECURITY.NO   - '000109-000'

    IF IDENT.SECURITY[1,4] EQ 'ISIN' THEN
        R.ALTERNATE.INDEX = ''
        tmp.ETEXT = EB.SystemTables.getEtext()
        R.ALTERNATE.INDEX = SC.ScoSecurityMasterMaintenance.AlternateIndex.Read('SYSTEM', tmp.ETEXT)
        EB.SystemTables.setEtext(tmp.ETEXT)
        IF EB.SystemTables.getEtext() THEN
            EB.SystemTables.setEtext('ALTERNATE.INDEX NOT SETUP')
            GOSUB WRITE.OFS.LOG
        END ELSE
            FIND.FILE = TRUE
            FIND INDEX.NAME IN R.ALTERNATE.INDEX<SC.ScoSecurityMasterMaintenance.AlternateIndex.AiFieldName> SETTING FMC,VMC THEN
                CONCAT.FILE.NAME = R.ALTERNATE.INDEX<SC.ScoSecurityMasterMaintenance.AlternateIndex.AiConcatFileName,VMC>
                SECURITY.ID = '' ; EB.SystemTables.setEtext('')
                IF IDENT.SECURITY[1,4] = "ISIN" THEN
                    IDENT.SECURITY = IDENT.SECURITY[6,12]
                END
                R.CONCAT.REC1 = '' ; YERR1 = ''
                CONCAT.ID = IDENT.SECURITY
                CONCAT.FILE.NAME = 'F.' :CONCAT.FILE.NAME
                EB.DataAccess.FRead(CONCAT.FILE.NAME,CONCAT.ID,R.CONCAT.REC1,'',YERR1)
                IF EB.SystemTables.getEtext() = '' THEN
                    SECURITY.NO = R.CONCAT.REC1<1>
                END ELSE
                    EB.SystemTables.setEtext('SECURITY NOT FOUND VIA ISIN CODE')
                    GOSUB WRITE.OFS.LOG
                END
                FIND.ALTER.IDX = TRUE
            END ELSE
                EB.SystemTables.setEtext('INDEX NOT FOUND IN SYSTEM RECORD')
                GOSUB WRITE.OFS.LOG
            END
        END
    END

RETURN
*** </region>

*** <region name = DiaryUpdate>

*******************
CREATE.OFS.RECORD:
***********************
    I.COUNT = '' ; SAVE.OFS.KEY = ''
    FOR I.COUNT = 1 TO NO.OF.REC
        ERR.DET = COMMON.ERRORS         ;* Assign common errors for each Diary
        WARN.DET = COMMON.WARNINGS      ;* Assign common warnings for each Diary
        R.DIARY = ''
        IF SC.PRE.KEY<I.COUNT> EQ '@@@' THEN      ;* Diary ID not found
            ERR.DET<1,1,-1> = 'DIARY REFERENCE MISSING'
            CA.LOG.ID = PRE.DIARY.LIST<I.COUNT>
            GOSUB UPDATE.CA.LOG         ;* Update log using Pre diary ID
* Determine securities that are processed by reading SC.PRE.DIARY
            R.PRE.DIARY = ''
            PR.ERR = ''
            R.PRE.DIARY = SC.SccEventNotification.PreDiary.Read(CA.LOG.ID, PR.ERR)
            IF PR.ERR THEN    ;* Read INAU pre diary
                R.PRE.DIARY = SC.SccEventNotification.PreDiary.ReadNau(CA.LOG.ID, PR.ERR)
            END
            SECURITY.NO = R.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdSecurityNo>

        END ELSE    ;* Process Diary
            GOSUB COMPARE.DIARY         ;*Compare message values with Diary
        END
* Compare data and authorise

        GOSUB UPDATE.CA.LOG

        GOSUB CREATE.SC.ENT.AUTHORISE   ;*Create SC.ENT.AUTHORISE record if no errors and no warnings
    NEXT I.COUNT
*

RETURN
*** </region>

*** <region name =logUpdate>

WRITE.OFS.LOG:

* Log messages either to T24 level log file or TAFC level log file depends on C$USE.T24.LOG common

    IF EB.Interface.getOfsSourceRec()<EB.Interface.OfsSource.OfsSrcLogDetailLevel> = 'FULL' THEN
        IF EB.SystemTables.getCUseTTwoFouLog() THEN         ;* If T24 level logging is enabled
            tmp.ETEXT = EB.SystemTables.getEtext()
            tmp.OFS.LOG = EB.Interface.getOfsLogFileName()
            WRITESEQ tmp.ETEXT TO tmp.OFS.LOG ELSE          ;* write to T24 log file directory
                NULL
                EB.Interface.setOfsLogFileName(tmp.OFS.LOG)
            END
        END ELSE    ;* else, TAFC logging enabled
            Category = R.DE.MESSAGE<DE.Config.Message.MsgOfsSource>:'.LOG'
*        tmp.ETEXT = EB.SystemTables.getEtext()
*        Logger(Category, TAFC_LOG_ERROR, tmp.ETEXT)
*        EB.SystemTables.setEtext(tmp.ETEXT)
        END
    END
*
    YERR = EB.SystemTables.getEtext()
    ERR.DET<1,1,-1> = EB.SystemTables.getEtext()
RETURN



***************
UPDATE.CA.LOG:
****************
    R.CA.ERROR = ''
    IF NOT(R.CA.PARAMETER<SC.SccConfig.CaParameter.ScCaStp>) THEN
        RETURN
    END

    IF NOT(R.DIARY) THEN
        ERR.DET<1,1,-1> = 'Entitlement Details not updated in Diary'
    END

    IF R.DIARY THEN
        LOCATE R.DIARY<SC.SccEventCapture.Diary.DiaSecurityNo> IN ORIG.SEC.LIST<1> SETTING SEC.POS THEN
            NULL
        END ELSE
            ERR.DET<1,1,-1> = 'SECURITY DOES NOT MATCH ISIN' :IDENT.SECURITY
        END

    END

    LOG.ERR = ''
    SC.SccConfig.ScCaErrorLogLock(CA.LOG.ID,R.CA.ERROR,LOG.ERR,'','')
    IF LOG.ERR THEN
        R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerEventType> = R.DIARY<SC.SccEventCapture.Diary.DiaEventType>  ;* Update event type
        R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerDepository> = R.DIARY<SC.SccEventCapture.Diary.DiaDepository>          ;* Depository
        R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerStp> = R.DIARY<SC.SccEventCapture.Diary.DiaStp>    ;* Whether full STP
        R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerLoan> = R.DIARY<SC.SccEventCapture.Diary.DiaLoan>  ;* Whether lent or non lent
        R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerCurrNo> = '1'
        R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerInputter> = 'SY_':EB.SystemTables.getTno():'_':EB.SystemTables.getOperator()
        X.DATE = OCONV(DATE(),"D-")
        DATE.TIME = X.DATE[9,2]:X.DATE[1,2]:X.DATE[4,2]:TIMEDATE()[1,2]:TIMEDATE()[4,2]
        R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerDateTime> = DATE.TIME
        R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerAuthoriser> = 'SY_':EB.SystemTables.getTno():'_':EB.SystemTables.getOperator()
        R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerCoCode> = EB.SystemTables.getIdCompany()
        R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerDeptCode> = EB.SystemTables.getRUser()<EB.Security.User.UseDepartmentCode>
    END
    MV.POS = DCOUNT(R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerDelivRef>,@VM) + 1
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerDelivRef,MV.POS> = ID.INWARD       ;* Inward delivery id
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerReceivingDate,MV.POS> = EB.SystemTables.getToday()     ;* Message receiving date
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerMessageType,MV.POS> = MESSAGE.TYPE        ;* message
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerSemeRef,MV.POS> = SOURCE.REF       ;* Source reference
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerCorpRef,MV.POS> = LINK.REF         ;* Corp action ref
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerErrors,MV.POS> = ERR.DET ;* Errors
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerWarnings,MV.POS> = WARN.DET        ;* warnings
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerSecurityNo,MV.POS> = SECURITY.NO   ;* security number in message
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerPayDate,MV.POS> = PAY.DATE         ;* Pay date
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerExDate,MV.POS> = R.DIARY<SC.SccEventCapture.Diary.DiaExDate>     ;* Ex date
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerGrossCash,MV.POS> = GROSS.AMT      ;* Gross cash
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerNetCash,MV.POS> = NET.AMT          ;* Net cash
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerQuantity,MV.POS> = ELIG.QTY        ;* Eligible quantity
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerStage,MV.POS> = 'CONF'   ;* Processing stage
*    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerPstaCash,MV.POS> = R.DIARY<SC.SccEventCapture.Diary.DiaTotalCashCcy,DEP.POS>:PSTA.AMT
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerPstaCash,MV.POS> = PSTA.CCY:PSTA.AMT
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerPstaQty,MV.POS> = LOWER(PSTA.QTY)
* If there are multiple securities update ISIN number into new security field as actual security cannot be determined
    IF MULTIPLE.SECURITY.UNDER.ISIN THEN
        R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerNewSecurity,MV.POS> = LOWER(SECMOVE.ISIN.LIST)
    END ELSE
*   In case of conversion,different ISIN will be there so the variable will be delimited by value marker. Hence convert to sub value marker

        R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerNewSecurity,MV.POS> = LOWER(SECMOVE.SEC.LIST)      ;*
    END
*
    IF PSTA.AMT THEN          ;* Update total cash into log
* Maintain currency wise cash received from depository
        LOCATE PSTA.CCY IN R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerTotalCashCcy,1> SETTING LOG.CCY.POS ELSE
            LOG.CCY.POS = -1
        END
        R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerTotalCashCcy,LOG.CCY.POS> = PSTA.CCY
        R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerTotalCash,LOG.CCY.POS> = PSTA.AMT

* If confirmation not received for all the currency nostro payments then reconciliation is pending
        IF R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DryCash> EQ 'Y' AND R.DIARY<SC.SccEventCapture.Diary.DiaDepDivCcy,DEP.POS> AND DCOUNT(R.DIARY<SC.SccEventCapture.Diary.DiaDepDivCcy,DEP.POS>,@SM) NE DCOUNT(R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerTotalCashCcy>,@VM) THEN
            RECONCILIATION.PENDING = 1
        END
    END
    IF MULTIPLE.SECURITY.UNDER.ISIN THEN          ;* If multiple securities under ISIN, Maintain under ISIN so that reconciliation will not match
        SECMOVE.SEC.LIST = SECMOVE.ISIN.LIST
    END

    IF PSTA.QTY THEN          ;* Update nominal and security into log
        NO.OF.SEC = DCOUNT(PSTA.QTY,@VM)
        FOR SEC.CNT = 1 TO NO.OF.SEC
            LOCATE SECMOVE.SEC.LIST<1,SEC.CNT> IN R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerTotSecurity,1> SETTING POS THEN
                NULL
            END ELSE
                POS = SEC.CNT
                R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerTotSecurity,-1> = SECMOVE.SEC.LIST<1,SEC.CNT>
            END
            IF PSTA.QTY<1,SEC.CNT> LT 0 THEN
                R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerTotalDebit,POS> = PSTA.QTY<1,SEC.CNT>
            END ELSE
                R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerTotalCredit,POS> = PSTA.QTY<1,SEC.CNT>
            END
        NEXT SEC.CNT
    END
*
    COUNT.VM = DCOUNT(R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerErrors>,@VM)
    BEGIN CASE
        CASE R.INWARD<SC.STP.DeIMsgFivFivx.IScFunction> EQ 'REVR'         ;* Update status as revr
            R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerStatus,MV.POS> = 'REVR'

        CASE R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerErrors><1,COUNT.VM> ;* update status as errors
            R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerStatus,MV.POS> = 'ERR'

        CASE R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerWarnings><1,COUNT.VM>         ;* update status as warnings
            R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerStatus,MV.POS> = 'WARN'

        CASE 1          ;* If no errors encountered, Update ok
            IF RECONCILIATION.PENDING THEN  ;* If no errors but reconciliation started and still pending for other movements
                R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerStatus,MV.POS> = 'RECO'
            END ELSE
                R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerStatus,MV.POS> = 'OK'
            END
    END CASE

    FLUSH.IT = ''
    EB.Logging.LogWrite('F.SC.CA.ERROR.LOG',CA.LOG.ID,R.CA.ERROR,FLUSH.IT)

RETURN

*** </region>

*****************************************************************************************
*** <region name = SECMOVE.PSTA.PROCESS>
SECMOVE.PSTA.PROCESS:

    GOSUB GET.SECMOVE.SECURITY
    GOSUB GET.PSTA.QTY

RETURN
*** </region>

*************************************************************************************************
*** <region name = GET.SECMOVE.SECURITY>
GET.SECMOVE.SECURITY:

    SECMOVE.SEC.LIST = ''
    SECMOVE.ISIN.LIST = ''
    MULTIPLE.SECURITY.UNDER.ISIN = ''
    NO.OF.SEC = DCOUNT(R.INWARD<19>,@VM)
    ISIN.CTR = 0
    FOR ISIN.CNT = 1 TO NO.OF.SEC
        IF R.INWARD<19,ISIN.CNT>[1,4] = 'ISIN' THEN
            ISIN.CTR += 1
            IDENT.SECURITY = R.INWARD<19,ISIN.CNT>[1,25]
            SECMOVE.ISIN.LIST<1,-1> = IDENT.SECURITY        ;* Store list of ISIN numbers in SECMOVE block
            GOSUB READ.SECURITY.MASTER
            CONVERT @FM TO @SM IN R.CONCAT.REC1
            SECMOVE.SEC.LIST<1,ISIN.CTR,-1> = R.CONCAT.REC1 ;* Store corresponding security numbers
            IF DCOUNT(SECMOVE.SEC.LIST<1,ISIN.CNT>,@SM) GT 1 THEN     ;* iF multiple security under ISIN
                MULTIPLE.SECURITY.UNDER.ISIN = 1
                WARN.DET<1,1,-1> = 'MULTIPLE SECURITY FOR ISIN ':IDENT.SECURITY ;* Report warnings
            END
        END
    NEXT ISIN.CNT

RETURN
*** <region>
*****************************************************************************************************
*** <region name = GET.PSTA.QTY>
GET.PSTA.QTY:

    PSTA.QTY = ''
    QTY.COUNT = DCOUNT(R.INWARD<20>,@VM)
    FOR I = 1 TO QTY.COUNT
        IF R.INWARD<20,I> EQ 'PSTA' THEN
            PSTA.QTY<1,-1> = R.INWARD<21,I>
        END
    NEXT I

    QTY.COUNT = DCOUNT(R.INWARD<30>,@VM)          ;* Get the count of credit debit indicators
    QTY.POS = 0
    FOR I = 1 TO QTY.COUNT
        IF FIELD(R.INWARD<30,I>,'//',2) EQ 'CRED' THEN      ;* If credit
            QTY.POS += 1
            PSTA.IDENT<1,QTY.POS> = 'CRED'
        END

        IF FIELD(R.INWARD<30,I>,'//',2) EQ 'DEBT' THEN      ;* If debit
            QTY.POS += 1
            PSTA.IDENT<1,QTY.POS> = 'DEBT'
            PSTA.QTY<1,QTY.POS> = PSTA.QTY<1,QTY.POS> * (-1)          ;* Make nominal as negative
        END
    NEXT I

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= GET.REFERENCE>
GET.REFERENCE:
*** <desc>Get corp and Seme reference </desc>
    REF = ''
    NO.REF = '' ; SOURCE.REF = '' ; LINK.REF = ''

    NO.REF = DCOUNT(R.INWARD<7>,@VM)    ;* Sender Reference
    FOR REF = 1 TO NO.REF
        BEGIN CASE
            CASE R.INWARD<7><1,REF> = "SEME"     ;* Get the sender reference
                SOURCE.REF = R.INWARD<8><1,REF>

            CASE R.INWARD<7><1,REF> = 'CORP'     ;* Get the corp reference
                LINK.REF = R.INWARD<8><1,REF>
        END CASE
    NEXT REF

RETURN

*** </region>

*-----------------------------------------------------------------------------

*** <region name= GET.RATE.DATE.AMT>
GET.RATE.DATE.AMT:
*** <desc>Get rate,date and amount details from message </desc>

    PSTA.AMT = ''
    PSTA.CCY = ''   ;*
    LOCATE 'PSTA' IN R.INWARD<24,1> SETTING POS THEN       ;* Custodian Amt
        PSTA.AMT = R.INWARD<25,POS>
    END

    PAY.DATE = ''
    LOCATE 'PAYD' IN R.INWARD<26,1> SETTING POS THEN       ;* Pay date
        PAY.DATE = R.INWARD<27,POS>
    END

    VALUE.DATE = ''
    LOCATE 'VALU' IN R.INWARD<26,1> SETTING POS THEN       ;* Value date
        VALUE.DATE = R.INWARD<27,POS>
    END

    TAX.RATE = ''

    LOCATE 'TAXR' IN R.INWARD<17,1> SETTING POS THEN       ;* Source tax rate
        TAX.RATE = R.INWARD<18,POS>
    END

    GROSS.AMT = ''
    LOCATE 'GRSS' IN R.INWARD<24,1> SETTING POS THEN       ;* Gross Amount from custodian
        GROSS.AMT = R.INWARD<25,POS>
    END

    NET.AMT = ''
    LOCATE 'NETT' IN R.INWARD<24,1> SETTING POS THEN       ;* Net amount from custodian
        NET.AMT = R.INWARD<25,POS>
    END
* RIGHTS S
    CAOP.INDICATOR = ''
    LOCATE 'CAOP' IN R.INWARD<15,1> SETTING CAOP.POS THEN
        CAOP.INDICATOR = R.INWARD<16,CAOP.POS>
    END
* RIGHTS E
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= GET.QUANTITY>
GET.QUANTITY:
*** <desc>Get eligible and loan quantity </desc>

* Check whether inward message pertains to Loan

    LOAN.INDICATOR = ''
    ELIG.POS = ''
    ELIG.QTY = ''
    LOCATE 'LOAN' IN R.INWARD<28,1> SETTING ELIG.POS THEN
        LOAN.INDICATOR = 1
    END ELSE
        LOCATE 'CONB' IN R.INWARD<28,1> SETTING ELIG.POS ELSE
            NULL    ;* Get confirmed quantity
        END
    END

    IF ELIG.POS THEN
        ELIG.QTY = R.INWARD<29,ELIG.POS>
    END

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= GET.DEPOSITORY>
GET.DEPOSITORY:
*** <desc>Get depository from safe account </desc>

    CONCAT.ID = ''
    CONC.ID = ''

* initialise the variables for segregated account processing
    SUB.ACCOUNT = ''
    CUST.SEC.SUB.ACCOUNT = ''
    PORTFOLIO.OR.CUSTOMER = ''

    CTR.COUNT = DCOUNT(R.INWARD<11>,@VM)
    FOR CTR = 1 TO CTR.COUNT
        IF FIELD(R.INWARD<11,CTR>,'//',1) EQ 'SAFE' THEN   ;* Get safe account
            CONC.ID = FIELD(R.INWARD<11,CTR>,"//",2)
            CTR = CTR.COUNT
        END
    NEXT CTR

* Read SC.STD.CLEARING and determine depository pertaining to the safe account otherwise, fetch depo in message
    R.STD.CLEARING = ''
    ER = ''
    ST.CompanyCreation.EbReadParameter('F.SC.STD.CLEARING','N','',R.STD.CLEARING,'','',ER)          ;* Read sc.sstd.clearing
    LOCATE CONC.ID IN R.STD.CLEARING<SC.Config.StdClearing.BsdSecDepotAc,1> SETTING CONC.POS THEN   ;* Locate for safekeep account
        CONC.ID.LIST<1,-1> = R.STD.CLEARING<SC.Config.StdClearing.BsdSecDepot,CONC.POS>   ;* Fetch Depo
        CONC.POS += 1
        LOOP
        WHILE CONC.POS        ;* Check whether same safekeep is linked to many depositories and get the list of depos
            LOCATE CONC.ID IN R.STD.CLEARING<SC.Config.StdClearing.BsdSecDepotAc,CONC.POS> SETTING CONC.POS THEN
                CONC.ID.LIST<1,-1> = R.STD.CLEARING<SC.Config.StdClearing.BsdSecDepot,CONC.POS>
                CONC.POS += 1
            END ELSE
                CONC.POS = ''
            END
        REPEAT
        DEPO.COUNT = DCOUNT(CONC.ID.LIST,@VM)
    END ELSE        ;* Depository in message is either customer number or All

* if segregated account processing, check whether the message is for omnibus or client segregated account
        SUB.ACC.EXT.ID = CONC.ID
        R.DE.I.HEADER = DE.Config.IHeader.Read(ID.INWARD,'')
        CONC.ID = R.DE.I.HEADER<DE.Config.IHeader.HdrCustomerNo>
        IF SEGREGATED.ACCOUNT.PROCESSING THEN
            SEG.CONCAT.ID = SUB.ACC.EXT.ID:'.':CONC.ID
            ERR = ''
            R.DEPO.SUB.ACC.CONCAT = ''
            R.DEPO.SUB.ACC.CONCAT = SC.Config.ScDepoSubAccConcat.Read(SEG.CONCAT.ID,ERR)
            IF NOT(ERR) THEN
* if omnibus, then fetch the sub account from the customer security record of DEPOSITORY
* by locating the sub account external id received from MT566 message
* SC.DEPO.SUB.ACC.CONCAT will have only the depository
                CUSTOMER.SEC.ID = R.DEPO.SUB.ACC.CONCAT<1>
                CS.ERR = ''
                R.CUSTOMER.SECURITY = ''
                R.CUSTOMER.SECURITY = SC.Config.CustomerSecurity.Read(CUSTOMER.SEC.ID, CS.ERR)
                LOCATE SUB.ACC.EXT.ID IN R.CUSTOMER.SECURITY<SC.Config.CustomerSecurity.CscSubAccExtId,1> SETTING SUB.ACC.POS THEN
                    CUST.SEC.SUB.ACCOUNT = R.CUSTOMER.SECURITY<SC.Config.CustomerSecurity.CscSubAccount,SUB.ACC.POS>
                    SUB.ACCOUNT = R.CUSTOMER.SECURITY<SC.Config.CustomerSecurity.CscSubAccount,SUB.ACC.POS>
                END
            END ELSE
* if client segregated, then fetch the sub account by reading the concat file
* SC.PORT.SUB.ACC.CONCAT will have portfolio and the sub account
                ERR = ''
                R.PORT.SUB.ACC.CONCAT = ''
                R.PORT.SUB.ACC.CONCAT = SC.Config.ScPortSubAccConcat.Read(SEG.CONCAT.ID,ERR)
                PORTFOLIO.OR.CUSTOMER = R.PORT.SUB.ACC.CONCAT<1,1>
                SUB.ACCOUNT = R.PORT.SUB.ACC.CONCAT<2,1>
            END
        END

        DEPO.COUNT = 1
        CONC.ID.LIST = CONC.ID
        IF NOT(NUM(CONC.ID)) THEN
            CONC.ID.LIST = 'ALL'
        END
    END
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= CREATE.DIARY>
CREATE.DIARY:
*** <desc>Diary creation process </desc>

    FOR DEPO.LOOP = 1 TO DEPO.COUNT     ;* Process Diary for each depo
        CONC.ID = CONC.ID.LIST<1,DEPO.LOOP>
        SC.PRE.KEY = ""
        CONCAT.ID = CONC.ID:'-':LINK.REF
        IF LOAN.INDICATOR THEN          ;* Add loan indicator to Id for lent position
            CONCAT.ID := '-LOAN'
        END
        R.CONCAT.REC = '' ; YERR2 = '' ; NO.OF.REC = ''
        R.CONCAT.REC = SC.SccEventNotification.MtFivSixFouReference.Read(CONCAT.ID, YERR2)

        NO.OF.REC = DCOUNT(R.CONCAT.REC,@FM)
        FOR X1 = 1 TO NO.OF.REC
            DIARY.ID = ''
            YERR1 = ''
            IF NOT(YERR2) THEN          ;* Get Diary id from Pre diary
                PRE.DIARY.ID = R.CONCAT.REC<1>
                R.LIVE.PRE.DIARY = SC.SccEventNotification.PreDiary.Read(PRE.DIARY.ID, YERR1)
                DIARY.ID = R.LIVE.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdDiaryId>
            END
            IF NOT(DIARY.ID) THEN
                DIARY.ID = '@@@'
            END
            SC.PRE.KEY<-1> = DIARY.ID   ;* assign diary id
            PRE.DIARY.LIST<-1> = PRE.DIARY.ID     ;* Maintain pre diary list to update log in case corresponding diary id is not found
        NEXT X1
        IF UNBLOCK.CODE THEN   ;* remove this during unblock of MT566 authorisation without MT564
            IF NOT(NO.OF.REC) THEN
;* Get the diary type by reading  SC.CON.SWIFT.CAEV file with caev qualifier fetched from the message
                tmp.ETEXT = EB.SystemTables.getEtext()
                R.SC.CON.SWIFT.CAEV = SC.SccEventCapture.ScConSwiftCaev.Read(EVENT.TYPE,tmp.ETEXT)
                EB.SystemTables.setEtext(tmp.ETEXT)
                IF EB.SystemTables.getEtext() THEN
                    EB.SystemTables.setEtext('DIARY.TYPE RECORD NOT FOUND FOR CA EVENT')
                    GOSUB WRITE.OFS.LOG
                END
;* incase where multiple diary types defined for same CAEV, then write in exception
                EVENT.TYPE.CNT = DCOUNT(R.SC.CON.SWIFT.CAEV,@FM)
                IF EVENT.TYPE.CNT GT 1 THEN
                    EB.SystemTables.setEtext('MULTIPLE DIARY TYPE FOR SAME CAEV')
                    GOSUB WRITE.OFS.LOG
                END ELSE
                    SEC.NO.LIST = DCOUNT(ORIG.SEC.LIST,@FM)     ;* get the security list
;* Determine diary record by selecting live diary file based on security.number, depository and diary type retreived from caev indicator
                    FOR SEC.LOOP = 1 TO SEC.NO.LIST
                        DIARY.LIST       = dasDiarySecurityNoPayDateEventTypeDepository
                        THE.ARGS         = ORIG.SEC.LIST<SEC.LOOP>
                        THE.ARGS<2>      = PAY.DATE                 ;* pay date
                        THE.ARGS<3>      = R.SC.CON.SWIFT.CAEV<1>   ;* diary type
                        THE.ARGS<4>      = CONC.ID                  ;* depository
                        EB.DataAccess.Das('DIARY', DIARY.LIST, THE.ARGS, "")
                        DIARY.LIST.CNT = DCOUNT(DIARY.LIST,@FM)
                        IF NOT(DIARY.LIST) OR DIARY.LIST.CNT GT 1 THEN
                            DIARY.LIST = '@@@'
                            PRE.DIARY.LIST<-1> = ID.INWARD:"-":ORIG.SEC.LIST<SEC.LOOP>
                        END ELSE
                            PRE.DIARY.LIST<-1> = " "
                        END
                        SC.PRE.KEY<-1> = DIARY.LIST         ;* add the list
                    NEXT SEC.LOOP
                END
                NO.OF.REC = DCOUNT(SC.PRE.KEY,@FM)          ;* set the diary list to NO.OF.REC to process for each diary
            END
        END
        SM.PENDING.LIST = ORIG.SEC.LIST
        IF NO.OF.REC THEN     ;* Process only if Pre diary is identified
            GOSUB CREATE.OFS.RECORD
        END
        NO.OF.SEC = DCOUNT(SM.PENDING.LIST,@FM)   ;* If no Pre Diary found in concat file
        FOR SEC.CNT = 1 TO NO.OF.SEC    ;* Update lOG file for securities not processed under ISIN
            CA.LOG.ID = CONCAT.ID:'-':SM.PENDING.LIST<SEC.CNT>
            GOSUB UPDATE.CA.LOG
        NEXT SEC.CNT
    NEXT DEPO.LOOP

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= COMPARE.DIARY>
COMPARE.DIARY:
*** <desc>Compare message values with Diary </desc>

    CA.LOG.ID = SC.PRE.KEY<I.COUNT>     ;* Set log id as DIary id
* Maintain log per sub account if 566 is received per segregated account
    IF SUB.ACCOUNT THEN
        CA.LOG.ID = CA.LOG.ID:'-':CONC.ID:'-':SUB.ACCOUNT
    END

    CALOG.WITH.SUBACC = ''
    CALOG.WITHOUT.SUBACC = ''
    TXN.ID = CA.LOG.ID                                                       ;* pass SC.PRE.DIARY id to SC.GET.LOG.ID routine
    CORPREF = LINK.REF                                                       ;* Pass Corp Reference
    DEPO.ID = CONC.ID                                                        ;* Pass Depo id.
* sub account is already initialised.
    SM.ID = ''                                                               ;* Reserved
    LOG.ID.FORMAT = R.CA.PARAMETER<SC.SccConfig.CaParameter.ScCaCaLogId>     ;* this holds either TXN.ID or CORP.REF from SC.CA.PARMAETER record for DIARY - pass it.
    SC.SccConfig.ScFormCaErrorLogId(TXN.ID, CORPREF, SUB.ACCOUNT, DEPO.ID, LOG.ID.FORMAT,SM.ID, CALOG.WITH.SUBACC, CALOG.WITHOUT.SUBACC) ;* call this routine to form the SC.CA.ERROR.LOG id.
    CA.LOG.ID = CALOG.WITH.SUBACC                                            ;* Id will be returned as either <Diaryid>-<Depo>-<Sub Account> or <Corp ref>-<Depo>-<Sub account>
    
    DIA.ER = ''
    R.DIARY = SC.SccEventCapture.Diary.Read(SC.PRE.KEY<I.COUNT>, DIA.ER)        ;* Read live Diary record
    IF NOT(R.DIARY.TYPE) THEN ;* Read Diary type only once
        DIA.TYP.ERR = ''
        R.DIARY.TYPE = SC.SccEventCapture.DiaryType.Read(R.DIARY<SC.SccEventCapture.Diary.DiaEventType>, DIA.TYP.ERR)
    END
*

    GOSUB GET.566.DET.FROM.LOG          ;*Get the log details updated during earlier 566
    SECURITY.NO = R.DIARY<SC.SccEventCapture.Diary.DiaSecurityNo>
    IF DIA.ER THEN  ;* Read Diary in exception
        R.DIARY.NAU = ''
        R.DIARY.NAU = SC.SccEventCapture.Diary.ReadNau(SC.PRE.KEY<I.COUNT>, DIA.ER)
        SECURITY.NO = R.DIARY.NAU<SC.SccEventCapture.Diary.DiaSecurityNo>
    END

    OPTION.NOMINAL = 0
    TOTAL.CASH = 0
    IF PAY.DATE AND PAY.DATE NE R.DIARY<SC.SccEventCapture.Diary.DiaPayDate> THEN         ;* If pay date does not match
        WARN.DET<1,1,-1> = 'PAY DATE DOES NOT MATCH WITH DIARY'
    END

    IF VALUE.DATE AND VALUE.DATE  NE R.DIARY<SC.SccEventCapture.Diary.DiaValueDate> THEN  ;* If value date does not match
        WARN.DET<1,1,-1> = 'VALUE DATE DOES NOT MATCH WITH DIARY'
    END

* Compare cash in message against Diary
    SAVE.PSTA.AMT = PSTA.AMT  ;* Save PSTA Amount arrived in message and restore it after current loop so as to update that only in log
    COUNT.PSTA = DCOUNT(PSTA.AMT.ARR,@VM)
    LOCATE CONC.ID IN R.DIARY<SC.SccEventCapture.Diary.DiaDepNo,1> SETTING DEP.POS THEN ;* Locate Depo - To store MV position of this depository
    END
    FOR PS = 1 TO COUNT.PSTA
        PSTA.AMT = PSTA.AMT.ARR<1,PS>
        GOSUB SEGREGATED.ACC.PROCESSING ;* This para will update details temporarily into Diary to perform matching process
*
        GOSUB MULTI.CCY.PROCESSING      ;* This para will  be used as pre process for multi ccy reconciliation
        OPTION.NOMINAL = SUM(R.DIARY<SC.SccEventCapture.Diary.DiaOptionNominal>)      ;* Get nominal
        TOTAL.CASH = R.DIARY<SC.SccEventCapture.Diary.DiaTotalCash,DEP.POS> ;* Get cash
        IF OPTION.NOMINAL NE ELIG.QTY THEN        ;* Check whether option nominal matches with message
            ERR.DET<1,1,-1> = 'DIARY POSITION = ':OPTION.NOMINAL:' CUSTODIAN POSITION = ':ELIG.QTY
        END

        DIARY.CCY = R.DIARY<SC.SccEventCapture.Diary.DiaTotalCashCcy,DEP.POS>

* Apply tolerance and check whether cash in Diary is matching with message
        IF R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DryTolerancePct> THEN      ;* Check for tolerance percent in Diary type
            TOLERANCE.PCT = R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DryTolerancePct>    ;* assign tolerance percent
        END

        IF R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DryToleranceCcy> THEN      ;* check for tolerance ccy and amount in diary type
            TOLERANCE.CCY = R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DryToleranceCcy>
            TOLERANCE.AMT = R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DryToleranceAmt>
        END

        IF TOLERANCE.PCT THEN ;* If tolerance percentage is set
            TOLERANCE.AMT = TOTAL.CASH * TOLERANCE.PCT/100  ;* Apply tolerance percent
            EB.Foundation.ScFormatCcyAmt(R.DIARY<SC.SccEventCapture.Diary.DiaTotalCashCcy,DEP.POS>, TOLERANCE.AMT)      ;* Format amount
        END ELSE    ;* Check for tolerance amount
            LOCATE DIARY.CCY IN TOLERANCE.CCY<1,1> SETTING CCY.POS THEN         ;* If tolerance is set for currency
                TOLERANCE.AMT = TOLERANCE.AMT<1,CCY.POS>    ;* Get tolerance amount of currency
            END
        END

        IF NOT(NUM(PSTA.AMT[1,3])) THEN ;* If currency
            PSTA.CCY = PSTA.AMT[1,3]    ;* Extract currency
            PSTA.AMT = PSTA.AMT[4,18]   ;* Extract amount
            IF PSTA.CCY NE R.DIARY<SC.SccEventCapture.Diary.DiaTotalCashCcy,DEP.POS> THEN ;* If currency is different
                IF R.DIARY<SC.SccEventCapture.Diary.DiaExchRate> THEN ;*For Diaries with Restricted Currencies, Exchange Rate from Diary should be used
                    EXCH.RATE = R.DIARY<SC.SccEventCapture.Diary.DiaExchRate>
                END ELSE
                    EXCH.RATE = ''
                END
                Y2 = ''
                ST.ExchangeRate.Exchrate('1',PSTA.CCY,PSTA.AMT,DIARY.CCY,Y2,'',EXCH.RATE,'','','')  ;* Convert to Diary currency
                PSTA.AMT = Y2
            END
        END

        IF PSTA.AMT NE '' AND ABS(TOTAL.CASH - PSTA.AMT) AND ABS(TOTAL.CASH - PSTA.AMT) GT TOLERANCE.AMT THEN ;* Raise error if amount is non-zero & is greater than tolerance
            ERR.DET<1,1,-1> = 'DIARY CASH = ':TOTAL.CASH:', CUSTODIAN CASH = ':PSTA.AMT:', TOLERANCE = ':DIARY.CCY:TOLERANCE.AMT
        END

        IF TAX.RATE AND R.DIARY<SC.SccEventCapture.Diary.DiaSourceTaxPerc> AND TAX.RATE NE R.DIARY<SC.SccEventCapture.Diary.DiaSourceTaxPerc> THEN
            WARN.DET<1,1,-1> = 'DIARY TAX = ':R.DIARY<SC.SccEventCapture.Diary.DiaSourceTaxPerc>:', CUSTODIAN TAX = ':TAX.RATE
        END

        OTHER.WARNING = 0
        IF WARN.DET THEN
            OTHER.WARNING = 1
        END

        IF PSTA.AMT NE '' AND ABS(TOTAL.CASH - PSTA.AMT) AND ABS(TOTAL.CASH - PSTA.AMT) LT TOLERANCE.AMT THEN ;* If amount doesnt match tolerance but, within
            WARN.DET<1,1,-1> = 'DIARY CASH = ':TOTAL.CASH:', CUSTODIAN CASH = ':PSTA.AMT:', TOLERANCE = ':DIARY.CCY:TOLERANCE.AMT
        END
    NEXT PS
    IF LOAN.INDICATOR THEN
        WARN.DET<1,1,-1> = 'LENT POSITION IMPACTED'
    END
* Perform comparison of PSTA qty only if there are no multiple securities under ISIN number in SECMOVE block
    IF NOT(MULTIPLE.SECURITY.UNDER.ISIN) AND CAOP.INDICATOR NE 'OVER' THEN ;*As we are not updating Alloted nominal details in TOTAL.CREDIT/DEBIT - For OVER
        NO.OF.SEC = DCOUNT(SECMOVE.SEC.LIST,@VM)
        FOR I = 1 TO NO.OF.SEC
            LOCATE SECMOVE.SEC.LIST<1,I> IN R.DIARY<SC.SccEventCapture.Diary.DiaTotSecurity,DEP.POS,1> SETTING POS THEN
                IF PSTA.QTY<1,I> AND PSTA.QTY<1,I> LT 0 AND R.DIARY<SC.SccEventCapture.Diary.DiaTotalDebit,DEP.POS,POS> NE ABS(PSTA.QTY<1,I>) THEN
                    ERR.DET<1,1,-1> = 'SECURITY = ':SECMOVE.SEC.LIST<1,I>:' DIARY DEBIT NOM =':R.DIARY<SC.SccEventCapture.Diary.DiaTotalDebit,DEP.POS,POS>:' PSTA DEBIT NOM =':PSTA.QTY<1,I>
                END

                IF PSTA.QTY<1,I> GE 0 AND R.DIARY<SC.SccEventCapture.Diary.DiaTotalCredit,DEP.POS,POS> NE PSTA.QTY<1,I> THEN
;*Assumption:Total nominals for new security those are finally distributed for both excercise and oversubscription
;*to be present in EXER's SECMOVE block.
                    ERR.DET<1,1,-1> = 'SECURITY = ':SECMOVE.SEC.LIST<1,I>:' DIARY CREDIT NOM =':R.DIARY<SC.SccEventCapture.Diary.DiaTotalCredit,DEP.POS,POS>:' PSTA CREDIT NOM =':PSTA.QTY<1,I>
                END
            END ELSE
                ERR.DET<1,1,-1> = 'SECURITY NUMBER DOESNT MATCH'
            END
        NEXT I
    END

    PSTA.AMT = SAVE.PSTA.AMT[4,18]
    PSTA.CCY = SAVE.PSTA.AMT[1,3]

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= CREATE.SC.ENT.AUTHORISE>
CREATE.SC.ENT.AUTHORISE:
*** <desc>Create SC.ENT.AUTHORISE record if no errors and no warnings </desc>

    CA.LOG.ID = SC.PRE.KEY<I.COUNT>     ;* set it back with Diary id
    OFS.DATA = ''
    IF R.INWARD<SC.STP.DeIMsgFivFivx.IScFunction> NE 'REVR' AND NOT(ERR.DET) AND NOT(RECONCILIATION.PENDING) AND CAOP.INDICATOR NE 'OVER' THEN   ;*Proces If not Reversal,No error ;* RIGHTS
        SC.SccEventCapture.DiaryLock(CA.LOG.ID,R.DIARY,DIA.ERR,'','') ;*Update received cash in Diary

* Update total cash received in each currency
        PSTA.CNT = DCOUNT(PSTA.AMT.ARR,@VM)
        FOR PP = 1 TO PSTA.CNT
            PSTA.CCY = PSTA.AMT.ARR<1,PP>[1,3]
            PSTA.AMT = PSTA.AMT.ARR<1,PP>[4,18]
            LOCATE PSTA.CCY IN R.DIARY<SC.SccEventCapture.Diary.DiaDepDivCcy,DEP.POS,1> SETTING DEP.CCY.POS THEN
                R.DIARY<SC.SccEventCapture.Diary.DiaTotCashDivRecd,DEP.POS,DEP.CCY.POS> += PSTA.AMT
            END ELSE
                R.DIARY<SC.SccEventCapture.Diary.DiaTotCashRecd,DEP.POS> += PSTA.AMT          ;* Update total cash received
            END
        NEXT PP

        SC.SccEventCapture.DiaryWrite(CA.LOG.ID,R.DIARY,'')
        IF R.DIARY<SC.SccEventCapture.Diary.DiaStp> AND NOT(OTHER.WARNING) THEN ;* Authorise Entitlement in case of Full STP and No warnings
            IF SUB.ACCOUNT AND NOT(CUST.SEC.SUB.ACCOUNT) THEN         ;* Authorise individual entitlement pertaining to portfolio
                EB.Foundation.OfsBuildRecord('ENTITLEMENT','A','PROCESS',ENT.VERSION,'1',0,ENTL.ID,'',OFS.DATA)
            END ELSE          ;* Authorise all entitlement or group of entitlement pertaining to a sub account
                R.ENT.AUTHORISE = ''
                R.ENT.AUTHORISE<SC.SccEntitlements.EntAuthorise.EauDiaryId> = CA.LOG.ID   ;* Assign Diary id
                R.ENT.AUTHORISE<SC.SccEntitlements.EntAuthorise.EauDepository> = CONC.ID  ;* Assign depository
                R.ENT.AUTHORISE<SC.SccEntitlements.EntAuthorise.EauSubAccount> = SUB.ACCOUNT        ;* Assign sub account
                VERSION.NAME = R.DE.MESSAGE<DE.Config.Message.MsgInOfsVersion>
                EB.Foundation.OfsBuildRecord('SC.ENT.AUTHORISE','I','PROCESS',VERSION.NAME,'1',0,'',R.ENT.AUTHORISE,OFS.DATA)
            END
            IF NO.OF.REC GT 1 THEN
                EB.API.AllocateUniqueTime(SAVE.OFS.KEY)
                SAVE.OFS.KEY = SAVE.OFS.KEY[6,99]
                CURRENT.DATE = DATE()
                SAVE.OFS.KEY = CURRENT.DATE:SAVE.OFS.KEY
                IF OFS.KEY EQ '' THEN
                    OFS.KEY = SAVE.OFS.KEY
                END ELSE
                    OFS.KEY = OFS.KEY : @VM : SAVE.OFS.KEY
                END
            END
            IF OFS.MESSAGE EQ '' THEN
                OFS.MESSAGE = OFS.DATA
            END ELSE
                OFS.MESSAGE  = OFS.MESSAGE:@VM:OFS.DATA
            END
        END
    END
    LOCATE SECURITY.NO IN SM.PENDING.LIST<1> SETTING SM.POS THEN      ;* Delete processed securities
        DEL SM.PENDING.LIST<SM.POS>
    END
    GOSUB OVERSUBSCRIPTION.PROCESS      ;* RIGHTS
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= GET.566.DET.FROM.LOG>
GET.566.DET.FROM.LOG:
*** <desc>Get the log details updated during earlier 566 </desc>
*
    LOG.ERR = ''
    R.CA.ERROR = ''
    R.CA.ERROR = SC.SccConfig.CaErrorLog.Read(CA.LOG.ID, LOG.ERR)

    IF R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DryNewSecurities> EQ "Y" OR R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DryRetainOriginal> EQ "NO" THEN     ;* if eligible for stock movement
* get quantity from log in order to reconcile
        NO.OF.SEC = DCOUNT(R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerTotSecurity>,@VM)
        LOG.QTY = ''
        LOG.SEC.LIST = ''
        FOR SEC.CNT = 1 TO NO.OF.SEC
            IF R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerTotalDebit,SEC.CNT> THEN
                LOG.SEC.LIST<1,-1> = R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerTotSecurity,SEC.CNT>
                LOG.QTY<1,-1> = R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerTotalDebit,SEC.CNT>
            END
            IF R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerTotalCredit,SEC.CNT> THEN
                LOG.SEC.LIST<1,-1> = R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerTotSecurity,SEC.CNT>
                LOG.QTY<1,-1> = R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerTotalCredit,SEC.CNT>
            END
        NEXT SEC.CNT
        IF LOG.SEC.LIST THEN  ;* Update in order to compare the nominals
            IF SECMOVE.SEC.LIST THEN
                SECMOVE.SEC.LIST = LOG.SEC.LIST:@VM:SECMOVE.SEC.LIST
                PSTA.QTY = LOG.QTY:@VM:PSTA.QTY
            END ELSE
                SECMOVE.SEC.LIST = LOG.SEC.LIST
                PSTA.QTY = LOG.QTY
            END
        END
*   If details not available in log and event is eligible for new securities means quantity details not arrived.Mark for reconciliation check if cash details are arrived
        IF  NOT(PSTA.QTY) AND R.DIARY<SC.SccEventCapture.Diary.DiaTotSecurity> AND PSTA.AMT THEN
            RECONCILIATION.PENDING = 1
        END
*   If quantity is there, check whether details are arrived for both debit and credit movements by comparing the movements with Diary
* Mark for reconciliation if movement doesnt match as anyhow other checks are performed to classify as error
        IF PSTA.QTY THEN
* get quantity from log in order to reconcile
            NO.OF.SEC = DCOUNT(R.DIARY<SC.SccEventCapture.Diary.DiaTotSecurity,1>,@SM)
            DIA.QTY = ''
            DIA.SEC.LIST = ''
            FOR SEC.CNT = 1 TO NO.OF.SEC
                IF R.DIARY<SC.SccEventCapture.Diary.DiaTotalDebit,1,SEC.CNT> THEN
                    DIA.SEC.LIST<1,-1> = R.DIARY<SC.SccEventCapture.Diary.DiaTotSecurity,1,SEC.CNT>
                    DIA.QTY<1,-1> = R.DIARY<SC.SccEventCapture.Diary.DiaTotalDebit,1,SEC.CNT>
                END
                IF R.DIARY<SC.SccEventCapture.Diary.DiaTotalCredit,1,SEC.CNT> THEN
                    DIA.SEC.LIST<1,-1> = R.DIARY<SC.SccEventCapture.Diary.DiaTotSecurity,1,SEC.CNT>
                    DIA.QTY<1,-1> = R.DIARY<SC.SccEventCapture.Diary.DiaTotalCredit,1,SEC.CNT>
                END
            NEXT SEC.CNT

            IF DCOUNT(SECMOVE.SEC.LIST,@VM) NE DCOUNT(DIA.SEC.LIST,@VM) THEN    ;* If all movements are not received
                RECONCILIATION.PENDING = 1
            END
        END
    END

    PSTA.AMT.ARR = PSTA.AMT   ;* Current PSTA amount arrived in message
    IF R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DryCash> EQ 'Y' THEN          ;* if no amount get from log for reconciliation
*       PSTA.CCY = R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerTotalCashCcy>
* Append cash arrived in earier message to compare again with total cash of each currency
        COUNT.LOG.CASH = DCOUNT(R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerTotalCashCcy>,@VM)
        FOR CA = 1 TO COUNT.LOG.CASH
            PSTA.AMT.ARR<1,-1> = R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerTotalCashCcy,CA>:R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerTotalCash,CA>
        NEXT CA
*   If details not available in log and event is eligible for cash means cash details not arrived.
* Mark for reconciliation check if security details are arrived
        IF NOT(PSTA.AMT.ARR) AND R.DIARY<SC.SccEventCapture.Diary.DiaTotalCash> AND PSTA.QTY THEN      ;*
            RECONCILIATION.PENDING = 1
        END

    END

* RIGHTS S
* Read SC.DIA.OVERSUBS.CONCAT to see if oversubscription processing is done. If record exists then oversubscription is being performed so, dont authorise.
    OVERSUBS.ID = DIARY.ID:'-':CONC.ID
    IF NOT(SUB.ACCOUNT) THEN
        OVERSUBS.ID := '-ALL'
    END ELSE
        OVERSUBS.ID := '-':SUB.ACCOUNT
    END
    OV.ERR = ''
    R.DIA.OVERSUBS = SC.SccEventCapture.DiaOverSubsConcat.Read(OVERSUBS.ID,OV.ERR)
    IF NOT(OV.ERR) THEN
        RECONCILIATION.PENDING = 1
    END
* RIGHTS E
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= SEGREGATED.ACC.PROCESSING>
SEGREGATED.ACC.PROCESSING:
*** <desc>This para will update nominal and cash details of segregated account into Diary to continue matching process </desc>

    BEGIN CASE
        CASE CUST.SEC.SUB.ACCOUNT OR NOT(SUB.ACCOUNT)
* In case of Sub account not pertaining to portfolio, fetch the details from Diary
            IF NOT(SUB.ACCOUNT) THEN        ;*  If no sub account locate for ALL
                DEP.SUB.ACC = CONC.ID:'-ALL'
            END ELSE
                DEP.SUB.ACC = CONC.ID:'-':SUB.ACCOUNT
            END
            LOCATE CONC.ID IN R.DIARY<SC.SccEventCapture.Diary.DiaDepNo,1> SETTING DEP.POS THEN
                LOCATE DEP.SUB.ACC IN R.DIARY<SC.SccEventCapture.Diary.DiaDepSubAcc,1> SETTING DEP.SUB.POS THEN
                    R.DIARY<SC.SccEventCapture.Diary.DiaTotalCash,DEP.POS> = R.DIARY<SC.SccEventCapture.Diary.DiaTotSubCash,DEP.SUB.POS>
                    R.DIARY<SC.SccEventCapture.Diary.DiaTotSecurity,DEP.POS> = R.DIARY<SC.SccEventCapture.Diary.DiaTotSubSecurity,DEP.SUB.POS>
                    R.DIARY<SC.SccEventCapture.Diary.DiaTotalCredit,DEP.POS> = R.DIARY<SC.SccEventCapture.Diary.DiaTotSubCredit,DEP.SUB.POS>
                    R.DIARY<SC.SccEventCapture.Diary.DiaTotalDebit,DEP.POS> = R.DIARY<SC.SccEventCapture.Diary.DiaTotSubDebit,DEP.SUB.POS>
* Frame currency wise nostro amount for reconciliation
                    R.DIARY<SC.SccEventCapture.Diary.DiaDepDivCcy,DEP.POS> = R.DIARY<SC.SccEventCapture.Diary.DiaDepSubDivCcy,DEP.SUB.POS>
                    R.DIARY<SC.SccEventCapture.Diary.DiaTotCashDiv,DEP.POS> = R.DIARY<SC.SccEventCapture.Diary.DiaTotDepSubCashDiv,DEP.SUB.POS>
                END
            END

        CASE SUB.ACCOUNT
* In case of sub account pertaining to portfolio, fetch the details from Entitlement
            DIM DIARY.REC(EB.SystemTables.SysDim)
            MAT DIARY.REC = ''
            DIM ENTL.REC(EB.SystemTables.SysDim)
            MAT ENTL.REC = ''
            ENTL.ID = SC.PRE.KEY<I.COUNT>:'.':PORTFOLIO.OR.CUSTOMER:'.':CONC.ID:'..':SUB.ACCOUNT        ;*Frame entitlement ID
            ER = ''
            R.ENTL = SC.SccEntitlements.Entitlement.ReadNau(ENTL.ID,ER)
            IF ER THEN  ;* For rights
                R.ENTL = SC.SccEntitlements.Entitlement.Read(ENTL.ID,ER)
            END
            IF R.ENTL THEN        ;* If Entitlement record exists
                MATPARSE ENTL.REC FROM R.ENTL
                MATPARSE DIARY.REC FROM R.DIARY
* Nullify the below fields so that only values pertaining to the current segregated account is available for matching
                DIARY.REC(SC.SccEventCapture.Diary.DiaTotalCash) = ''
                DIARY.REC(SC.SccEventCapture.Diary.DiaTotSecurity) = ''
                DIARY.REC(SC.SccEventCapture.Diary.DiaTotalCredit) = ''
                DIARY.REC(SC.SccEventCapture.Diary.DiaTotalDebit) = ''
                DIARY.REC(SC.SccEventCapture.Diary.DiaOptionNominal) = ''
                DIARY.REC(SC.SccEventCapture.Diary.DiaTotCashDiv) = ''
                SC.SccEntitlements.SetupDiaryRecord(MAT DIARY.REC, R.DIARY.TYPE, MAT ENTL.REC,CONC.ID,'','')
                MATBUILD R.DIARY FROM DIARY.REC
            END
    END CASE
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= MULTI.CCY.PROCESSING>
MULTI.CCY.PROCESSING:
*** <desc>This para will  be used as pre process for multi ccy reconciliation </desc>
    IF R.DIARY<SC.SccEventCapture.Diary.DiaDepDivAcc,1> THEN          ;*
        LOCATE PSTA.AMT[1,3] IN R.DIARY<SC.SccEventCapture.Diary.DiaDepDivCcy,DEP.POS,1> SETTING DEP.CCY.POS THEN
            DIARY.CCY = PSTA.AMT[1,3]
            R.DIARY<SC.SccEventCapture.Diary.DiaTotalCash,DEP.POS> = R.DIARY<SC.SccEventCapture.Diary.DiaTotCashDiv,DEP.POS,DEP.CCY.POS>
            R.DIARY<SC.SccEventCapture.Diary.DiaTotalCashCcy,DEP.POS> = PSTA.AMT[1,3]
        END
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= OVERSUBSCRIPTION.PROCESS>
OVERSUBSCRIPTION.PROCESS:
*** <desc> </desc>
* Update Alloted nominal from oversubscription
    IF CAOP.INDICATOR EQ 'OVER' THEN
        SC.SccEventCapture.DiaryLock(CA.LOG.ID,R.DIARY,DIA.ERR,'','') ;*Update received cash in Diary
        IF CUST.SEC.SUB.ACCOUNT OR NOT(SUB.ACCOUNT) THEN         ;* handling Omni bus cases
* In case of Sub account not pertaining to portfolio, fetch the details from Diary
            IF NOT(SUB.ACCOUNT) THEN        ;*  RIGHTS If no sub account locate for ALL
                DEP.SUB.ACC = CONC.ID:'-ALL'
            END ELSE    ;* RIGHTS
                DEP.SUB.ACC = CONC.ID:'-':SUB.ACCOUNT
            END         ;* RIGHTS
            LOCATE CONC.ID IN R.DIARY<SC.SccEventCapture.Diary.DiaDepNo,1> SETTING DEP.POS THEN
                LOCATE DEP.SUB.ACC IN R.DIARY<SC.SccEventCapture.Diary.DiaDepSubAcc,1> SETTING DEP.SUB.POS THEN
                    R.DIARY<SC.SccEventCapture.Diary.DiaAllotedNom,DEP.SUB.POS> = PSTA.QTY      ;*Update alloted quantity
                    R.DIARY<SC.SccEventCapture.Diary.DiaOverSubEntStatus,DEP.SUB.POS> = 'UNAUTHORISE' ;*To be in sync with the workfile
                    GOSUB UPD.DIA.OVER.SUBS.CONCAT ;*Update SC.DIA.OVER.SUBS.CONCAT  - for omni bus accounts alone
                END
            END
            SC.SccEventCapture.DiaryWrite(CA.LOG.ID,R.DIARY,'')
        END ELSE
;*To handle client segregated account cases. -
            ENTL.ID = SC.PRE.KEY<I.COUNT>:'.':PORTFOLIO.OR.CUSTOMER:'.':CONC.ID:'..':SUB.ACCOUNT        ;*Frame entitlement ID
            ER = ''
            R.ENTL = '' ;*Do not read the record.just update alloted nom
            R.ENTL<SC.SccEntitlements.Entitlement.EntOverAllotedNom> = PSTA.QTY      ;*Update alloted quantity
            APP.NAME = 'ENTITLEMENT'
            PROC.TYPE = 'ONLINE'
            OPERATION = 'INPUT'
* generate and send ofs to ENTITLEMENT
            SC.SccEntitlements.CaOfsProcess(APP.NAME,OPERATION,PROC.TYPE,R.ENTL,ENTL.ID,PROC.STATUS)
        END
    END


RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= UPD.DIA.OVER.SUBS.CONCAT>
UPD.DIA.OVER.SUBS.CONCAT:
*** <desc>Updates the concat file SC.DIA.OVER.SUBS.CONCAT to support oversubscription process SC.OVER.SUBSCRIPTION.SERVICE </desc>
    LOCATE 'EXER' IN R.DIARY<SC.SccEventCapture.Diary.DiaOptionInd,1> SETTING EXER.POS THEN
        NEW.SEC.NUM = R.DIARY<SC.SccEventCapture.Diary.DiaNewSecNo,EXER.POS>
    END
    SC.DIA.OVER.SUBS.CONCAT.ID = CA.LOG.ID:'-':R.DIARY<SC.SccEventCapture.Diary.DiaDepSubAcc,DEP.SUB.POS> ;*CA.LOG.ID - is the Diary ID
    R.SC.DIA.OVER.SUBS.CONCAT = ''
    R.SC.DIA.OVER.SUBS.CONCAT<1,1> = CA.LOG.ID
    R.SC.DIA.OVER.SUBS.CONCAT<1,2> = R.DIARY<SC.SccEventCapture.Diary.DiaSubscribedNom,DEP.SUB.POS>
    R.SC.DIA.OVER.SUBS.CONCAT<1,3> = R.DIARY<SC.SccEventCapture.Diary.DiaAllotedNom,DEP.SUB.POS>
    R.SC.DIA.OVER.SUBS.CONCAT<1,4> = 'UNAUTHORISE' ;*By default, all entitlements will be updated in INAU
    R.SC.DIA.OVER.SUBS.CONCAT<1,5> = NEW.SEC.NUM
    R.SC.DIA.OVER.SUBS.CONCAT<1,6> = '' ;*Percentage process is not required during SWIFT processing
    SC.SccEventCapture.DiaOverSubsConcatWrite(SC.DIA.OVER.SUBS.CONCAT.ID, R.SC.DIA.OVER.SUBS.CONCAT, '')

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.EVENT.INDICATOR>
GET.EVENT.INDICATOR:
*** <desc>get the event type from CAEV tag </desc>
    EVENT.TYPE = ''
    EVENT.COUNT = DCOUNT(R.INWARD<10>,@VM)
    FOR CTR = 1 TO EVENT.COUNT
        IF FIELD(R.INWARD<10,CTR>,'//',1) EQ 'CAEV' THEN   ;* Get safe account
            EVENT.TYPE = FIELD(R.INWARD<10,CTR>,"//",2)
            CTR = EVENT.COUNT
        END
    NEXT CTR
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= MX.PROCESS>
MX.PROCESS:
*** <desc>Convert the SEEV036 MX message to MT 566 message </desc>

    VAR1 = ''
    DEFFUN CHARX(VAR1)

    R.XML.IN = ''
    tmp.E = EB.SystemTables.getE()
    tmp.F.DE.I.MSG = DE.Inward.getFDeIMsg()
    tmp.R.KEY = DE.Inward.getRKey()
    R.XML.IN = DE.ModelBank.IMsg.Read(tmp.R.KEY, tmp.E)
    EB.SystemTables.setE(tmp.E)

    R.DE.MESSAGE = ''
    tmp.E = EB.SystemTables.getE()
    R.DE.MESSAGE = DE.Config.Message.Read(DE.Inward.getRHead(DE.Config.IHeader.HdrMessageType), tmp.E)
    EB.SystemTables.setE(tmp.E)

    R.OFS.SOURCE = ''
    tmp.E = EB.SystemTables.getE()
    R.OFS.SOURCE = EB.Interface.OfsSource.Read(R.DE.MESSAGE<DE.Config.Message.MsgOfsSource>, tmp.E)
    EB.SystemTables.setE(tmp.E)

    EB.Interface.setOfsSourceId(R.DE.MESSAGE<DE.Config.Message.MsgOfsSource>)
    EB.Interface.setOfsSourceRec(R.OFS.SOURCE)

    EQU CR TO CHARX(013)  ;* carriage return
    EQU LF TO CHARX(010)  ;* line feed
    CRLF = CR:LF

    CONVERT @FM TO '' IN R.XML.IN   ;*convert the FM to null
    CONVERT CRLF TO '' IN R.XML.IN  ;*convert the CRLF to null
    CONVERT LF TO '' IN R.XML.IN    ;*convert the LF to null

    EB.TRANSFORM.ID = 'SC-SEEV036'

    IF NOT(EB.SystemTables.getE()) THEN
        GOSUB PROCESS.MESSAGE       ;*Process the xml message to convert it into ofsml
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= PROCESS.MESSAGE>
PROCESS.MESSAGE:
*** <desc>Process the xml message to convert it into ofsml</desc>

    GOSUB PRE.PROCESS.XSLT          ;*Pre process for XSLT. convert the required tag before XSLT conversion
    RESULT.XML = ''
    GOSUB READ.EB.TRANSFORM         ;*Read the EB.TRANSFORM record
    EB.Browser.CleanXmlText(R.XML.IN,"REPLACE.CODES","")          ;* convert into chars
* transform the xml message to form R.INWARD array
    EB.API.TransformXml(R.XML.IN,'',R.EB.TRANSFORM<EB.SystemTables.Transform.XmlTransMappingXsl>,RESULT.XML)

    IF RESULT.XML THEN
        DE.Inward.setRHead(DE.Config.OHeader.HdrErrorCode, RESULT.XML)
* if there is an error while transforming then log it in exception
        EB.ErrorProcessing.ExceptionLog("S","SC.MT566.QUEUE","SC.OFS.SEEV036.MAPPING","SECURITIES",'',RESULT.XML,'SC.MT566.QUEUE',tmp.R.KEY,'1',RESULT.XML,'')
    END ELSE
        R.XML.IN = CHANGE(R.XML.IN,'@FM',@FM)
        R.XML.IN = CHANGE(R.XML.IN,'@VM',@VM)
        R.XML.IN = CHANGE(R.XML.IN,'@SM',@SM)
        R.INWARD = R.XML.IN
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= PRE.PROCESS.XSLT>
PRE.PROCESS.XSLT:
*** <desc>Pre process for XSLT. convert the required tag before XSLT conversion </desc>

* Remove header part
    R.XML.IN = FIELD(R.XML.IN,'<Document',2)
    R.XML.IN = FIELD(R.XML.IN,'</Document',1)
    R.XML.IN = '<?xml version="1.0" encoding="UTF-8"?><Document':R.XML.IN:'</Document>'

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= READ.EB.TRANSFORM>
READ.EB.TRANSFORM:
*** <desc>Read the EB.TRANSFORM record </desc>

    R.EB.TRANSFORM = ''
    YERR = ''
    R.EB.TRANSFORM = EB.SystemTables.Transform.Read(EB.TRANSFORM.ID, YERR)

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name = GENERATE.OFS>
GENERATE.OFS:

    SAVE.APPLICATION = EB.SystemTables.getApplication()
    K.VERSION = R.DE.MESSAGE<DE.Config.Message.MsgInOfsVersion>

    EB.SystemTables.setApplication(FIELD(K.VERSION,",",1))

    IF YERR THEN
        EB.SystemTables.setEtext(YERR)
        GOSUB WRITE.REPAIR
    END
    IF OFS.MESSAGE THEN
        NB.KEY = DCOUNT(OFS.KEY,@VM)
        IF NOT(NB.KEY) THEN
            NB.KEY = 1
            EB.API.AllocateUniqueTime(OFS.KEY)
            OFS.KEY = OFS.KEY[6,99]
            CURRENT.DATE = DATE()
            OFS.KEY = CURRENT.DATE:OFS.KEY
        END
        FOR X = 1 TO NB.KEY
            OFS.KEY.NEW = ''
            OFS.MESSAGE.NEW = ''
            OFS.KEY.NEW = OFS.KEY<1,X>
            OFS.MESSAGE.NEW = OFS.MESSAGE<1,X>
            GOSUB WRITE.OFS.MESSAGE
            TXN.REF = FIELD(OFS.MESSAGE.RESPONSE, '/' ,1)
            DE.Inward.setRHead(DE.Config.OHeader.HdrTransRef,TXN.REF)
        NEXT X
    END
    DE.Inward.setRHead(DE.Config.OHeader.HdrCompanyCode, EB.SystemTables.getIdCompany()) ;*Should we verify this?. if any change should restore earlier company
    EB.SystemTables.setApplication(SAVE.APPLICATION)
RETURN
*** </region>
*-----------------------------------------------------------------------------
** <region name = WRITE.OFS.MESSAGE>
WRITE.OFS.MESSAGE:

    OFS.MESSAGE.RESPONSE = '' ; REQUEST.COMMIT = ''
    EB.Interface.OfsBulkManager(OFS.MESSAGE.NEW, OFS.MESSAGE.RESPONSE, REQUEST.COMMIT)

RETURN
*** </region>
*-----------------------------------------------------------------------------
** <region name = WRITE.REPAIR>
WRITE.REPAIR:

    DE.Inward.setRHead(DE.Config.OHeader.HdrDisposition ,"REPAIR")
    DE.Inward.setRHead(DE.Config.OHeader.HdrErrorCode, YERR)
    R.REPAIR = ID.INWARD
*
    DE.Outward.UpdateIRepair(R.REPAIR,'')
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
