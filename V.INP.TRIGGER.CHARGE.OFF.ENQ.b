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
* <Rating>-31</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE V.INP.TRIGGER.CHARGE.OFF.ENQ
*-----------------------------------------------------------------------------
* Subroutine Type  : VERSION API
* Attached to      : AA.ARRANGEMENT.ACTIVITY,AA.DRILL.CO
* Attached as      : AUTH.ROUTINE
* Primary Purpose  : To open a new enquiry on commit of the AA.ARRANGEMENT.ACTIVITY record.
*
* Incoming:
* ---------
* NA
* Outgoing:
* ---------
* NA
* Error Variables:
* ----------------
* NA
*-----------------------------------------------------------------------------------
* Modification History:
* ---------------------
* 20/06/2014 : Task : 722477
*              Enh : 713751
*              To open a new enquiry on commit of the AA.ARRANGEMENT.ACTIVITY record.
*
* 25/01/16 - Task : 1605438
*            Defect ID : 1593519
*            Compilation Warnings - Retail for TAFC compatibility on DEV area.
*
*-------------------------------------------------------------------------------------
    
    $USING EB.API
    $USING EB.SystemTables
    $USING EB.Interface


    IF EB.Interface.getOfsOperation() EQ "PROCESS" THEN
        GOSUB INIT
        GOSUB PROCESS
    END

    RETURN
*---------------------------------------------------------------------------------------
* Initiliase neccessary variable
*----------------------------------------------------------------------------------------
INIT:
*---
    AA.ID = EB.SystemTables.getRNew(AA.ARR.ACT.ARRANGEMENT)
    NEXT.TASK = "ENQ AA.DETAILS.FIN.SUMMARY.CHARGEOFF ARRANGEMENT.ID EQ ":AA.ID:" CHG.OFF EQ BANK DISPLAY.ZERO.BALS EQ YES"

    RETURN
*-----------------------------------------------------------------------------------------
* Call Eb set new task to open the enquiry in the new window
*-----------------------------------------------------------------------------------------
PROCESS:
*-------
    EB.API.SetNewTask(NEXT.TASK)
    RETURN
*-------------------------------------------------------------------------------------------
END
