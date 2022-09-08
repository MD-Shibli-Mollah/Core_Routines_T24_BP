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

* Version n dd/mm/yy  GLOBUS Release No. R05.007 30/05/06
*-----------------------------------------------------------------------------
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
   SUBROUTINE CONV.EB.ENQUIRY.GRAPH.R08
*
****************************************************************************
* Remove the following EB.ENQUIRY.GRAPH records if AM not installed.
*
* GB.VAL.CHART.BAR
* GB.VAL.CHART.LINE
*
****************************************************************************
* Modifications
*
****************************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
*
* This conversion will remove the records GB.VAL.CHART.BAR and GB.VAL.CHART.LINE
* from EB.ENQUIRY.GRAPH if AM product is not installed.
*

   GOSUB INITIALISE

   IF NOT(AM.INSTALLED) THEN


      ID.LIST = "GB.VAL.CHART.BAR":FM:"GB.VAL.CHART.LINE"

      LOOP
         REMOVE DEL.ID FROM ID.LIST SETTING EXISTS
      WHILE DEL.ID : EXISTS DO

         READ R.TEST FROM F.EB.ENQUIRY.GRAPH, DEL.ID THEN
            DELETE F.EB.ENQUIRY.GRAPH, DEL.ID
         END
                  
         READ R.TEST FROM F.EB.ENQUIRY.GRAPH$NAU, DEL.ID THEN
            DELETE F.EB.ENQUIRY.GRAPH$NAU, DEL.ID
         END

      REPEAT

   END

   RETURN

*-----------------------------------------------------------------------------

INITIALISE:

* Initialise parameters

* Find out if AM is installed or not

   AM.INSTALLED = @FALSE
   PRODUCT.CODE = 'AM'
   VALID.PRODUCT = ''
   PRODUCT.INSTALLED = ''
   COMPANY.HAS.PRODUCT = ''
   ERROR.TEXT = ''

* Validate product

   CALL EB.VAL.PRODUCT(PRODUCT.CODE, VALID.PRODUCT, PRODUCT.INSTALLED, COMPANY.HAS.PRODUCT, ERROR.TEXT)

   IF VALID.PRODUCT AND COMPANY.HAS.PRODUCT AND PRODUCT.INSTALLED THEN
      AM.INSTALLED = @TRUE
   END

   IF NOT(AM.INSTALLED) THEN

      FN.EB.ENQUIRY.GRAPH = 'F.EB.ENQUIRY.GRAPH'
      F.EB.ENQUIRY.GRAPH = ''
      CALL OPF(FN.EB.ENQUIRY.GRAPH,F.EB.ENQUIRY.GRAPH)
      
      FN.EB.ENQUIRY.GRAPH$NAU = 'F.EB.ENQUIRY.GRAPH$NAU'
      F.EB.ENQUIRY.GRAPH$NAU = ''
      CALL OPF(FN.EB.ENQUIRY.GRAPH$NAU,F.EB.ENQUIRY.GRAPH$NAU)
      
   END

   RETURN

*-----------------------------------------------------------------------------
   END
