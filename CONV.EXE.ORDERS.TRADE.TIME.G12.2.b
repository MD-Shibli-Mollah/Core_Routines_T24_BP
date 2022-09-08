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
    $PACKAGE SC.SctOrderExecution
      SUBROUTINE CONV.EXE.ORDERS.TRADE.TIME.G12.2(ID, REC, FILE)

$INSERT I_COMMON
$INSERT I_EQUATE
*====================================================================
* Moves the value in FIELD.NO.68(SC.ESO.RESERVED.4) 
* to FIELD.NO.51(SC.ESO.TRADE.TIME).
*====================================================================
      OLD.REC = REC
      NEW.REC = REC

      CNT = DCOUNT(OLD.REC<38>,VM)
      FOR I = 1 TO CNT
         NEW.REC<51,I> = OLD.REC<68>         
      NEXT I
      NEW.REC<68> = ''
      REC = NEW.REC
      RETURN
*====================================================================
   END
