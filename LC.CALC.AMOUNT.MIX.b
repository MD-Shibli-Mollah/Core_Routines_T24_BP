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

* Version 4 06/06/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>-76</Rating>
*-----------------------------------------------------------------------------

    $PACKAGE LC.Contract

    SUBROUTINE LC.CALC.AMOUNT.MIX(AMOUNT)

*------------------------------------------------------------------------
*
* 20/12/99 - GB9901566
*            Program is copy of LC.CALC.AMOUNT but populates static
*            fields in Mixed Portion Set.
*
* 28/02/00 - GB0000300
*            Adding Revolving Functionality. This change will cater the
*            ADD.COVERED.AMT inside MIXED payment set.
*
* 19/02/07 - BG_100013043
*            CODE.REVIEW changes.
*
* 01/04/10 - TASK:36267
*            LIAB.PORT.AMT amount gets updated wrongly.
*            REF : HD1009997/34903
*
* 23/04/10 - TASK : 43874
*            LIAB.PORT.AMT and UNCONF.LIAB.AMOUNT are updated wrongly while performing change on change.
*            REF : HD1011585 / 41169
*
* 16/06/10 - TASK : 59263
*            LIAB.PORT.AMT is updated wrongly while approving the LC.AMENDMENTS.
*            REF : 57506/HD1023436
*
* 12/04/10 - TASK:24915
*            ARC-IB in Import LC Issue.Changed to support the operation 'IO'.
*            ENHANCEMENT : 16211
*
* 07/03/11 - TASK : 167323
*            When charges are collected through operation "C", system updates
*            LIAB.PORT.AMT field with out considering the drawings amount.
*            REF : 166446
*
* 30/08/13 - 770431
*            When change the external reference alone system wrongly update
*            the LIAB.PORT.AMT, LCY.PORT.AMT, LC.AMOUNT.LOCAL and LC.ORIG.RATE
*            REF : 764417
*
* 21/10/13 - TASK : 814298
*            While increasing the LC.AMOUNT in a fully utilised LC contract,System
*            updates the fields LIAB.PORT.AMT, LCY.PORT.AMT, LIABILITY.AMT and
*            LC.AMOUNT.LOCAL with incorrect values.
*            REF : 809816
*
*
* 24/11/14- TASK : 1165602
*			 LC Componentization and Incorporation
*			 DEF : 990544
*
*------------------------------------------------------------------------
*

    $USING LC.Contract
    $USING EB.SystemTables

*
* When the operation equal 'C'(Direct charges) or 'T'(Trace collections)
* use the action code 'OPN' because no fields are allowed to be input
*
    ACTION.CODE = ''
    NEW.PERCENT = ''
*
    IF EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcOperation) MATCHES 'T':@VM:'C':@VM:'IO' THEN
        *When charges are collected through operation "C", system updates LIAB.PORT.AMT field with out considering the drawings amount.
        ACTION.CODE = 'AMD'
    END ELSE
        IF EB.SystemTables.getIdOld() EQ "" THEN  ;* New L/C
            BEGIN CASE
                CASE EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcOperation) EQ "O"
                    ACTION.CODE = "OPN"
                CASE EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcOperation) EQ "P"
                    ACTION.CODE = "PRE"
            END CASE
        END ELSE    ;* L/C Amendment
            BEGIN CASE
                CASE EB.SystemTables.getROld(LC.Contract.LetterOfCredit.TfLcOperation) EQ "P" AND EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcOperation) EQ "O"
                    ACTION.CODE = "OPN"
                CASE EB.SystemTables.getROld(LC.Contract.LetterOfCredit.TfLcOperation) EQ "P" AND EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcOperation) EQ "P"
                    ACTION.CODE = "PRE"
*****LIAB.PORT.AMT needs to be recalculate while approving the LC.AMENDMENTS by "D" operation.
                CASE EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcOperation) EQ "A" OR EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcOperation) EQ "D"
                    ACTION.CODE = "AMD"
            END CASE
        END
    END
    BEGIN CASE

        CASE ACTION.CODE EQ 'OPN' OR ACTION.CODE EQ 'PRE'
            GOSUB OPEN.LC

        CASE ACTION.CODE EQ 'AMD'
            GOSUB LC.AMEND

    END CASE

    RETURN
*********************************************************************
OPEN.LC:

    IF NOT(EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcPercentageCrAmt)) AND NOT(EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcPercentageDrAmt)) THEN
        AMOUNT = EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcPayPortion)<1,EB.SystemTables.getAv()>
    END ELSE

        PERCENTAGE = 0
        SIGN = 1

        IF EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcPercentageCrAmt) THEN
            PERCENTAGE = EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcPercentageCrAmt)
        END ELSE
            AMOUNT = EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcPayPortion)<1,EB.SystemTables.getAv()>
        END
        IF PERCENTAGE THEN
            AMOUNT = EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcPayPortion)<1,EB.SystemTables.getAv()>
            TEMP.AMOUNT = AMOUNT * PERCENTAGE
            TEMP.AMOUNT = TEMP.AMOUNT / 100
            AMOUNT += TEMP.AMOUNT
        END
    END
    !GB9901566+
    IF EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcAddCoveredAmt)<1,EB.SystemTables.getAv()> THEN
        AMOUNT += EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcAddCoveredAmt)<1,EB.SystemTables.getAv()>
    END
    !GB9901566-
    RETURN
*************************************************************************
*
LC.AMEND:
*
*  L/C is being amended
*
    AMOUNT = EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcPayPortion)<1,EB.SystemTables.getAv()> -  EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcDrawingAmt)<1,EB.SystemTables.getAv()> ;* The available amount is a difference of drawing amount and pay portion amount
    PORT.PCT=EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcPaymentPct)<1,EB.SystemTables.getAv()>
    YAMOUNT=''


    IF NOT(EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcPercentageCrAmt)) AND NOT(EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcPercentageDrAmt)) AND NOT(EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcAddCoveredAmt)<1,EB.SystemTables.getAv()>) THEN
        IF EB.SystemTables.getRNewLast(LC.Contract.LetterOfCredit.TfLcPayPortion)<1,EB.SystemTables.getAv()> THEN         ;*Any INAU record is present then take that amount from INAU record (LC.Contract.LetterOfCredit.TfLcPayPortion).
            AMOUNT = EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcPayPortion)<1,EB.SystemTables.getAv()> -  EB.SystemTables.getRNewLast(LC.Contract.LetterOfCredit.TfLcPayPortion)<1,EB.SystemTables.getAv()>
        END ELSE
            AMOUNT = EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcPayPortion)<1,EB.SystemTables.getAv()> - EB.SystemTables.getROld(LC.Contract.LetterOfCredit.TfLcPayPortion)<1,EB.SystemTables.getAv()>
        END
        IF AMOUNT <= 0 THEN
            AMOUNT = EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcPayPortion)<1,EB.SystemTables.getAv()> - EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcDrawingAmt)<1,EB.SystemTables.getAv()>
            RETURN
        END
    END

    IF EB.SystemTables.getRNewLast(LC.Contract.LetterOfCredit.TfLcOperation) NE '' THEN
        OLD.AMOUNT = EB.SystemTables.getRNewLast(LC.Contract.LetterOfCredit.TfLcPayPortion)<1,EB.SystemTables.getAv()> -  EB.SystemTables.getRNewLast(LC.Contract.LetterOfCredit.TfLcDrawingAmt)<1,EB.SystemTables.getAv()> ;* INAU change on available amount
        IF EB.SystemTables.getRNewLast(LC.Contract.LetterOfCredit.TfLcPercentageCrAmt) THEN
            OLD.PERCENT = EB.SystemTables.getRNewLast(LC.Contract.LetterOfCredit.TfLcPercentageCrAmt)
        END ;*Don't consider the PERCENTAGE.DR.AMT while amending.
    END ELSE
        OLD.AMOUNT = EB.SystemTables.getROld(LC.Contract.LetterOfCredit.TfLcPayPortion)<1,EB.SystemTables.getAv()> -  EB.SystemTables.getROld(LC.Contract.LetterOfCredit.TfLcDrawingAmt)<1,EB.SystemTables.getAv()> ;* Old available amount
        IF EB.SystemTables.getROld(LC.Contract.LetterOfCredit.TfLcPercentageCrAmt) THEN
            OLD.PERCENT = EB.SystemTables.getROld(LC.Contract.LetterOfCredit.TfLcPercentageCrAmt)
        END ;*Don't consider the PERCENTAGE.DR.AMT while amending.
    END

    NEW.AMOUNT = EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcPayPortion)<1,EB.SystemTables.getAv()> - EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcDrawingAmt)<1,EB.SystemTables.getAv()>  ;* New available amount
    NEW.SIGN = 1
    IF EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcPercentageCrAmt) THEN
        NEW.PERCENT = EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcPercentageCrAmt)
    END ;*Don't consider the PERCENTAGE.DR.AMT while amending.
    YAMOUNT = EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcAddCoveredAmt)<1,EB.SystemTables.getAv()>
    IF NEW.PERCENT THEN ;*If PERCENTAGE present then calculate the amount always.
        TEMP.AMOUNT = EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcPayPortion)<1,EB.SystemTables.getAv()>
        TEMP.AMOUNT += (TEMP.AMOUNT * NEW.PERCENT) / 100 ;* Find the percentage of tolerance
        AMOUNT = TEMP.AMOUNT - EB.SystemTables.getRNew(LC.Contract.LetterOfCredit.TfLcDrawingAmt)<1,EB.SystemTables.getAv()> ;* Remove the tolerance from the pay portion amount
    END ELSE
        IF OLD.AMOUNT NE NEW.AMOUNT THEN
            AMOUNT = NEW.AMOUNT ;*New.amount holds the difference of pay portion amount and drawings amount.
        END
    END
    AMOUNT += YAMOUNT
    RETURN
*************************************************************************
*
    END
