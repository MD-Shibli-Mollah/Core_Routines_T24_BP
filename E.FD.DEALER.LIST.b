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

* Version 5 07/06/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>1828</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FD.Reports
    SUBROUTINE E.FD.DEALER.LIST(FID.IDS)
*
** This routine is used to generate a list of Fiduciary Orders used
** for the default list enquiry for dealer processing
** It will select both the unauthorised file for new deals and the
** live file for principal changes and reimbursements
*
* 13/07/93 - GB9301185
*            Show unapproved changes only, so check the nau file too
*
* 10/09/96 - GB9601219
*            Modifications to allow notice orders to be pooled.
*
* 5/5/2015 - 1322379
*            Incorporation of components
*
    $USING EB.SystemTables
    $USING FD.Contract
    $USING EB.DataAccess
    $USING EB.Reports
*
    SQ = "'"                           ; * Single Quote
    DQ = '"'                           ; * Double quote
    ID.LIST = ""
    PERFORM.OPERANDS = 'EQ,XX,LT,GT,NE,LIKE,UNLIKE,LE,GE,XX'

*

    SS.REC = ""
    YERR = ''
    SS.REC = EB.SystemTables.tableStandardSelection("FD.FIDUCIARY",YERR)

    YSEL.FIELDS = SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName>:@VM:SS.REC<EB.SystemTables.StandardSelection.SslUsrFieldName>
    YSEL.TYPES = SS.REC<EB.SystemTables.StandardSelection.SslSysType>:@VM:SS.REC<EB.SystemTables.StandardSelection.SslUsrType>
*
    FD.FIDUCIARY$NAU = "F.FD.FIDUCIARY$NAU"
    F.FD.FIDUCIARY$NAU = ""
    EB.DataAccess.Opf(FD.FIDUCIARY$NAU, F.FD.FIDUCIARY$NAU)
*
    FD.FIDUCIARY.LOCAL = "F.FD.FIDUCIARY"
    F.FD.FIDUCIARY.LOCAL = ""
    EB.DataAccess.Opf(FD.FIDUCIARY.LOCAL, F.FD.FIDUCIARY.LOCAL)
*
    GOSUB ADD.SEL.CRITERIA
    GOSUB GET.SORT.FIELDS
*
    NAU.LIST = ""
    SEL.STMT = "SELECT ":FD.FIDUCIARY$NAU:" WITH CURR.NO LT 1"
    IF SELECTION.CRITERIA THEN SEL.STMT := " ":SELECTION.CRITERIA
    IF SORT.CRITERIA THEN SEL.STMT := " ":SORT.CRITERIA
    SEL.STMT = TRIM(SEL.STMT)
    EB.DataAccess.Readlist(SEL.STMT, NAU.LIST, "", "", "")
*
*      SEL.STMT = "SELECT ":FD.FIDUCIARY:" WITH CHANGE.STATUS = 'REQUESTED' OR REIMBURSE.STATUS = 'REQUESTED'"
    SEL.STMT = "SELECT ":FD.FIDUCIARY.LOCAL
    IF SELECTION.CRITERIA THEN SEL.STMT := " ":SELECTION.CRITERIA
    IF SORT.CRITERIA THEN SEL.STMT := " ":SORT.CRITERIA
    SEL.STMT = TRIM(SEL.STMT)
    EB.DataAccess.Readlist(SEL.STMT, LIVE.LIST, "", "", "")
*
** For the Live ids check that an unauthorised does not already exist
** id so then remove it from the file
*
    IF NAU.LIST THEN FID.IDS = NAU.LIST
    LOOP
        REMOVE YID FROM LIVE.LIST SETTING YDELIM
    WHILE YID:YDELIM
        READ YREC FROM F.FD.FIDUCIARY.LOCAL, YID THEN

            LOCATE "REQUESTED" IN YREC<FD.Contract.Fiduciary.ChngStatus,1,1> SETTING YY THEN
            GOSUB CHECK.NAU.RECORD
            IF YINCLUDE THEN GOSUB ADD.TO.LIST
        END ELSE                     ; * Check REIMBURSE
            IF YREC<FD.Contract.Fiduciary.ReimburseStatus> = "REQUESTED" THEN
                GOSUB CHECK.NAU.RECORD
                IF YINCLUDE THEN GOSUB ADD.TO.LIST
            END
        END
    END ELSE                        ; * No unauth record
        GOSUB ADD.TO.LIST
    END
    REPEAT
*
    RETURN
*
*------------------------------------------------------------------------
*
ADD.TO.LIST:
    IF FID.IDS THEN
        FID.IDS := @FM:YID
    END ELSE
        FID.IDS = YID
    END
    RETURN
*
*------------------------------------------------------------------------
CHECK.NAU.RECORD:
*================
** Check to see if the record is on the unauth file. If it is and the
** status is not REQUESTED, don't add as it has been accepted
*
    YINCLUDE = 0
    READ NAU.REC FROM F.FD.FIDUCIARY$NAU, YID THEN
        LOCATE "REQUESTED" IN NAU.REC<FD.Contract.Fiduciary.ChngStatus,1,1> SETTING YY THEN
        YINCLUDE = 1                 ; * Still a change pending
    END ELSE                        ; * Check REIMBURSE
        IF NAU.REC<FD.Contract.Fiduciary.ReimburseStatus> = "REQUESTED" THEN
            YINCLUDE = 1              ; * Still reimbursement
        END
    END
    END ELSE                           ; * Add to Nau List
    YINCLUDE = 1
    END
*
    RETURN
*
*------------------------------------------------------------------------
ADD.SEL.CRITERIA:
*================
*
    SEL.FLDS = EB.Reports.getDFields()
    SEL.OPER = EB.Reports.getDLogicalOperands()
    SEL.VALUES = EB.Reports.getDRangeAndValue()
*
    SELECTION.CRITERIA = ""
    YI = 1
    LOOP
    WHILE SEL.FLDS<YI>
        FIELD.NAME = SEL.FLDS<YI>
        OPER = SEL.OPER<YI>
        SEL.DATA = SEL.VALUES<YI>
        *
        IF SEL.DATA = 'ALL' THEN
            GOTO NEXT.SEL.ITEM
        END
        *
        LOCATE FIELD.NAME IN YSEL.FIELDS<1,1> SETTING YSEL.POS THEN
        IF NOT(YSEL.TYPES<1,YSEL.POS> MATCHES "I":@VM:"D") THEN
            GOTO NEXT.SEL.ITEM
        END
    END ELSE                        ; * Missing field
        GOTO NEXT.SEL.ITEM
    END
*
* Replace the keyword NULL with '' in the user list. This allows the
* user to enter EQ NULL instead of GT 0 or whatever.
*
    LOOP LOCATE 'NULL' IN SEL.DATA<1,1,1> SETTING D ELSE D = 0 UNTIL D = 0
        SEL.DATA<1,1,D> = ''
    REPEAT
*
* Build the selection criteria according to the operand.
*
    BEGIN CASE
        CASE OPER = 1                ; * EQ
            SELECTION.CRITERIA<-1> = ' AND WITH '
            CONNECTION = ''
            LOOP REMOVE UD FROM SEL.DATA SETTING D
                IF NUM(UD) AND UD THEN
                    SELECTION.CRITERIA:= CONNECTION: FIELD.NAME: ' = ': UD
                END ELSE
                    SELECTION.CRITERIA:= CONNECTION: FIELD.NAME: ' = ': SQ: UD: SQ
                END
                CONNECTION = ' OR '
            UNTIL D = 0               ; * NO MORE TO REMOVE
            REPEAT
            *
        CASE OPER = 2                ; * RG
            RG1 = SEL.DATA<1,1,1>
            RG2 = SEL.DATA<1,1,2>
            IF NOT(NUM(RG1)) THEN
                RG1 = SQ: RG1: SQ
            END
            IF NOT(NUM(RG2)) THEN
                RG2 = SQ: RG2: SQ
            END
            *
            SELECTION.CRITERIA<-1> = " AND WITH ":FIELD.NAME: ' => ': RG1: ' AND '
            SELECTION.CRITERIA:= FIELD.NAME: ' <= ': RG2
            *
        CASE OPER = 10               ; * NR
            RG1 = SEL.DATA<1,1,1>
            RG2 = SEL.DATA<1,1,2>
            IF NOT(NUM(RG1)) THEN
                RG1 = SQ: RG1: SQ
            END
            IF NOT(NUM(RG2)) THEN
                RG2 = SQ: RG2: SQ
            END
            SELECTION.CRITERIA<-1> = " AND WITH ":FIELD.NAME: ' < ': RG1: ' OR '
            SELECTION.CRITERIA:= FIELD.NAME: ' > ': RG2
            *
        CASE 1
            SELECTION.CRITERIA<-1> = ' AND WITH '
            CONNECTION = ''
            OPERAND = FIELD(PERFORM.OPERANDS,',',OPER)    ; * LIKE, GE etc
            LOOP REMOVE UD FROM SEL.DATA SETTING D
                IF NUM(UD) AND UD THEN
                    SELECTION.CRITERIA:= CONNECTION: FIELD.NAME: " ":OPERAND:" ": UD
                END ELSE
                    SELECTION.CRITERIA:= CONNECTION: FIELD.NAME: " ":OPERAND:" ": SQ: UD: SQ
                END
                IF OPER = 5 OR OPER = 7 THEN     ; * NE UNLIKE
                    CONNECTION = ' AND '
                END ELSE
                    CONNECTION = ' OR '
                END
            UNTIL D = 0               ; * NO MORE TO REMOVE
            REPEAT
    END CASE
*
NEXT.SEL.ITEM:
    YI += 1
    REPEAT
*
    IF SELECTION.CRITERIA THEN         ; * Add
        CONVERT @FM TO "" IN SELECTION.CRITERIA
    END
    RETURN
*
*------------------------------------------------------------------------
GET.SORT.FIELDS:
*===============
*
    SORT.FIELDS = EB.Reports.getREnq()<EB.Reports.Enquiry.EnqFixedSort>
    SORT.FIELDS<-1> = EB.Reports.getEnqSelection()<9>
*
    SORT.CRITERIA = ""
    LOOP REMOVE V$SORT FROM SORT.FIELDS SETTING D UNTIL V$SORT = ''
        IF INDEX(V$SORT,'DSND',1) THEN
            SORT.SEQ = 'BY.DSND'
        END ELSE
            SORT.SEQ = 'BY'
        END
        *
        SORT.CRITERIA:= ' _': @FM: SORT.SEQ:' ':FIELD(V$SORT,' ',1)
        *
    REPEAT
*
    RETURN
*
    END
