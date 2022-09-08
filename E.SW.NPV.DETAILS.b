* @ValidationCode : MjoxNjMwNTUzNzMzOkNwMTI1MjoxNTAwODk1MTUwNTI4OmhhcnJzaGVldHRncjoxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxNzAyLjA6NzI6NTU=
* @ValidationInfo : Timestamp         : 24 Jul 2017 16:49:10
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : harrsheettgr
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 55/72 (76.3%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*
*-----------------------------------------------------------------------------
    $PACKAGE SW.Reports
    SUBROUTINE E.SW.NPV.DETAILS(NPV.DETAILS)
*-----------------------------------------------------------------------------
*** <region name= Parameters>
*** <desc>Parameter Details</desc>
*
* Parameters - NPV Details - Out
*
* Layout :
*    Details                   Index
*   ----------                -------
*    Schedule Type              1
*    Schedule Start Date        2
*    Schedule End Date          3
*    Schedule Cash flow         4
*    Days Difference            5
*    Period Days                6
*    Coupon Curve Rate          7
*    Previous PV                8
*    Zero Rates                 9
*    Current NPV               10
*    Leg Type                  11
*    Total Cashflow            12
*    Total PV                  13
*    Interest Accrued          14
*    Leg NPV                   15
*
*** </region>
*
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Modification History</desc>
*
* 09/02/17 - EN_2010681/ Task 2010677
*            Transparency in NPV calculation
*
*
*** </region>
*
*-----------------------------------------------------------------------------
*** <region name= Using>
*** <desc>Include necessary components</desc>

    $USING SW.Contract
    $USING SW.PositionAndReval
    $USING EB.DataAccess
    $USING SW.Foundation
    $USING EB.Reports

*** </region>
*
*-----------------------------------------------------------------------------
*** <region name= Main Process>
*** <desc>Processing details </desc>
MAIN.PROCESS:
*
    GOSUB INITIALISATION
*
    GOSUB READ.SWAP.RECORDS

    GOSUB CALC.NPV

    RETURN ;*  exit out

*** </region>
*
*-----------------------------------------------------------------------------
*** <region name= Initialization>
*** <desc>Load neccessary variables </desc>
***************
INITIALISATION:
***************
*
* The opf and common variables are needed for the manipulation in SW.NPV.CALCULATION so load here

    F$SWAP.LOC = ""
    EB.DataAccess.Opf("F.SWAP",F$SWAP.LOC)
    SW.Foundation.setFdSwap(F$SWAP.LOC)
*
    F.SWAP$NAU = ""
    EB.DataAccess.Opf("F.SWAP$NAU",F.SWAP$NAU)
*
    F$SWAP.BALANCES.LOC = ""
    EB.DataAccess.Opf("F.SWAP.BALANCES",F$SWAP.BALANCES.LOC)
    SW.Foundation.setFdSwapBalances(F$SWAP.BALANCES.LOC)
*
    SW.Foundation.setRSwap("")
    SW.Foundation.setRSwAssetBalances("")
    SW.Foundation.setRSwLiabilityBalances("")
    SW.Foundation.setCAccountingEntries("")
    SW.Foundation.setCForwardEntries("")
*
    LOCATE "CONTRACT.ID" IN EB.Reports.getDFields()<1> SETTING APPL.POS THEN
    ID.VAL = EB.Reports.getDRangeAndValue()<APPL.POS>
    END

    ID.SWAP = FIELD(ID.VAL,"*",1)

    SW.Foundation.setCSwapId(ID.SWAP);* Swap contract id.
    ASST.BAL.ID = SW.Foundation.getCSwapId():".A"        ;* Asset swap bal id.
    LIAB.BAL.ID = SW.Foundation.getCSwapId():".L"        ;* Liab swap bal id.

    LOCATE "DISCOUNT.RATE" IN EB.Reports.getDFields()<1> SETTING APPL.POS THEN
    DISCOUNT.RATE = EB.Reports.getDRangeAndValue()<APPL.POS>
    END
*
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Read contract details >
*** <desc>Load neccessary variables </desc>
READ.SWAP.RECORDS:
*
*  Read swap contract from either the swap unauth or auth file.
*  Set the common variables needed for SW.NPV.CALCULATION

    ER = ''
    C$SWAP.ID.VAL = SW.Foundation.getCSwapId()
    R$SWAP.VAL = SW.Contract.Swap.ReadNau(C$SWAP.ID.VAL, ER)
    IF ER THEN
        ER = ''
        R$SWAP.VAL = SW.Contract.Swap.Read(C$SWAP.ID.VAL, ER)
        IF ER THEN
            R$SWAP.VAL = ''
        END
    END
    SW.Foundation.setRSwap(R$SWAP.VAL)
*
*  Read swap balance asset and liability records.
*
    IF R$SWAP.VAL THEN
        ER = ''
        R$SW.ASSET.BALANCES.VAL = SW.Contract.SwapBalances.Read(ASST.BAL.ID, ER)
        IF ER THEN
            R$SW.ASSET.BALANCES.VAL = ''
        END
        ER = ''
        R$SW.LIABILITY.BALANCES.VAL = SW.Contract.SwapBalances.Read(LIAB.BAL.ID, ER)
        IF ER THEN
            R$SW.LIABILITY.BALANCES.VAL = ''
        END
        SW.Foundation.setRSwAssetBalances(R$SW.ASSET.BALANCES.VAL)
        SW.Foundation.setRSwLiabilityBalances(R$SW.LIABILITY.BALANCES.VAL)
    END
*
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Calculate Npv >
*** <desc>Calculate and get NPV details </desc>
CALC.NPV:
*Layout:
*NPV.DETAILS<-1> = Schedule Type * Schedule Start Date * Schedule End Date * Schedule Cash flow * Days Difference * Period Days * Coupon Curve Rate * Previous PV *Zero Rates * Current NPV * Leg Type
*NPV.DETAILS<-1> = NPV.DETAILS:* Total Cashflow * Total Pv * Interest Accrued * Leg NPV

    NPV.DATA = ''
    NPV.DATA<1> = 'DETAILS'  ;* flag to indicate that NPV transparency are needed

    SW.PositionAndReval.NpvCalculation(DISCOUNT.RATE,NPV.DATA) ;* get npv details

    NO.OF.CF = DCOUNT(NPV.DATA<11>,@VM) ;* Total number of cashflow
    LEG.START = 0  ;* flag to indicate the start of liab leg
    FOR CF = 1 TO NO.OF.CF ;* Process each cashflow

        IF NPV.DATA<21,CF> = 'L' AND NOT(LEG.START) THEN ;* If it is the start of Liability leg, then append total for Asset leg
            NPV.DETAILS = NPV.DETAILS:'*':NPV.DATA<22,(CF-1)>:'*':NPV.DATA<23,(CF-1)>:'*':NPV.DATA<24,(CF-1)>:'*':NPV.DATA<25,(CF-1)>   ;* append asset totals which are available in the previous positions CF-1
            NPV.DETAILS<-1> = NPV.DATA<11,CF> :'*': NPV.DATA<12,CF> :'*': NPV.DATA<13,CF> :'*': NPV.DATA<14,CF> :'*': NPV.DATA<15,CF> :'*' :NPV.DATA<16,CF> :'*': NPV.DATA<17,CF> :'*': NPV.DATA<18,CF> :'*': NPV.DATA<19,CF> :'*' :NPV.DATA<20,CF> :'*': NPV.DATA<21,CF> ;* append current liab details
            LEG.START = 1  ;* start of liab leg
        END ELSE
            NPV.DETAILS<-1> = NPV.DATA<11,CF> :'*': NPV.DATA<12,CF> :'*': NPV.DATA<13,CF> :'*': NPV.DATA<14,CF> :'*': NPV.DATA<15,CF> :'*' :NPV.DATA<16,CF> :'*': NPV.DATA<17,CF> :'*': NPV.DATA<18,CF> :'*': NPV.DATA<19,CF> :'*' :NPV.DATA<20,CF> :'*': NPV.DATA<21,CF> ;* append current leg details
        END
        IF CF = NO.OF.CF THEN  ;* if end of the cashflow, then append total of Liab leg
            NPV.DETAILS = NPV.DETAILS:'*':NPV.DATA<22,CF>:'*':NPV.DATA<23,CF>:'*':NPV.DATA<24,CF>:'*':NPV.DATA<25,CF>
        END

    NEXT CF

    RETURN
*** </region>
*-----------------------------------------------------------------------------
    END ;* end of routine
