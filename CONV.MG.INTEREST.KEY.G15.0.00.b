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
* <Rating>33</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE MG.Interest
    SUBROUTINE CONV.MG.INTEREST.KEY.G15.0.00

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_CONV.COMMON
    $INSERT I_F.COMPANY

*******************************************************************
* Modifications
*
* 24/05/04 - EN_100002260
*            Convert MG.INTEREST.KEY id.
*
*******************************************************************
*
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
        LOCATE 'MG' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING FOUND.POS THEN

            GOSUB INITIALISE

            GOSUB SELECT.MG.INTEREST.KEY.RECORDS

            GOSUB PROCESS.MG.INTEREST.KEY.RECORDS

        END

    REPEAT

*Restore back ID.COMPANY if it has changed.

    IF ID.COMPANY <> SAVE.ID.COMPANY THEN
        CALL LOAD.COMPANY(SAVE.ID.COMPANY)
    END

    RETURN

************************************************************************

INITIALISE:
***********

    FN.MG.INTEREST.KEY = "F.MG.INTEREST.KEY"
    F.MG.INTEREST.KEY = ""
    CALL OPF(FN.MG.INTEREST.KEY,F.MG.INTEREST.KEY)

    RETURN

************************************************************************

SELECT.MG.INTEREST.KEY.RECORDS:
*******************************

*
* Select all MG.INTEREST.KEY records
*

    KEY.LIST = ""
    SELECTED = ""
    RET.CODE = ""

    SELECT.COMMAND = "SELECT ":FN.MG.INTEREST.KEY

    CALL EB.READLIST(SELECT.COMMAND,KEY.LIST,"",SELECTED,RET.CODE)

    RETURN

***********************************************************************

PROCESS.MG.INTEREST.KEY.RECORDS:
********************************

    LOOP
        REMOVE MG.KEY.ID FROM KEY.LIST SETTING KEY.POS
    WHILE MG.KEY.ID:KEY.POS
        GOSUB READ.MG.INTEREST.KEY
        LOOP
            REMOVE MG.CONTRACT.ID FROM CONTRACTS.LIST SETTING CONT.POS
        WHILE MG.CONTRACT.ID:CONT.POS
            GOSUB WRITE.MG.INTEREST.KEY
        REPEAT
        GOSUB DELETE.OLD.MG.INTEREST.KEY
    REPEAT

    RETURN

READ.MG.INTEREST.KEY:
*********************

    READ CONTRACTS.LIST FROM F.MG.INTEREST.KEY,MG.KEY.ID ELSE CONTRACTS.LIST = ""

    RETURN

**********************************************************************

WRITE.MG.INTEREST.KEY:
**********************

    NEW.KEY.ID = MG.KEY.ID:".":MG.CONTRACT.ID

    WRITE "" TO F.MG.INTEREST.KEY,NEW.KEY.ID

    RETURN

**********************************************************************

DELETE.OLD.MG.INTEREST.KEY:
***************************

    DELETE F.MG.INTEREST.KEY,MG.KEY.ID

    RETURN

**********************************************************************

END
