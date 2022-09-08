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

*
*-----------------------------------------------------------------------------
* <Rating>-37</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AM.Reports
      SUBROUTINE CONV.AM.REP.TEMPLATE.R09(AM.REP.TEMPLATE.ID,R.AM.REP.TEMPLATE,FN.AM.REP.TEMPLATE)
*-----------------------------------------------------------------------------
*** <region name= Program Description>
*** <desc> </desc>
* This routine clears the field TEMPLATE.CATEG as AM.REP.TEMPLATE.CATEG has
* been made obsolete (and isn't used by anything).

*
*
* Field numbers are (as of R08.000):
*
*     TEMPLATE.CATEG = 2
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc> </desc>
*-----------------------------------------------------------------------------
* Modification History:
*-----------------------------------------------------------------------------
*
* 15/05/08 - BG_100018460 - aleggett@temenos.com
*            Created as part of record conversion for AM.REP.TEMPLATE.
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc> </desc>
$INSERT I_COMMON
$INSERT I_EQUATE

*** </region>

      GOSUB EQUATE.FIELDS
      GOSUB CLEAR.FIELDS
      GOSUB CONVERT.FIELDS

      RETURN
*-----------------------------------------------------------------------------
*** <region name= EQUATE.FIELDS>
*** <desc>Set local field equates here as this is a conversion.</desc>
EQUATE.FIELDS:

      EQUATE templateCategFld TO 2
   
      RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= CLEAR.FIELDS>
*** <desc>Clear the obsolete fields.</desc>
CLEAR.FIELDS:

      R.AM.REP.TEMPLATE<templateCategFld> = ''

      RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= CONVERT.FIELDS>
*** <desc>Convert field values as applicable.</desc>
CONVERT.FIELDS:

* Nothing to do

      RETURN

*** </region>
*-----------------------------------------------------------------------------
   END
