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

* Version 3 13/04/00  GLOBUS Release No. G9.0.00 25/06/98
*-----------------------------------------------------------------------------
* <Rating>-31</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DE.Outward
    SUBROUTINE SAMPLE.OUT(MISN,R.MSG,GENERIC.DATA,ERROR.MSG)
*
* Sample subroutine to show how a routine to handle outgoing messages
* could be written
*
*
* P A R A M E T E R S
* ===================
*
* IN
* ==
*
* MISN                -  Message sequence number (5 digit number)
*
* R.MSG               -  Formatted message to be sent
*
* GENERIC.DATA        -  Miscellaneous data available to subroutine
*             <1>     -  Message key e.g. D199707105379202.1
*             <2>     -  Debug flag
*             <3>     -  PDE (1 if PDE, 0 otherwise)
*             <4>     -  Interface reference number/id
*             <5>     -  Interactive flag
*                        Layout of GENERIC.DATA is described in the
*                        insert I_DE.GENERIC.DATA
*
* OUT
* ===
*
* ERROR.MSG           -  Error message passed back to DE.CC.GENERIC, to
*                        indicate whether the message was processed
*                        successfully.
*                        Set to "STOP" to terminate DE.CC.GENERIC
*
* 21/02/07 - BG_100013037
*            CODE.REVIEW changes.
*
* 08/04/15 - Enhancement 1265068 / Task 1265070
*          - Including $PACKAGE
*
**********************************************************************************************
    $USING DE.Outward
*
* Initialise variables
*
    ERROR.MSG = ''
    V$DEBUG = GENERIC.DATA<DE.Outward.DeGenOutDebug>
*
* Print the sequence number and formatted message (debug statements to
* show the programmer what is happening)
*
    IF V$DEBUG THEN
        PRINT 'MISN = ':MISN  ;* BG_100013037 - S
    END   ;* BG_100013037 - E
    PRINT 'R.MSG = ':R.MSG
*
* Allow the user to set the error message, to simulate switch naks
*
    PRINT 'ENTER ERROR.MSG'
    IF V$DEBUG THEN
        INPUT ERROR.MSG       ;* BG_100013037 - S
    END   ;* BG_100013037 - E
*
    IF ERROR.MSG = '' THEN
        *
        * If an error has not occurred, open the outward message file
        *
        F.DE.O.MSG.SAMPLE = ''
        OPEN '','F.DE.O.MSG.SAMPLE' TO F.DE.O.MSG.SAMPLE ELSE
            ERROR.MSG = 'STOP'
            RETURN
        END
        *
        * Manipulate the formatted message (e.g. add a header and trailer)
        *
        R.MSG = 'HEADER':R.MSG[3,999]
        MSG.LEN = LEN(R.MSG)
        R.MSG = R.MSG[1,MSG.LEN-2]:'TRAILER'
        *
        * Write the amended message to the outward message file
        *
        WRITE R.MSG TO F.DE.O.MSG.SAMPLE,MISN
            *
        END

        RETURN
    END
