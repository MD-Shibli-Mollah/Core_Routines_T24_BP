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
* <Rating>449</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AZ.ModelBank
    SUBROUTINE E.CC.DATE(ARR.LIST)
*****************************************************************
* 05/02/07 - EN_10003187
*            Data Access Service - Application changes
*****************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.AZ.ACCOUNT
    $INSERT I_F.ACCOUNT
    $INSERT I_F.LIMIT
    $INSERT I_F.CARD.ISSUE
    $INSERT I_DAS.CARD.ISSUE  ;* EN_10003187 S
    $INSERT I_DAS.ACCOUNT     ;* EN_10003187 E

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS

    RETURN

INIT:

    FN.ACC = "F.ACCOUNT"
    FV.ACC = ""
    FN.AZ.ACC = "F.AZ.ACCOUNT"
    FV.AZ.ACC = ""
    FN.LT = "F.LIMIT"
    FV.LT = ""
    FN.CARD.ISS = "F.CARD.ISSUE"
    FV.CARD.ISS = ""
    Y.ERR = ""
    Y.AC.ID = ""
    Y.VALUE.DATE = ""
    Y.TOT.DRAW.DOWN = 0
    Y.LIM.SANC = 0
    Y.LIM.AVAIL = 0
    Y.OUTSTANDING = 0
    Y.LIM.ID = ""
    Y.AC.REC = ""
    Y.AZ.ID = ""
    Y.AZ.REC = ""
    Y.AC.IDS = ""


    RETURN

OPENFILES:

    CALL OPF(FN.ACC,FV.ACC)
    CALL OPF(FN.AZ.ACC,FV.AZ.ACC)
    CALL OPF(FN.LT,FV.LT)
    CALL OPF(FN.CARD.ISS,FV.CARD.ISS)

    RETURN

PROCESS:

*GET THE ACCT. NO AND DATE
    ACC.POS = ''
    LOCATE 'ACCT.NO' IN D.FIELDS<1> SETTING ACC.POS ELSE NULL
    IF ACC.POS THEN
        SEL.OPR = D.LOGICAL.OPERANDS<ACC.POS>
        SEL.LIST = D.RANGE.AND.VALUE<ACC.POS>
* To give error if more than one account is entered in the selection
        SEL.CNT = DCOUNT(SEL.LIST,SM)
        IF SEL.CNT > '1' THEN
            ENQ.ERROR = 'ONLY ONE ACCOUNT NUMBER CAN BE ENTERED.'
            GOTO V$ERROR
        END
    END

*Y.AC.ID - HAS THE MAIN ACCT.
    Y.AC.ID = SEL.LIST

    DATE.POS = ''
    LOCATE 'VALUE.DATE' IN D.FIELDS<1> SETTING DATE.POS ELSE NULL
    IF DATE.POS THEN
        SEL.OPR = D.LOGICAL.OPERANDS<DATE.POS>
        SEL.LIST = D.RANGE.AND.VALUE<DATE.POS>
* To give error if more than one date is entered in the selection
        SEL.CNT = DCOUNT(SEL.LIST,SM)
        IF SEL.CNT > '1' THEN
            ENQ.ERROR = 'ONLY ONE DATE CAN BE ENTERED.'
            GOTO V$ERROR
        END
    END

*Y.VALUE.DATE - HAS THE DATE ON WHICH TO BE CALCULATED
    Y.VALUE.DATE = SEL.LIST

    CALL F.READ(FN.ACC,Y.AC.ID,Y.AC.REC,FV.ACC,Y.ERR)

    REF.NO = ""
    SEQ.NO = ""
    REF.NO = FMT(FIELD(Y.AC.REC<AC.LIMIT.REF>,".",1,1),"7'0'R")
    SEQ.NO = FMT(FIELD(Y.AC.REC<AC.LIMIT.REF>,".",2,1),"2'0'R")

    Y.LIM.ID = Y.AC.REC<AC.CUSTOMER>:".":REF.NO:".":SEQ.NO

    CALL F.READ(FN.LT,Y.LIM.ID,Y.LIM.REC,FV.LT,Y.ERR)
    Y.LIM.SANC = Y.LIM.REC<LI.ONLINE.LIMIT>
*CHECK WHETHER THE ACCOUNT NO. HAS A VALID CREDIT CARD
* EN_10003187 S
    THE.LIST = dasCardIssueAccount
    THE.ARGS = ''
    THE.ARGS<1> = Y.AC.ID
    CALL DAS("CARD.ISSUE",THE.LIST ,THE.ARGS,'')

    Y.AC.IDS = THE.LIST
    NO.OF.REC = DCOUNT(Y.AC.IDS,@FM)
* EN_10003187 E
    IF NO.OF.REC NE '1' THEN
        ENQ.ERROR = "NO PROPER CREDIT CARD FOR THE ACCOUNT"
        GOTO V$ERROR
    END

* EN_10003187 S
    THE.LIST = DAS.ACCOUNT$MAST.DATE
    THE.ARGS = ''
    THE.ARGS<1> = Y.AC.ID
    THE.ARGS<2> = Y.VALUE.DATE
    CALL DAS("ACCOUNT",THE.LIST ,THE.ARGS,'')

    Y.AC.IDS = THE.LIST
* EN_10003187 E
    LOOP
        REMOVE Y.AZ.ID FROM Y.AC.IDS SETTING POS
    WHILE Y.AZ.ID
        CALL F.READ(FN.AZ.ACC,Y.AZ.ID,Y.AZ.REC,FV.AZ.ACC,Y.ERR)
        Y.DRAW.DOWN+=Y.AZ.REC<AZ.ORIG.PRINCIPAL>
        Y.OUTSTANDING+=Y.AZ.REC<AZ.PRINCIPAL>
    REPEAT

    Y.LIM.AVAIL = Y.LIM.SANC - Y.DRAW.DOWN
    ARR.LIST<-1> = Y.LIM.SANC:"*":Y.DRAW.DOWN:"*":Y.LIM.AVAIL:"*":Y.OUTSTANDING:"*":Y.AC.ID

    RETURN

    V$ERROR:
    RETURN TO V$ERROR
    RETURN

END
