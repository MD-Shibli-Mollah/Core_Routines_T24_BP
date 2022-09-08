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

* Version 5 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.Config
      SUBROUTINE CONV.LC.PARAMETER(PARAM.ID, R.LCP, F.LCP)

$INSERT I_COMMON
$INSERT I_EQUATE

      EQU LC.PARA.LC.CLASS.TYPE TO 68
      EQU LC.PARA.EB.CLASS.NO TO 69

      R.LCP<LC.PARA.LC.CLASS.TYPE,1> = "BASIC.MESSAGE"
      R.LCP<LC.PARA.EB.CLASS.NO,1> = "OPERATIONS"
      R.LCP<LC.PARA.LC.CLASS.TYPE,2> = "REIMBURSING"
      R.LCP<LC.PARA.EB.CLASS.NO,2> = "REIMBURSING"
      R.LCP<LC.PARA.LC.CLASS.TYPE,3> = "ADVICE.THRU"
      R.LCP<LC.PARA.EB.CLASS.NO,3> = "ACKNOWLEDGE"
      R.LCP<LC.PARA.LC.CLASS.TYPE,4> = "PAYMENT.CUST"
      R.LCP<LC.PARA.EB.CLASS.NO,4> = "PAYMENT"
      R.LCP<LC.PARA.LC.CLASS.TYPE,5> = "COVER.BANK"
      R.LCP<LC.PARA.EB.CLASS.NO,5> = "COVERPAYMENT"
      R.LCP<LC.PARA.LC.CLASS.TYPE,6> = "RECEIVE.NOTIFY"
      R.LCP<LC.PARA.EB.CLASS.NO,6> = "RECEIVEPAY"
      R.LCP<LC.PARA.LC.CLASS.TYPE,7> = "NOTIFICATION"
      R.LCP<LC.PARA.EB.CLASS.NO,7> = "NOTIFICATION"
      R.LCP<LC.PARA.LC.CLASS.TYPE,8> = "DEBIT.CUST"
      R.LCP<LC.PARA.EB.CLASS.NO,8> = "DEBITADVICE"
      R.LCP<LC.PARA.LC.CLASS.TYPE,9> = "CREDIT.CUST"
      R.LCP<LC.PARA.EB.CLASS.NO,9> = "CREDITADVICE"
      R.LCP<LC.PARA.LC.CLASS.TYPE,10> = "PAYMENT.BANK"
      R.LCP<LC.PARA.EB.CLASS.NO,10> = "BANKTRANSFER"
      R.LCP<LC.PARA.LC.CLASS.TYPE,11> = "PROVISION.DEBIT"
      R.LCP<LC.PARA.EB.CLASS.NO,11> = "DEBITPROVISION"
      R.LCP<LC.PARA.LC.CLASS.TYPE,12> = "PROVISION.CREDIT"
      R.LCP<LC.PARA.EB.CLASS.NO,12> = "CREDITPROVISION"
      R.LCP<LC.PARA.LC.CLASS.TYPE,13> = "COLL.ACCEPT"
      R.LCP<LC.PARA.EB.CLASS.NO,13> = "ACCEPTADVICE"
*      R.LCP<LC.PARA.SHARE.PARNT.LIM> = "YES"
      RETURN
   END
