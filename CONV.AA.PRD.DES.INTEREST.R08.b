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
* <Rating>-28</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.Interest
    SUBROUTINE CONV.AA.PRD.DES.INTEREST.R08(REC.ID, PROD.REC, YFILE)


*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*
* Record Conversion routine to convert values in NR.ATTRIBUTE field in AA.PRD.DES.INTEREST
* NOMINAL.RATE - EFFECTIVE.RATE
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
** PROD.REC - AA.PRD.DES.INTERST Record
** YFILE    - File Name
*
*** </region>
*-----------------------------------------------------------------------------



*** <region name= Modification History>
*** <desc>Changes done in the sub-routine</desc>
* Modification History
*
* 21/04/08 - BG_100018098
*            Ref : BG_100018098
*            Field NOMINAL.RATE in interest property renamed to EFFECTIVE.RATE
*
*** </region>
*-----------------------------------------------------------------------------



*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
* Inserts
$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_AA.APP.COMMON
$INSERT I_F.AA.INTEREST
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

    TOTAL.NR.ATTRIB  = ''  ;** NR.ATTRIBUTE count
    IS.NOMINAL.RATE = ''   ;**flag to denote whether nominal rate is present
    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main process>
*** <desc>Description for the main process</desc>
PROCESS:

    NR.CNT = 0
    TOTAL.NR.ATTRIB = DCOUNT(PROD.REC<AA.INT.NR.ATTRIBUTE>, VM)
    LOOP
        NR.CNT += 1
    WHILE NOT(IS.NOMINAL.RATE) AND NR.CNT LE TOTAL.NR.ATTRIB

        IF PROD.REC<AA.INT.NR.ATTRIBUTE, NR.CNT> EQ "NOMINAL.RATE" THEN ;*If field contains NOMINAL.RATE change it to EFFECTIVE.RATE
            PROD.REC<AA.INT.NR.ATTRIBUTE, NR.CNT> = "EFFECTIVE.RATE"
            IS.NOMINAL.RATE = 1 ; ** since  NR.ATTRIBUTE can't have duplicate value breaking the the loop after one value is found
        END

    REPEAT

    RETURN
*** </region>
*-----------------------------------------------------------------------------

    END
