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

* Version 2 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>93</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FT.Contract
      SUBROUTINE CONV.FTNO.10.4
*
$INSERT I_COMMON
$INSERT I_EQUATE
*
      F.FTNO = ""
      CALL OPF("F.FTNO",F.FTNO)
      FTNO.ID = "1"
*
      READU YREC FROM F.FTNO , FTNO.ID ELSE YREC = ""
      IF COUNT(YREC,FM) + (YREC NE "") GT 7 THEN   ; * Not yet converted
         YNEW.REC = ""
         YNEW.REC<1> = TODAY
         YNEW.REC<2> = YREC<3>           ; * Savings Accts
         YNEW.REC<3> = 30000             ; * LD settlements
         YNEW.REC<4> = YREC<5>           ; * STO Balances and Payments
         YNEW.REC<5> = YREC<7>-10000     ; * FT in processing
         YNEW.REC<6> = YREC<7>           ; * BGC in mapping
         YNEW.REC<7> = 80000             ; * Closed accounts
         WRITE YNEW.REC TO F.FTNO, FTNO.ID
      END
*
      RETURN
   END
