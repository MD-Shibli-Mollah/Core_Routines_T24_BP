* @ValidationCode : Mjo0MjEwMjE5NDE6Q3AxMjUyOjE1NDc3MjA3MTAwNzI6a2FqYWF5c2hlcmVlbjoyMDowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTgxMS4yMDE4MTAyMi0xNDA2OjM2OjM2
* @ValidationInfo : Timestamp         : 17 Jan 2019 15:55:10
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kajaayshereen
* @ValidationInfo : Nb tests success  : 20
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 36/36 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE LI.ModelBank
SUBROUTINE E.LI.ADJUST.AVAIL.AMT
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
    $USING LI.Config
    $USING EB.Reports
    $USING LI.ModelBank
*-----------------------------------------------------------------------------
    ENQ.SELECTION = EB.Reports.getEnqSelection()
    R.RECORD = EB.Reports.getRRecord()
    VM.COUNT = EB.Reports.getVmCount()
    VC = EB.Reports.getVc()

    ADJ.AVAIL.AMT = ''
    D.FIELDS = EB.Reports.getDFields()
    LOCATE "ADJUST.AVAIL.AMT" IN D.FIELDS<1> SETTING ADJ.POS THEN
        ADJ.AVAIL.AMT = EB.Reports.getDRangeAndValue()<ADJ.POS>
    END
    
    IF (VM.COUNT GT 1) AND (VC EQ 1) AND (ADJ.AVAIL.AMT[1,1] = "Y") THEN
    END ELSE
        RETURN
    END
    
    IF ENQ.SELECTION<1> = "LIAB" THEN
        LIMIT.AMT = R.RECORD<5>
        OS.AMT = R.RECORD<6>
        AVAIL.AMT = R.RECORD<7>
    END ELSE
        LIMIT.AMT = R.RECORD<LI.Config.Limit.OnlineLimit>
        OS.AMT = R.RECORD<LI.Config.Limit.TotalOs>
        AVAIL.AMT = R.RECORD<LI.Config.Limit.AvailAmt>
    END

    TB.COUNT = DCOUNT(LIMIT.AMT,@VM)
    FOR TB = 2 TO TB.COUNT-1
        AVAIL = LIMIT.AMT<1,TB> + OS.AMT<1,TB>
        IF (LIMIT.AMT<1,TB> + OS.AMT<1,TB>) LT 0 THEN
            AVAIL.AMT<1,TB> = LIMIT.AMT<1,TB> + OS.AMT<1,TB>
        END
    NEXT TB

    IF ENQ.SELECTION<1> = "LIAB" THEN
        R.RECORD<7> = AVAIL.AMT
    END ELSE
        R.RECORD<LI.Config.Limit.AvailAmt> = AVAIL.AMT
    END
    EB.Reports.setRRecord(R.RECORD)
RETURN
END
