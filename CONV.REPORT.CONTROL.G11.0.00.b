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

* Version 1 18/07/01  GLOBUS Release No. G12.0.01 31/07/01
*-----------------------------------------------------------------------------
* <Rating>97</Rating>
*-----------------------------------------------------------------------------
      SUBROUTINE CONV.REPORT.CONTROL.G11.0.00
*
* Populate the blank CO.CODE field in the file REPORT.CONTROL
* with ID.COMPANY.
* This is so that the Conversion Program will work for all records.
*
************************************************************************
* Modification                                                         *
* ============                                                         *
*                                                                      *
* 16/05/00 - GB0001143                                                 *
*            Initial Version of this program.                          *
*                                                                      *
* 01/08/01 - GB0102059                                                 *
*            Amend this program to look at CO.CODE field position      *
*            not the field name.                                       *
************************************************************************
*

$INSERT I_COMMON
$INSERT I_F.COMPANY
$INSERT I_EQUATE
$INSERT I_F.REPORT.CONTROL
$INSERT I_F.USER
*
* Open files
*
      FN.REPORT.CONTROL = "F.REPORT.CONTROL"
      F.REPORT.CONTROL = ""
      CALL OPF(FN.REPORT.CONTROL,F.REPORT.CONTROL)

*
* For each record on REPORT.CONTROL, if the CO.CODE is blank,
* default to ID.COMPANY.
*
      K.REPORT = ""

      SELECT.STATEMENT ="SELECT " : FN.REPORT.CONTROL

      EOL = ''
      EXECUTE SELECT.STATEMENT
      LOOP
         READNEXT K.REPORT ELSE EOL = 1
      UNTIL EOL DO

*Read Selected Records
         ETEXT = ''
         R.REPORT.CONTROL = ''
         CALL F.READ(FN.REPORT.CONTROL,K.REPORT,R.REPORT.CONTROL,F.REPORT.CONTROL,ETEXT)
         IF R.REPORT.CONTROL<32> = "" THEN
            R.REPORT.CONTROL<32> = ID.COMPANY
         END
         WRITE R.REPORT.CONTROL TO F.REPORT.CONTROL,K.REPORT
*
      REPEAT
*

      RETURN

   END
