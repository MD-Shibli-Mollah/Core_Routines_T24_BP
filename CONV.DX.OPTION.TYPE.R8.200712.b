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
    $PACKAGE DX.Configuration
      SUBROUTINE CONV.DX.OPTION.TYPE.R8.200712(dxOptionTypeId,rDxOptionType,fnDxOptionType)
*-----------------------------------------------------------------------------
*** <region name= Program Description>
*** <desc> </desc>
* This routine clears the fields DX.OT.USR.FLD.PGM, DX.OT.CROSSVAL.PGM and
* DX.OT.EOE.PGM.
* User field program, User field crossval program and User field EOE program
* fields were never implemented, therefore made obsolete in DX.OPTION.TYPE.
*
* Also converts field DX.OT.USR.FLD.PRICE from 'YES'/'NO'/blank option field
* to YES/blank checkbox-type field - i.e. 'NO' changed to blank.
*
* Field numbers are (as of 200712):
*
*     DX.OT.USR.FLD.PGM   = 12
*     DX.OT.USR.FLD.PRICE = 14
*     DX.OT.CROSSVAL.PGM  = 18
*     DX.OT.EOE.PGM       = 20
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc> </desc>
*-----------------------------------------------------------------------------
* Modification History:
*-----------------------------------------------------------------------------
*
* 21/01/08 - BG_100016734 - aleggett@temenos.com
*            Created as part of record conversion for DX.OPTION.TYPE.
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

      EQUATE usrFldPgm TO 12
      EQUATE usrFldPrice TO 14
      EQUATE crossvalPgm TO 18
      EQUATE eoePgm TO 20

      RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= CLEAR.FIELDS>
*** <desc>Clear the obsolete fields.</desc>
CLEAR.FIELDS:

      rDxOptionType<usrFldPgm> = ''
      rDxOptionType<crossvalPgm> = ''
      rDxOptionType<eoePgm> = ''

      RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= CONVERT.FIELDS>
*** <desc>Convert field values as applicable.</desc>
CONVERT.FIELDS:

* USR.FLD.PRICE changed from YES/NO/blank TO YES/blank.

      IF rDxOptionType<usrFldPrice> = 'NO' THEN
         rDxOptionType<usrFldPrice> = ''
      END

      RETURN

*** </region>
*-----------------------------------------------------------------------------
   END
