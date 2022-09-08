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
* <Rating>-66</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CR.ModelBank
    SUBROUTINE E.SCV.CUST.ENGAGEMENT.PW.CONV.IMAGE
*
* Subroutine Type : BUILD Routine
* Attached to     : CR.CUSTOMER.ENGAGEMENT
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
* 12 Feb 2015 - mdhamo
*               New Development for CRM SI
*
*-----------------------------------------------------------------------------------

    $USING CR.Analytical
    $USING EB.DataAccess
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

    CUSTOMER.NO = EB.Reports.getRRecord()<CR.Analytical.CustEngagement.CetCustomer>

    IF CUSTOMER.NO THEN
        IMAGE.TYPE = 'PHOTOS'
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

        BEGIN CASE
            CASE LOOP.CNT EQ 1

        END CASE
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
