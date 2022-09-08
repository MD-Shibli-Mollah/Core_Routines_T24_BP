* @ValidationCode : MjotNzk0NDM1Nzk2OkNwMTI1MjoxNTcxNzQ2NjI3MjcwOnN1ZGhhcmFtZXNoOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MTAuMjAxOTA5MjAtMDcwNzozNDozNA==
* @ValidationInfo : Timestamp         : 22 Oct 2019 17:47:07
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sudharamesh
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 34/34 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE T2.ModelBank
SUBROUTINE V.TC.REMOVE.CLOSED.ACCOUNT
*-----------------------------------------------------------------------------
* Routine type       : Before Auth Routine
* Attached To        : VERSION -> ACCOUNT.CLOSURE,TC AND VERSION.CONTROL AA.ARRANGEMENT.ACTIVITY
* Purpose            : This routine is used to write closed accounts to Channel Permission List
*-----------------------------------------------------------------------------
* Modification History :
* 29/03/18 - Defect - 2523170 / Task : 2529524
*            Citco Closed accounts are not removed from TCIB in case of multi company
*
* 17/07/18 - Defect - 2673564 / Task : 2681550
*            Accounts are not being closed if ClOSED.ACCOUTN.ARRANGEMENT activity is triggered as child activity
*
*  21/10/19 - Enhancement : 2851854
*             Task : 3396231
*             Code changes has been done as a part of AA to AF Code segregation
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING AA.Framework
    $USING ST.CompanyCreation
    $USING EB.ARC
    $USING EB.TransactionControl
    $USING AF.Framework
*-----------------------------------------------------------------------------
    GOSUB INITIALISE
    GOSUB OPENFILES
    GOSUB PROCESS
*
RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
* Initialise required variables
    ARR.STATUS= ""
    FN.CHANNEL.PERMISSION.LIST= 'F.CHANNEL.PERMISSION.LIST'  ;* Assign file name for Channel Permission List
    F.CHANNEL.PERMISSION.LIST= ''        ;* Assign file path for Channel Permission List
    R.ARRANGEMENT= ""
    APP= ""
    ARR.ID= ""
    ACCOUNT.CLOSED.ID= ""
    R.CHANNEL.PERM.LIST= ""
    ID=""
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= OPENFILES>
OPENFILES:
* Open required files
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
PROCESS:
    APP= EB.SystemTables.getApplication()
    ID= EB.SystemTables.getIdNew()      ;*ID of the current record
    ARR.STATUS=AF.Framework.getC_arractivitystatus()
    BEGIN CASE
        CASE APP EQ "AA.ARR.CLOSURE" AND ARR.STATUS EQ 'AUTH'
            ARR.ID= AA.Framework.getArrId()   ;*Arrangement id is assigned to the variable
            R.ARRANGEMENT = AA.Framework.Arrangement.Read(ARR.ID, Err)
            ACCOUNT.CLOSED.ID="ACCOUNT-":R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkedApplId>
            GOSUB UPDATE.CHANNEL.PERMISSION.LIST
*
        CASE APP EQ "ACCOUNT.CLOSURE"
            ACCOUNT.CLOSED.ID = "ACCOUNT-":ID
            GOSUB UPDATE.CHANNEL.PERMISSION.LIST
    END CASE
RETURN
*** </region>
*-----------------------------------------------------------------------------
* Update Channel Permission List
UPDATE.CHANNEL.PERMISSION.LIST:
    R.CHANNEL.PERM.LIST= EB.ARC.ChannelPermissionList.Read(ACCOUNT.CLOSED.ID, REC.ERR)  ;* Read channel permission list to get record
    IF NOT(R.CHANNEL.PERM.LIST) THEN
        EB.TransactionControl.ConcatFileUpdate(FN.CHANNEL.PERMISSION.LIST,ACCOUNT.CLOSED.ID,ID,'I','AL')    ;* If the current Id is not exist, then add ID.NEW to Channel Permission List
    END
RETURN
**** </region>
*-----------------------------------------------------------------------------
END

