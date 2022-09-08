* @ValidationCode : MjotMTU0MDU1NTM1MzpDcDEyNTI6MTU5MzYxMjk4NDUxNjpqYWJpbmVzaDotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjctMDQzNTotMTotMQ==
* @ValidationInfo : Timestamp         : 01 Jul 2020 19:46:24
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jabinesh
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 2 25/05/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
$PACKAGE LI.ModelBank
SUBROUTINE E.LIMIT.ACCOUNT.OS
*-----------------------------------------------------------------------------
*
*     LIMIT ACCOUNT O/S (ENQ'S)
*     =========================
*
*-----------------------------------------------------------------------------
    $USING LI.LimitTransaction
    $USING EB.Reports
    $USING LI.Config
    $USING EB.SystemTables
*=====MAIN CONTROL========================================================
*
    DIM LIMIT(EB.SystemTables.SysDim) ;
    MAT LIMIT = ''
    R.LIMIT =  EB.Reports.getRRecord()
    MATPARSE LIMIT FROM R.LIMIT
    tmp.O.DATA = EB.Reports.getOData()
    LI.LimitTransaction.LimitGetAccBals(MAT LIMIT,'','',tmp.O.DATA)
    EB.Reports.setOData(tmp.O.DATA)
RETURN
*-----------------------------------------------------------------------------
END
