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
* <Rating>-4</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.Config
    SUBROUTINE CONV.LC.PARAMETERS.R13(LC.PARAM.ID,R.PARAM.REC,YFILE)
*** <region name= Modifications>
*** <desc> </desc>
*
* Modifications
*
* 31/01/13 - TASK : 560208
*            Conversion routine to populate following fields in LC.PARAMETERS
*            a)PROV.CALC.BASE
*            b)PROV.NETTING
*            REF : 291610
*
* 13/04/13 - TASK : 649481
*            Don't use inserts instead equate the positions.
*            REF : 649264
*
*
*** </region>
*----------------------------------------------------------------------------------
*** <region name= INSERTS>
*** <desc>Insert files </desc>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    EQU LC.PARA.PROV.CALC.BASE TO 88
    EQU LC.PARA.PROV.NETTING TO 89
*** </region>
*----------------------------------------------------------------------------------
*** <region name= POPULATE FIELDS>
*** <desc>Populate the fields during conversion </desc>

    IF NOT(R.PARAM.REC<LC.PARA.PROV.CALC.BASE>) THEN
        R.PARAM.REC<LC.PARA.PROV.CALC.BASE> = 'LIABILITY.AMT' ;*Populating the provision calc base as LIABILITY amount for the existing contracts.
    END

    IF NOT(R.PARAM.REC<LC.PARA.PROV.NETTING>) THEN
        R.PARAM.REC<LC.PARA.PROV.NETTING> = "NO" ;*Populate NO in provision netting field if not inputted.
    END

    RETURN

*** </region>
********************************************************************************
    END
