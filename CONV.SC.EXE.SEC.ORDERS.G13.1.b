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
* <Rating>100</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctOrderExecution
      SUBROUTINE CONV.SC.EXE.SEC.ORDERS.G13.1(YID,YREC,YFILE)
*
* This is the Conversion routine for the change of Narrative
* field as the customer multi value set
* the field Narrative have been moved from 62 to 38
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.SC.EXE.SEC.ORDERS
*
      YVAR = ''
      OPEN YFILE TO YVAR ELSE YVAR = ''
*
      OLD.REC = '' ; YERR = ''
      CALL F.READ(YFILE,YID,OLD.REC,YVAR,YERR)
      YREC<38> = OLD.REC<62>
      RETURN
   END
