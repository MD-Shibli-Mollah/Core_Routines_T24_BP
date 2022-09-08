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
* <Rating>-54</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE T2.ModelBank
    SUBROUTINE V.TC.UPDATE.USER.PREF
*-----------------------------------------------------------------------------
* Routine type       : Auth routine
* Attached To        : VERSION>CHANNEL.PERMISSION,TCIB
* Purpose            : This routine used to update Channel Permission Id for Channel Permission List Concat file
*-----------------------------------------------------------------------------
* Modification History :
* 18/05/15 - Enhancement - 1226758 / Task: 1347374
*            Create and update account groups based on channel permission
*
* 14/07/15 - Enhancement 1326996 / Task 1399946
*			 Incorporation of T components
* 09/12/15 - Defect 1555469 / Task 1558543
*			 While commit the channel permission record we are getting "There is a problem with the system, Please contact the System Administrator"
*-----------------------------------------------------------------------------
*
    $USING EB.ARC
    $USING EB.SystemTables
    $USING EB.TransactionControl

    $INSERT I_DAS.EB.EXTERNAL.USER
*
    GOSUB INITIALISE
    GOSUB OPENFILES
    GOSUB PROCESS
*
    RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
* Initialise required variables
    CHNL.PERM.ID = EB.SystemTables.getIdNew()     ;*ID of the current record
    USER.TYPE = "CORPORATE"   ;*User type to update the account group
    APP.NAME = "EB.EXTERNAL.USER"
    ID.LIST = DAS.EXT$CHANNEL.PERMISSION          ;* Argument to get External User for particular Channel Permission
    THE.ARGS = CHNL.PERM.ID:@FM:USER.TYPE
*
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= OPENFILES>
OPENFILES:
*---------
	FN.CHANNEL.PERMISSION.LIST='F.CHANNEL.PERMISSION.LIST'  ;* Assign file name for Channel Permission List
    F.CHANNEL.PERMISSION.LIST=''        ;* Assign file path for Channel Permission List
*
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
PROCESS:
* Update Channel Permission List
    CALL DAS(APP.NAME,ID.LIST,THE.ARGS,'')        ;* Get External User List
    IF ID.LIST THEN
        tmp.ID.NEW = EB.SystemTables.getIdNew()
        R.CHANNEL.PERM.LIST = EB.ARC.ChannelPermissionList.Read(tmp.ID.NEW, REC.ERR)  ;* Read channel permission list to get record
        IF NOT(R.CHANNEL.PERM.LIST) THEN
            tmp.ID.NEW = EB.SystemTables.getIdNew()
            EB.TransactionControl.ConcatFileUpdate(FN.CHANNEL.PERMISSION.LIST,tmp.ID.NEW,tmp.ID.NEW,'I','AL')    ;* If the current Id is not exist, then add ID.NEW to Channel Permission List
            EB.SystemTables.setIdNew(tmp.ID.NEW)
        END
    END
    IF EB.SystemTables.getVFunction() EQ 'D' THEN
        tmp.ID.NEW = EB.SystemTables.getIdNew()
        EB.TransactionControl.ConcatFileUpdate(FN.CHANNEL.PERMISSION.LIST,tmp.ID.NEW,tmp.ID.NEW,'D','AL')        ;* Delete the record from Concat List
        EB.SystemTables.setIdNew(tmp.ID.NEW)
    END
*
    RETURN
*** </region>
*-----------------------------------------------------------------------------
    END
