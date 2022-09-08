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

* Attached to     : AA.ARRANGEMENT & AA.ACCOUNT.DETAILS

* Attached as     : Build Routine in the Field BUILD.ROUTINE

* Primary Purpose : To return appropriate FILE.VERSION

* Incoming        : Common variable ENQ.DATA Which contains all the
*                 : enquiry selection criteria details

* Change History  :

* Version         : First Version

* Author          : vhariharane@temenos.com

************************************************************
*MODIFICATION HISTORY
*
* 05/01/09 - BG_100021512
*            Arguments changed for SIM.READ.
*
************************************************************
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.BUILD.ARR.DETAILS(ENQ.DATA)
************************************************************

    $USING EB.Reports
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
    FILE.VERSION = ENQ.DATA<DCOUNT(ENQ.DATA,@FM)>
    IF EB.Reports.getEnqSimRef() AND INDEX(FILE.VERSION,"SIM",1) THEN
        SIM.REF = EB.Reports.getEnqSimRef()
    END
*
    LOCATE "@ID" IN ENQ.DATA<2,1> SETTING ARR.POS THEN
    ARR.ID = ENQ.DATA<4,ARR.POS>
    END
*
    RETURN
**********************
PROCESS:
**********************

    EB.Reports.setRRecord('')
    RET.ERROR = ''
    SIM.REC.FND = ""
    FILE.NAME = "F.":EB.Reports.getREnq()<2>
*
    IF SIM.REF THEN
        tmp.R.RECORD = EB.Reports.getRRecord()
        EB.DatInterface.SimRead(SIM.REF, FILE.NAME, ARR.ID, tmp.R.RECORD, "", SIM.REC.FND, RET.ERROR)
        EB.Reports.setRRecord(tmp.R.RECORD)
    END
*

* Modifying the File Version
    IF SIM.REC.FND THEN       ;*If SIM Record exist then change the File Version
        CONVERT ' ' TO @FM IN FILE.VERSION
        LOCATE 'LIV' IN FILE.VERSION SETTING SIM.POS THEN
        DEL FILE.VERSION<SIM.POS>
    END
    CONVERT @FM TO ' ' IN FILE.VERSION
    ENQ.DATA<DCOUNT(ENQ.DATA,@FM)> = FILE.VERSION
    EB.Reports.setEnqFileVersion(FILE.VERSION)
    END
*
    RETURN
******************************
