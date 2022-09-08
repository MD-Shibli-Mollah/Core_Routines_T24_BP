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

*-----------------------------------------------------------------------------
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RE.ModelBank
    SUBROUTINE E.SELECT.LASTWDAY.SUMMARY(ENQ.DATA)

** The routine selects only the last working day's EB.SYSTEM.SUMMARY record
** in order to be reported as report for the enquiry SYS.POS.ACCOUNT.SUMMARY.RPT
    
    $USING EB.SystemTables
    $USING EB.Utility

    GOSUB INITIALISE
    GOSUB GET.LAST.WORKING.ID

    RETURN

INITIALISE:
***********

    LAST.WORK.DAY = EB.SystemTables.getRDates(EB.Utility.Dates.DatLastWorkingDay)
    RETURN
    
GET.LAST.WORKING.ID:
*******************
    LOCATE 'SYSTEM.DATE' IN ENQ.DATA<2,1> SETTING DATE.POS THEN
        ENQ.DATA<4,DATE.POS> = LAST.WORK.DAY
    END ELSE
        SEL.CNT = DCOUNT(ENQ.DATA<2>,@VM) + 1
        ENQ.DATA<2,SEL.CNT> = 'SYSTEM.DATE'
        ENQ.DATA<3,SEL.CNT> = 'EQ'
        ENQ.DATA<4,SEL.CNT> = LAST.WORK.DAY
    END
    RETURN
    END
