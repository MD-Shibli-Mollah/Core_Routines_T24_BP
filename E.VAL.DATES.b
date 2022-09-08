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

* Version 3 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>-5</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.VAL.DATES
*-----------------------------------------------------------------------------
*
** This routine will enrich and validate dates entered in ENQUIRY.SELECT
** and should be added to the STANDARD.SELECTION record for the file
** being selected
*
*-----------------------------------------------------------------------------
*
* 07/05/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.Utility

    IF EB.SystemTables.getComi()[1,6] NE "!TODAY" THEN
        SAVE.COMI = EB.SystemTables.getComi()
        EB.SystemTables.setComi(EB.Reports.getOData())
        EB.Utility.InTwod("11", "D")
        IF EB.SystemTables.getEtext() THEN
            EB.SystemTables.setE(EB.SystemTables.getEtext())
        END ELSE
            EB.Reports.setOData(EB.SystemTables.getComi())
        END
        EB.SystemTables.setComi(SAVE.COMI)
    END
*
    RETURN
*-----------------------------------------------------------------------------
    END
