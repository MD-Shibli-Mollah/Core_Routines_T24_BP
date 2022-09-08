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
* <Rating>260</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctPriceTypeUpdateAndProcessing
      SUBROUTINE CONV.SC.PRICE.CHANGE.G12.0

************************************************************************
* 21/10/02 - BG_100002439
*            This Subroutine is written with the intention to update
*            SC.PRICE.CHANGE.CON separately as the conversion at HSJ
*            ran for about 35 hours as they had 3 million records
*
**********************************************************************
*
$INSERT I_EQUATE
$INSERT I_COMMON
$INSERT I_F.SC.PRICE.CHANGE
$INSERT I_F.SC.PRICE.CHANGE.CON

* This SUBROUTINE is written to populate the file SC.PRICE.CHANGE.CON
*
      GOSUB OPEN.FILES

      GOSUB PROCESS

      RETURN

************************************************************************

OPEN.FILES:

      FN.SC.PRICE.CHANGE = 'F.SC.PRICE.CHANGE'
      FV.SC.PRICE.CHANGE = ''
      CALL OPF(FN.SC.PRICE.CHANGE,FV.SC.PRICE.CHANGE)

      FN.SC.PRICE.CHANGE.CON = 'F.SC.PRICE.CHANGE.CON'
      FV.SC.PRICE.CHANGE.CON = ''
      CALL OPF(FN.SC.PRICE.CHANGE.CON,FV.SC.PRICE.CHANGE.CON)

      RETURN
*
**********************************************************************
PROCESS:
**********************************************************************

      LIST = ''
      CODE = ''
      ER = ''
      POS = ''
      R.SC.PRICE.CHANGE = ''
      R.SC.PRICE.CHANGE.CON = ''
      SELECT FV.SC.PRICE.CHANGE
      END.OF.LIST = 0

      LOOP
         READNEXT CODE ELSE END.OF.LIST = 1
      UNTIL END.OF.LIST


         READ R.SC.PRICE.CHANGE FROM FV.SC.PRICE.CHANGE,CODE THEN

            ONLY.SEC = FIELD(CODE,'.',1)
            DATE.CHANGED = R.SC.PRICE.CHANGE<2>
            ONLY.YR = DATE.CHANGED[1,4]
            PRICE.CON.ID = ONLY.SEC : '.' : ONLY.YR

            READ R.SC.PRICE.CHANGE.CON FROM FV.SC.PRICE.CHANGE.CON,PRICE.CON.ID THEN

               LOCATE DATE.CHANGED IN R.SC.PRICE.CHANGE.CON<1> BY "AR" SETTING POS THEN
                  GOTO NEXT.RECORD
               END ELSE
                  R.SC.PRICE.CHANGE.CON := @VM :DATE.CHANGED
                  WRITE R.SC.PRICE.CHANGE.CON TO FV.SC.PRICE.CHANGE.CON,PRICE.CON.ID
               END
            END ELSE
               R.SC.PRICE.CHANGE.CON = DATE.CHANGED
               WRITE R.SC.PRICE.CHANGE.CON TO FV.SC.PRICE.CHANGE.CON,PRICE.CON.ID
            END
         END

NEXT.RECORD:
      REPEAT

      RETURN


FATAL.ERROR:

      TEXT = E
      CALL FATAL.ERROR('CONV.SC.PRICE.CHANGE.G12.0')

   END
