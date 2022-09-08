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

* Version 6 15/05/01  GLOBUS Release No. 200511 31/10/05
*-----------------------------------------------------------------------------
* <Rating>367</Rating>
*-----------------------------------------------------------------------------
* 15/01/13 - Defect:522762 Task:524855
*            Component Reclassification
*            File variable LIQD.SETTLE.DATE is made obsolete
*
* 12/02/15 - Defect:1250871 / Task: 1252690
*            !HUSHIT is not supported in TAFJ, hence changed to use HUSHIT(). 
*
    $PACKAGE SC.ScoFoundation
    SUBROUTINE CONV.MULTI.SC.FILES
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
*
*************************************************************************
*
    YFILE.CONTROL = "F.FILE.CONTROL" ; YLASTFIELDNO = '' ; YNEWFIELDNO = ''
    Y.FC.WRITE = ''
    Y.FIRST.DELETE = 1
    Y.SL = ''
*
*     F.FILE.CONTROL = ""
*     CALL OPF (YFILE.CONTROL, F.FILE.CONTROL)
*
    OPEN '','VOC' TO F.VOC ELSE
        YTXT = 'UNABLE TO OPEN THE VOC FILE'
        GOTO FATAL.ERROR:
    END
*
    OPEN '','&SAVEDLISTS&' TO F.SL ELSE
        YTXT = 'UNABLE TO OPEN THE &SAVEDLISTS& FILE'
        GOTO FATAL.ERROR:
    END
*
    Y1ST.FIELD.CANCEL = "" ; YLAST.FIELD.CANCEL = ""
    DIM YFILES.LIST(84)
    MAT YFILES.LIST = ''
    Z = 0
    Z += 1 ; YFILES.LIST(Z) = 'ASSET.TYPE'
    Z += 1 ; YFILES.LIST(Z) = 'VAL.INTERFACE'
    Z += 1 ; YFILES.LIST(Z) = 'SUB.ASSET.TYPE'
    Z += 1 ; YFILES.LIST(Z) = 'ASSET.BREAK'
    Z += 1 ; YFILES.LIST(Z) = 'ASSET.BY.CATEG'
    Z += 1 ; YFILES.LIST(Z) = 'PRICE.TYPE'
    Z += 1 ; YFILES.LIST(Z) = 'PRICE.UPDATE'
    Z += 1 ; YFILES.LIST(Z) = 'MARGIN.CONTROL'
    Z += 1 ; YFILES.LIST(Z) = 'MANAGED.ACCOUNT'
    Z += 1 ; YFILES.LIST(Z) = 'INVESTMENT.PROGRAM'
    Z += 1 ; YFILES.LIST(Z) = 'COUPON.TAX.CODE'
    Z += 1 ; YFILES.LIST(Z) = 'SC.REPORT.TYPE'
    Z += 1 ; YFILES.LIST(Z) = 'NOMINEE.CODE'
    Z += 1 ; YFILES.LIST(Z) = 'SC.DEL.INSTR'
    Z += 1 ; YFILES.LIST(Z) = 'SC.TRANS.NAME'
    Z += 1 ; YFILES.LIST(Z) = 'SC.TRANS.TYPE'
    Z += 1 ; YFILES.LIST(Z) = 'SC.TRA.CODE'
    Z += 1 ; YFILES.LIST(Z) = 'SC.INDUSTRY'
    Z += 1 ; YFILES.LIST(Z) = 'POLICY.PARAMETER'
    Z += 1 ; YFILES.LIST(Z) = 'TRANS.FUND.FLOW'
    Z += 1 ; YFILES.LIST(Z) = 'SC.REPORT.VAR'
**      Z += 1 ; YFILES.LIST(Z) = 'BROKER.COMM.EARNT'
    Z += 1 ; YFILES.LIST(Z) = 'DIV.COUP.TYPE'
    Z += 1 ; YFILES.LIST(Z) = 'DIV.COUP.TAX'
    Z += 1 ; YFILES.LIST(Z) = 'STOCK.DIV.TYPE'
    Z += 1 ; YFILES.LIST(Z) = 'REDEMPTION.TYPE'
    Z += 1 ; YFILES.LIST(Z) = 'CAPTL.INCREASE.TYP'
    Z += 1 ; YFILES.LIST(Z) = 'NI.ISSUE.TYPE'
    Z += 1 ; YFILES.LIST(Z) = 'NI.REALLOWANCE.TYP'
    Z += 1 ; YFILES.LIST(Z) = 'NI.BORROWER.TYPE'
    Z += 1 ; YFILES.LIST(Z) = 'STOCK.EXCHANGE'
    Z += 1 ; YFILES.LIST(Z) = 'STK.EXC.AT'
    Z += 1 ; YFILES.LIST(Z) = 'STK.EXC.AU'
    Z += 1 ; YFILES.LIST(Z) = 'STK.EXC.BE'
    Z += 1 ; YFILES.LIST(Z) = 'STK.EXC.CA'
    Z += 1 ; YFILES.LIST(Z) = 'STK.EXC.CH'
    Z += 1 ; YFILES.LIST(Z) = 'STK.EXC.DK'
    Z += 1 ; YFILES.LIST(Z) = 'STK.EXC.FR'
    Z += 1 ; YFILES.LIST(Z) = 'STK.EXC.DE'
    Z += 1 ; YFILES.LIST(Z) = 'STK.EXC.ES'
    Z += 1 ; YFILES.LIST(Z) = 'STK.EXC.HK'
    Z += 1 ; YFILES.LIST(Z) = 'STK.EXC.IT'
    Z += 1 ; YFILES.LIST(Z) = 'STK.EXC.JP'
    Z += 1 ; YFILES.LIST(Z) = 'STK.EXC.LU'
    Z += 1 ; YFILES.LIST(Z) = 'STK.EXC.MX'
    Z += 1 ; YFILES.LIST(Z) = 'STK.EXC.NL'
    Z += 1 ; YFILES.LIST(Z) = 'STK.EXC.SG'
    Z += 1 ; YFILES.LIST(Z) = 'STK.EXC.ZA'
    Z += 1 ; YFILES.LIST(Z) = 'STK.EXC.LOCAL'
    Z += 1 ; YFILES.LIST(Z) = 'STK.EXC.US'
    Z += 1 ; YFILES.LIST(Z) = 'SAFECUSTODY.VALUES'
    Z += 1 ; YFILES.LIST(Z) = 'SECURITY.MASTER'
    Z += 1 ; YFILES.LIST(Z) = 'SECURITY.SUPP'
    Z += 1 ; YFILES.LIST(Z) = 'MNEMONIC.SECURITY'
    Z += 1 ; YFILES.LIST(Z) = 'SC.ISIN.NO.CON'
    Z += 1 ; YFILES.LIST(Z) = 'SC.EUCLID.NO.CON'
    Z += 1 ; YFILES.LIST(Z) = 'SC.CEDEL.NO.CON'
    Z += 1 ; YFILES.LIST(Z) = 'SC.SEDOL.NO.CON'
    Z += 1 ; YFILES.LIST(Z) = 'SC.TELEKURS.CODE'
    Z += 1 ; YFILES.LIST(Z) = 'SC.CUSIP.NO.CON'
    Z += 1 ; YFILES.LIST(Z) = 'NEW.ISSUE.MASTER'
    Z += 1 ; YFILES.LIST(Z) = 'SC.REPORTS.REQUEST'
    Z += 1 ; YFILES.LIST(Z) = 'BOND.RED.WF'
    Z += 1 ; YFILES.LIST(Z) = 'DIV.COUP.WF'
    Z += 1 ; YFILES.LIST(Z) = 'STOCK.DIV.WF'
    Z += 1 ; YFILES.LIST(Z) = 'SC.CALCULATE.CPN'
    Z += 1 ; YFILES.LIST(Z) = 'SC.RATING'
*
    Z += 1 ; YFILES.LIST(Z) = 'SC.POS.ASSET'
    Z += 1 ; YFILES.LIST(Z) = 'SC.POS.ASSET.PRICE'
    Z += 1 ; YFILES.LIST(Z) = 'SC.CASH.FLOW01'
    Z += 1 ; YFILES.LIST(Z) = 'SC.CASH.FLOW02'
    Z += 1 ; YFILES.LIST(Z) = 'SC.CASH.FLOW03'
    Z += 1 ; YFILES.LIST(Z) = 'SC.CASH.FLOW04'
    Z += 1 ; YFILES.LIST(Z) = 'SC.CASH.FLOW05'
    Z += 1 ; YFILES.LIST(Z) = 'SC.CASH.FLOW06'
    Z += 1 ; YFILES.LIST(Z) = 'SC.CASH.FLOW07'
    Z += 1 ; YFILES.LIST(Z) = 'SC.CASH.FLOW08'
    Z += 1 ; YFILES.LIST(Z) = 'SC.CASH.FLOW09'
    Z += 1 ; YFILES.LIST(Z) = 'SC.CASH.FLOW10'
    Z += 1 ; YFILES.LIST(Z) = 'SC.CASH.FLOW11'
    Z += 1 ; YFILES.LIST(Z) = 'SC.CASH.FLOW12'
*
    GOSUB MODIFY.FILE
*
    RETURN
*
*************************************************************************
*
MODIFY.FILE:
*
    TEXT = "" ; YFILE.SAVE = YFILE ; YFILE.ADD = "" ; YLOOP = "Y"
    FOR YF = 1 TO Z UNTIL YLOOP <> 'Y'
        GOSUB MODIFY.FILE.START
    NEXT YF
*
*     IF NOT(Y.FIRST.DELETE) THEN
*        IF Y.DELETE.FILES = 'Y' THEN
*           IF Y.SL THEN
*              WRITE Y.SL TO F.SL,'MULTI.COMPANY.FILES.DELETE'
*           END
*        END
*     END
    RETURN
*
*************************************************************************
*
MODIFY.FILE.START:
*
    Y.FC.WRITE = ''
    YFILE = YFILES.LIST(YF)
    CALL SF.CLEAR.STANDARD
    CALL SF.CLEAR(1,5,"FILE RUNNING:  ":YFILE)
*
    READ Y.FILE.CONTROL FROM F.FILE.CONTROL, YFILE
    ELSE
    YTXT = 'FILE ':YFILE:' MISSING IN ':YFILE.CONTROL
    GOTO FATAL.ERROR:
    END
*
    IF Y.FILE.CONTROL<6> = 'INT' THEN
*** Conversion already done....
        TEXT = "CONVERSION ALREADY DONE"
        CALL OVE
        YLOOP = TEXT
        RETURN
    END
*
    Y.OLD.TYPE = Y.FILE.CONTROL<6>
    Y.FILE.CONTROL<6> = 'INT'
    WRITE Y.FILE.CONTROL TO F.FILE.CONTROL, YFILE
    Y.FC.WRITE = 1
*
    LOCATE Y.FILE.CONTROL<2> IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING YPOS
        ELSE
        YPOS = ''
    END
*
    IF YPOS = '' THEN
        RETURN
    END
*
    Y.OLD.FILE = 'F':R.COMPANY(EB.COM.MNEMONIC):'.':YFILE
    Y.NEW.FILE = 'F.':YFILE
    GOSUB CREATE.NEW.FILE:
*
    IF Y.FILE.CONTROL<3> <> '' THEN
        Y.COUNT = COUNT(Y.FILE.CONTROL<3>,VM) + 1
        FOR YI = 1 TO Y.COUNT
            Y.FILE.ADD = Y.FILE.CONTROL<3,YI>
            Y.OLD.FILE = 'F':R.COMPANY(EB.COM.MNEMONIC):'.':YFILE:Y.FILE.ADD
            Y.NEW.FILE = 'F.':YFILE:Y.FILE.ADD
            GOSUB CREATE.NEW.FILE:
        NEXT YI
    END
    RETURN
*
*************************************************************************
CREATE.NEW.FILE:
*--------------
    IF Y.FIRST.DELETE THEN
        Y.FIRST.DELETE = ''
        YSAVE.TEXT = TEXT
        TEXT = 'DO YOU WANT TO DELETE THE OLD SOURCE FILES ?'
        CALL OVE
        IF TEXT = 'Y' THEN Y.DELETE.FILES = 'Y'
        ELSE Y.DELETE.FILES = 'N'
        TEXT = YSAVE.TEXT
    END
*
    CALL SF.CLEAR(1,6,"CREATING NEW FILE:  ":Y.NEW.FILE)
    Y.OUT.FILE = Y.NEW.FILE
    YTXT = ""
*     CALL HUSHIT(1)
*     CALL EBS.CREATE.FILE(Y.OUT.FILE,"DATA",YTXT)
*     CALL HUSHIT(0)
*
*     IF YTXT THEN
*        GOTO FATAL.ERROR:
*     END
*
    READ R.VOC FROM F.VOC, Y.OLD.FILE ELSE
        YTXT = 'UNABLE TO READ THE VOC ENTRY FOR THE FILE ':Y.OLD.FILE
        GOTO FATAL.ERROR:
    END
*
    Y.OLD.UNIX.FILE = R.VOC<2>
    Y.SLSH = COUNT(R.VOC<2>,'/')
    Y.LAST.COMP = FIELD(R.VOC<2>,'/',(Y.SLSH + 1))
    Y.NEW.LAST.COMP = 'F.':FIELD(Y.LAST.COMP,'.',2,99999)
    Y.NEW.UNIX.FILE = FIELD(R.VOC<2>,'/',1,Y.SLSH):'/':Y.NEW.LAST.COMP
    Y.OLD.PATH = "'": Y.OLD.UNIX.FILE: "'"
    Y.NEW.PATH = "'": Y.NEW.UNIX.FILE: "'"
    IF Y.DELETE.FILES = 'Y' THEN
        Y.EXEC.CMD = 'SH -c "mv ':Y.OLD.PATH:' ':Y.NEW.PATH:'"'
    END ELSE
        Y.EXEC.CMD = 'SH -c "cp ':Y.OLD.PATH:' ':Y.NEW.PATH:'"'
    END
    PRINT @(1,15):Y.EXEC.CMD
    EXECUTE Y.EXEC.CMD
    IF @SYSTEM.RETURN.CODE < 0 THEN
        YTXT= Y.EXEC.CMD:' FAILED'
        GOTO FATAL.ERROR:
    END
    Y.VOC = R.VOC
    Y.VOC<2> = Y.NEW.UNIX.FILE
*
    WRITE Y.VOC TO F.VOC, Y.NEW.FILE
*
***** Delete the old file...
**    CALL SF.CLEAR(1,7,"COPYING FROM ":Y.OLD.FILE:" TO ":Y.NEW.FILE)
*     Y.EXEC = 'COPY FROM ':Y.OLD.FILE:' TO ':Y.NEW.FILE:' ALL'
**    CALL HUSHIT(1)
*     EXECUTE Y.EXEC
*     Y.SRC = @SYSTEM.RETURN.CODE
*     CALL HUSHIT(0)
*
*     IF Y.SRC < 0 THEN
*        YTXT = 'COPY FAILED...'
*        GOTO FATAL.ERROR:
*     END
*
    IF Y.DELETE.FILES = 'Y' THEN
        CALL SF.CLEAR(1,8,"DELETING OLD FILE:  ":Y.OLD.FILE)
        *        Y.SL<-1> = R.VOC<2>
        *        CALL HUSHIT(1)
        *        EXECUTE 'DELETE.FILE DATA ':Y.OLD.FILE
        *        Y.SRC = @SYSTEM.RETURN.CODE
        *        CALL HUSHIT(0)
        DELETE F.VOC,Y.OLD.FILE
    END
*
    RETURN
*************************************************************************
FATAL.ERROR:
*
    IF Y.FC.WRITE THEN
        Y.FILE.CONTROL<6> = Y.OLD.TYPE
        WRITE Y.FILE.CONTROL TO F.FILE.CONTROL, YFILE
    END
    CALL SF.CLEAR(8,22,YTXT)
    CALL PGM.BREAK
*
*************************************************************************
    END
