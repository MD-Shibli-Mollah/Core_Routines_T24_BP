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
* <Rating>199</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.MB.TF.MD.UNAUTH(DATA.ARR)
*-------------------------------------------------------------------------------
* This is a routine that is attached to a NOFILE enquiry TF.MD.UNAUTH
* It returns the list of records that are input through the logged in USER and
* whose status is INAU from the following applications..
* LETTER.OF.CREDIT, LC.AMENDMENTS, DRAWINGS, DR.DISC.AMENDMENTS, MD.DEAL, LC.ACCOUNT.BALANCES .
*-------------------------------------------------------------------------------
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
    $USING EB.Security
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

    PROCESS.GOAHEAD = ""

    Y.REC.STATUS.POS ="" ; Y.USER.POS ="" ;
    FIELD.POS = "" ;  REC.POS = ""
    R.ERR = ""
    DATA.ARR = ""

    Y.NULL = ""

    RETURN

***********
OPEN.FILES:
***********

    LOCATE "USER" IN EB.Reports.getDFields()<1,1> SETTING FIELD.POS THEN

    SEL.USER.ID = EB.Reports.getDRangeAndValue()<1,FIELD.POS>

    END

    Y.RECORD.STATUS = "INAU"

* If no value is entered in the enquiry selection then
* the current logged in USER id is fetched and used to read the records
* that are input by him

    IF SEL.USER.ID NE "" THEN ;

    Y.USER = EB.Security.User.Read(SEL.USER.ID, R.ERR)

    IF NOT(R.ERR) THEN
        PROCESS.GOAHEAD = 1
    END ELSE
        PROCESS.GOAHEAD = -1

    END

    END ELSE

    SEL.USER.ID = EB.SystemTables.getOperator()

    PROCESS.GOAHEAD = 1

    END

    RETURN


************
LC.PROCESS:
************

* This sub process reads the LETTER.OF.CREDIT application based on the USER, and returns the
* array DATA.ARR by appending the various values for the display


    IF PROCESS.GOAHEAD EQ "1" THEN

        LOCATE "LC" IN EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfProducts,1> SETTING LC.SPF.POS THEN

    END

    IF LC.SPF.POS THEN

        Y.APP = "LETTER.OF.CREDIT"

        TABLE.NAME = "LETTER.OF.CREDIT"
        DAS.LIST   = dasLetterOfCreditNauEntries
        ARGUMENTS  = SEL.USER.ID:@FM:Y.RECORD.STATUS
        TABLE.SUFFIX = "$NAU"

        EB.DataAccess.Das(TABLE.NAME, DAS.LIST, ARGUMENTS, TABLE.SUFFIX)

        LOOP

            REMOVE LC.ID FROM DAS.LIST SETTING LC.POS

        WHILE LC.ID:LC.POS

            R.LETTER.OF.CREDIT = LC.Contract.LetterOfCredit.ReadNau(LC.ID, ERR.LETTER.OF.CREDIT)

            LC.INPUTTER = R.LETTER.OF.CREDIT<LC.Contract.LetterOfCredit.TfLcInputter>

            LC.INPUTTER = FIELD(LC.INPUTTER,"_",2,1)

            IF LC.INPUTTER EQ SEL.USER.ID THEN

                DATA.ARR<-1>=LC.ID:"*":"LETTER.OF.CREDIT":"*":R.LETTER.OF.CREDIT<LC.Contract.LetterOfCredit.TfLcLcCurrency>

                DATA.ARR:= "*":R.LETTER.OF.CREDIT<LC.Contract.LetterOfCredit.TfLcLcAmount>:"*":R.LETTER.OF.CREDIT<LC.Contract.LetterOfCredit.TfLcInputter>

                DATA.ARR:= "*":R.LETTER.OF.CREDIT<LC.Contract.LetterOfCredit.TfLcLcType>:"*":R.LETTER.OF.CREDIT<LC.Contract.LetterOfCredit.TfLcOperation>

            END

        REPEAT
    END
    END

    RETURN



***************
LC.AMM.PROCESS:
***************

* This sub process reads the LC.AMENDMENTS application based on the USER, and returns the
* array DATA.ARR by appending the various values for the display

    IF PROCESS.GOAHEAD EQ "1" THEN

        LOCATE "LC" IN EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfProducts,1> SETTING LC.AMM.SPF.POS THEN

    END

    IF LC.AMM.SPF.POS THEN


        TABLE.NAME1 = "LC.AMENDMENTS"
        DAS.LIST1   = dasLcAmendmentsNauEntries
        ARGUMENTS1  = SEL.USER.ID:@FM:Y.RECORD.STATUS
        TABLE.SUFFIX1 = "$NAU"

        EB.DataAccess.Das(TABLE.NAME1, DAS.LIST1, ARGUMENTS1, TABLE.SUFFIX1)

        LOOP
            REMOVE LC.AMM.ID FROM DAS.LIST1 SETTING LC.AMM.POS

        WHILE LC.AMM.ID:LC.AMM.POS

            R.LC.AMENDMENTS = LC.Contract.Amendments.ReadNau(LC.AMM.ID, ERR.LC.AMENDMENTS)

            LC.AMM.INPUTTER = R.LC.AMENDMENTS<LC.Contract.Amendments.AmdInputter>

            LC.AMM.INPUTTER = FIELD(LC.AMM.INPUTTER,"_",2,1)

            IF LC.AMM.INPUTTER EQ SEL.USER.ID THEN

                DATA.ARR<-1> = LC.AMM.ID:"*":"LC.AMENDMENTS":"*":R.LC.AMENDMENTS<LC.Contract.Amendments.AmdLcCurrency>

                DATA.ARR:= "*":R.LC.AMENDMENTS<LC.Contract.Amendments.AmdLcAmount>:"*":R.LC.AMENDMENTS<LC.Contract.Amendments.AmdInputter>

                DATA.ARR:= "*":Y.NULL:"*":Y.NULL

            END

        REPEAT
    END
    END

    RETURN


***************
DRAWINGS.PROCESS:
***************

* This sub process reads the DRAWINGS application based on the USER, and returns the
* array DATA.ARR by appending the various values for the display


    IF PROCESS.GOAHEAD EQ "1" THEN

        LOCATE "LC" IN EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfProducts,1> SETTING DR.SPF.POS THEN

    END

    IF DR.SPF.POS THEN

        TABLE.NAME2 = "DRAWINGS"
        DAS.LIST2   = dasDrawingsNauEntries
        ARGUMENTS2  = SEL.USER.ID:@FM:Y.RECORD.STATUS
        TABLE.SUFFIX2 = "$NAU"

        EB.DataAccess.Das(TABLE.NAME2, DAS.LIST2, ARGUMENTS2, TABLE.SUFFIX2)

        LOOP
            REMOVE DRAWING.ID FROM DAS.LIST2 SETTING DRAWING.POS

        WHILE DRAWING.ID:DRAWING.POS

            R.DRAWINGS = LC.Contract.Drawings.ReadNau(DRAWING.ID, ERR.DRAWINGS)

            DRAWINGS.INPUTTER = R.DRAWINGS<LC.Contract.Drawings.TfDrInputter>

            DRAWINGS.INPUTTER = FIELD(DRAWINGS.INPUTTER,"_",2,1)

            IF DRAWINGS.INPUTTER EQ SEL.USER.ID THEN

                DATA.ARR<-1> = DRAWING.ID:"*":"DRAWINGS":"*":R.DRAWINGS<LC.Contract.Drawings.TfDrDrawCurrency>

                DATA.ARR:= "*":R.DRAWINGS<LC.Contract.Drawings.TfDrDocumentAmount>:"*":R.DRAWINGS<LC.Contract.Drawings.TfDrInputter>

                DATA.ARR:= "*":R.DRAWINGS<LC.Contract.Drawings.TfDrLcCreditType>:"*":Y.NULL

            END

        REPEAT

    END

    END

    RETURN



***************
DR.DISC.PROCESS:
***************

* This sub process reads the DR.DISC.AMENDMENTS application based on the USER, and retunrs the
* array DATA.ARR by appending the various values for the display


    IF PROCESS.GOAHEAD EQ "1" THEN

        LOCATE "LC" IN EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfProducts,1> SETTING DR.DISC.SPF.POS THEN

    END

    IF DR.DISC.SPF.POS THEN

        TABLE.NAME3 = "DR.DISC.AMENDMENTS"
        DAS.LIST3   = dasDrDiscAmendmentsNauEntries
        ARGUMENTS3  = SEL.USER.ID:@FM:Y.RECORD.STATUS
        TABLE.SUFFIX3 = "$NAU"

        EB.DataAccess.Das(TABLE.NAME3, DAS.LIST3, ARGUMENTS3, TABLE.SUFFIX3)

        LOOP
            REMOVE DR.DISC.ID FROM DAS.LIST3 SETTING DR.DISC.POS

        WHILE DR.DISC.ID:DR.DISC.POS

            R.DR.DISC.AMM = LC.Contract.DrDiscAmendments.ReadNau(DR.DISC.ID, ERR.DR.DISC.AMM)

            DR.DISC.INPUTTER = R.DR.DISC.AMM<LC.Contract.DrDiscAmendments.DiscDrInputter>

            DR.DISC.INPUTTER = FIELD(DR.DISC.INPUTTER,"_",2,1)

            IF DR.DISC.INPUTTER EQ SEL.USER.ID THEN

                DATA.ARR<-1> = DR.DISC.ID:"*":"DR.DISC.AMENDMENTS":"*":R.DR.DISC.AMM<LC.Contract.DrDiscAmendments.DiscDrDrawCurrency>

                DATA.ARR:= "*":R.DR.DISC.AMM<LC.Contract.DrDiscAmendments.DiscDrDocumentAmount>:"*":R.DR.DISC.AMM<LC.Contract.DrDiscAmendments.DiscDrInputter>

                DATA.ARR:= "*":Y.NULL:"*":Y.NULL

            END

        REPEAT

    END

    END

    RETURN



***************
MD.DEAL.PROCESS:
***************

* This sub process reads the MD.DEAL application based on the USER, and returns the
* array DATA.ARR by appending the various values for the display


    IF PROCESS.GOAHEAD EQ "1" THEN

        LOCATE "MD" IN EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfProducts,1> SETTING MD.SPF.POS THEN

    END

    IF MD.SPF.POS THEN

        TABLE.NAME4 = "MD.DEAL"
        DAS.LIST4   = dasMdDealNauEntries
        ARGUMENTS4  = SEL.USER.ID:@FM:Y.RECORD.STATUS
        TABLE.SUFFIX4 = "$NAU"

        EB.DataAccess.Das(TABLE.NAME4, DAS.LIST4, ARGUMENTS4, TABLE.SUFFIX4)

        LOOP

            REMOVE MD.DEAL.ID FROM DAS.LIST4 SETTING MD.DEAL.POS

        WHILE MD.DEAL.ID:MD.DEAL.POS

            R.MD.DEAL = MD.Contract.Deal.ReadNau(MD.DEAL.ID, ERR.MD.DEAL)

            MD.INPUTTER = R.MD.DEAL<MD.Contract.Deal.DeaInputter>

            MD.INPUTTER = FIELD(MD.INPUTTER,"_",2,1)

            IF MD.INPUTTER EQ SEL.USER.ID THEN

                DATA.ARR<-1> = MD.DEAL.ID:"*":"MD.DEAL":"*":R.MD.DEAL<MD.Contract.Deal.DeaCurrency>

                DATA.ARR:= "*":R.MD.DEAL<MD.Contract.Deal.DeaPrincipalAmount>:"*":R.MD.DEAL<MD.Contract.Deal.DeaInputter>

                DATA.ARR:= "*":Y.NULL:"*":Y.NULL

            END

        REPEAT

    END

    END

    RETURN


***************
LC.ACB.PROCESS:
***************

* This sub process reads the LC.ACCOUNT.BALANCES application based on the USER, and returns the
* array DATA.ARR by appending the various values for the display

    IF PROCESS.GOAHEAD EQ "1" THEN

        LOCATE "LC" IN EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfProducts,1> SETTING LC.ACB.SPF.POS THEN

    END

    IF LC.ACB.SPF.POS THEN


        TABLE.NAME5 = "LC.ACCOUNT.BALANCES"
        DAS.LIST5   = dasLcAccountBalancesNauEntries
        ARGUMENTS5  = SEL.USER.ID:@FM:Y.RECORD.STATUS
        TABLE.SUFFIX5 = "$NAU"

        EB.DataAccess.Das(TABLE.NAME5, DAS.LIST5, ARGUMENTS5, TABLE.SUFFIX5)

        LOOP
            REMOVE LC.ACB.ID FROM DAS.LIST5 SETTING LC.ACB.POS

        WHILE LC.ACB.ID:LC.ACB.POS

            R.LC.ACB = LC.Foundation.AccountBalances.ReadNau(LC.ACB.ID, ERR.LC.ACB)

            LC.ACB.INPUTTER = R.LC.ACB<LC.Foundation.AccountBalances.LcacInputter>

            LC.ACB.INPUTTER = FIELD(LC.ACB.INPUTTER,"_",2,1)

            IF LC.ACB.INPUTTER EQ SEL.USER.ID THEN

                DATA.ARR<-1> = LC.ACB.ID:"*":"LC.ACCOUNT.BALANCES":"*":R.LC.ACB<LC.Foundation.AccountBalances.LcacCurrency>

                DATA.ARR:= "*":R.LC.ACB<LC.Foundation.AccountBalances.LcacLcAmount>:"*":R.LC.ACB<LC.Foundation.AccountBalances.LcacInputter>

                DATA.ARR:= "*":Y.NULL:"*":Y.NULL

            END

        REPEAT

    END

    END

    RETURN
