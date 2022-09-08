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
* <Rating>-70</Rating>
*-----------------------------------------------------------------------------
	$PACKAGE T5.ModelBank
    SUBROUTINE TCIB.SC.PRICE.CHANGE.BLD.RTN(ENQ.DATA)
*-----------------------------------------------------------------------------
*<doc>
* It is copy of TCIB.SC.PRICE.CHANGE.BLD.RTN core routine by using TCIB WEALTH.
* @author jayaramank@temenos.com
* @stereotype Application
* INCOMING PARAMETER  - @Id which is security number.
* OUTGOING PARAMETER  - ENQ.DATA
* </doc>
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------
* 17/02/2014 - Enhancement (641974)
*
* 25/07/14 - Defect_1040024/Task_1040357
*            TCIB Wealth - Graph details are not displayed correctly in ‘Market Watch List’.
*            added new case for short name with EQ condition.
*
* 14/07/15 - Enhancement 1326996 / Task 1399917
*			 Incorporation of T components
*-------------------------------------------------------------------------------
	
	$USING EB.Reports
    $USING EB.SystemTables
	$USING EB.Utility	
	
    $INSERT I_DAS.SECURITY.MASTER
    $INSERT I_DAS.COMMON
	
	
    GOSUB INITILIZE
    GOSUB PROCESS
    RETURN
*---------------------------------------------------------------------------------------------------------
INITILIZE:
**********

    RETURN
*---------------------------------------------------------------------------------------------------------
PROCESS:
********
    LOCATE "DATE.CHANGE" IN ENQ.DATA<2,1> SETTING FROM.DATE.POS THEN  ;* To get the Selection field value
        FROM.DATE = ENQ.DATA<4,FROM.DATE.POS>     ;*get the Date Range value

        DEL ENQ.DATA<2,FROM.DATE.POS>   ;* Delete the existing Enquiry selection.
        DEL ENQ.DATA<3,FROM.DATE.POS>   ;* Delete the existing selection operator
        DEL ENQ.DATA<4,FROM.DATE.POS>   ;* Delete the selection field value
    END
    LOCATE "SECURITY.NO" IN ENQ.DATA<2,1> SETTING SECURITY.NO.POS THEN          ;* To get the Selection field value
        SECURITY.VALUE = ENQ.DATA<4,SECURITY.NO.POS>        ;* get the Security No value

        DEL ENQ.DATA<2,SECURITY.NO.POS> ;* Delete the existing Enquiry selection.
        DEL ENQ.DATA<3,SECURITY.NO.POS> ;* Delete the existing selection operator
        DEL ENQ.DATA<4,SECURITY.NO.POS> ;* Delete the selection field value
    END

    IF FROM.DATE NE '' THEN
        GOSUB PROCESS.DATE.RANGE
    END

    IF SECURITY.VALUE NE '' THEN
        GOSUB PROCESS.SECURITY.NO
    END

    RETURN
*----------------------------------------------------------------------------------------------------------
PROCESS.DATE.RANGE:
********************
* Get the from date and pass it to the enquiry selection.

    INDATE = EB.SystemTables.getToday()
    SIGN = '-'
    DISPLACEMENT = FROM.DATE

    EB.Utility.CalendarDay(INDATE,SIGN,DISPLACEMENT)   ;* get the From date
    FROM.DATE = DISPLACEMENT : ' ' : EB.SystemTables.getToday()        ;* Passing those values to enquiry selection.

    ENQ.DATA<2,FROM.DATE.POS> = "DATE.CHANGE"
    ENQ.DATA<3,FROM.DATE.POS> = 'RG'
    ENQ.DATA<4,FROM.DATE.POS> = FROM.DATE

    RETURN
*--------------------------------------------------------------------------------------------------------------
PROCESS.SECURITY.NO:
********************
* Get the Security Master records based on the Security No.

    THE.ARGS = SECURITY.VALUE ;* Security No Passed to DAS routine.
    SECURITY.MASTER.LIST = dasSecurityMasterSecurityShortNametcib     ;* Passing this arguments to DAS routine.
     CALL DAS('SECURITY.MASTER',SECURITY.MASTER.LIST,THE.ARGS,'')      ;* DAS routine call

    IF SECURITY.MASTER.LIST NE '' THEN  ;* DAS routine to return the Security Master list
        CHANGE @FM TO @SM IN SECURITY.MASTER.LIST
        ENQ.DATA<2,SECURITY.NO.POS> = "SECURITY.NO"
        ENQ.DATA<3,SECURITY.NO.POS>  = 'LK'
        ENQ.DATA<4,SECURITY.NO.POS>  = SECURITY.MASTER.LIST
    END ELSE
        EB.Reports.setEnqError('SC-INVALID.ID')
    END
    RETURN
*---------------------------------------------------------------------------------------------------------------
END
