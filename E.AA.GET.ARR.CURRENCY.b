* @ValidationCode : MjotNDQwNzcxMTg6Q3AxMjUyOjE1NDUyMjUxMjcxODQ6cm9uZGxhdmVua2F0cmFtOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTIuMjAxODExMjMtMTMxOToxNjoxNA==
* @ValidationInfo : Timestamp         : 19 Dec 2018 18:42:07
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rondlavenkatram
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 14/16 (87.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201812.20181123-1319
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-2</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.ARR.CURRENCY
**************************************
*MODIFICATION HISTORY
*
* 05/01/09 - BG_100021512
*            Arguments changed for SIM.READ.
*
* 15/12/18 - Task : 2904819
*            Def  : 2893147
*            Simulation is displaying the schedule projection without decimal even if  foreign currency is configured with 2 decimal places.As SimRef is not fectched it displays with local currency decimals
**************************************

    $USING EB.Reports
    $USING AA.Framework
    $USING EB.DatInterface

**************************************
    ARR.ID = EB.Reports.getOData()
    R.ARR = ''
    RET.ERR = ''
    SIM.REF = EB.Reports.getEnqSimRef()
    IF SIM.REF ELSE  ;*If simRef is not found it should be fectched from the enquiry selection table
        LOCATE "SIM.REF" IN EB.Reports.getEnqSelection()<2,1> SETTING SIM.POS THEN
            SIM.REF = EB.Reports.getEnqSelection()<4,SIM.POS>
        END
    END
    IF SIM.REF THEN
        EB.DatInterface.SimRead(SIM.REF, "F.AA.ARRANGEMENT", ARR.ID, R.ARR, "", "", RET.ERR)
    END ELSE
        AA.Framework.GetArrangement(ARR.ID, R.ARR, RET.ERR)
    END
    EB.Reports.setOData(R.ARR<AA.Framework.Arrangement.ArrCurrency>)
*
RETURN
***************************************
