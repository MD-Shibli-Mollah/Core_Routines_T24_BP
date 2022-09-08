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
* <Rating>913</Rating>
*-----------------------------------------------------------------------------
* Update TXN.REF of Consol Ent Today with STP.ID so that EOD.CONSOL.UPDATE
* raises SPEC Entry during EOD. As SC.EOD.TRADE.UPD.CONSOL is made Adhoc.
*----------------------------------------------------------------------------
* 15/07/04 - BG_100006960
*            BG for EN_10002167.
*
* 24/09/04 - CI_10023440
*            Fatal out occurs during EOD.CONSOL.UPDATE.
*            Ref. HD0412233.
*            The updation of CET from SC.CONSOL.ENTRIES needs to be done
*            by locating the amount appropriately for the Portfolio.
*
* 26/09/05 - CI_10034992
*            Crash during upgrade from G11 to R05 due to wrong conversion in CET
*            records that were created on the day of upgrade.
*
* 07/06/06 - CI_10041684
*            STP id not appended to CET Txn ref. after conversion
*
* 26/02/07 - CI_10047447
*            COB crashed at batch SC.BATCH.APP in the job SC.UPD.STP.BALANCES
*
* 29/10/07 - CI_10052240
*            For the DISCOUNT BOND Trade,CONVERSION program fails to update the
*            TXN.REF in the format of (SEC.TRADE.ID..STPID).
*
* 10/12/07 - CI_10052843
*            Select statement throws an parse error.
*-----------------------------------------------------------------------------

    $PACKAGE SC.SctDealerBook
    SUBROUTINE CONV.CONSOL.ENT.TODAY.G150

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CONSOL.ENT.TODAY
    $INSERT I_F.SC.ENT.TODAY

    FN.CET = 'F.CONSOL.ENT.TODAY'
    FV.CET = ''
    CALL OPF(FN.CET,FV.CET)

    FN.SC.CONSOL.ENT = 'F.SC.CONSOL.ENTRIES'
    FV.SC.CONSOL.ENT = ''
    CALL OPF(FN.SC.CONSOL.ENT,FV.SC.CONSOL.ENT)

    FN.SAM = 'F.SEC.ACC.MASTER'
    F.SAM  = ''
    CALL OPF(FN.SAM, F.SAM)

    SEL.CMD = "SELECT ":FN.CET:" WITH PRODUCT EQ 'SC'"
    EXECUTE SEL.CMD
    Y.KEYS.ADDED = ''
    LOOP
        READNEXT CET.ID ELSE NULL
    WHILE CET.ID DO
        READ R.CET.REC FROM FV.CET,CET.ID THEN
            IF R.CET.REC<RE.CET.TYPE>[1,7] = 'FORWARD' THEN
                IF FIELD(R.CET.REC<RE.CET.TXN.REF>,'*',2) ELSE
                    DELETE FV.CET,CET.ID
                END
            END ELSE
                GOSUB PROCESS.CET
            END
        END
    REPEAT

    RETURN
*--------------
PROCESS.CET:
*--------------
    IF FIELD(R.CET.REC<RE.CET.TXN.REF>,'*',2) ELSE
        TRANS.REF = ''
        REV.INDICATOR = ''
        IF R.CET.REC<RE.CET.TXN.REF> MATCHES '6A0N' THEN
            TRANS.REF = R.CET.REC<RE.CET.TXN.REF>
        END ELSE
            SC.ENT.TODAY.ID = FIELD(R.CET.REC<RE.CET.TXN.REF>,'.',5):'.':FIELD(R.CET.REC<RE.CET.TXN.REF>,'.',1)
            POSN = '' ; YERR = '' ; R.SC.ENT.TODAY = ''
            CALL F.READ('F.SC.ENT.TODAY',SC.ENT.TODAY.ID,R.SC.ENT.TODAY,'',YERR)
            LOCATE R.CET.REC<RE.CET.TXN.REF> IN R.SC.ENT.TODAY<SC.ENTTD.ID.RECORD,1> SETTING POSN THEN
                TRANS.REF = R.SC.ENT.TODAY<SC.ENTTD.TRANS.REF,POSN>
            END
        END
        READ R.SC.CONSOL.ENT.REC FROM FV.SC.CONSOL.ENT,TRANS.REF THEN
            POSN.KEY = R.SC.CONSOL.ENT.REC<1>
            AMT.VAL = R.SC.CONSOL.ENT.REC<2>

            Y.CNT = DCOUNT(POSN.KEY, VM)
            GOSUB UPDATE.CET
        END
    END
    RETURN
*--------------
UPDATE.CET:
*--------------
    FOR I = 1 TO Y.CNT
        Y.KEY = POSN.KEY<1, I>
        Y.AMT = AMT.VAL<1, I>
        Y.CUST = R.CET.REC<RE.CET.CUSTOMER>
        IF Y.CUST <> FIELD(Y.KEY, '-', 1) THEN
            CONTINUE
        END
        TRANS.CODE = R.SC.CONSOL.ENT.REC<8, I>
        BEGIN CASE
*When its of type other than LIVEDB eg. 52000, 51600 etc.
        CASE NUM(R.CET.REC<RE.CET.TYPE>)
            Y.SAM.ID = FIELD(Y.KEY, '.', 1)
            CALL F.READ(FN.SAM, Y.SAM.ID, R.SAM.REC, F.SAM, ERR )

            Y.INT.CAT = R.SAM.REC<44>:VM:R.SAM.REC<43>      ;*SC.SAM.INT.RECD.CAT,SC.SAM.INT.PAID.CAT
            Y.CAP.CAT = R.SAM.REC<89>:VM:R.SAM.REC<88>      ;*SC.SAM.CAP.RECD.CAT,SC.SAM.CAP.PAID.CAT

            IF R.CET.REC<RE.CET.TYPE> MATCHES Y.INT.CAT THEN
                Y.AMT = R.SC.CONSOL.ENT.REC<5, I>
            END ELSE
                Y.AMT = R.SC.CONSOL.ENT.REC<12, I>          ;*Y.CAP.CAT
                Y.AMT = -1 * Y.AMT
            END
        END CASE
        IF R.CET.REC<RE.CET.CURRENCY> = LCCY THEN
            IF TRANS.CODE = 'DB' AND R.CET.REC<RE.CET.LOCAL.DR> THEN
                CONSID.POS = RE.CET.LOCAL.DR
            END ELSE
                IF TRANS.CODE = 'DB' AND R.CET.REC<RE.CET.LOCAL.CR> THEN
                    REV.INDICATOR = "R"
                    CONSID.POS = RE.CET.LOCAL.CR
                    Y.AMT = -1 * Y.AMT
                END
            END
            IF TRANS.CODE = 'CR' AND R.CET.REC<RE.CET.LOCAL.CR> THEN
                CONSID.POS = RE.CET.LOCAL.CR
            END ELSE
                IF TRANS.CODE = 'CR' AND R.CET.REC<RE.CET.LOCAL.DR> THEN
                    REV.INDICATOR = "R"
                    CONSID.POS = RE.CET.LOCAL.DR
                    Y.AMT = -1 * Y.AMT
                END
            END
        END ELSE
            IF TRANS.CODE = 'DB' AND R.CET.REC<RE.CET.FOREIGN.DR> THEN
                CONSID.POS = RE.CET.FOREIGN.DR
            END ELSE
                IF TRANS.CODE = 'DB' AND R.CET.REC<RE.CET.FOREIGN.CR> THEN
                    REV.INDICATOR = "R"
                    CONSID.POS = RE.CET.FOREIGN.CR
                    Y.AMT = -1 * Y.AMT
                END
            END
            IF TRANS.CODE = 'CR' AND R.CET.REC<RE.CET.FOREIGN.CR> THEN
                CONSID.POS = RE.CET.FOREIGN.CR
            END ELSE
                IF TRANS.CODE = 'CR' AND R.CET.REC<RE.CET.FOREIGN.DR> THEN
                    REV.INDICATOR = "R"
                    CONSID.POS = RE.CET.FOREIGN.DR
                    Y.AMT = -1 * Y.AMT
                END
            END
        END

        IF Y.AMT = R.CET.REC<CONSID.POS>  THEN
            Y.TXN.REF = ''
            POS = 0
            IF REV.INDICATOR THEN
                Y.TXN.REF = R.CET.REC<RE.CET.TXN.REF>:'*':Y.KEY:'*':R.CET.REC<RE.CET.TYPE>:'*':REV.INDICATOR
            END ELSE
                Y.TXN.REF = R.CET.REC<RE.CET.TXN.REF>:'*':Y.KEY:'*':R.CET.REC<RE.CET.TYPE>
            END
            LOCATE Y.TXN.REF IN Y.KEYS.ADDED<1> SETTING POS ELSE POS = 0
            IF POS > 0 THEN CONTINUE    ;*Key already associated for the same Amount.
            R.CET.REC<RE.CET.TXN.REF> = R.CET.REC<RE.CET.TXN.REF>:'*':Y.KEY
            WRITE R.CET.REC TO FV.CET,CET.ID
            IF REV.INDICATOR THEN
                Y.KEYS.ADDED<-1> = R.CET.REC<RE.CET.TXN.REF>:'*':R.CET.REC<RE.CET.TYPE>:'*':REV.INDICATOR
            END ELSE
                Y.KEYS.ADDED<-1> = R.CET.REC<RE.CET.TXN.REF>:'*':R.CET.REC<RE.CET.TYPE>
            END
            BREAK
        END
    NEXT I
    RETURN
*----------------------------------------------------------------------------------
END
