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
* <Rating>99</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.SystemTables
      SUBROUTINE CONV.FC.MB.FRP
*
* 03/06/03 - EN_10001865
* converts file control FIN level repgen records to FRP for multi book
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.FILE.CONTROL
*
*
      CALL OPF("F.FILE.CONTROL",F.FC)
      SEL.CMD = 'SELECT F.FILE.CONTROL WITH @ID LIKE RGS... AND CLASSIFICATION EQ "FIN"'
      ID.LIST = ""
      CALL EB.READLIST(SEL.CMD,ID.LIST,"","","")
      LOOP
         REMOVE ID FROM ID.LIST SETTING POS
      WHILE ID:POS
         R.FC = ""
         READU R.FC FROM F.FC, ID THEN
            R.FC<EB.FILE.CONTROL.CLASS> = "FRP"
            WRITE R.FC ON F.FC, ID
         END ELSE RELEASE F.FC, ID
      REPEAT
      RETURN
   END
