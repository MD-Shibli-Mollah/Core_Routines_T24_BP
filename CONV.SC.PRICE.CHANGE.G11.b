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

* Version 2 16/05/01  GLOBUS Release No. 200509 29/07/05
*-----------------------------------------------------------------------------
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctPriceTypeUpdateAndProcessing
      SUBROUTINE CONV.SC.PRICE.CHANGE.G11(RELEASE.NO, R.RECORD, FN.FILE)
$INSERT I_EQUATE
$INSERT I_COMMON
$INSERT I_F.SC.PRICE.CHANGE
$INSERT I_F.USER
*GB0001206 - CHANGING SC.PRICE.CHANGE FROM LIVE FILE TO
*	      INPUTTABLE FILE. SO AUDIT FIELDS ADDED
*	      ALSO INCOME, OLD.INCOME AND LOCAL.REF
*	      FIELDS ADDED AND DATE.TIME AND INPUTTER
*	      REMOVED
      R.RECORD<7> = ''
      R.RECORD<8> = ''
      R.RECORD<9> = ''
      R.RECORD<10> = ''
      R.RECORD<11> = 1
      R.RECORD<12> = TNO:"-":'CONV.SC.PRICE.CHANGE.G11'
      X = OCONV(DATE(),"D-")
      X = X[9,2]:X[1,2]:X[4,2]:TIME.STAMP[1,2]:TIME.STAMP[4,2]
      R.RECORD<13> = X
      R.RECORD<14> = TNO:"-":'CONV.SC.PRICE.CHANGE.G11'
      R.RECORD<15> = ID.COMPANY
      R.RECORD<16> = R.USER<EB.USE.DEPARTMENT.CODE>
      R.RECORD<17> = ''
      R.RECORD<18> = ''


      RETURN

   END
