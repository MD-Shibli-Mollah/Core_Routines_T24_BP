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
* <Rating>36</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.AccountClosure
    SUBROUTINE CONV.ACCOUNT.CLOSED.G16.0.0
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_F.COMPANY.CHECK
*
*************************************************************************
* 11/04/05 - EN_10002472
*            This conversion is used to convert all the ACCOUNT.CLOSED
*            records as per the new layout.
*
* 10/03/08 - CI_10054055
*            ACCOUNT.CLOSED not converted for all companies.
*
* 27/05/08 - CI_10055641
*            Company read from COMPANY.CHECK.
*************************************************************************
* NEW.LAYOUT:
*            Now ACCOUNT.CLOSED keyed on account number with closure
*            date as the only field.
* OLD.LAYOUT:
*           Id of ACCOUNT.CLOSED is date inside all the accounts reside.
**************************************************************************
*
    SAVE.ID.COMPANY = ID.COMPANY
*
* Loop through each company
*
    F.COMPANY.CHECK = ''
    CALL OPF("F.COMPANY.CHECK", F.COMPANY.CHECK)

    CALL F.READ("F.COMPANY.CHECK", "FIN.FILE", COMP.CHECK.REC, F.COMPANY.CHECK, "")
    COMPANY.LIST = COMP.CHECK.REC<EB.COC.COMPANY.CODE>

    LOOP
        REMOVE K.COMPANY FROM COMPANY.LIST SETTING COMP.MARK
    WHILE K.COMPANY:COMP.MARK
*
        IF K.COMPANY <> ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
        END
*
        GOSUB INITIALISE
        GOSUB SELECT.ACCT.CLOSED.RECORDS
        GOSUB PROCESS.ACCT.CLOSED.RECORDS
*
    REPEAT

    IF ID.COMPANY <> SAVE.ID.COMPANY THEN
        CALL LOAD.COMPANY(SAVE.ID.COMPANY)
    END
    RETURN
*
INITIALISE:
*
    FN.ACCOUNT.CLOSED = 'F.ACCOUNT.CLOSED'
    F.ACCOUNT.CLOSED = ''
    CALL OPF(FN.ACCOUNT.CLOSED,F.ACCOUNT.CLOSED)
    RETURN
*
SELECT.ACCT.CLOSED.RECORDS:
    SELECT.COMMAND = ''
    KEY.LIST = ''
    RET.CODE = ''
    SELECT.COMMAND = 'SELECT ':FN.ACCOUNT.CLOSED

    CALL EB.READLIST(SELECT.COMMAND,KEY.LIST,'',SELECTED,RET.CODE)

    RETURN
*
PROCESS.ACCT.CLOSED.RECORDS:

    LOOP
        REMOVE ID.DATE FROM KEY.LIST SETTING DATE.POS
    WHILE ID.DATE:DATE.POS
        GOSUB READ.ACCT.CLOSED
        LOOP
            REMOVE ACCT.ID FROM ACCT.IDS SETTING ACCT.ID.POS
        WHILE ACCT.ID:ACCT.ID.POS
            GOSUB WRITE.ACCT.CLOSED
        REPEAT
        GOSUB DELETE.ACCT.CLOSED
    REPEAT
    RETURN
*
READ.ACCT.CLOSED:
    READ ACCT.IDS FROM F.ACCOUNT.CLOSED,ID.DATE ELSE ACCT.IDS = ''
    RETURN
*
WRITE.ACCT.CLOSED:
    WRITE ID.DATE TO F.ACCOUNT.CLOSED, ACCT.ID
    RETURN
*
DELETE.ACCT.CLOSED:
    DELETE F.ACCOUNT.CLOSED,ID.DATE
    RETURN
END
