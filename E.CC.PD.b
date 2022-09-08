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
* <Rating>393</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AZ.ModelBank
    SUBROUTINE E.CC.PD(Y.ARR)

*-----------------------------
* Modifications
*--------------
*
* 21/11/06 - CI_10045435
*            Checking for PD.INSTALLED before calling PD in the routines.
*
* 05/02/07 - EN_10003187
*            Data Access Service - Application changes
*------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.PD.PAYMENT.DUE
    $INSERT I_F.AZ.ACCOUNT
    $INSERT I_F.COMPANY       ;*CI_10045435-S/E
    $INSERT I_DAS.PD.PAYMENT.DUE        ;* EN_10003187 S/E
*-------------------------------
* CI_10045435-S
    LOCATE 'PD' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING PD.INSTALLED ELSE          ;*CI_10045435-S
        PD.INSTALLED = ''
    END
    IF NOT(PD.INSTALLED) THEN
        RETURN
    END
* CI_10045435-E
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
*------------------------------
    RETURN

INIT:
*----
    FN.AZ.ACC = "F.AZ.ACCOUNT"
    FV.AZ.ACC = ""
    FN.PD = "F.PD.PAYMENT.DUE"
    FV.PD = ""
    Y.AC.ID = ""
    Y.DUE.DATE = ""
    Y.PD.ID = ""
    Y.PD.IDS = ""
    Y.PD.REC = ""
    Y.AC.REC = ""
    Y.PD.REC = ""
    Y.PR.AMT = 0

    ACCT.NO = ""
    Y.PE.AMT = 0
    Y.IN.AMT = 0
    Y.TX.AMT = 0
    Y.A1.AMT = 0
    Y.A2.AMT = 0

    Y.TOT.DUE = 0
    Y.PAY.DUE.DTE = ""
    Y.PAYMENT = 0
    Y.REP.AMT = 0
    Y.ADJ.AMT = 0
    Y.OUTS.AMT = 0
    Y.PAYMENT.OUTS.REC = ""
    Y.OUTS.AMT.REC = ""
    Y.REP.AMT.REC = ""
    Y.ADJ.AMT.REC = ""

    Y.ERR = ""
    Y.CNT = 0
    CMD = ""
    Y.TEMP =""
    Y.TEMP1 = ""
    Y.TEMP2 = ""
    Y.TEMP.REC = ""

    Y.PAYMENT1 = 0
    Y.PR.AMT1 = 0
    Y.PE.AMT1 = 0; Y.IN.AMT1 = 0; Y.TX.AMT1 = 0; Y.A1.AMT1 = 0; Y.A2.AMT1 = 0

    RETURN

*----------
OPENFILES:
*---------
    CALL OPF(FN.AZ.ACC,FV.AZ.ACC)
    CALL OPF(FN.PD,FV.PD)

    RETURN
*--------
PROCESS:
*-------

*GET THE ACCT.NO AND DUE DATE FROM SELECTION CRITERIA BOX

    ACC.POS = ""
    LOCATE "ACCT.NO" IN D.FIELDS<1> SETTING ACC.POS ELSE NULL

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


*GET THE CORRESPONDING PD RECORDS
*--------------------------------
* EN_10003187 S
    THE.LIST = dasPdPaymentDueSettleAccount
    THE.ARGS = ''
    THE.ARGS<1> = Y.AC.ID
    CALL DAS("PD.PAYMENT.DUE",THE.LIST ,THE.ARGS,'')

    Y.PD.IDS = THE.LIST
* EN_10003187 E

    LOOP

        Y.PAYMENT = 0
        Y.PR.AMT = 0
        Y.PE.AMT = 0; Y.IN.AMT = 0; Y.TX.AMT = 0; Y.A1.AMT = 0; Y.A2.AMT = 0

        REMOVE Y.PD.ID FROM Y.PD.IDS SETTING POS

    WHILE Y.PD.ID

        CALL F.READ(FN.PD,Y.PD.ID,Y.PD.REC,FV.PD,Y.ERR)

*RAISE THE PD.TOT.OVRDUE.TYPE TO GET THE DIFF. TYPES
*---------------------------------------------------
        Y.TEMP = RAISE (Y.PD.REC<PD.TOT.OVRDUE.TYPE>)
        Y.TEMP1 = RAISE (Y.PD.REC<PD.TOT.OD.TYPE.AMT>)
        Y.DTE.DUE = RAISE (Y.PD.REC<PD.PAYMENT.DTE.DUE>)
        Y.TOT.DUE += Y.PD.REC<PD.TOTAL.OVERDUE.AMT>

*CALCULATE THE OD'S FOR EACH TYPE
*--------------------------------

        LOOP
            REMOVE Y.TYPE FROM Y.TEMP SETTING POS1
            REMOVE Y.AMT FROM Y.TEMP1 SETTING POS2

        WHILE Y.TYPE

            IF Y.TYPE = 'PR' THEN
                Y.PR.AMT += Y.AMT
                Y.PAYMENT += Y.AMT
            END

            IF Y.TYPE = 'PE' THEN
                Y.PE.AMT +=Y.AMT
                Y.PAYMENT += Y.AMT
            END

            IF Y.TYPE = 'IN' THEN
                Y.IN.AMT +=Y.AMT
                Y.PAYMENT += Y.AMT
            END

            IF Y.TYPE = 'TX' THEN
                Y.TX.AMT += Y.AMT
                Y.PAYMENT += Y.AMT
            END

            IF Y.TYPE = 'A1' THEN
                Y.A1.AMT += Y.AMT
                Y.PAYMENT += Y.AMT
            END

            IF Y.TYPE = 'A2' THEN
                Y.A2.AMT += Y.AMT
                Y.PAYMENT += Y.AMT
            END

        REPEAT

        Y.PAYMENT1 += Y.PAYMENT; Y.PR.AMT1 += Y.PR.AMT; Y.PE.AMT1 += Y.PE.AMT
        Y.IN.AMT1 += Y.IN.AMT; Y.TX.AMT1 += Y.TX.AMT; Y.A1.AMT1 += Y.A1.AMT
        Y.A2.AMT1 += Y.A2.AMT

        Y.ARR<-1> = Y.PD.ID:"*":Y.PAYMENT:"*":Y.PR.AMT:"*":Y.PE.AMT:"*":Y.IN.AMT:"*":Y.TX.AMT:"*":Y.A1.AMT:"*":Y.A2.AMT

*TOTAL IS IN Y.PAYMENT

    REPEAT

    MAIN.ARR = Y.AC.ID:"*":Y.PAYMENT1:"*":Y.PR.AMT1:"*":Y.PE.AMT1:"*":Y.IN.AMT1:"*":Y.TX.AMT1:"*":Y.A1.AMT1:"*":Y.A2.AMT1

    Y.ARR = MAIN.ARR:FM:Y.ARR

    V$ERROR:
    RETURN TO V$ERROR

    RETURN
END
