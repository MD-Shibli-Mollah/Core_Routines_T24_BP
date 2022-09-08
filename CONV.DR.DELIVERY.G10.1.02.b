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

* Version 6 15/05/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>6552</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.Delivery
    SUBROUTINE CONV.DR.DELIVERY.G10.1.02
*
* This conversion program will populate the delivery info on
* the DRAWING RECORD in respect with Soft Delivery Concept.
*
* It is worth to note that this program always only run
* after the LC record has finished.
*

****************************************************************************
*
* CHANGE CONTROL
* --------------
*
* 27/03/00 - GB0000603
*            Jbase Compatibility
*            The use of EQU LIT & EQU TO "" must be limited to
*            only literals and not variables. In Universe even
*           if variables have been included into the literals
*           they are acted upon by the pre-processor and hence
*           replaced if equated. In jBase this does not happen
*           and the variable is left alone
*
* 18/05/00 - GB0001257
*            Modified for jBase. BITSET and BITRESET work in
*            different way in UV and jBase.
*
* 19/03/12 - TASK : 3774637
*            Compilation Warnings.
*            REF : 374126
*
********************************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_LC.COMMON
    $INSERT I_F.COMPANY
    $INSERT I_F.DATES

*
* Symbol Definition
*
    EQU TRUE TO 1
    EQU FALSE TO 0

*// Defining location stuff
*// DRAWINGS
    EQU TF.DR.DRAWING.TYPE TO 1
    EQU TF.DR.DRAW.CURRENCY TO 2
    EQU TF.DR.MATURITY.REVIEW TO 7
    EQU TF.DR.DISCOUNT.AMT TO 14
    EQU TF.DR.DRAWDOWN.ACCOUNT TO 17
    EQU TF.DR.PAYMENT.METHOD TO 18
    EQU TF.DR.PAYMENT.ACCOUNT TO 19
    EQU TF.DR.RECEIVERS.BANK TO 22
    EQU TF.DR.RECEIVERS.CORR TO 23
    EQU TF.DR.UNDER.RESERVE TO 26
    EQU TF.DR.PRESENTOR.CUST TO 27
    EQU TF.DR.PRESENTOR TO 28
    EQU TF.DR.DISCREPANCY TO 33
    EQU TF.DR.MAT.ADVICE.DATE TO 66
    EQU TF.DR.REIMBURSE.SENT TO 85
    EQU TF.DR.DEBIT.VALUE TO 102
    EQU TF.DR.MANUAL.MATURITY TO 111
    EQU TF.DR.ACTIVITY.SENT TO 117
    EQU TF.DR.ADVIS.SCHEDULE TO 118
    EQU TF.DR.CLASS.SCHED TO 119
    EQU TF.DR.EB.ADV.NO TO 120
    EQU TF.DR.DELIVERY.DAYS TO 121
    EQU TF.DR.MSG.CLASS.NO TO 122
    EQU TF.DR.SEND.NOTICE TO 123
    EQU TF.DR.RECORD.STATUS TO 126

*// LETTER.OF.CREDIT
    EQU TF.LC.LC.TYPE TO 2
    EQU TF.LC.BENEFICIARY.CUSTNO TO 12
    EQU TF.LC.BENEFICIARY TO 13
    EQU TF.LC.THIRD.PARTY.CUSTNO TO 46
    EQU TF.LC.THIRD.PARTY TO 47
    EQU TF.LC.ADVISE.THRU.CUSTNO TO 49
    EQU TF.LC.ADVISE.THRU TO 50
    EQU TF.LC.CONFIRM.INST TO 64
    EQU TF.LC.ACCOUNT.OFFICER TO 88
    EQU TF.LC.PROVIS.ACC TO 138
    EQU TF.LC.PRO.OUT.AMOUNT TO 141
    EQU TF.LC.CREDIT.PROVIS.ACC TO 151

*// LC.TYPES
    EQU LC.TYP.IMPORT.EXPORT TO 3
    EQU LC.TYP.PAY.TYPE TO 6
    EQU LC.TYP.DOC.COLLECTION TO 7
    EQU LC.TYP.CLEAN.CREDIT TO 8
    EQU LC.TYP.CLEAN.COLLECTION TO 9

*// LC.PARAMETERS
    EQU LC.PARA.REIMBURSE.DAYS TO 3
    EQU LC.PARA.LC.CLASS.TYPE TO 68
    EQU LC.PARA.EB.CLASS.NO TO 69

*// EB.ACTIVITY
    EQU EB.ACT.DESCRIPTION TO 1
    EQU EB.ACT.DAYS.PRIOR.EVENT TO 2

*// EB.ADVICES
    EQU EB.ADV.MESSAGE.TYPE TO 2
    EQU EB.ADV.MSG.CLASS TO 3

*// CUSTOMER
    EQU EB.CUS.RESIDENCE TO 17

*// ACCOUNT
    EQU AC.CUSTOMER TO 1

*// AGENCY
    EQU EB.AG.NOSTRO.ACCT.NO TO 1

*// CURRENCY
    EQU EB.CUR.DAYS.DELIVERY TO 7

*// Simplifying Code Reading
* GB0000603 S
    EQU DRAWN.ACCT TO R.NEW(TF.DR.DRAWDOWN.ACCOUNT)
    EQU PAY.ACCT TO R.NEW(TF.DR.PAYMENT.ACCOUNT)
    EQU EB.ACTIVITY TO 'EB.ACTIVITY':FM:EB.ACT.DESCRIPTION
    EQU AGENCY.NOSTRO TO 'AGENCY':FM:EB.AG.NOSTRO.ACCT.NO
    EQU BASIC.MSG.CLASS TO 'BASIC.MESSAGE':FM:'NOTIFICATION':FM:'USER.DEFINE1'
* GB0000603 E
*
* Identify type of transaction
*
* GB0000603 S
    EQU IS.IMPORT.EXPORT TO R$TYPES(LC.TYP.IMPORT.EXPORT) = 'I'
    EQU IS.COLLECTION TO R$TYPES(LC.TYP.DOC.COLLECTION) EQ 'YES' OR R$TYPES(LC.TYP.CLEAN.CREDIT) EQ 'YES' OR R$TYPES(LC.TYP.CLEAN.COLLECTION) EQ 'YES'
* GB0000603 E
*
* Identify type of payment
*
* GB0000603 S
    EQU SIGHT TO NDR.TYPE = 'SP'
    EQU USANCE TO NDR.TYPE MATCH 'AC':VM:'DP'
* GB0001257 START
*      EQU IMPORT.LC TO BITTEST(BIT.FLG,3)
*      EQU EXPORT.LC TO BITTEST(BIT.FLG,2)
*GB0001257 END
    EQU MATURE.USANCE TO (NDR.TYPE EQ 'MA' AND ODR.TYPE EQ 'AC') OR (NDR.TYPE EQ 'MD' AND ODR.TYPE EQ 'DP')
    EQU DISCREPANCY TO NDR.TYPE MATCH 'CO':VM:'CR':VM:'RP':VM:'FR'
* GB0000603 E
*      EQU MATURITY.CHANGE LIT "R.NEW(TF.DR.MATURITY.REVIEW) # R.OLD(TF.DR.MATURITY.REVIEW)"
    EQU UPDATE.ADVISE.SCHEDULE TO R.NEW(TF.DR.ADVIS.SCHEDULE)<1,-1> = SEND.DATE:'.':ACCT.OFFICER:'.':REIMB.ACT.NO      ; * GB0000603
*      EQU UNCONFIRM.EXPORT LIT "LC.REC(TF.LC.CONFIRM.INST)[1,1]='U' AND BITTEST(BIT.FLG,2)"
    EQU UNCONFIRM.EXPORT TO LC.REC(TF.LC.CONFIRM.INST)[1,1]='W' AND EXPORT.LC  ; * GB0000603
*
* Identify Set of Conditions
*
    EQU REVERSE.SET TO IF (V$FUNCTION = 'A' AND R.NEW(TF.DR.RECORD.STATUS)[1,1] = 'R') OR V$FUNCTION = 'R' THEN 'R' ELSE ''      ; * GB0000603
*      EQU REIMBURSING.SET LIT "(LC.REC(TF.LC.THIRD.PARTY.CUSTNO) OR LC.REC(TF.LC.THIRD.PARTY)) AND BITTEST(BIT.FLG,2)"
* GB0000603 S
    EQU REIMBURSING.SET TO (LC.REC(TF.LC.THIRD.PARTY.CUSTNO) OR LC.REC(TF.LC.THIRD.PARTY)) AND EXPORT.LC
    EQU PROCESS.DISCOUNT TO (R.NEW(TF.DR.DISCOUNT.AMT) > 0 AND R.OLD(TF.DR.DISCOUNT.AMT) = '')
* GB0000603 E
*      EQU MATURE.EOD.UNCONFIRM.EXPORT LIT "LC.REC(TF.LC.CONFIRM.INST)[1,1]='U' AND BITTEST(BIT.FLG,2) AND RUNNING.UNDER.BATCH"
* GB0000603 S
    EQU MATURE.EOD.UNCONFIRM.EXPORT TO LC.REC(TF.LC.CONFIRM.INST)[1,1]='U' AND EXPORT.LC AND RUNNING.UNDER.BATCH
    EQU CO.DISC TO NDR.TYPE MATCH 'CO':VM:'CR':VM:'FR'
* GB0000603 E
*
* Party Involved Definition
*
* GB0000603 S
    EQU PRESENT.PARTY TO IF R.NEW(TF.DR.PRESENTOR.CUST) THEN R.NEW(TF.DR.PRESENTOR.CUST) ELSE R.NEW(TF.DR.PRESENTOR)
    EQU ADVIS.THRU.BNK TO IF LC.REC(TF.LC.ADVISE.THRU.CUSTNO) THEN LC.REC(TF.LC.ADVISE.THRU.CUSTNO) ELSE LC.REC(TF.LC.ADVISE.THRU)
    EQU BENEFICIARY TO IF LC.REC(TF.LC.BENEFICIARY.CUSTNO) THEN LC.REC(TF.LC.BENEFICIARY.CUSTNO) ELSE LC.REC(TF.LC.BENEFICIARY)
    EQU SAME.RESIDENCE.AND.CCY.RESIDENCE TO (R.CORR.BNK<EB.CUS.RESIDENCE> = R.RECV.BNK<EB.CUS.RESIDENCE>) AND (R.RECV.BNK<EB.CUS.RESIDENCE> = R.NEW(TF.DR.DRAW.CURRENCY)[1,2])
**      EQU GET.CREDIT.CUST.NO TO CALL DBR('ACCOUNT':FM:AC.CUSTOMER,R.NEW(TF.DR.PAYMENT.ACCOUNT),CUST.NO)
**      EQU GET.DEBIT.CUST.NO TO CALL DBR('ACCOUNT':FM:AC.CUSTOMER,R.NEW(TF.DR.DRAWDOWN.ACCOUNT),CUST.NO)
* GB0000603 E
*
* Customer Type Definition
*
    EQU CUSTOMER.TYPE TO 0
    EQU BANK.TYPE TO 1
    EQU UNIDENTIFY.TYPE TO 2
*
*  Check to see whether the Drawing entered is Takenover Contracts
*  if so, NO delivery will be produced.
*
    GOSUB INITIALIZE
    IF REIM.PAY.SENT THEN
        PAY.DEL = FALSE
    END ELSE
        GOSUB CHECK.PAYMENT.DELIVERY
    END
    GOSUB DR.DETERMINE.ACTIVITY
    RETURN

*
* Main Activity Control
*
DR.DETERMINE.ACTIVITY:
    GOSUB RAISE.BASIC.ACTIVITY
    IF NDR.TYPE # 'AD' THEN
        BEGIN CASE
            CASE DR.OPER.TYPE > 4000 AND COLL.FLG
                IF USANCE THEN
                    CALL UPDATE.CLASS.LIST('COLL.ACCEPT', TRUE)
                END
                IF PAY.DEL THEN
                    GOSUB RAISE.COLLECTION.PAYMENT
                END
            CASE DR.OPER.TYPE > 4000     ; * if USANCE
                IF NOT(NDR.TYPE MATCH 'CO':VM:'CR':VM:'FR') THEN
                    GOSUB RAISE.REIMB.SENT.ACTIVITY  ; * Never change order
                END
                GOSUB RAISE.REIMB.PAYMNT.ACTIVITY   ; * of the part.
                GOSUB RAISE.REIMB.CLAIM.ACTIVITY
                GOSUB RAISE.PROVISION.ACTIVITY
            CASE 1
                IF REV.FLG THEN
                    GOSUB RAISE.REV.PAYMENT.CLASS
                END ELSE
                    GOSUB RAISE.REIMBURSE.CLASS
                    GOSUB RAISE.PAYMENT.CLASS
                END
        END CASE
    END
****Stoping the execution of DEBUG statement.
* CRT "BEFORE ..."
* GOSUB DEBUG.PRINT
    CALL MAP.MSG.CLASS.ARRAY(MSG.CLASS.LIST,
    LC.PARA.CLASS, LC.PARA.EB.ID)

*// Update user control list on the screen
    GOSUB EXTRACT.AND.UPDATE.CLASS
*      CRT "AFTER ..."
*      GOSUB DEBUG.PRINT

    RETURN
*
DEBUG.PRINT:
    IMAX = DCOUNT(R.NEW(TF.DR.ADVIS.SCHEDULE),VM)
    FOR IDB = 1 TO IMAX
        *         CRT "ADVIS :":R.NEW(TF.DR.ADVIS.SCHEDULE)<1,IDB>
        JMAX = DCOUNT(R.NEW(TF.DR.CLASS.SCHED)<1,IDB>, SM)
        FOR JDB = 1 TO JMAX
            CRT "CLASS :":R.NEW(TF.DR.CLASS.SCHED)<1,IDB,JDB>
        NEXT JDB
    NEXT IDB
**INPUT XXX ; IF XXX = 'D' THEN DEBUG
    RETURN
*
RAISE.COLLECTION.PAYMENT:
    IF MATURE.USANCE OR NOT(CTRL.MODE) THEN
        ACT.FLG = 15
        REIMB.ACT.NO = 'LC-':FMT(DR.OPER.TYPE+ACT.FLG,"4'0'R")
        GOSUB RAISE.PAYMENT.CLASS
        DR.ACT.LISTS<1,-1> = REIMB.ACT.NO
    END
    RETURN
*
* Control usance reimbursement payment, i.e. MT754, MT756 or
* MT752. The possible activity number is 4414 or 4814.
*
RAISE.REIMB.SENT.ACTIVITY:
    IF NOT(REIMBURSING.SENT) THEN
        ACT.FLG = 14
        REIMB.ACT.NO = 'LC-':FMT(DR.OPER.TYPE+ACT.FLG,"4'0'R")
        GOSUB CHECK.REIMB.DAYS
        IF REIMB.SENT THEN
            DR.USANCE.ACT.LISTS<1,-1> = REIMB.ACT.NO
        END
        DR.ACT.LISTS<1,-1> = REIMB.ACT.NO
        UPDATE.ADVISE.SCHEDULE          ; * Macro Assignment
    END
    RETURN
*
* This activity will always control the message related to payment.
* The activiy number maybe 4115, 4215, 4415 or 4815.
*
RAISE.REIMB.PAYMNT.ACTIVITY:
    IF PAY.DEL THEN
        ACT.FLG = 15
        REIMB.ACT.NO = 'LC-':FMT(DR.OPER.TYPE+ACT.FLG,"4'0'R")
        YCCY = R.NEW(TF.DR.DRAW.CURRENCY)
        CCY.LIST = YCCY[1,2]:FM:R.COMPANY(EB.COM.LOCAL.COUNTRY)[1,2]
        PAY.DAYS = ''
        CALL DBR("CURRENCY":FM:EB.CUR.DAYS.DELIVERY,YCCY,PAY.DAYS)
        *         IF RUNNING.UNDER.BATCH THEN
        *            CALL WORKING.DAY("",REIMB.DATE,"+",PAY.DAYS:"W","",CCY.LIST,
        *               "",SEND.DATE,"","")
        *            REIMB.SENT = SEND.DATE > MATURE.DATE
        IF DISCOUNT.SET OR (MATURE.USANCE AND NOT(DISCOUNT.SET)) THEN
            SEND.DATE = REIMB.DATE
            REIMB.SENT = TRUE
        END ELSE
            CALL WORKING.DAY("",MATURE.DATE,"-",PAY.DAYS:"W","",CCY.LIST,
            "",SEND.DATE,"","")
            REIMB.SENT = SEND.DATE < REIMB.DATE
            SEND.DATE = IF REIMB.SENT THEN REIMB.DATE ELSE SEND.DATE
    END
    BEGIN CASE
        CASE NOT(CTRL.MODE)
            DR.USANCE.ACT.LISTS<1,-1> = REIMB.ACT.NO
        CASE REIMB.SENT
            DR.USANCE.ACT.LISTS<1,-1> = REIMB.ACT.NO
            R.NEW(TF.DR.ACTIVITY.SENT)<1,-1> = REIMB.ACT.NO:'.':SEND.DATE
    END CASE
    DR.ACT.LISTS<1,-1> = REIMB.ACT.NO
    UPDATE.ADVISE.SCHEDULE          ; * Assignment Macro
    GOSUB RAISE.PAYMENT.CLASS
    END
    RETURN
*
* Provision will only be raise at maturity (by manual or EOD).
* Activity No. 4417 and 4817
*
RAISE.PROVISION.ACTIVITY:
    IF PROVISION.SENT THEN RETURN
    IF PROVISION.SET AND (MATURE.USANCE OR NOT(CTRL.MODE)) THEN
        ACT.FLG = 17
        REIMB.ACT.NO = 'LC-':FMT(DR.OPER.TYPE+ACT.FLG,"4'0'R")
        REIM.DATE = MATURE.DATE
        GOSUB CHECK.REIMB.DAYS
        IF REIMB.SENT THEN
            DR.USANCE.ACT.LISTS<1,-1> = REIMB.ACT.NO
        END
        DR.ACT.LISTS<1,-1> = REIMB.ACT.NO
        GOSUB RAISE.PROVISION.CLASS
    END
    RETURN
*
* If the reimbursing bank is specified, this will be raised.
* Activity No. 4416
*
RAISE.REIMB.CLAIM.ACTIVITY:
    IF REIMBURSING.SET AND NOT(REIM.CLAIM.SENT) THEN
        ACT.FLG = 16
        REIMB.ACT.NO = 'LC-':FMT(DR.OPER.TYPE+ACT.FLG,"4'0'R")
        GOSUB CHECK.REIMB.DAYS
        IF REIMB.SENT THEN
            DR.USANCE.ACT.LISTS<1,-1> = REIMB.ACT.NO
        END
        DR.ACT.LISTS<1,-1> = REIMB.ACT.NO
        UPDATE.ADVISE.SCHEDULE          ; * Macro Assignment
        CALL UPDATE.CLASS.LIST("REIMBURSING",TRUE)
    END
    RETURN
*
* Calculate number of days before the maturity to generate
* the activity. Default value either from EB.ACTIVITY or from
* LC.PARAMETERS (field REIMBURSE.DAYS).
*
CHECK.REIMB.DAYS:
    REIMB.DAYS = ''
    ETEXT = ''
    GOSUB FIND.ACTIVITY.INPUT.DAYS
    IF REIMB.DAYS = '' THEN
        CALL DBR("EB.ACTIVITY$NAU":FM:EB.ACT.DAYS.PRIOR.EVENT,
        REIMB.ACT.NO, REIMB.DAYS)
    END
    ETEXT = ''
*      IF ETEXT THEN                      ; * ACTIVITY NOT SET
*         REIMB.SENT = FALSE ; * GB9901534
*      END ELSE ; * GB9901534
    IF REIMB.DAYS = '' THEN
        REIMB.DAYS = R$PARAMETER(LC.PARA.REIMBURSE.DAYS)
    END
    CCY.LIST = R.COMPANY(EB.COM.LOCAL.COUNTRY)[1,2]
    ACTIVITY.DATE = R.NEW(TF.DR.MATURITY.REVIEW)
    IF R.NEW(TF.DR.DEBIT.VALUE) THEN
        ACTIVITY.DATE = R.NEW(TF.DR.DEBIT.VALUE)
    END
*         IF RUNNING.UNDER.BATCH THEN
*            CALL WORKING.DAY("",REIMB.DATE, "+",REIMB.DAYS:"W","",
*               CCY.LIST, "", SEND.DATE,"","")
*            REIMB.SENT = SEND.DATE > ACTIVITY.DATE
    IF MATURE.USANCE THEN
        SEND.DATE = REIMB.DATE
        REIMB.SENT = TRUE
    END ELSE
        CALL WORKING.DAY("",ACTIVITY.DATE, "-",REIMB.DAYS:"W","",
        CCY.LIST, "", SEND.DATE,"","")
        REIMB.SENT = SEND.DATE < REIMB.DATE
        SEND.DATE = IF REIMB.SENT THEN REIMB.DATE ELSE SEND.DATE
    END
*      END
*      REIMB.SENT = IF NOT(CTRL.MODE) THEN TRUE ELSE REIMB.SENT
    IF CTRL.MODE THEN
        IF REIMB.SENT THEN
            R.NEW(TF.DR.ACTIVITY.SENT)<1,-1> = REIMB.ACT.NO:'.':SEND.DATE
            GOSUB UPDATE.REIMB.SENT.FLD
        END
    END ELSE
        REIMB.SENT = TRUE
    END
    RETURN
*
* Backward compatibility, updating REIMBURSE.SENT field
*
UPDATE.REIMB.SENT.FLD:
    ACT.MSG.LIST = ''
    CALL DBR("EB.ADVICES$NAU":FM:EB.ADV.MESSAGE.TYPE,
    REIMB.ACT.NO:'-':YLC.TYPE, ACT.MSG.LIST)
    IF ETEXT THEN
        CALL DBR("EB.ADVICES$NAU":FM:EB.ADV.MESSAGE.TYPE,
        REIMB.ACT.NO, ACT.MSG.LIST)
        IF ETEXT THEN
            CALL DBR("EB.ADVICES":FM:EB.ADV.MESSAGE.TYPE,
            REIMB.ACT.NO:'-':YLC.TYPE, ACT.MSG.LIST)
            IF ETEXT THEN
                CALL DBR("EB.ADVICES":FM:EB.ADV.MESSAGE.TYPE,
                REIMB.ACT.NO, ACT.MSG.LIST)
            END
        END
    END
    ETEXT = ''
    LOOP
        MSG.ITEM = ''
        REMOVE MSG.ITEM FROM ACT.MSG.LIST SETTING MSG.FLG1
    WHILE MSG.ITEM:MSG.FLG1 DO
        MSG.ITEM = FMT(MSG.ITEM,'4L')
        R.NEW(TF.DR.REIMBURSE.SENT)<1,-1> = 'MT':MSG.ITEM:SEND.DATE
    REPEAT
    RETURN
*
* Check whether user override number of days. If so, use it.
*
FIND.ACTIVITY.INPUT.DAYS:
    NO.ACTIVITY = DCOUNT(R.NEW(TF.DR.EB.ADV.NO),VM)
    FOR IACT = 2 TO NO.ACTIVITY
        EB.ACT = R.NEW(TF.DR.EB.ADV.NO)<1,IACT>
        EB.ACT = EB.ACT['-',2,1]
        EB.ACT = EB.ACT[3,2]
        IF EB.ACT = ACT.FLG THEN
            REIMB.DAYS = R.NEW(TF.DR.DELIVERY.DAYS)<1,IACT>
        END
    UNTIL REIMB.DAYS # ''
    NEXT IACT
    RETURN
*
* Since usance has multiple activity and classes, where classes may
* not unique, we have to arrange those classes to their associated
* activities.
*
EXTRACT.AND.UPDATE.CLASS:
    IF R.NEW(TF.DR.EB.ADV.NO) AND R.NEW(TF.DR.MSG.CLASS.NO) THEN
        NO.ACT = DCOUNT(R.NEW(TF.DR.EB.ADV.NO),VM)
        YOFFSET = 0
        FOR I = 1 TO NO.ACT
            IOFFSET = I - YOFFSET
            *            ISCHED = IF (COLL.FLG) THEN 0 ELSE IOFFSET - 1
            CLASS.LIST = ''
            ADV.ID = DR.ACT.LISTS<1,IOFFSET>:"-":YLC.TYPE
            CALL DBR("EB.ADVICES":FM:EB.ADV.MSG.CLASS,ADV.ID,CLASS.LIST)
            IF ETEXT THEN
                ADV.ID = DR.ACT.LISTS<1,IOFFSET>
                CALL DBR("EB.ADVICES":FM:EB.ADV.MSG.CLASS,ADV.ID,
                CLASS.LIST)
            END
            *            GOSUB DEBUG.PRINT
            *            PRINT "DEBUG .... " ; INPUT XXX ; IF XXX = 'D' THEN DEBUG
            *            LOCATE DR.ACT.LISTS<1,I> IN DR.USANCE.ACT.LISTS<1,1> SETTING RM.POS THEN
            LOCATE R.NEW(TF.DR.EB.ADV.NO)<1,IOFFSET> IN DR.ACT.LISTS<1,1> SETTING RM.POS THEN
                NO.CLS = DCOUNT(MSG.CLASS.LIST,VM)
                FOR J = 1 TO NO.CLS
                    LOCATE MSG.CLASS.LIST<1,J> IN CLASS.LIST<1,1> SETTING CL.POS THEN
                        LOCATE MSG.CLASS.LIST<1,J> IN R.NEW(TF.DR.MSG.CLASS.NO)<1,IOFFSET,1> SETTING POS THEN
                            R.NEW(TF.DR.SEND.NOTICE)<1,IOFFSET,POS> = Y.AND.N.LIST<1,J>
                        END ELSE
                            R.NEW(TF.DR.MSG.CLASS.NO)<1,IOFFSET,-1> = MSG.CLASS.LIST<1,J>
                            R.NEW(TF.DR.SEND.NOTICE)<1,IOFFSET,-1> = Y.AND.N.LIST<1,J>
                        END
                    END
                NEXT J
            END ELSE
                YOFFSET += 1
                NO.CLS = DCOUNT(R.NEW(TF.DR.MSG.CLASS.NO),SM)
                FOR J = 1 TO NO.CLS
                    DEL R.NEW(TF.DR.MSG.CLASS.NO)<1,I,1>
                    DEL R.NEW(TF.DR.SEND.NOTICE)<1,I,1>
                NEXT J
                DEL R.NEW(TF.DR.MSG.CLASS.NO)<1,I>
                DEL R.NEW(TF.DR.SEND.NOTICE)<1,I>
                DEL R.NEW(TF.DR.DELIVERY.DAYS)<1,I>
                DEL R.NEW(TF.DR.EB.ADV.NO)<1,I>
            END
        NEXT I
    END ELSE
        NO.ACT = DCOUNT(DR.ACT.LISTS, VM)
        FOR I = 1 TO NO.ACT
            ISCHED = IF (COLL.FLG) THEN 0 ELSE I - 1
        CLASS.LIST = ''
        ADV.ID = DR.ACT.LISTS<1,I>:"-":YLC.TYPE
        CALL DBR("EB.ADVICES":FM:EB.ADV.MSG.CLASS,ADV.ID,CLASS.LIST)
        IF ETEXT THEN
            ADV.ID = DR.ACT.LISTS<1,I>
            CALL DBR("EB.ADVICES":FM:EB.ADV.MSG.CLASS,ADV.ID,
            CLASS.LIST)
        END
        NO.DAYS = ''
        CALL DBR("EB.ACTIVITY":FM:EB.ACT.DAYS.PRIOR.EVENT,
        DR.ACT.LISTS<1,I>,NO.DAYS)
        *            DR.ACT.LISTS<1,I> = ADV.ID
        R.NEW(TF.DR.DELIVERY.DAYS)<1,I> = NO.DAYS
        NO.CLS = DCOUNT(MSG.CLASS.LIST,VM)
        FOR J = 1 TO NO.CLS
            FIND MSG.CLASS.LIST<1,J> IN CLASS.LIST SETTING YAF,YAV,YAS THEN
            R.NEW(TF.DR.MSG.CLASS.NO)<1,I,-1> = MSG.CLASS.LIST<1,J>
            R.NEW(TF.DR.SEND.NOTICE)<1,I,-1> = Y.AND.N.LIST<1,J>
            IF ISCHED AND Y.AND.N.LIST<1,J>[1,1] = 'Y' THEN
                R.NEW(TF.DR.CLASS.SCHED)<1,ISCHED,-1> = MSG.CLASS.LIST<1,J>
            END
        END
    NEXT J
    NEXT I
    END

    IF DR.OPER.TYPE >= 4000 AND NOT(COLL.FLG) THEN
        R.NEW(TF.DR.EB.ADV.NO) = DR.USANCE.ACT.LISTS
        DR.ACT.LISTS = DR.USANCE.ACT.LISTS
    END ELSE
        R.NEW(TF.DR.EB.ADV.NO) = DR.ACT.LISTS
    END
    RETURN

RAISE.BASIC.ACTIVITY:

*// Determine basic activity
    BEGIN CASE
        CASE COLL.FLG AND NOT(CO.DISC)  ; * Collection payment
            ACT.FLG = 1
        CASE NDR.TYPE = 'CO'
            DISCREPANT = R.NEW(TF.DR.DISCREPANCY)
            IF PAY.URESERVE THEN
                ACT.FLG = 5
            END ELSE
                ACT.FLG = IF UPCASE(DISCREPANT) = 'NO' THEN 2 ELSE 3
        END
    CASE NDR.TYPE = 'CC'
        *// If reverse, raise 93. Otherwise 41
        ACT.FLG = IF REV.FLG THEN 3 ELSE 41
    CASE NDR.TYPE = 'CR'
    ACT.FLG = 4                  ; * 3404, 3804, 4404 or 4804
    CASE NDR.TYPE = 'FR'
    ACT.FLG = 6                  ; * 3406, 3806, 4406, or 4806
    CASE NDR.TYPE = 'RP'            ; * Similar to 'SP'
    ACT.FLG = 1                  ; * 3401, 3801, 4401 or 4801
    CASE NDR.TYPE = 'MA' OR NDR.TYPE = 'MD'
    ACT.FLG = 7                  ; * 4407 or 4807
    CASE NDR.TYPE = 'AD'            ; * Both Sight and Usance
    ACT.FLG = 11                 ; * X111,X211,X411 or X811
    CASE DISCOUNT.SET
    ACT.FLG = 8                  ; * 4408
    CASE 1
    ACT.FLG = 1                  ; * Input/Authorise Activity
    END CASE
    DR.ACT.LISTS = 'LC-':FMT(DR.OPER.TYPE+REV.FLG+ACT.FLG,"4'0'R")

*// If EB.ACTIVITY not set, default will be used.
    DESC = ''
*      CALL DBR(EB.ACTIVITY,DR.ACT.LISTS,DESC)
*      IF ETEXT THEN
*         ETEXT = ''
*         DR.ACT.LISTS = 'LC-':FMT(DR.OPER.TYPE+REV.FLG+1,"4'0'R")
*         CALL DBR(EB.ACTIVITY,DR.ACT.LISTS,DESC)
*         IF ETEXT THEN
*            ETEXT = ''
*            DR.ACT.LISTS = 'LC-':FMT(DR.OPER.TYPE+REV.FLG,"4'0'R")
*         END
*      END
    DR.USANCE.ACT.LISTS = DR.ACT.LISTS
    RETURN

RAISE.MATURITY.ACTIVITY:
    BEGIN CASE
        CASE DR.OPER.TYPE < 4000
            RETURN
        CASE REV.FLG
            RETURN
        CASE DISCOUNT.SET
            ACT.FLG = 22                 ; * 4122, 4222, 4422 or 4822
        CASE 1
            ACT.FLG = 15                 ; * 4115, 4215, 4415 or 4815
    END CASE
    DR.ACT.LISTS := VM : 'LC-':FMT(DR.OPER.TYPE+ACT.FLG,"4'0'R")
    RETURN
*
* Raise Provision Class event, if the provision is set of this L/C
*
RAISE.PROVISION.CLASS:
    IF NOT(PROVISION.SET) THEN RETURN
    BEGIN CASE
        CASE USANCE AND CTRL.MODE
            RETURN
        CASE MATURE.EOD.UNCONFIRM.EXPORT
            RETURN
    END CASE
    IS.CUST = FALSE
    PROVISION.CLASS = 'PROVISION.CREDIT'
    PROV.AC = LC.REC(TF.LC.PROVIS.ACC)
    GOSUB UPDATE.PROVISION.CLASS
    PROVISION.CLASS = 'PROVISION.DEBIT'
    PROV.AC = LC.REC(TF.LC.CREDIT.PROVIS.ACC)
    GOSUB UPDATE.PROVISION.CLASS
    RETURN

UPDATE.PROVISION.CLASS:
    CUST.NO = ''
    CALL DBR("ACCOUNT":FM:AC.CUSTOMER,PROV.AC,CUST.NO)
    GOSUB IDENTIFY.PARTY.TYPE
    IF IS.BANK = CUSTOMER.TYPE THEN
        CLASS.TYPE = PROVISION.CLASS
        CALL UPDATE.CLASS.LIST(CLASS.TYPE, TRUE)
    END
    RETURN

RAISE.REIMBURSE.CLASS:
    CLASS.TYPE = "REIMBURSING"
    CLASS.SET = REIMBURSING.SET
    CALL UPDATE.CLASS.LIST(CLASS.TYPE, CLASS.SET)
    RETURN

RAISE.REV.PAYMENT.CLASS:
    CLASS.TYPE = "DEBIT.CUST"
    CLASS.SET = PAY.DEL
    CALL UPDATE.CLASS.LIST(CLASS.TYPE, CLASS.SET)
    RETURN
*
* Payment class is basically used to raised the payment
* message, i.e. MT900, 910, 100, 202 or 202 cover.
*
RAISE.PAYMENT.CLASS:
    IF PAY.DEL THEN
        GOSUB GET.CREDIT.PARTY
        GOSUB ADD.PAYMENT.CLASS
        GOSUB ADD.COVER.PAY.CLASS
        GOSUB ADD.RECEIVE.CLASS
    END
    RETURN
*
* This classed basically used to advise the receiver about
* the payment, which depend on type of party whether it is
* a bank or general customer.
*
ADD.PAYMENT.CLASS:
    GOSUB IDENTIFY.PARTY.TYPE
    IF PAYMNT.METHOD MATCH "N" THEN
        BEGIN CASE
                *            CASE IS.BANK = BANK.TYPE AND NOT(IS.CUST)
                *               CLASS.TYPE = "PAYMENT.CUST"
            CASE IS.BANK = BANK.TYPE AND PRESENT.PARTY
                CLASS.TYPE = "PAYMENT.BANK"
                *            CASE IS.BANK = CUSTOMER.TYPE
                *               CLASS.TYPE = "PAYMENT.CUST"
            CASE 1
                *               IF NOT(IS.CUST) THEN
                CLASS.TYPE = "PAYMENT.CUST"
                *               END
        END CASE
    END ELSE
        BEGIN CASE
            CASE IS.BANK = BANK.TYPE
                CLASS.TYPE = "PAYMENT.CUST"
            CASE IS.BANK = CUSTOMER.TYPE
                CLASS.TYPE = "CREDIT.CUST"
        END CASE
    END
    CLASS.SET = (IS.BANK # UNIDENTIFY.TYPE) OR IS.CUST
    CALL UPDATE.CLASS.LIST(CLASS.TYPE, CLASS.SET)
    RETURN
*
* This classed is used to attached the cover payment message.
*
ADD.COVER.PAY.CLASS:
    CORR.BANK = R.NEW(TF.DR.RECEIVERS.CORR)
    IF CORR.BANK THEN
        CUST.NO = R.NEW(TF.DR.RECEIVERS.BANK)
        GOSUB IDENTIFY.PARTY.TYPE
        IF IS.BANK = BANK.TYPE THEN
            IF NUM(CORR.BANK) THEN
                GOSUB CHECK.COVER.PAYMENT
            END ELSE
                CLASS.TYPE = "PAYMENT.BANK"
                CLASS.SET = TRUE
                CALL UPDATE.CLASS.LIST(CLASS.TYPE, CLASS.SET)
            END
        END
    END
    RETURN

CHECK.COVER.PAYMENT:
    FN.CU = 'F.CUSTOMER'
    F.CU = ''
    R.CORR.BNK = ''
    R.RECV.BNK = ''
    NOSTRO.ACCT = ''
    PRODUCE.FLG = TRUE
    CALL DBR(AGENCY.NOSTRO,CUST.NO,NOSTRO.ACCT.LISTS)
    IF NOSTRO.ACCT.LISTS THEN
        CALL OPF(FN.CU, F.CU)
        CALL F.READ(FN.CU,CORR.BANK,R.CORR.BNK,F.CU,YERR)
        CALL F.READ(FN.CU,CUST.NO,R.RECV.BNK,F.CU,YERR)
        IF SAME.RESIDENCE.AND.CCY.RESIDENCE THEN
            LOCATE PAY.ACCT IN NOSTRO.ACCT.LISTS<1> SETTING IND THEN
                PRODUCE.FLG = FALSE
            END
        END
    END
    IF PRODUCE.FLG THEN
        CLASS.SET = TRUE
        CLASS.TYPE = "COVER.BANK"
        CALL UPDATE.CLASS.LIST(CLASS.TYPE, CLASS.SET)
    END
    RETURN
*
* If need to advise receiver bank about the outgoing funds.
*
ADD.RECEIVE.CLASS:
    CALL DBR('ACCOUNT':FM:AC.CUSTOMER,R.NEW(TF.DR.DRAWDOWN.ACCOUNT),CUST.NO)   ; * GB0000603
    GOSUB IDENTIFY.PARTY.TYPE
    CLASS.SET = TRUE
    BEGIN CASE
        CASE IS.BANK = BANK.TYPE
            CLASS.TYPE = "RECEIVE.NOTIFY"
            CALL UPDATE.CLASS.LIST(CLASS.TYPE, CLASS.SET)
        CASE IS.BANK = CUSTOMER.TYPE
            CLASS.TYPE = "DEBIT.CUST"
            CALL UPDATE.CLASS.LIST(CLASS.TYPE, CLASS.SET)
    END CASE
    RETURN

IDENTIFY.PARTY.TYPE:
    IF NUM(CUST.NO) AND CUST.NO THEN
        CALL CHECK.ACCOUNT.CLASS("BANK","",CUST.NO,"",RTN.CODE)
        IF RTN.CODE = 'FATAL' THEN
            IS.BANK = IF IS.CUST THEN CUSTOMER.TYPE ELSE UNIDENTIFY.TYPE
    END ELSE
        IS.BANK = RTN.CODE[1,1] = 'Y'          ; * 0-Cust, 1-Bank
    END
    END
    RETURN

GET.CREDIT.PARTY:                        ; * Segregate Imp/Exp
    CUST.NO = PRESENT.PARTY
*// Take Advise Thru, if no presentor
    IF NOT(CUST.NO) THEN
        CUST.NO = ADVIS.THRU.BNK
    END
*// Take Beneficiary, if no ADVISE.THRU.BANK
    IF NOT(CUST.NO) THEN
        IF IMPORT.LC THEN
            CUST.NO = BENEFICIARY
        END ELSE
            IS.CUST = FALSE
            CALL DBR('ACCOUNT':FM:AC.CUSTOMER,R.NEW(TF.DR.PAYMENT.ACCOUNT),CUST.NO)        ; * GB0000603
        END
    END
    RETURN

GET.ACCT.PARTY:
    CALL DBR("ACCOUNT":FM:AC.CUSTOMER,ACCT.NO,CUST.NO)
    RETURN
*
* Condition matrix, whether need to raise payment message.
*
CHECK.PAYMENT.DELIVERY:
    BEGIN CASE
        CASE NDR.TYPE EQ 'CO' AND PAY.URESERVE
        CASE NDR.TYPE = 'SP' AND ODR.TYPE = 'CO' AND NOT(PAY.URESERVE)
        CASE (NDR.TYPE = 'SP' AND ODR.TYPE # 'RP') OR (NDR.TYPE = 'RP')
        CASE USANCE AND ODR.TYPE = 'CO' AND NOT(PAY.URESERVE)
            *         CASE USANCE AND MATURITY.CHANGE AND NOT(DISCOUNT.SET)
        CASE USANCE
            PAY.DEL = IF UNCONFIRM.EXPORT THEN FALSE ELSE TRUE
        *            PAY.DEL = IF CTRL.MODE THEN PAY.DEL ELSE TRUE
        *         CASE USANCE AND MATURITY.CHANGE AND DISCOUNT.SET
        *         CASE MATURE.USANCE AND NOT(DISCOUNT.SET)
    CASE MATURE.USANCE
    CASE 1
        PAY.DEL = FALSE
    END CASE
    RETURN

*
* Reassign the condition provided by users
*
SETUP.CLASS.CONTROL:
    FOR ICNT = 0 TO 3
        CLASS.CTRL<ICNT+1> = R.NEW(TF.DR.EB.ADV.NO+ICNT)
    NEXT ICNT

*// Consolidate message class from various activity
    MSG.LIST = CLASS.CTRL<3>
    YN.LIST = CLASS.CTRL<4>
    ADVISE.NOS = CLASS.CTRL<1>
    NO.ADVICES = DCOUNT(ADVISE.NOS, VM)
    FOR IADV = 1 TO NO.ADVICES
        IPOS = IF COLL.FLG THEN 0 ELSE IADV - 1
    NO.CLASSES = DCOUNT(MSG.LIST<1,IADV>, SM)
    FOR JADV = 1 TO NO.CLASSES
        MSG.CLS = MSG.LIST<1,IADV,JADV>
        YN.FLG = YN.LIST<1,IADV,JADV>
        IF IPOS AND YN.FLG[1,1] = 'Y' THEN
            R.NEW(TF.DR.CLASS.SCHED)<1,IPOS,-1> = MSG.CLS
        END
        LOCATE MSG.CLS IN MSG.CLASS.LIST<1,1> SETTING MSG.POS ELSE
            MSG.CLASS.LIST<1,-1> = MSG.CLS
            Y.AND.N.LIST<1,-1> = YN.FLG
        END
    NEXT JADV
    NEXT IADV
    RETURN
*
* Find whether which activity has already been sent
*
SET.ACTIVITY.SENT:
    ACT.SENT = DCOUNT(R.NEW(TF.DR.ACTIVITY.SENT),VM)
    FOR I = 1 TO ACT.SENT
        ACT.FLG = R.NEW(TF.DR.ACTIVITY.SENT)<1,I>
        ACT.FLG = ACT.FLG[6,2]
        BEGIN CASE
            CASE ACT.FLG = 14            ; * REIMBURSING SENT
                REIMBURSING.SENT = TRUE
            CASE ACT.FLG = 15            ; * REIMBURSING PAYMENT
                REIM.PAY.SENT = TRUE
            CASE ACT.FLG = 16            ; * REIMBURSING CLAIM
                REIM.CLAIM.SENT = TRUE
            CASE ACT.FLG = 17            ; * PROVISION RELEASE
                PROVISION.SENT = TRUE
        END CASE
    NEXT I
    RETURN

EOD.UPD.REIMB.SENT.FLD:
    IF NOT(ALREADY.SENT.FLG) THEN
        REIMB.ACT.NO = ACTIVITY.NO<1>
        GOSUB UPDATE.REIMB.SENT.FLD
    END
    RETURN

INITIALIZE:
    ACTIVITY.NO = ''
    DR.ACT.LISTS = ''                  ; * Keep Activity Lists
    DR.USANCE.ACT.LISTS = ''           ; * Keep Real Usance Activity
    YLC.REC = ''
    DE.REFERENCES = ''
    DE.REF = ''                        ; * returning DELIVERY reference
    ER.MSG = ''                        ; * Error message control
    SEND.NOTICE = ""                   ; * Message Class Control
    MSG.CLASS.LIST = ''
    Y.AND.N.LIST = ''
    IS.CUST = TRUE                     ; * Indicate CUSTOMER.TYPE
    LC.PARA.CLASS = R$PARAMETER(LC.PARA.LC.CLASS.TYPE)
    LC.PARA.EB.ID = R$PARAMETER(LC.PARA.EB.CLASS.NO)
    YLC.TYPE = LC.REC(TF.LC.LC.TYPE)
    NDR.TYPE = R.NEW(TF.DR.DRAWING.TYPE)
    ODR.TYPE = R.OLD(TF.DR.DRAWING.TYPE)
    COLL.FLG = IS.COLLECTION

*// Keep tracking whether activity has been sent
    REIM.CLAIM.SENT = FALSE
    REIMBURSING.SENT = FALSE
    REIM.PAY.SENT = FALSE
    PROVISION.SENT = FALSE
    GOSUB SET.ACTIVITY.SENT

*// Send advise associated to maturity event
    BEGIN CASE
        CASE MATURE.USANCE AND RUNNING.UNDER.BATCH
            REIMB.DATE = R.DATES(EB.DAT.PERIOD.END)
            MATURE.DATE = REIMB.DATE
            R.NEW(TF.DR.MAT.ADVICE.DATE) = MATURE.DATE
        CASE MATURE.USANCE
            REIMB.DATE = TODAY
            MATURE.DATE = REIMB.DATE
            R.NEW(TF.DR.MAT.ADVICE.DATE) = MATURE.DATE
            R.NEW(TF.DR.MANUAL.MATURITY) = MATURE.DATE
        CASE 1
            REIMB.DATE = TODAY
            MATURE.DATE = R.NEW(TF.DR.MATURITY.REVIEW)
    END CASE

    IF RUNNING.UNDER.BATCH THEN
        SEND.DATE = REIMB.DATE
        SCHED.NOS = DCOUNT(R.NEW(TF.DR.ADVIS.SCHEDULE),VM)
        ACT.FLG = ACTIVITY.NO<1>[6,2]
        FOR I = 1 TO SCHED.NOS
        UNTIL R.NEW(TF.DR.ADVIS.SCHEDULE)<1,I>[20,2] = ACT.FLG
        NEXT I
        ALREADY.SENT.FLG = FALSE
        BEGIN CASE
            CASE ACT.FLG = 14
                ALREADY.SENT.FLG = REIMBURSING.SENT
                GOSUB EOD.UPD.REIMB.SENT.FLD
            CASE ACT.FLG = 15
                ALREADY.SENT.FLG = REIM.PAY.SENT
            CASE ACT.FLG = 16
                ALREADY.SENT.FLG = REIM.CLAIM.SENT
                GOSUB EOD.UPD.REIMB.SENT.FLD
            CASE ACT.FLG = 17
                ALREADY.SENT.FLG = PROVISION.SENT
        END CASE
        IF NOT(ALREADY.SENT.FLG) THEN
            MSG.CLASS.LIST = R.NEW(TF.DR.CLASS.SCHED)<1,I>
            MSG.CLASS.LIST = RAISE(MSG.CLASS.LIST)
            DR.ACT.LISTS = ACTIVITY.NO<1>
            R.NEW(TF.DR.ACTIVITY.SENT)<1,-1> = ACTIVITY.NO<1>:'.':TODAY
        END
    END ELSE

        IS.BANK = UNIDENTIFY.TYPE
        IE.FLG = IS.IMPORT.EXPORT
        PAY.URESERVE = (R.NEW(TF.DR.UNDER.RESERVE)[1,1] = 'Y') AND (R.OLD(TF.DR.UNDER.RESERVE)[1,1] = '')
        PAYMNT.METHOD = R.NEW(TF.DR.PAYMENT.METHOD)

        * 1 - Outward, 2 - Inward, 4 - Export, 8 - Import
*****START***** GB0001257
        * BIT.FLG = BITSET(0,BITRESET(2,COLL.FLG)+IE.FLG)
        * The BITSET is replaced by BEGIN CASE.
        BEGIN CASE
            CASE NOT(IE.FLG) AND NOT(COLL.FLG)
                BIT.FLG = 4
            CASE NOT(IE.FLG) AND COLL.FLG
                BIT.FLG = 1
            CASE IE.FLG AND NOT(COLL.FLG)
                BIT.FLG = 8
            CASE IE.FLG AND COLL.FLG
                BIT.FLG = 2
        END CASE
        *
        * THis is to replace the BITTEST function  used in DEFINE.PARA
        *
        IMPORT.LC = BIT.FLG = 8
        EXPORT.LC = BIT.FLG = 4
*****END ***** GB0001257
        DR.FLG = BIT.FLG * 100
        PAY.DEL = TRUE

        *// Segregate Activities 3000 - Sight, 4000 - Usance
        BEGIN CASE
            CASE NDR.TYPE = 'SP'
                DR.OPER.TYPE = 3000
            CASE USANCE OR MATURE.USANCE
                DR.OPER.TYPE = 4000
            CASE R$TYPES(LC.TYP.PAY.TYPE) = 'P'
                DR.OPER.TYPE = 3000
            CASE 1
                DR.OPER.TYPE = 4000
        END CASE
        DR.OPER.TYPE += DR.FLG          ; * Formulate the real activity
        REV.FLG = IF REVERSE.SET THEN 90 ELSE 0   ; * Reverse Activity
    DISCOUNT.SET = PROCESS.DISCOUNT
    PROVISION.SET = (LC.REC(TF.LC.PRO.OUT.AMOUNT) > 0)
    OLD.ADVICE.DATE = R.NEW(TF.DR.MAT.ADVICE.DATE)
* This will allow maximum delivery generate possible
*         CTRL.MODE = (PREVIEW.MODE = '')
    CTRL.MODE = FALSE
    ACCT.OFFICER = FMT(LC.REC(TF.LC.ACCOUNT.OFFICER),"4'0'R")

*// Prepare EB.CLASS control info.
*// CLASS.CTRL<1> = EB.ACTIVITY.NO
*// CLASS.CTRL<2> = NUMBER OF DAYS BEFORE MATURITY
*// CLASS.CTRL<3> = MESSAGE.CLASS
*// CLASS.CTRL<4> = Y and N flag
    CLASS.CTRL = ''
    R.NEW(TF.DR.ADVIS.SCHEDULE) = ''
    R.NEW(TF.DR.CLASS.SCHED) = ''
    DR.CLS.LIST = BASIC.MSG.CLASS
    CALL INIT.CLASS.MSG(DR.CLS.LIST)
    GOSUB SETUP.CLASS.CONTROL
    END
    RETURN
    END
