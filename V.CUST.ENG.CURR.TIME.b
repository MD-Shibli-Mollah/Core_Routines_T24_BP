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
* <Rating>-4</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CR.ModelBank
    SUBROUTINE V.CUST.ENG.CURR.TIME

*-------------------------------------------------------------------------
* 21/01/15 - Task 1200551
*            Ref : Enhancement 1200539
*            Client Contact Experience
*
* A routine which populates the time in Customer Engagement
*
*-------------------------------------------------------------------------

    $USING CR.Analytical
    $USING EB.SystemTables

    EB.SystemTables.setTimeStamp(TIMEDATE())
    X = EB.SystemTables.getTimeStamp()[1,2]:':':EB.SystemTables.getTimeStamp()[4,2]
    EB.SystemTables.setRNew(CR.Analytical.CustEngagement.CetTimeIn, X)
    END
