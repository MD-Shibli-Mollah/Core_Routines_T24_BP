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

* Version 1 31/05/00  GLOBUS Release No. G13.1.00 31/10/02
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.Config
      SUBROUTINE CONV.LC.PARAMETERS.G10.2.04(PARAM.ID, R.LCP, F.LCP)

      EQU LC.PARA.LC.CLASS.TYPE TO 68
      EQU LC.PARA.EB.CLASS.NO TO 69
      EQU LC.PARA.SHARE.PARNT.LIM TO 72
      EQU LC.PARA.EXCH.PRFT.CAT TO 72

      R.LCP<LC.PARA.LC.CLASS.TYPE, -1> = "CUST.DRAW"
      R.LCP<LC.PARA.EB.CLASS.NO, -1> = "CUSTDRAWDOWN"
      R.LCP<LC.PARA.LC.CLASS.TYPE, -1> = "CUST.CHEQUE"
      R.LCP<LC.PARA.EB.CLASS.NO, -1> = "CUSTCHEQUE"
      R.LCP<LC.PARA.LC.CLASS.TYPE, -1> = "BANK.DRAFT"
      R.LCP<LC.PARA.EB.CLASS.NO, -1> = "BANKDRAFT"
      RETURN
   END
