* @ValidationCode : MjoxMTY4OTY0ODUxOkNwMTI1MjoxNTc4NDc4OTc5Mjg3OnN1ZGhhcmFtZXNoOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MTIuMjAxOTExMTktMTMzNDoyMDoxNg==
* @ValidationInfo : Timestamp         : 08 Jan 2020 15:52:59
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sudharamesh
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 16/20 (80.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201912.20191119-1334
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-12</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.ARR.PRODUCT
************************************
*
* This is a conversion routine for the field containing
* an arrangement Id(live or SIM).
*
************************************
*MODIFICATION HISTORY
*
* 05/01/09 - BG_100021512
*            Arguments changed for SIM.READ.
*
* 27/07/10 - Task 71493
*            Ref : Defect 71321 / HD1030435
*            Call the core routine setting SIM.MODE instead of locating locally here.
*
* 22/10/12 - Task 501661
*            Ref : Defect 500374
*            For simulation the effective date that we are getting it from the AA.SIMULATION.RUNNER
*
* 30/04/16 - Task   : 1716644
*            Defect : 1704114
*            For simulation the effective date that we are getting it from the AA.SIMULATION.RUNNER
*
* 18/12/19 - Task : 3496003
*            Defect : 3451851
*            System not displaying historical information of a BN pool structure.
*
************************************

    $USING AA.Framework
    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.DatInterface

************************************

    IN.DATA = EB.Reports.getOData()
    ARR.ID = FIELD(IN.DATA, '~', 1)
    EFF.DATE = FIELD(IN.DATA, '~', 2)
    IF NOT(EFF.DATE) THEN
        EFF.DATE = EB.SystemTables.getToday()          ;*For live arrangement, get the product as on today
    END
    R.ARR = ''
    RET.ERR = ''
    IF INDEX(ARR.ID,'%',1) THEN
        SIM.REF = ARR.ID['%',2,1]
        ARR.ID = ARR.ID['%',1,1]
    END
        
    IF SIM.REF THEN
        EB.DatInterface.SimRead(SIM.REF, "F.AA.ARRANGEMENT", ARR.ID, R.ARR, "", "", RET.ERR)
    END ELSE
        AA.Framework.GetArrangement(ARR.ID, R.ARR, RET.ERR)
    END
    AA.Framework.GetArrangementProduct(ARR.ID,EFF.DATE,R.ARR,PRODUCT.ID,'')
    EB.Reports.setOData(PRODUCT.ID)
*
RETURN
