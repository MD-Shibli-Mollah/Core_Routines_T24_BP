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
    $PACKAGE MD.Contract
    SUBROUTINE CONV.MD.DEAL.R13(RECORD.ID, MD.DEAL.REC, YFILE)
*** <region name= Modifications>
*** <desc> </desc>
*
* Modifications
*
* 31/01/13 - TASK : 560208
*            Conversion routine to populate following fields in MD.DEAL
*            a)PROV.NETTING
*            b)SG.ISSUED
*            c)MATURITY.DATE
*            REF : 291610
*
* 12/04/13 - TASK : 649841
*            Don't use inserts instead equate the positions.
*            REF : 649264
*
*** </region>
*----------------------------------------------------------------------------------
*** <region name= INSERTS>
*** <desc>Insert files </desc>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    EQU MD.DEA.PROV.NETTING TO 73
    EQU MD.DEA.LC.REFERENCE TO 126
    EQU MD.DEA.SG.ISSUED TO 150
    EQU MD.DEA.MATURITY.DATE TO 7
    EQU MD.DEA.ADVICE.EXPIRY.DATE TO 146

**** </region>
*----------------------------------------------------------------------------------
*** <region name= POPULATE FIELDS>
*** <desc>Populate the fields during conversion </desc>


    IF NOT(MD.DEAL.REC<MD.DEA.PROV.NETTING>) THEN
        MD.DEAL.REC<MD.DEA.PROV.NETTING> = "NO" ;*Populating provision netting as NO.
    END

    IF MD.DEAL.REC<MD.DEA.LC.REFERENCE> AND NOT(MD.DEAL.REC<MD.DEA.SG.ISSUED>) THEN
        MD.DEAL.REC<MD.DEA.SG.ISSUED> = "LC" ;*Populating "LC" in SG.ISSUED for existing shipping gtee contracts.
    END

    IF MD.DEAL.REC<MD.DEA.MATURITY.DATE> MATCHES '8N' THEN
        MD.DEAL.REC<MD.DEA.ADVICE.EXPIRY.DATE> = MD.DEAL.REC<MD.DEA.MATURITY.DATE> ;*Populate maturity date as advice expiry date.
    END
    RETURN
**** </region>
*----------------------------------------------------------------------------------
    END
