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
* <Rating>-40</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE T2.ModelBank
    SUBROUTINE NOFILE.TCIB.DISPL.EEU.INFO(OUT_ARRAY)
*-----------------------------------------------------------------------
* Attached to : STANDARD.SELECTION record NOFILE.TCIB.DISPL.EEU.INFO
* Incoming    : NA
* Outgoing    : External User Details
*---------------------------------------------------------------------------------------------
* Description:
* Authorised/unauthorised External User Details
*---------------------------------------------------------------------------------------------
* Modification History :
* 01/07/14 - Enhancement 1001222/Task 1001223
*            TCIB : User management enhancements and externalisation
*
* 14/07/15 - Enhancement 1326996 / Task 1399946
*			 Incorporation of T components
*-----------------------------------------------------------------------

    $USING EB.ARC
    $USING EB.Reports
*
    GOSUB INITIALIZE
    GOSUB MAIN.PROCESS
*
    RETURN
*-------------------------------------------------------------------------------------------------
INITIALIZE:
* Initialsie and Open Required Files
    OUT_ARRAY = ""
    R.EXTERNAL.USER  = ""
    ERR.EXTERNAL.USER = ""

*
    RETURN
*-------------------------------------------------------------------------------------------------
MAIN.PROCESS:
* To get External User Details
    LOCATE "ID.USER" IN EB.Reports.getDFields()<1> SETTING ENQ.POS THEN
    ID_USER = EB.Reports.getDRangeAndValue()<ENQ.POS>      ;* To get External User Id
    R.EXTERNAL.USER = EB.ARC.ExternalUser.Read(ID_USER,ERR.EXTERNAL.USER)     ;* To read external user record
    IF R.EXTERNAL.USER EQ "" OR ERR.EXTERNAL.USER THEN
        R.EXTERNAL.USER  = ""
        ERR.EXTERNAL.USER = ""
        R.EXTERNAL.USER = EB.ARC.ExternalUser.ReadNau(ID_USER,ERR.EXTERNAL.USER) ;* To get external user details
    END
    IF R.EXTERNAL.USER NE "" THEN
        OUT_ARRAY<-1> = R.EXTERNAL.USER<EB.ARC.ExternalUser.XuCustomer> ;* To get external user customer Id
        OUT_ARRAY<-1> = R.EXTERNAL.USER<EB.ARC.ExternalUser.XuStatus>   ;* To get external user status
        OUT_ARRAY<-1> = R.EXTERNAL.USER<EB.ARC.ExternalUser.XuName>     ;* To get external user name
        OUT_ARRAY<-1> = R.EXTERNAL.USER<EB.ARC.ExternalUser.XuArrangement>        ;* To get external user arrangement
        OUT_ARRAY<-1> = R.EXTERNAL.USER<EB.ARC.ExternalUser.XuAllowedCustomer>   ;* To get allowed customer
        OUT_ARRAY<-1> = R.EXTERNAL.USER<EB.ARC.ExternalUser.XuChannelPermission> ;* To get Channel Permission record id
        OUT_ARRAY= CHANGE(OUT_ARRAY, @FM, "*")
    END ELSE
        EB.Reports.setEnqError("EB-EXTERNAL.USER.NOT.FOUND")
    END
*
    RETURN
*----------------------------------------------------------------------------------------------
*
    END
