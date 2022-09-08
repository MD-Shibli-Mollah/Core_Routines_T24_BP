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
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.Config
      SUBROUTINE CONV.ACCOUNT.PARAMETER.G13(ID,REC,FILE)
*******************************************************

* This Subroutine populates the field GENERIC.CHARGES in the
* ACCOUNT.PARAMETER File with the value 'Y', if there are any
* IC.CHARGE.PRODUCT Records existing.
*
* 06/06/2002 - GLOBUS_BG_100001001
*              New Conversion Routine written to be triggered
*              When Upgradation Happens
*
*******************************************************
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.ACCOUNT.PARAMETER
*
*
      F.IC.CHARGE.PRODUCT = ''
      FN.IC.CHARGE.PRODUCT = 'F.IC.CHARGE.PRODUCT'
      CALL OPF(FN.IC.CHARGE.PRODUCT,F.IC.CHARGE.PRODUCT)

      FN.ACCOUNT.PARAMETER = 'F.ACCOUNT.PARAMETER'
      F.ACCOUNT.PARAMETER = ''
      CALL OPF(FN.ACCOUNT.PARAMETER,F.ACCOUNT.PARAMETER)

      SEL.STMT = "SELECT ":FN.IC.CHARGE.PRODUCT
      CALL EB.READLIST(SEL.STMT,IC.CHARGE.SEL.LIST,'',NO.OF.REC,RETCODE)
      IF NO.OF.REC THEN
         REC<61> = 'Y'
      END
      RETURN
   END
