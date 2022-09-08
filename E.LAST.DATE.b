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

* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-3</Rating>
*-----------------------------------------------------------------------------
      $PACKAGE SC.ScoReports
      SUBROUTINE E.LAST.DATE
*************************************************************************
*
* Return the last date as opposed to all dates
*
* 22/6/15 - 1322379 Task:1336841
*           Incorporation of components
****************
      $USING EB.Reports

      PAY.DATES = EB.Reports.getOData()
      PAY.DATES.COUNT = DCOUNT((PAY.DATES),@VM)
      EB.Reports.setOData(PAY.DATES<1,PAY.DATES.COUNT>)
   END
