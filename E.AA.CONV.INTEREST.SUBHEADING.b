* @ValidationCode : MjotMTQzNzEwMjA5OkNwMTI1MjoxNjA1NTExNjAyNTg4OmRpdnlhc2FyYXZhbmFuOjM6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjEtMDY1NToyMToyMQ==
* @ValidationInfo : Timestamp         : 16 Nov 2020 12:56:42
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : divyasaravanan
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 21/21 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200521-0655
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


*-----------------------------------------------------------------------------
* <Rating>-27</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ModelBank
SUBROUTINE E.AA.CONV.INTEREST.SUBHEADING
*-----------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Program Description </desc>
**
* Conversion routine to return last period date
*
* @uses I_ENQUIRY.COMMON I_F.AA.ARRANGEMENT
* @package AA.ModelBank
* @stereotype subroutine
* @author divyasaravanan@temenos.com
*
**

*** </region>
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*
* 11/11/20 - Task : 4076072
*            Enhancement : 3164925
*            Conversion routine to return property description based on productline
*
*** </region>

*-----------------------------------------------------------------------------
*** <region name= Inserts>
***
   
    $USING EB.Reports
    $USING AA.Framework

*** </region>

*-----------------------------------------------------------------------------
*** <region name= Main control>
*** <desc>Main control logic in the sub-routine</desc>
    GOSUB Initialise
    GOSUB MainProcess

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise local variables and file variables</desc>
Initialise:
*----------

    AccrualId =  EB.Reports.getOData() ;* Get incoming accrual id
    ArrangementId = FIELD(AccrualId,'-',1) ;* Fetch arrangement id
    SkimFlag = FIELD(AccrualId,'-',5) ;* Skim flag

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Main Process>
*** <desc>Main control logic in the sub-routine</desc>
MainProcess:
*------------

* Get arrangement record
    RArrangement = ''
    RetError = ''
    AA.Framework.GetArrangement(ArrangementId, RArrangement, RetError)
    
    ProductLine = RArrangement<AA.Framework.Arrangement.ArrProductLine> ;* Fetch product line
    
    BEGIN CASE
        CASE SkimFlag  EQ 'SKIM'
            ReturnData = 'Skim Accruals'
            
        CASE ProductLine EQ 'LENDING'
            ReturnData = 'Interest Accruals'
            
        CASE ProductLine EQ 'FACILITY'
            ReturnData = 'Fee Accruals'
    END CASE
          
    EB.Reports.setOData(ReturnData) ;* Set OData value

RETURN
*** </region>
*-----------------------------------------------------------------------------
END

