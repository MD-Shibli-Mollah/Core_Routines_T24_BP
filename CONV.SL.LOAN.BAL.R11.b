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
* <Rating>-4</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SL.Contract
    SUBROUTINE CONV.SL.LOAN.BAL.R11(LN.ID, LN.REC, SLL.FILE)
*-----------------------------------------------------------------------------
*** <region name= Modifications>
*** <desc> </desc>
*
* 13/04/13 - TASK : 649841
*            Don't use inserts instead equate the positions.
*            REF : 649264
*
*
* Modifications
*** </region>
*** <region name= Inserts>
*** <desc>Inserts </desc>

    $INSERT I_COMMON
    $INSERT I_EQUATE
    EQU SLB.RATE.EFF.DT TO 20
    EQU SLB.INT.BASIS TO 19
    EQU SL.LN.INTEREST.BASIS TO 24
*** </region>
*** <region name= Initialise>
*** <desc>Initialise </desc>

    FN.SL.LOANS = 'F.SL.LOANS'
    FV.SL.LOANS = ''
    SL.LOANS.REC = ''
    LOAN.ERR1 = ''
    LOAN.ERR2 = ''
    CALL F.READ(FN.SL.LOANS,LN.ID,SL.LOANS.REC,FV.SL.LOANS,LOAN.ERR1)
    IF NOT(SL.LOANS.REC) THEN
        FN.SL.LOANS$NAU = 'F.SL.LOANS$NAU'
        FV.SL.LOANS$NAU = ''
        CALL F.READ(FN.SL.LOANS$NAU,LN.ID,SL.LOANS.REC,FV.SL.LOANS$NAU,LOAN.ERR2)
    END

*** </region>
*** <region name= Main Program>
*** <desc>Main Program </desc>

    EFF.DATE.CNT = DCOUNT(LN.REC<SLB.RATE.EFF.DT>,VM)
    FOR I = 1 TO EFF.DATE.CNT
        LN.REC<SLB.INT.BASIS,I> = SL.LOANS.REC<SL.LN.INTEREST.BASIS>
    NEXT I

*** </region>
    RETURN
    END
