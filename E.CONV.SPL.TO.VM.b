* @ValidationCode : MjotNDkxMzc3NDY2OkNwMTI1MjoxNDk1MTk0ODE2ODU3OmFiY2l2YW51amE6MTowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDIuMDoxNzoxNQ==
* @ValidationInfo : Timestamp         : 19 May 2017 17:23:36
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : abcivanuja
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 15/17 (88.2%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

    $PACKAGE AC.ModelBank
    SUBROUTINE E.CONV.SPL.TO.VM
*-----------------------------------------------------------------------------
*
*----------------------------------------------------------------------------
* Modification History :
*
* 03/05/2017  - EN 2087544 / Task 2109264
*               Conversion routine for account statement enq
*
*-----------------------------------------------------------------------------
*
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
    $USING EB.Reports
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>

    IN.DATA = EB.Reports.getOData()
    VM.POS = EB.Reports.getVc()
    SM.POS = EB.Reports.getS()
    VM.CNT = EB.Reports.getVmCount()
    SM.CNT = EB.Reports.getSmCount()

    IN.DATA = CHANGE(IN.DATA,'~',@VM)
    IN.DATA = CHANGE(IN.DATA,'}',@SM)

    EB.Reports.setOData(IN.DATA<1,VM.POS,SM.POS>)

    TOTAL.VM.COUNT = DCOUNT(IN.DATA,@VM)
    IF VM.CNT AND VM.CNT LT TOTAL.VM.COUNT THEN ;* VM.COUNT should always have maximum count of all the conditons to display all values properly
        EB.Reports.setVmCount(TOTAL.VM.COUNT)
    END

    TOTAL.SM.COUNT = DCOUNT(IN.DATA,@SM)
    IF SM.CNT AND SM.CNT LT TOTAL.SM.COUNT THEN ;* SM.COUNT should always have maximum count of all the conditons to display all values properly
        EB.Reports.setSmCount(TOTAL.SM.COUNT)
    END
    RETURN
*-----------------------------------------------------------------------------
    END
