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
      SUBROUTINE E.SC.MATDATE

* Enquiry subroutine to convert maturity date
* 23-07-2015 - 1415959
*             Incorporation of components
*************************************************************************


$USING EB.Display
$USING EB.SystemTables
$USING EB.Reports

*************************************************************************

      IF EB.Reports.getOData() = '' ELSE
         EB.SystemTables.setVDisplay(EB.Reports.getOData())
         EB.Display.Msk(11,'D')
         EB.Reports.setOData(EB.SystemTables.getVDisplay())
      END

      RETURN

   END
