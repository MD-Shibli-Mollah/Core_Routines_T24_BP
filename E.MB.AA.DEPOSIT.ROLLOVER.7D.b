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
*
* Subroutine Type : Subroutine

* Incoming        : ENQ.DATA

* Outgoing        : ENQ.DATA Common Variable

* Attached to     : AA.ARRANGEMENT & AA.ACCOUNT.DETAILS

* Attached as     : Build Routine in the Field BUILD.ROUTINE

* Primary Purpose : To return required Arrangement ids Which has a Product line Deposits and
*                   has a Renewal days as Seven days from Today
*

* Incoming        : Common variable ENQ.DATA Which contains all the
*                 : enquiry selection criteria details

* Change History  :

*-----------------------------------------------------------------------------
  
    $PACKAGE AD.ModelBank
    SUBROUTINE E.MB.AA.DEPOSIT.ROLLOVER.7D(ENQ.DATA)

    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING EB.Reports
    $USING EB.API
    
    $INSERT I_DAS.AA.ACCOUNT.DETAILS
    $INSERT I_DAS.AA.ARRANGEMENT

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN
*-------------------------------------------------------------------------
INITIALISE:

    TABLE.NAME   = "AA.ACCOUNT.DETAILS"
    TABLE.SUFFIX = ""
    SEL.LIST     = DasAaAccountDetails$MaturityRenewalDate

    Y.START.DATE = EB.SystemTables.getToday()
    Y.END.DATE = EB.SystemTables.getToday()

    EB.API.Cdt('', Y.END.DATE, '+7C')
    MAT.DATE= Y.START.DATE:@FM:Y.END.DATE

    RETURN

PROCESS:

    EB.DataAccess.Das(TABLE.NAME,SEL.LIST,MAT.DATE,TABLE.SUFFIX)
    SEL.LIST = CHANGE(SEL.LIST,@FM,"' '")

    TABLE.NAME.ARR   = "AA.ARRANGEMENT"
    TABLE.SUFFIX.ARR = ""
    SEL.LIST.LEN  = DasAaArrangement$IdProductLine
    ID.PRD.LINE = "'":SEL.LIST:"'":@FM:"DEPOSITS"

    EB.DataAccess.Das(TABLE.NAME.ARR,SEL.LIST.LEN,ID.PRD.LINE,TABLE.SUFFIX.ARR)
    CONVERT @FM TO ' ' IN SEL.LIST.LEN
    ENQ.DATA<2,-1> = '@ID'
    ENQ.DATA<3,-1> = 'EQ'
    ENQ.DATA<4,-1> = SEL.LIST.LEN

    RETURN
END
