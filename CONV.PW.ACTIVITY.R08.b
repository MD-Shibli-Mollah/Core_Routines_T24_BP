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
* <Rating>-2</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PW.Foundation
    SUBROUTINE CONV.PW.ACTIVITY.R08(PW.ACT.ID,R.PW.ACTIVITY,FILE)
*
******************************************************************************
* This routine will do the following
*  1. Populate the new field COMPLETE.STATUS with the value in STATUS.CODES fields
*     whose value in their respective COMPLETE field is 'YES'
*  2. Clear the values in COMPLETE field which is replaced by a single value field EVAL.RULE
*
******************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.PW.ACTIVITY
*------------------------------------------------------------------------------------------------------------------
*                   MODIFICATION LOG
*                   ----------------
*
* 25/04/07 - EN_10003336
*            Conversion routine for populating COMPLETE.STATUS field with STATUS.CODES which
*            has COMPLETE field set to 'YES'
*
*------------------------------------------------------------------------------------------------------------------
* populate COMPLETE.STATUS with STATUS.CODES having COMPLETE field set to 'YES'
* clear COMPLETE field which will be replaced by EVAL.RULE field

    SRULE.COUNT = COUNT(R.PW.ACTIVITY<7>,VM)+1
    FOR S.LOOP = 1 TO SRULE.COUNT
        IF R.PW.ACTIVITY<7,SRULE.COUNT> = "YES" THEN
            R.PW.ACTIVITY<8,-1> = R.PW.ACTIVITY<5,SRULE.COUNT>        ;* COMPLETE.STATUS populated with STATUS.CODES
        END
    NEXT S.LOOP
    R.PW.ACTIVITY<7> = ''     ;* Initialise EVAL.RULE

    RETURN
END
