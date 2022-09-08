* @ValidationCode : MjotNDE1NDU5MTg1OkNwMTI1MjoxNTIxMTA2OTA2NzgzOmRtYXRlaToyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxODAzLjE6Mzg6Mzg=
* @ValidationInfo : Timestamp         : 15 Mar 2018 11:41:46
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : dmatei
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 38/38 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201803.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-79</Rating>
*-----------------------------------------------------------------------------
$PACKAGE T2.ModelBank
SUBROUTINE TC.LAST.LOGIN.UPDATE(CHANNEL.POSITION)
*----------------------------------------------------------------------------
* Attached to      : API Routine
* Return Parameter : NA
*----------------------------------------------------------------------------------------------------
* Description:
*-------------
* Update the date & time in EB.EXTERNAL.USER
*----------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* 21/08/17 - Enhancement 2161898 / Task 2244717
*            Authentication solution support w.r.t Multiple Arrangement set-up
* 16/02/18 - Enhancement 2462955 / Task 2462958
*            Update the status for EEU from Initiated to Active
*----------------------------------------------------------------------------------------------------
    $USING EB.ARC
    $USING EB.Utility
    $USING EB.ErrorProcessing
    $USING EB.DataAccess
    $USING EB.Browser

    GOSUB INITIALIZE          ;* Initialize the variables
    GOSUB OPEN.FILES          ;* Open the required files
    GOSUB MAIN.PROCESS        ;* Process to update the login time and date

RETURN
*-----------------------------------------------------------------------------------
******<desc> initialize the required variables </desc>
INITIALIZE:
**********
    FN.EB.EXTERNAL.USER = 'F.EB.EXTERNAL.USER'
    F.EB.EXTERNAL.USER = ''
    R.EB.EXTERNAL.USER = '' ;* Initialise External user record
    EB.USER.ERR=''   ;* Initialize Error variable
RETURN
*--------------------------------------------------------------------------------------
*****<desc>Open the required files </desc>
OPEN.FILES:
*********
    EB.DataAccess.Opf(FN.EB.EXTERNAL.USER,F.EB.EXTERNAL.USER)  ;* Open file
RETURN
*----------------------------------------------------------------------------------------
*** <desc>if its first request update the time of use in External user </desc>
MAIN.PROCESS:
************
*** The below logic is suitable only for External user with Ofs source type as "TELNET" and Channel as "INTERNET"
*** Also its applicable only OFS.SOURCE as TCIB.
*** <desc>Get local zone date and time based on the SPF setup </desc>
    INOPTIONS='' ; OUTOPTIONS=''        ;* Initialise
    INOPTIONS<1> ='':@VM:'D4E' ;* local zone date
    INOPTIONS<2> ='':@VM:'MTH' ;* local zone time

    EB.Utility.Getlocalzonedatetime('','',INOPTIONS,localZoneDate,localZoneTime,OUTOPTIONS, reserved1)

    YSYSDATE = localZoneDate<1>[7,4]:localZoneDate<1>[1,2]:localZoneDate<1>[4,2]          ;* date
    dateLastUse=localZoneDate<2>        ;* D4E
    timeLastUse=localZoneTime<2>        ;* MTH
    HHMM = localZoneTime<1>:' ':localZoneDate<2>  ;* TIMEDATE() output

    EB.EXTERNAL.HHMM = HHMM
    EB.EXTERNAL.HHMM = EB.EXTERNAL.HHMM[1,2]:EB.EXTERNAL.HHMM[4,2] : EB.EXTERNAL.HHMM[7,2]
    CURR.CHANNEL.TYPE = EB.ErrorProcessing.getExternalChannelType()  ;* get current channel from common variable
    
    tmp.EB.EXTERNAL$USER.ID = EB.ErrorProcessing.getExternalUserId()
    R.EB.EXTERNAL.USER = EB.ARC.ExternalUser.CacheRead(tmp.EB.EXTERNAL$USER.ID, EB.USER.ERR) ;* Read external user details from cache file
    EB.ErrorProcessing.setExternalUserId(tmp.EB.EXTERNAL$USER.ID)
    
    EXT.ID = EB.ErrorProcessing.getExternalUserId()
    EB.ARC.ExternalUserLock(EXT.ID, R.EB.EXTERNAL.USER, "", "", "")
    INS YSYSDATE BEFORE R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuDateLastUse,CHANNEL.POSITION,1>    ;* Insert system date in current channel Date Last Use field
    INS EB.EXTERNAL.HHMM  BEFORE R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuTimeLastUse,CHANNEL.POSITION,1>     ;* Insert Time in Time Last Use of current channel
    INS "" BEFORE R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuUseDuration,CHANNEL.POSITION,1> ;* Insert null for Use Duration during SIGN.ON
    IF R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuStatus,CHANNEL.POSITION,1> EQ 'INITIATED' THEN
        R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuStatus,CHANNEL.POSITION,1> = 'ACTIVE'
    END
    DEL R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuTimeLastUse,CHANNEL.POSITION,6>          ;* Last 5 subvalue sets are maintained
    DEL R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuDateLastUse,CHANNEL.POSITION,6>
    DEL R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuUseDuration,CHANNEL.POSITION,6> ;* Delete values in subvalue set greater than 5

    WRITE R.EB.EXTERNAL.USER TO F.EB.EXTERNAL.USER, EXT.ID     ;* Write the External user record.

RETURN
END
