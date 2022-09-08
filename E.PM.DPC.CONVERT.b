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

* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>98</Rating>
*-----------------------------------------------------------------------------
*
* Modification History :
*
*
* 01/11/15 - EN_1226121/Task 1499688
*			 Incorporation of routine
*
    $PACKAGE PM.Reports
    SUBROUTINE E.PM.DPC.CONVERT(DPC.ID, MAT DPC.REC, TO.CURRENCY)
*


    $USING EU.Config
    $USING PM.Config
    $USING ST.ExchangeRate
    $USING PM.Reports

*
** Perform conversion to EUR or other fixed ccy using exchange rate
*
    WCCY = DPC.ID['.',5,1]
    MKT = DPC.ID['.',2,1]
*
    VMX = DCOUNT(DPC.REC(PM.Config.DlyPosnClass.DpcAmount),@VM)
    FOR VMIND = 1 TO VMX
        SMX = DCOUNT(DPC.REC(PM.Config.DlyPosnClass.DpcAmount)<1,VMIND>,@SM)
        FOR SMIND = 1 TO SMX

            IF SMIND = 3 THEN CONTINUE   ; * DO NOT convert lccy equivalent

            FIX.AMT = ''
            TEMP.VAR = PM.Config.getREuFixedCcy()
            LOCATE WCCY IN TEMP.VAR<EU.Config.FixedCurrency.FcCurrencyCode,1> SETTING POS THEN
            FIX.RATE = PM.Config.getREuFixedCcy()<EU.Config.FixedCurrency.FcFixedRate,POS>
        END ELSE
            FIX.RATE = ''
        END
        *
        OTHER.AMT = DPC.REC(PM.Config.DlyPosnClass.DpcAmount)<1,VMIND,SMIND>
        IF OTHER.AMT THEN
            ST.ExchangeRate.Exchrate(MKT, WCCY, OTHER.AMT, TO.CURRENCY, FIX.AMT, '', FIX.RATE, '', '', '')
        END
        DPC.REC(PM.Config.DlyPosnClass.DpcAmount)<1,VMIND,SMIND> = FIX.AMT
    NEXT VMIND
    NEXT SMIND
*
    RETURN
*
    END
