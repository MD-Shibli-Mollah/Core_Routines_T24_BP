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
* <Rating>-21</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.BalanceUpdates
    SUBROUTINE CONV.ACCT.BK.BALANCE.UPD

* This conversion routine is to update the BK.BALANCE field in ACCT.ACTIVITY if it
* is not updated prior to running conversion.This updation happens from the account's
* OPEN.ACTUAL.BALANCE field.
*************************************************************************************
* Modification logs:
* -----------------
*
* 01/02/07 - BG_100013175
*            New routine
*************************************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE

***********************************************************************************

    SEL.CMD = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'
    COMPANY.LIST = ''
    CALL EB.READLIST(SEL.CMD, COMPANY.LIST ,'' , '' , '')

    IDX = 0
    SAVE.CO.CODE = ID.COMPANY
    LOOP
        IDX += 1
        COMP.ID = COMPANY.LIST<IDX>
    WHILE COMP.ID DO

        GOSUB CALL.LOAD.COMPANY
        GOSUB INITIALISE      ;* Initialise and open files here

        DUMMY = ''
        WRITE DUMMY ON F.AC.CONV.ENTRY, "BKUPDATE"

    REPEAT

    COMP.ID = SAVE.CO.CODE
    GOSUB CALL.LOAD.COMPANY

    RETURN

***********************************************************************************
INITIALISE:
*----------

    FN.AC.CONV.ENTRY = 'F.AC.CONV.ENTRY'
    F.AC.CONV.ENTRY = ''
    CALL OPF(FN.AC.CONV.ENTRY,F.AC.CONV.ENTRY)

    RETURN

************************************************************************************
CALL.LOAD.COMPANY:
*-----------------
    IF COMP.ID <> ID.COMPANY THEN
        CALL LOAD.COMPANY(COMP.ID)
    END

    RETURN

END
