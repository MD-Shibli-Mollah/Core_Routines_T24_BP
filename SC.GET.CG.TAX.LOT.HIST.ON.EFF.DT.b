* @ValidationCode : Mjo2NTg1NDY0ODc6Q3AxMjUyOjE1OTU1MTA4NjM2OTQ6ZHBvb3JuaW1hOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDcuMjAyMDA2MjQtMTUyODozNzozNw==
* @ValidationInfo : Timestamp         : 23 Jul 2020 18:57:43
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : dpoornima
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 37/37 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202007.20200624-1528
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SC.ModelBank
SUBROUTINE SC.GET.CG.TAX.LOT.HIST.ON.EFF.DT(ID.CG.TXN.BASE,END.DATE, CG.DATA)
*-----------------------------------------------------------------------------
*
* Incoming parameter :
* ID.CG.TXN.BASE    - Id of CG.TXN.BASE
* END.DATE          - Date till which unallocation to be performed
*
* Outgoing parameter :
* CG.DATA           - Details fetched from CG.TXN.BASE
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 22/07/2020 - TASK 3870782
*              CGT API - No File Enquiry routines to be converted as API with Public access
*-----------------------------------------------------------------------------
    $USING SC.SctCapitalGains

    CG.DATA = ''
    GOSUB BUILD.CG.TXN.BASE.DATE ; *Read Cg Txn Base Record from id and frame the base DATA

RETURN

*-----------------------------------------------------------------------------
*** <region name= BUILD.CG.TXN.BASE.DATE>
BUILD.CG.TXN.BASE.DATE:
*** <desc>Read Cg Txn Base Record from id and frame the base DATA </desc>

    E.CG.TXN.BASE = ''
    R.CG.TXN.BASE = SC.SctCapitalGains.CgTxnBase.Read(ID.CG.TXN.BASE, E.CG.TXN.BASE)
    GOSUB UNALLOCATE.TXNS          ; *Unallocate all the disposal transactions that has taken place after portfolio lock date if mentioned
* GOSUB SET.BASE.ID ;* Set CG.TXN.BASE id and Portfolio , Instrument Components.
* If Tax Lot ID is not available, then list all tax lots from this
    INDIVIUAL.BASE.REC = 1
    TOTAL.CG.TXNS = DCOUNT(R.CG.TXN.BASE<SC.SctCapitalGains.CgTxnBase.CgTxnTradeDateTime>,@VM)
    FOR CG.TXN.POS = 1 TO TOTAL.CG.TXNS
        IF R.CG.TXN.BASE<SC.SctCapitalGains.CgTxnBase.CgTxnTaxLotId,CG.TXN.POS> THEN
            TAX.LOT.ID = R.CG.TXN.BASE<SC.SctCapitalGains.CgTxnBase.CgTxnTaxLotId,CG.TXN.POS>
*GOSUB GET.HISTORY.FROM.CG.DETS ;* Get History from CG.TXN.DETS
            CG.BASE.ID = ''
            IF INDIVIUAL.BASE.REC =1 THEN
                CG.BASE.ID = ID.CG.TXN.BASE:@VM:'BASE'
                INDIVIUAL.BASE.REC = 0
            END ELSE
                CG.BASE.ID = ID.CG.TXN.BASE
            END
            ENQ.OUT = ''
            SC.SctCapitalGains.ScGetHistoryBuyParcel(TAX.LOT.ID, CG.BASE.ID, ENQ.OUT, R.CG.TXN.BASE, R.CG.TXN.DETS)
            CG.DATA<-1> = ENQ.OUT
        END
    NEXT CG.TXN.POS
    
RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= UNALLOCATE.TXNS>
UNALLOCATE.TXNS:
*** <desc>Unallocate all the disposal transactions that has taken place after portfolio lock date if mentioned </desc>

    IF END.DATE THEN
* Unallocate all the txn after EFFECTIVE DATE so that all the open lots will be presented to user
        INPUT.ID = ID.CG.TXN.BASE
        INPUT.REC = ""
        INPUT.REC<SC.SctCapitalGains.CgUnallocateTillDate> = END.DATE
        ACTION = "UNALLOCATE"
        OVERRIDE.MSGS = ""
        ORIGIN = "UNALLOCATE"
        ORIGIN<3> = "" ;* Donot update Other files when CG.ENH.PROCESS is set like CG.TXN.EFF.LIST , CG.TXN.DETS
        TRA.CODE = ""
        SC.SctCapitalGains.ScPrepareCgBaseUpdate(R.CG.TXN.BASE, INPUT.REC, INPUT.ID, ACTION, OVERRIDE.MSGS, ORIGIN, TRA.CODE)
        R.CG.TXN.DETS = SC.SctCapitalGains.getCgBuildCgTxnDets()
    END
    
RETURN
*** </region>

END
