* @ValidationCode : MjoxNDY5NjMwNzYwOkNwMTI1MjoxNTg2NzY2MjM4OTQ0Om5kaXZ5YToyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDAyLjIwMjAwMTE3LTIwMjY6MTY6MTY=
* @ValidationInfo : Timestamp         : 13 Apr 2020 13:53:58
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ndivya
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 16/16 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-23</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.GET.LINKED.RATE
*-------------------------------------
*
*** <region name= Description>
*** <desc>Task of the sub-routine</desc>
*
* This is a enquiry conversion routine that will
* return the linked rate for the arrangement
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Arguments>
*** <desc>Input and Output arguments</desc>
* Arguements
*
* Input
* Output
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Amendment history>
*** <desc>Modifications done to the sub-routine</desc>
* Modification history
*
* 31/03/16 - Task : 1652750
*            Enhancement : 1623262
*            Enquiry Conversion routine to return linked interest rate
*
*03/03/2020 - Task   : 3620349
*             Defect : 31613847
*             Pass the Enquiry flag to GetLinkedRate to fetch the interest rate for the expired,pending closure,close contracts
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>Inserts and common variables</desc>

    $USING AA.Interest
    $USING EB.DataAccess
    $USING EB.Reports
    $USING AA.Framework
    
*----------------------------------------
*

    GOSUB INITIALISE
    GOSUB PROCESS
*
RETURN
*----------------------------------------
INITIALISE:
*-----------
*
    ArrangementId = EB.Reports.getOData()['~',1,1] ;* Arrangement ID
    Property = EB.Reports.getOData()['~',2,1] ;* Property belongs to the arrangement
    RArrangement = ""       ;* Initalise the variables
    Err          = ""
   
RETURN
*------------------------------------------------------------------
PROCESS:
*
** For Pending closure, expired, close contracts the Curbalance amount will be zero. So, while calling the GetLinkedInterestRate routine it would return the rate 0 for
** the parent interest, since it will check the source balance of the interest. To avoid the wrong display of interest rate pass the enquiry flag to the Getlinked Rate for the
** Pending closure, expired, close contracts and get the Interest rate from GetLinked rate
    AA.Framework.GetArrangement(ArrangementId,RArrangement,Err)     ;* Arrangement record to get the status
    ArrStatus = RArrangement<AA.Framework.Arrangement.ArrArrStatus> ;* Get the Arrangement Status
    
    IF ArrStatus MATCHES "EXPIRED":@VM:"PENDING.CLOSURE":@VM:"CLOSE" THEN
        ArrangementId<2> = "1" ;* Pass the enquiry flag with Arrangement id
    END
    AA.Interest.GetLinkedInterestRate(ArrangementId, Property, '', Rate, RetError) ;* API to find the linked interest rate

    EB.Reports.setOData(Rate) ;* Linked rate returned to O.DATA
*
RETURN
*----------------------------------------
