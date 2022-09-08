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
* <Rating>-37</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Pricing
      SUBROUTINE CONV.DX.PRICE.G121(DX.PRICE.ID,R.DX.PRICE,FN.DX.PRICE)
*
*************************************************************************

* Modification History:

* 28/01/03 - BG_100003268
* Code Patched from 131Dev

*************************************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.DX.PRICE
*
*      FOR XX = 1 TO C$SYSDIM
*         IF R.DX.PRICE<XX> # '' THEN
*            CRT "PRE:":XX"L#4":":":R.DX.PRICE<XX>
*         END
*      NEXT XX
*      INPUT X,1:_
*
      GOSUB STORE.AUDIT
*
      GOSUB PROCESS.FLDS
*
      GOSUB RESTORE.AUDIT
*
*      FOR XX = 1 TO C$SYSDIM
*         IF R.DX.PRICE<XX> # '' THEN
*            CRT "PST:":XX"L#4":":":R.DX.PRICE<XX>
*         END
*     NEXT XX
*     INPUT X,1:_
*
      RETURN
*================================================================================
STORE.AUDIT:
*
      STORE.SECTION = R.DX.PRICE
      STORE.SECTION<50,-1> = R.DX.PRICE<68>
*
      RETURN
*================================================================================

RESTORE.AUDIT:

* This section will restore the audit information just in case
*
      R.DX.PRICE<DX.PRI.SOURCE.KEY> = STORE.SECTION<37>
*
      R.DX.PRICE<DX.PRI.OVERRIDE> = STORE.SECTION<46>
      R.DX.PRICE<DX.PRI.LOCAL.REF> = STORE.SECTION<47>
      R.DX.PRICE<DX.PRI.RECORD.STATUS> = STORE.SECTION<48>
      R.DX.PRICE<DX.PRI.CURR.NO> = STORE.SECTION<49>
      R.DX.PRICE<DX.PRI.INPUTTER> = STORE.SECTION<50>
      R.DX.PRICE<DX.PRI.DATE.TIME> = STORE.SECTION<51>
      R.DX.PRICE<DX.PRI.AUTHORISER> = STORE.SECTION<52>
      R.DX.PRICE<DX.PRI.CO.CODE> = STORE.SECTION<53>
      R.DX.PRICE<DX.PRI.DEPT.CODE> = STORE.SECTION<54>
      R.DX.PRICE<DX.PRI.AUDITOR.CODE> = STORE.SECTION<55>
      R.DX.PRICE<DX.PRI.AUDIT.DATE.TIME> = STORE.SECTION<56>
*
      RETURN
*================================================================================
PROCESS.FLDS:
*
      NO.OPT.STRIKE = DCOUNT(R.DX.PRICE<DX.PRI.OPTION.STRIKE>,VM)
*
      FOR FLD.CNT = (DX.PRI.OPT.PUT.TIME+1) TO (DX.PRI.LOCAL.REF-1)
         R.DX.PRICE<FLD.CNT> = ""
      NEXT FLD.CNT
      R.DX.PRICE<DX.PRI.RESERVED15> = ""
*
      RETURN
*================================================================================
* <new subroutines>
   END
