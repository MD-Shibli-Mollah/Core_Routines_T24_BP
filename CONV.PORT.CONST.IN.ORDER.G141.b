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
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctConstraints
    SUBROUTINE CONV.PORT.CONST.IN.ORDER.G141(SOO.ID , R.SOO , F.SEC.OPEN.ORDER)

* This conversion routine will change the PORT.CONST.NO field in Order to ID.COMPANY
*
* Modification History
*
* 08/11/06 - GLOBUS_CI_10045310
*            Routine to change the PORT.CONST.NO to ID.COMPANY
*
*------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE

    NO.OF.CUST = DCOUNT(R.SOO<10>, VM)
    I = 1
    LOOP
    WHILE I <= NO.OF.CUST
        IF R.SOO<42,I> = 'SYSTEM' THEN
            R.SOO<42,I> = ID.COMPANY
        END
        I += 1
    REPEAT

    RETURN
END
