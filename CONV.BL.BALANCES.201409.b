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
    $PACKAGE BL.Foundation
    SUBROUTINE CONV.BL.BALANCES.201409(BAL.ID, BAL.REC, BAL.FILE)
*
* Routine to Replace the Balances id with the Register ID concatenated with
* BL.BILL transaction id.
*
*** <region name= Inserts>
*** <desc>Loan File and Common Variables </desc>

    $INSERT I_COMMON
    $INSERT I_EQUATE
    EQU BL.BAL.CONTRACT.ID TO 1
*** </region>
*** <region name= Main Process>
*** <desc>Conversion Process for balances </desc>
    GOSUB INITIALISE
    GOSUB PROCESS
    RETURN
*** </region>

*** <region name= Initialise>
*** <desc>Initialise routine variables and File open </desc>
INITIALISE:
**********
    FN.BL.BALANCES = 'F.BL.BALANCES'
    F.BL.BALANCES = ''
    CALL OPF(FN.BL.BALANCES,F.BL.BALANCES)
    RETURN
*** </region>

*** <region name= ProcessFlow>
*** <desc>Convert the BL.BALANCES ID </desc>
PROCESS:
********
    BL.BAL.ID = BAL.ID
    BAL.ID = BAL.ID:"*":BAL.REC<BL.BAL.CONTRACT.ID>  ;* Concat the BL.BILL id with the BAL.ID to convert the balances ids.
    CALL F.DELETE(FN.BL.BALANCES,BL.BAL.ID)   ;* Delete the existing balances record.

    RETURN
*** </region>
