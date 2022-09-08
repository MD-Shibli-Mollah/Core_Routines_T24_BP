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
* <Rating>248</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AZ.ModelBank
    SUBROUTINE E.CC.AMOUNT(ARR.LIST)
*****************************************************************
* 05/02/07 - EN_10003187
*            Data Access Service - Application changes
*****************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.ACCOUNT
    $INSERT I_F.CARD.ISSUE
    $INSERT I_F.AZ.ACCOUNT
    $INSERT I_F.AZ.SCHEDULES
    $INSERT I_DAS.CARD.ISSUE  ;* EN_10003187 S/E

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS

INIT:

    FN.ACC = "F.ACCOUNT"
    FV.ACC = ""
    FN.AZ.ACC = "F.AZ.ACCOUNT"
    FV.AZ.ACC = ""
    FN.CARD.ISS = "F.CARD.ISSUE"
    FV.CARD.ISS = ""
    FN.AZ.SCH = "F.AZ.SCHEDULES"
    FV.AZ.SCH = ""
    Y.ERR = ""
    Y.AC.ID = ""
    Y.AC.REC = ""
    Y.CARD.ID = ""
    Y.CARD.REC = ""
    Y.SCH.ID = ""
    Y.REPAY.DATE =""
    Y.BILL.DATE = ""
    NO.OF.REC = ""
    Y.C = 0
    Y.CC = 0
    Y.CI = 0
    Y.TEMP = ""

    RETURN

OPENFILES:

    CALL OPF(FN.ACC,FV.ACC)
    CALL OPF(FN.AZ.ACC,FV.AZ.ACC)
    CALL OPF(FN.CARD.ISS,FV.CARD.ISS)
    CALL OPF(FN.AZ.SCH,FV.AZ.SCH)

    RETURN

PROCESS:

*GET THE ACCT. NO.

    ACC.POS = ""
    LOCATE "ACCT.NO" IN D.FIELDS<1> SETTING ACC.POS ELSE NULL
    IF ACC.POS THEN
        SEL.OPR = D.LOGICAL.OPERANDS<ACC.POS>
        SEL.LIST = D.RANGE.AND.VALUE<ACC.POS>
* TO GIVE ERROR IF MORE THAN ONE ACCOUNT IS ENTERED
        SEL.CNT = DCOUNT(SEL.LIST,SM)
        IF SEL.CNT > '1' THEN
            ENQ.ERROR = "ENTER ONLY ONE ACCOUNT"
            GOTO V$ERROR
        END
    END
* Y.AC.ID STORES THE AC.NO.
    Y.AC.ID = SEL.LIST

* EN_10003187 S
    THE.LIST = dasCardIssueAccount
    THE.ARGS = ''
    THE.ARGS<1> = Y.AC.ID
    CALL DAS("CARD.ISSUE",THE.LIST,THE.ARGS,'')

    Y.CARD.REC = THE.LIST
    NO.OF.REC = DCOUNT(Y.CARD.REC,@FM)
* EN_10003187 E

    IF NO.OF.REC NE '1' THEN
        ENQ.ERROR = "NO PROPER CREDIT CARD FOR THE ACCOUNT"
        GOTO V$ERROR
    END

*Y.CARD.REC HAS CARD.ISSUE RECORD FOR THIS ACCOUNT
*NO.OF REC IS ALWAYS 1 AND HENCE Y.AC.REC HAS 1 VALUE.
*SO DIRECTLY SUBSTITUTE FOR Y.CARD.ID

    REMOVE Y.CARD.ID FROM Y.CARD.REC SETTING POS

    CALL F.READ(FN.CARD.ISS,Y.CARD.ID,Y.CARD.REC,FV.CARD.ISS,Y.ERR)


    Y.REPAY.DATE = Y.CARD.REC<CARD.IS.REPAY.DATE>[1,8]

    Y.BILL.DATE = Y.CARD.REC<CARD.IS.BILLING.CLOSE>[1,8]

    CALL F.READ(FN.AZ.SCH,Y.AC.ID,Y.AC.REC,FV.AZ.SCH,Y.ERR)

    Y.TEMP = RAISE(Y.AC.REC<AZ.SLS.TYPE.C>)

    COUNT1 = 0
    LOOP
        REMOVE COUNT1 FROM Y.TEMP SETTING POSS
    WHILE COUNT1:POSS
        Y.C+=COUNT1
    REPEAT


    Y.TEMP = RAISE(Y.AC.REC<AZ.SLS.TYPE.CI>)
    COUNT1 = 0

    LOOP
        REMOVE COUNT1 FROM Y.TEMP SETTING POSS
    WHILE COUNT1:POSS
        Y.CI+=COUNT1
    REPEAT

    Y.TEMP = RAISE(Y.AC.REC<AZ.SLS.TYPE.CC>)
    COUNT1 = 0
    LOOP
        REMOVE COUNT1 FROM Y.TEMP SETTING POSS
    WHILE COUNT1:POSS
        Y.CC+=COUNT1
    REPEAT


    ARR.LIST<-1> = Y.REPAY.DATE:"*":Y.BILL.DATE:"*":Y.C:"*":Y.CI:"*":Y.CC:"*":Y.AC.ID

    RETURN

    V$ERROR:
    RETURN TO V$ERROR

    RETURN
END
