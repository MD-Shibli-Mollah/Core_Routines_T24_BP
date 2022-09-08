* @ValidationCode : Mjo3MjcwMjc3MDU6Q3AxMjUyOjE1OTk1NjcwNTczNzM6a2JoYXJhdGhyYWo6NjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOC4yMDIwMDczMS0xMTUxOjQ2OjIx
* @ValidationInfo : Timestamp         : 08 Sep 2020 17:40:57
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kbharathraj
* @ValidationInfo : Nb tests success  : 6
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 21/46 (45.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OC.Reporting
SUBROUTINE OC.UPD.EXEC.ENTITY.ID(APPL.ID,APPL.REC,FIELD.POS,RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
*
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* populte the OC.PARAMETER>BANK.LEI or if BROKER field has a value then populate the LEI of broker Id from OC.CUSTOMER
*
* Incoming parameters:
*
* APPL.ID   -   Transaction ID of the contract.
* APPL.REC  -   A dynamic array holding the contract.
* FIELD.POS -   Current field in OC.MIFID.DATA.
*
* Outgoing parameters:
*
* RET.VAL   - LEI ID
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 31/03/20 - Enhancement 3660935 / Task 3660937
*            CI#3 - Mapping Routines - Part I
*
* 02/04/2020 - Enhancement - 3661737 / Task - 3661740
*              CI#3 Mapping Routines Part-2
*
* 11/06/20 - Enhancement 3715903 / Task 3796601
*            MIFID changes for DX - OC changes
*
* 27/08/20 - Enhancement 3793940 / Task 3793943
*            CI#3 - Mapping routines - Part II
*-----------------------------------------------------------------------------

    $USING FX.Contract
    $USING ST.CompanyCreation
    $USING EB.SystemTables
    $USING OC.Parameters
    $USING FR.Contract
    $USING SW.Contract
    $USING ST.Customer
    $USING DX.Trade
*-----------------------------------------------------------------------------
    GOSUB INITIALIZE ; *
    GOSUB PROCESS ; *


RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALIZE>
INITIALIZE:
*** <desc> </desc>
    OcParamRec = ''
    BankLei = ''
    OcParamId = ''
    RET.VAL = ''
    BrokerId = ''
    OcCustomerRec = ''
    Lei = ''
RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc> </desc>
    IF (APPL.ID[1,2] EQ 'FR') OR (APPL.ID[1,2] EQ 'ND') OR (APPL.ID[1,2] EQ 'SW') OR (APPL.ID[1,2] EQ 'DX') OR (APPL.ID[1,2] EQ 'FX')THEN
        OcParamId = EB.SystemTables.getIdCompany()
        OcParamErr = ''
        ST.CompanyCreation.EbReadParameter('F.OC.PARAMETER', '', '', OcParamRec, OcParamId, '', OcParamErr)
        IF OcParamRec THEN
            BankLei = OcParamRec<OC.Parameters.OcParameter.ParamBankLei>
            IF BankLei THEN
                RET.VAL = BankLei
            END ELSE
                BEGIN CASE
                    CASE APPL.ID[1,2] = 'SW'
                        BrokerId = APPL.REC<SW.Contract.Swap.BrokerCode>
    
                    CASE APPL.ID[1,2] = 'FR'
                        BrokerId = APPL.REC<FR.Contract.FraDeal.FrdBrokerDealMeth>
                        
                    CASE APPL.ID[1,2] = 'DX'
                        BrokerId = APPL.REC<DX.Trade.Trade.TraExecutingBroker>
                         
                    CASE APPL.ID[1,2] = 'FX'
                        BrokerId = APPL.REC<FX.Contract.Forex.Broker>
                        
                END CASE
                GOSUB ASSIGN.LEI.FROM.OC.CUSTOMER ; *
            END
        END
        RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= ASSIGN.LEI.FROM.OC.CUSTOMER>
ASSIGN.LEI.FROM.OC.CUSTOMER:
*** <desc> </desc>
        IF BrokerId THEN
            OcCusErr = ''
            OcCustomerRec = ST.Customer.OcCustomer.CacheRead(BrokerId, OcCusErr)
            IF OcCustomerRec THEN
                Lei = OcCustomerRec<ST.Customer.OcCustomer.CusLegalEntityId>
                IF Lei THEN
                    RET.VAL = Lei
                END
            END
        END
        RETURN
*** </region>

    END



