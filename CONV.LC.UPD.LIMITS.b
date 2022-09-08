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

* Version 4 15/05/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>153</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.Limits
      SUBROUTINE CONV.LC.UPD.LIMITS(LC.ID)

$INSERT I_EQUATE
$INSERT I_COMMON
$INSERT I_F.ACCOUNT
$INSERT I_F.CUSTOMER

      EQU TF.LC.CON.CUS.LINK TO 18
      EQU TF.LC.LC.CURRENCY TO 20
      EQU TF.LC.EXPIRY.DATE TO 28
      EQU TF.LC.PORT.LIM.REF TO 73
      EQU TF.LC.PROVIS.ACC TO 140
      EQU TF.LC.LIABILITY.AMT TO 177
      EQU TF.LC.PRO.OUT.AMOUNT TO 145
      EQU TF.LC.PRO.AWAIT.REL TO 146
      EQU TF.LC.OVERRIDE TO 191
      EQU TF.LC.AUDIT.DATE.TIME TO 200

! This conversion is to reverse the lc limit and recreate the lc
! limit with provision effect
! Set running under batch since you might get overrides like excess

      ROB=RUNNING.UNDER.BATCH
      RUNNING.UNDER.BATCH=1
      CUSTOMER.NUMBER = R.NEW(TF.LC.CON.CUS.LINK)
      LIAB.NO = ""

      RETURN.CODE = ""
      IF NOT(CUSTOMER.NUMBER) THEN
         RETURN
      END

      GOSUB INIT
      GOSUB PROCESS.LIMITS
      RUNNING.UNDER.BATCH=ROB
      RETURN
*********************************************************************
INIT:
*********************************************************************

      V.LC=TF.LC.AUDIT.DATE.TIME
      V=TF.LC.AUDIT.DATE.TIME
*      YFILE.NAME='F.LETTER.OF.CREDIT'
*      CALL OPF(YFILE.NAME,F.LETTER.OF.CREDIT)
*
*! Select only the outstanding lc's with provision
*      SEL.COMM = 'SELECT ':YFILE.NAME:' WITH EXPIRY.DATE GE ':TODAY:' AND LIABILITY.AMT NE 0 AND  PROVIS.ACC NE ""'
*      NO.RECS = 0
*      LC.LISTS = ''
*      CALL EB.READLIST(SEL.COMM, LC.LISTS, 'LCLIST', NO.RECS, '')
      RETURN
*********************************************************************
PROCESS.LIMITS:
*********************************************************************

*
* Mergin into Conversion Programs, called from CONV.MIX.PAY.SET
*
*      LOOP
*         REMOVE ID FROM LC.LISTS SETTING CODE
*      WHILE ID
*         ID.NEW=ID
*         CALL F.MATREADU("F.LETTER.OF.CREDIT",ID.NEW,MAT R.NEW,
*            V.LC,F.LETTER.OF.CREDIT,ETEXT,"")
*         IF ETEXT THEN
*            ETEXT = "MISSING FILE = F.LETTER.OF.CREDIT ID =":ID.NEW
*!               GOTO FATAL.ERROR
*         END
      YPROV.ACC=R.NEW(TF.LC.PROVIS.ACC)
      CALL DBR("ACCOUNT":FM:AC.CURRENCY,YPROV.ACC,YPROV.CCY)
! Only fccy provsion needs to be rebuilt
      IF YPROV.CCY NE LCCY THEN
*         PRINT "REF":ID.NEW
         GOSUB SET.LIMIT.PARAM

!LIMIT.AMOUNT=LIAB.AMT
         LIMIT.AMOUNT=R.NEW(TF.LC.LIABILITY.AMT)
!REV THE LIMITS
         CALL LIMIT.CHECK(LIAB.NO,CUSTOMER.NUMBER,
            REF.NO, SERIAL.NO, LC.ID,
            YTIME.BAND, R.NEW(TF.LC.LC.CURRENCY),
            -LIMIT.AMOUNT,'','','','','','',LC.YCURR.NO,'','',
            'DEL',RETURN.CODE)

!UPDATE NEW LIMITS
!LIMIT.AMOUNT=LIAB.AMT-OS.PROVISION-AWAIT.PROV (ALL IN LC CCY)
*
         LC.CCY=R.NEW(TF.LC.LC.CURRENCY)
         YPROV.LC.CCY=''
         CCY.MKT='1'
         LOCAL.AMT=''
         EXCH.RATE=''
         LC.YCURR.NO=DCOUNT(R.NEW(TF.LC.OVERRIDE),VM)
!            LC.YCURR.NO=''
         YPROV.AMT=R.NEW(TF.LC.PRO.OUT.AMOUNT)
         IF YPROV.AMT THEN
            CALL EXCHRATE(CCY.MKT,YPROV.CCY,YPROV.AMT,LC.CCY,YPROV.LC.CCY,'',
               EXCH.RATE,'',LOCAL.AMT,'')

            YPROV.OS.AMT=YPROV.LC.CCY
         END ELSE
            YPROV.OS.AMT=''
         END
         YPROV.AMT=R.NEW(TF.LC.PRO.AWAIT.REL)
         YPROV.LC.CCY=''
         EXCH.RATE=''
         LC.YCURR.NO=DCOUNT(R.NEW(TF.LC.OVERRIDE),VM)
!            LC.YCURR.NO=''
         LOCAL.AMT=''
         IF YPROV.AMT THEN
            CALL EXCHRATE(CCY.MKT,YPROV.CCY,YPROV.AMT,LC.CCY,YPROV.LC.CCY,'',
               EXCH.RATE,'',LOCAL.AMT,'')
            YPROV.AWAIT.REL=YPROV.LC.CCY
         END ELSE
            YPROV.AWAIT.REL=''
         END
*
         LIMIT.AMOUNT=R.NEW(TF.LC.LIABILITY.AMT)-(YPROV.OS.AMT-YPROV.AWAIT.REL)
         IF LIMIT.AMOUNT GT 0 THEN
            CALL LIMIT.CHECK(LIAB.NO,CUSTOMER.NUMBER,REF.NO,SERIAL.NO,
               LC.ID,YTIME.BAND,R.NEW(TF.LC.LC.CURRENCY),
               -LIMIT.AMOUNT,'','','','','','',LC.YCURR.NO,'','',
               'VAL', RETURN.CODE)
         END
      END
!         CALL JOURNAL.UPDATE(ID.NEW)
*      REPEAT
      RETURN
*********************************************************************
SET.LIMIT.PARAM:
*********************************************************************
*

      CALL DBR("CUSTOMER":FM:EB.CUS.CUSTOMER.LIABILITY,
         CUSTOMER.NUMBER,LIAB.NO)

      POS=INDEX(R.NEW(TF.LC.PORT.LIM.REF)<1,1>,'.',1)
      REF.NO=R.NEW(TF.LC.PORT.LIM.REF)<1,1>[1,POS-1]
      SERIAL.NO=R.NEW(TF.LC.PORT.LIM.REF)<1,1>[POS+1,9]
      YTIME.BAND=R.NEW(TF.LC.EXPIRY.DATE)
      RETURN
*********************************************************************
   END
