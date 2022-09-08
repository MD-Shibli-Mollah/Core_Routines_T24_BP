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
* <Rating>-42</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ProductManagement
    SUBROUTINE CONV.AA.PRODUCT.DESIGNER.R08(REC.ID, PROD.REC, YFILE)


*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*
* Record Conversion routine to convert arr link options in product designer
* FIXED - NON.TRACKING ; NEGOTIABLE - CUSTOM.TRACKING
*
*
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Arguments>
*** <desc>Input and output arguments required for the sub-routine</desc>
* Arguments
*
** Input:
*
** REC.ID   - Record Id
** PROD.REC - Product Designer Record 
** YFILE    - File Name
*
*** </region>
*-----------------------------------------------------------------------------



*** <region name= Modification History>
*** <desc>Changes done in the sub-routine</desc>
* Modification History
*
* 08/02/08 - BG_100017004
*            Ref : TTS0800371
*            Record Conversion routine to convert arr link options in product designer
*            FIXED - NON.TRACKING ; NEGOTIABLE - CUSTOM.TRACKING
*
*
*** </region>
*-----------------------------------------------------------------------------



*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
* Inserts
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.AA.PRODUCT.DESIGNER
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Initialise>
*** <desc>Initialise local variables and file variables</desc>
INITIALISE:

    PROPERTY.COUNT = ''
    PRD.PROPERTY.COUNT = ''

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main process>
*** <desc>Description for the main process</desc>
PROCESS:

    PROPERTY.COUNT = DCOUNT(PROD.REC<AA.PRD.PROPERTY>, VM)

    FOR PROP = 1 TO PROPERTY.COUNT

        PRD.PROPERTY.COUNT = DCOUNT(PROD.REC<AA.PRD.PRD.PROPERTY,PROP>, SM)

        FOR PRD.PROP = 1 TO PRD.PROPERTY.COUNT

            BEGIN CASE
            CASE PROD.REC<AA.PRD.ARR.LINK, PROP, PRD.PROP> EQ "FIXED" ;*If old ARR.LINK field contains FIXED , change it to NON.TRACKING
                PROD.REC<AA.PRD.ARR.LINK, PROP, PRD.PROP> = "NON.TRACKING"
            CASE PROD.REC<AA.PRD.ARR.LINK, PROP, PRD.PROP> EQ "NEGOTIABLE"
                PROD.REC<AA.PRD.ARR.LINK, PROP, PRD.PROP> = "CUSTOM.TRACKING"   ;* If old ARR.LINK field contains NEGOTIABLE , change it to CUSTOM.TRACKING
            END CASE

        NEXT PRD.PROP
    NEXT PROP

    RETURN
*** </region>
*-----------------------------------------------------------------------------

END
