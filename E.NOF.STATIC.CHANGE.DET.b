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
* <Rating>-49</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.ModelBank
    
    SUBROUTINE E.NOF.STATIC.CHANGE.DET(GET.ARRAY)
   
     *
* 10/05/16 - Enhancement 1499014
*          - Task 1626129
*          - Routine incorporated
  
    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.Logging
    $USING EB.DataAccess
    
    GOSUB PROCESS
    RETURN
*------------------------------------------------------------
PROCESS:
********
    GOSUB INIT      ;* Initialise variables
    GOSUB LOCATE.ENQ.SELECTION

    SEL.CMD = 'SELECT ' : FN.PROTOCOL :" WITH ":SELECTION.VAL:" AND REMARK EQ TRANSACTION.COMMIT BY @ID "     ;*select a protocol record as based on condition
    EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,'',SEL.COUNT,SEL.ERR) ;* Execute the SELECT and get the IDS's
    Y.RECORD.LIST = SEL.LIST
    LOOP
        REMOVE Y.SEL.ID.VAL FROM Y.RECORD.LIST SETTING Y.SEL.REC.POS
    WHILE Y.SEL.ID.VAL : Y.SEL.REC.POS
        IF NUM(Y.SEL.ID.VAL) THEN
            R.PROTOCOL.REC = '' ; Y.PROTOCOL.ERR = ''
            R.PROTOCOL.REC = EB.Logging.Protocol.Read(Y.SEL.ID.VAL, Y.PROTOCOL.ERR)
            IF NOT(Y.PROTOCOL.ERR) THEN
                GOSUB MAIN.PROCESS
            END
        END
    REPEAT
    RETURN
*---------------------------------------------------------------------------------------------------
INIT:
*****

    EB.SystemTables.setFProtocol('')
    FN.PROTOCOL = 'F.PROTOCOL'

    tmp.F.PROTOCOL = ''
    EB.DataAccess.Opf(FN.PROTOCOL,tmp.F.PROTOCOL) ; Y.SEL.CONTRACT.LIST = ''
    EB.SystemTables.setFProtocol(tmp.F.PROTOCOL)
    
    RETURN
*---------------------------------------------------------------------------------------------------
LOCATE.ENQ.SELECTION:
**********************
    Y.SEL.VAL = ''
    Y.OPERAND = ''
    SELECTION.VAL = ''

    LOCATE "OPERATOR" IN EB.Reports.getDFields()<1> SETTING SELET.POS THEN
        Y.SEL.VAL = EB.Reports.getDRangeAndValue()<SELET.POS>
        Y.OPERAND = EB.Reports.getDLogicalOperands()<SELET.POS>
        SELECTION.VAL = "USER ":EB.Reports.getOperandList()<Y.OPERAND>:" '": Y.SEL.VAL:"' AND "
    END ELSE
        SELECTION.VAL = "USER NE '' AND "
    END

    SELET.POS = ''
    LOCATE "APPLICATION" IN EB.Reports.getDFields()<1> SETTING SELET.POS THEN
        Y.SEL.VAL = EB.Reports.getDRangeAndValue()<SELET.POS>
        Y.OPERAND = EB.Reports.getDLogicalOperands()<SELET.POS>
*        SELECTION.VAL := "APPLICATION ":OPERAND.LIST<Y.OPERAND>:" '": Y.SEL.VAL:"' AND "
        SELECTION.VAL := "APPLICATION LIKE ":Y.SEL.VAL:"... AND "
    END ELSE
        SELECTION.VAL := "APPLICATION NE '' AND "
    END
    SELET.POS = ''
    LOCATE "COMPANY.CODE" IN EB.Reports.getDFields()<1> SETTING SELET.POS THEN
        Y.SEL.VAL = EB.Reports.getDRangeAndValue()<SELET.POS>
        Y.OPERAND = EB.Reports.getDLogicalOperands()<SELET.POS>
        SELECTION.VAL := "COMPANY.ID ":EB.Reports.getOperandList()<Y.OPERAND>:" '": Y.SEL.VAL:"' AND "
    END ELSE
        SELECTION.VAL := "COMPANY.ID EQ '":EB.SystemTables.getIdCompany():"' AND "
    END
    SELET.POS = ''
    LOCATE "REC.ID" IN EB.Reports.getDFields()<1> SETTING SELET.POS THEN
        Y.SEL.VAL = EB.Reports.getDRangeAndValue()<SELET.POS>
        Y.OPERAND = EB.Reports.getDLogicalOperands()<SELET.POS>
*        SELECTION.VAL := "ID ":OPERAND.LIST<Y.OPERAND>:" '": Y.SEL.VAL:"'"
        SELECTION.VAL := "ID LIKE ...": Y.SEL.VAL:"..."
    END ELSE

        SELECTION.VAL := "ID NE '' "

    END

    RETURN
*------------------------------------------------------------
MAIN.PROCESS:
*************

    Y.SEL.CONTRACT.VAL = R.PROTOCOL.REC<EB.Logging.Protocol.PtlId>
    PGM.TYPE.VAL = '' ;  Y.SEL.APP.VAL = '' ; R.PGM.FILE.REC = '' ; Y.PGM.FILE.ERR = '' ; Y.SEL.TIME.VAL = '' ; Y.SEL.FULL.TIME.VAL = ''
    Y.SEL.APP.VAL = R.PROTOCOL.REC<EB.Logging.Protocol.PtlApplication>
    Y.SEL.APP.VER.VAL = FIELD(Y.SEL.APP.VAL,',',2,1)
    Y.SEL.APP.VAL = FIELD(Y.SEL.APP.VAL,',',1,1)
    Y.SEL.APP.USER = R.PROTOCOL.REC<EB.Logging.Protocol.PtlUser>
    Y.SEL.FULL.TIME.VAL = R.PROTOCOL.REC<EB.Logging.Protocol.PtlTime>
    Y.SEL.TIME.VAL = Y.SEL.FULL.TIME.VAL[1,4]     ;* PROCESS.TIME
    Y.SEL.PROCS.DATE.VAL = R.PROTOCOL.REC<EB.Logging.Protocol.PtlProcessDate>        ;*PROCESS.DATE
    Y.SEL.RECORD.CUR.NUM.VAL = FIELD(Y.SEL.CONTRACT.VAL,';',2)
    Y.SEL.CONTRACT.VAL = FIELD(Y.SEL.CONTRACT.VAL,';',1)
    Y.SEL.TIME.VAL = R.PROTOCOL.REC<EB.Logging.Protocol.PtlTime>
    Y.SEL.DATE.VAL = R.PROTOCOL.REC<EB.Logging.Protocol.PtlProcessDate>
    Y.SEL.FUNCTION = R.PROTOCOL.REC<EB.Logging.Protocol.PtlLevelFunction>

    IF Y.SEL.FUNCTION[3,1] NE 'R' THEN
        R.PGM.FILE.REC = ''
        R.PGM.FILE.REC = EB.SystemTables.PgmFile.Read(Y.SEL.APP.VAL, Y.PGM.FILE.ERR)
        PGM.TYPE.VAL = R.PGM.FILE.REC<EB.SystemTables.PgmFile.PgmType>          ;* variable is used to only H type file allowed to display

        IF Y.SEL.RECORD.CUR.NUM.VAL GT 1 AND PGM.TYPE.VAL EQ 'H'  THEN
            PROCESS.DATE.VAL = OCONV(ICONV(Y.SEL.DATE.VAL,'D'),'D4')
            REC.DATE.VAL = PROCESS.DATE.VAL[1,2]:"-":PROCESS.DATE.VAL[4,3]:"-":PROCESS.DATE.VAL[8,4]
            REC.TIME.VAL = Y.SEL.TIME.VAL[1,2]:":":Y.SEL.TIME.VAL[3,2]:":":Y.SEL.TIME.VAL[5,2]
            GET.ARRAY<-1> = Y.SEL.ID.VAL:'*':Y.SEL.APP.USER:'*':REC.DATE.VAL:'*':REC.TIME.VAL:'*':Y.SEL.APP.VAL:'*':
            GET.ARRAY :=  Y.SEL.APP.VER.VAL:'*':Y.SEL.CONTRACT.VAL:'*':Y.SEL.RECORD.CUR.NUM.VAL
        END
    END
    RETURN
END
 
