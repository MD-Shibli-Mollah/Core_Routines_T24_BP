* @ValidationCode : MjotMTg2NDAwNDM1NTpDcDEyNTI6MTYwNTcwMjEwMjg4NDpyYWtzaGFyYToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA5LjA6MjU6MjU=
* @ValidationInfo : Timestamp         : 18 Nov 2020 17:51:42
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rakshara
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 25/25 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202009.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.MB.AA.LENDING.ROLLOVER.7D(EnqData)
*-----------------------------------------------------------------------------
* Routine Description:
*---------------------
* Primary Purpose : To return required Arrangement ids Which has a Product line Lending and
*                   has a Renewal days as Seven days from Today.
*
* Incoming        : Common variable EnqData Which contains all the
*                 : enquiry selection criteria details
*
* Outgoing        : EnqData Common Variable
*
*-----------------------------------------------------------------------------
* Subroutine Type : Subroutine
* Attached to     : AA.ARRANGEMENT & AA.ACCOUNT.DETAILS
* Attached as     : Build Routine in the Field BUILD.ROUTINE
*-----------------------------------------------------------------------------
* Modification History :
*
* 05/11/20 - Task- 4044949
*            Enhancement - 4030912
*            Routine to return arrangament id having renewal days as seven days from today.
*
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING EB.Reports
    $USING EB.API
    
    $INSERT I_DAS.AA.ACCOUNT.DETAILS
    $INSERT I_DAS.AA.ARRANGEMENT

    GOSUB Initialise
    GOSUB Process

RETURN
*** </region>
*-------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialising variables </desc>
Initialise:

    TableName   = "AA.ACCOUNT.DETAILS"
    TableSuffix = ""
    SelList     = DasAaAccountDetails$RenewalDate

    YstartDate = EB.SystemTables.getToday()
    YendDate   = EB.SystemTables.getToday()

    EB.API.Cdt('', YendDate, '+7C')
    MatDate= YstartDate:@FM:YendDate

RETURN
*** </region>
*-------------------------------------------------------------------------
*** <region name= Process>
*** <desc> Main process</desc>
Process:

    EB.DataAccess.Das(TableName,SelList,MatDate,TableSuffix)
    SelList = CHANGE(SelList,@FM,"' '")

    TableNameArr   = "AA.ARRANGEMENT"
    TableSuffixArr = ""
    SelListLen     = DasAaArrangement$IdProductLine
    IdPrdLine      = "'":SelList:"'":@FM:"LENDING"

    EB.DataAccess.Das(TableNameArr,SelListLen,IdPrdLine,TableSuffixArr)
    CONVERT @FM TO ' ' IN SelListLen
    EnqData<2,-1> = '@ID'
    EnqData<3,-1> = 'EQ'
    EnqData<4,-1> = SelListLen

RETURN
*** </region>
*-------------------------------------------------------------------------
END
