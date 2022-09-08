* @ValidationCode : Mjo5NTc3MDY0OTI6Q3AxMjUyOjE1NDE3NjA2Njk5ODA6aGFycnNoZWV0dGdyOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTgxMC4yMDE4MDkwNi0wMjMyOi0xOi0x
* @ValidationInfo : Timestamp         : 09 Nov 2018 16:21:09
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : harrsheettgr
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201810.20180906-0232
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-49</Rating>
*-----------------------------------------------------------------------------
$PACKAGE OC.Parameters
SUBROUTINE OC.UPD.REP.MODEL(TXN.ID,TXN.REC,TXN.DATA,RET.VAL)

******************************************************************
* Modification History:
*
* 18/03/15 - EN 1047936 / Task 1252419
*            FX - Mapping & COB scheduling
*
* 06/04/15 - EN 1177301 / Task 1284514
*            FRA - Mapping & COB scheduling
*
* 22/04/15 - EN 1177300 / Task 1320631
*            NDF - Mapping & COB scheduling
*
* 05/08/15 - Enhancement 1179782 / Task 1179788
*            Swap clearing phase 1 - Template changes  - DX
*
* 23/09/15 - EN - 1461371 / Task - 1461382
*            OTC Collateral and Valuation Reporting
*
* 30/12/15 - EN_1226121 / Task 1568411
*            Incorporation of the routine
*
* 08/10/18 - Enh 2789746 / Task 2789749
*            Changing OC.Parameters to ST.Customer to access OC.CUSTOMER
*
*******************************************************************
*
*
*The purpose of the routine is to identify reporting model for OTC trade.
*
* Incoming parameters:
*
* Txn.id   - Id of transaction
* Txn.rec  - A dynamic array holding the contract.
* Txn.data - Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
*Ret.val- Variable holding the reporting status.
*
*
*******************************************************************




    $USING EB.SystemTables
    $USING FX.Contract
    $USING FR.Contract
    $USING SW.Contract
    $USING OC.Parameters
    $USING DX.Trade
    $USING EB.DataAccess
    $USING ST.Customer

    GOSUB INITIALISE ; *INITIALISE
    GOSUB IDENTIFY.REPORTING.PARTY ; *IDENTIFY.REPORTING.PARTY
    RET.VAL=REPORTING.STATUS


RETURN

*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
INITIALISE:
*** <desc>INITIALISE </desc>

    SINGLE=''
    PRI.CUS.NO=''
    R.OC.CUSTOMER=''
    OC.Parameters.setROcParam('')

    FN.OC.PARAMETER ="F.OC.PARAMETER"
    F.OC.PARAMETER=''
    EB.DataAccess.Opf(FN.OC.PARAMETER,F.OC.PARAMETER)

    tmp.ID.COMPANY = EB.SystemTables.getIdCompany()
    OC.Parameters.setROcParam(OC.Parameters.OcParameter.Read(tmp.ID.COMPANY, READ.ERR))
* Before incorporation : CALL F.READ("F.OC.PARAMETER",tmp.ID.COMPANY,R.OC.PARAM,F.OC.PARAMETER,READ.ERR)
    EB.SystemTables.setIdCompany(tmp.ID.COMPANY)


    BEGIN CASE
        CASE TXN.ID[1,2] = 'FX'
            CUS.ID = TXN.REC<FX.Contract.Forex.Counterparty>;*get deal counterparty
        CASE TXN.ID[1,2] = 'FR'
            CUS.ID = TXN.REC<FR.Contract.FraDeal.FrdCounterparty>
        CASE TXN.ID[1,2] = 'ND'
            CUS.ID = TXN.REC<FX.Contract.NdDeal.NdDealCounterparty>
        CASE TXN.ID[1,2] = 'SW'
            CUS.ID = TXN.REC<SW.Contract.Swap.Customer>
        CASE TXN.ID[1,2] = 'DX'
            PRI.CUS.NO = TXN.REC<DX.Trade.Trade.TraPriCustNo>
            CUS.ID = PRI.CUS.NO<1,1>
    END CASE

    R.OC.CUSTOMER = ST.Customer.OcCustomer.Read(CUS.ID, READ.ERR)
* Before incorporation : CALL F.READ("F.OC.CUSTOMER",CUS.ID,R.OC.CUSTOMER,F.OC.CUSTOMER,READ.ERR)
    REPORTING.PARTY = R.OC.CUSTOMER<ST.Customer.OcCustomer.CusReportingCustomer>;*reporting party status from oc.customer

    IF OC.Parameters.getROcRegulator()<OC.Parameters.OcRegulator.RegReportingJurisdiction> EQ 'SINGLE' THEN
        SINGLE = 1;*flag to indicate single reporting jurisdiction
    END

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= IDENTIFY.REPORTING.PARTY>
IDENTIFY.REPORTING.PARTY:
*** <desc>IDENTIFY.REPORTING.PARTY </desc>


    BEGIN CASE


        CASE REPORTING.PARTY EQ 'YES';*If the counterparty is the reporting party,then T24 bank would not report the trade to trade repository.
            REPORTING.STATUS='0'


        CASE REPORTING.PARTY EQ 'DELEGATED';*If the counterparty has delegated the reporting

            IF OC.Parameters.getROcParam()<OC.Parameters.OcParameter.ParamThirdPartyReporting> EQ 'YES' THEN

                REPORTING.STATUS=0;*T24 bank has delegated the reporting to a third party.Hence ,the bank would not report.

            END ELSE

                IF SINGLE THEN
                    REPORTING.STATUS=1;*If single reporting jurisdiction,then bank will report only its own trade details.
                END ELSE
                    REPORTING.STATUS=2;*If multiple reporting jurisdiction,then bank will report its own trade details and also counterparty details.
                END

            END

        CASE REPORTING.PARTY EQ ''

            MODULE.NAME = EB.SystemTables.getApplication()
            BANK.CPARTY=EB.SystemTables.getIdCompany()
            DEAL.CPARTY=CUS.ID

            IF SINGLE THEN;*then call for tie breaker logic to identify the reporting party

                OC.Parameters.IdentifyGenParty( MODULE.NAME ,DEAL.CPARTY, BANK.CPARTY, GENERATING.CPARTY , '' ,'')

            END

            IF GENERATING.CPARTY EQ BANK.CPARTY OR NOT(SINGLE)  THEN;*If t24 bank is the generating cparty or multiple jurisdiction ,then check for
*third party reporting status in oc.parameter.
                GOSUB CHECK.THIRD.PARTY.REPORT ; *CHECK.THIRD.PARTY.REPORT

            END ELSE

                REPORTING.STATUS=0

            END



    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= CHECK.THIRD.PARTY.REPORT>
CHECK.THIRD.PARTY.REPORT:
*** <desc>CHECK.THIRD.PARTY.REPORT </desc>

    IF OC.Parameters.getROcParam()<OC.Parameters.OcParameter.ParamThirdPartyReporting> EQ 'YES' THEN
        REPORTING.STATUS=0;*bank would not report
    END ELSE
        REPORTING.STATUS=1;*bank would report
    END

RETURN
*** </region>


END
