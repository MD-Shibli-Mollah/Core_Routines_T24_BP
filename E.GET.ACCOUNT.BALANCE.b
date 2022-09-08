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
* <Rating>-25</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.GET.ACCOUNT.BALANCE

* This routine is used to get the balance for an account depending on the Balance type
*
* Input  - In O.DATA we are getting the Account number  & Balance type
* Output - In O.DATA amount get stored
*
* This conversion routine is attached to various Loan & deposit enquiries in SCV pages.
**------------------------------------------------------------------------------
*    ! 20/11/14 - Sathish PS
*    !            Call AA.GET.ECB.BALANCE instead of AA.GET.PERIOD.BALANCES so we can support
*    !            Virtual Balances as well...
*    !-------------------------------------------------------------------------------
**
    $USING AA.Framework
    $USING EB.Reports
    $USING EB.SystemTables
    

    GOSUB PROCESS
    RETURN

PROCESS:
    REC.ID = ""
    REC.ID = EB.Reports.getOData()
    ACCOUNT.ID = FIELD(REC.ID,"*",1)
    BALANCE.TO.CHECK = FIELD(REC.ID,"*",2)
    ! 20/11/14 - Sathish PS /s
    REQUEST.DATE = EB.SystemTables.getToday()
    BALANCE.AMOUNT = ""
    RET.ERROR = ""
    AA.Framework.GetEcbBalanceAmount (ACCOUNT.ID, BALANCE.TO.CHECK, REQUEST.DATE, BALANCE.AMOUNT, RET.ERROR)
    IF RET.ERROR THEN
        EB.Reports.setEnqError(RET.ERROR)
    END ELSE
        EB.Reports.setOData(BALANCE.AMOUNT)
    END
*    ! Sathish PS - commented the lines below
*    !     PERIOD.ST.DATE = TODAY
*    !     PERIOD.END.DAT = TODAY
*    !     CALL AA.GET.PERIOD.BALANCES(ACCOUNT.ID, BALANCE.TO.CHECK, REQUEST.TYPE, PERIOD.ST.DATE ,PERIOD.END.DAT, SYSTEM.DATE, BAL.DETS, ERROR.MESSAGE)
*    !     NO.OF.DAYS = DCOUNT(BAL.DETS<1>,VM)
*    !     O.DATA = BAL.DETS<4,NO.OF.DAYS>
*    ! 20/11/14 - Sathish PS /e
    RETURN
