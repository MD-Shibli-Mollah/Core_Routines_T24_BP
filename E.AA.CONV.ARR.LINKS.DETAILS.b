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
* <Rating>-27</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.CONV.ARR.LINKS.DETAILS
*-----------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Program Description </desc>
**
* 
* Conversion Routine in Enquiry> AA.DETAILS.ARRANGEMENT.BUNDLE
* Retail account which is part of a bundle is delinked from the bundle arrangement and linked
*
* @uses I_ENQUIRY.COMMON I_F.AA.ARRANGEMENT
* @package AA.ModelBank
* @stereotype subroutine
* @author ssudhakar@temenos.com
*
**

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>History of amendments </desc>
* 23/03/2016 - Defect : 1670676
*              Task   : 1673545

*** </region>

*-----------------------------------------------------------------------------
*** <region name= Inserts>
***
   
    $USING EB.Reports
    $USING AA.Framework
    
*** </region>

*-----------------------------------------------------------------------------
*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>
    GOSUB INITIALISE
    GOSUB MAIN.PROCESS

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Initialise>
*** <desc>Initialise local variables and file variables</desc>
INITIALISE:
*----------

    ARR.ID = EB.Reports.getOData()
    R.ARRANGEMENT = EB.Reports.getRRecord()

    ARR.LINK.TYPE = ""
    ARR.LINK.ARRANGEMENT = ""
    LINK.DETAILS = ""

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main Process>
*** <desc>Main control logic in the sub-routine</desc>
MAIN.PROCESS:
*------------

    EXIT.FLAG = '0'
    LINK.DATE.CNT = DCOUNT(R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkDate>,@VM)

* When multiple updations happen on the same date the latest is on the top position inside that date set.
* Other dates are in ascending order.
* Please be careful while changing the below logic and make sure it satisfies all cases.
    LOOP
    WHILE LINK.DATE.CNT GE "1" AND NOT(EXIT.FLAG)

        IF R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkDate,LINK.DATE.CNT-1> EQ R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkDate,LINK.DATE.CNT> THEN
            ARR.LINK.TYPE = R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkType,LINK.DATE.CNT-1>
            ARR.LINK.ARRANGEMENT = R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkArrangement,LINK.DATE.CNT-1>
        END ELSE
            ARR.LINK.TYPE = R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkType,LINK.DATE.CNT>
            ARR.LINK.ARRANGEMENT = R.ARRANGEMENT<AA.Framework.Arrangement.ArrLinkArrangement,LINK.DATE.CNT>
            EXIT.FLAG = '1'
        END
        LINK.DATE.CNT--

    REPEAT
    
    LINK.DETAILS = ARR.LINK.TYPE:"*":ARR.LINK.ARRANGEMENT
    EB.Reports.setOData(LINK.DETAILS)

    RETURN
*** </region>
*-----------------------------------------------------------------------------

END
