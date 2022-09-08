* @ValidationCode : MjotMTk4Nzc3MjY2NTpDcDEyNTI6MTU3MzIwNjI5NTU4NDpzdWRoYXJhbWVzaDotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MTAuMjAxOTA5MjAtMDcwNzotMTotMQ==
* @ValidationInfo : Timestamp         : 08 Nov 2019 15:14:55
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sudharamesh
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-7</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.ARR.PROPERTY.CONDITIONS
*
** Routine to return an array of property details from an enquiry based
** on an arrangement record
** O.DATA is supplied in the format ARR ID - Property

    $USING AA.Framework
    $USING AA.ProductFramework
    $USING EB.Reports
    $USING AF.Framework

*
*
    DETAIL.POS = 100          ;* Field at the end of the record to hold details
    F.AA.XREF = ''
    ARR.ID = EB.Reports.getOData()
    AF.Framework.setProductArr(AA.Framework.AaArrangement)
*    AA.Framework.setProductArr(AA.Framework.AaArrangement)
    RET.ARRAY = ''
*
** Add the arrangement level records
*
    R.AA.XREF = AA.Framework.ArrangementDatedXref.Read(ARR.ID, YERR)
    NO.PROPERTIES = DCOUNT(R.AA.XREF<1>,@VM)
    FOR PROP.CNT = 1 TO NO.PROPERTIES
        PROPERTY = R.AA.XREF<1,PROP.CNT>
        PROPERTY.CLASS = ''
        AA.ProductFramework.GetPropertyClass(PROPERTY,PROPERTY.CLASS)
        PROP.CLASS.APP = "AA.ARR.":PROPERTY.CLASS
        AA.Framework.setPropertyClassId(PROPERTY.CLASS)
*
        TOT.DATES = COUNT(R.AA.XREF<2,PROP.CNT>,@SM) + 1
        FOR DT.CNT = 1 TO TOT.DATES
            EFF.DATE = R.AA.XREF<2,PROP.CNT,DT.CNT>
            PROP.COND.ID = ARR.ID:AA.Framework.Sep:R.AA.XREF<1,PROP.CNT>:AA.Framework.Sep:R.AA.XREF<2,PROP.CNT,DT.CNT>
            AF.Framework.SetPropertyCommon(PROP.COND.ID)
            RET.ARRAY<1,-1> = PROPERTY:">":EFF.DATE:">":PROP.CLASS.APP:">":PROP.COND.ID:">":AA.Framework.getArrLinkType()
        NEXT DT.CNT
*
    NEXT PROP.CNT

    tmp=EB.Reports.getRRecord(); tmp<DETAIL.POS>=RET.ARRAY; EB.Reports.setRRecord(tmp);* Put detail back int he record
    EB.Reports.setVmCount(DCOUNT(EB.Reports.getRRecord()<DETAIL.POS>,@VM));* and set the vm counter
*
RETURN
END
