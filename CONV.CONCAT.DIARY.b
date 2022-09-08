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

* Version 1 14/09/01  GLOBUS Release No. G12.0.03 14/09/01
*-----------------------------------------------------------------------------
* <Rating>58</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SccEntitlements
    SUBROUTINE CONV.CONCAT.DIARY
*
*
*********************************************************
*
* This is a conversion program run by CONVERSION.DETAILS
* This program adds the sub account as the new element
* of the key of ENTITLEMENT for each record of the
* CONCAT.DIARY file
*
* author : P.LABE
*
* 22/03/05 - CI_10028622
*            Multicompany compatible
*
* 12/05/05 - CI_10030114
*            Multi conv stops if there is no record in one company
*
*********************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
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
        GOSUB OPEN.FILES

* Select list from concat file
*
        YLIST = '' ; * CI_10030114
        YSELECT = 'SSELECT ':FN.CONCAT.DIARY
        CALL EB.READLIST(YSELECT,YLIST,'','','')
* CI_10030114 Lines deleted
        LOOP
            REMOVE YID FROM YLIST SETTING MORE
*
        WHILE YID DO
*
            REC = ''
            CALL F.READU(FN.CONCAT.DIARY,YID,REC,F.CONCAT.DIARY,ER,'R 05 12')
            IF ER THEN
                E = 'RECORD & NOT FOUND ON FILE & ':FM:YID:VM:FN.CONCAT.DIARY
                GOTO FATAL.ERROR
            END
*
            YNB = DCOUNT(REC,FM)
*
            FOR I = 1 TO YNB
                REC<I> = REC<I>:'.'
            NEXT I
*
            CALL F.WRITE(FN.CONCAT.DIARY,YID,REC)
*
            CALL JOURNAL.UPDATE(YID)
*
        REPEAT
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
*
*****************************************************************
OPEN.FILES:
*****************************************************************

*
    FN.CONCAT.DIARY = 'F.CONCAT.DIARY'
    F.CONCAT.DIARY = ''
    CALL OPF(FN.CONCAT.DIARY,F.CONCAT.DIARY)
*
    RETURN

******************************************************************
******************************************************************

FATAL.ERROR:

    TEXT = E
    CALL FATAL.ERROR('CONV.CONCAT.DIARY')


END
