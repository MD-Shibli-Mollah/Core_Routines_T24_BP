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
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PM.Config
      SUBROUTINE CONV.PM.PC.PARAM.G14(ID,REC,FILE)
*******************************************************

* This Subroutine empties the contents of the field TRAN.CODE
* START and moves this to the field ACC.MVMT.CHAR.
*
* 03/04/03 - BG_100003980
*              New Conversion Routine written to be triggered
*              When Upgradation Happens
*
*******************************************************
$INSERT I_COMMON
$INSERT I_EQUATE


      PM.PC.PAR.POSN.TYPE = 1
      PM.PC.PAR.TR.CD.START = 2
      PM.PC.PAR.ACC.MVMT.CHAR = 4

      POSN.TYPES = REC<PM.PC.PAR.POSN.TYPE>
      NO.OF.POS = DCOUNT(POSN.TYPES,VM)

      FOR I = 1 TO NO.OF.POS

         REC<PM.PC.PAR.ACC.MVMT.CHAR,I> = REC<PM.PC.PAR.TR.CD.START,I>
         REC<PM.PC.PAR.TR.CD.START,I> = ''

      NEXT I

      RETURN
   END
