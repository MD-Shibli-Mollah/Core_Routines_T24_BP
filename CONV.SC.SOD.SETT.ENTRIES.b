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
* <Rating>93</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctSettlement
    SUBROUTINE CONV.SC.SOD.SETT.ENTRIES
**********************************************************************
* Conversion Routine to update the F.ENTRIES with CYCLE.FORWARD = 'Y'
*
* 31/05/06 - CI_10041494
*            Conversion routine for CONV.SC.SETT.ENTRIES.R06
*
* 12/12/06 - CI_10046051
*            Batch job SC.SOD.ENT.FWD.ACCT made obsolete.
*            Forward entries for entitlement records in INAU status
*            are also included as part of this conversion.
**********************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_F.DIARY
    $INSERT I_F.DIARY.TYPE
    $INSERT I_F.ENTITLEMENT
    $INSERT I_F.SC.PARAMETER
**********************************************************************
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
            GOSUB PROCESS.SETT.ENTRIES
            GOSUB PROCESS.INAU.ENTITLEMENTS
        END
    REPEAT
    IF ORIG.COMPANY <> ID.COMPANY THEN
        CALL LOAD.COMPANY(ORIG.COMPANY)
    END

    RETURN
**********************************************************************
PROCESS.SETT.ENTRIES:

    SAVE.COMPANY = '' ; SAVE.FENTRY.IDS = '' ; COMP.POS = 0

    F.SC.SETT.ENTRIES = ""
    FN.SC.SETT.ENTRIES = "F.SC.SETT.ENTRIES"
    CALL OPF(FN.SC.SETT.ENTRIES,F.SC.SETT.ENTRIES)
    F.STMT.ENTRY = ''
    CALL OPF('F.STMT.ENTRY',F.STMT.ENTRY)

    CALL DBR('SC.PARAMETER':FM:SC.PARAM.SUP.ACT.FWD.ENT,ID.COMPANY,SUP.Y.N)
    IF SUP.Y.N = 'NO' THEN
        SEL.CMD = 'SSELECT ' :FN.SC.SETT.ENTRIES
        YID.LIST = '' ; YSEL = 0
        CALL EB.READLIST(SEL.CMD,YID.LIST,'',YSEL,'')
        GOSUB PROCESS.ENTRIES
    END

    RETURN
**********************************************************************
PROCESS.INAU.ENTITLEMENTS:

    SAVE.COMPANY = '' ; COMP.POS = 0
    YID.LIST = '' ; SAVE.FENTRY.IDS = ''

    FN.SC.CON.ENT = 'F.SC.CON.ENTITLEMENT'
    F.SC.CON.ENT = ''
    CALL OPF(FN.SC.CON.ENT,F.SC.CON.ENT)

    FN.DIARY = 'F.DIARY'
    F.DIARY = ''
    CALL OPF(FN.DIARY,F.DIARY)

    FN.ENTL.NAU = 'F.ENTITLEMENT$NAU'
    F.ENTL.NAU = ''
    CALL OPF(FN.ENTL.NAU,F.ENTL.NAU)

    SEL.CMD = 'SELECT ' : FN.SC.CON.ENT
    DIARY.LIST = '' ; YSEL = 0
    CALL EB.READLIST(SEL.CMD,DIARY.LIST,'',YSEL,'')

    LOOP
        REMOVE DIARY.ID FROM DIARY.LIST SETTING END.OF.DIARY.LIST
    WHILE DIARY.ID:END.OF.DIARY.LIST
        R.DIARY = '' ; DIARY.ERR = ''
        CALL F.READ(FN.DIARY,DIARY.ID,R.DIARY,F.DIARY,DIARY.ERR)
        DIARY.TYPE = R.DIARY<SC.DIA.EVENT.TYPE>

        R.DIARY.TYPE = ''
        CALL CACHE.READ('F.DIARY.TYPE',DIARY.TYPE,R.DIARY.TYPE,'')
        FWD.ACCT = R.DIARY.TYPE<SC.DRY.FWD.ACCT>

        IF FWD.ACCT = 'YES' THEN
            R.SC.CON.ENTITLEMENT = '' ; CONCAT.ERR = ''
            CALL F.READ(FN.SC.CON.ENT,DIARY.ID,R.SC.CON.ENTITLEMENT,F.SC.CON.ENT,CONCAT.ERR)
            LOOP
                REMOVE ENTL.ID FROM R.SC.CON.ENTITLEMENT SETTING END.OF.ENTL.LIST
            WHILE ENTL.ID:END.OF.ENTL.LIST
                R.ENTL = '' ; ENTL.ERR = ''
                CALL F.READ(FN.ENTL.NAU,ENTL.ID,R.ENTL,F.ENTL.NAU,ENTL.ERR)
                IF R.ENTL<SC.ENT.RECORD.STATUS> EQ 'INAU' THEN
                    YID.LIST<-1> = ENTL.ID
                END
            REPEAT
            YID.LIST<-1> = DIARY.ID
        END
    REPEAT

    IF YID.LIST THEN
        GOSUB PROCESS.ENTRIES
    END

    RETURN
**********************************************************************
PROCESS.ENTRIES:

    LOOP
        REMOVE TRANS.REF FROM YID.LIST SETTING END.OF.ID.LIST
    WHILE TRANS.REF:END.OF.ID.LIST
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

    RETURN
**********************************************************************
PROCESS.OTHER.COMPANIES:

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
**********************************************************************
WRITE.STMT.ENTRIES:

    R.STMT.ENTRY = '' ; YERR1 = ''
    CALL F.READ('F.STMT.ENTRY',FENTRY.ID,R.STMT.ENTRY,'',YERR1)
    IF R.STMT.ENTRY<52> NE 'Y' AND NOT(YERR1) THEN
        R.STMT.ENTRY<52> = 'Y'
        WRITE R.STMT.ENTRY TO F.STMT.ENTRY, FENTRY.ID
    END

    RETURN
**********************************************************************
END
