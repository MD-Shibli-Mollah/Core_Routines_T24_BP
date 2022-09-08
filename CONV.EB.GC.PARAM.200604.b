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

* Version 3 02/06/00  GLOBUS Release No. G11.0.00 29/06/00
*-----------------------------------------------------------------------------
* <Rating>-10</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.Constraints
      SUBROUTINE CONV.EB.GC.PARAM.200604(ID,R.RECORD, FN.FILE)
*-----------------------------------------------------------------------------
* Program Description
* Conversion inserts a new EB.GCP.PRECEDENCE.USER value of 1 and increments
* all the existing precedences. Making user the highest precedence.
*-----------------------------------------------------------------------------
* Modification History :
*
* 13/01/2006 - EN_10002736
*              Created.
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
*-----------------------------------------------------------------------------

      GOSUB INITIALISE
      IF R.RECORD<EB.GCP.PRECEDENCE.USER> EQ '' THEN
         R.RECORD<EB.GCP.PRECEDENCE.USER> = 1
         R.RECORD<EB.GCP.PRECEDENCE.CURR> += 1
         R.RECORD<EB.GCP.PRECEDENCE.ACCT> += 1
         R.RECORD<EB.GCP.PRECEDENCE.PORT> += 1
         R.RECORD<EB.GCP.PRECEDENCE.CUST> += 1
      END
      RETURN

*-----------------------------------------------------------------------------
INITIALISE:
      EB.GCP.PRECEDENCE.USER = 5
      EB.GCP.PRECEDENCE.CURR = 6
      EB.GCP.PRECEDENCE.ACCT = 7
      EB.GCP.PRECEDENCE.PORT = 8 
      EB.GCP.PRECEDENCE.CUST = 9
      RETURN

*-----------------------------------------------------------------------------
*
   END
