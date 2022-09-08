* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>725</Rating>
*-----------------------------------------------------------------------------
* Version 6 12/06/01  GLOBUS Release No. G12.0.00 29/06/01
    $PACKAGE AC.ModelBank

    SUBROUTINE E.FIND.MATURITY
*-------------------------------------------------
*
* This subroutine will be used to
*  to find out the maturity date for the Re.Consol.spec.Entry
* being processed.
*
* The fields used are as follows:-
*
* INPUT   ID              Id of the record
*                         being processed.
*
*         R.RECORD        record being processed
*
*         VC              Pointer to the current
*                         multi-value set being
*                         processed.
*
*         S               Pointer to the current
*                         sub-value set being
*                         processed.
*
*
* OUTPUT O.DATA           The expected maturity date
*---------------------------------------------------
* 09/06/04 - EN_10002141/EN_10002135
*            Multibooking changes
* 04/02/04 - BG_10006150
*            Multibook bug fixes
*
* 08/10/08 - BG_100020322 - dadkinson@temenos.com
*            TTS0803790
*            Fatal in OPF when running enquiry CH.SPEC.ENT.MAT
*            following a DIARY redemption.
*
* 29/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*-------------------------------------------------Insert statements
    $USING EB.SystemTables
    $USING MM.Contract
    $USING EB.DataAccess
    $USING SC.SctTrading
    $USING LM.Contract
    $USING LM.Config
    $USING AC.EntryCreation
    $USING FX.Contract
    $USING LD.Contract
    $USING FD.Contract
    $USING FR.Contract
    $USING MG.Contract
    $USING MD.Contract
    $USING LI.Config
    $USING SC.SctOffMarketTrades
    $USING SC.ScoSecurityMasterMaintenance
    $USING SC.ScoSecurityPositionUpdate
    $USING SC.SccEntitlements
    $USING ST.CompanyCreation
    $USING EB.Reports

    GOSUB INITIALISE

    GOSUB GET.APPLICATION

    GOSUB SETUP.MATURITY.DATE

    RETURN
*
************************************************************************
INITIALISE:
    APP = EB.Reports.getRRecord()<AC.EntryCreation.ReConsolSpecEntry.ReCseSystemId>
    TXN.REF = EB.Reports.getRRecord()<AC.EntryCreation.ReConsolSpecEntry.ReCseTransReference>
    MATURITY.DATE = EB.Reports.getRRecord()<AC.EntryCreation.ReConsolSpecEntry.ReCseNarrative,1>
    FILE.KEY = TXN.REF
    FILE.KEY2 = ''
    SC.APP = TXN.REF[1,6]
    FD.APP = TXN.REF[1,4]
    CON.KEY = EB.Reports.getRRecord()<AC.EntryCreation.ReConsolSpecEntry.ReCseConsolKeyType>
    COUNT.DOT = COUNT(CON.KEY,".")
    COUNT.DOT.TYPE = COUNT.DOT + 1
    KEY.ONLY = FIELD(CON.KEY,'.',1,COUNT.DOT)
    TYPE = FIELD(CON.KEY,'.',COUNT.DOT.TYPE)
    FIELD.PART = ''
*
    RETURN
*
************************************************************************
*
GET.APPLICATION:
*
* Determine the application from the id and open the relevant file.
*
    FILE.NAME = ''
    FIELD.POS = ''
    FILE.NAME2 = ''
    FIELD.POS2 = ''
    FILE.NAMESC = ''
    FIELD.POSSC = ''

    BEGIN CASE
        CASE TXN.REF[5] = 'REVAL'
            FILE.NAME = 'NONE'
            FIELD.POS = 'NONE'
        CASE APP EQ 'FX'
            FILE.NAME = 'F.FOREX'
            IF TYPE[3] EQ "BUY" OR TYPE[5] EQ "BUYBL" THEN
                FIELD.POS = FX.Contract.Forex.ValueDateBuy
            END ELSE
                FIELD.POS = FX.Contract.Forex.ValueDateSell
            END
        CASE APP EQ 'MM'
            IF NUM(TYPE) THEN
                F.LMM.INSTALL.CONDS = ""
                Y.LMM.INSTALL.CONDS.REC =""
                LD.PARAM.ID = ""
                EB.DataAccess.Opf("F.RE.LMM.INSTALL.CONDS",F.LMM.INSTALL.CONDS)
                READ.FAILED = ''
                ST.CompanyCreation.EbReadParameter("F.RE.LMM.INSTALL.CONDS",'N',"",Y.LMM.INSTALL.CONDS.REC,LD.PARAM.ID,F.LMM.INSTALL.CONDS,READ.FAILED)
                IF TYPE = Y.LMM.INSTALL.CONDS.REC<LM.Config.LmmInstallConds.LdThrZerPlOSetIrCur> OR TYPE = Y.LMM.INSTALL.CONDS.REC<LM.Config.LmmInstallConds.LdThrZerPlOSetIpCur> THEN
                    FILE.NAME = 'F.LMM.ACCOUNT.BALANCES'
                    FIELD.POS = LM.Contract.LmmAccountBalances.LdTwoSevEndPeriodInt
                    FILE.KEY := '00'
                    FILE.NAME2 = 'F.LMM.ACCOUNT.BALANCES'
                    FIELD.POS2 = LM.Contract.LmmAccountBalances.LdTwoSevStartPeriodInt
                END ELSE
                    FILE.NAME = 'NONE'
                    FIELD.POS = 'NONE'
                END
            END ELSE
                FILE.NAME = 'F.MM.MONEY.MARKET'
                FIELD.POS = MM.Contract.MoneyMarket.MaturityDate
            END
        CASE APP EQ 'LD'
            IF NUM(TYPE) THEN
                F.LMM.INSTALL.CONDS = ""
                EB.DataAccess.Opf("F.RE.LMM.INSTALL.CONDS",F.LMM.INSTALL.CONDS)
                LD.PARAM.ID = ''          ;* EN_10002135 S
                Y.LMM.INSTALL.CONDS.REC = ''
                READ.FAILED = ''
                ST.CompanyCreation.EbReadParameter("F.RE.LMM.INSTALL.CONDS",'N',"",Y.LMM.INSTALL.CONDS.REC,LD.PARAM.ID,F.LMM.INSTALL.CONDS,READ.FAILED)

                IF TYPE = Y.LMM.INSTALL.CONDS.REC<LM.Config.LmmInstallConds.LdThrZerPlOSetIrCur> OR TYPE = Y.LMM.INSTALL.CONDS.REC<LM.Config.LmmInstallConds.LdThrZerPlOSetIpCur> OR TYPE = Y.LMM.INSTALL.CONDS.REC<LM.Config.LmmInstallConds.LdThrZerPlOSetIra> OR TYPE = Y.LMM.INSTALL.CONDS.REC<LM.Config.LmmInstallConds.LdThrZerPlOSetIpa> THEN
                    FILE.NAME = 'F.LMM.ACCOUNT.BALANCES'
                    FIELD.POS = LM.Contract.LmmAccountBalances.LdTwoSevEndPeriodInt
                    FILE.KEY := '00'
                    FILE.NAME2 = 'F.LMM.ACCOUNT.BALANCES'
                    FIELD.POS2 = LM.Contract.LmmAccountBalances.LdTwoSevStartPeriodInt
                END ELSE
                    FILE.NAME = 'NONE'
                    FIELD.POS = 'NONE'
                END
            END ELSE
                FILE.NAME = 'F.LD.LOANS.AND.DEPOSITS'
                FIELD.POS = LD.Contract.LoansAndDeposits.FinMatDate
            END
        CASE APP EQ 'FR'
            FILE.NAME = 'F.FRA.DEAL'
            FIELD.POS = FR.Contract.FraDeal.FrdMaturityDate
        CASE APP EQ 'MG'
            IF NUM(TYPE) THEN
                FILE.NAME = 'F.MG.BALANCES'
                FIELD.POS = MG.Contract.Balances.BalEndIntPeriod
                FILE.NAME2 = 'F.MG.BALANCES'
                FIELD.POS2 = MG.Contract.Balances.BalStartIntPeriod
            END ELSE
                FILE.NAME = 'F.MG.MORTGAGE'
                FIELD.POS = MG.Contract.Mortgage.MaturityDate
                FILE.NAME2 = 'F.MG.MORTGAGE'
                FIELD.POS2 = MG.Contract.Mortgage.OriginalMatDate
            END
        CASE APP EQ 'FD'
            IF FD.APP EQ "FDOR" THEN
                FILE.NAME = "F.FD.FID.ORDER"
                FIELD.POS = FD.Contract.FidOrder.OrdMaturityDate
            END ELSE
                FILE.NAME = "F.FD.FIDUCIARY"
                FIELD.POS = FD.Contract.Fiduciary.MaturityDate
            END
        CASE APP EQ 'SC'
            FILE.NAME = 'F.SECURITY.MASTER'
            IF NUM(TYPE) THEN
                FIELD.POS = SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmIntPaymentDate
                FILE.NAME2 = 'F.SECURITY.MASTER'
                FIELD.POS2 = SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmMaturityDate
            END ELSE
                FIELD.POS = SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmMaturityDate
            END
            SC.TXN.POS = FIELD(TXN.REF,'-',1,1)
            IF NUM(SC.TXN.POS) THEN
                FILE.KEY = FIELD(TXN.REF,'.',2,1)
            END ELSE
                FILE.KEYSC = FILE.KEY
                BEGIN CASE
                    CASE SC.APP EQ 'SCTRSC'
                        FILE.NAMESC = 'F.SEC.TRADE'
                        FIELD.POSSC = SC.SctTrading.SecTrade.SbsSecurityCode
                    CASE SC.APP EQ 'SECTSC'
                        FILE.NAMESC = 'F.SECURITY.TRANSFER'
                        FIELD.POSSC = SC.SctOffMarketTrades.SecurityTransfer.ScStrSecurityNo
                    CASE SC.APP EQ 'BDRDSC'
                        FILE.NAMESC = 'F.SECURITY.TRANS'
                        FIELD.POSSC = SC.ScoSecurityPositionUpdate.SecurityTrans.SctSecurityNumber
                        FILE.KEYSC := '.1'
                    CASE SC.APP EQ 'DIARSC'              ;* BG_100020322 S
                        FILE.NAMESC = 'F.ENTITLEMENT'
                        FIELD.POSSC = SC.SccEntitlements.Entitlement.EntSecurityNo  ;* BG_100020322 E
                END CASE
                FILESC = ''
                EB.DataAccess.Opf(FILE.NAMESC,FILESC)
                *
                EB.DataAccess.FRead(FILE.NAMESC,FILE.KEYSC,RECSC,FILESC,ER)

                IF ER THEN
                    RECSC = ''
                END

                FILE.KEY = RECSC<FIELD.POSSC>
            END
        CASE APP EQ 'MD'
            FILE.NAME = 'F.MD.DEAL'
            FIELD.POS = MD.Contract.Deal.DeaMaturityDate
        CASE APP EQ 'LI'
            FILE.NAME = 'F.LIMIT'
            FIELD.POS = LI.Config.Limit.ExpiryDate
        CASE 1
            FILE.NAME = 'NONE'
            FIELD.POS = 'NONE'
    END CASE

    RETURN
*
************************************************************************
*
SETUP.MATURITY.DATE:
*

    IF FILE.NAME NE 'NONE' THEN
        FILE = ''
        EB.DataAccess.Opf(FILE.NAME,FILE)
        *
        EB.DataAccess.FRead(FILE.NAME,FILE.KEY,REC,FILE,ER)

        IF ER THEN
            REC = ''
        END

        CHECK.MAT = REC<FIELD.POS>
        BEGIN CASE
            CASE MATURITY.DATE EQ CHECK.MAT
                EB.Reports.setOData(CHECK.MAT:'\\')
            CASE FILE.NAME EQ 'F.SECURITY.MASTER' AND FIELD.POS EQ SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmMaturityDate AND MATURITY.DATE EQ '0'
                EB.Reports.setOData(CHECK.MAT:'\\':'  SEC')
            CASE MATURITY.DATE NE CHECK.MAT AND NOT(FILE.NAME2)
                EB.Reports.setOData(CHECK.MAT:'\\':'*DIFF*')
            CASE FILE.NAME EQ FILE.NAME2
                CHECK.MAT2 = REC<FIELD.POS2>
                IF MATURITY.DATE EQ CHECK.MAT2 THEN
                    EB.Reports.setOData(CHECK.MAT:'\':CHECK.MAT2:'\':' MAT2 ')
                END ELSE
                    EB.Reports.setOData(CHECK.MAT:'\':CHECK.MAT2:'\':'*DIFF*')
                END
            CASE 1
                FILE2 = ''
                IF NOT(FILE.KEY2) THEN
                    FILE.KEY2 = FILE.KEY
                END
                EB.DataAccess.Opf(FILE.NAME2,FILE2)
                *
                EB.DataAccess.FRead(FILE.NAME2,FILE.KEY2,REC2,FILE2,ER)

                IF ER THEN
                    REC2 = ''
                END

                CHECK.MAT2 = REC2<FIELD.POS2>
                IF MATURITY.DATE EQ CHECK.MAT2 THEN
                    EB.Reports.setOData(CHECK.MAT:'\':CHECK.MAT2:'\':' MAT2 ')
                END ELSE
                    EB.Reports.setOData(CHECK.MAT:'\':CHECK.MAT2:'\':'*DIFF*')
                END
        END CASE
    END ELSE
        EB.Reports.setOData('')
    END
    RETURN
*
************************************************************************
    END
