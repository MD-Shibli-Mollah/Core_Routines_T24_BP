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
* <Rating>-28</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RE.Consolidation
    SUBROUTINE CONV.RE.CONSOL.ACCOUNT.R07
******************************************************************
* This conversion routine is used to move all the RE.CONSOL.ACCOUNT
* records to RE.CONSOL.CONTRACT/.SEQU files with id as CONSOL.KEY
* in the eod routine EOD.AC.CONV.ENTRY
*******************************************************************
* 17/06/06 - EN_10002948
*            Tidy up link file updates for accounts
*            Ref : SAR-2006-05-09-0001
*
* 11/07/06 - BG_100011644/Ref:TTS0604404
*            RE.CONSOL.CONTRACT is not built for other companies at the time of conversion.
*
*******************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
***   Main processing   ***
*     ---------------     *

    SAVE.ID.COMPANY = ID.COMPANY
*
* Loop through each company
*
    COMMAND = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'
    COMPANY.LIST = ''
    CALL EB.READLIST(COMMAND, COMPANY.LIST, '', '', '')

    LOOP
        REMOVE K.COMPANY FROM COMPANY.LIST SETTING COMP.MARK
    WHILE K.COMPANY:COMP.MARK

        IF K.COMPANY <> ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
        END
*
* Check whether product is installed
*

        GOSUB INITIALISE

        GOSUB WRITE.AC.CONV.ENTRY.TO.TRIGGER.CONVERSION

    REPEAT

*Restore back ID.COMPANY if it has changed.

    IF ID.COMPANY <> SAVE.ID.COMPANY THEN
        CALL LOAD.COMPANY(SAVE.ID.COMPANY)
    END

    RETURN

*---------*
INITIALISE:
*---------*

    FN.AC.CONV.ENTRY = 'F.AC.CONV.ENTRY'
    F.AC.CONV.ENTRY = ''
    CALL OPF(FN.AC.CONV.ENTRY,F.AC.CONV.ENTRY)

    RETURN
*
***********************************************************************************************************
WRITE.AC.CONV.ENTRY.TO.TRIGGER.CONVERSION:
*****************************************
*     -----------------------------------------------         *
***   Write one off record 'RE.CONSOL.CONTRACT' to trigger  ***
***   the update of RE.CONSOL.CONTRACT file during EOD      ***
***                                                         ***
*     -----------------------------------------------         *

    DUMMY = ''
    WRITE DUMMY ON F.AC.CONV.ENTRY,'UPDATELINK'
    RETURN
END

