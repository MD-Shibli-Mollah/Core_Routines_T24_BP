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
* <Rating>-40</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FX.ModelBank
    SUBROUTINE E.BUILD.FX.IDS(ARR.FX.IDS)
*
*********************************************************
* 24/09/03 - BG_100005226
*          - Inability to close positions.
*
* 19/02/04 - BG_100006251
*     Transaction Management and Performance Fixes
*     Fix applied on the usage of EB.READLIST Command
*
* 25/06/04 - BG_100006841
*            Bug fix for Transaction Management and Performance Fixes
*
* 07/04/06 - BG_100010895
*            Session hanges while executing the enquiry FX.CLS.GRP
*
* 24/01/07 - BG_100012827
*            Enquiry FX.CLS.GRP doesnot work even though relevant data exists
*
* 07/03/07 - EN_10003249
*            Replace all SELECT and EB.READLIST statements with DAS commands in FX
*
* 25/11/08 - BG_100021002
*            Rating Reduction
*
* 15/09/15 - EN_1226121 / Task 1477143
*	      	 Routine incorporated
*
**********************************************************

    $USING FX.Contract
    $USING EB.DataAccess
    $USING EB.Reports
    $USING FX.ModelBank

    $INSERT I_DAS.FOREX
*
    GOSUB INITIALISE
    GOSUB PROCESS
    RETURN
*
INITIALISE:
*===========
*
    RETURN
*
PROCESS:
*========
*
    LOCATE "COUNTERPARTY" IN EB.Reports.getDFields()<1> SETTING CUS.POS ELSE
    CUS.POS = ''
    END
    IF CUS.POS THEN
        CNTR.PRTY = EB.Reports.getDRangeAndValue()<CUS.POS>
    END
*
    LOCATE "VALUE.DATE" IN EB.Reports.getDFields()<1> SETTING VAL.DT.POS ELSE
    VAL.DT.POS = ''
    END
    IF VAL.DT.POS THEN
        VAL.DATE = EB.Reports.getDRangeAndValue()<VAL.DT.POS>
    END
*
    SEL.LIST = '';THE.ARGS = ''
    SWAP.DEAL = 'SW'
* dasForexNofileEnq1 - This query selects records from FOREX table
* matching the given values of counterparty, value date buy, closing id,
* option date, record status and with deal type NE to the given value and
* with value date sell condition
    THE.LIST = dasForexNofileEnq1 ;TABLE.SUFFIX = ''
    THE.ARGS<1> = CNTR.PRTY
    THE.ARGS<2> = VAL.DATE
    THE.ARGS<3> = ''
    THE.ARGS<4> = SWAP.DEAL
    THE.ARGS<5> = ''
    THE.ARGS<6> = ''
    EB.DataAccess.Das('FOREX',THE.LIST,THE.ARGS,TABLE.SUFFIX)
    SEL.LIST = THE.LIST
*
    LOOP
        REMOVE FX.ID FROM SEL.LIST SETTING FX.POS
    WHILE FX.ID:FX.POS
        ER = ''
        R.FX = ''
        R.FX = FX.Contract.Forex.Read(FX.ID, ER)
        IF ER THEN
            R.FX = ''
        END
        IF R.FX THEN
            IF R.FX<FX.Contract.Forex.Status,1> NE "MAT" THEN
                ARR.FX.IDS<-1> = FX.ID
            END
        END
    REPEAT
*
    RETURN
    END
