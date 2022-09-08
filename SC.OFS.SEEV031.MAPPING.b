* @ValidationCode : MjotMjcxNjc3OTAwOkNwMTI1MjoxNjA1NjE5Mjg4ODgwOnNtYWxsaWthcmp1bjoxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEwLjIwMjAwOTI5LTEyMTA6OTE0OjQ5OA==
* @ValidationInfo : Timestamp         : 17 Nov 2020 18:51:28
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : smallikarjun
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 498/914 (54.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200929-1210
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.SccEventNotification
SUBROUTINE SC.OFS.SEEV031.MAPPING
*------------------------------------------------------------------------
*
* This routine is defined in DE.MESSAGE for message type SEEV031 as
* the default routine to map message details to T24 - SC.PRE.DIARY record
* It follows SC.OFS.564.MAPPING Routine's process to map details in SC.PRE.DIARY
*
*------------------------------------------------------------------------
* Modification History:
*
*  15/12/16 - Enhancement-1545934/Task-1957541
*             ISO20022 MX - Event Inward Messages(MT564,MT566 and MT568)[Post Process XML]
*
* 15/05/2018 - Task - 2589571
*             changes related to SC.CA.ERROR.LOG id based on field CA.LOG.ID of SC.CA.PARAMETER - DIARY
*
* 03/02/2020 - Enhancement 3568228 / Task 3569215
*            Changing reference of routines that have been moved from ST to CG
*
* 10/11/20 - SI-3858153 / ENH-4034105 / TASK-4034130
*            ENC2 Client BIL-Tax setup at SAT/AT level-Auth processing
*
*------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.Utility
    $USING SC.SccConfig
    $USING SC.ScoSecurityMasterMaintenance
    $USING ST.CompanyCreation
    $USING SC.SccEventCapture
    $USING SC.SctTaxes
    $USING CG.ChargeConfig
    $USING EB.API
    $USING EB.Foundation
    $USING SC.STP
    $USING EB.DataAccess
    $USING EB.Interface
    $USING SC.Config
    $USING EB.Security
    $USING DE.Config
    $USING SC.SccEventNotification
    $USING DE.Inward
    $USING EB.Browser
    $USING EB.ErrorProcessing
    $USING DE.ModelBank
    $USING DE.Outward

    GOSUB INITIALISATION
    GOSUB MAIN.PROCESSING
    GOSUB GENERATE.OFS

RETURN
*-----------------------------------------------------------------------------
*** <region name = initialisation>
INITIALISATION:

    R.SC.PRE.DIARY = ''
    EB.SystemTables.setEtext("")
    ID.INWARD = DE.Inward.getRKey() ;*Inward Delivery ID
    R.INWARD = ''
    R.SWIFT = '' ;*Not used
    MESSAGE.TYPE = 'SEEV031' ;*MESSAGE.TYPE field in SC.PRE.DIARY
    R.DE.MESSAGE = ''
    OFS.MESSAGE = ''
    OFS.KEY = ''
    YERR=''

    GOSUB MX.PROCESS          ;*Convert the SEEV031 MX message to MT 564 message

    ERR.DET = ''
    WARN.DET = ''
*
    R.CA.PARAMETER = ''
    R.CA.PARAMETER = SC.SccConfig.CaParameter.CacheRead('DIARY', '')

    F.SC.PRE.DIARY.NAU = ''

    TRUE = 1
    FALSE = 0
    ST.CompanyCreation.EbReadParameter('F.SC.PARAMETER','N','',R.SC.PARAMETER,'','',ER)
*

* Initialise necessary variables here related to changes in SC.CA.ERROR.LOG id.
    CA.LOG.ID = ''
    TXN.ID = ''
    CORPREF = ''
    DEPO.ID = ''
    SM.ID = ''
    SUB.ACCOUNT = ''
    LOG.ID.FORMAT = ''
    CALOG.WITH.SUBACC = ''
    CALOG.WITHOUT.SUBACC = ''
RETURN
*** </region>
*------------------------------------------------------------------------
*** <region name = messageProcessing>
MAIN.PROCESSING:

* Build SC.PRE.DIARY record from message 564
    CONVERT ',' TO '.' IN R.INWARD
    R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdHldReason> = ''
    NARR.INWARD = R.INWARD<SC.STP.DeIMsgFivFivx.IScEndAddNarrative>

    GOSUB GET.DIARY.TYPE      ;* From the CAEV Tag, Identifying DIARY.TYPE and store its record.
    GOSUB GET.PROC.CODE       ;* Determine processing code
    GOSUB GET.REFERENCE       ;* Get corp and Seme reference
    GOSUB GET.QUANTITY        ;* Get eligible or loan quantity

* Msg type
    R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdMessageType> = MESSAGE.TYPE

    GOSUB GET.CAOPTN.DETAILS
    RIGHTS.FLAG = ''
    GOSUB EVENT.SECURITY.ISIN.MAPPING
    GOSUB QTY.REF.MAPPING

    GOSUB CADETL.RATE.DATE.MAPPING
* Reference of inward message
    R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdDeliveryInref> = ID.INWARD
*
    IF OPT.POS THEN
        GOSUB ASSIGN.NEW.SECURITY.RIGHTS
    END
    GOSUB SETUP.RATE
    GOSUB UPDATE.GROSS.AMOUNT
    GOSUB GET.DEPOSITORY      ;*Determine depo from safe account
    GOSUB CREATE.PRE.DIARY    ;*Create Pre diary for each depo and security


RETURN
*-----------------------------------------------------------------------
ASSIGN.NEW.SECURITY.RIGHTS:
*------------


    RIGHTS.FLAG = ''
    IF R.INWARD<58> = "RTUN" THEN
        CONVERT ',' TO '.' IN R.INWARD<59>
        R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdOldToRight,OPT.POS,1> = FIELD(R.INWARD<59>,'/',1)
        R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdOldRatio,OPT.POS,1> = FIELD(R.INWARD<59>,'/',2)
    END
    IF R.INWARD<52> = "NWRT" THEN
        CONVERT ',' TO '.' IN R.INWARD<53>
        R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdNewRatio,OPT.POS,1> = FIELD(R.INWARD<53>,'/',1)
        R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdRightToNew,OPT.POS,1> = FIELD(R.INWARD<53>,'/',2)
    END
    IF R.INWARD<52> EQ "NEWO" OR R.INWARD<52> EQ "ADEX" THEN
        CONVERT ',' TO '.' IN R.INWARD<53>
        R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdNewRatio,OPT.POS,1> = FIELD(R.INWARD<53>,'/',1)
        R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdOldRatio,OPT.POS,1> = FIELD(R.INWARD<53>,'/',2)
    END

    NO.ISIN = DCOUNT(R.INWARD<56>,@VM)
    FOR I = 1 TO NO.ISIN
        IF R.INWARD<56,I>[1,4] = "ISIN" THEN
            RIGHTS.FLAG = 1
            IDENT.SECURITY = R.INWARD<56,I>[6,12]
            GOSUB READ.SECURITY.MASTER
            R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdRightsNo,OPT.POS,1> = SECURITY.NO
        END
    NEXT I

    CONVERT @SM TO @VM IN R.INWARD<57>
    NO.ISIN = DCOUNT(R.INWARD<57>,@VM)
    PARENT.SECURITY = R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdSecurityNo>
    FOR I = 1 TO NO.ISIN
        IF R.INWARD<57,I>[1,4] = "ISIN" THEN
            RIGHTS.FLAG = 1
            IDENT.SECURITY = R.INWARD<57,I>[6,12]
            GOSUB READ.SECURITY.MASTER
            IF SECURITY.NO NE PARENT.SECURITY THEN
*1).In case, if a SECURITY.NO in loop is diff from parent security, then clear the old value
                R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdNewSecNo,OPT.POS,1> = ''
            END
*2).Assign SECURITY.NO in the field, when it is cleared from '1' or when this loop is executed for first time.
            IF R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdNewSecNo,OPT.POS,1> EQ '' THEN
                R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdNewSecNo,OPT.POS,1> =  SECURITY.NO
                R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdNewPrice,OPT.POS,1> = NEW.PRICE          ;*Assign new price
            END
        END
    NEXT I
    IF R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdNewSecNo,OPT.POS,1> AND NOT(R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdOldRatio,OPT.POS,1> OR R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdNewRatio,OPT.POS,1>) THEN
*In cases where ratio of old to new shares is not available in the incoming MT564
*then determine these ratios based on 90B tag value and RATE field
*choose RATE based on CASH - indicator
        LOCATE 'CASH' IN R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdOptionInd,1> SETTING CASH.POS THEN
            RATE = R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdRate,CASH.POS>
            IF RATE EQ '' THEN
                RATE = 1
            END
        END
        R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdOldRatio> = NEW.PRICE
        R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdNewRatio> = RATE
    END
RETURN
*-----------------------------------------------------------------------------
SETUP.RATE:
*------------
* RATE shouldnt ne updated for non cash events.
    IF R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DryCash> EQ 'NO' THEN
        RETURN
    END
    OPTION.COUNT = DCOUNT(R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdOptionDesc>,@VM)
    FOR I = 1 TO OPTION.COUNT
        IF NOT(R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdRate,I>) AND NOT(R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdNewSecNo,I,1>) AND NOT(R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdOptCcyDivRate,I>) AND NOT(R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdOptCcyExchRate,I>) THEN
            R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdRate,I> = 0
        END
    NEXT I

RETURN
*--------------------------------------------------------------------------
*** <region name = GET.CAOPTN.DETAILS>
GET.CAOPTN.DETAILS:
*------------------

    DESC.ARR = ''
    CCY.ARR = ''
    CNT = ''
    NO.CAON = ''

    CAOP.POS = 1
    NO.CAON = DCOUNT(R.INWARD<50>,@VM)
    FOR CNT = 1 TO NO.CAON
        POS = ''
        IF INDEX(R.INWARD<50,CNT>,"CAON",1) THEN
            LOCATE 'CAOP' IN R.INWARD<63,CAOP.POS> SETTING CAOP.POS THEN
                CAON.DESC = R.INWARD<51,CAOP.POS>
                CAOP.POS += 1
            END
            CAON.SEQ = FIELD(R.INWARD<50,CNT>,'//',2)
            CCY.DESC = FIELD(R.INWARD<60,CNT>,'//',2)
            BEGIN CASE
                CASE CAON.DESC EQ 'OVER'
*Oversubscription option details are to be entered in newly added fields OVER.OPTION.DESC & OVER.OPTION.NUM
*which are identical to OPTION.IND & OPTION.NUM
                    R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdOverOptionDesc> = CAON.DESC    ;* Assign Indicator from CAOP tag
                    R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdOverOptionNum> = CAON.SEQ      ;* Assign sequence from CAON tag
                    CONTINUE

                CASE CAON.DESC EQ 'LAPS' AND R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DryRights> EQ 'Y'
*In case of Rights as single event processing, skip updation of LAPS option , as we handle this at ENTITLEMENT level.
                    CONTINUE

                CASE CAON.DESC MATCHES 'BUYA':@VM:'SLLE'
*Currently we dont process BUYA / SLLE options
                    CONTINUE
            END CASE

            OPTION.DESC = CAON.DESC:"-":CAON.SEQ
            LOCATE OPTION.DESC IN R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdOptionDesc,1> SETTING POS THEN
                CAON.DESC = FIELD(R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdOptionDesc><1,POS>,'-',1)
                CCY.DESC = R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdCashCcy><1,POS>
            END ELSE
                POS = DCOUNT(R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdOptionDesc>,@VM) + 1
                R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdOptionDesc,POS> = OPTION.DESC
                R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdCashCcy,POS> = CCY.DESC
                R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdOptionInd,POS> = CAON.DESC     ;* Assign Option Indicator from CAOP tag
                R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdOptionNum,POS> = CAON.SEQ      ;* Assign Option sequence from CAON tag
                R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdDefaultOption,POS> = FIELD(R.INWARD<72,CNT>,'//',2)          ;* Assign default indicator from DFLT tag

            END
            DEFAULT.OPTION.ARR<1,POS> = R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdDefaultOption,POS>
            DESC.ARR<1,POS> = CAON.DESC
            CCY.ARR<1,POS> = CCY.DESC
            IF DEFAULT.OPTION.ARR<1,POS> EQ 'Y' THEN        ;*If it is default option, this should be event currency
                R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdCurrency> = CCY.ARR<1,POS>
            END
        END
    NEXT CNT
* GET Trading period start and End
    TRPD.CNT = DCOUNT(R.INWARD<71>,@VM)
    FOR TRP = 1 TO TRPD.CNT
        IF FIELD(R.INWARD<71,TRP>,'/',1) EQ 'TRDP' THEN     ;*If trading period qualifier
            R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdTrdPeriodStart> = FIELD(R.INWARD<71,TRP>,'/',3)[1,8]   ;*Assign trading period start from TRDP qualifier
            R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdTrdPeriodEnd> = FIELD(R.INWARD<71,TRP>,'/',4)[1,8]     ;*Assign trading period end from TRDP qualifier
        END
    NEXT TRP
RETURN

*------------------------------------------------------------------------
*** </region>
EVENT.SECURITY.ISIN.MAPPING:
*---------------------------
* Corporate Action Event Indicator(CAEV)
* This field is used as key of SC.CON.SWIFT.CAEV concat file
* to determine which event type to use in SC.PRE.DIARY
    CONCAT.COUNT = ''

    PARTIAL.STP = ''          ;* Determine whether Event is full or partial stp
    IF R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DryPartialStp> THEN
        PARTIAL.STP = R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DryPartialStp>
        IF PARTIAL.STP NE 'ALL' THEN
            R.PARTIAL.STP = SC.SccConfig.PartialStp.CacheRead(PARTIAL.STP, '')
            PARTIAL.STP = R.PARTIAL.STP<SC.SccConfig.PartialStp.ScPstpType>
        END
    END

    OPT.POS = ''
    IF R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DryRights> = "Y" OR CAEV.SWIFT.ID EQ 'EXRI' THEN   ;* If rights is received as 2 MT564 or MT564 is itself a single message for Rights
        LOCATE 'EXER' IN DESC.ARR<1,1> SETTING OPT.POS THEN
        END ELSE
            OPT.POS = ''
        END
    END ELSE
        LOCATE 'SECU' IN DESC.ARR<1,1> SETTING OPT.POS THEN
        END ELSE
            OPT.POS = ''
        END
    END

    FIND.ALTER.IDX = FALSE
    FIND.FILE = FALSE
    INDEX.NAME = 'I.S.I.N.'
    SECURITY.NO = ''
    CONVERT @SM TO @VM IN R.INWARD<SC.STP.DeIMsgFivFivx.IScISIN>
    ISIN.POS = DCOUNT(R.INWARD<SC.STP.DeIMsgFivFivx.IScISIN>,@VM)
    IF NOT(ISIN.POS) THEN
        ISIN.POS = 1
    END
    FOR ISIN.CNT = 1 TO ISIN.POS
        IF R.INWARD<SC.STP.DeIMsgFivFivx.IScISIN,ISIN.CNT>[1,4] = 'ISIN' THEN
            IDENT.SECURITY = R.INWARD<SC.STP.DeIMsgFivFivx.IScISIN,ISIN.CNT>[1,25]
        END ELSE
            IDENT.SECURITY = R.INWARD<SC.STP.DeIMsgFivFivx.IScISIN,ISIN.CNT>
        END
        IF IDENT.SECURITY THEN
            ISIN.CNT = ISIN.POS + 1
        END
    NEXT ISIN.CNT
    GOSUB READ.SECURITY.MASTER
    ORIG.SEC.LIST = R.CONCAT.REC1
    CONCAT.COUNT = DCOUNT(ORIG.SEC.LIST,@FM)
    R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdSecurityNo> = SECURITY.NO
RETURN
********************
READ.SECURITY.MASTER:
********************
* Get security number from security.master index
* input  - SECURITY.ISIN - 'ISIN US1730341096'
* output - SECURITY.NO   - '000109-000'

    IF IDENT.SECURITY[1,4] EQ 'ISIN' OR RIGHTS.FLAG THEN
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
                IF NOT(RIGHTS.FLAG) THEN
                    R.CONCAT.REC1 = '' ; YERR1 = ''
                    CONCAT.ID = IDENT.SECURITY[6,12]
                    CONCAT.FILE.NAME = 'F.' :CONCAT.FILE.NAME
                    EB.DataAccess.FRead(CONCAT.FILE.NAME,CONCAT.ID,R.CONCAT.REC1,'',YERR1)
                END ELSE
                    IF IDENT.SECURITY[1,4] = "ISIN" THEN
                        IDENT.SECURITY = IDENT.SECURITY[6,12]
                    END
                    R.CONCAT.REC1 = '' ; YERR1 = ''
                    CONCAT.ID = IDENT.SECURITY
                    CONCAT.FILE.NAME = 'F.' :CONCAT.FILE.NAME
                    EB.DataAccess.FRead(CONCAT.FILE.NAME,CONCAT.ID,R.CONCAT.REC1,'',YERR1)
                END
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
* Isin reference
    IF IDENT.SECURITY[1,4] EQ 'ISIN' THEN
        R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdIsinNr> = IDENT.SECURITY[6,12]
    END ELSE
        R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdIsinNr> = IDENT.SECURITY
    END


RETURN
*------------------------------------------------------------------------
QTY.REF.MAPPING:
*---------------

    BALANCE.CNT = ''
    BC = ''

    BALANCE.CNT = DCOUNT(R.INWARD<SC.STP.DeIMsgFivFivx.IScBalance>,@VM)
    FOR BC = 1 TO BALANCE.CNT
        R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdQtySecurity> = FIELD(R.INWARD<SC.STP.DeIMsgFivFivx.IScEndBalance>,'.',1)
        IF R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdQtySecurity> THEN
            BREAK
        END
    NEXT BC

    R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdSourceRef> = SOURCE.REF
    R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdNarrative> = LINK.REF
    R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdLinkRef> = LINK.REF

    R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdActionStatus> = R.INWARD<SC.STP.DeIMsgFivFivx.IScFunction>
RETURN
*------------------------------------------------------------------------
CADETL.RATE.DATE.MAPPING:
*------------------------
    GOSUB GET.DATE  ;*Retreive Date from message
    GOSUB GET.RATE  ;*Get rate, redemption price from message

RETURN

*****************
TAX.RATE.PROCESS:
***************
    MAIN.SEC.NO = R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdSecurityNo>
    SEC.ERR = ''
    R.MAIN.SM = ''
    R.MAIN.SM = SC.ScoSecurityMasterMaintenance.SecurityMaster.Read(MAIN.SEC.NO, SEC.ERR)
    CT.ERR = ''
* Getting tax details moved to new method, since multiple tax setup is introduced.
    TAX = 'COUPON.TAX.CODE'
    SC.ScoSecurityMasterMaintenance.SmGetTaxByName(R.MAIN.SM,TAX,'')
    R.COUP.TAX = SC.SctTaxes.CouponTaxCode.CacheRead(TAX, CT.ERR)
    IF R.MAIN.SM<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmBondOrShare> EQ 'S' AND R.COUP.TAX<SC.SctTaxes.CouponTaxCode.ScCpnSourceShareTax>[1,1] NE '*' THEN
        COUP.TAX.CODE = R.COUP.TAX<SC.SctTaxes.CouponTaxCode.ScCpnSourceShareTax>
        R.DATA = ''
        TAX.DATE = R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdPayDate>
        IF NOT(TAX.DATE) THEN
            TAX.DATE = EB.SystemTables.getToday()
        END
        R.DATA = COUP.TAX.CODE:".":TAX.DATE
        R.DATA<2> = "TAX"
        CURRENCY = EB.SystemTables.getLccy()
        R.DATA<68> = "YES"
        CG.ChargeConfig.CalculateCharge("", '1000000', CURRENCY, "1", "", "", "", R.DATA, "", "", "")
        COUPON.TAX.RATE = R.DATA<13>
        IF COUPON.TAX.RATE AND TAX.RATE NE COUPON.TAX.RATE THEN
            WARN.DET<1,1,-1> = 'CUSTODIAN TAX = ':TAX.RATE:' DEFAULT TAX = ':COUPON.TAX.RATE
        END
    END

RETURN

*************
UPDATE.RATE:
*************

    IF RATE[1,3] MATCHES "3A" THEN
        IF NOT(R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdCurrency>) THEN
            R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdCurrency> = RATE[1,3]
        END
        CCY.POS = ''
        LOCATE RATE[1,3] IN CCY.ARR<1,1> SETTING CCY.POS THEN
            IF DEFAULT.OPTION.ARR<1,CCY.POS> EQ 'Y' THEN    ;* If default option currency then it is same as event currency, assign to Rate field
                R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdRate,CCY.POS> = RATE[4,15]
                R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdOptCcyExchRate,CCY.POS> = 1    ;*Rate between event and div ccy
* Assign optional currency rate
            END ELSE          ;*It is not default currency. So assign to dividend rate field
                R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdOptCcyDivRate,CCY.POS> = RATE[4,15]
            END
        END ELSE ;*Even though this is not available, Rate alone is to be updated - DVOP cases
            R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdRate,1> = RATE[4,15]
        END
    END ELSE
        R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdRate,1> = RATE
    END
RETURN

*------------------------------------------------------------------------
NARRATIVE.MAPPING:
*-----------------
    NARR.VM = 1
    IF NOT(R.NAU.PRE.DIARY) THEN
        R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdAddlNarrative> = ''
    END ELSE
        PREV.NARR.CNT = DCOUNT(R.NAU.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdAddlNarrative>,@VM)
        FOR PREV.NARR.NO = 1 TO PREV.NARR.CNT
            R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdAddlNarrative,PREV.NARR.NO> = '"':R.NAU.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdAddlNarrative><1,PREV.NARR.NO>:'"'
        NEXT PREV.NARR.NO
        NARR.VM = PREV.NARR.CNT + 1
    END
    NARR.CNT = DCOUNT(R.INWARD<SC.STP.DeIMsgFivFivx.IScAddnarrative>,@VM)
    FOR NARR.NO = 2 TO NARR.CNT
        START.NARR = 4 ; NARR.LOOP = 1
        NARR.LENGTH = LEN(NARR.INWARD<1,NARR.NO>) - 3
        MOD.NARR = FIELD((NARR.LENGTH/65),'.',1)
        REM.NARR = MOD(NARR.LENGTH,65)
        IF REM.NARR THEN
            MOD.NARR += 1
        END
        LOOP
        WHILE NARR.LOOP LE MOD.NARR
            R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdAddlNarrative,NARR.VM> = NARR.INWARD<1,NARR.NO>[START.NARR,65]
            START.NARR += 65
            NARR.LOOP += 1 ; NARR.VM += 1
        REPEAT
    NEXT NARR.NO
RETURN
*------------------------------------------------------------------------
***************************************************************************
UPDATE.GROSS.AMOUNT:
********************
    NET.AMOUNT = ''
    AMT.CNT = DCOUNT(R.INWARD<61>,@VM)
    FOR CNT = 1 TO AMT.CNT
        GROSS.AMT = R.INWARD<61,CNT>
        AMOUNT = FIELD(R.INWARD<62,CNT>,"//",2)
        LENGTH = LEN(AMOUNT)
        IF  GROSS.AMT = "GRSS" THEN
            R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdGrossAmount> =  AMOUNT[4,LENGTH]
        END

        IF GROSS.AMT = 'NETT' THEN
            NET.AMOUNT = AMOUNT[4,LENGTH]
        END

    NEXT CNT

RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name = ProcessPreDiary>
CREATE.OFS.RECORD:

    I.COUNT = '' ; SAVE.OFS.KEY = ''
    FOR I.COUNT = 1 TO CONCAT.COUNT
        IF CONCAT.COUNT GT 1 THEN
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

        PRE.DIARY.ID = SC.PRE.KEY<I.COUNT>        ;* Get pre diary id
        SECURITY.NO = ORIG.SEC.LIST<I.COUNT>      ;* get security number
        R.NAU.PRE.DIARY = '' ; PRD.NAU.ERR = ''
        IF PRE.DIARY.ID THEN  ;* Pre diary Exists
            R.NAU.PRE.DIARY = SC.SccEventNotification.PreDiary.ReadNau(PRE.DIARY.ID, PRD.NAU.ERR)   ;* Read NAU pre diary to append narrative
        END ELSE    ;* Create new pre diary
            R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdSecurityNo> = SECURITY.NO
        END
        GOSUB NARRATIVE.MAPPING

* Call the routine defined in SC.CA.PARAMETER to determine specific event type for security
        IF R.CA.PARAMETER<SC.SccConfig.CaParameter.ScCaEventTypeRtn> THEN
            EVENT.TYPE.RTN = R.CA.PARAMETER<SC.SccConfig.CaParameter.ScCaEventTypeRtn>
            DEPOSITORY = R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdDepository>
            EVENT.TYPE = ''
            CALL @EVENT.TYPE.RTN(SECURITY.NO,DEPOSITORY,LOAN.INDICATOR,CAEV.SWIFT.ID,ID.INWARD,EVENT.TYPE)    ;* Determine event type
            IF EVENT.TYPE AND EVENT.TYPE NE DIARY.TYPE.ID THEN        ;* If Diary type is different, Determine Partial STP for new event
                R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdEventType> = EVENT.TYPE
                R.DIARY.TYPE = SC.SccEventCapture.DiaryType.Read(EVENT.TYPE, '')
                PARTIAL.STP = ''        ;* Determine whether Event is full or partial stp
                IF R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DryPartialStp> THEN
                    PARTIAL.STP = R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DryPartialStp>
                    IF PARTIAL.STP NE 'ALL' THEN
                        R.PARTIAL.STP = SC.SccConfig.PartialStp.CacheRead(PARTIAL.STP, '')
                        PARTIAL.STP = R.PARTIAL.STP<SC.SccConfig.PartialStp.ScPstpType>
                    END
                END
            END
        END
        GOSUB DETERMINE.STP   ;* Determine STP based on event
        IF R.CA.PARAMETER<SC.SccConfig.CaParameter.ScCaStp> THEN
            GOSUB UPDATE.CA.LOG
        END
        OFS.DATA = ''
        IF R.INWARD<SC.STP.DeIMsgFivFivx.IScFunction> NE 'CANC' THEN
            EB.Foundation.OfsBuildRecord('SC.PRE.DIARY','I','PROCESS',R.DE.MESSAGE<DE.Config.Message.MsgInOfsVersion>,'1',NO.OF.AUTH,PRE.DIARY.ID,R.SC.PRE.DIARY,OFS.DATA)
            IF OFS.MESSAGE EQ '' THEN
                OFS.MESSAGE = OFS.DATA
            END ELSE
                OFS.MESSAGE  = OFS.MESSAGE:@VM:OFS.DATA
            END
        END
    NEXT I.COUNT
*

RETURN

** </region>
*-----------------------------------------------------------------------------
*** <region name = logupdate>
WRITE.OFS.LOG:
*------------
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
*------------------------------------------------------------------------
*************
DETERMINE.STP:
**************
* Locate for security number or sub asset type to find whether event is to be treated as partial stp.
    tmp.ETEXT = EB.SystemTables.getEtext()
    R.SECURITY.MASTER = SC.ScoSecurityMasterMaintenance.SecurityMaster.Read(SECURITY.NO, tmp.ETEXT)
    EB.SystemTables.setEtext(tmp.ETEXT)
    IF PARTIAL.STP AND PARTIAL.STP NE 'ALL' THEN  ;* If partial STP is setup security or sub asset wise
        LOCATE SECURITY.NO IN PARTIAL.STP<1,1> SETTING POS THEN
        END ELSE
            POS = ''
        END
        IF NOT(POS) THEN      ;* If security not set, locate for sub asset type
            SUB.ASSET.TYPE = 'S-':R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmSubAssetType>
            LOCATE SUB.ASSET.TYPE IN PARTIAL.STP<1,1> SETTING POS THEN
            END ELSE
                POS = ''
            END
            IF NOT(POS) THEN
                PARTIAL.STP = ''
            END
        END
    END
    IF R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmBondOrShare> EQ 'B' AND COUPON THEN
        SM.RATE = ''
        SC.ScoSecurityMasterMaintenance.GetRateChDate(R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmAccrualStartDate>,SECURITY.NO,SM.RATE)
        IF R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdRate> AND R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdRate> NE SM.RATE THEN
            WARN.DET<1,1,-1> = 'Rate in SECURITY.MASTER is ':SM.RATE:', Custodian Rate ':R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdRate>
        END

        IF R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdPayDate> NE R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmIntPaymentDate> THEN
            WARN.DET<1,1,-1> = 'Payment Date in SECURITY.MASTER is ':R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmIntPaymentDate>:', Custodian Pay date is ':R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdPayDate>
        END
    END

* Determine whether pre diary is to be authorised based on processing code and STP flag
    NO.OF.AUTH = ''
    IF (PARTIAL.STP OR (PROC.CODE NE 'PREC' AND PROC.CODE NE 'COMP')) AND R.CA.PARAMETER<SC.SccConfig.CaParameter.ScCaStp> THEN         ;* to create the SC.PRE.DIARY in authorised status,If the process stage as "COMP"
* Dont authorise pre diary if partial stp or in case of not confirmed
* No of authoriser should be from version if new STP processing is not required. Hence, Change only if new stp processing is enabled.
        NO.OF.AUTH = 1
    END

* Update field STP as YES if full stp processing
    IF NOT(PARTIAL.STP) THEN
        R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdStp> = 'YES'
    END
RETURN
*-----------------------------------------------------------------------------
UPDATE.CA.LOG:

    R.LIVE.PRE.DIARY = ''
    IF PRE.DIARY.ID THEN
        PRD.ERR = ''
        R.LIVE.PRE.DIARY = SC.SccEventNotification.PreDiary.Read(PRE.DIARY.ID, PRD.ERR)
    END
* For initial input of Pre diary, Log Id will be combination of Corp ref, depository and Loan
    CA.LOG.ID = R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdDepository>:'-':R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdLinkRef>
    IF R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdLoan> THEN
        CA.LOG.ID := '-LOAN'
    END
    CA.LOG.ID := '-':SECURITY.NO

    IF PRE.DIARY.ID THEN  ;* If Pre diary ID exists, Log id will be pre diary id
        CA.LOG.ID = PRE.DIARY.ID
    END
    IF R.LIVE.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdDiaryId> THEN ;* if Diary id exists in Pre diary, Log id will be diary id
        CA.LOG.ID = R.LIVE.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdDiaryId>
    END
    
    IF CA.LOG.ID[1,6] EQ 'SCPDIA' THEN                                           ;* if the log id formed is SC.PRE.DIARY id, form the log id.
        
        TXN.ID = CA.LOG.ID                                                       ;* pass SC.PRE.DIARY id to SC.GET.LOG.ID routine
        CORPREF = LINK.REF                                                       ;* Pass Corp Reference
        DEPO.ID = CONC.ID                                                        ;* Pass Depo id.
        SUB.ACCOUNT = ''                                                         ;* Sub account is blank here.
        SM.ID = ''                                                               ;* Reserved
        LOG.ID.FORMAT = R.CA.PARAMETER<SC.SccConfig.CaParameter.ScCaCaLogId>     ;* this holds either TXN.ID or CORP.REF from SC.CA.PARMAETER record for DIARY - pass it.
        
        SC.SccConfig.ScFormCaErrorLogId(TXN.ID, CORPREF, SUB.ACCOUNT, DEPO.ID, LOG.ID.FORMAT,SM.ID,CALOG.WITH.SUBACC, CALOG.WITHOUT.SUBACC) ;* call this routine to form the SC.CA.ERROR.LOG id.
        
* Id will be returned as either <ScPreDiaryid>-<Depo>-<Sub Account> for TXN.ID or <Corp ref>-<Depo>-<Sub account> for CORP.REF in SC.CA.PARAMETER and if segregated account set up is available in SC.PARAMETER with Sub Account available.
* if the segregated account set up is not available, then id will be <sc Pre diary> OR <Diary> for TXN.ID set up and <Corp Ref>-<Depo> for CORP.REF set up

        CA.LOG.ID = CALOG.WITH.SUBACC
    END
    
    LOG.ERR = ''
    SC.SccConfig.ScCaErrorLogLock(CA.LOG.ID,R.CA.ERROR,LOG.ERR,'','')
    IF LOG.ERR THEN
        R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerEventType> = R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdEventType> ;* Update event type
        R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerDepository> = R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdDepository>         ;* Depository
        R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerStp> = R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdStp>   ;* Whether full STP
        IF NOT(R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerStp>) THEN
            R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerStp> = 'NO'  ;* Partial STP
        END
        R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerLoan> = R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdLoan> ;* Whether lent or non lent
    END
    MV.POS = DCOUNT(R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerSecurityNo>,@VM) + 1
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerDelivRef,MV.POS> = ID.INWARD   ;* Inward delivery id
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerReceivingDate,MV.POS> = EB.SystemTables.getToday() ;* Message receiving date
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerMessageType,MV.POS> = MESSAGE.TYPE   ;* message
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerSemeRef,MV.POS> = R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdSourceRef>          ;* Source reference
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerCorpRef,MV.POS> = R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdLinkRef>  ;* Corp action ref
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerErrors,MV.POS> = ERR.DET       ;* Errors
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerWarnings,MV.POS> = WARN.DET    ;* warnings
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerSecurityNo,MV.POS> = SECURITY.NO         ;* security number in message
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerPayDate,MV.POS> = R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdPayDate>  ;* Pay date
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerExDate,MV.POS> = R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdExDate>    ;* Ex date
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerGrossCash,MV.POS> = R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdGrossAmount>      ;* Gross cash
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerNetCash,MV.POS> = NET.AMOUNT   ;* Net cash
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerQuantity,MV.POS> = ELIG.QTY    ;* Eligible quantity
    R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerStage,MV.POS> = PROC.CODE      ;* Processing stage
    COUNT.VM = DCOUNT(R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerErrors>,@VM)
    BEGIN CASE
        CASE R.INWARD<SC.STP.DeIMsgFivFivx.IScFunction> EQ 'CANC'     ;* Update status as Canc
            R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerStatus,MV.POS> = 'CANC'

        CASE R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerErrors><1,COUNT.VM>       ;* update status as errors
            R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerStatus,MV.POS> = 'ERR'

        CASE R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerWarnings><1,COUNT.VM>     ;* update status as warnings
            R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerStatus,MV.POS> = 'WARN'

        CASE 1      ;* If no errors encountered, Update ok
            R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerStatus,MV.POS> = 'OK'

    END CASE
    IF LOG.ERR THEN
        R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerCurrNo> = '1'
        R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerInputter> = 'SY_':EB.SystemTables.getTno():'_':EB.SystemTables.getOperator()
        X.DATE = OCONV(DATE(),"D-")
        DATE.TIME = X.DATE[9,2]:X.DATE[1,2]:X.DATE[4,2]:TIMEDATE()[1,2]:TIMEDATE()[4,2]
        R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerDateTime> = DATE.TIME
        R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerAuthoriser> = 'SY_':EB.SystemTables.getTno():'_':EB.SystemTables.getOperator()
        R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerCoCode> = EB.SystemTables.getIdCompany()
        R.CA.ERROR<SC.SccConfig.CaErrorLog.ScCaerDeptCode> = EB.SystemTables.getRUser()<EB.Security.User.UseDepartmentCode>
    END

    SC.SccConfig.ScCaErrorLogWrite(CA.LOG.ID, R.CA.ERROR,'')

    IF CALOG.WITH.SUBACC NE CALOG.WITHOUT.SUBACC THEN                                        ;* SC.CA.GET.LOG.ID will return same id in both variables, when Segregated account set up not there and sub account is not available, so to maintain another record, its checked both values not equal.
        R.CA.ERROR.SUBACC = ''
        LOG.ERR = ""
        SC.SccConfig.ScCaErrorLogLock(CALOG.WITHOUT.SUBACC,R.CA.ERROR.SUBACC,LOG.ERR,'','')  ;* Read & Lock the SC.CA.ERROR.LOG record id with out sub account formed earlier
        IF LOG.ERR THEN
            SC.SccConfig.ScCaErrorLogWrite(CALOG.WITHOUT.SUBACC,R.CA.ERROR,'')               ;* Update a SC.CA.ERROR.LOG record if the record for log without sub account doesn't exists.
        END
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.PROC.CODE>
GET.PROC.CODE:
*** <desc>Determine processing code </desc>
    PROC.CODE = R.INWARD<68>
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= GET.REFERENCE>
GET.REFERENCE:
*** <desc>Get corp and Seme reference </desc>
    REF = ''
    NO.REF = '' ; SOURCE.REF = '' ; LINK.REF = ''
    NO.REF = DCOUNT(R.INWARD<SC.STP.DeIMsgFivFivx.IScSenderReference>,@VM)
    FOR REF = 1 TO NO.REF
        BEGIN CASE
            CASE R.INWARD<SC.STP.DeIMsgFivFivx.IScSenderReference><1,REF> = "SEME"        ;* Assign sender reference
                SOURCE.REF = R.INWARD<SC.STP.DeIMsgFivFivx.IScCorpReference><1,REF>

            CASE R.INWARD<SC.STP.DeIMsgFivFivx.IScSenderReference><1,REF> = 'CORP'        ;* Assign corp reference
                LINK.REF = R.INWARD<SC.STP.DeIMsgFivFivx.IScCorpReference><1,REF>
        END CASE
    NEXT REF
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.QUANTITY>
GET.QUANTITY:
*** <desc>Get eligible or loan quantity </desc>
* Check whether inward message pertains to Loan
    LOAN.INDICATOR = ''
    ELIG.POS = ''
    ELIG.QTY = ''
    LOCATE 'LOAN' IN R.INWARD<38,1> SETTING ELIG.POS THEN         ;* Check whether message pertains to lent
        R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdLoan> = 'YES'  ;* Set field Loan
        LOAN.INDICATOR = 1          ;* Set Loan indicator
        WARN.DET<1,1,-1> = 'LENT POSITION IMPACTED'     ;* set the warning
    END ELSE    ;* Message pertains to non-lent
        LOCATE 'ELIG' IN R.INWARD<38,1> SETTING ELIG.POS ELSE
            NULL
        END
    END
    IF ELIG.POS THEN      ;* Get the quantity
        ELIG.QTY = R.INWARD<39,ELIG.POS>
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= GET.DEPOSITORY>
GET.DEPOSITORY:
*** <desc>Determine depo from safe account </desc>
    CONCAT.ID = ''
    CONC.ID = ''

    CTR.COUNT = DCOUNT(R.INWARD<SC.STP.DeIMsgFivFivx.IScSafeAccount>,@VM)
    FOR CTR = 1 TO CTR.COUNT
        IF FIELD(R.INWARD<SC.STP.DeIMsgFivFivx.IScSafeAccount,CTR>,'//',1) EQ 'SAFE' THEN
            CONC.ID = FIELD(R.INWARD<SC.STP.DeIMsgFivFivx.IScSafeAccount,CTR>,"//",2)
            CTR = CTR.COUNT
        END
    NEXT CTR
* Read SC.STD.CLEARING and determine depository pertaining to the safe account otherwise, fetch depo in message
    R.STD.CLEARING = ''
    ER = ''
    CONC.ID.LIST = ''
    ST.CompanyCreation.EbReadParameter('F.SC.STD.CLEARING','N','',R.STD.CLEARING,'','',ER)      ;* Read sc.std.clearing
    LOCATE CONC.ID IN R.STD.CLEARING<SC.Config.StdClearing.BsdSecDepotAc,1> SETTING CONC.POS THEN         ;* Locate for safekeep account
        CONC.ID.LIST<1,-1> = R.STD.CLEARING<SC.Config.StdClearing.BsdSecDepot,CONC.POS>         ;* Fetch Depo
        CONC.POS += 1
        LOOP
        WHILE CONC.POS    ;* Check whether same safekeep is linked to many depositories and get the list of depos
            LOCATE CONC.ID IN R.STD.CLEARING<SC.Config.StdClearing.BsdSecDepotAc,CONC.POS> SETTING CONC.POS THEN
                CONC.ID.LIST<1,-1> = R.STD.CLEARING<SC.Config.StdClearing.BsdSecDepot,CONC.POS>
                CONC.POS += 1
            END ELSE
                CONC.POS = ''
            END
        REPEAT
        DEPO.COUNT = DCOUNT(CONC.ID.LIST,@VM)
    END ELSE    ;* Depository in message is either customer number or All
        R.DE.I.HEADER = DE.Config.IHeader.Read(ID.INWARD,'')
        CONC.ID = R.DE.I.HEADER<DE.Config.IHeader.HdrCustomerNo>  ;* fetch the depository from customer number
        DEPO.COUNT = 1
        CONC.ID.LIST = CONC.ID
        IF NOT(NUM(CONC.ID)) THEN
            CONC.ID.LIST = 'ALL'
        END
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= CREATE.PRE.DIARY>
CREATE.PRE.DIARY:
*** <desc>Create Pre diary for each depo and security </desc>
    FOR DEPO.LOOP = 1 TO DEPO.COUNT ;* Create pre diary for each depo
        CONC.ID = CONC.ID.LIST<1,DEPO.LOOP>
        SC.PRE.KEY = ""
        CONCAT.ID = CONC.ID:'-':LINK.REF
        IF LOAN.INDICATOR THEN      ;* Add loan indicator to Id
            CONCAT.ID := '-LOAN'
        END

* For segregated accounts, Subsequent messages with the same combination(DEPOSITORY,CORP.REF,function,processing code) will be ignored and
* diary will not be created. only one diary record will be created
        R.CONCAT.REC.DUP = '' ; DUP.ERR = ''
        MSG.FUNC = R.INWARD<SC.STP.DeIMsgFivFivx.IScFunction>
        CONCAT.ID.DUP = CONC.ID :'.': LINK.REF :'.': MSG.FUNC :'.': PROC.CODE
* write the concat file to check if message with the same combination is processed
        SC.SccEventNotification.MtFivSixFouDuplicateConcatLock(CONCAT.ID.DUP,R.CONCAT.REC.DUP,DUP.ERR,'','')
        IF NOT(DUP.ERR) THEN
            CONTINUE
        END

        R.CONCAT.REC = '' ; YERR3 = '' ; NO.OF.REC = ''
        R.CONCAT.REC = SC.SccEventNotification.MtFivSixFouReference.Read(CONCAT.ID, YERR3)

        LIVE.RECORD = ''
        NO.OF.REC = DCOUNT(R.CONCAT.REC,@FM)
        FOR X1 = 1 TO NO.OF.REC
            RECORD.EXIST = '' ; YERR1 = '' ; LIVE.RECORD = ''
            R.PRE.DIARY = ''
            IF NOT(YERR3) THEN      ;*  If pre diary exists, amend existing
                PRE.DIARY.ID = R.CONCAT.REC<1>
                R.PRE.DIARY = SC.SccEventNotification.PreDiary.Read(PRE.DIARY.ID, YERR1)
                IF NOT(YERR1) THEN
                    RECORD.EXIST = 1
                    LIVE.RECORD = 1
                END
            END
            YERR2 = ''
            IF YERR1 AND NOT(YERR3) THEN      ;* Check whether pre diary exists
                R.PRE.DIARY = SC.SccEventNotification.PreDiary.ReadNau(PRE.DIARY.ID, YERR2)
                IF NOT(YERR2) THEN
                    RECORD.EXIST = 1
                END
            END

            IF RECORD.EXIST THEN    ;* Amend existing pre diary record
                LOCATE R.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdSecurityNo> IN ORIG.SEC.LIST<1> SETTING SEC.POS THEN ;* Add pre diary id in sync with security number
                    SC.PRE.KEY<SEC.POS> = R.CONCAT.REC<X1>
                END
            END

        NEXT X1
        R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdDepository> = CONC.ID
        GOSUB CREATE.OFS.RECORD
        SC.SccEventNotification.MtFivSixFouDuplicateConcatWrite(CONCAT.ID.DUP, '','') ;* Check whether message processed
    NEXT DEPO.LOOP
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.DATE>
GET.DATE:
*** <desc>Retreive Date from message </desc>
    DCT = ''
    NO.DATES = ''
    NO.DATES = DCOUNT(R.INWARD<SC.STP.DeIMsgFivFivx.IScCadetlDate>,@VM)
    FOR DCT = 1 TO NO.DATES
        BEGIN CASE
            CASE R.INWARD<SC.STP.DeIMsgFivFivx.IScCadetlDate><1,DCT> = 'XDTE'
                IF NUM(R.INWARD<SC.STP.DeIMsgFivFivx.IScEndCadetlDate><1,DCT>) THEN
                    R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdExDate> = R.INWARD<SC.STP.DeIMsgFivFivx.IScEndCadetlDate><1,DCT>
                END

            CASE R.INWARD<SC.STP.DeIMsgFivFivx.IScCadetlDate><1,DCT> = 'PAYD'
                IF (NOT(R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdPayDate>) OR R.INWARD<SC.STP.DeIMsgFivFivx.IScEndCadetlDate><1,DCT> LE R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdPayDate>) AND NUM(R.INWARD<SC.STP.DeIMsgFivFivx.IScEndCadetlDate><1,DCT>) THEN
                    R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdPayDate> = R.INWARD<SC.STP.DeIMsgFivFivx.IScEndCadetlDate><1,DCT>
                END

            CASE R.INWARD<SC.STP.DeIMsgFivFivx.IScCadetlDate><1,DCT> = 'RDTE'   ;* EN_10002353 s
* record date. only use for short position processing
                IF NUM(R.INWARD<SC.STP.DeIMsgFivFivx.IScEndCadetlDate><1,DCT>) THEN
                    R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdRecordDate> = R.INWARD<SC.STP.DeIMsgFivFivx.IScEndCadetlDate><1,DCT>
                END


            CASE R.INWARD<SC.STP.DeIMsgFivFivx.IScCadetlDate><1,DCT> = 'ETPD'
                IF NUM(R.INWARD<SC.STP.DeIMsgFivFivx.IScEndCadetlDate><1,DCT>) THEN
                    R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdEarlyDeadline> = R.INWARD<SC.STP.DeIMsgFivFivx.IScEndCadetlDate><1,DCT>
                END

        END CASE

    NEXT DCT

    IF NOT(R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdExDate>) THEN
        R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdExDate> = R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdRecordDate>
    END
    IF NOT(R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdPayDate>) THEN
        R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdPayDate> = R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdExDate>
    END

    IF R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdExDate> = '' THEN
        EB.SystemTables.setEtext('NO EX DATE')
        GOSUB WRITE.OFS.LOG
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.RATE>
GET.RATE:
*** <desc>Get rate, redemption price from message </desc>
* SWIFT field 92A for RATE.TYPE
    TAX.RATE = ''
    NO.RATES = ''
    RT = ''
    NO.RATES = DCOUNT(R.INWARD<SC.STP.DeIMsgFivFivx.IScCadetlRate>,@VM)
    FOR RT = 1 TO NO.RATES
        RATE = ''
        BEGIN CASE
            CASE R.INWARD<SC.STP.DeIMsgFivFivx.IScCadetlRate><1,RT> = "GRSS"
                R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdRateType> = 'GROSS'
                RATE = R.INWARD<SC.STP.DeIMsgFivFivx.IScEndCadetlRate><1,RT>
                IF RATE[1,4] MATCHES "4A" THEN
                    RATE =  FIELD(RATE,'/',2)
                END
                GOSUB UPDATE.RATE

            CASE R.INWARD<SC.STP.DeIMsgFivFivx.IScCadetlRate><1,RT> = "NETT"
* If gross rate is already updated dont update Net rate
                IF R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdRateType> EQ 'GROSS' THEN   ;*
                    CONTINUE
                END
                R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdRateType> = 'NET'

                RATE = R.INWARD<SC.STP.DeIMsgFivFivx.IScEndCadetlRate><1,RT>
                IF RATE[1,4] MATCHES "4A" THEN
                    RATE =  FIELD(RATE,'/',2)
                END
                GOSUB UPDATE.RATE

            CASE R.INWARD<SC.STP.DeIMsgFivFivx.IScCadetlRate><1,RT> = "INTP"
                RATE = R.INWARD<SC.STP.DeIMsgFivFivx.IScEndCadetlRate><1,RT>
                IF RATE[1,4] MATCHES "4A" THEN
                    RATE =  FIELD(RATE,'/',2)
                END
                GOSUB UPDATE.RATE

            CASE R.INWARD<SC.STP.DeIMsgFivFivx.IScCadetlRate><1,RT> = "TAXR"
                TAX.RATE = R.INWARD<SC.STP.DeIMsgFivFivx.IScEndCadetlRate><1,RT>
                GOSUB TAX.RATE.PROCESS

            CASE R.INWARD<SC.STP.DeIMsgFivFivx.IScCadetlRate><1,RT> = 'RATE'
                REDEM.PERC = R.INWARD<SC.STP.DeIMsgFivFivx.IScEndCadetlRate><1,RT>
                R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdRedemPercent> = REDEM.PERC

* Assign exchange rate between event currency and dividend currency if arrived under EXCH tag
            CASE R.INWARD<SC.STP.DeIMsgFivFivx.IScCadetlRate><1,RT> = 'EXCH'
                EXCH.RATE.ARR = R.INWARD<SC.STP.DeIMsgFivFivx.IScEndCadetlRate><1,RT>
                GOSUB EXCH.RATE.PROCESS


        END CASE
    NEXT RT

    REDEM.PRICE = ''
    LOCATE 'OFFR' IN R.INWARD<69,1> SETTING POS THEN
        REDEM.PRICE = R.INWARD<70,POS>
        IF NOT(NUM(REDEM.PRICE[1,3])) THEN
            REDEM.PRICE = REDEM.PRICE[4,15]
        END
    END
    IF REDEM.PRICE THEN
        R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdRate> = REDEM.PRICE
    END

    NEW.PRICE = ''
    LOCATE 'PRPP' IN R.INWARD<69,1> SETTING POS THEN    ;*Get new price for exercise of Diary and for oversubscription
        NEW.PRICE = R.INWARD<70,POS>
        IF NOT(NUM(NEW.PRICE[1,3])) THEN      ;*If prefixed by currency
            NEW.PRICE = NEW.PRICE[4,15]       ;*Extract price part alone
        END
    END
    IF NEW.PRICE AND R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdOverOptionDesc> THEN  ;* If oversubscription option exists
        R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdOverSubsPrice> = NEW.PRICE         ;*Assign price
    END

* If there is no rate qualifier default to GROSS
    IF R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DryCash> EQ "Y" AND R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdRateType> = '' THEN
        R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdRateType> = 'GROSS'
    END

    IF R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DryCash> EQ "Y" AND R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdRate> = '' THEN
        EB.SystemTables.setEtext('RATE MISSING')
        GOSUB WRITE.OFS.LOG
    END
RETURN
*** </region>

*************************
EXCH.RATE.PROCESS:
*********************
* To assign exchange rate between dividend currency and event currency

    CCY1 = FIELD(EXCH.RATE.ARR,'/',1)
    CCY2 = FIELD(EXCH.RATE.ARR,'/',2)
    EXCH.RATE = FIELD(EXCH.RATE.ARR,'/',3)

    BEGIN CASE
        CASE CCY1 EQ R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdCurrency>       ;* If currency1 is event CCY, currency 2 is dividend CCY. Locate for dividend currency and assign exchange rate
            LOCATE CCY2 IN R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdCashCcy,1> SETTING POS.CCY THEN         ;*Locate and assign Rate
                R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdOptCcyExchRate,POS.CCY> = EXCH.RATE
            END

        CASE CCY2 EQ R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdCurrency>       ;* If currency2 is event CCY, currency 1 is dividend CCY. Locate for dividend currency and assign exchange rate
            LOCATE CCY1 IN R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdCashCcy,1> SETTING POS.CCY THEN         ;*Locate and assign Rate
                R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdOptCcyExchRate,POS.CCY> = EXCH.RATE
            END
    END CASE

RETURN
*-----------------------------------------------------------------------------

*** <region name= GET.DIARY.TYPE>
GET.DIARY.TYPE:
*** <desc>From the CAEV Tag, Identifying DIARY.TYPE and store its record. </desc>
    CT = ''
    NO.CAEV = ''
    NO.CAEV = DCOUNT(R.INWARD<SC.STP.DeIMsgFivFivx.IScCaevQual>,@VM)
    CAEV.SWIFT.ID = ''
    R.SC.CON.SWIFT.CAEV = ''
    FOR CT = 1 TO NO.CAEV
        IF R.INWARD<SC.STP.DeIMsgFivFivx.IScCaevQual><1,CT> = 'CAEV' THEN
            CAEV.SWIFT.ID = R.INWARD<SC.STP.DeIMsgFivFivx.IScCaev><1,CT>
            tmp.ETEXT = EB.SystemTables.getEtext()
            R.SC.CON.SWIFT.CAEV = SC.SccEventCapture.ScConSwiftCaev.Read(R.INWARD<SC.STP.DeIMsgFivFivx.IScCaev><1,CT>,tmp.ETEXT)
            EB.SystemTables.setEtext(tmp.ETEXT)
        END
*Skip this here and do it after after DIARY.TYPE finding.
*        IF EB.SystemTables.getEtext() THEN
*            EB.SystemTables.setEtext('DIARY.TYPE RECORD NOT FOUND FOR CA EVENT')
*            GOSUB WRITE.OFS.LOG
*        END
        IF R.INWARD<SC.STP.DeIMsgFivFivx.IScCaevQual><1,CT> EQ 'CAMV' THEN  ;*Assign mandatory voluantry or choice flag
            R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdMandVoluFlag> = R.INWARD<SC.STP.DeIMsgFivFivx.IScCaev><1,CT>
        END
    NEXT CT
*
*Cases when multiple DIARY.TYPEs are associated with single SWIFT.CAEV field,
*then DIARY.TYPE is to be choosed based on MAND,VOLU Flag.
    DIARY.TYPE.COUNT = DCOUNT(R.SC.CON.SWIFT.CAEV,@FM)
    R.DIARY.TYPE = ''
    CT = 0
    LOOP
        CT+=1
    WHILE CT LE DIARY.TYPE.COUNT AND R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdEventType> EQ ''
        DIARY.TYPE.ID = R.SC.CON.SWIFT.CAEV<CT>
        R.DIARY.TYPE = SC.SccEventCapture.DiaryType.Read(DIARY.TYPE.ID,'')
        BEGIN CASE
            CASE DIARY.TYPE.COUNT EQ 1
                R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdEventType> = DIARY.TYPE.ID

            CASE R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdMandVoluFlag> EQ 'MAND' AND R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DryOptions> EQ 'NO'
                R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdEventType> = DIARY.TYPE.ID

            CASE R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdMandVoluFlag> NE 'MAND' AND R.DIARY.TYPE<SC.SccEventCapture.DiaryType.DryOptions> EQ 'Y'
                R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdEventType> = DIARY.TYPE.ID

            CASE 1
                R.DIARY.TYPE = ''
        END CASE
    REPEAT
*When no such DIARY.TYPE is found , then log is to be updated with this error.
    IF NOT(R.DIARY.TYPE) THEN
        EB.SystemTables.setEtext('DIARY.TYPE RECORD NOT FOUND FOR CA EVENT')
        GOSUB WRITE.OFS.LOG
    END
    DIARY.TYPE.ID = R.SC.PRE.DIARY<SC.SccEventNotification.PreDiary.ScPrdEventType>
    LOCATE DIARY.TYPE.ID IN R.SC.PARAMETER<SC.Config.Parameter.ParamCouponType,1> SETTING COUPON THEN
    END ELSE
        COUPON = ''
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= MX.PROCESS>
MX.PROCESS:
*** <desc>Convert the SEEV031 MX message to MT 564 message </desc>
    
    VAR1 = ''
    DEFFUN CHARX(VAR1) ;*Defining Function
    
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

    EB.TRANSFORM.ID = 'SC-SEEV031'

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
        EB.ErrorProcessing.ExceptionLog("S","SC.MT564.QUEUE","SC.OFS.SEEV031.MAPPING","SECURITIES",'',RESULT.XML,'SC.MT564.QUEUE',tmp.R.KEY,'1',RESULT.XML,'')
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
            GOSUB CALL.TO.OBM
            TXN.REF = FIELD(OFS.MESSAGE.RESPONSE, '/' ,1)
            DE.Inward.setRHead(DE.Config.OHeader.HdrTransRef,TXN.REF)
        NEXT X
    END
    DE.Inward.setRHead(DE.Config.OHeader.HdrCompanyCode, EB.SystemTables.getIdCompany())
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
** <region name = CALL.TO.OBM>
CALL.TO.OBM:

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
