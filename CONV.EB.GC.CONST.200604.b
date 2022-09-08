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

* Version 3 02/06/00  GLOBUS Release No. G11.0.00 29/06/00
*-----------------------------------------------------------------------------
* <Rating>-13</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.Constraints
      SUBROUTINE CONV.EB.GC.CONST.200604(ID,R.RECORD, FN.FILE)
*-----------------------------------------------------------------------------
* Program Description
* Adds default values for EB.GCC.DEPEND.PREVIOUS. Null for first and 'NO'
* for subsequnet values.
*-----------------------------------------------------------------------------
* Modification History :
*
* 11/01/2006 - EN_10002736
*              Created.
*-----------------------------------------------------------------------------
$INSERT I_COMMON
$INSERT I_EQUATE
*-----------------------------------------------------------------------------

      GOSUB INITIALISE
*... only modify value if target field is totally empty.
      IF R.RECORD<EB.GCC.LOGIC> EQ '' THEN
         NUM.CONSTRAINTS = DCOUNT(R.RECORD<EB.GCC.OPERAND>, VM)
         FOR CNT = 1 TO NUM.CONSTRAINTS
            IF CNT EQ NUM.CONSTRAINTS THEN
* last value must be blank as does not have a following constraint to apply logic to.
            END ELSE
* this is the default behaviour before DEPEND.PREVIOUS added.
               R.RECORD<EB.GCC.LOGIC, CNT> = 'OR'
            END
         NEXT CNT
      END
      RETURN

*-----------------------------------------------------------------------------
INITIALISE:

      EB.GCC.OPERAND = 8
      EB.GCC.LOGIC = 20
      RETURN

*-----------------------------------------------------------------------------
*
   END
