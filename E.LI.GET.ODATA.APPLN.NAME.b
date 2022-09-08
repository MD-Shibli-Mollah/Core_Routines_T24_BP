* @ValidationCode : Mjo0MjEzODQxNDg6Q3AxMjUyOjE2MTY5OTkzNDI0NDc6bS5kaGluZXNocmFqYToyOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTAzLjIwMjEwMzAxLTA1NTY6NTg6MjA=
* @ValidationInfo : Timestamp         : 29 Mar 2021 11:59:02
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : m.dhineshraja
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 20/58 (34.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210301-0556
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE LI.ModelBank
SUBROUTINE E.LI.GET.ODATA.APPLN.NAME
*-----------------------------------------------------------------------------
* Conversion routine to form ODATA with application name and txn.ref
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
* 23/03/21 - Defect 4274512 / Task 4302379
*            View Contract details - drilldown not shown for the enquiry LIM.TXN in UXPB
*-----------------------------------------------------------------------------
    $USING EB.Reports
    GOSUB Initialise ; *
    GOSUB SET.ODATA ; *Form the Odata
RETURN
*-----------------------------------------------------------------------------

*** <region name= Initialise>
Initialise:
*** <desc> </desc>
    oData = ''
    applname = ''
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= SET.ODATA>
SET.ODATA:
*** <desc>Form the Odata </desc>
    oData          = EB.Reports.getOData()      ;* O.DATA
    GOSUB SET.APPLICATION.NAME ; *Based on the first two letters of txn.ref,find the application name
    IF applname NE ''  THEN
        oData = applname:' S ':oData
    END
    EB.Reports.setOData(oData)
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= SET.APPLICATION.NAME>
SET.APPLICATION.NAME:
*** <desc>Based on the first two letters of txn.ref,find the application name </desc>
    BEGIN CASE
        CASE oData[1,2] EQ 'BL'
            applname = 'BL.BILL'
        CASE oData[1,2] EQ 'FX'
            applname = 'FOREX'
        CASE oData[1,2] EQ 'LD'
            applname = 'LD.LOANS.AND.DEPOSITS'
        CASE oData[1,2] EQ 'AC'
            oData = 'ACCT.BAL.TODAY'
        CASE oData[1,2] EQ 'MD'
            applname = 'MD.DEAL'
        CASE oData[1,2] EQ 'MM'
            applname = 'MM.MONEY.MARKET'
        CASE oData[1,2] EQ 'SA'
            applname = 'LIMIT.SUB.ALLOC'
        CASE oData[1,2] EQ 'MG'
            applname = 'MG.MORTGAGE'
        CASE oData[1,2] EQ 'TF'
            IF LEN(oData) GT 14 THEN
                applname = 'DRAWINGS'
            END ELSE
                applname = 'LETTER.OF.CREDIT'
            END
        CASE oData[1,2] EQ 'FD'
            applname = 'FD.FIDUCIARY'
        CASE oData[1,2] EQ 'FO'
            applname = 'FD.FID.ORDER'
        CASE oData[1,2] EQ 'SW'
            applname = 'SWAP'
        CASE oData[1,2] EQ 'PD'
            applname = 'PD.PAYMENT.DUE'
        CASE oData[1,2] EQ 'SF'
            applname = 'FACILITY'
        CASE oData[1,2] EQ 'SL'
            applname = 'SL.LOANS'
        CASE oData[1,2] EQ 'FR'
            applname = 'FRA.DEAL'
        CASE oData[1,2] EQ 'ST'
            applname = 'SC.TRADING.POSITION'
        CASE oData[1,2] EQ 'SC'
            applname = 'SEC.TRADE'
        CASE oData[1,2] EQ 'DX'
            applname = 'DX.TRADE'
    END CASE

RETURN
*** </region>

END
