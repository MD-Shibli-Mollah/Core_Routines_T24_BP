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
* <Rating>-68</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ST.ModelBank

    SUBROUTINE E.SCV.CUSTOMER.PW.CONV.IMAGE
*-----------------------------------------------------------------------------
*
* Subroutine Type : BUILD Routine
* Attached to     : SCV.CUSTOMER.PW
* Attached as     : Conversion Routine
* Primary Purpose :
*                   Optionally we should also be able to link the photo of the customer (from
*                   IM.DOCUMENT.IMAGE.
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
* 28 OCT 2010 - Sathish PS
*               New Development for RMB1 SI
*
* 27/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
*-----------------------------------------------------------------------------------
    $USING EB.Reports
    $USING EB.DataAccess

    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB CHECK.PRELIM.CONDITIONS

    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

    RETURN          ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:

    CUSTOMER.NO = EB.Reports.getId()

    IF CUSTOMER.NO THEN
        IMAGE.TYPE = EB.Reports.getOData()
        IF IMAGE.TYPE  THEN
            GOSUB GET.IM.DOCUMENT.IMAGE.ID
            EB.Reports.setOData(IM.DI.ID)
        END
    END

    RETURN
*-----------------------------------------------------------------------------------
GET.IM.DOCUMENT.IMAGE.ID:

    EB.DataAccess.Opf(FN.IM.DI,F.IM.DI)
    SEL.CMD = "SELECT ":FN.IM.DI
    SEL.CMD := " WITH IMAGE.TYPE EQ ":IMAGE.TYPE
    SEL.CMD := " AND IMAGE.APPLICATION EQ 'CUSTOMER'"
    SEL.CMD := " AND IMAGE.REFERENCE EQ ":CUSTOMER.NO
    EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,'',NO.SEL,SEL.ERR)
    IF SEL.LIST THEN
        IM.DI.ID = SEL.LIST<1>
    END

    RETURN
*-----------------------------------------------------------------------------------
* <New Subroutines>

* </New Subroutines>
*-----------------------------------------------------------------------------------*
*//////////////////////////////////////////////////////////////////////////////////*
*////////////////P R E  P R O C E S S  S U B R O U T I N E S //////////////////////*
*//////////////////////////////////////////////////////////////////////////////////*
INITIALISE:

    PROCESS.GOAHEAD = 1
    CUSTOMER.NO = ''
    IM.DI.ID = ''

    RETURN          ;* From INITIALISE
*-----------------------------------------------------------------------------------
OPEN.FILES:

    FN.IM.DI = 'F.IM.DOCUMENT.IMAGE' ; F.IM.DI = ''

    RETURN          ;* From OPEN.FILES
*-----------------------------------------------------------------------------------
CHECK.PRELIM.CONDITIONS:
*
    LOOP.CNT = 1 ; MAX.LOOPS = 0
    LOOP
    WHILE LOOP.CNT LE MAX.LOOPS AND PROCESS.GOAHEAD DO

        LOOP.CNT += 1

        BEGIN CASE
            CASE EB.Reports.getEnqError()
                PROCESS.GOAHEAD = 0

            CASE CUSTOMER.NO
                BREAK

        END CASE

    REPEAT

    RETURN          ;* From CHECK.PRELIM.CONDITIONS
*-----------------------------------------------------------------------------------
    END
