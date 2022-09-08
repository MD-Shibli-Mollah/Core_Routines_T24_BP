* @ValidationCode : MTo2NTM4NDExNTpDcDEyNTI6MTU0NzYzMjQxNjg3ODpqaGFsYWt2aWo6LTE6LTE6MDoxOmZhbHNlOk4vQTpOL0E6MDow
* @ValidationInfo : Timestamp         : 16 Jan 2019 15:23:36
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jhalakvij
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 0/0 (0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------
* Subroutine Type : Subroutine

* Incoming        : ENQ.DATA

* Outgoing        : ENQ.DATA Common Variable

* Attached to     : AA.ARRANGEMENT & AA.ACCOUNT.DETAILS

* Attached as     : Build Routine in the Field BUILD.ROUTINE

* Primary Purpose : To return required Arrangement ids Which has a Product line Lending and
*                   has a maturity date as Seven days from Today

* Incoming        : Common variable ENQ.DATA Which contains all the
*                 : enquiry selection criteria details

* Change History  :

* Version         : First Version
*
* 14/06/15 - Task :1762483
*            Defect : 1762426
*            Variable intialisation
*-----------------------------------------------------------------------------

    $PACKAGE AA.ModelBank
    SUBROUTINE E.MB.AA.LOAN.MATURITY.7D(ENQ.DATA)


    $USING EB.API
    $USING EB.DataAccess
    $USING EB.SystemTables


    $INSERT I_DAS.AA.ACCOUNT.DETAILS
    $INSERT I_DAS.AA.ARRANGEMENT

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN
*-------------------------------------------------------------------------
INITIALISE:

    TABLE.NAME   = "AA.ACCOUNT.DETAILS"
    TABLE.SUFFIX = ""
    SEL.LIST     = DasAaAccountDetails$MaturityDate

    Y.START.DATE = EB.SystemTables.getToday()
    Y.END.DATE = EB.SystemTables.getToday()
    EB.API.Cdt('', Y.END.DATE, '+7C')

    MAT.DATE= Y.START.DATE:@FM:Y.END.DATE

    RETURN

PROCESS:

    EB.DataAccess.Das(TABLE.NAME,SEL.LIST,MAT.DATE,TABLE.SUFFIX)
    SEL.LIST = CHANGE(SEL.LIST,@FM,"' '")

    TABLE.NAME1   = "AA.ARRANGEMENT"
    TABLE.SUFFIX1 = ""
    SEL.LIST.LEN     = DasAaArrangement$IdProductLine
    ID.PRD.LINE = "'":SEL.LIST:"'":@FM:"LENDING"

    EB.DataAccess.Das(TABLE.NAME1,SEL.LIST.LEN,ID.PRD.LINE,TABLE.SUFFIX)
    CONVERT @FM TO ' ' IN SEL.LIST.LEN

    ENQ.DATA<2,-1> = '@ID'
    ENQ.DATA<3,-1> = 'EQ'
    ENQ.DATA<4,-1> = SEL.LIST.LEN

    RETURN
    END
