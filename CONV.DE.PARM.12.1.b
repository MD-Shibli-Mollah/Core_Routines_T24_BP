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

* Version 3 15/05/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>680</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DE.Config
      SUBROUTINE CONV.DE.PARM.12.1
*
* CONV.DE.PARM - Convert old DE.PARM records into new ones, ie with
* CLEARING.SYSTEM and CLEARING.INTERFACE fields.
* When SIC is encountered as a valid carrier, if no clearing system
* or no clearing interface is present, they are created with 'SIC'
* and 'SPAC' as values.
*
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.DE.PARM
$INSERT I_F.DATES
$INSERT I_F.DE.MESSAGE
*
      CRT @(5,5):"This will convert the clearing fields in DE.PARM"
      TEXT = "DO YOU WISH TO CONVERT THE FILE"
      CALL OVE
      IF TEXT NE "Y" THEN GOTO PGM.EXIT
*
      DIM R.PARM(DE.PAR.DIM + 9)
      CLEARING.SYSTEMS = 'SIC_BGC_BACS'
*
      F.DE.PARM = '' ; 
      OPEN 'F.DE.PARM' TO F.DE.PARM ELSE STOP 'CANNOT OPEN F.DE.PARM'
*
      MATREADU R.PARM FROM F.DE.PARM,'SYSTEM.STATUS' ELSE STOP 'CANNOT READ'
*
      LOCATE 'SIC' IN R.PARM(DE.PAR.OUTWARD.CARRIERS)<1,1> SETTING POS ELSE
         LOCATE 'SIC' IN R.PARM(DE.PAR.INWARD.CARRIERS)<1,1> SETTING POS ELSE
            TEXT = 'CONVERSION NOT NEEDED - CARRIER NOT AVAILABLE'
            CALL REM
            GOTO PGM.EXIT
         END
      END
      IF R.PARM(DE.PAR.CLEARING.SYSTEM) = '' THEN
         R.PARM(DE.PAR.CLEARING.SYSTEM) = 'SIC'
      END ELSE
         TEXT = 'CONVERSION NOT NEEDED - CLEARING SYSTEM PRESENT'
         CALL REM ; GOTO PGM.EXIT
      END
      IF R.PARM(DE.PAR.CLEARING.INTERFACE) = '' THEN
         R.PARM(DE.PAR.CLEARING.INTERFACE) = 'SPAC'
      END ELSE
         TEXT = 'CONVERSION NOT NEEDED - CLEARING INTERFACE PRESENT'
         CALL REM
         RELEASE F.DE.PARM ; GOTO PGM.EXIT
      END
      MATWRITE R.PARM TO F.DE.PARM,'SYSTEM.STATUS'
PGM.EXIT:
      RETURN
   END
