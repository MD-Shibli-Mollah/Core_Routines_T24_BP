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
* <Rating>-2</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SY.Config
      SUBROUTINE CONV.SY.PRODUCT.DEFINITION.R09(syProductDefinition.ID, syProductDefinition.RECORD, YFILE)
*-----------------------------------------------------------------------------
* Conversion routine to populate  audit fields
*-----------------------------------------------------------------------------
*MODIFICATION HISTORY:
*--------------------
* 11/10/07 - EN_10003534
*            Locking and history file update for EB.RULES.VERSION.
*
* 05/12/08 - BG_100021187 - aleggett@temenos.com
*            Define FILE.CLASS before invoking S.UPDATE.AUDIT.FIELDS to avoid
*            fatal error in EB.SET.COMPANY.ID (Ref: TTS0804767)
*            Additionally replace inserts with local equates.
*
*-----------------------------------------------------------------------------

$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.USER
$INSERT I_F.FILE.CONTROL
*$INSERT I_F.SY.PRODUCT.DEFINITION
*$INSERT I_F.SY.PRODUCT.DESCRIPTION

      EQUATE SyProductDefinition_ShortName TO 5
      EQUATE SyProductDefinition_Description TO 6
      EQUATE SyProductDefinition_FirstDate TO 32

      EQUATE SyProductDescription_ProductDescription TO 1
      EQUATE SyProductDescription_ProductDefinition TO 2
      EQUATE SyProductDescription_ShortName TO 3
      EQUATE SyProductDescription_Description TO 4
      EQUATE SyProductDescription_AuditDateTime TO 25

      IF FIELD(syProductDefinition.ID,";",2) = "" THEN
* This is not a historical record

      FN.SY.PRODUCT.DESCRIPTION = 'F.SY.PRODUCT.DESCRIPTION'
      F.SY.PRODUCT.DESCRIPTION = ''
      CALL OPF(FN.SY.PRODUCT.DESCRIPTION,F.SY.PRODUCT.DESCRIPTION)

      syProductDescription.RECORD = ""
      syProductDescription.RECORD<SyProductDescription_ProductDescription> = syProductDefinition.ID
      syProductDescription.RECORD<SyProductDescription_ProductDefinition> = syProductDefinition.ID
      syProductDescription.RECORD<SyProductDescription_ShortName> = syProductDefinition.RECORD<SyProductDefinition_ShortName>
      syProductDescription.RECORD<SyProductDescription_Description> = syProductDefinition.RECORD<SyProductDefinition_Description>
      
      IF syProductDefinition.RECORD<SyProductDefinition_FirstDate> = "" THEN
         syProductDefinition.RECORD<SyProductDefinition_FirstDate> = TODAY
         WRITE syProductDefinition.RECORD TO F.FILE, syProductDefinition.ID
      END

* Set the FILE.CLASS for SY.PRODUCT.DESCRIPTION before calling S.UPDATE.AUDIT.FIELDS

      saveFileClass = FILE.CLASS
      FILE.CONTROL.ID = 'SY.PRODUCT.DESCRIPTION'
      readErr = ''
      CALL CACHE.READ('F.FILE.CONTROL',FILE.CONTROL.ID,R.FILE.CONTROL,readErr)
      FILE.CLASS = R.FILE.CONTROL<EB.FILE.CONTROL.CLASS> 
      
      oldV = V
      V = SyProductDescription_AuditDateTime
      CALL S.UPDATE.AUDIT.FIELDS(syProductDescription.RECORD)
      ID.SY.PRODUCT.DESCRIPTION = syProductDefinition.ID
      R.SY.PRODUCT.DESCRIPTION  = syProductDescription.RECORD
      CALL F.WRITE(FN.SY.PRODUCT.DESCRIPTION,ID.SY.PRODUCT.DESCRIPTION,R.SY.PRODUCT.DESCRIPTION)
      V = oldV

      FILE.CLASS = saveFileClass

   END

   RETURN
   END
