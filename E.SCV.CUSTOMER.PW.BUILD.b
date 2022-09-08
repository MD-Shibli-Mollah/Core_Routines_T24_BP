* @ValidationCode : MjoxNDMwODI1MDAwOkNwMTI1MjoxNjA0NDcxNjk4MzI5OmJzYXVyYXZrdW1hcjoxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDEwLjIwMjAwOTI5LTEyMTA6MTI1OjUy
* @ValidationInfo : Timestamp         : 04 Nov 2020 12:04:58
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bsauravkumar
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 52/125 (41.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202010.20200929-1210
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------

* <Rating>125</Rating>
*-----------------------------------------------------------------------------
$PACKAGE ST.ModelBank

SUBROUTINE E.SCV.CUSTOMER.PW.BUILD(ENQ.DATA)
*-----------------------------------------------------------------------------
*
* Subroutine Type : BUILD Routine
* Attached to     : SCV.CUSTOMER.PW
* Attached as     : Build Routine
* Primary Purpose : We need a way of searching a customer based on any products held
*                   by the customer (like current account or a deposit or a loan) or
*                   even a Card number.
*                   Current account, deposit and loan are all in ACCOUNT table. Card number
*                   is in CARD.ISSUE
*                   Optionally we should also be able to link the photo of the customer (from
*                   IM.DOCUMENT.IMAGE.
*                   There are 4 new S type I-descs added to CUSTOMER table namely ACCOUNT.NO,
*                   CARD.NO and INCLUDE.IMAGE and IM.DOCUMENT.IMAGE
*                   It is important that the Operand for all these three I-Descs should always be
*                   EQ.
*                   Based on the account number or card number, try to get the customer number
*                   and add it as a selection criteria to ENQ.DATA which core will use to
*                   select CUSTOMER table with.
*                   'S' type i-desc are not used by core for selection. But provide a way
*                   of supplying data to routines like this one without intruding core
*                    processing.
*
* Incoming:
* ---------
*
*
* Outgoing:
* ---------
*
*
* Error Variables:
* ----------------
*
*
*-----------------------------------------------------------------------------------
* Modification History:
*
* 28 OCT 2010 - Sathish PS
*               New Development for RMB1 SI
*
* 22 NOV 2010 - Included additional requirement to fetch details when Portfolio No
*               is given as selection
*
* 23 APR 2015 - Enhancement 1263702
*               Changes done to Remove the inserts and incorporate the routine
*
* 02 MAY 2017 - Enhancement 1765879 / Task 2106068
*               Read on account table is done only when AC product is installed
*               in the current company
*
* 24 SEP 2019 - Enhancement - 3186323 / Task - 3354515
*             - CQ product installation check.
*
* 04 NOV 2020 - Defect 4061103 / Task 4061937
*               CQ product check before doing OPF
*-----------------------------------------------------------------------------------
    $USING FT.Contract
    $USING CQ.Cards
    $USING AC.AccountOpening
    $USING EB.DataAccess
    $USING EB.Interface
    $USING EB.SystemTables
    $USING EB.Reports
    $USING EB.API

    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB CHECK.PRELIM.CONDITIONS
    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

RETURN          ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:

    IF CUSTOMER.NO THEN
        GOSUB ADD.CUSTOMER.NO.TO.SELECTION
    END

RETURN          ;* from PROCESS
*-----------------------------------------------------------------------------------
ADD.CUSTOMER.NO.TO.SELECTION:

    LOCATE 'CUSTOMER.CODE' IN ENQ.DATA<2,1> SETTING CUS.CODE.POS THEN
        IF ENQ.DATA<4,CUS.CODE.POS> NE CUSTOMER.NO THEN
            EB.Reports.setEnqError('EB-RMB1.CUSTOMER.CODE.MISMATCH')
            tmp=EB.Reports.getEnqError(); tmp<2,1>=ENQ.DATA<4,CUS.CODE.POS>; EB.Reports.setEnqError(tmp)
            tmp=EB.Reports.getEnqError(); tmp<2,2>=CUSTOMER.NO; EB.Reports.setEnqError(tmp)
        END
    END

    IF NOT(EB.Reports.getEnqError()) THEN
        ENQ.DATA<2,-1> = 'CUSTOMER.CODE'
        ENQ.DATA<3,-1> = 'EQ'
        ENQ.DATA<4,-1> = CUSTOMER.NO
    END

RETURN
*-----------------------------------------------------------------------------------
* <New Subroutines>

* </New Subroutines>
*-----------------------------------------------------------------------------------*
*//////////////////////////////////////////////////////////////////////////////////*
*////////////////P R E  P R O C E S S  S U B R O U T I N E S //////////////////////*
*//////////////////////////////////////////////////////////////////////////////////*
INITIALISE:

    PROCESS.GOAHEAD = 1
    SEL.FIELDS := @VM: 'ACCOUNT.NO' :@VM: 'LOAN.NO' :@VM: 'DEPOSIT.NO'
    SEL.FIELDS := @VM: 'CARD.NO'
    CUSTOMER.NO = ''
    
    CQInstalled = ''
    EB.API.ProductIsInCompany('CQ', CQInstalled)   ;* Checks if CQ product is installed

RETURN          ;* From INITIALISE
*-----------------------------------------------------------------------------------
OPEN.FILES:
    
    IF CQInstalled THEN
        FN.CI = 'F.CARD.ISSUE' ; F.CI = ''
        EB.DataAccess.Opf(FN.CI,F.CI)
    END

RETURN          ;* From OPEN.FILES
*-----------------------------------------------------------------------------------
CHECK.PRELIM.CONDITIONS:
*
    LOOP.CNT = 1 ; MAX.LOOPS = 3
    LOOP
    WHILE LOOP.CNT LE MAX.LOOPS AND PROCESS.GOAHEAD DO

        BEGIN CASE
            CASE LOOP.CNT EQ 1
                LOCATE 'ACCOUNT.NO' IN ENQ.DATA<2,1> SETTING AC.NO.POS THEN
                    IF ENQ.DATA<3,AC.NO.POS> NE 'EQ' THEN
                        EB.Reports.setEnqError('EB-RMB1.ALLOWED.OPERAND.FOR.ACCOUNT.NO')
                    END ELSE
                        ACCOUNT.NO = ENQ.DATA<4,AC.NO.POS>
                        GOSUB GET.CUSTOMER.NO.FROM.ACCOUNT.NO
                    END
                END

            CASE LOOP.CNT EQ 2
                LOCATE 'CARD.NO' IN ENQ.DATA<2,1> SETTING CARD.NO.POS THEN
                    IF ENQ.DATA<3,CARD.NO.POS> NE 'EQ' THEN
                        EB.Reports.setEnqError('EB-RM1.ALLOWED.OPERAND.FOR.CARD.NO')
                    END ELSE
                        CARD.NO = ENQ.DATA<4,CARD.NO.POS>
                        GOSUB GET.CUSTOMER.NO.FROM.CARD.NO
                        IF NOT(EB.Reports.getEnqError()) THEN
                            ENQ.DATA<4,CARD.NO.POS> = CARD.NO   ;! The full Card Number including the Card Type as a Prefix
                        END
                    END
                END

            CASE LOOP.CNT EQ 3
                LOCATE 'PORTFOLIO.NO' IN ENQ.DATA<2,1> SETTING PORTFOLIO.NO.POS THEN
                    PORTFOLIO.NO = ENQ.DATA<4,PORTFOLIO.NO.POS>
                    CUSTOMER.NO=FIELD(PORTFOLIO.NO,'-',1)
                END

        END CASE
        LOOP.CNT += 1

        BEGIN CASE
            CASE EB.Reports.getEnqError()
                PROCESS.GOAHEAD = 0

            CASE CUSTOMER.NO
                BREAK

        END CASE

    REPEAT

RETURN          ;* From CHECK.PRELIM.CONDITIONS
*-----------------------------------------------------------------------------------
GET.CUSTOMER.NO.FROM.ACCOUNT.NO:
    !
    ! VAL.PROG will anyway be set to IN2.ALLACCVAL for this 'S' type field in SS... Check anyway
    !
    IF NOT(NUM(ACCOUNT.NO)) THEN
        GOSUB GET.ACCOUNT.NO
    END
    IF NOT(EB.Reports.getEnqError()) THEN
        R.AC = '' ; ERR.AC = ''
        acInstalled = ''
        EB.API.ProductIsInCompany('AC', acInstalled)
        
        IF acInstalled THEN
            R.AC = AC.AccountOpening.tableAccount(ACCOUNT.NO, ERR.AC)
        END
        IF R.AC THEN
            CUSTOMER.NO = R.AC<AC.AccountOpening.Account.Customer>
        END ELSE
            EB.Reports.setEnqError('EB-RMB1.INVALID.PRODUCT.REFERENCE')
        END
    END

RETURN
*-----------------------------------------------------------------------------------
GET.ACCOUNT.NO:

    SAVE.COMI = EB.SystemTables.getComi() ; SAVE.ETEXT = EB.SystemTables.getEtext() ; SAVE.DISPLAY = EB.SystemTables.getVDisplay()
    N1 = '35' ; T1 = '.ALLACCVAL'
    FT.Contract.In2Allaccval(N1,T1)
    IF EB.SystemTables.getEtext() THEN
        EB.Reports.setEnqError(EB.SystemTables.getEtext())
    END ELSE
        ACCOUNT.NO = EB.SystemTables.getComi()
    END
    EB.SystemTables.setComi(SAVE.COMI); EB.SystemTables.setEtext(SAVE.ETEXT); EB.SystemTables.setVDisplay(SAVE.DISPLAY)

RETURN
*-----------------------------------------------------------------------------------
GET.CUSTOMER.NO.FROM.CARD.NO:
    
    IF NOT(CQInstalled) THEN
        RETURN
    END
    
    GOSUB SELECT.FROM.CARD.ISSUE
    IF NOT(EB.Reports.getEnqError()) THEN
        R.CI = '' ; ERR.CI = ''
        R.CI = CQ.Cards.tableCardIssue(CARD.NO, ERR.CI)
        IF R.CI THEN
            ACCOUNT.NO = R.CI<CQ.Cards.CardIssue.CardIsAccount,1>
            GOSUB GET.CUSTOMER.NO.FROM.ACCOUNT.NO
        END ELSE
            EB.Reports.setEnqError('EB-RMB1.INVALID.CARD.NO')
        END
    END

RETURN
*-----------------------------------------------------------------------------------
SELECT.FROM.CARD.ISSUE:

    SEL.CMD = 'SELECT ':FN.CI
    SEL.CMD := ' LIKE ...':CARD.NO
    EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,'',NO.SEL,RETURN.CODE)
    IF SEL.LIST THEN
        CARD.NO = SEL.LIST<1>
    END

RETURN
*-----------------------------------------------------------------------------------
END
