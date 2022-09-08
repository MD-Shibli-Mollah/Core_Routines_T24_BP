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
* <Rating>-21</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.MB.SUM.LOCKED.AMOUNT
*-----------------------------------------------------------------------------

* Routine to get the sum of LOCKED.AMOUNT in ACCOUNT application
*-----------------------------------------------------------------------------

    $USING EB.Reports

    GOSUB INITIALISE
    GOSUB PROCESS
    EB.Reports.setOData(LOCKED.AMT)
    RETURN

INITIALISE:
    LOCKED.AMT = 0
    NO.OF.LOCKED.AMT = DCOUNT(EB.Reports.getOData(),@VM)
    RETURN

PROCESS:

    FOR I = 1 TO  NO.OF.LOCKED.AMT
        LOCKED.AMT += EB.Reports.getOData()<1,I>
    NEXT I

    RETURN
*-----------------------------------------------------------------------------
    END
