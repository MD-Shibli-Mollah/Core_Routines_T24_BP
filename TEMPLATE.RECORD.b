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

* Version 9 16/05/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>-34</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.Template
      SUBROUTINE TEMPLATE.RECORD
*-----------------------------------------------------------------------------
!** Simple SUBROUTINE template
* @author youremail@temenos.com
* @stereotype recordcheck
* @package infra.eb
* @uses E
* @uses AF
*!
*----------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE

* Check if the record is okay to input to...
      GOSUB CHECK.RECORD
      IF E = '' THEN
         GOSUB SET.ENRICHMENTS
         GOSUB POPULATE.COMMONS
      END

      RETURN
*-----------------------------------------------------------------------
POPULATE.COMMONS:
      RETURN
*-----------------------------------------------------------------------------
SET.ENRICHMENTS:
      CALL EB.SET.FIELD.ENRICHMENT(FIELD.NUMBER, FIELD.ENRICHMENT)
      RETURN
*--------------------------------------------------------------------
CHECK.RECORD:
* Input not allowed for matured contracts!
      IF V$FUNCTION MATCHES 'I' : VM : 'R' THEN
* TODO add specific checks for blocking functions if required,
*         IF NOT(R.NEW(MY.RECORD.STATUS) EQ 'INAU') AND R.NEW(MY.CONTRACT.STATUS) = 'LIQ' THEN
*            E ='SAMPLE.ERROR.CODE'
*         END
      END
      RETURN
*-----------------------------------------------------------------------------
END
