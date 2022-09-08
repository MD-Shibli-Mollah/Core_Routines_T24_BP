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

* Version n dd/mm/yy  GLOBUS Release No. 200512 09/12/05
*-----------------------------------------------------------------------------
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AZ.Accounting
      SUBROUTINE AZ.SE.LOCAL.REF.VALUE(AZ.ACCT.ID,SENTRY.REC,SENTRY.TXN,LOC.REF.VALUE,RES.1,RES.2,RES.3,RES.4)

* Subroutine to return back the LOCAL REF value that will be populated in
* the LOCAL.REF field of the STMT.ENTRY raised for AZ.

* Incoming parameters:
* AZ.ACCT.ID - Underlying AZ Account contract id
* SENTRY.REC - Contains the current STMT.ENTRY record
* SENTRY.TXN - Holds the TRANSACTION.CODE in current STMT.ENTRY

* Outgoing parameters:
* LOC.REF.VALUE - value to be updated in LOCAL.REF field of AZ entries.
*                 values can be determined based on APPLICATION & R.NEW

*------------------------------------------------------------------------
* 08/08/05 - EN_10002616
*            Introduction.
*-------------------------------------------------------------------------

$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.FUNDS.TRANSFER
$INSERT I_F.TELLER
$INSERT I_F.AZ.ACCOUNT


* Kindly set the LOC.REF.VALUE as per the required transaction code.

      BEGIN CASE
         CASE APPLICATION ='FUNDS.TRANSFER'
            LOC.REF.VALUE =R.NEW(FT.LOCAL.REF)
         CASE APPLICATION ='TELLER'
            LOC.REF.VALUE = R.NEW(TT.TE.LOCAL.REF)
         CASE APPLICATION ='AZ.ACCOUNT'
            LOC.REF.VALUE = R.NEW(AZ.LOCAL.REF)
         CASE 1
            LOC.REF.VALUE =''
      END CASE
      RETURN
   END
