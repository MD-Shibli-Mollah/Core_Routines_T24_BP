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

* Version 3 21/09/99  GLOBUS Release No. 200512 09/12/05
*-----------------------------------------------------------------------------
* <Rating>-8</Rating>
*-----------------------------------------------------------------------------
      $PACKAGE SC.ScoReports
      SUBROUTINE E.SC.UNAUTH.FLAG
*
************************************************************
*
* SUBROUTINE TO DETERMINE WHETHER THE RECORD
* DISPLAYED HAS BEEN AUTHORISED OR NOT.
* IF UNAUTHORISED THEN THE LITERAL 'U' IS RETURNED
* IN O.DATA
* 'D' IF DELETED
* 'R' IF REVERSED
* 23-07-2015 - 1415959
*             Incorporation of components
************************************************************
*
$USING SC.ScoSecurityPositionUpdate
$USING EB.Reports

*
*
      AUTH.REC = ''
*
      BEGIN CASE
         CASE EB.Reports.getRRecord()<SC.ScoSecurityPositionUpdate.SecurityTrans.SctDateUpdated> = "" AND EB.Reports.getRRecord()<SC.ScoSecurityPositionUpdate.SecurityTrans.SctReversalDate> = ""
            AUTH.REC = "U"
         CASE EB.Reports.getRRecord()<SC.ScoSecurityPositionUpdate.SecurityTrans.SctDateUpdated> = "" AND EB.Reports.getRRecord()<SC.ScoSecurityPositionUpdate.SecurityTrans.SctReversalDate> NE ""
            AUTH.REC = "D"
         CASE EB.Reports.getRRecord()<SC.ScoSecurityPositionUpdate.SecurityTrans.SctDateUpdated> NE "" AND EB.Reports.getRRecord()<SC.ScoSecurityPositionUpdate.SecurityTrans.SctReversalDate> NE ""
            AUTH.REC = "R"
      END CASE
*
      EB.Reports.setOData(AUTH.REC)
*
      RETURN
*
   END
