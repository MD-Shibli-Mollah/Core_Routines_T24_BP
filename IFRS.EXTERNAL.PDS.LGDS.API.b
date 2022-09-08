* @ValidationCode : MjotMTU1OTMyNDUyMjpDcDEyNTI6MTUxNTQ5Mjg5MTcxNTp2aGluZHVqYTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE3MTIuMjAxNzEwMjctMDAyMDotMTotMQ==
* @ValidationInfo : Timestamp         : 09 Jan 2018 15:44:51
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vhinduja
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201712.20171027-0020
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE I9.Config
SUBROUTINE IFRS.EXTERNAL.PDS.LGDS.API(TARRAY,PDS,LGDS,R.EB.CASHFLOW.VAL,CON.CASHFLOW.DATE, CON.CASHFLOW.AMT,EXP.CASHFLOW.AMT ,CON.NPV,EXP.NPV, tECL ,T.FLAG,TERROR)
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
* 30/12/17 - Defect 2378810 / Task 2399124
*            IFRS9 - IFRS.PARAMETER - OPENING THE FIELD FOR API return PDS and LGDS
*            Sample API return PDS and LGDS alone.
*            PDS and LDS are read from local field in LD record.
*
*-----------------------------------------------------------------------------
   
    $USING EB.LocalReferences
    $USING LD.Contract
    $USING EB.SystemTables
    

    IF T.FLAG EQ "PROJECTED.ECL" THEN
        RETURN
    END
   
    GOSUB GET.LOCAL.FIELD ; *

RETURN
*-----------------------------------------------------------------------------

*** <region name= GET.LOCAL.FIELD>
GET.LOCAL.FIELD:
*** <desc> </desc>

    PD.POS = ""
    EB.LocalReferences.GetLocRef("LD.LOANS.AND.DEPOSITS", "PD1", PD.POS)

    LGD.POS = ""
    EB.LocalReferences.GetLocRef("LD.LOANS.AND.DEPOSITS", "LGD1", LGD.POS)

    PD.ACT.VAL = EB.SystemTables.getRNew(LD.Contract.LoansAndDeposits.LocalRef)<1,PD.POS>
    LD.ACT.VAL = EB.SystemTables.getRNew(LD.Contract.LoansAndDeposits.LocalRef)<1,LGD.POS>
    
    PDS = RAISE(PD.ACT.VAL) ;*covert 'SM' delimiter to 'VM'
    LGDS = LD.ACT.VAL
    

RETURN
*** </region>

END
