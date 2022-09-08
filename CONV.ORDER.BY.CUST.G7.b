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
* <Rating>418</Rating>
*-----------------------------------------------------------------------------
* Version 4 02/06/00  GLOBUS Release No. 200508 30/06/05
*
    $PACKAGE SC.SctModelling
      SUBROUTINE CONV.ORDER.BY.CUST.G7
*
* This routine will map G6 ORDER.BY.CUST fields into the G7 format.
*
$INSERT I_COMMON
$INSERT I_EQUATE
*
      GOSUB INITIALISE
*
      GOSUB PROCESS.LIVE
      GOSUB PROCESS.NAU
      GOSUB PROCESS.HIS
*
      RETURN                             ; * Exit program
*
*----------
INITIALISE:
*----------
*
      FN.ORDER.BY.CUST = 'F.ORDER.BY.CUST'
      F.ORDER.BY.CUST = ''
      CALL OPF(FN.ORDER.BY.CUST,F.ORDER.BY.CUST)
*
      FN.ORDER.BY.CUST$NAU = 'F.ORDER.BY.CUST$NAU'
      F.ORDER.BY.CUST$NAU = ''
      CALL OPF(FN.ORDER.BY.CUST$NAU,F.ORDER.BY.CUST$NAU)
      FN.ORDER.BY.CUST$HIS = 'F.ORDER.BY.CUST$HIS'
      F.ORDER.BY.CUST$HIS = ''
      CALL OPF(FN.ORDER.BY.CUST$HIS,F.ORDER.BY.CUST$HIS)
      F.SC.TRANS.TYPE = ''
      CALL OPF('F.SC.TRANS.TYPE',F.SC.TRANS.TYPE)
      F.SC.TRA.CODE = ''
      CALL OPF('F.SC.TRA.CODE',F.SC.TRA.CODE)
*
      RETURN
*
*------------
PROCESS.LIVE:
*------------
*
      F.CURRENT.FILE = F.ORDER.BY.CUST
      FN.CURRENT.FILE = FN.ORDER.BY.CUST
      GOSUB PROCESS.RECORDS
*
      RETURN
*
*------------
PROCESS.NAU:
*------------
*
      F.CURRENT.FILE = F.ORDER.BY.CUST$NAU
      FN.CURRENT.FILE = FN.ORDER.BY.CUST$NAU
      GOSUB PROCESS.RECORDS
*
      RETURN
*
*------------
PROCESS.HIS:
*------------
*
      F.CURRENT.FILE = F.ORDER.BY.CUST$HIS
      FN.CURRENT.FILE = FN.ORDER.BY.CUST$HIS
      GOSUB PROCESS.RECORDS
*
      RETURN
*
*---------------
PROCESS.RECORDS:
*---------------
*
      STUFF = ''
      ID.LIST = ''
      TOTAL.SELECTED = ''
      CMMND = 'SELECT ':FN.CURRENT.FILE
      CALL EB.READLIST(CMMND,ID.LIST,'',TOTAL.SELECTED,STUFF)
*
      LOOP
         REMOVE ORDER.BY.CUST.ID FROM ID.LIST SETTING MORE
      WHILE ORDER.BY.CUST.ID:MORE DO
         READ R.ORDER.BY.CUST FROM F.CURRENT.FILE,ORDER.BY.CUST.ID THEN
            IF NOT(R.ORDER.BY.CUST<1>) THEN
               R.ORDER.BY.CUST<30> = R.ORDER.BY.CUST<6>
               R.SC.TRA.CODE = ''
               READ R.SC.TRA.CODE FROM F.SC.TRA.CODE,R.ORDER.BY.CUST<18> THEN
                  R.SC.TRANS.TYPE = ''
                  READ R.SC.TRANS.TYPE FROM F.SC.TRANS.TYPE,R.SC.TRA.CODE<1> THEN
                     CONVERT VM TO SM IN R.ORDER.BY.CUST<31>
                     CONVERT VM TO SM IN R.ORDER.BY.CUST<32>
                     CONVERT VM TO SM IN R.ORDER.BY.CUST<33>
                     CONVERT VM TO SM IN R.ORDER.BY.CUST<34>
                     CONVERT VM TO SM IN R.ORDER.BY.CUST<35>
                     CONVERT VM TO SM IN R.ORDER.BY.CUST<36>
                     CONVERT VM TO SM IN R.ORDER.BY.CUST<37>
                     CONVERT VM TO SM IN R.ORDER.BY.CUST<38>
                     CONVERT VM TO SM IN R.ORDER.BY.CUST<39>
                     TRANS.COUNT = DCOUNT(R.ORDER.BY.CUST<34>,SM)
                     FOR CT = 1 TO TRANS.COUNT
                        R.ORDER.BY.CUST<34,1,CT> = R.ORDER.BY.CUST<18>
                     NEXT CT
                     IF R.ORDER.BY.CUST<18> = R.SC.TRANS.TYPE<1> THEN  ; * DEBIT
                        R.ORDER.BY.CUST<8> = R.ORDER.BY.CUST<7>
                        R.ORDER.BY.CUST<7> = R.ORDER.BY.CUST<13>
                        R.ORDER.BY.CUST<13> = ''
                        R.ORDER.BY.CUST<1> = 'SELL'
                     END
                     IF R.ORDER.BY.CUST<18> = R.SC.TRANS.TYPE<3> THEN  ; * CREDIT
                        R.ORDER.BY.CUST<12> = R.ORDER.BY.CUST<7>
                        R.ORDER.BY.CUST<7> = ''
                        R.ORDER.BY.CUST<11> = R.ORDER.BY.CUST<13>
                        R.ORDER.BY.CUST<13> = ''
                        R.ORDER.BY.CUST<19> = R.ORDER.BY.CUST<18>
                        R.ORDER.BY.CUST<18> = ''
                        R.ORDER.BY.CUST<10> = R.ORDER.BY.CUST<6>
                        R.ORDER.BY.CUST<6> = ''
                        R.ORDER.BY.CUST<1> = 'PURCHASE'
                     END
                  END
               END
               WRITE R.ORDER.BY.CUST ON F.CURRENT.FILE,ORDER.BY.CUST.ID
            END
         END
      REPEAT
*
      RETURN
*
   END
