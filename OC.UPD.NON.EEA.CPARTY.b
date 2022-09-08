* @ValidationCode : Mjo2MDk0MzY0OTQ6Y3AxMjUyOjE0ODcwNzc4MDc1NTU6aGFycnNoZWV0dGdyOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTYxMi4yMDE2MTEwMi0xMTQyOi0xOi0x
* @ValidationInfo : Timestamp         : 14 Feb 2017 18:40:07
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : harrsheettgr
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201612.20161102-1142
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-20</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.NON.EEA.CPARTY(APPL.ID, APPL.REC, FIELD.POS, RET.VAL)
*-----------------------------------------------------------------------------
****
*<Routine desc>
*
*The routine can be attached as LINK routine in tax mapping record
*to determine whether T24 bank has made a contract with non -EEA cparty.
*
* Incoming parameters:
*
* APPL.ID  - Id of transaction
* APPL.REC  - A dynamic array holding the contract.
* FIELD.POS - Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
*Ret.val - "Y" if trade with non -EEA deal cparty.
*		 - "N" if trade with European cparty .
*-----------------------------------------------------------------------------
* Modification History :
*
* 12/12/16 - Enhancement 1764033 / Task 1829190
*            Bring sample EMIR mappings into Dev
*
*-----------------------------------------------------------------------------

    $INSERT I_CustomerService_Profile

    $USING FX.Contract
    $USING OC.Parameters
    $USING ST.Config
    $USING SW.Contract
*-----------------------------------------------------------------------------

    GOSUB INITIALIZE

    GOSUB PROCESS

    RETURN

INITIALIZE:
***<desc>Initialise the variables</desc>

    RET.VAL = ''
    CUSTOMER.ID = ''
    READ.ERR = ''
    customerProfile=''
    responseDetails=''

    COUNTRY = ''


    R.COUNTRY = ''

    RETURN

PROCESS:

    BEGIN CASE
        CASE APPL.ID[1,2] = "FX";*when forex trade
            CUSTOMER.ID = APPL.REC<FX.Contract.Forex.Counterparty>
        CASE APPL.ID[1,2] = "ND";*ndf trade
            CUSTOMER.ID = APPL.REC<FX.Contract.NdDeal.NdDealCounterparty>
        CASE APPL.ID[1,2] = "SW";*swap deal
            CUSTOMER.ID = APPL.REC<SW.Contract.Swap.Customer>
    END CASE

    CALL CustomerService.getProfile(CUSTOMER.ID, customerProfile) 

    COUNTRY =customerProfile<Profile.residence>;*fetch country

    R.COUNTRY = ST.Config.Country.Read(COUNTRY, READ.ERR);*read country record
* Before incorporation : CALL F.READ(FN.COUNTRY, COUNTRY, R.COUNTRY, F.COUNTRY, READ.ERR);*read country record

    IF R.COUNTRY<ST.Config.Country.EbCouGeographicalBlock> EQ 'EUROPE' THEN;*if geographical block falls in europe,
        RET.VAL = "N"
    END ELSE
        RET.VAL = "Y"
    END

    RETURN  

    END
