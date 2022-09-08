* @ValidationCode : MjoyNTAwMzk0MzQ6Q3AxMjUyOjE0ODU4NjI4NDU4MTg6YnJpbmRoYXI6MTowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE3MDIuMjAxNzAxMjgtMDEzOTo5Ojk=
* @ValidationInfo : Timestamp         : 31 Jan 2017 17:10:45
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : brindhar
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 9/9 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.20170128-0139
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

    $PACKAGE AA.AgentCommission
    SUBROUTINE CONV.AA.AGENT.EVENT.R1703(Id, Record,File)
*-----------------------------------------------------------------------------
*  Conversion Routine to update the correct marker for AA.AGENT.EVENT fields.
*-----------------------------------------------------------------------------
* @package Retaillending.AA
* @stereotype subroutine
* @ author brindhar@temenos.com
*-----------------------------------------------------------------------------

* Modification History :
*
* 05/01/17 - Enhancement : 1911014
*            Task        : 1911021
*            Conversion Routine to update the correct marker for field.
*
*-----------------------------------------------------------------------------

*** <region name= Process Logic>
*** <desc>Program Control</desc>

    GOSUB Initialise
    GOSUB UpdateMarker

    RETURN
*** </region>
*-----------------------------------------------------------------------------------

Initialise:

    RETURN

*----------------------------------------------------------------------------------------

UpdateMarker:

    Record<7> = CHANGE(Record<7>,@VM,@SM) ;* Got the marker and update!
    Record<8> = CHANGE(Record<8>,@VM,@SM) ;* Got the marker and update!
    Record<12> = CHANGE(Record<12>,@VM,@SM) ;* Got the marker and update!
    Record<13> = CHANGE(Record<13>,@VM,@SM) ;* Got the marker and update!

    RETURN

    END
