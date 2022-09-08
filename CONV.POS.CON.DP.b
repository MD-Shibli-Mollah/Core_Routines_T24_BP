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

* Version 1 29/06/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>35</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoSecurityPositionUpdate
    SUBROUTINE CONV.POS.CON.DP
*
*
*********************************************************
*
* This is a conversion program run by CONVERSION.DETAILS
* author : L.COLI
*
* 22/03/05 - CI_10028622
*            Multicompany compatible
*
* 09/05/08 - CI_10055270
*            Extra dots were appended to SECURITY.POSITION and its related concat files.
*********************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY

    EQU TRUE TO 1, FALSE TO 0

*====================================================
* Main controlling section
*====================================================
* CI_10028622 S
    SAVE.ID.COMPANY = ID.COMPANY
*
* Loop through each company
*
* GB9701190 - Not for Conslidation and Reporting companies
    COMMAND = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'
    COMPANY.LIST = ''
    CALL EB.READLIST(COMMAND, COMPANY.LIST, '','','')
    LOOP
        REMOVE K.COMPANY FROM COMPANY.LIST SETTING COMP.MARK
    WHILE K.COMPANY:COMP.MARK
*
        IF K.COMPANY <> ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
        END
* CI_10028622 E
        IF R.COMPANY(EB.COM.MNEMONIC) EQ R.COMPANY(EB.COM.FINAN.FINAN.MNE) THEN
            GOSUB OPEN.FILES
            GOSUB PROCESS.POS.CON.DP
        END
* CI_10028622 S
* Processing for this company now complete.
*
    REPEAT
*
* Processing now complete for all companies.
* Change back to the original company if we have changed.
*
    IF ID.COMPANY <> SAVE.ID.COMPANY THEN
        CALL LOAD.COMPANY(SAVE.ID.COMPANY)
    END
* CI_10028622 E
*
    RETURN

*****************************************************************
OPEN.FILES:
*****************************************************************

*
    FN.POS.CON.DP = 'F.POS.CON.DP'
    F.POS.CON.DP = ''
    CALL OPF(FN.POS.CON.DP,F.POS.CON.DP)
*
    RETURN

******************************************************************
PROCESS.POS.CON.DP:
* Select list
*

    SEL.CMD = "SELECT ":FN.POS.CON.DP
    CALL EB.READLIST(SEL.CMD,SEL.LIST,"","","")
*
    LOOP
        REMOVE PORT FROM SEL.LIST SETTING MORE
    WHILE PORT:MORE
        CALL F.READ(FN.POS.CON.DP,PORT,R.FILE,F.POS.CON.DP,ER)
        IF ER THEN
            E = 'RECORD & NOT FOUND ON FILE & ':FM:PORT:VM:"F.POS.CON.DP"
            GOTO FATAL.ERROR
        END
*
        REC.NB = DCOUNT(R.FILE,FM)
*
        FOR I = 1 TO REC.NB   ;*process each line
            R.FILE<I> = R.FILE<I>:'.'
        NEXT I
        CALL F.WRITE(FN.POS.CON.DP,PORT,R.FILE)   ;*save the record
        CALL JOURNAL.UPDATE(PORT)
    REPEAT
    RETURN
******************************************************************

FATAL.ERROR:

    TEXT = E
    CALL FATAL.ERROR('CONV.POS.CON.DP')


END
