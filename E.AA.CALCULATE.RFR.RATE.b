* @ValidationCode : MjotNTk3MjkzODU5OkNwMTI1MjoxNjE2NzQ5ODIyNzgzOnZhcmNoYW5hOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIxMDMuMDoyNjoyNg==
* @ValidationInfo : Timestamp         : 26 Mar 2021 14:40:22
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : varchana
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 26/26 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AA.ModelBank
SUBROUTINE E.AA.CALCULATE.RFR.RATE
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 11/9/2020 - Task:3911429
*             Enhancement:3911426
*             Effective rate to be calculated dynamically to project in overview screen for RFR
*
* 10/10/20 - Enhancement : 3853183
*            Task        : 4015334
*            Prior Days for Interest Rate calculation.
*
* 26/03/21 - Enhancement : 4219094
*            Task        : 4298642
*            Pass the values in ODATA only if the Interest Rate is set, i.e, only for arrangements with PI definition.
*-----------------------------------------------------------------------------
    $USING EB.Reports
    $USING AA.Framework
    $USING AA.Interest
*-----------------------------------------------------------------------------

    GOSUB INITIALISE ; *Initialise variables
    GOSUB CALCULATE.RFR.RATE ; *To calculate RFR rate dynamically
    
RETURN
*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>Initialise variables </desc>
    ARR.ID = ''
    PERIODIC.INTEREST.RATE = ''
    ARR.ID = EB.Reports.getOData()
    ID.ARRANGEMENT.COMP = FIELD(ARR.ID,"-",1)
    ID.PROPERTY = FIELD(ARR.ID,"-",2)
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= CALCULATE.RFR.RATE>
CALCULATE.RFR.RATE:
*** <desc>To calculate RFR rate dynamically </desc>
    AA.Framework.GetArrangementConditions(ID.ARRANGEMENT.COMP, '', ID.PROPERTY, '', RETURN.IDS, RETURN.CONDITIONS, RETURN.ERROR)
    R.AA.ARR.INTEREST.REC = RAISE(RETURN.CONDITIONS)

    TIER.COUNT = COUNT(R.AA.ARR.INTEREST.REC<AA.Interest.Interest.IntTierAmount>, @VM) + 1
    FOR T.CNT=1 TO TIER.COUNT
        INTEREST.RATE = ''
        PERIODIC.INDEX = R.AA.ARR.INTEREST.REC<AA.Interest.Interest.IntPeriodicIndex,T.CNT>
        AA.Interest.GetInterestRfrRate(PERIODIC.INDEX, '', '', T.CNT, R.AA.ARR.INTEREST.REC, '', '', '', '', INTEREST.RATE, RETURN.ERROR, '')
        PERIODIC.INTEREST.RATE<1,-1> =INTEREST.RATE
    NEXT T.CNT
    
    IF INTEREST.RATE THEN ;* Only if the Interest Rate is available, then pass the OData
        EB.Reports.setOData(PERIODIC.INTEREST.RATE)
        tmp.O.DATA = EB.Reports.getOData()
        EB.Reports.setVmCount(DCOUNT(tmp.O.DATA, @VM))
        EB.Reports.setOData(tmp.O.DATA)
        EB.Reports.setOData(EB.Reports.getOData()<1,EB.Reports.getVc()>)
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

END


