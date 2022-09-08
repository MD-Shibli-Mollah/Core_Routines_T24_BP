* @ValidationCode : MjoyNzg2OTgxNjc6Y3AxMjUyOjE1ODI4ODMwNzIwNzk6c2l2YXNhbmdhcmluOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDEuMjAxOTEyMjQtMTkzNToxNToxNQ==
* @ValidationInfo : Timestamp         : 28 Feb 2020 15:14:32
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : sivasangarin
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 15/15 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202001.20191224-1935
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.PENDING.ACTIVITIES.DETAILS
    
    $USING EB.Reports
    

    COMMON/AAHIST/RET.ARR

    GOSUB INITIALISE
    GOSUB PROCESS
*
RETURN
***************************
INITIALISE:

    ARR.VAL = EB.Reports.getOData()
*
RETURN
***************************
PROCESS:

    tmp=EB.Reports.getRRecord(); tmp<1>=RET.ARR<1,ARR.VAL>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<2>=RET.ARR<2,ARR.VAL>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<3>=RET.ARR<3,ARR.VAL>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<4>=RET.ARR<4,ARR.VAL>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<5>=RET.ARR<5,ARR.VAL>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<6>=RET.ARR<6,ARR.VAL>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<7>=RET.ARR<7,ARR.VAL>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<8>=RET.ARR<8,ARR.VAL>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<9>=RET.ARR<9,ARR.VAL>; EB.Reports.setRRecord(tmp)

*
RETURN
***************************
