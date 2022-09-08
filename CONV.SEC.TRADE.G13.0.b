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

*
*-----------------------------------------------------------------------------
* <Rating>-3</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctTrading
      SUBROUTINE CONV.SEC.TRADE.G13.0(YID,YREC,YFILE)
*
* Conversion record routine to move the file BR.TRADE.TIME from position 116 to
* sub-valued set associated with BR.NO.NOM & BR.PRICE
* This field BR.TRADE.TIME was added for BJB in G12.2 but was added in the
* wrong place. This conversion will correct the bug.
*------------------------------------------------------------------------------
* Modification History:
*
* 25/06/02 - GLOBUS_CI_10002404
*            New Program
*------------------------------------------------------------------------------
$INSERT I_EQUATE
*
* test to see if the new field has been added and is blank
      IF YREC<84> = "" THEN
* count the number of multi-values (brokers) in OLD BR.TRADE.TIME field
         NO.MVS = DCOUNT(YREC<118>,VM)
         FOR MV.NO = 1 TO NO.MVS
* for each BR.NO.NOM sub-value replicate the time from the old field
            NO.SVS = DCOUNT(YREC<82,MV.NO>,SM)
            FOR SV.NO = 1 TO NO.SVS
               YREC<84,MV.NO,SV.NO> = YREC<118,MV.NO>
            NEXT SV.NO

         NEXT MV.NO
* once the field has been moved, set it to null
         YREC<118> = ""
      END

      RETURN
   END
