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

* Version 8 15/05/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>13</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PM.Reports
    SUBROUTINE E.PM.NOS.OPEN.BAL
*-----------------------------------------------------------------------------

    $USING ST.CompanyCreation
    $USING PM.Config
    $USING EB.DataAccess
    $USING EB.API
    $USING ST.CurrencyConfig
    $USING PM.Reports
    $USING EB.SystemTables
    $USING EB.Reports

* 14/10/96 - GB9601433
*            Allow for an opening date of zero
*
* 13/08/97 - GB9700938
*            fFormat to number of decimals and do not adjust
*            open balance. Format to 19 digits not 12
*
* 08/11/13 - Defect 825069 Task  830994
*            When PM.NOS enquiry is drill down ‘Currency’ did not appear
*
* 26/10/15 - EN_1226121 / Task 1511358
*	      	 Routine incorporated
*

*
** Open PM.ENQ.PARAM file
*
    F.PM.ENQ.PARAM = ""
    EB.DataAccess.Opf("F.PM.ENQ.PARAM",F.PM.ENQ.PARAM)

*
** Read the enquiry parameter for PM.NOS
*
    PM.ENQ.PARAM.ID = "PM.NOS"
    READ.ERR = ""
    R.PM.ENQ.PARAM = PM.Reports.EnqParam.Read(PM.ENQ.PARAM.ID, READ.ERR)

    IF READ.ERR THEN
        R.PM.ENQ.PARAM = ""
    END

*
* Extract positive and negative indicators from the Parameter file
*
    Y = 0
    SIGN = ''
    FOR X = PM.Reports.EnqParam.EnqTakSign TO PM.Reports.EnqParam.EnqDifPlacSign
        Y+= 1
        BEGIN CASE
            CASE R.PM.ENQ.PARAM<X> = 'BRACKETS'
                SIGN<Y,1> = '('
                SIGN<Y,2> = ')'
            CASE R.PM.ENQ.PARAM<X> = 'MINUS'
                SIGN<Y,1> = '-'
                SIGN<Y,2> = SPACE(1)
            CASE R.PM.ENQ.PARAM<X> = 'PLUS'
                SIGN<Y,1> = '+'
                SIGN<Y,2> = SPACE(1)
            CASE 1
                SIGN<Y,1> = SPACE(1)
                SIGN<Y,2> = SPACE(1)
        END CASE
    NEXT X
*
    PM.DPC.FILE = "F.PM.DLY.POSN.CLASS"
    F.PM.DPC = ""
    EB.DataAccess.Opf(PM.DPC.FILE, F.PM.DPC)

* Add the current ID back onto ENQ.KEYS
	TEMP.ENQ.KEYS = EB.Reports.getEnqKeys()
    INS EB.Reports.getId() BEFORE TEMP.ENQ.KEYS<1>
    EB.Reports.setEnqKeys(TEMP.ENQ.KEYS)

* Look through ENQ.KEYS for an AC... posn type

    OPEN.BAL = 0

    XX = 1
    LOOP
        *
        * GB9600737
        *
        DP.ID = EB.Reports.getEnqKeys()<XX>
        DPC.ID = FIELD(DP.ID,'*',1)
        MNE = FIELD(DP.ID,'*',2)
        *
        * GB9600737
        *
        DPC.DATE = FIELD(DPC.ID, ".", 6)
    UNTIL DPC.ID = ""
        DPC.CURRENCY = FIELD(DPC.ID,".",5)
        IF DPC.ID[1,2] = "AC" AND DPC.DATE MATCHES EB.SystemTables.getToday():@VM:"1" THEN  ; * May be 1 for opening
            GOSUB READ.DPC.REC
            GOSUB GET.OPENING.BAL
            TEMP.ENQ.KEYS = EB.Reports.getEnqKeys()
            DEL TEMP.ENQ.KEYS<XX>
            EB.Reports.setEnqKeys(TEMP.ENQ.KEYS)
        END ELSE
            XX += 1
        END
    REPEAT

    OPEN.FBAL = OPEN.BAL
    ROUND.TYPE = 1
    EB.API.RoundAmount(DPC.CURRENCY, OPEN.FBAL, ROUND.TYPE, "")
* GB9700938
    CCY = DPC.CURRENCY
    CCY.DECIMALS = "NO.OF.DECIMALS"
    ST.CurrencyConfig.UpdCcy(CCY,CCY.DECIMALS)
*

    IF R.PM.ENQ.PARAM THEN
        IF OPEN.FBAL < 0 THEN
            OPEN.FBAL = OPEN.FBAL * -1
            OPEN.FBAL = FMT(SIGN<3,1>:FMT(OPEN.FBAL,'R':CCY.DECIMALS:','),'R#19'):SIGN<3,2>
        END ELSE
            OPEN.FBAL = FMT(SIGN<4,1>:FMT(OPEN.FBAL,'R':CCY.DECIMALS:','),'R#19'):SIGN<4,2>
        END
    END ELSE
        IF OPEN.FBAL < 0 THEN
            OPEN.FBAL = OPEN.FBAL * -1
            OPEN.FBAL = FMT("-":FMT(OPEN.FBAL,'R':CCY.DECIMALS:','),'R#19'):" "
        END ELSE
            OPEN.FBAL = FMT("+":FMT(OPEN.FBAL,'R':CCY.DECIMALS:','),'R#19'):" "
        END
    END

    EB.Reports.setOData(OPEN.BAL:">":OPEN.FBAL)

* ENQ.KEYS becomes null when it holds only one record(AC position classes)
* Proper resetting ID, ENQ.KEYS and R.RECORD

    IF EB.Reports.getEnqKeys()<1> NE '' THEN
        EB.Reports.setId(EB.Reports.getEnqKeys()<1>)
        TEMP.ENQ.KEYS = EB.Reports.getEnqKeys()
        DEL TEMP.ENQ.KEYS<1>
        EB.Reports.setEnqKeys(TEMP.ENQ.KEYS)
    END
    DPC.ID = EB.Reports.getId()
    GOSUB READ.DPC.REC
    EB.Reports.setRRecord(DPC.REC)


    RETURN


*************************************************************************
*                          INTERNAL ROUTINES
*************************************************************************

READ.DPC.REC:
*============
*
* GB9600737
*
    IF MNE = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComMnemonic) THEN
        ER = ""
        DPC.REC = PM.Config.DlyPosnClass.Read(DPC.ID, ER)
        IF ER THEN
            DPC.REC = ""
        END
    END ELSE
        *
        * For the secondary companies open the file with the menmonic set
        *
        PM.CO2.DPC.FILE = "F":MNE:".PM.DLY.POSN.CLASS"
        FCO2.PM.DPC = ""
        EB.DataAccess.Opf(PM.CO2.DPC.FILE, FCO2.PM.DPC)
        ER1 = ""
        EB.DataAccess.FRead(PM.CO2.DPC.FILE, DPC.ID, DPC.REC, FCO2.PM.DPC, ER1)
        IF ER1 THEN
            DPC.REC = ""
        END
    END
*
* GB9600737
*

    RETURN


GET.OPENING.BAL:
*===============

    VM.POS = 0
    NO.VMS = DCOUNT(DPC.REC<PM.Config.DlyPosnClass.DpcAsstLiabCd>, @VM)
    LOOP
        VM.POS += 1
        ASST.OR.LIAB = DPC.REC<PM.Config.DlyPosnClass.DpcAsstLiabCd, VM.POS>
        AMT.STR = DPC.REC<PM.Config.DlyPosnClass.DpcAmtCode, VM.POS>
        LOCATE "1" IN AMT.STR<1,1,1> SETTING YY THEN
        IF ASST.OR.LIAB = 2 THEN
            OPEN.BAL -= DPC.REC<PM.Config.DlyPosnClass.DpcAmount, VM.POS, YY>
        END ELSE
            OPEN.BAL += DPC.REC<PM.Config.DlyPosnClass.DpcAmount, VM.POS, YY>
        END
    END
    UNTIL VM.POS = NO.VMS
    REPEAT

    RETURN


******
    END
