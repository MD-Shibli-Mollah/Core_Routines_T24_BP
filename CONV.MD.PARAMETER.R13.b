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
* <Rating>-5</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE MD.Config
    SUBROUTINE CONV.MD.PARAMETER.R13(MD.PARAM.ID, MD.PARAM.REC, YFILE)
*** <region name= Modifications>
*** <desc> </desc>
*
* Modifications
*
* 31/01/13 - TASK : 560208
*            Conversion routine to populate following fields in MD.PARAMETERS
*            a)CSN.PERIOD
*            b)PROV.NETTING
*            c)REDUCE.LC.LIAB
*            REF : 291610
*
* 12/04/13 - TASK : 649481
*            Don't use inserts instead equate the positions.
*            REF : 649264
*
*** </region>
*----------------------------------------------------------------------------------
*** <region name= INSERTS>
*** <desc>Insert files </desc>

    $INSERT I_COMMON
    $INSERT I_EQUATE
    EQU MD.PAR.PROV.NETTING TO 38
    EQU MD.PAR.CSN.PERIOD TO 41
    EQU MD.PAR.REDUCE.LC.LIAB TO 39


**** </region>
*----------------------------------------------------------------------------------
*** <region name= POPULATE FIELDS>
*** <desc>Populate the fields during conversion </desc>
    IF NOT(MD.PARAM.REC<MD.PAR.PROV.NETTING>) THEN
        MD.PARAM.REC<MD.PAR.PROV.NETTING> = "NO" ;*Populate the PROV.NETTING with NO if not inputted,
    END

    IF NOT(MD.PARAM.REC<MD.PAR.CSN.PERIOD>) THEN
        MD.PARAM.REC<MD.PAR.CSN.PERIOD> = "MATURITY DATE" ;*To retain the existing functionality in commission calculation  the value "MATURITY DATE" needs to populte in CSN.PERIOD.
    END

    IF NOT(MD.PARAM.REC<MD.PAR.REDUCE.LC.LIAB>) THEN
        MD.PARAM.REC<MD.PAR.REDUCE.LC.LIAB> = 'NO' ;*Populating the reduce liab as NO to stop the creation of drawings automatically while authorising MD.
    END

    RETURN
**** </region>
*----------------------------------------------------------------------------------
    END
