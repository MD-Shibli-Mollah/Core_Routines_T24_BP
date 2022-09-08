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

* Version 5 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>-22</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FX.ModelBank
    SUBROUTINE E.POSITION.SIGN
*
** This subroutine will change the sign of positions according to
** the definition of LONG.POS.SIGN in the enquiry selection
** This may be PLUS or MINUS, the default is PLUS. Positions are
*

    $USING AC.CurrencyPosition
    $USING EB.Reports
    $USING FX.ModelBank
*
***************************************************************************
*
* CHANGE CONTROL
* ------ -------
*
* 10/12/97 - GB9701430
*            Changes to the insert file I.F.POSITION prefix requires
*            changes to any reference of fields from there in this
*            program.
*
* 24/12/97 - GB9701430
*            The file FX.TRANSACTION has been changed to POS.TRANSACTION
*            Since this program uses the file it must be changed to use
*            the new file.
*
* 10/4/2000- GB0000729
*            jBASE does not accept a LOCATE function with dynamic array
*            as its variable, in a LOCATE statement. So store the dynamic
*            array in a variable and use the variable in the CONVERT
*            function.
*
* 06/02/09 - CI_10060465
*            E.POSITION.SIGN routine is taken back from OB as
*            FX.BY.DATE enquiry's results are wrong (i.e signs changed)
*
* 15/09/15 - EN_1226121 / Task 1477143
*	      	 Routine incorporated
*
***************************************************************************
*
    LOCATE "LONG.POS.SIGN" IN EB.Reports.getEnqSelection()<2,1> SETTING SG.POS THEN
    LONG.SIGN = EB.Reports.getEnqSelection()<4,SG.POS>
    END ELSE
***** START ** GB0000729
    ENQ.FIX.SEL = ''
    ENQ.FIX.SEL = EB.Reports.getREnq()<EB.Reports.Enquiry.EnqFixedSelection>
    LOCATE "LONG.POS.SIGN" IN CONVERT(" ", @FM,ENQ.FIX.SEL)<1,1> SETTING SG.POS THEN
***** END ** GB0000729
    LONG.SIGN = EB.Reports.getREnq()<EB.Reports.Enquiry.EnqFixedSelection, SG.POS>[" ",3,1]
    END ELSE
    LONG.SIGN = "PLUS"
    END
    END
*
    IF LONG.SIGN NE "PLUS" THEN
        SIGN = 1
    END ELSE
        SIGN = -1   ;* Opposite of POSITION fiel
    END
*
    BEGIN CASE
            *
        CASE EB.Reports.getDataFileName() = "POSITION"
            FOR IND = AC.CurrencyPosition.Position.CcyPosAmountOne TO AC.CurrencyPosition.Position.CcyPosLcyAmount
                tmp=EB.Reports.getRRecord(); tmp<IND>=MULS(EB.Reports.getRRecord()<IND>, REUSE(SIGN)); EB.Reports.setRRecord(tmp)
            NEXT IND
            *
        CASE EB.Reports.getDataFileName() = "POS.TRANSACTION"
            FOR IND = AC.CurrencyPosition.PosTransaction.PosTxnAmountOne TO AC.CurrencyPosition.PosTransaction.PosTxnLcyAmountTwo
                tmp=EB.Reports.getRRecord(); tmp<IND>=MULS(EB.Reports.getRRecord()<IND>, REUSE(SIGN)); EB.Reports.setRRecord(tmp)
            NEXT IND
            FOR IND = AC.CurrencyPosition.PosTransaction.PosTxnOldAmountOne TO AC.CurrencyPosition.PosTransaction.PosTxnOldLcyAmountTwo
                tmp=EB.Reports.getRRecord(); tmp<IND>=MULS(EB.Reports.getRRecord()<IND>, REUSE(SIGN)); EB.Reports.setRRecord(tmp)
            NEXT IND
            *
        CASE 1
            *
    END CASE
*
    END
