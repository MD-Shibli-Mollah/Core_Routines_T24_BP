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

* Version 2 15/05/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>79</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScoSecurityMasterMaintenance
      SUBROUTINE CONV.SECURITY.MASTER.G9(SM.ID,SM.REC,SM.FILE)

$INSERT I_EQUATE
$INSERT I_COMMON
$INSERT I_F.CUSTOMER
*
      F.COMPANY.CHECK = ""
      CALL OPF("F.COMPANY.CHECK",F.COMPANY.CHECK)
      R.COMPANY.CHECK = ""
      CALL F.READ("F.COMPANY.CHECK","CUSTOMER",R.COMPANY.CHECK,F.COMPANY.CHECK,ER)
      IF R.COMPANY.CHECK THEN
         NCOS = DCOUNT(R.COMPANY.CHECK<2>,FM)
         FOR I = 1 TO NCOS
            FMNE.CUSTOMER = "F":R.COMPANY.CHECK<2,I>:".CUSTOMER"
            GOSUB READ.CUS
         NEXT I
      END
      IF SM.REC<76> THEN SM.REC<76> = ""
      RETURN
*
* read customer and set up company level fields
*
READ.CUS:
      CALL OPF(FMNE.CUSTOMER,F.CUSTOMER)
      CUS.ID = SM.REC<76>                ; * ISSUER
      R.CUSTOMER = ""
      CALL F.READ(FMNE.CUSTOMER,CUS.ID,R.CUSTOMER,F.CUSTOMER,ER)
      IF R.CUSTOMER THEN
         SM.REC<82,I> = R.COMPANY.CHECK<2,I>
         SM.REC<83,I> = SM.REC<76>
      END
      RETURN
   END
