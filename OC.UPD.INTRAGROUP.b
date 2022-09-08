* @ValidationCode : MjozNjEwNzM4MzY6Q3AxMjUyOjE1NDE3NjA1OTEzMjI6aGFycnNoZWV0dGdyOjI6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTAuMjAxODA5MDYtMDIzMjoyNDoyNA==
* @ValidationInfo : Timestamp         : 09 Nov 2018 16:19:51
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : harrsheettgr
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 24/24 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201810.20180906-0232
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
$PACKAGE OC.Reporting

SUBROUTINE OC.UPD.INTRAGROUP(APPL.ID, APPL.REC, FIELD.POS, RET.VAL)
*-----------------------------------------------------------------------------
*<Routine description>
*
* Attached as a link routine in TX.TXN.BASE.MAPPING record to
* report know if the transaction was concluded within Inter Group.
*
*
* Incoming parameters:
*
* APPL.ID   -   Transaction ID of the contract.
* APPL.REC  -   A dynamic array holding the contract.
* FIELD.POS -   Current field in OC.TRADE.DATA.
*
* Outgoing parameters:
*
* RET.VAL   -   Y - If the transaction was concluded within Inter Group
*               N - Else
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 12/12/16 - Enhancement 1764033 / Task 1829190
*            Bring sample EMIR mappings into Dev
*
* 08/10/18 - Enh 2789746 / Task 2789749
*            Changing OC.Parameters to ST.Customer to access OC.CUSTOMER
*
*-----------------------------------------------------------------------------

    $USING SW.Contract
    $USING OC.Parameters
    $USING ST.Customer

*-----------------------------------------------------------------------------

    GOSUB INITIALIZE
    GOSUB PROCESS

RETURN
*-----------------------------------------------------------------------------

INITIALIZE:


    RET.VAL = ''
    R.OC.CUSTOMER = ''
    READ.ERR = ''
    OC.CUST.ID = ''

RETURN

*-----------------------------------------------------------------------------

PROCESS:


    BEGIN CASE

        CASE APPL.ID[1,2] EQ 'SW'

* Get the  field value required from the contract
            EXEC.VENUE = APPL.REC<SW.Contract.Swap.ExecVenue>

* If the venue is not XXXX, then the OC Customer's customer type is read to decide the return.
* If the type is "INTERGROUP MEMBER" then Y else N

            IF EXEC.VENUE NE "XXXX" THEN
                OC.CUST.ID = APPL.REC<SW.Contract.Swap.Customer>
*        CALL F.READ(FN.OC.CUSTOMER,OC.CUST.ID,R.OC.CUSTOMER,F.OC.CUSTOMER,CUST.ERR)
                R.OC.CUSTOMER = ST.Customer.OcCustomer.Read(OC.CUST.ID, READ.ERR)
                IF NOT(READ.ERR) THEN
                    IF R.OC.CUSTOMER<ST.Customer.OcCustomer.CusCustomerType> EQ "INTERGROUP MEMBER" THEN
                        RET.VAL = 'Y'
                    END ELSE
                        RET.VAL = 'N'
                    END
                END
            END

    END CASE

RETURN
*-----------------------------------------------------------------------------
END
