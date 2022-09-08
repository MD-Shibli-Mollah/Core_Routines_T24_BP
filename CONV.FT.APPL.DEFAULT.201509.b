* @ValidationCode : MjotMTU5MTcyODIyNzpDcDEyNTI6MTQ4OTY2NTY2NjQ2MDpjaGFydXNoYWppOjE6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxNzAyLjA6NDk6NDM=
* @ValidationInfo : Timestamp         : 16 Mar 2017 17:31:06
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : charushaji
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 43/49 (87.7%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-31</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FT.Config
    SUBROUTINE CONV.FT.APPL.DEFAULT.201509
*-----------------------------------------------------------------------------
* Description:
*-------------
* This pre routine will update the RESUBMIT.RULE field in FT.APPL.DEFAULT
* record with the values in RESUBMIT.OVERRIDE
*-----------------------------------------------------------------------------
* Modification History:
*----------------------
* 27/08/15 - Task 1451155
*            New file conversion routine.
*
* 23/02/17 - Defect 2024356 / Task 2030081
*          - The values inputted in the local fields were moved to the newly 
*            included RESUBMIT.OVERRIDE field in the FT.APPL.DEFAULT.
* 
*-----------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FT.APPL.DEFAULT
    $INSERT I_DAS.COMMON
*
*-----------------------------------------------------------------------------
*
    GOSUB INITIALISE
    GOSUB PROCESS
*
    RETURN
*
*-----------------------------------------------------------------------------
INITIALISE:
*----------
*
    SUFFIX = ''
*
    COMPANIES.LIST = dasAllIds
    CALL DAS("COMPANY", COMPANIES.LIST, "", "")
*
    APPL.ARRAY = 'FT.APPL.DEFAULT'
    FLD.ARRAY = 'RESUBMIT.RULE'
    FLD.POS = ''
    CALL GET.LOC.REF(APPL.ARRAY,FLD.ARRAY,FLD.POS)
*
    RETURN
*
*-----------------------------------------------------------------------------
PROCESS:
*-------
*
    LOOP
        REMOVE COMPANY.ID FROM COMPANIES.LIST SETTING COMP.POS
    WHILE COMPANY.ID:COMP.POS
        FOR FILE.TYPE = 1 TO 3
            BEGIN CASE
                CASE FILE.TYPE EQ 1
                    SUFFIX = ""
                CASE FILE.TYPE EQ 2
                    SUFFIX = "$NAU"
                CASE FILE.TYPE EQ 3
                    SUFFIX = "$HIS"
            END CASE

            GOSUB CONVERT.RECORD

        NEXT FILE.TYPE
    REPEAT
*
    RETURN
*
*-----------------------------------------------------------------------------
CONVERT.RECORD:
*--------------
*
    FN.FT.APPL.DEFAULT = 'F.FT.APPL.DEFAULT':SUFFIX
    F.FT.APPL.DEFAULT = ''
    CALL OPF(FN.FT.APPL.DEFAULT,F.FT.APPL.DEFAULT)
    R.FT.APPL.DEFAULT = ''
    Y.ERR = ''
    CALL F.READU(FN.FT.APPL.DEFAULT,COMPANY.ID,R.FT.APPL.DEFAULT,F.FT.APPL.DEFAULT,Y.ERR,'')
    OVERRIDE.LIST = ''
    IF R.FT.APPL.DEFAULT AND R.FT.APPL.DEFAULT<FT1.LOCAL.REF,FLD.POS> NE '' AND FLD.POS NE '' THEN
        OVERRIDE.LIST = R.FT.APPL.DEFAULT<FT1.LOCAL.REF,FLD.POS>
        CONVERT @SM TO @VM IN OVERRIDE.LIST
        R.FT.APPL.DEFAULT<FT1.RESUBMIT.OVERRIDE> = OVERRIDE.LIST
        R.FT.APPL.DEFAULT<FT1.LOCAL.REF,FLD.POS> = ''
        CALL F.WRITE(FN.FT.APPL.DEFAULT,COMPANY.ID,R.FT.APPL.DEFAULT)
    END ELSE
        CALL F.RELEASE(FN.FT.APPL.DEFAULT,COMPANY.ID,F.FT.APPL.DEFAULT)
    END
*
    RETURN
*
*-----------------------------------------------------------------------------
*
    END
