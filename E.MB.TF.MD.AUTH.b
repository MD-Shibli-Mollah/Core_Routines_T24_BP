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
*-----------------------------------------------------------------------------
* <Rating>-110</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.MB.TF.MD.AUTH(DATA.ARR)
*-------------------------------------------------------------------------------
* This is a routine that is attached to a NOFILE enquiry TF.MD.AUTH
* It returns the list of records based on the selection criteria i.e.. DEPT.CODE , INPUTTER and AUTHORISER" from the
* following applications.. LETTER.OF.CREDIT, LC.AMENDMENTS, DRAWINGS, DR.DISC.AMENDMENTS, MD.DEAL, LC.ACCOUNT.BALANCES.
* that are done today.
* If no selection is made through the selection criteria then it will return all the records that are input today with
* INPUTTER or AUTHORISER equal to the current logged in USER.
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

*                             MODIFICATION SUMMARY
*                           ------------------------
*
* 23/04/2009          VERSION : 1.0         CD  : GLOBUS_EN_10004063
*                                           SAR : SAR-2008-12-24-0001
*                                           AUTHOR : ravivmc@temenos.com
*                                           DATE   : 23 APRIL 2009
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------


    $USING LC.Contract
    $USING MD.Contract
    $USING LC.Foundation
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING AC.ModelBank
    $USING EB.Reports

    $INSERT I_DAS.LETTER.OF.CREDIT
    $INSERT I_DAS.LETTER.OF.CREDIT.NOTES
    $INSERT I_DAS.LC.AMENDMENTS
    $INSERT I_DAS.DRAWINGS
    $INSERT I_DAS.DR.DISC.AMENDMENTS
    $INSERT I_DAS.MD.DEAL
    $INSERT I_DAS.LC.ACCOUNT.BALANCES



    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB LC.PROCESS
    GOSUB LC.AMM.PROCESS
    GOSUB DRAWINGS.PROCESS
    GOSUB DR.DISC.PROCESS
    GOSUB MD.DEAL.PROCESS
    GOSUB LC.ACB.PROCESS


    RETURN

****************
INITIALISE:
****************

    Y.LOGGED.USER          = ""
    Y.RECORD.STATUS        = ""
    Y.INPUTTER             = ""
    Y.AUTHORISER           = ""
    Y.DEPT.CODE            = ""

    SEL.USER.ID =''
    CURR.DATE = ''
    NULL.VAL = ''

    DATA.ARR = ""

    Y.NULL = ''

    LC.SPF.POS = ''

    RETURN

***********
OPEN.FILES:
***********

    LOCATE "DEPT.CODE" IN EB.Reports.getDFields()<1,1> SETTING DEPT.POS THEN

    Y.DEPT.CODE = EB.Reports.getDRangeAndValue()<1,DEPT.POS>

    END

    LOCATE "INPUTTER" IN EB.Reports.getDFields()<1,1> SETTING INPUTTER.POS THEN

    Y.INPUTTER = EB.Reports.getDRangeAndValue()<1,INPUTTER.POS>

    END

    LOCATE "AUTHORISER" IN EB.Reports.getDFields()<1,1> SETTING AUTHORISER.POS THEN

    Y.AUTHORISER = EB.Reports.getDRangeAndValue()<1,AUTHORISER.POS>

    END

    IF Y.DEPT.CODE EQ "" AND Y.INPUTTER EQ "" AND Y.AUTHORISER EQ "" THEN

        SEL.USER.ID = EB.SystemTables.getOperator()

    END




    X = OCONV(DATE(),"D-")

    CURR.DATE = X[9,2]:X[1,2]:X[4,2]


    RETURN



************
SUB.PROCESS:
************

* Here the values for TABLE.NAME, DAS.LIST, ARGUMENTS are assingned based on the enquiry
* selection criteria.


    BEGIN CASE


        CASE  Y.DEPT.CODE NE '' AND Y.INPUTTER NE '' AND Y.AUTHORISER NE ''

            TABLE.NAME = Y.APP
            DAS.LIST = DAS.LIST1
            ARGUMENTS = Y.DEPT.CODE:@FM:CURR.DATE:@FM:Y.INPUTTER:@FM:Y.AUTHORISER

        CASE Y.DEPT.CODE NE '' AND Y.INPUTTER NE ''

            TABLE.NAME = Y.APP
            DAS.LIST = DAS.LIST2
            ARGUMENTS = Y.DEPT.CODE:@FM:CURR.DATE:@FM:Y.INPUTTER

        CASE Y.DEPT.CODE NE '' AND Y.AUTHORISER NE ''

            TABLE.NAME = Y.APP
            DAS.LIST = DAS.LIST3
            ARGUMENTS = Y.DEPT.CODE:@FM:CURR.DATE:@FM:Y.AUTHORISER

        CASE Y.INPUTTER NE '' AND Y.AUTHORISER NE ''

            TABLE.NAME = Y.APP
            DAS.LIST = DAS.LIST4
            ARGUMENTS = Y.INPUTTER:@FM:CURR.DATE:@FM:Y.AUTHORISER

        CASE Y.DEPT.CODE NE '' AND Y.INPUTTER EQ NULL.VAL AND Y.AUTHORISER EQ NULL.VAL

            TABLE.NAME = Y.APP
            DAS.LIST = DAS.LIST5
            ARGUMENTS = Y.DEPT.CODE:@FM:CURR.DATE

        CASE Y.INPUTTER NE '' AND Y.DEPT.CODE EQ NULL.VAL AND Y.AUTHORISER EQ NULL.VAL

            TABLE.NAME = Y.APP
            DAS.LIST = DAS.LIST6
            ARGUMENTS = Y.INPUTTER:@FM:CURR.DATE

        CASE Y.AUTHORISER NE '' AND Y.DEPT.CODE EQ NULL.VAL AND Y.INPUTTER EQ NULL.VAL

            TABLE.NAME = Y.APP
            DAS.LIST = DAS.LIST7
            ARGUMENTS = Y.AUTHORISER:@FM:CURR.DATE


        CASE Y.DEPT.CODE EQ NULL.VAL AND Y.INPUTTER EQ NULL.VAL AND Y.AUTHORISER EQ NULL.VAL

            TABLE.NAME = Y.APP
            DAS.LIST = DAS.LIST8
            ARGUMENTS = SEL.USER.ID:@FM:SEL.USER.ID:@FM:CURR.DATE

    END CASE

    TABLE.SUFFIX = ''

    EB.DataAccess.Das(TABLE.NAME, DAS.LIST, ARGUMENTS, TABLE.SUFFIX)


    RETURN


***********
LC.PROCESS:
***********

* This sub process reads the LETTER.OF.CREDIT application based on the enquiry selection, and returns the
* array DATA.ARR by appending the various values for the display


    LOCATE "LC" IN EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfProducts,1> SETTING LC.SPF.POS THEN

    END

    IF LC.SPF.POS THEN

        Y.APP = "LETTER.OF.CREDIT"

        DAS.LIST1 = dasLetterOfCreditAuthEntries.1  ; DAS.LIST5 = dasLetterOfCreditAuthEntries.5
        DAS.LIST2 = dasLetterOfCreditAuthEntries.2  ; DAS.LIST6 = dasLetterOfCreditAuthEntries.6
        DAS.LIST3 = dasLetterOfCreditAuthEntries.3  ; DAS.LIST7 = dasLetterOfCreditAuthEntries.7
        DAS.LIST4 = dasLetterOfCreditAuthEntries.4  ; DAS.LIST8 = dasLetterOfCreditAuthEntries.8

        GOSUB SUB.PROCESS

        LOOP

            REMOVE LC.ID FROM DAS.LIST SETTING LC.POS

        WHILE LC.ID:LC.POS

            R.LETTER.OF.CREDIT = LC.Contract.LetterOfCredit.Read(LC.ID, ERR.LETTER.OF.CREDIT)

            DATA.ARR<-1>=LC.ID:"*":"LETTER.OF.CREDIT":"*":R.LETTER.OF.CREDIT<LC.Contract.LetterOfCredit.TfLcLcCurrency>

            DATA.ARR:= "*":R.LETTER.OF.CREDIT<LC.Contract.LetterOfCredit.TfLcLcAmount>:"*":R.LETTER.OF.CREDIT<LC.Contract.LetterOfCredit.TfLcInputter>

            DATA.ARR:= "*":R.LETTER.OF.CREDIT<LC.Contract.LetterOfCredit.TfLcAuthoriser>:"*":R.LETTER.OF.CREDIT<LC.Contract.LetterOfCredit.TfLcLcType>

            DATA.ARR:= "*":R.LETTER.OF.CREDIT<LC.Contract.LetterOfCredit.TfLcOperation>

        REPEAT

    END

    RETURN


***************
LC.AMM.PROCESS:
***************

* This sub process reads the LC.AMENDMENTS application based on the enquiry selection, and returns the
* array DATA.ARR by appending the various values for the display


    LOCATE "LC" IN EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfProducts,1> SETTING LC.AMM.SPF.POS THEN

    END

    IF LC.AMM.SPF.POS THEN

        Y.APP = "LC.AMENDMENTS"

        DAS.LIST1 = dasLcAmendmentsAuthEntries.1  ; DAS.LIST5 = dasLcAmendmentsAuthEntries.5
        DAS.LIST2 = dasLcAmendmentsAuthEntries.2  ; DAS.LIST6 = dasLcAmendmentsAuthEntries.6
        DAS.LIST3 = dasLcAmendmentsAuthEntries.3  ; DAS.LIST7 = dasLcAmendmentsAuthEntries.7
        DAS.LIST4 = dasLcAmendmentsAuthEntries.4  ; DAS.LIST8 = dasLcAmendmentsAuthEntries.8

        GOSUB SUB.PROCESS

        LOOP

            REMOVE LC.AMM.ID FROM DAS.LIST SETTING LC.AMM.POS

        WHILE LC.AMM.ID:LC.AMM.POS

            R.LC.AMENDMENTS = LC.Contract.Amendments.Read(LC.AMM.ID, ERR.LC.AMENDMENTS)

            DATA.ARR<-1> = LC.AMM.ID:"*":"LC.AMENDMENTS":"*":R.LC.AMENDMENTS<LC.Contract.Amendments.AmdLcCurrency>

            DATA.ARR:= "*":R.LC.AMENDMENTS<LC.Contract.Amendments.AmdLcAmount>:"*":R.LC.AMENDMENTS<LC.Contract.Amendments.AmdInputter>:"*":R.LC.AMENDMENTS<LC.Contract.Amendments.AmdAuthoriser>

            DATA.ARR:= "*":Y.NULL:"*":Y.NULL

        REPEAT

    END

    RETURN


***************
DRAWINGS.PROCESS:
***************

* This sub process reads the DRAWINGS application based on the enquiry selection, and returns the
* array DATA.ARR by appending the various values for the display


    LOCATE "LC" IN EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfProducts,1> SETTING DR.SPF.POS THEN

    END

    IF DR.SPF.POS THEN

        Y.APP = "DRAWINGS"

        DAS.LIST1 = dasDrawingsAuthEntries.1  ; DAS.LIST5 = dasDrawingsAuthEntries.5
        DAS.LIST2 = dasDrawingsAuthEntries.2  ; DAS.LIST6 = dasDrawingsAuthEntries.6
        DAS.LIST3 = dasDrawingsAuthEntries.3  ; DAS.LIST7 = dasDrawingsAuthEntries.7
        DAS.LIST4 = dasDrawingsAuthEntries.4  ; DAS.LIST8 = dasDrawingsAuthEntries.8

        GOSUB SUB.PROCESS

        LOOP
            REMOVE DRAWING.ID FROM DAS.LIST SETTING DRAWING.POS

        WHILE DRAWING.ID:DRAWING.POS

            R.DRAWINGS = LC.Contract.Drawings.Read(DRAWING.ID, ERR.DRAWINGS)

            DATA.ARR<-1> = DRAWING.ID:"*":"DRAWINGS":"*":R.DRAWINGS<LC.Contract.Drawings.TfDrDrawCurrency>

            DATA.ARR:= "*":R.DRAWINGS<LC.Contract.Drawings.TfDrDocumentAmount>:"*":R.DRAWINGS<LC.Contract.Drawings.TfDrInputter>:"*":R.DRAWINGS<LC.Contract.Drawings.TfDrAuthoriser>

            DATA.ARR:= "*":R.DRAWINGS<LC.Contract.Drawings.TfDrLcCreditType>:"*":Y.NULL

        REPEAT

    END

    RETURN



***************
DR.DISC.PROCESS:
***************

* This sub process reads the DR.DISC.AMENDMENTS application based on the enquiry selection, and returns the
* array DATA.ARR by appending the various values for the display


    LOCATE "LC" IN EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfProducts,1> SETTING DR.DISC.SPF.POS THEN

    END

    IF DR.DISC.SPF.POS THEN

        Y.APP = "DR.DISC.AMENDMENTS"

        DAS.LIST1 = dasDrDiscAmendmentsAuthEntries.1  ; DAS.LIST5 = dasDrDiscAmendmentsAuthEntries.5
        DAS.LIST2 = dasDrDiscAmendmentsAuthEntries.2  ; DAS.LIST6 = dasDrDiscAmendmentsAuthEntries.6
        DAS.LIST3 = dasDrDiscAmendmentsAuthEntries.3  ; DAS.LIST7 = dasDrDiscAmendmentsAuthEntries.7
        DAS.LIST4 = dasDrDiscAmendmentsAuthEntries.4  ; DAS.LIST8 = dasDrDiscAmendmentsAuthEntries.8

        GOSUB SUB.PROCESS

        LOOP
            REMOVE DR.DISC.ID FROM DAS.LIST SETTING DR.DISC.POS

        WHILE DR.DISC.ID:DR.DISC.POS

            R.DR.DISC.AMM = LC.Contract.DrDiscAmendments.Read(DR.DISC.ID, ERR.DR.DISC.AMM)

            DATA.ARR<-1> = DR.DISC.ID:"*":"DR.DISC.AMENDMENTS":"*":R.DR.DISC.AMM<LC.Contract.DrDiscAmendments.DiscDrDrawCurrency>

            DATA.ARR:= "*":R.DR.DISC.AMM<LC.Contract.DrDiscAmendments.DiscDrDocumentAmount>:"*":R.DR.DISC.AMM<LC.Contract.DrDiscAmendments.DiscDrInputter>:"*":R.DR.DISC.AMM<LC.Contract.DrDiscAmendments.DiscDrAuthoriser>

            DATA.ARR:= "*":Y.NULL:"*":Y.NULL

        REPEAT

    END

    RETURN


***************
MD.DEAL.PROCESS:
***************

* This sub process reads the MD.DEAL application based on the enquiry selection, and returns the
* array DATA.ARR by appending the various values for the display


    LOCATE "MD" IN EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfProducts,1> SETTING MD.SPF.POS THEN

    END

    IF MD.SPF.POS THEN

        Y.APP = "MD.DEAL"

        DAS.LIST1 = dasMdDealAuthEntries.1  ; DAS.LIST5 = dasMdDealAuthEntries.5
        DAS.LIST2 = dasMdDealAuthEntries.2  ; DAS.LIST6 = dasMdDealAuthEntries.6
        DAS.LIST3 = dasMdDealAuthEntries.3  ; DAS.LIST7 = dasMdDealAuthEntries.7
        DAS.LIST4 = dasMdDealAuthEntries.4  ; DAS.LIST8 = dasMdDealAuthEntries.8

        GOSUB SUB.PROCESS

        LOOP

            REMOVE MD.DEAL.ID FROM DAS.LIST SETTING MD.DEAL.POS

        WHILE MD.DEAL.ID:MD.DEAL.POS

            R.MD.DEAL = MD.Contract.Deal.Read(MD.DEAL.ID, ERR.MD.DEAL)

            DATA.ARR<-1> = MD.DEAL.ID:"*":"MD.DEAL":"*":R.MD.DEAL<MD.Contract.Deal.DeaCurrency>

            DATA.ARR:= "*":R.MD.DEAL<MD.Contract.Deal.DeaPrincipalAmount>:"*":R.MD.DEAL<MD.Contract.Deal.DeaInputter>:"*":R.MD.DEAL<MD.Contract.Deal.DeaAuthoriser>

            DATA.ARR:=  "*":Y.NULL:"*":Y.NULL

        REPEAT

    END

    RETURN



***************
LC.ACB.PROCESS:
***************


* This sub process reads the LC.ACCOUNT.BALANCES application based on the enquiry selection, and returns the
* array DATA.ARR by appending the various values for the display



    LOCATE "LC" IN EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfProducts,1> SETTING LC.ACB.SPF.POS THEN

    END

    IF LC.ACB.SPF.POS THEN

        Y.APP = "LC.ACCOUNT.BALANCES"


        DAS.LIST1 = dasLcAccountBalancesAuthEntries.1  ; DAS.LIST5 = dasLcAccountBalancesAuthEntries.5
        DAS.LIST2 = dasLcAccountBalancesAuthEntries.2  ; DAS.LIST6 = dasLcAccountBalancesAuthEntries.6
        DAS.LIST3 = dasLcAccountBalancesAuthEntries.3  ; DAS.LIST7 = dasLcAccountBalancesAuthEntries.7
        DAS.LIST4 = dasLcAccountBalancesAuthEntries.4  ; DAS.LIST8 = dasLcAccountBalancesAuthEntries.8

        GOSUB SUB.PROCESS

        LOOP
            REMOVE LC.ACB.ID FROM DAS.LIST SETTING LC.ACB.POS

        WHILE LC.ACB.ID:LC.ACB.POS

            R.LC.ACB = LC.Foundation.AccountBalances.Read(LC.ACB.ID, ERR.LC.ACB)


            DATA.ARR<-1> = LC.ACB.ID:"*":"LC.ACCOUNT.BALANCES":"*":R.LC.ACB<LC.Foundation.AccountBalances.LcacCurrency>

            DATA.ARR:= "*":R.LC.ACB<LC.Foundation.AccountBalances.LcacLcAmount>:"*":R.LC.ACB<LC.Foundation.AccountBalances.LcacInputter>:"*":R.LC.ACB<LC.Foundation.AccountBalances.LcacAuthoriser>

            DATA.ARR:= "*":Y.NULL:"*":Y.NULL

        REPEAT

    END

    RETURN
