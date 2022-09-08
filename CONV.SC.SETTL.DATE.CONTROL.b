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
* <Rating>37</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctSettlement
    SUBROUTINE CONV.SC.SETTL.DATE.CONTROL

*********************************************************
*
* This is a conversion routine run by CONVERSION.DETAILS
* for SC.SETTL.DATE.CONTROL file.
* This program converts the ID of all the existing
* REDEMPTION.CUS records to include the SUB.ACCOUNT in
* the key of the REDEMPTION.CUS record.
*
* author : P.LABE
*
* 13-11-01 CI_10000508/GB0102292
*          The modification concerns only
*               DIV.COUP.CUS
*               REDEMPTION.CUS
*               ENTITLEMENT
*               CAPTL.INCREASE.CUS
*               STOCK.DIV.CUS
*
* 20/07/06 - GLOBUS_CI_10042798
*            In addition this program handles the conversion of
*            trans reference in SC.HOLD.ENTRIES to include the SUB.ACCOUNT.
*
*********************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE

*====================================================
* Main controlling section
*====================================================

    GOSUB OPEN.FILES

    LIST = ''
    CMD = 'SSELECT ':FN.FILE
    CALL EB.READLIST(CMD,LIST,'','','')
    IF NOT(LIST) THEN
        RETURN
    END
*CI10000508-S
    LIST.PGM = ''
    LIST.PGM = 'DIV.COUP.CUS':FM:'REDEMPTION.CUS':FM:'ENTITLEMENT':FM:'CAPTL.INCREASE.CUS':FM:'STOCK.DIV.CUS'
*CI10000508-E
    LOOP
        REMOVE CODE FROM LIST SETTING MORE

    WHILE CODE DO
*
        CALL F.READU(FN.FILE,CODE,R.FILE,F.FILE,ER,'R 05 12')
        IF ER THEN
            E = 'RECORD & NOT FOUND ON FILE & ':FM:CODE:VM:F.FILE
            GOTO FATAL.ERROR
        END

        NB.REC = 0  ;*CI10000508
        NB.KEY = DCOUNT(R.FILE<2>,VM)
        FOR I = 1 TO NB.KEY
            LOCATE R.FILE<3,I> IN LIST.PGM<1> SETTING MATCH.PGM THEN  ;*CI10000508
                YID = R.FILE<1,I>
                YFIELD = R.FILE<2,I>
                R.FILE<2,I> = R.FILE<2,I>:'.' ; NB.REC += 1 ;*CI10000508
                GOSUB UPDATE.SC.HOLD.ENTRIES
            END
        NEXT I

        IF NB.REC THEN        ;*CI10000508
            CALL F.WRITE(FN.FILE,CODE,R.FILE)
            CALL JOURNAL.UPDATE(CODE)
        END ELSE    ;*CI10000508
            CALL F.RELEASE(FN.FILE,CODE,F.FILE)   ;*CI10000508
        END
*
    REPEAT
*
    RETURN
*---------------------
UPDATE.SC.HOLD.ENTRIES:
*---------------------
* Locate the trans reference and update the SUB.ACCOUNT in
* SC.HOLD.ENTRIES records.

    HOLD.REC = ''; ER = ''
    CALL F.READ(FN.SC.HOLD.ENTRIES,YID,HOLD.REC,F.SC.HOLD.ENTRIES,ER)
    IF NOT(ER) THEN
        FLD.CNT = DCOUNT(HOLD.REC,FM)
        FOR J = 1 TO FLD.CNT
            LOCATE YFIELD IN HOLD.REC<J,1> SETTING FOUND THEN
                HOLD.REC<J,FOUND> = HOLD.REC<J,FOUND>:'.'
            END
        NEXT J
        CALL F.WRITE(FN.SC.HOLD.ENTRIES,YID,HOLD.REC)
    END
*
    RETURN
*****************************************************************
OPEN.FILES:
*****************************************************************

*
    FN.FILE = 'F.SC.SETTL.DATE.CONTROL'
    F.FILE = ''
    CALL OPF(FN.FILE,F.FILE)
    FN.SC.HOLD.ENTRIES = 'F.SC.HOLD.ENTRIES'
    F.SC.HOLD.ENTRIES = ''
    CALL OPF(FN.SC.HOLD.ENTRIES,F.SC.HOLD.ENTRIES)
*
    RETURN

******************************************************************
******************************************************************

FATAL.ERROR:

    TEXT = E
    CALL FATAL.ERROR('CONV.SC.SETTL.DATE.CONTROL')


END
