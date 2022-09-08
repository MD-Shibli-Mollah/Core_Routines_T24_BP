* @ValidationCode : MjotNzgyNTE2MTYyOkNwMTI1MjoxNjE0MzIyNDc4OTUxOnN2YW1zaWtyaXNobmE6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAxMS4yMDIwMTAyOS0xNzU0OjE2OjEy
* @ValidationInfo : Timestamp         : 26 Feb 2021 12:24:38
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : svamsikrishna
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 12/16 (75.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202011.20201029-1754
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE QI.Reporting
SUBROUTINE QI.GET.OWNING.PERCNT(CONTRACT.ID, USDB.REC, RES.IN1, RES.IN2, OWNING.PERCNT, ERROR.INFO, RES.OUT.1, RES.OUT.2)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 18/02/2021   - Enhancement 4240598  / Task 4240601
*            API to get an Owning percentage from ST.TAX.REPORT.DETAILS for a respective customer
*-----------------------------------------------------------------------------
    $USING QI.Reporting
    $USING CG.ChargeConfig
    $USING EB.SystemTables
    $USING QI.Config

    TAX.REP.ERR = ""
    IF CONTRACT.ID[1,6] EQ "SCADTX" THEN
        TAX.REP.REC = CG.ChargeConfig.TaxReportDetails.CacheRead(CONTRACT.ID, TAX.REP.ERR)
        TRIGGER.ID = 'REP*SC.ADJ.TXN.UPDATE*MOD*':FIELD(CONTRACT.ID,".",1):'*':EB.SystemTables.getIdCompany()
        USDB.ID = QI.Config.QcsiTrigger.Read(TRIGGER.ID, '')
        CUSTOMER.ID = FIELD(USDB.ID,"*",1)
    END ELSE
        CUSTOMER.ID = FIELD(CONTRACT.ID,"*",1)
        TAX.REP.REC = CG.ChargeConfig.TaxReportDetails.CacheRead(FIELD(CONTRACT.ID,"*",4), TAX.REP.ERR)
    END
    OWNING.PERCNT = ""

    JOINT.CUST.ID = RAISE(TAX.REP.REC<CG.ChargeConfig.TaxReportDetails.TaxRepJointCustTaxid>)
    FINDSTR CUSTOMER.ID:"*" IN JOINT.CUST.ID SETTING V.POS,S.POS THEN
        OWNING.PERCNT = TAX.REP.REC<CG.ChargeConfig.TaxReportDetails.TaxRepOwningPerc,V.POS,S.POS>
    END
    
RETURN
END
