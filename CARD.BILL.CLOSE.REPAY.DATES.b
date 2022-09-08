* @ValidationCode : MjoxOTc5NzY1NjQ0OkNwMTI1MjoxNTY0NTY5NzY4NTA3OnNyYXZpa3VtYXI6NDowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwOC4wOjYxOjYx
* @ValidationInfo : Timestamp         : 31 Jul 2019 16:12:48
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 61/61 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-27</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.Cards
SUBROUTINE CARD.BILL.CLOSE.REPAY.DATES(CARD.ID)

*****************************************************************************
* 19/05/07 - CI_10069687
*            CARD.BILL.CLOSE.DATE, CARD.REPAYMENT.DATE applications are written
*            in size of 10000 to avoid performance issues and hence old
*            records with size of 200 are converted to new size of 10000
*            in this subroutine.
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
*01/08/15 -  Enhancement 1265068
*         -  Task 1387479
*			 Routine incorporated
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
*----------------------------------------------------------------------------
    $USING EB.TransactionControl
    $USING AZ.Foundation
    $USING CQ.Cards

    CARD.TYPE.ID = FIELD(CARD.ID, "*", 2)
    CARD.ID = FIELD(CARD.ID, "*", 1)

    BEGIN CASE

        CASE CARD.TYPE.ID = "BILL.CLOSE"

            GOSUB PROCESS.BILL.DATE

        CASE CARD.TYPE.ID = "REPAY.DATE"

            GOSUB PROCESS.REPAY.DATE

    END CASE


RETURN

PROCESS.BILL.DATE:
******************

    CARD.BILL.CLOSE.RECORD = ""
    CARD.BILL.CLOSE.RECORD = CQ.Cards.CardBillCloseDate.Read(CARD.ID, "")

    CARD.COUNT =  DCOUNT(CARD.BILL.CLOSE.RECORD,@FM)

    IF CARD.COUNT > 202 THEN
        RETURN
    END

    BILL.DATE.ID = CARD.ID

    NEW.BILL.DATE.ID = BILL.DATE.ID
    READ.WRITE = 'READ'
    TEMP.ID = BILL.DATE.ID
    BILL.REC =  ''
    LOOP
    WHILE READ.WRITE[1,4] EQ 'READ'
        TEMP.BILL.REC =''
        READ.WRITE<2> = '200'
        AZ.Foundation.EbReadWriteTable(TEMP.ID,'CARD.BILL.CLOSE.DATE',READ.WRITE,TEMP.BILL.REC,'')
        IF TEMP.BILL.REC THEN
            BILL.REC<-1> = TEMP.BILL.REC
        END
    REPEAT

    READ.WRITE = 'DELETE':@FM:'200'
    AZ.Foundation.EbReadWriteTable(BILL.DATE.ID,'CARD.BILL.CLOSE.DATE',READ.WRITE,'','')

    READ.WRITE = 'WRITE'
    AZ.Foundation.EbReadWriteTable(NEW.BILL.DATE.ID,'CARD.BILL.CLOSE.DATE',READ.WRITE,BILL.REC,'')

    EB.TransactionControl.JournalUpdate(NEW.BILL.DATE.ID)

RETURN

PROCESS.REPAY.DATE:
*******************

    CARD.BILL.REPAY.RECORD = ""
    CARD.BILL.REPAY.RECORD = CQ.Cards.CardRepaymentDate.Read(CARD.ID, "")
    CARD.COUNT =  DCOUNT(CARD.BILL.REPAY.RECORD ,@FM)

    IF CARD.COUNT > 202 THEN
        RETURN
    END

    REPAY.DATE.ID = CARD.ID

    NEW.REPAY.DATE.ID = REPAY.DATE.ID
    READ.WRITE = 'READ'
    TEMP.ID = REPAY.DATE.ID
    REPAY.REC =  ''

    LOOP
    WHILE READ.WRITE[1,4] EQ 'READ'
        TEMP.REPAY.REC =''
        READ.WRITE<2> = '200'
        AZ.Foundation.EbReadWriteTable(TEMP.ID,'CARD.REPAYMENT.DATE',READ.WRITE,TEMP.REPAY.REC,'')
        IF TEMP.REPAY.REC THEN
            REPAY.REC<-1> = TEMP.REPAY.REC
        END
    REPEAT

    READ.WRITE = 'DELETE':@FM:'200'
    AZ.Foundation.EbReadWriteTable(REPAY.DATE.ID,'CARD.REPAYMENT.DATE',READ.WRITE,'','')

    READ.WRITE = 'WRITE'
    AZ.Foundation.EbReadWriteTable(NEW.REPAY.DATE.ID,'CARD.REPAYMENT.DATE',READ.WRITE,REPAY.REC,'')

    EB.TransactionControl.JournalUpdate(NEW.REPAY.DATE.ID)

RETURN

END

