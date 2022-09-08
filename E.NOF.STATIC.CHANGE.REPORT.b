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
* <Rating>-187</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.ModelBank
    
    SUBROUTINE E.NOF.STATIC.CHANGE.REPORT(GET.REP.ARRAY)
    
    *
* 10/05/16 - Enhancement 1499014
*          - Task 1626129
*          - Routine incorporated
    
    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.Logging
    $USING EB.API
    $USING EB.DataAccess
    $USING EB.LocalReferences

    GOSUB PROCESS
    RETURN
*------------------------------------------------------------
PROCESS:
*------------------------------------------------------------

    LOCATE "PROTOCOL" IN EB.Reports.getDFields()<1> SETTING SELET.POS THEN
        Y.SEL.ID.VAL = EB.Reports.getDRangeAndValue()<SELET.POS>
        Y.OPERAND = EB.Reports.getDLogicalOperands()<SELET.POS>
    END

    R.PROTOCOL.REC = '' ; Y.PROTOCOL.ERR = ''
    R.PROTOCOL.REC = EB.Logging.Protocol.Read(Y.SEL.ID.VAL, Y.PROTOCOL.ERR)

    IF NOT(Y.PROTOCOL.ERR) THEN
        GOSUB MAIN.PROCESS
    END

    RETURN
*------------------------------------------------------------
MAIN.PROCESS:
*------------------------------------------------------------

    Y.SEL.CONTRACT.VAL = R.PROTOCOL.REC<EB.Logging.Protocol.PtlId>          ;* Protocol ID
    Y.SEL.APP.VAL = '' ; Y.SEL.TIME.VAL = '' ; Y.SEL.FULL.TIME.VAL = ''
    Y.SEL.APP.VAL = R.PROTOCOL.REC<EB.Logging.Protocol.PtlApplication>
    Y.SEL.APP.VER.VAL = FIELD(Y.SEL.APP.VAL,',',2,1)
    Y.SEL.APP.VAL = FIELD(Y.SEL.APP.VAL,',',1,1)
    Y.SEL.APP.USER = R.PROTOCOL.REC<EB.Logging.Protocol.PtlUser>  ;* User value
    Y.SEL.FULL.TIME.VAL = R.PROTOCOL.REC<EB.Logging.Protocol.PtlTime>
    Y.SEL.TIME.VAL = Y.SEL.FULL.TIME.VAL[1,4]     ;* PROCESS.TIME
    Y.SEL.PROCS.DATE.VAL = R.PROTOCOL.REC<EB.Logging.Protocol.PtlProcessDate>
    Y.SEL.RECORD.CUR.NUM.VAL = FIELD(Y.SEL.CONTRACT.VAL,';',2)        ;* get the curr no
    Y.SEL.CONTRACT.VAL = FIELD(Y.SEL.CONTRACT.VAL,';',1)    ;* get the application
    Y.SEL.TIME.VAL = R.PROTOCOL.REC<EB.Logging.Protocol.PtlTime>

    Y.SEL.COMP.ID.VAL = R.PROTOCOL.REC<EB.Logging.Protocol.PtlCompanyId>

    IF Y.SEL.RECORD.CUR.NUM.VAL GT 1 THEN         ;* Check the curr no is greater than 1
        Y.SEL.RECORD.PRV.NUM.VAL = Y.SEL.RECORD.CUR.NUM.VAL - 1

        FN.APPLN = 'F.':Y.SEL.APP.VAL
        F.APPLN = ''
        F.APPLN.HIS = ''
        FN.APPLN.HIS = 'F.':Y.SEL.APP.VAL:'$HIS'

        FN.APPLN.NAU = 'F.':Y.SEL.APP.VAL:'$NAU'
        F.APPLN.NAU = ''

        EB.DataAccess.Opf(FN.APPLN,F.APPLN)
        EB.DataAccess.Opf(FN.APPLN.HIS,F.APPLN.HIS)
        EB.DataAccess.Opf(FN.APPLN.NAU,F.APPLN.NAU)

        EB.API.GetStandardSelectionDets(Y.SEL.APP.VAL,R.SS.MASTER)
        Y.SS.FIELD.LIST = R.SS.MASTER<EB.SystemTables.StandardSelection.SslSysFieldName>
        GOSUB FETCH.AUDIT.FIELD.POS.VALUE.PROCESS ;* Fetch the audit field postion
        GOSUB CHECK.LATEST.REC.VALUE.PROCESS      ;* Check latest record value and process

    END
    RETURN
*------------------------------------------------------------
FETCH.AUDIT.FIELD.POS.VALUE.PROCESS:
*------------------------------------------------------------

    Y.CONT.FLD.NUM = '' ;  YAF = '' ;  YAV = '' ; YAS = '' ; DATA.TYPE = '' ; ERR.MSG = ''
    Y.CONT.AUDIT.FIELD = 'AUDIT.DATE.TIME'
    EB.API.FieldNamesToNumbers(Y.CONT.AUDIT.FIELD,R.SS.MASTER,Y.CONT.FLD.NUM,YAF,YAV,YAS,DATA.TYPE,ERR.MSG)  ;*get the field no

* Assigning the audit variables

    Y.CONT.RECORD.STATUS.FIELD.POS = Y.CONT.FLD.NUM - 8
    Y.CONT.CURR.NUM.POS = Y.CONT.FLD.NUM - 7
    Y.CONT.INPUT.FIELD.POS = Y.CONT.FLD.NUM - 6
    Y.CONT.DATE.TIME.POS = Y.CONT.FLD.NUM - 5
    Y.CONT.AUTH.POS = Y.CONT.FLD.NUM - 4
    Y.CONT.BR.CODE.POS = Y.CONT.FLD.NUM - 3
    Y.CONT.DEPT.CODE.POS = Y.CONT.FLD.NUM - 2
    Y.CONT.AUDITOR.CODE.POS = Y.CONT.FLD.NUM - 1
    Y.CONT.AUDIT.DATE.TIME.POS = Y.CONT.FLD.NUM
*Store the audit fields values in array
    Y.CONT.AUDIT.FIELDS.POS = Y.CONT.RECORD.STATUS.FIELD.POS:@VM:Y.CONT.CURR.NUM.POS:@VM:
    Y.CONT.AUDIT.FIELDS.POS:= Y.CONT.INPUT.FIELD.POS:@VM:Y.CONT.DATE.TIME.POS:@VM:Y.CONT.AUTH.POS:@VM:Y.CONT.BR.CODE.POS:@VM:
    Y.CONT.AUDIT.FIELDS.POS:= Y.CONT.DEPT.CODE.POS:@VM:Y.CONT.AUDITOR.CODE.POS:@VM:Y.CONT.AUDIT.DATE.TIME.POS

* check override is avalible
    Y.CONT.OVERRDE.NUM = ''
    Y.CONT.AUDIT.FIELD = 'OVERRIDE'
    EB.API.FieldNamesToNumbers(Y.CONT.AUDIT.FIELD,R.SS.MASTER,Y.CONT.OVERRDE.NUM,YAF,YAV,YAS,DATA.TYPE,ERR.MSG)
    IF Y.CONT.OVERRDE.NUM THEN
        Y.CONT.AUDIT.FIELDS.POS:= @VM:Y.CONT.OVERRDE.NUM
    END

    RETURN
*------------------------------------------------------------
CHECK.LATEST.REC.VALUE.PROCESS:
*------------------------------------------------------------
    R.CUR.NUM.FR.REC.VALUES = '' ; R.CUR.NUM.TO.REC.VALUES = ''
    GOSUB FETCH.CUR.TO.REC.VALUES       ;* Fetch the current record value
    Y.APPLN.ID = Y.SEL.CONTRACT.VAL:';': Y.SEL.RECORD.PRV.NUM.VAL
    IF R.CUR.NUM.FR.REC.VALUES EQ '' THEN
        GOSUB FETCH.CUR.FR.REC.VALUE.PROCESS      ;* Get the previous record value
        R.CUR.NUM.FR.REC.VALUES = R.PREV.REC.VALUES
    END

    IF (R.CUR.NUM.TO.REC.VALUES NE '' AND R.CUR.NUM.FR.REC.VALUES NE '') THEN   ;* check live and history record is availabe
        Y.CONT.INPUT.FIELD.VAL = R.CUR.NUM.TO.REC.VALUES<Y.CONT.INPUT.FIELD.POS>
        Y.CONT.INPUT.FIELD.VAL = FIELD(Y.CONT.INPUT.FIELD.VAL,'_',2,1)
        Y.CONT.DATE.TIME.VAL = R.CUR.NUM.TO.REC.VALUES<Y.CONT.DATE.TIME.POS>
        Y.CONT.AUTH.VAL = R.CUR.NUM.TO.REC.VALUES<Y.CONT.AUTH.POS>
        Y.CONT.AUTH.VAL = FIELD(Y.CONT.AUTH.VAL,'_',2,1)
        Y.CONT.BR.CODE.VAL = R.CUR.NUM.TO.REC.VALUES<Y.CONT.BR.CODE.POS>
        Y.CONT.DEPT.CODE.VAL = R.CUR.NUM.TO.REC.VALUES<Y.CONT.DEPT.CODE.POS>
        Y.COMPARE.OUT.VALUES = EQS(R.CUR.NUM.TO.REC.VALUES,R.CUR.NUM.FR.REC.VALUES)       ;* Compare the live record and history records
        GOSUB CHECK.CURR.PREV.VALUE.PROCESS       ;* check the Actual curr no value and pervious curr no value
    END
    RETURN
*------------------------------------------------------------
FETCH.CUR.TO.REC.VALUES:
*------------------------------------------------------------

    Y.APPLN.ID = Y.SEL.CONTRACT.VAL
    R.APPLN.REC = '' ; Y.APPLN.REC.ERR = ''
    EB.DataAccess.FRead(FN.APPLN,Y.APPLN.ID,R.APPLN.REC,F.APPLN,Y.APPLN.REC.ERR)
    IF R.APPLN.REC THEN
        R.CUR.NUM.TO.REC.VALUES = R.APPLN.REC
    END

    Y.LATEST.CURR.NO.VAL = R.CUR.NUM.TO.REC.VALUES<Y.CONT.CURR.NUM.POS>         ;* store the live record CURR.NO
    IF Y.LATEST.CURR.NO.VAL NE Y.SEL.RECORD.CUR.NUM.VAL THEN          ;* if curr not equal then, read the record form history
        Y.APPLN.ID = Y.SEL.CONTRACT.VAL:';':Y.SEL.RECORD.CUR.NUM.VAL
        GOSUB FETCH.CUR.FR.REC.VALUE.PROCESS
        R.CUR.NUM.TO.REC.VALUES = R.PREV.REC.VALUES

* If history record is not avaliable then read NAU record
        IF R.CUR.NUM.TO.REC.VALUES EQ '' THEN
            GOSUB FETCH.INAU.RECORDS
        END

    END
    RETURN
*-------------------------------------------------------------------------------------------------------
FETCH.INAU.RECORDS:
*******************
*History record is unavailable then check INAU record is availabe.

    R.APPLN.NAU.REC = '' ;  Y.APPLN.NAU.ERR = ''
    EB.DataAccess.FRead(FN.APPLN.NAU,Y.SEL.CONTRACT.VAL,R.APPLN.NAU.REC,F.APPLN.NAU,Y.APPLN.NAU.ERR)
    IF R.APPLN.NAU.REC THEN
        Y.NAU.CURR.NO = R.APPLN.NAU.REC<Y.CONT.CURR.NUM.POS>

        IF Y.NAU.CURR.NO EQ Y.SEL.RECORD.CUR.NUM.VAL THEN   ;* check protocol id curr.no is equal to INAU curr no.
            R.CUR.NUM.TO.REC.VALUES = R.APPLN.NAU.REC

*            Y.APPLN.ID = Y.SEL.CONTRACT.VAL
*            R.APPLN.REC = '' ; Y.APPLN.REC.ERR = '' ; R.CUR.NUM.FR.REC.VALUES = ''
*            CALL F.READ(FN.APPLN,Y.APPLN.ID,R.APPLN.REC,F.APPLN,Y.APPLN.REC.ERR)

            IF R.APPLN.REC THEN
                R.CUR.NUM.FR.REC.VALUES = R.APPLN.REC       ;* INAU record is avaiable then live record as treat as forward record
            END

        END

    END
    RETURN
*-----------------------------------------------------------------------------------------------------------
FETCH.CUR.FR.REC.VALUE.PROCESS:
*------------------------------------------------------------
* Read the History record values for the corresponding curr no.
    R.APPLN.HIS = '' ; Y.APPLN.HIS.ERR = '' ; R.PREV.REC.VALUES = ''
    EB.DataAccess.FRead(FN.APPLN.HIS,Y.APPLN.ID,R.APPLN.HIS,F.APPLN.HIS,Y.APPLN.HIS.ERR)
    IF R.APPLN.HIS THEN
        R.PREV.REC.VALUES = R.APPLN.HIS
    END
    RETURN
*------------------------------------------------------------
CHECK.CURR.PREV.VALUE.PROCESS:
*------------------------------------------------------------

    Y.COMPARE.FM.CNT = 1
    TOTAL.FM.CNT = DCOUNT(Y.COMPARE.OUT.VALUES,@FM)
    LOOP
        REMOVE Y.COMPARE.OUT.VALUE FROM Y.COMPARE.OUT.VALUES SETTING Y.COM.FM.POS         ;* Remove the field value record has one by one
    WHILE TOTAL.FM.CNT GE Y.COMPARE.FM.CNT
        IF Y.COMPARE.FM.CNT MATCHES Y.CONT.AUDIT.FIELDS.POS ELSE
            Y.COMPARE.INITIAL.VAL = Y.COMPARE.OUT.VALUES<Y.COMPARE.FM.CNT>
            TOT.MULTI.VAL.CNT = DCOUNT(Y.COMPARE.INITIAL.VAL,@VM)
            TOT.SUB.VAL.CNT = DCOUNT(Y.COMPARE.INITIAL.VAL,@SM)
            BEGIN CASE
            CASE TOT.MULTI.VAL.CNT GT 1 ;* check for multi value as necessary
                GOSUB CHK.MULTI.FLD.VAL ;* Multi Value Processing
            CASE TOT.SUB.VAL.CNT GT 1   ;* check for sub value as necessary
                Y.COMPARE.VM.CNT = 1
                GOSUB CHK.SUB.FLD.VAL   ;* Sub Value Processing
            CASE Y.COMPARE.INITIAL.VAL NE 1
                Y.FM.POS = Y.COMPARE.FM.CNT       ;* single field position
                Y.VM.POS = ''
                Y.SM.POS = ''
                GOSUB STORE.VAL.IN.ARRAY          ;* Processing the enquiry out record
            END CASE
        END
        Y.COMPARE.FM.CNT+=1
    REPEAT
    RETURN
*----------------------------------------------------------------------------------
CHK.MULTI.FLD.VAL:
*****************
    TOT.SUB.VAL.CNT = ''
    Y.COMPARE.VM.CNT = 1
    LOOP
    WHILE TOT.MULTI.VAL.CNT GE Y.COMPARE.VM.CNT

        Y.COMPARE.MUL.VAL =  Y.COMPARE.OUT.VALUES<Y.COMPARE.FM.CNT,Y.COMPARE.VM.CNT>
        TOT.SUB.VAL.CNT = DCOUNT(Y.COMPARE.MUL.VAL,@SM)
        IF TOT.SUB.VAL.CNT GT 1 THEN

            GOSUB CHK.SUB.FLD.VAL       ;* Sub Value Processing
        END ELSE
            IF Y.COMPARE.MUL.VAL NE 1 THEN
                Y.FM.POS = Y.COMPARE.FM.CNT
                Y.VM.POS = Y.COMPARE.VM.CNT
                Y.SM.POS = ''
                GOSUB STORE.VAL.IN.ARRAY
            END
        END
        Y.COMPARE.VM.CNT+=1
    REPEAT
    RETURN
*-----------------------------------------------------------------------------------
CHK.SUB.FLD.VAL:
****************

    Y.COMPARE.SM.CNT = 1
    LOOP
    WHILE TOT.SUB.VAL.CNT GE Y.COMPARE.SM.CNT
        Y.COMPARE.SUB.VL =  Y.COMPARE.OUT.VALUES<Y.COMPARE.FM.CNT,Y.COMPARE.VM.CNT,Y.COMPARE.SM.CNT>
        IF Y.COMPARE.SUB.VL NE 1 THEN
            Y.FM.POS = Y.COMPARE.FM.CNT
            Y.VM.POS = Y.COMPARE.VM.CNT
            Y.SM.POS = Y.COMPARE.SM.CNT
            GOSUB STORE.VAL.IN.ARRAY
        END
        Y.COMPARE.SM.CNT+=1
    REPEAT
    RETURN
*---------------------------------------------------------------------------------------------
STORE.VAL.IN.ARRAY:
*******************

    LRT.ARRY.VAL = ''
    IN.FIELD.NUMBER = Y.COMPARE.FM.CNT; FIELD.NAME = '' ; DATA.TYPE = '' ; ERR.MSG = ''
    EB.API.FieldNumbersToNames(IN.FIELD.NUMBER,R.SS.MASTER,FIELD.NAME,DATA.TYPE,ERR.MSG)

    IF FIELD.NAME EQ 'LOCAL.REF' THEN
        EB.LocalReferences.LocrefSetup(Y.SEL.APP.VAL,LRT.ARRY.VAL)
        FIELD.NAME = LRT.ARRY.VAL<Y.VM.POS,9>
    END
    Y.OLD.REC.VALUE = R.CUR.NUM.FR.REC.VALUES<Y.FM.POS,Y.VM.POS,Y.SM.POS>
    Y.NEW.REC.VALUE = R.CUR.NUM.TO.REC.VALUES<Y.FM.POS,Y.VM.POS,Y.SM.POS>
    GOSUB FORM.CHANGED.FIELDS.ARRAY.PROCESS       ;* Form the enquiry output array

    RETURN
*------------------------------------------------------------
FORM.CHANGED.FIELDS.ARRAY.PROCESS:
*------------------------------------------------------------
    Y.CONT.DATE.TIME.VAL = Y.CONT.DATE.TIME.VAL<1,1>        ;* For testing purpose change the values.
    REC.DATE.VAL = Y.SEL.PROCS.DATE.VAL[7,2]:"/":Y.SEL.PROCS.DATE.VAL[5,2]:"/":Y.SEL.PROCS.DATE.VAL[1,4]
    REC.TIME.VAL = Y.SEL.TIME.VAL[1,2]:":":Y.SEL.TIME.VAL[3,2]
    DAT.TIME.VAL = REC.DATE.VAL:"  ":REC.TIME.VAL
    GET.REP.ARRAY<-1> = FIELD.NAME:'_':Y.VM.POS:'_':Y.SM.POS:'_':Y.OLD.REC.VALUE:'_':Y.NEW.REC.VALUE:'_':
    GET.REP.ARRAY := Y.SEL.APP.VAL:'_':Y.SEL.COMP.ID.VAL:'_':Y.SEL.CONTRACT.VAL:'_':Y.SEL.APP.USER:"_":DAT.TIME.VAL

    RETURN

END
