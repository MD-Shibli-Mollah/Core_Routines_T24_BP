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
* <Rating>-36</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE T4.ModelBank
    SUBROUTINE E.BLD.TCIB.SWP.ACCT.CORP(ENQ.DATA)
* ==========================================================
*                 LOCAL DEVELOPMENT
* ==========================================================
* This is validation routine for listing sweeps
* Owner:  Anand Kumar
* Enhancement: 696318
*
* 14/07/15 - Enhancement 1326996 / Task 1399947
*			 Incorporation of T components
* ----------------------------------------------------------

    $USING T4.ModelBank

    GOSUB INIT
    GOSUB OPEN
    GOSUB PROCESS

    RETURN
*-------------------------------------------------------------------------------
INIT:
*------

    RETURN

*--------------------------------------------------------------------------------
OPEN:
*------

    RETURN

*-------------------------------------------------------------------------------
PROCESS:
*------

    T4.ModelBank.ENofileTcibAcListCorp(FINAL.ARRAY)

    IF FINAL.ARRAY  THEN
        Y.ACCID=FINAL.ARRAY
        CHANGE @FM TO ' ' IN Y.ACCID
        ENQ.DATA<2,1> = 'ACCOUNT.TO'
        ENQ.DATA<3,1> = 'EQ'
        ENQ.DATA<4,1> = Y.ACCID
    END
    RETURN

    END
