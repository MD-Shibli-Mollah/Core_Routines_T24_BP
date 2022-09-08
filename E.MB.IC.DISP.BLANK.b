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
* <Rating>-27</Rating>
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
    $PACKAGE IC.ModelBank
    SUBROUTINE E.MB.IC.DISP.BLANK
*-----------------------------------------------------------------------------
* This conversion routine is used to replace '0.00000' value with blank value
*-----------------------------------------------------------------------------
* Modification History:
*
* 15/09/08-BG_100019949
*          Routine restructured
*
* 16/08/10 - Defect 76624 / Task 77564
*            Changes done to display full amount under "Rate Cr" head.
*
* 17/03/11 - Defect 171851 / Task 173886
*             system is showing the wrong spread interest rate value in ACC.CURRENT.INT enquiry.
*-----------------------------------------------------------------------------

    $USING EB.Reports
    $USING IC.ModelBank

    GOSUB INITIALISE

    RETURN

***********
INITIALISE:
***********

    IF EB.Reports.getOData()[1,1] MATCHES "*":@VM:"+":@VM:"-" THEN
        FIELD.VAL = EB.Reports.getOData()[2,99]
        FIELD.OPER = EB.Reports.getOData()[1,1]
    END ELSE
        FIELD.VAL = EB.Reports.getOData()
        FIELD.OPER = ''
    END


    IF FIELD.VAL EQ '' THEN
        EB.Reports.setOData('')
        RETURN
    END ELSE
        GOSUB PROCESS
    END
    RETURN

********
PROCESS:
********

    IF FIELD.VAL EQ '0.00000' THEN
        EB.Reports.setOData(" ")
    END ELSE
        IF (FIELD.OPER EQ '*') OR (FIELD.OPER EQ '-') OR (FIELD.OPER EQ '+') THEN

            IF (FIELD.VAL EQ '*') OR (FIELD.VAL EQ '+') OR (FIELD.VAL EQ '-') THEN
                EB.Reports.setOData('')
            END ELSE
                FIELD.VAL = FMT(FIELD.VAL, "L6%8")
                EB.Reports.setOData(FIELD.OPER:FIELD.VAL)
            END

        END ELSE
            EB.Reports.setOData(FMT(EB.Reports.getOData(), "L6%9"))
        END

    END

    RETURN
