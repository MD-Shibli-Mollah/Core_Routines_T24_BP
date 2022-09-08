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

* <Rating>-22</Rating>

*-----------------------------------------------------------------------------

* Subroutine Type : Subroutine

* Incoming        : ENQ.DATA

* Outgoing        : ENQ.DATA Common Variable

* Attached to     : AA.ARRANGEMENT

* Attached as     : Build Routine in the Field BUILD.ROUTINE

* Primary Purpose : To only return a record if the Arrangement is linked
*                 : to a Limit.

* Incoming        : Common variable ENQ.DATA Which contains all the
*                 : enquiry selection criteria details

* Change History  :

* Version         : First Version

* Author          : smakrinos@temenos.com


************************************************************

*MODIFICATION HISTORY

*

*

************************************************************

    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.NO.LIMIT(ENQ.DATA)

************************************************************

    $USING EB.Reports
    $USING AA.Limit
    $USING EB.DatInterface


****************************

*

    GOSUB INITIALISE

    GOSUB PROCESS

*

    RETURN

****************************

INITIALISE:

*
    LOCATE "@ID" IN ENQ.DATA<2,1> SETTING ARR.POS THEN

    ARR.ID = ENQ.DATA<4,ARR.POS>

    END

    SIM.REF = EB.Reports.getEnqSimRef()
*

    RETURN

**********************

PROCESS:

**********************


    EB.Reports.setRRecord('')

    RET.ERROR = ''

    FILE.NAME = "F.":EB.Reports.getREnq()<2>

    tmp.R.RECORD = EB.Reports.getRRecord()
    EB.DatInterface.SimRead(SIM.REF, FILE.NAME, ARR.ID, tmp.R.RECORD, "", "", "")
    EB.Reports.setRRecord(tmp.R.RECORD)

* Check if Arrangement is part of bundle
* If not, then change Arrangement.ID to "NO.BUNDLE" so that no records are returned

    LIMIT.REF = ''
    LIMIT.REF = EB.Reports.getRRecord()<AA.Limit.Limit.LimLimitReference>

    IF LIMIT.REF='' THEN
        ENQ.DATA<4,ARR.POS>='NO.LIMIT'
    END

*

    RETURN

******************************

