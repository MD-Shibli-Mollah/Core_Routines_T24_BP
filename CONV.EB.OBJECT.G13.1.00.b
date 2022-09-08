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
* <Rating>-19</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.SystemTables
      SUBROUTINE CONV.EB.OBJECT.G13.1.00(EB.OBJ.ID,EB.OBJ.REC,EB.OBJ.FILE)
*
$INSERT I_COMMON
$INSERT I_EQUATE
*
* 19/11/02 - BG_100002805
*            Include IN2ALLACCVAL in IN2.LIST field for EB.OBJECT record
*            with id as 'ACCOUNT'
*
* 27/11/02 - BG_100002886
*            Changed IN2ALLACCVAL to IN2.ALLACCVAL
*
* 20/05/03 - CI_10009304
*            To include IN2BIC in the IN2.LIST
*
* 15/07/03 - BG_100004798
*            Introducing IN2CUST.BIC in CUSTOMER record
*
* 30/07/03 - CI_10011259
*            Include IN2PLANT in IN2LIST to support Alternate Key
*            in Teller application.
*
* 06/11/03 - CI_10014420
*            Changes made to suppress error messages in UNIVERSE,
*            while calling F.WRITE.
*            Ref: HD0314431  
*****************************************************************************
* Initialisation

      FN.IN2.CONCAT = 'F.IN2.CONCAT'
      F.IN2.CONCAT = ''
      CALL OPF(FN.IN2.CONCAT,F.IN2.CONCAT)

      IF EB.OBJ.ID = 'CUSTOMER' THEN
         IN2.CONCAT.REC = 'CUSTOMER'
         EB.OBJ.REC<6,1> = 'IN2CUS'
         IN2.CONCAT.KEY = 'IN2CUS' ; GOSUB UPD.IN2.CONCAT
         EB.OBJ.REC<6,2> = 'IN2CPARTY'
         IN2.CONCAT.KEY = 'IN2CPARTY' ; GOSUB UPD.IN2.CONCAT
         EB.OBJ.REC<6,3> = 'IN2BIC'      ; * CI_10009304 S
         IN2.CONCAT.KEY = 'IN2BIC' ; GOSUB UPD.IN2.CONCAT    ; * CI_10009304 E
         EB.OBJ.REC<6,4> = 'IN2CUST.BIC'           ; * BG_100004798 - S
         IN2.CONCAT.KEY = 'IN2CUST.BIC' ; GOSUB UPD.IN2.CONCAT         ; * BG_100004798 - E

      END
      IF EB.OBJ.ID = 'ACCOUNT' THEN
         IN2.CONCAT.REC = 'ACCOUNT'
         EB.OBJ.REC<6,1> = 'IN2.ALLACCVAL'         ; * BG_100002886 S
         IN2.CONCAT.KEY = 'IN2.ALLACCVAL' ; GOSUB UPD.IN2.CONCAT       ; * BG_100002886 E
         EB.OBJ.REC<6,2> = 'IN2ALL'
         IN2.CONCAT.KEY = 'IN2ALL' ; GOSUB UPD.IN2.CONCAT
         EB.OBJ.REC<6,3> = 'IN2.ACCD'
         IN2.CONCAT.KEY = 'IN2.ACCD' ; GOSUB UPD.IN2.CONCAT
         EB.OBJ.REC<6,4> = 'IN2NOSANT'
         IN2.CONCAT.KEY = 'IN2NOSANT' ; GOSUB UPD.IN2.CONCAT
         EB.OBJ.REC<6,5> = 'IN2NOSACC'
         IN2.CONCAT.KEY = 'IN2NOSACC' ; GOSUB UPD.IN2.CONCAT
         EB.OBJ.REC<6,6> = 'IN2NOSALL'
         IN2.CONCAT.KEY = 'IN2NOSALL' ; GOSUB UPD.IN2.CONCAT
         EB.OBJ.REC<6,7> = 'IN2.ANTD'
         IN2.CONCAT.KEY = 'IN2.ANTD' ; GOSUB UPD.IN2.CONCAT
         EB.OBJ.REC<6,8> = 'IN2.AYM'
         IN2.CONCAT.KEY = 'IN2.AYM' ; GOSUB UPD.IN2.CONCAT
         EB.OBJ.REC<6,9> = 'IN2ACC'
         IN2.CONCAT.KEY = 'IN2ACC' ; GOSUB UPD.IN2.CONCAT
         EB.OBJ.REC<6,10>= 'IN2DELACC'
         IN2.CONCAT.KEY = 'IN2DELACC' ; GOSUB UPD.IN2.CONCAT
         EB.OBJ.REC<6,11>= 'IN2ANT'
         IN2.CONCAT.KEY = 'IN2ANT' ; GOSUB UPD.IN2.CONCAT
         EB.OBJ.REC<6,12>= 'IN2PLANT'                            ; * CI_10011259 - S
         IN2.CONCAT.KEY = 'IN2PLANT' ; GOSUB UPD.IN2.CONCAT      ; * CI_10011259 - E
      END
      RETURN ;* CI_10014420 - S/E
UPD.IN2.CONCAT:
      CALL F.WRITE(FN.IN2.CONCAT,IN2.CONCAT.KEY,IN2.CONCAT.REC)
      RETURN
   END
