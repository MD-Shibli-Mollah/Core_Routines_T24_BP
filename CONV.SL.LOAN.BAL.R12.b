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
    SUBROUTINE CONV.SL.LOAN.BAL.R12(LN.ID, LN.REC, SLL.FILE)
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
*-------------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Inserts </desc>

    $INSERT I_COMMON
    $INSERT I_EQUATE
    EQU SLB.STRT.PRD.INT TO 11
    EQU SL.LN.INT.RATE.TYPE TO 23
    EQU SLB.FLT.INT.AMT TO 16
    EQU SLB.COMMITED.INT TO 15
    EQU SLB.RATE.EFF.DT TO 28
    EQU SLB.INT.RATE.TYPE TO 27
    EQU SLB.PRD.INT.AMT TO 17

*** </region>
*** <region name= Initialise>
*** <desc>Initialise </desc>

    FN.SL.LOANS = 'F.SL.LOANS'
    FV.SL.LOANS = ''
    SL.LOANS.REC = ''
    CALL F.READ(FN.SL.LOANS,LN.ID,SL.LOANS.REC,FV.SL.LOANS,'')

*** </region>
*** <region name= Main Program>
*** <desc>Main Program </desc>
    PERIOD.I = DCOUNT(LN.REC<SLB.STRT.PRD.INT>,VM)
    BEGIN CASE
        CASE SL.LOANS.REC<SL.LN.INT.RATE.TYPE> EQ '2'
            LN.REC<SLB.FLT.INT.AMT,PERIOD.I> = LN.REC<SLB.COMMITED.INT,PERIOD.I>
        CASE SL.LOANS.REC<SL.LN.INT.RATE.TYPE> EQ '3'
            LN.REC<SLB.PRD.INT.AMT,PERIOD.I> = LN.REC<SLB.COMMITED.INT,PERIOD.I>
    END CASE
    EFF.DATE.CNT = DCOUNT(LN.REC<SLB.RATE.EFF.DT>,VM)
    FOR I = 1 TO EFF.DATE.CNT
        LN.REC<SLB.INT.RATE.TYPE,I> = SL.LOANS.REC<SL.LN.INT.RATE.TYPE>
    NEXT I

*** </region>
    RETURN
    END
