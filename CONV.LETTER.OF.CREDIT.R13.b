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

* Version n dd/mm/yy  GLOBUS Release No. R13 08/03/12
*-------------------------------------------------------------------------
* <Rating>-5</Rating>
*-------------------------------------------------------------------------
    $PACKAGE LC.Contract
    SUBROUTINE CONV.LETTER.OF.CREDIT.R13(LC.ID,R.LC.RECORD,YFILE)
*** <region name= Modifications>
*** <desc> </desc>
*
* Modifications
*
* 31/01/13 - TASK : 560208
*            Conversion routine to populate following fields in LETTER.OF.CREDIT
*            a)PROV.CALC.BASE
*            b)AUTO.EXPIRY
*            c)SEND.MT740
*
*            REF : 291610
*
* 13/04/13 - TASK : 649481
*            Don't use inserts instead equate the positions.
*            REF : 649264
*
*
*** </region>
*-------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc> </desc>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    EQU TF.LC.PROVISION TO 143
    EQU TF.LC.PROV.CALC.BASE TO 262
    EQU TF.LC.AUTO.EXPIRY TO 263
    EQU TF.LC.ADVISING.BK.CUSTNO TO 15
    EQU TF.LC.ADVISING.BK TO 16
    EQU TF.LC.THIRD.PARTY.CUSTNO TO 44
    EQU TF.LC.THIRD.PARTY TO 45
    EQU TF.LC.SEND.MT740 TO 264


*** </region>
*---------------------------------------------------------------------------
*** <region name= Populate fields>
*** <desc>Populate the fields during conversion </desc>

    IF R.LC.RECORD<TF.LC.PROVISION> EQ 'Y' AND NOT(R.LC.RECORD<TF.LC.PROV.CALC.BASE>) THEN
        R.LC.RECORD<TF.LC.PROV.CALC.BASE> = 'LIABILITY.AMT' ;*Populating the provision calc base as LIABILITY amount for the existing contracts.
    END

    R.LC.RECORD<TF.LC.AUTO.EXPIRY> = 'YES'    ;*Populating auto expiry as YES for existing contracts.

    IF (R.LC.RECORD<TF.LC.ADVISING.BK.CUSTNO> OR R.LC.RECORD<TF.LC.ADVISING.BK>) AND (R.LC.RECORD<TF.LC.THIRD.PARTY.CUSTNO> OR R.LC.RECORD<TF.LC.THIRD.PARTY>) THEN
        R.LC.RECORD<TF.LC.SEND.MT740> = 'YES' ;*Populate SEND.MT740 only for import LC's with third party customer.
    END

    RETURN
*** </region>
*------------------------------------------------------------------------------------------------------------------------------------
    END
