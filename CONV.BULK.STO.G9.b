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

* Version 2 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-14</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.StandingOrders

    SUBROUTINE CONV.BULK.STO.G9(RECORD.ID, R.RECORD, FILE.NAME)
*-----------------------------------------------------------------------------
* Modifications:
* --------------
*
* 09/02/15 - Enhancement 1214535 / Task 1218721
*            Moved the routine from FT to AC. Also included the Package name
*
*----------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
** This is the standard record conversion routine
** The id and record selected in FILE.NAME is passed.
** At this point any new fields will have been added, any old
** fields will have been removed.
** FILE.NAME contains the full name.
** No write of the record is required as this is performed in
** the main routine.
*
** Add modifications here to exsiting record
** Do NOT use insert positions unless the conversion
** is run AFTER installing releases.
*
* Populate PAY.CCY with STO.CURRENCY
* Add currency to charge / commission amounts
*
    VMC = DCOUNT(R.RECORD<18>,VM)
    FOR INDX = 1 TO VMC
        R.RECORD<23,INDX> = R.RECORD<6>
        SMC = DCOUNT(R.RECORD<30,INDX>,SM)
        FOR IND2 = 1 TO SMC
            IF R.RECORD<31,INDX,IND2> THEN
                R.RECORD<31,INDX,IND2> = R.RECORD<6>:R.RECORD<31,INDX,IND2>
            END
        NEXT IND2
        SMC = DCOUNT(R.RECORD<33,INDX>,SM)
        FOR IND2 = 1 TO SMC
            IF R.RECORD<34,INDX,IND2> THEN
                R.RECORD<34,INDX,IND2> = R.RECORD<6>:R.RECORD<34,INDX,IND2>
            END
        NEXT IND2
    NEXT INDX
*
    RETURN
*
    END
