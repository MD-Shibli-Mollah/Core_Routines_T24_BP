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

* Version 6 27/02/01  GLOBUS Release No. G11.2.00 28/03/01
*-----------------------------------------------------------------------------
* <Rating>83</Rating>
    $PACKAGE DE.Reports
    SUBROUTINE E.DISP.DE.O.MSG
*
    $USING DE.Config
    $USING DE.Reports
    $USING EB.Reports

*
*
* 21/02/07 - BG_100013037
*            CODE.REVIEW changes.
*
*07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*
*******************************************************************************************

    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)
    YKEY = EB.Reports.getOData()
    PAGE.NO = FIELD(YKEY,".",3)
    COPY.NO = FIELD(YKEY,".",2)
    EB.Reports.setRRecord("")
*
NEXT.PAGE:
    YREC = ""
    YREC = DE.Config.OHistory.Read(YKEY, ER)
    IF YREC THEN
        CONVERT @FM TO @VM IN YREC
        CONVERT CHARX(010) TO @VM IN YREC
        CONVERT CHARX(013) TO "" IN YREC
        YREC = TRIMBS(YREC)
        IF EB.Reports.getRRecord() THEN
            EB.Reports.setRRecord(@VM:YREC<1>)
        END ELSE
            EB.Reports.setRRecord(YREC)
        END
        IF PAGE.NO THEN
            tmp.O.DATA = EB.Reports.getOData()
            PAGE.NO += 1 ; YKEY = FIELD(tmp.O.DATA,".",1,2):".":PAGE.NO
            GOTO NEXT.PAGE
        END
    END ELSE        ;* End or missing
        tmp.R.RECORD = EB.Reports.getRRecord()
        IF NOT(tmp.R.RECORD) THEN
            EB.Reports.setRRecord("Record missing");* BG_100013037 - S
        END         ;* BG_100013037 - E
    END
*
    EB.Reports.setVmCount(COUNT(EB.Reports.getRRecord()<1>,@VM)+(EB.Reports.getRRecord()<1> NE ""))
    YKEY2 = FIELD(YKEY,".",1)
    YREC = DE.Config.OHeaderArch.Read(YKEY2, ER)
    IF YREC THEN
        FOR XX = DE.Config.OHeader.HdrCarrierAddressNo TO DE.Config.OHeader.HdrBankDate
            YREC<XX> = YREC<XX,COPY.NO>
        NEXT XX
        R.REC.TEMP = EB.Reports.getRRecord()
        R.REC.TEMP := @FM:YREC
        EB.Reports.setRRecord(R.REC.TEMP)
    END ELSE
        NULL        ;* BG_100013037 - S
    END   ;* BG_100013037 - E
*
    RETURN
    END
