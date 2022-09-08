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
* <Rating>-36</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.GET.NEXT.DUE.DATE

*** <region name= Synopsis of the Routine>
***
* Enquiry routine to return the next due dae or the next payment.date
*
*** </region>

*** <region name= Modification History>
***
* 14/07/08 - EN_10003753
*            Ref : SAR-2008-06-02-0002
*            Enquiry routine to return the next due date
*
*=======================================================================================================================
*
*                                                                    [B
*=======================================================================================================================
*** </region>

*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>

    $USING AA.PaymentSchedule
    $USING EB.Reports


*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main Process>
*** <desc> Main processing logic </desc>

    GOSUB INITIALISE          ;* Initialise Variables here
    GOSUB GET.NEXT.DUE.DATE   ;* Get the next due date or the payment date

    RETURN
*** </region>
*------------------------------------------------------------------------------------------------------------------------------

*** <region name= Initialise>
*** <desc> Initialise variables </desc>
INITIALISE:

    ARRANGEMENT.ID = EB.Reports.getOData()

    RETURN
*** </region>
*------------------------------------------------------------------------------------------------------------------------------

*** <region name= Get next due date>
*** <desc> Get the next due or payment date </desc>
GET.NEXT.DUE.DATE:

    AA.PaymentSchedule.GetNextDueDate(ARRANGEMENT.ID, NEXT.DUE.DATE)

    EB.Reports.setOData(NEXT.DUE.DATE)

    RETURN
*** </region>
*------------------------------------------------------

    END
