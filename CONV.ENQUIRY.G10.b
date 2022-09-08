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

* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>157</Rating>
*-----------------------------------------------------------------------------
      SUBROUTINE CONV.ENQUIRY.G10(YID,YREC,YFILE)
*************************************************************
* 12/01/00 - GB9901860
*            If FILE.NAME begins NOFILE... then don't do DBR
*            and set product to null.
*
*************************************************************

$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.PGM.FILE
*
      PRODUCT = ''
      GOSUB DETERMINE.PRODUCT
      IF YREC<53> = '' THEN YREC<53> = PRODUCT
      SHORT.DESC = ''
      GOSUB DETERMINE.DESCRIPTION
      IF YREC<54> = '' THEN YREC<54> = SHORT.DESC
      RETURN
*
DETERMINE.PRODUCT:
      FILE.NAME = YREC<2>
      *--- GB9901860 S
      BEGIN CASE
         CASE FILE.NAME[1,6] EQ 'NOFILE'
            *--- Do nothing since PRODUCT already assigned to null
         CASE 1
            CALL DBR("PGM.FILE" : FM : EB.PGM.PRODUCT, FILE.NAME,PRODUCT)
      END CASE
      *--- GB9901860 E

      RETURN
*
DETERMINE.DESCRIPTION:
      BEGIN CASE
         CASE YID[1,1] = "%"
            SHORT.DESC = FILE.NAME : " Default List"
         CASE INDEX(YID, "-LIST",1)
            SHORT.DESC = FILE.NAME : " Drop Down List"
         CASE OTHERWISE
            SHORT.DESC = YID
      END CASE
      RETURN
   END
