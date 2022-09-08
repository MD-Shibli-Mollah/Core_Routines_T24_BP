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
* <Rating>105</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctOrderCapture
    SUBROUTINE CONV.SEC.OPEN.ORDER.R07
* Conversion Routine to update SOO F.ENTRIES with CYCLE.FORWARD = 'Y'
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_F.SC.PARAMETER

    ORIG.COMPANY = ID.COMPANY
    F.COMPANY = ''
    CALL OPF('F.COMPANY',F.COMPANY)

    SEL.CMD = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'
    COM.LIST = '' ; YSEL = 0
    CALL EB.READLIST(SEL.CMD,COM.LIST,'',YSEL,'')
    LOOP
        REMOVE K.COMPANY FROM COM.LIST SETTING END.OF.COMPANIES
    WHILE K.COMPANY:END.OF.COMPANIES
        IF K.COMPANY <> ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
        END
        LOCATE 'SC' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING PROD.POSN THEN
            GOSUB PROCESS.SOO.FWD.ENTRIES
        END
    REPEAT
    IF ORIG.COMPANY <> ID.COMPANY THEN
        CALL LOAD.COMPANY(ORIG.COMPANY)
    END
    RETURN

PROCESS.SOO.FWD.ENTRIES:
*--------------------
    SAVE.COMPANY = '' ; SAVE.FENTRY.IDS = '' ; COMP.POS = 0

    F.TRANS.FWD = ""
    FN.TRANS.FWD = "F.TRANS.FWD"
    CALL OPF(FN.TRANS.FWD,F.TRANS.FWD)
    F.STMT.ENTRY = ''
    CALL OPF('F.STMT.ENTRY',F.STMT.ENTRY)

    CALL DBR('SC.PARAMETER':FM:SC.PARAM.OPN.ORD.FWD.ACCT,ID.COMPANY,FWD.ENTRY.FLAG)
    IF FWD.ENTRY.FLAG = 'Y' OR FWD.ENTRY.FLAG = 'UNAUTH' THEN
        SEL.CMD = ' SELECT ' :FN.TRANS.FWD : ' LIKE OPODSC...'
        FWD.ENTRIES.LIST = '' ; YSEL = 0
        CALL EB.READLIST(SEL.CMD,FWD.ENTRIES.LIST,'',YSEL,'')
        LOOP
            REMOVE TRANS.REF FROM FWD.ENTRIES.LIST SETTING END.OF.FWD.ENT
        WHILE TRANS.REF:END.OF.FWD.ENT
            R.TRANS.FWD = '' ; YERR = ''
            CALL F.READ('F.TRANS.FWD',TRANS.REF,R.TRANS.FWD,'',YERR)
            LOOP
                REMOVE FENTRY FROM R.TRANS.FWD SETTING FWDPOS
            WHILE FENTRY:FWDPOS DO
                COMP.MNEMONIC = FIELD(FENTRY,"\",2)
                IF R.COMPANY(3) NE COMP.MNEMONIC THEN
                    LOCATE COMP.MNEMONIC IN SAVE.COMPANY SETTING COMP.MNE THEN
                        SAVE.FENTRY.IDS<COMP.MNE> = SAVE.FENTRY.IDS<COMP.MNE>:VM:FIELD(FENTRY,"\",1)
                    END ELSE
                        SAVE.COMPANY<-1> = COMP.MNEMONIC
                        COMP.POS += 1
                        SAVE.FENTRY.IDS<COMP.POS,1>= FIELD(FENTRY,"\",1)
                    END
                    CONTINUE
                END
                FENTRY.ID = FIELD(FENTRY,"\",1)
                GOSUB WRITE.STMT.ENTRIES
            REPEAT
        REPEAT
        GOSUB PROCESS.OTHER.COMPANIES

    END
    RETURN
*-------------------------
PROCESS.OTHER.COMPANIES:
*-------------------------
    COMP.NO = 1
    LOOP
        REMOVE COMPANY.MNE FROM SAVE.COMPANY SETTING COMPANY.CODE
    WHILE COMPANY.MNE:COMPANY.CODE
        CALL LOAD.COMPANY(COMPANY.MNE)
        CALL OPF('F.STMT.ENTRY',F.STMT.ENTRY)
        COMP.ENTRIES = SAVE.FENTRY.IDS<COMP.NO>
        CONVERT VM TO FM IN COMP.ENTRIES
        LOOP
            REMOVE FENTRY.ID FROM COMP.ENTRIES SETTING ENTRY.FOUND
        WHILE FENTRY.ID:ENTRY.FOUND
            GOSUB WRITE.STMT.ENTRIES
        REPEAT
        COMP.NO += 1
    REPEAT
    RETURN

*------------------
WRITE.STMT.ENTRIES:
*------------------
    R.STMT.ENTRY = '' ; YERR1 = ''
    CALL F.READ('F.STMT.ENTRY',FENTRY.ID,R.STMT.ENTRY,'',YERR1)
    IF R.STMT.ENTRY<52> NE 'Y' AND NOT(YERR1) THEN
        R.STMT.ENTRY<52> = 'Y'
        WRITE R.STMT.ENTRY TO F.STMT.ENTRY, FENTRY.ID
    END
    RETURN
END
