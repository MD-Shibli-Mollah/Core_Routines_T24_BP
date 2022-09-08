* @ValidationCode : MjotMTU2MDYxNDk0MTpDcDEyNTI6MTQ5OTc1MjkyNDYzMjpjaGphaG5hdmk6MzowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTcwNy4yMDE3MDYyMy0wMDM1OjU2OjUz
* @ValidationInfo : Timestamp         : 11 Jul 2017 11:32:04
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : chjahnavi
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 53/56 (94.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201707.20170623-0035
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>-79</Rating>
*-----------------------------------------------------------------------------
$PACKAGE T2.ModelBank
SUBROUTINE TCIB.LAST.LOGIN.UPDATE(INREQUEST)
*----------------------------------------------------------------------------
* Attached to      : OFS.SOURCE>TCIB, as Message Pre routine (it will triggered before run the enquiry)
* Return Parameter : Ofs Request
*----------------------------------------------------------------------------------------------------
* Description:
* When logged in to TCIB, Time and date updated based on the first request in TCIB of External user.
*----------------------------------------------------------------------------------------------------
* Modification History :
* 10/11/14 - Defect : 879630 / Task : 1127320
*            Last login details are updated based on the first request in TCIB.
*
* 19/08/15 - Defect: 1433538 / Task: 1443079
*            DATE.LAST.USE AND TIME.LAST.USE is updating properly in IB.USER record.
*
* 27/08/15 - Defect 1451158 / Task 1451333
*            Initialise R.EB.EXTERNAL.USER variable
*
* 14/07/15 - Enhancement 1326996 / Task 1399946
*            Incorporation of T components
*
* 31/12/15 - Defect 1584279 / Task 1584852
*            Last login details are not displayed after logging in into the system
*
* 16/11/16 - Defect 1926211 / Task 1926590
*            Last login details are not updated for TCIB 2
*
* 26/06/17 - Enhancement 2075331 / Task 2186800
*            Support multiple arrangements for an external user
*----------------------------------------------------------------------------------------------------
    $USING EB.ARC
    $USING EB.Utility
    $USING EB.ErrorProcessing
    $USING EB.DataAccess
    $USING EB.Browser

    ENQ.NAME = FIELD(INREQUEST, ',',4)  ;* get the enquiry name
    IF ENQ.NAME NE "TCIB.LOGIN.DETAILS" AND ENQ.NAME NE "TC.NOF.USER.RIGHTS" THEN      ;* Check whether its first request
        RETURN      ;* if not a first request,Time last use writes in External user does not happen .
    END

    GOSUB INITIALIZE          ;* Initialize the variables
    GOSUB OPEN.FILES          ;* Open the required files
    GOSUB MAIN.PROCESS

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
    
    CH.POS = ''
    tmp.EB.EXTERNAL$USER.ID = EB.ErrorProcessing.getExternalUserId()
    R.EB.EXTERNAL.USER = EB.ARC.ExternalUser.CacheRead(tmp.EB.EXTERNAL$USER.ID, EB.USER.ERR) ;* Read external user details from cache file
    EB.ErrorProcessing.setExternalUserId(tmp.EB.EXTERNAL$USER.ID)
    
    GOSUB GET.CHANNEL.POSITION ;* Get exact channel position using the arrangement id to update last login details
    EXT.ID = EB.ErrorProcessing.getExternalUserId()
    EB.ARC.ExternalUserLock(EXT.ID, R.EB.EXTERNAL.USER, "", "", "")
    INS YSYSDATE BEFORE R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuDateLastUse,CH.POS,1>    ;* Insert system date in current channel Date Last Use field
    INS EB.EXTERNAL.HHMM  BEFORE R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuTimeLastUse,CH.POS,1>     ;* Insert Time in Time Last Use of current channel
    INS "" BEFORE R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuUseDuration,CH.POS,1> ;* Insert null for Use Duration during SIGN.ON
    DEL R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuTimeLastUse,CH.POS,6>          ;* Last 5 subvalue sets are maintained
    DEL R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuDateLastUse,CH.POS,6>
    DEL R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuUseDuration,CH.POS,6> ;* Delete values in subvalue set greater than 5

    WRITE R.EB.EXTERNAL.USER TO F.EB.EXTERNAL.USER, EXT.ID     ;* Write the External user record.

RETURN
*---------------------------------------------------------------------------------------------------------------------------
*** <desc> Get the current channel position using the arrangement provided through request</desc>
GET.CHANNEL.POSITION:
********************
* Get the User variables to file - e.g. the ones starting "CURRENT."
    User.variableNames = ''
    User.variableValues = ''
    EB.Browser.SystemGetuservariables( User.variableNames, User.variableValues )

* Get arrangement id from EXT variables for external user and locate exact channel position
    IF EB.ErrorProcessing.getExternalUserId() THEN
        LOCATE 'EXT.ARRANGEMENT' IN User.variableNames SETTING ARR.POS THEN ;* Locate arrangement id in user variables and retrieve the value
            ARRANGEMENT.ID = User.variableValues<ARR.POS>
        END

        NO.OF.CHS = DCOUNT(R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuChannel>,@VM)
        FOR CH.POS = 1 TO NO.OF.CHS
            IF (CURR.CHANNEL.TYPE EQ R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuChannel,CH.POS>) AND (ARRANGEMENT.ID EQ R.EB.EXTERNAL.USER<EB.ARC.ExternalUser.XuArrangement,CH.POS>) THEN  ;* Check for the channel and arrangement position and exit from the loop
                EXIT
            END
        NEXT CH.POS
    END
RETURN
*---------------------------------------------------------------------------------------------------------------------------
END
