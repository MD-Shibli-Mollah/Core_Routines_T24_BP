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
* <Rating>-50</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CR.ModelBank
    SUBROUTINE MB.GET.CR.PROFILE(CR.PROFILE, CR.PROFILE.TYPES, CR.PROFILES)
*** <region name= PROGRAM DESCRIPTION>
***
*
* API which returns the corresponding CR.PROFILE value for the given CR.PROFILE.TYPE...
* Rules Engine cant handle multi-value sets and hence, for the different segment types
* (CR.PROFILE.TYPEs), we will create new DATA.LABEL (Run-time field) in EB.CONTEXT
* and attach this routine.
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Arguments>
*** <desc>Input and output arguments required for the sub-routine</desc>
*
* Arguments
*
* Input
*
* @param   CR.PROFILE        - the CR.PROFILE.TYPE to look for ("LOYALTY", "PROFESSION" etc)
*          CR.PROFILE.TYPES  - CR.PROFILE.TYPE field value from CUSTOMER
*          CR.PROFILES       - CR.PROFILE field value from CUSTOMER
*
* Output
*
* @param   CR.PROFILE        - the Located CR.PROFILE value
*
*
*
*** </region>
*-------------------------------------------------------------------------------
*
*** <region name= INSERTS>
***

*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>

    GOSUB INITIALISE
    GOSUB CHECK.PRELIM.CONDS
    IF PROCESS.GOAHEAD THEN
        GOSUB GET.THE.PROFILE
    END

    RETURN

*---------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>File variables and local variables</desc>
INITIALISE:

    PROCESS.GOAHEAD = 1
    PROFILE.TO.LOCATE = CR.PROFILE
    CR.PROFILE = ""

    RETURN
*** </region>
*------------------------------------------------------------------------------
*** <region name= Check Prelim Conds>
*** <desc>Ensure all the parameters are set</desc>
CHECK.PRELIM.CONDS:

    IF PROFILE.TO.LOCATE<1,1,1> EQ "" THEN
        PROCESS.GOAHEAD = 0
    END

    RETURN
*** </region>
*------------------------------------------------------------------------------
*** <region name= Get The Profile>
*** <desc>Ensure all the parameters are set</desc>
GET.THE.PROFILE:

    LOCATE PROFILE.TO.LOCATE IN CR.PROFILE.TYPES<1,1> SETTING CR.PROF.POS THEN
        CR.PROFILE = CR.PROFILES<1,CR.PROF.POS>
    END

    RETURN
*** </region>
*------------------------------------------------------------------------------
END
