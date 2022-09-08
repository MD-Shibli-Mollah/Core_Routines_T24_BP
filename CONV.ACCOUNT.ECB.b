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
* <Rating>-91</Rating>
*-----------------------------------------------------------------------------
* Version 46 25/10/00 GLOBUS Release No. G14.0.00 03/07/03
*
*************************************************************************
*
    $PACKAGE RE.ConBalanceUpdates
    SUBROUTINE CONV.ACCOUNT.ECB(ACCT.ID)
*
*************************************************************************
* This routine will initialise Open.Asset.Type and the Consol.Key field
* in the Account record.
* It will also build the EB.CONTRACT.BALANCES record for that account.
* It will first get the balance from the account and build the EB.CONTRACT.BALANCES
* then loop through the accrual interest and charges.
*===============================================================================
* MAINTENANCE
* ===========
* 08/05/06 - BG_100011162
*            Clear Contingent Bal CR/DR
* 16/05/06 - BG_100011187
*            Open.Asset.Type could be blank for if a/c has no real entries and only contingent.
* 24/05/06 - BG_100011274
*            Cater for self balancing and get the correct local balance for contingent.
*
* 30/12/07 - CI_10053160
*            FATAL.ERROR in EOD.CONSOL.UPDATE when running COB after upgrade from R05 to R07.
*
* 11/02/08 - CI_10053659
*            OPEN.ASSET.TYPE not updated in EB.CONTRACT.BALANCES record during first COB
*            in JOB EOD.AC.CONV.ENTRY.
*
* 16/02/08 - BG_100017116
*            Accrual amounts for accounts are fetched from RE.CONTRACT.BALANCES instead of
*            account to avoid mismatch.

* 07/17/08 - CI_10056819/Ref: HD0812187
*            When building the spec entries from consol.ent.today entries populate the local amounts also
*            for foreign currencies. Also populate the our.reference after reading the stmt.id if stmt.id
*            is populated in the ENTRY.ID field of consol.ent.today.
*
* 25/11/09 - CI_10067781
*            In a Multi Book company environment always fetch company code from Account record.
*            If transactions were inputted before creating a book company then consol key won't
*            have company code. In APPLICATION.ID<3>, pass comapny code to be updated in ECB record.
*
* 28/07/2010 - DEFECT 70550 / TASK 71748
*              Initialize the OPEN.ASSET.TYPE variable even the account's open actual bal is null is lower release
*              Made changes in CONV.ACCOUNT.ECB not to call this routine to update
*              open balance '0' when OPEN.ASSET.TYPE as "NILOPEN"
*
* 26/10/2010 - DEFECT 110712 / TASK 112258
*              All contingent self balance asset type needs to update in ECB.
*----------------------------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.DATES
    $INSERT I_F.ACCOUNT.PARAMETER
    $INSERT I_F.STMT.ENTRY
    $INSERT I_EOD.AC.CONV.ENTRY.COMMON
    $INSERT I_F.CONSOL.ENT.TODAY
    $INSERT I_F.RE.CONTRACT.BALANCES
*------------------------------------------------------------------------------------------------
*
    WRITE.REC = "1" ;* This is set as all the calls to EB.CONTRACT.BALANCES.BUILD will write to EB.CONTRACT.BALANCES

    GOSUB READ.ACCOUNT


    IF ACCT.REC<AC.OPEN.ASSET.TYPE> NE '' OR  ACCT.REC<AC.CONSOL.KEY> NE '' THEN          ;* BG_1000011187
        GOSUB BUILD.BALANCE

        GOSUB BUILD.INT.CHARGES

        GOSUB BUILD.MOVEMENTS

        GOSUB UPDATE.ACCOUNT

    END ELSE
        GOSUB RELEASE.ACCOUNT
    END
    RETURN
*
*-------------------------------------------------------------------------------------------------------
*
READ.ACCOUNT:
*===========
*

    ACCT.REC = ""
    YERR = ''
    RETRY = ""
    CALL F.READU(FN.ACCOUNT, ACCT.ID,ACCT.REC,F.ACCOUNT,YERR,RETRY)
    IF YERR THEN
        ACCT.REC = ''
        E = "IC.RTN.MISS.FILE.F.ACCT.ID":FM:ACCT.ID
        GOSUB FATAL.ERROR
    END

* Set static info
    OPEN.CURRENCY = ACCT.REC<AC.CURRENCY>
    OPEN.ASSET.TYPE = ''
    CONTRACT.BAL.ID = ACCT.ID
    APPLICATION.ID = ''
    APPLICATION.ID<1> = 'ACCOUNT'
    APPLICATION.ID<2> = 'AC'
    APPLICATION.ID<3> = ACCT.REC<AC.CO.CODE>      ;* Company code to be updated in ECB
    CONSOL.KEY = ACCT.REC<AC.CONSOL.KEY>
    VALUE.DATE = ''
    MAT.DATE = ''

    IF NOT(YERR) THEN
        FN.RE.CONTRACT.BALANCES = 'F.RE.CONTRACT.BALANCES'
        F.RE.CONTRACT.BALANCES = ''
        CALL OPF(FN.RE.CONTRACT.BALANCES,F.RE.CONTRACT.BALANCES)

        R.RE.CONTRACT.BALANCES = ''

        CALL F.READ(FN.RE.CONTRACT.BALANCES,ACCT.ID,R.RE.CONTRACT.BALANCES,F.RE.CONTRACT.BALANCES,'')
    END

    RETURN
*----------------------------------------------------------------------------------------------
BUILD.BALANCE:
*============
*
* If there is no Open.Actual.Balance, then it is a new account

    YPOS.CONT = ''
    OPEN.BAL.LCL = ''
    OPEN.ASSET.TYPE = ACCT.REC<AC.OPEN.ASSET.TYPE>
    IF ACCT.REC<AC.OPEN.ACTUAL.BAL> OR ACCT.REC<AC.OPEN.ACTUAL.BAL> = "0" THEN

        OPEN.BALANCE = ACCT.REC<AC.OPEN.ACTUAL.BAL>

        ENTRY.TYPE =''
        ENTRY.ID = ''
        ENTRY.REC = ''
        CONTRACT.BAL.ID = ACCT.ID
        ASSET.TYPE = OPEN.ASSET.TYPE
        LOCATE OPEN.ASSET.TYPE IN Y.CONTINGENT.TYPES<1> SETTING YPOS.CONT THEN

            IF OPEN.ASSET.TYPE[1,3] NE 'OFF' THEN

                GOSUB GET.LOCAL.BAL
            END
        END

        IF OPEN.ASSET.TYPE NE "NILOPEN" THEN
            GOSUB BUILD.CONTRACT.BALANCES
        END

        *  Check if type is contingent, then if Self-Balancing required.


        IF Y.CONTINGENT.BAL.TYPES<YPOS.CONT> THEN
            GOSUB CHECK.SELF.BAL

        END

    END

* If there is any contingent balance then get the original local equivalent from the STMT.ENTRIES
    IF (ACCT.REC<AC.CONTINGENT.BAL.DR> OR ACCT.REC<AC.CONTINGENT.BAL.CR>) AND (ACCT.REC<AC.CURRENCY> NE LCCY) THEN
        GOSUB GET.CONT.LOCAL.BAL
    END


* If there is a Contingent credit Balance
    IF ACCT.REC<AC.CONTINGENT.BAL.CR> THEN

        OPEN.BALANCE = ACCT.REC<AC.CONTINGENT.BAL.CR>
        IF ACCT.REC<AC.CURRENCY> EQ LCCY THEN
            OPEN.BAL.LCL = OPEN.BALANCE
        END ELSE
            OPEN.BAL.LCL = CONT.CR.LCL
        END
        ENTRY.TYPE =''
        ENTRY.ID = ''
        ENTRY.REC = ''
        CONTRACT.BAL.ID = ACCT.ID
        ASSET.TYPE = 'CONTCR'

        GOSUB BUILD.CONTRACT.BALANCES


        GOSUB CHECK.SELF.BAL  ;* BG_100011274

    END

* If there is a Contingent debit Balance

    IF ACCT.REC<AC.CONTINGENT.BAL.DR> THEN

        OPEN.BALANCE = ACCT.REC<AC.CONTINGENT.BAL.DR>
        IF ACCT.REC<AC.CURRENCY> EQ LCCY THEN
            OPEN.BAL.LCL = OPEN.BALANCE
        END ELSE
            OPEN.BAL.LCL = CONT.DB.LCL
        END

        ASSET.TYPE = 'CONTDB'
        ENTRY.TYPE =''
        ENTRY.ID = ''
        ENTRY.REC = ''
        CONTRACT.BAL.ID = ACCT.ID

        GOSUB BUILD.CONTRACT.BALANCES


        GOSUB CHECK.SELF.BAL  ;* BG_100011274

    END

* There may be forward entries in CONSOL.ENT.TODAY from SOD.VALUE.DATED.SUSPENSE

    GOSUB BUILD.RE.SPEC.ENT


    RETURN
*---------------------------------------------------------------------------------------------
BUILD.CONTRACT.BALANCES:
*=======================
* Routine to  create  and update EB.CONTRACT.BALANCES

    CALL EB.CONTRACT.BALANCES.BUILD(OPEN.BALANCE, OPEN.BAL.LCL, OPEN.ASSET.TYPE, OPEN.CURRENCY,ACCT.REC,
    ENTRY.TYPE, ENTRY.ID, ENTRY.REC, CONTRACT.BAL.ID, CONSOL.KEY, ASSET.TYPE,
    APPLICATION.ID,VALUE.DATE,MAT.DATE,WRITE.REC,"")


    RETURN
*----------------------------------------------------------------------------------------------
GET.LOCAL.BAL:
*=============
* Convert Open.Balance for contingent asset types
    CCY.MKT = ACCT.REC<AC.CURRENCY.MARKET>
    FOR.CCY = ACCT.REC<AC.CURRENCY>

    IF FOR.CCY EQ LCCY THEN

        OPEN.BAL.LCL = OPEN.BALANCE
    END ELSE
        CALL EXCHRATE(CCY.MKT,FOR.CCY,OPEN.BALANCE,LCCY,OPEN.BAL.LCL,'','','','','')
    END

    RETURN

*------------------------------------------------------------------------------------------------
GET.CONT.LOCAL.BAL:
*=================
* Read ACCT.ENT.FWD, if real entries then get the total local equ for credits and
* debits.
    AEF.REC = ''
    YERR = ''

    CONT.CR.LCL = ''
    CONT.DB.LCL = ''
    CALL F.READ(FN.ACCT.ENT.FWD,ACCT.ID,AEF.REC,F.ACCT.ENT.FWD,YERR)


    LOOP
        REMOVE YID.STMT FROM AEF.REC SETTING STMT.DELIM
    WHILE YID.STMT:STMT.DELIM

        YERR = ''
        ENTRY.REC = ''


        IF YID.STMT[1,1] <> "F"  THEN   ;* ignore contracts

            CALL F.READ(FN.STMT.ENTRY,YID.STMT,ENTRY.REC,F.STMT.ENTRY,YERR)

            IF ENTRY.REC THEN

                IF ENTRY.REC<AC.STE.AMOUNT.LCY>  > 0 THEN
                    CONT.CR.LCL += ENTRY.REC<AC.STE.AMOUNT.LCY>
                END ELSE
                    CONT.DB.LCL += ENTRY.REC<AC.STE.AMOUNT.LCY>
                END
            END

        END

    REPEAT
    RETURN

*----------------------------------------------------------------------------------------------
CHECK.SELF.BAL:
*=============

* If SELF.BAL.LOCK is set there is a locking record, that indicates
* SELF.BAL has been changed in CONSOLIDATE.COND.


    BEGIN CASE
        CASE SELF.BAL.LOCK

            * If there is a locking record and SELF.BAL is not set, it means
            * it has been removed and CRF.SELF.BAL.CONT.UPD will raise the offsetting entries
            * So we need to update the entries. If SELF.BAL is set, CRF.SELF.BAL.CONT.UPD
            * will raise the Balancing entries, no need to do it here.

            IF SELF.BAL EQ ''  THEN
                GOSUB RAISE.SELF.BAL
            END

        CASE OTHERWISE
            * If there is no locking and SELF.BAL is set, then it means Self-Balancing entries
            * are already there, so  we need to raise the balances.


            IF SELF.BAL  THEN
                GOSUB RAISE.SELF.BAL
            END


    END CASE
    RETURN
*-------------------------------------------------------------------------------------------
RAISE.SELF.BAL:
*=============

    OPEN.BALANCE = OPEN.BALANCE * -1
    OPEN.BAL.LCL = OPEN.BAL.LCL * -1
    ASSET.TYPE:= 'BL'
    ENTRY.TYPE =''
    ENTRY.ID = ''
    ENTRY.REC = ''
    CONTRACT.BAL.ID = ACCT.ID

    GOSUB BUILD.CONTRACT.BALANCES


    RETURN

*-------------------------------------------------------------------------------------------
BUILD.INT.CHARGES:
*================

* Loop through the Accr.Int.chg

    IF R.RE.CONTRACT.BALANCES THEN

        ACCR.CNT = RAISE(R.RE.CONTRACT.BALANCES<RCB.TYPE>)
        ASSET.NO = DCOUNT(ACCR.CNT,FM)
        ASSET.TYPE.ARRAY = ''
        OPEN.BALANCE = ''
        ASSET.TYPE = ''
        SUSP.TYPE = ''

        FOR CNT = 1 TO ASSET.NO
            GOSUB BUILD.ACCT.INT.CHG
        NEXT CNT

    END

    RETURN
*---------------------------------------------------------------------------------------------
BUILD.ACCT.INT.CHG:
*=================

    ASSET.TYPE = R.RE.CONTRACT.BALANCES<RCB.TYPE,CNT>
    SUSP.TYPE = ASSET.TYPE[6,2]
    OPEN.BALANCE = R.RE.CONTRACT.BALANCES<RCB.BALANCE,CNT>
    LOCATE ASSET.TYPE IN ASSET.TYPE.ARRAY<1,1> SETTING T.POS THEN
        ASSET.TYPE.ARRAY<2,T.POS> += OPEN.BALANCE
    END ELSE
        ASSET.TYPE.ARRAY<1,T.POS> = ASSET.TYPE
        ASSET.TYPE.ARRAY<2,T.POS> = OPEN.BALANCE
    END

    OPEN.BALANCE = ASSET.TYPE.ARRAY<2,T.POS>

    OPEN.BAL.LCL = ''
    ENTRY.TYPE =''
    ENTRY.ID = ''
    ENTRY.REC = ''

    GOSUB BUILD.CONTRACT.BALANCES

    RETURN
*--------------------------------------------------------------------------------------------------
BUILD.MOVEMENTS:
*===============

    AET.REC = ''
    YERR = ''
    CALL F.READ(FN.ACCT.ENT.TODAY,ACCT.ID,AET.REC,F.ACCT.ENT.TODAY,YERR)        ;* BG_100011274


    LOOP
        REMOVE YID.STMT FROM AET.REC SETTING STMT.DELIM
    WHILE YID.STMT:STMT.DELIM

        YERR = ''

        ENTRY.REC = ''
        CALL F.READ(FN.STMT.ENTRY,YID.STMT,ENTRY.REC,F.STMT.ENTRY,YERR)


        IF ENTRY.REC THEN
            OPEN.BALANCE = ''
            OPEN.ASSET.TYPE = ACCT.REC<AC.OPEN.ASSET.TYPE>
            ENTRY.TYPE ='S'
            ENTRY.ID = YID.STMT
            ASSET.TYPE = OPEN.ASSET.TYPE
            MAT.DATE = ENTRY.REC<AC.STE.CRF.MAT.DATE>

            GOSUB  BUILD.CONTRACT.BALANCES
        END
    REPEAT
    RETURN
*------------------------------------------------------------------------------------------------
UPDATE.ACCOUNT:
*==============
    ACCT.REC<AC.CONSOL.KEY> = ''
    ACCT.REC<AC.OPEN.ASSET.TYPE> = ''
    ACCT.REC<AC.CONTINGENT.BAL.DR> = '' ;* BG_100011162
    ACCT.REC<AC.CONTINGENT.BAL.CR> = '' ;* BG_100011162

    CALL F.WRITE(FN.ACCOUNT,ACCT.ID,ACCT.REC)
    RETURN

*--------------------------------------------------------------------------------------------------
BUILD.RE.SPEC.ENT:
*================
* This will read EOD.CONSOL.UDATE.DETAIL for today or next working day.
* Then retrieve the CONSOL.ENT.TODAY entry and build; it will
*
    YERR = ''
    RETRY = ''
    CET.DETAIL = ''
    CET.DETAIL.ID = ACCT.ID:'*':TODAY
    CALL F.READU(FN.EOD.CONSOL.UPDATE.DETAIL, CET.DETAIL.ID,CET.DETAIL,F.EOD.CONSOL.UPDATE.DETAIL,YERR,RETRY)
    IF YERR  THEN
        YERR = ''
        CET.DETAIL.ID = ACCT.ID:'*':R.DATES(EB.DAT.NEXT.WORKING.DAY)
        CALL F.READU(FN.EOD.CONSOL.UPDATE.DETAIL, CET.DETAIL.ID,CET.DETAIL,F.EOD.CONSOL.UPDATE.DETAIL,YERR,RETRY)
    END

    IF YERR THEN

        CALL F.RELEASE(FN.EOD.CONSOL.UPDATE.DETAIL,CET.DETAIL.ID,F.EOD.CONSOL.UPDATE.DETAIL)
    END ELSE
        LOOP
            REMOVE CET.ID FROM CET.DETAIL SETTING CET.POS
        WHILE CET.ID:CET.POS

            CONSOL.ID = FIELD(CET.ID,'*',2)       ;* CI_10007655E EN_10002408

            CONSOL.REC = ''   ;* EN_10002275S
            YERR = ''
            RETRY = ''
            CALL F.READU(FN.CONSOL.ENT.TODAY,CONSOL.ID,CONSOL.REC,F.CONSOL.ENT.TODAY,YERR,RETRY)
            IF YERR <> "" THEN

                CONTINUE
            END ELSE
                GOSUB LOAD.RE.SPEC.ENT
                DELETE F.CONSOL.ENT.TODAY, CONSOL.ID
            END

        REPEAT
        DELETE F.EOD.CONSOL.UPDATE.DETAIL,CET.DETAIL.ID
    END
    RETURN
*-----------------------------------------------------------------------------------------------------*
LOAD.RE.SPEC.ENT:
* Build a STMT.ENTRY format from CONSOL.ENT.TODAY and call EB.ENTRY.REC.UPDATE

    ENTRY.REC<AC.STE.COMPANY.CODE> = CONSOL.REC<RE.CET.CO.CODE>
    IF NOT(ENTRY.REC<AC.STE.COMPANY.CODE>) AND C$MULTI.BOOK THEN
        ENTRY.REC<AC.STE.COMPANY.CODE> = ACCT.REC<AC.CO.CODE>
    END ELSE
        IF NOT(ENTRY.REC<AC.STE.COMPANY.CODE>) THEN
            ENTRY.REC<AC.STE.COMPANY.CODE> = ID.COMPANY
        END
    END
    ENTRY.REC<AC.STE.OUR.REFERENCE> = CONSOL.REC<RE.CET.TXN.REF>
    ENTRY.REC<AC.STE.TRANS.REFERENCE> = CONSOL.REC<RE.CET.TXN.REF>
    STMT.ID = CONSOL.REC<RE.CET.ENTRY.ID>
    IF STMT.ID AND CONSOL.REC<RE.CET.TXN.CODE> NE 'COR' THEN
        GOSUB REFERENCE.FROM.STMT
    END

    ENTRY.REC<AC.STE.SYSTEM.ID> = CONSOL.REC<RE.CET.PRODUCT>
    ENTRY.REC<AC.STE.CURRENCY.MARKET> = CONSOL.REC<RE.CET.CURRENCY.MARKET>
    ENTRY.REC<AC.STE.CURRENCY> = CONSOL.REC<RE.CET.CURRENCY>
    ENTRY.REC<AC.STE.CRF.TYPE> =  CONSOL.REC<RE.CET.TYPE>
    ENTRY.REC<AC.STE.CRF.TXN.CODE> = CONSOL.REC<RE.CET.TXN.CODE>
    ENTRY.REC<AC.STE.SUPPRESS.POSITION> = CONSOL.REC<RE.CET.SUPPRESS.POSITION>
    ENTRY.REC<AC.STE.CRF.MAT.DATE> = CONSOL.REC<RE.CET.MAT.DATE>
    ENTRY.REC<AC.STE.CRF.PROD.CAT> = CONSOL.REC<RE.CET.PRODUCT.CATEGORY>
    ENTRY.REC<AC.STE.PRODUCT.CATEGORY> = CONSOL.REC<RE.CET.PRODUCT.CATEGORY>
    ENTRY.REC<AC.STE.CUSTOMER.ID> = CONSOL.REC<RE.CET.CUSTOMER>
    ENTRY.REC<AC.STE.EXCHANGE.RATE> = CONSOL.REC<RE.CET.EXCHANGE.RATE>
    ENTRY.REC<AC.STE.ACCOUNT.OFFICER> =  CONSOL.REC<RE.CET.ACCOUNT.OFFICER>
    ENTRY.REC<AC.STE.VALUE.DATE> = CONSOL.REC<RE.CET.VALUE.DATE>
    ENTRY.REC<AC.STE.BOOKING.DATE>    = CONSOL.REC<RE.CET.BOOKING.DATE>
    ENTRY.REC<AC.STE.POSITION.TYPE> = CONSOL.REC<RE.CET.POSITION.TYPE>
    ENTRY.REC<AC.STE.BOOKING.DATE> = CONSOL.REC<RE.CET.BOOKING.DATE>

    IF ENTRY.REC<AC.STE.CURRENCY> EQ LCCY THEN

        IF CONSOL.REC<RE.CET.LOCAL.DR> <> "" THEN
            ENTRY.REC<AC.STE.AMOUNT.LCY> = CONSOL.REC<RE.CET.LOCAL.DR>
        END ELSE
            ENTRY.REC<AC.STE.AMOUNT.LCY> = CONSOL.REC<RE.CET.LOCAL.CR>
        END
    END ELSE
        IF CONSOL.REC<RE.CET.FOREIGN.DR> OR CONSOL.REC<RE.CET.LOCAL.DR> THEN
            ENTRY.REC<AC.STE.AMOUNT.FCY> = CONSOL.REC<RE.CET.FOREIGN.DR>
            ENTRY.REC<AC.STE.AMOUNT.LCY> = CONSOL.REC<RE.CET.LOCAL.DR>
        END ELSE
            IF CONSOL.REC<RE.CET.FOREIGN.CR> OR CONSOL.REC<RE.CET.LOCAL.CR> THEN
                ENTRY.REC<AC.STE.AMOUNT.FCY> = CONSOL.REC<RE.CET.FOREIGN.CR>
                ENTRY.REC<AC.STE.AMOUNT.LCY> = CONSOL.REC<RE.CET.LOCAL.CR>
            END
        END
    END
    CURRTIME = ""   ;* Used for Id update
    TDATE = DATE()  ;* Date part
    CALL ALLOCATE.UNIQUE.TIME(CURRTIME)
    UNIQUE.ID = TDATE:CURRTIME



    UPD.MODE = "SAO"
    UPD.MODE<2> = 1
    CONS.REC = LOWER(ENTRY.REC)
    CALL EB.UPDATE.CONSOL.ENTRY(UPD.MODE, CONS.REC, CONSOL.REC<RE.CET.TXN.REF>, "", UNIQUE.ID )
    RETURN

*-----------------------------------------------------------------------------------------------------*
REFERENCE.FROM.STMT:
*----------------------------
    CALL F.READ(FN.STMT.ENTRY,STMT.ID,R.ENTRY,F.STMT.ENTRY,YER)
    IF YER THEN
        E ='AC.RTN.MISS':FM:STMT.ID:VM:FN.STMT.ENTRY
        GOSUB FATAL.ERROR
    END
    ENTRY.REC<AC.STE.OUR.REFERENCE> = R.ENTRY<AC.STE.TRANS.REFERENCE>
    ENTRY.REC<AC.STE.TRANS.REFERENCE> = R.ENTRY<AC.STE.TRANS.REFERENCE>
    ENTRY.REC<AC.STE.CONTRACT.BAL.ID> = CONSOL.REC<RE.CET.TXN.REF>

    RETURN
*-----------------------------------------------------------------------------------------------------*
RELEASE.ACCOUNT:
*==============

    CALL F.RELEASE(FN.ACCOUNT,ACCT.ID,F.ACCOUNT)

    RETURN


*-----------------------------------------------------------------------------------------------------*
FATAL.ERROR:
*==========
    TEXT = E ; CALL FATAL.ERROR ("CONV.ACCOUNT.ECB")
    RETURN

    END
