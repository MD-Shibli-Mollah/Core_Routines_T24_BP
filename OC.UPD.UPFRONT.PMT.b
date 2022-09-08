* @ValidationCode : MjoxMzI4Mjk0MjY4OkNwMTI1MjoxNTkyNTcwOTc0NjU4OnN0aGVqYXN3aW5pOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDYuMjAyMDA1MjctMDQzNTo0NDo0Mg==
* @ValidationInfo : Timestamp         : 19 Jun 2020 18:19:34
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sthejaswini
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 42/44 (95.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202006.20200527-0435
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.UPFRONT.PMT(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
* The routine will determine the amount of any upfront payment done.
* Attached as a link routine in TX.TXN.BASE.MAPPING record to report
* the upfront payments on the contract.
*
*
* Incoming parameters:
*
* APPL.ID   -   Transaction ID of the contract.
* APPL.REC  -   A dynamic array holding the contract.
* FIELD.POS -   Current field in OC.MIFID.DATA.
*
* Outgoing parameters:
*
* RET.VAL   -   For swap deals based on the assest/liab type equal to 'PMUF' the sum of the asset/liab amounts is obtained.
*               For DX deals fetch PREM.PYMT.AMT field,if it holds value else fetch the value PRI.TOTAL.PREM.AMT
*
*
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 13/04/20 - Enhancement 3661787 / Task 3661793
*            CI#4 - Mapping Routines - Part III
*
* 11/06/20 - Enhancement 3715903 / Task 3796601
*            MIFID changes for DX - OC changes
*
*-----------------------------------------------------------------------------
    $USING SW.Contract
    $USING SW.Foundation
    $USING DX.Trade

    GOSUB Initialise ; *
    GOSUB Process ; *
RETURN

*-----------------------------------------------------------------------------

*** <region name= Initialise>
Initialise:
*** <desc> </desc>
    ASSET.AMT = ""
    LIAB.AMT = ""
    ASSET.TYPE = ''
    LIAB.TYPE = ''
    NO.OF.SCHEDULES = ""
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= Process>
Process:
*** <desc> </desc>
    BEGIN CASE
        CASE APPL.ID[1,2] EQ 'SW'
            CheckIfNewReport = APPL.REC<SW.Contract.Swap.MifidReportStatus> = "NEWT"
            IF CheckIfNewReport NE "" THEN
                ASSET.TYPE = APPL.REC<SW.Contract.Swap.AsType>
                NO.OF.SCHEDULES = DCOUNT(ASSET.TYPE,@VM)
                GOSUB CalculateAssetAmount ; *
                LIAB.TYPE = APPL.REC<SW.Contract.Swap.LbType>
                NO.OF.SCHEDULES = DCOUNT(LIAB.TYPE,@VM)
                GOSUB CalculateLiabAmount ; *
                RET.VAL = ASSET.AMT + LIAB.AMT
            END
        
        CASE APPL.ID[1,2] EQ 'DX'
            CheckIfNewReport = APPL.REC<DX.Trade.Trade.TraMifidReportStatus> = "NEWT"
            IF CheckIfNewReport NE "" THEN
                IF APPL.REC<DX.Trade.Trade.TraPremPymtAmt> NE '' THEN
                    RET.VAL = APPL.REC<DX.Trade.Trade.TraPremPymtAmt>
                END ELSE
                    RET.VAL = APPL.REC<DX.Trade.Trade.TraPriTotalPremAmt>
                END
            END
    END CASE
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= CalculateAssetAmount>
CalculateAssetAmount:
*** <desc> </desc>

    FOR I = 1 TO NO.OF.SCHEDULES
        IF (ASSET.TYPE<1,I> EQ 'PMUF')  THEN
            ASSET.AMT =  ASSET.AMT + APPL.REC<SW.Contract.Swap.AsAmount,I>
        END
    NEXT I
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= CalculateLiabAmount>
CalculateLiabAmount:
*** <desc> </desc>
  
    FOR I = 1 TO NO.OF.SCHEDULES
        IF (LIAB.TYPE<1,I> EQ 'PMUF')  THEN
            LIAB.AMT =  LIAB.AMT + APPL.REC<SW.Contract.Swap.LbAmount,I>
        END
    NEXT I
RETURN
*** </region>

END




