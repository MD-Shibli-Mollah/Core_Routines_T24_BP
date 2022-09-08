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
* <Rating>181</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE MD.Foundation
    SUBROUTINE CONV.MD.BALANCES.R13(MD.ID, MD.BAL.REC, SLL.FILE)
*---------------------------------------------------------------
*** <region name= Modifications>
*** <desc> </desc>
*
* Modifications
* 12/04/13 - TASK : 649481
*            Don't use inserts instead equate the positions.
*            REF : 649264
*
*** </region>
*-------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>Inserts </desc>

    $INSERT I_COMMON
    $INSERT I_EQUATE
    EQU MD.BAL.NEXT.SETTLE.ID TO 54
    EQU MD.BAL.CHARGE.SEQ TO 9
    EQU MD.BAL.CHARGE.DATE TO 4
    EQU MD.BAL.CHARGE.CODE TO 10
    EQU MD.BAL.TOT.CSN.AMOUNT TO 51
    EQU MD.BAL.PAST.SCHED.DATE TO 30
    EQU MD.BAL.PAST.SCHED.TYPE TO 32
    EQU MD.DEA.RETURN.COMM TO 145
    EQU MD.BAL.PAST.SCHED.AMT TO 31

*** </region>
***************************************************************************************
*** <region name= PROGRAM>
*** <desc>PROGRAM </desc>
    GOSUB MAIN.PROGRAM

    RETURN

*** </region>
***************************************************************************************
*** <region name=Main Program>
*** <desc>Update new fields related to Fee Settlement application</desc>
*************
MAIN.PROGRAM:
*************
*Updation of Next Refund Id

    IF MD.BAL.REC<MD.BAL.NEXT.SETTLE.ID> EQ '' THEN
        MD.BAL.REC<MD.BAL.NEXT.SETTLE.ID> = '01'
    END

*Updation of Charge Sequence
    IF MD.BAL.REC<MD.BAL.CHARGE.SEQ> EQ '' THEN
        NO.OF.CHGS = DCOUNT(MD.BAL.REC<MD.BAL.CHARGE.DATE>,@VM)
        CHARGE.SEQUENCE = 1
        FOR CHG = 1 TO NO.OF.CHGS

            NO.OF.CHG.CODE = DCOUNT(MD.BAL.REC<MD.BAL.CHARGE.CODE,CHG>,@SM)
            FOR CHG.CODE = 1 TO NO.OF.CHG.CODE
                IF CHG NE 1 AND CHG.CODE EQ 1 THEN
                    NO.OF.PAST.CH = DCOUNT(MD.BAL.REC<MD.BAL.CHARGE.CODE,CHG-1>,@SM)
                    CHARGE.SEQUENCE = MD.BAL.REC<MD.BAL.CHARGE.SEQ,CHG-1,NO.OF.PAST.CH>
                    CHARGE.SEQUENCE += 1
                END
                MD.BAL.REC<MD.BAL.CHARGE.SEQ,CHG,CHG.CODE> = CHARGE.SEQUENCE
                CHARGE.SEQUENCE = CHARGE.SEQUENCE + 1
            NEXT CHG.CODE
        NEXT CHG
    END

*Updation of Total Csn amount field
    R.MD.DEAL = ''
    F.MD.DEAL = ''
    CALL F.READ('F.MD.DEAL',MD.ID,R.MD.DEAL,F.MD.DEAL,MD.ERR)
    IF MD.BAL.REC<MD.BAL.TOT.CSN.AMOUNT> EQ '' THEN
        NO.OF.COMM = DCOUNT(MD.BAL.REC<MD.BAL.PAST.SCHED.DATE>,@VM)
        FOR COMM = 1 TO NO.OF.COMM
            IF MD.BAL.REC<MD.BAL.PAST.SCHED.TYPE,COMM> EQ 'CSN' THEN
                IF R.MD.DEAL<MD.DEA.RETURN.COMM> EQ 'YES' THEN        ;*If return commission is yes then add all the past commission amounts.
                    MD.BAL.REC<MD.BAL.TOT.CSN.AMOUNT> += MD.BAL.REC<MD.BAL.PAST.SCHED.AMT,COMM>
                END ELSE
                    IF MD.BAL.REC<MD.BAL.PAST.SCHED.AMT,COMM> GT 0 THEN         ;*If return commission is NO then update only the collected amount not with the amount moved to P/L.
                        MD.BAL.REC<MD.BAL.TOT.CSN.AMOUNT> += MD.BAL.REC<MD.BAL.PAST.SCHED.AMT,COMM>
                    END
                END
            END
        NEXT COMM
    END
    RETURN
**************************************************************************************
