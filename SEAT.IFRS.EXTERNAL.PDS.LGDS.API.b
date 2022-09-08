* @ValidationCode : MjotMTExMzYwODYxNTpjcDEyNTI6MTUzOTkyMTAyMTAwNDpra2F2aXRoYW5qYWxpOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE4MDguMjAxODA3MjEtMTAyNjotMTotMQ==
* @ValidationInfo : Timestamp         : 19 Oct 2018 09:20:21
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : kkavithanjali
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201808.20180721-1026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE I9.Config
SUBROUTINE SEAT.IFRS.EXTERNAL.PDS.LGDS.API(TARRAY,PDS,LGDS,R.EB.CASHFLOW.VAL,CON.CASHFLOW.DATE, CON.CASHFLOW.AMT,EXP.CASHFLOW.AMT ,CON.NPV,EXP.NPV, tECL ,T.FLAG,TERROR)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
*Incoming param:
*-------------------
* TARRAY<1>   - CashflowId
* TARRAY<2>   - CustomerId
* TARRAY<3>   - Period End Date
* TARRAY<4>   - Seperated by valueMarkers and it contains the RATE Values of the contract based on npv rate.
*  *TARRAY<4,1> - Either EIR or Marketkey
*  *TARRAY<4,2> - MarginOperand
*  *TARRAY<4,3> - MarketMargin
*  *TARRAY<4,4> - Either B(BID) or O(OFFER)
* TARRAY<5>   - Seperated by valueMarkers and it contains InterestBasis
*  *TARRAY<5,1> - InterestBasis
*  *TARRAY<5,2> - Currency
* TARRAY<6>   - Present Stage of the Contract.
*
* CON.CASHFLOW.DATE - Contractual Cashflow Dates
* CON.CASHFLOW.AMT  - Contractual Cashflow Amounts
* ECL.FLAG          - Either 'ACTUAL.ECL' or 'PROJECTED.ECL'(ACTUAL.ECL represent to calculate the ECL for current period and PROJECTED.ECL represent to calcuate the ECL for future)
*
*
*Outgoing param:
*---------------------
*  Read the record where PDS and LGDs are stored and  passed back to PDS and LGDS parameter.
*  NOTE :
*  --------
*  PDs and LGD values are converted based on PD.PER.NUM and LGD.PER.NUM fields in IFRS.PARAMETER.
*  if these fields are specified as PERCENTAGE in IFRS.PARAMETER record, then PD's and LGD are convert to decimal number for calculation.
*  if these fields are specified as  NUMBER in IFRS.PARAMETER record, then PD's and LGD are taken as number for calculation.
*
* PDS     -  PDs to calculate the ECL
* LGDS    -  LGD to calcuate the ECL
* TERROR  -  Any Error to be thrown
*
*
* Modification History :
*
* 12/10/18 - Defect 2378810 / Task 2399124
*            IFRS9 - IFRS.PARAMETER - OPENING THE FIELD FOR API return PDS and LGDS
*            Sample API return PDS and LGDS alone.
*
* 19/10/18 - Task 2817785
*            FM separator changed to VM for PD values
*
*-----------------------------------------------------------------------------
   
    IF T.FLAG EQ "PROJECTED.ECL" THEN
        RETURN
    END
   
    GOSUB GET.PD.LGD ; *

RETURN
*-----------------------------------------------------------------------------

*** <region name= GET.PD.LGD>
GET.PD.LGD:
*** <desc> </desc>


    PDS<1,1> = "0.40"
    PDS<1,2> = "0.45"
    LGDS   = "70"
    
RETURN
*** </region>

END
