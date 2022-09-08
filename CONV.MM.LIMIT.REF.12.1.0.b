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

* Version 4 25/10/00  GLOBUS Release No. 200602 09/01/06
*-----------------------------------------------------------------------------
* <Rating>-21</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE MM.Contract
      SUBROUTINE CONV.MM.LIMIT.REF.12.1.0
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.MM.MONEY.MARKET
*
** 13/10/93 - GB9301430
**            Fids are not converted correctly
*
      YFILE = "F.MM.MONEY.MARKET"
      GOSUB CONVERT.MM.FILE
*
      YFILE = "F.MM.MONEY.MARKET$NAU"
      GOSUB CONVERT.MM.FILE
*
      RETURN
*
*------------------------------------------------------------------------
CONVERT.MM.FILE:
*==============
*
      CRT @(5,5):"Selecting ":YFILE
      MM.FILE = ""
      CALL OPF(YFILE,MM.FILE)
*
      SEL.CMD = "SELECT ":YFILE:" WITH LIMIT.REFERENCE = ''"
      ID.LIST = ""
      CALL EB.READLIST(SEL.CMD,ID.LIST,"","","")
      LOOP
         REMOVE YID FROM ID.LIST SETTING YD
      WHILE YID:YD
         CRT @(5,6):YID
         READ YREC FROM MM.FILE,YID THEN
            BEGIN CASE
               CASE YREC<MM.CATEGORY> GE "21040" AND YREC<MM.CATEGORY> LE "21044"
                  YREC<MM.LIMIT.REFERENCE> = "9800.01"
                  WRITE YREC TO MM.FILE,YID
               CASE YREC<MM.CATEGORY> GE "21001" AND YREC<MM.CATEGORY> LT "21050"
                  YREC<MM.LIMIT.REFERENCE> = "9900.01"
                  WRITE YREC TO MM.FILE,YID
               CASE YREC<MM.CATEGORY> GE "21085" AND YREC<MM.CATEGORY> LE "21089"
                  YREC<MM.LIMIT.REFERENCE> = "9700.01"
                  WRITE YREC TO MM.FILE,YID
            END CASE
         END
      REPEAT
*
      RETURN
*
   END
