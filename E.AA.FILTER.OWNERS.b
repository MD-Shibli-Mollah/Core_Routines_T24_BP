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
* <Rating>-60</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.FILTER.OWNERS
*
* Subroutine Type : ENQUIRY routine
* Attached to     : ENQUIRY ACCOUNT.DETAILS.ARR.SCV
* Attached as     : CONVERSION
* Primary Purpose : Filter out the Primary owner and return only the Joint holders
*                   and update it in R.RECORD ENQUIRY.COMMON variable...
*
* Incoming:
* ---------
*
*
* Outgoing:
* ---------
*
*
* Error Variables:
* ----------------
*
*
*-----------------------------------------------------------------------------------
* Modification History:
*
* 14 NOV 2013 - Sathish PS
*               New Development
*
* 12/08/15 - Task : 1555096
*            Defect : 1550854
*            OWNER is not a valid field in AA.ARRANGEMENT record.
*
*-----------------------------------------------------------------------------------
    $USING AA.Framework
    $USING EB.Reports

    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB CHECK.PRELIM.CONDITIONS
    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

    RETURN          ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:

*    LOCATE THIS.OWNER IN EB.Reports.getRRecord()<AA.Framework.Arrangement.ArrOwner,1> SETTING THIS.OWNER.IN.ALL.OWNER.POS THEN

*    TMP=EB.Reports.getRRecord()
*    DEL TMP<AA.Framework.Arrangement.ArrOwner,THIS.OWNER.IN.ALL.OWNER.POS>
*    EB.Reports.setRRecord(TMP)

*    END


    RETURN          ;* from PROCESS
*-----------------------------------------------------------------------------------
* <New Subroutines>

* </New Subroutines>
*-----------------------------------------------------------------------------------*
*//////////////////////////////////////////////////////////////////////////////////*
*////////////////P R E  P R O C E S S  S U B R O U T I N E S //////////////////////*
*//////////////////////////////////////////////////////////////////////////////////*
INITIALISE:

    PROCESS.GOAHEAD = 1

    RETURN          ;* From INITIALISE
*-----------------------------------------------------------------------------------
OPEN.FILES:

    RETURN          ;* From OPEN.FILES
*-----------------------------------------------------------------------------------
CHECK.PRELIM.CONDITIONS:
*
* Check for any Pre requisite conditions - like the existence of a record/parameter etc
* if not, set PROCESS.GOAHEAD to 0
*
* When adding more CASEs, remember to assign the number of CASE statements to MAX.LOOPS
*
*
    LOOP.CNT = 1 ; MAX.LOOPS = 2
    LOOP
    WHILE LOOP.CNT LE MAX.LOOPS AND PROCESS.GOAHEAD DO

        BEGIN CASE
            CASE LOOP.CNT EQ 1
                IF EB.Reports.getREnq()<EB.Reports.Enquiry.EnqFileName> NE 'AA.ARRANGEMENT' THEN
                    EB.Reports.setEnqError("EB-ENQ.FILE.NAME.NOT.AA.ARRANGEMENT")
                    PROCESS.GOAHEAD = 0
                END

            CASE LOOP.CNT EQ 2
                LOCATE 'OWNER' IN EB.Reports.getEnqSelection()<2,1> SETTING THIS.OWNER.POS THEN
                THIS.OWNER = EB.Reports.getEnqSelection()<4,THIS.OWNER.POS>
            END ELSE
                PROCESS.GOAHEAD = 0
            END

    END CASE
    LOOP.CNT += 1
    REPEAT

    RETURN          ;* From CHECK.PRELIM.CONDITIONS
*-----------------------------------------------------------------------------------
    END
