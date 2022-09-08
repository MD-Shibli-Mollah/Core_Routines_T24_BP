* @ValidationCode : MjotNzQzNDI5Mzc2OkNwMTI1MjoxNDkwMjY3NTU1NzA0OmNoamFobmF2aToxOjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTcwMi4wOjM3OjM3
* @ValidationInfo : Timestamp         : 23 Mar 2017 16:42:35
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : chjahnavi
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 37/37 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


    $PACKAGE EB.ARC
    SUBROUTINE V.USER.ACCT.GROUPS
*----------------------------------------------------------------------------------
* Routine type       : Auth routine
* Attached To        : VERSION.CONTROL>EB.EXTERNAL.USER
* Purpose            : This routine used to create a copy of accounts group for New User.
*-----------------------------------------------------------------------------
* Modification History :
* 18/05/15 - Enhancement - 1226758 / Task: 1347374
*            Create and update account groups based on channel permission
*
* 13/07/15 - Enhancement - 1326996 / Task 1399931
*			 Incorporation of EB_ARC component
*
* 15/03/17 - Defect 2033781 / Task 2054540
*            Cloning of user account groups for the new users
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING EB.ARC

    $INSERT I_DAS.EB.EXT.USER.PREF
    $INSERT I_DAS.EB.EXTERNAL.USER
*
    GOSUB INITIALISE
    GOSUB OPENFILE
    GOSUB PROCESS
*
    RETURN
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
* Initialise required variables
    ARR.ID=EB.SystemTables.getRNew(EB.ARC.ExternalUser.XuArrangement)     ;* To get arrangement Id from new record
    EXT.ID=EB.SystemTables.getIdNew()   ;* To get external user Id
    USER.TYPE=EB.SystemTables.getRNew(EB.ARC.ExternalUser.XuUserType)    ;* Assign User Type of external user
*
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= OPENFILE>
OPENFILE:

*
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS>
PROCESS:
* Create Account groups for New user
    IF USER.TYPE EQ 'CORPORATE' THEN    ;* Check the user type of external user is 'CORPORATE'
        THE.LIST=DAS.EXT$ARRANGEMENT
        THE.ARGS=ARR.ID
        CALL DAS('EB.EXTERNAL.USER',THE.LIST,THE.ARGS,'')   ;* Get an external user with same arrangement Id
        IF THE.LIST THEN
            GOSUB GET.ACCT.GROUP.LIST ;* get account groups list created for the user list returned
            LOOP
                REMOVE ACCT.GROUP.ID FROM THE.EXT.LIST SETTING POS    ;* Get a account group Id
            WHILE ACCT.GROUP.ID:POS
                NEW.GROUP.ID=EXT.ID:'-':FIELD(ACCT.GROUP.ID,'-',2)    ;* New user account group Id
                R.ACC.GROUP = EB.ARC.ExtUserPref.Read(ACCT.GROUP.ID,ERR.GROUP)         ;* Get an existing user account group record
                EB.ARC.ExtUserPref.Write(NEW.GROUP.ID,R.ACC.GROUP)       ;* Create a new user account group record
            REPEAT
        END
    END
*
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.ACCT.GROUP.LIST>
GET.ACCT.GROUP.LIST:
* Get account groups list from the users
    USER.POS = ''; EXT.USER.ID = ''; ACCT.GRP.LIST = '';
    LOOP
        REMOVE EXT.USER.ID FROM THE.LIST SETTING USER.POS    ;* Get a account group Id
    WHILE EXT.USER.ID:USER.POS
        THE.EXT.LIST=DAS.EB$USER.ID ;* Get a external User Account
        THE.ARGS = EXT.USER.ID:'...'
        CALL DAS('EB.EXT.USER.PREF',THE.EXT.LIST,THE.ARGS,'')     ;* Get the account
        ACCT.GRP.LIST<-1> = THE.EXT.LIST
    REPEAT
*
    RETURN
*** </region>
*---------------------------------------------------------------------------------
    END
