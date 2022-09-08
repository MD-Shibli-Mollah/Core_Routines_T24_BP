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
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
* Version n dd/mm/yy  GLOBUS Release No. 200508 30/06/05
*
    $PACKAGE RE.ConBalanceUpdates
    SUBROUTINE CONV.AL.ECB.R08
*----------------------------------------------------------------------------------
*
* Template file routine, to be used as a basis for building a FILE.ROUTINE
* to be run as part of the CONVERSION.DETAILS record.
* This routine should only be used to do such things as change record keys etc
* wherever possible use the RECORD.ROUTINE to convert/populate record data fields.
*
*-------------------------------------------------------------------------------
*                      M O D I F I C A T I O N
*-------------------------------------------------------------------------------
* 25/04/07- EN_10003338
*           New routine for SAR-2007-03-09-0001 AL to update EB.CONTRACT.BALANCES
*
*-------------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE

*-------------------------------------------------------------------------------

*-- Main processing

    SAVE.ID.COMPANY = ID.COMPANY

*-- Loop through each company

    COMMAND = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'
    COMPANY.LIST = ''
    CALL EB.READLIST(COMMAND, COMPANY.LIST, '', '', '')

    LOOP
        REMOVE K.COMPANY FROM COMPANY.LIST SETTING COMP.MARK
    WHILE K.COMPANY:COMP.MARK

        IF K.COMPANY <> ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
        END

*-- Check whether product is installed


        GOSUB INITIALISE

        GOSUB WRITE.AC.CONV.ENTRY.TO.TRIGGER.CONVERSION

    REPEAT

*-- Restore back ID.COMPANY if it has changed.

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

*-----------------------------------------*
WRITE.AC.CONV.ENTRY.TO.TRIGGER.CONVERSION:
*----------------------------------------*

    AC.CONV.ENTRY.ID = "ECB.CONTRACT"
    READ R.AC.CONV.ENTRY FROM F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID THEN
        LOCATE 'AL'  IN R.AC.CONV.ENTRY<1> SETTING POSN ELSE
            INS 'AL' BEFORE R.AC.CONV.ENTRY<POSN>
        END
        WRITE R.AC.CONV.ENTRY ON F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID
    END ELSE
        WRITE 'AL' ON F.AC.CONV.ENTRY, AC.CONV.ENTRY.ID

    END

    RETURN
*----------------------------------------------------------------------------

 
