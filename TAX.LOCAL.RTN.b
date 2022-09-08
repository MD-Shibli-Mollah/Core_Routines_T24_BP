* @ValidationCode : MjoxMDI0MzY4ODcwOkNwMTI1MjoxNTgzMzA2Mjc2OTQ4OmluZGh1bWF0aGlzOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDMuMDoxNTA6NTg=
* @ValidationInfo : Timestamp         : 04 Mar 2020 12:47:56
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : indhumathis
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 58/150 (38.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>156</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CG.ChargeConfig
SUBROUTINE TAX.LOCAL.RTN(PASS.CUSTOMER,DEAL.AMOUNT,DEAL.CCY,CCY.MKT,CROSS.RATE,CROSS.CCY,DRAWDOWN.CCY,PASS.T.DATA,CUSTOMER.CONDITION,R.TAX,CHARGE.AMOUNT)

    $USING CG.ChargeConfig
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_DAS.TAX
    $INSERT I_DAS.COMMON

* 14/08/03 - EN_10001953
*            A sample routine which can be attached
*            as a local routine in TAX.Calculates the tax
*            amount for account customer & each joint holder.
* 05/09/03 - BG_100005108
*            Missed one 'END'.
* 26/02/07 - EN_10003224
*            Modified to call DAS to select data.
*
* 08/05/07 - BG_100013785
*            Use dasTaxIdLikeById for DAS query and remove the '.' from argument.
*
* 01/08/14 - DEFECT 1048635 / Task 1075008
*            system is passing tax entry only for the tax due from prime customer  For an account with JOINT.HOLDERS,
*            when a tax type is defined in the GCI in the field TAX.KEY with '*', system is not calculating the correct tax amount.
*
* 1/5/2017 - Enhancement 1765879 / Task 2106494
*            Remove dependency of code in ST products
*
* 11/10/19 - Enhancement 2822520 / Task 3380794
*            Code changed done for componentisation and to avoid errors while compilation
*            using strict compile
*Parameters:
*==========
* PASS.CUSTOMER =  PASS.CUSTOMER<1>& PASS.CUSTOMER<2> contains the CUSTOMER NO.
*                  CUSTOMER<3> contains the contract group for identify-
*                  ing the TAX.TYPE.CONDITION.
* DEAL.AMOUNT  =   Transaction amount.
* DEAL.CCY     =   Deal Currency.
* CCY.MKT      =   Currency Market.
* CROSS.RATE<1>=   The deal rate used in the transaction if present
* CROSS.RATE<2>=   The base currency used in the txn if present
* CROSS.RATE<3>=   Use Cross rate to convert charges when passing
*                  amount input in a different currency.
* CROSS.RATE<4>=   If set to 'Y', indicates that the deal rate
*                  should be used for currency conversions.
* CROSS.CURRENCY   The other currency involved in the transaction
* DRAWDOWN.CURRENCY Default deal currency.
* PASS.T.DATA      Contains all the tax details.
*                  PASS.T.DATA<1> contains the tax code.
*                  PASS.T.DATA<37>...PASS.T.DATA<47 contains
*                  the local routine details.
* R.TAX            Tax record
* CHARGE.AMOUNT    Charge amount

* If accountid is null then return

    ACCT.ID = PASS.T.DATA<38,1>
    IF ACCT.ID ELSE
        RETURN
    END

    GOSUB INITIALISE
    GOSUB CALCULATE.TAX

RETURN

INITIALISE:

    acInstalled = @FALSE
    CALL Product.isInCompany('AC',acInstalled)
    IF acInstalled THEN
        FN.ACCOUNT = 'F.ACCOUNT' ; F.ACCOUNT = ''
        CALL OPF(FN.ACCOUNT,F.ACCOUNT)
        R.ACCT = '' ; RET.ERR = ''
        CALL F.READ(FN.ACCOUNT,ACCT.ID,R.ACCT,F.ACCOUNT,RET.ERR)
        ACCT.CUSTOMER = R.ACCT<AC.CUSTOMER>
        NO.OF.JOINT.HOLDERS = DCOUNT(R.ACCT<AC.JOINT.HOLDER>,@VM)
    END
    FN.CUSTOMER.CHARGE = 'F.CUSTOMER.CHARGE'
    F.CUSTOMER.CHARGE = ''
    CALL OPF(FN.CUSTOMER.CHARGE,F.CUSTOMER.CHARGE)

    FN.TAX.TYPE.CONDITION = 'F.TAX.TYPE.CONDITION'
    F.TAX.TYPE.CONDITION = ''
    CALL OPF(FN.TAX.TYPE.CONDITION,F.TAX.TYPE.CONDITION)

    FN.TAX = 'F.TAX' ; F.TAX = ''
    CALL OPF(FN.TAX,F.TAX)

    TAX.TYPE = ''
    CONTRACT.GRP = PASS.CUSTOMER<3>     ;* Contains the contract group.

    TAX.GROUP = PASS.T.DATA<43>         ;* Get the tax type
    IF TAX.GROUP THEN
        NO.OF.JOINT.HOLDERS = NO.OF.JOINT.HOLDERS + 1       ;* To include account customer also.
    END
    TAX.DATE = FIELD(TAX.GROUP,".",2)
    IF NUM(TAX.DATE) THEN
        TAX.GROUP = FIELD(TAX.GROUP,".",1)
    END ELSE
        TAX.DATE = ''
    END
    
    IF TAX.GROUP[1,1] EQ '*' THEN
        TAX.GROUP=FIELD(TAX.GROUP,'*',2)
    END
    TAX.TYPE = FIELD(TAX.GROUP,"-",1)
    GOSUB READ.TAX.TYPE.CONDITION
* Get the charge amount,if it should calculate tax on charge.
* & split among the customers.
    AMT.PER.CUSTOMER = ''

    IF DEAL.AMOUNT  THEN
        IF NO.OF.JOINT.HOLDERS THEN
            AMT.PER.CUSTOMER = DEAL.AMOUNT/NO.OF.JOINT.HOLDERS
        END ELSE
            AMT.PER.CUSTOMER = DEAL.AMOUNT
        END
    END

* Get the tax code evaluated for the account customer
* in CALCULATE.CHARGE , even if the tax is a tax type.

    IF R.TAX THEN
        TAX.RATE.FOR.ACCT.CUST = R.TAX<CG.ChargeConfig.Tax.EbTaxRate>
    END

RETURN

CALCULATE.TAX:

* For account customer , tax code & amt on which tax is
* calculated in INITIALISE para.
    IF AMT.PER.CUSTOMER THEN
        TAX.FOR.ACCT.CUSTOMER = AMT.PER.CUSTOMER * TAX.RATE.FOR.ACCT.CUST/100

        PASS.T.DATA<44,1> = ACCT.CUSTOMER
        PASS.T.DATA<45,1> = TAX.FOR.ACCT.CUSTOMER

        CHARGE.AMOUNT = TAX.FOR.ACCT.CUSTOMER
        IF TAX.TYPE AND R.ACCT<AC.JOINT.HOLDER> THEN
* Calculate the tax amount for each joint holder.
            GOSUB CALC.TAX.FOR.JOINT.HLDR
        END
    END   ;* BG_100005108 S/E
RETURN

CALC.TAX.FOR.JOINT.HLDR:

* Loop through each joint holder
    FOR JOINT.HLDR.CNT = 1 TO NO.OF.JOINT.HOLDERS
        CUSTOMER.CHARGE.ID = R.ACCT<AC.JOINT.HOLDER,JOINT.HLDR.CNT>

* Read CUSTOMER.CHARGE for each joint holder.
        GOSUB READ.CUSTOMER.CHARGE

        IF R.CUSTOMER.CHARGE THEN

            IF R.TAX.TYPE.CONDITION THEN
                LOCATE TAX.TYPE IN R.CUSTOMER.CHARGE<CG.ChargeConfig.CustomerCharge.EbCchTaxType,1> SETTING TAX.POS ELSE
                    TAX.POS = ''
                END

                Y.TAX.ID = ''
                TAX.AMT.FOR.JNT.HLDR = ''

                IF TAX.POS THEN
                    GOSUB EVALUATE.TAX.GROUP      ;* Get the tax code
                END
                IF Y.TAX.ID THEN
                    GOSUB READ.TAX
                END
                Y.TAX.RATE = ''
                IF R.TAX.FOR.JNT.HLDR THEN
                    Y.TAX.RATE = R.TAX.FOR.JNT.HLDR<CG.ChargeConfig.Tax.EbTaxRate>
                END

                IF Y.TAX.RATE OR Y.TAX.RATE = '0' THEN
                    TAX.AMT.FOR.JNT.HLDR = AMT.PER.CUSTOMER * Y.TAX.RATE/100

* Update the array PASS.T.DATA<44> & PASS.T.DATA<45>
* with customer nos and respective tax amounts.
* And accumulate the amounts in CHARGE.AMOUNT.

                    PASS.T.DATA<44,-1> = CUSTOMER.CHARGE.ID
                    PASS.T.DATA<45,-1> = TAX.AMT.FOR.JNT.HLDR
                    CHARGE.AMOUNT = CHARGE.AMOUNT + TAX.AMT.FOR.JNT.HLDR        ;* Accumulate the charge amount.

                END
            END
        END

    NEXT JOINT.HLDR.CNT

RETURN

READ.CUSTOMER.CHARGE:

    R.CUSTOMER.CHARGE = '' ; RET.ERR = ''
    R.CUSTOMER.CHARGE = CG.ChargeConfig.CustomerCharge.Read(CUSTOMER.CHARGE.ID, RET.ERR)
RETURN

READ.TAX.TYPE.CONDITION:
    R.TAX.TYPE.CONDITION = '' ; RET.ERR = ''
    R.TAX.TYPE.CONDITION = CG.ChargeConfig.TaxTypeCondition.Read(TAX.GROUP, RET.ERR)

RETURN

EVALUATE.TAX.GROUP:
* Get the matching group from CUSTOMER.CHARGE & get the tax
* code from TAX.TYPE.CONDITION.

    CUST.GROUP = R.CUSTOMER.CHARGE<CG.ChargeConfig.CustomerCharge.EbCchTaxActGroup,TAX.POS>
    LOCATE CUST.GROUP IN R.TAX.TYPE.CONDITION<CG.ChargeConfig.TaxTypeCondition.TaxTtcCustTaxGrp,1> SETTING GRP.POS ELSE
        GRP.POS = ''
    END
    IF GRP.POS THEN
        DEF.GRP.POS = '' ; CONT.GRP.POS = ''
        IF R.TAX.TYPE.CONDITION<CG.ChargeConfig.TaxTypeCondition.TaxTtcContractGrp,GRP.POS,1> = "" THEN
            DEF.GRP.POS = 1 ;* Default group
        END
        IF CONTRACT.GRP THEN
            LOCATE CONTRACT.GRP IN R.TAX.TYPE.CONDITION<CG.ChargeConfig.TaxTypeCondition.TaxTtcContractGrp,GRP.POS,1> SETTING CONT.GRP.POS ELSE
                CONT.GRP.POS = ''
            END
        END
* if there is no group for this contract group then assign the default group.
        IF CONT.GRP.POS EQ '' THEN
            CONT.GRP.POS = DEF.GRP.POS
        END
        TAX.CODE = R.TAX.TYPE.CONDITION<CG.ChargeConfig.TaxTypeCondition.TaxTtcTaxCode,GRP.POS,CONT.GRP.POS>

        IF TAX.DATE THEN
            Y.TAX.ID = TAX.CODE:".":TAX.DATE
        END ELSE
            Y.TAX.ID = TAX.CODE:".":TODAY
        END
    END

RETURN

READ.TAX:

    R.TAX.FOR.JNT.HLDR = '' ; RET.ERR = ''
    R.TAX.FOR.JNT.HLDR = CG.ChargeConfig.Tax.Read(Y.TAX.ID, RET.ERR)

* If there is no record for this date, then get the latest record
* for the same tax id.

    IF RET.ERR THEN
        Y.TAX.CODE = FIELD(Y.TAX.ID,".",1)

        TAX.IDS        = dasTaxIdLikeById
        THE.ARGS       = Y.TAX.CODE : dasWildcard
        CALL DAS('TAX',TAX.IDS,THE.ARGS,'')

        IF TAX.IDS THEN
            LOCATE Y.TAX.ID IN TAX.IDS<1> BY 'AL' SETTING POSN ELSE
                POSN = POSN - 1
            END
            IF POSN THEN
                Y.TAX.ID = TAX.IDS<POSN>
                RET.ERR = ''
                R.TAX.FOR.JNT.HLDR = CG.ChargeConfig.Tax.Read(Y.TAX.ID, RET.ERR)
            END
        END
    END

RETURN
END
