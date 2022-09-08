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
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.GET.PROPERTY.COND.RECORD
*
** Routine to return the proeprty record


    $USING EB.SystemTables
    $USING EB.Reports

*
    YFILE.NAME = "F.":EB.Reports.getOData()["_",1,1]
    EB.Reports.setId(EB.Reports.getOData()["_",2,1])
    YFILE = '':@FM:"NO.FATAL.ERROR"
    CALL OPF(YFILE.NAME,YFILE)
    tmp.ETEXT = EB.SystemTables.getEtext()
    IF NOT(tmp.ETEXT) THEN
        EB.SystemTables.setEtext(tmp.ETEXT)
        READ REC FROM YFILE, EB.Reports.getId() THEN
            CONVERT @FM TO ">" IN REC
        END
        EB.Reports.setOData(REC)
    END
    RETURN
*
    END
