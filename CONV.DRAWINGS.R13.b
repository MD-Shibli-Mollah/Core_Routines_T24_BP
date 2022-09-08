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
* <Rating>-41</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.Contract
    SUBROUTINE CONV.DRAWINGS.R13(DRAW.ID,R.DR.REC,YFILE)
*** <region name= Modifications>
*** <desc> </desc>
*
* Modifications
*
* 31/01/13 - TASK : 560208
*            Conversion routine to populate following fields in DRAWINGS
*            a)PROV.NETTING
*            b)AUTO.EXPIRY
*            REF : 291610
*
* 12/04/13 - TASK : 649481
*            Don't use inserts instead equate the positions.
*            REF : 649264
*
* 19/11/13 - TASK : 836010
*            Insert I_F.LC.TYPES to avoid wrong updation in AUTO.EXPIRY.
*            REF : 839397
*** </region>
*-------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc> </desc>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.LC.TYPES
    EQU TF.LC.CONFIRM.INST TO 62
    EQU TF.LC.CONFIRMATION.AMT TO 202
    EQU TF.DR.LC.CREDIT.TYPE TO 101
    EQU TF.DR.PROV.NETTING TO 220
    EQU TF.DR.AUTO.EXPIRY TO 222
    EQU TF.DR.DISCOUNT.AMT TO 14
    EQU TF.DR.DRAWING.TYPE TO 1
*
*** </region>
*---------------------------------------------------------------------------
*** <region name= Populate fields>
*** <desc>Populate the fields during conversion </desc>

    GOSUB INITIALIZE
    GOSUB POPULATE.DR.FIELDS
    RETURN
*** </region>
*---------------------------------------------------------------------------
*** <region name= POPULATE.DR.FIELDS>
*** <desc> </desc>
*==================
POPULATE.DR.FIELDS:
*==================

    IF NOT(R.DR.REC<TF.DR.PROV.NETTING>) THEN
        R.DR.REC<TF.DR.PROV.NETTING> = "NO" ;*Netting as No.
    END

    BEGIN CASE
        CASE R.DR.REC<TF.DR.DRAWING.TYPE> MATCHES 'MA':VM:'MD'
            R.DR.REC<TF.DR.AUTO.EXPIRY> = 'YES'

        CASE R.DR.REC<TF.DR.DRAWING.TYPE> MATCHES 'AC':VM:'DP'
            GOSUB POPULATE.AUTO.EXPIRY
    END CASE

    RETURN
*** </region>
*---------------------------------------------------------------------------
*** <region name= INITIALIZE>
*** <desc> </desc>
*==========
INITIALIZE:
*==========

    IMPORT = ''
    LC.RECORD = ''
    YERR = ''
    F.LC = ''
    FN.LC = 'F.LETTER.OF.CREDIT'
    CALL OPF(FN.LC, F.LC)
    LC.ID = DRAW.ID[1,12]

    RETURN
*** </region>
*---------------------------------------------------------------------------
*** <region name= POPULATE.AUTO.EXPIRY>
*** <desc> </desc>
*====================
POPULATE.AUTO.EXPIRY:
*====================

    CALL F.READ(FN.LC, LC.ID, LC.RECORD , F.LC, YERR)

    CALL DBR("LC.TYPES":FM:LC.TYP.IMPORT.EXPORT,R.DR.REC<TF.DR.LC.CREDIT.TYPE>,IMPORT)

    IF IMPORT NE 'I' THEN
        BEGIN CASE

            CASE R.DR.REC<TF.DR.DISCOUNT.AMT> GT 0
                R.DR.REC<TF.DR.AUTO.EXPIRY> = 'YES' ;*Discounted drawings

            CASE LC.RECORD<TF.LC.CONFIRM.INST>[1,1] EQ 'C' AND LC.RECORD<TF.LC.CONFIRMATION.AMT> EQ ''
                R.DR.REC<TF.DR.AUTO.EXPIRY> = 'YES' ;*Confirmed drawings.

            CASE OTHERWISE
                R.DR.REC<TF.DR.AUTO.EXPIRY> = 'NO' ;*Default - Export
        END CASE
    END ELSE
        R.DR.REC<TF.DR.AUTO.EXPIRY> = 'YES' ;*Default Yes for Import LC's.
    END
    RETURN

*** </region>
*---------------------------------------------------------------------------
    END
