* @ValidationCode : MjotNTA1NDc1NDQxOkNwMTI1MjoxNTk4Mzc2NjI4MjYwOnZoaW5kdWphOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwNy4yMDIwMDcwMS0wNjU3Oi0xOi0x
* @ValidationInfo : Timestamp         : 25 Aug 2020 23:00:28
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vhinduja
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202007.20200701-0657
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE I9.Config
SUBROUTINE SEAT.IFRS.PV.GET.CLASSIFICATION.RC(APP.NAME,CONT.ID,R.CONTRACT,RETURN.CLASS,CLASS.ERR)
*-----------------------------------------------------------------------------
* Modification History :

* 12/10/18 - Enhancement 1886853 / Task 2132167
*            API to return the PV.CLASSIFICATION to be attached in PV.MANAGEMENT record
*
* 11/12/18 - Enhancement 2890185 / Task 2890205
*            Get CUSTOMER.KEY and CATEGORY for FACILITY, SL.LOANS and BL.REGISTER.
*
* 24/10/19 - Enhancement 3364047 / Task 3402619
*            Allow Customers with Mnemonic as I9PV<XXXXXX> where XXXXXX is customer number
*            to return the contract's classification
*
* 17/8/2020 - Task 3886096
*            Consider the category 60000 as valid for limit classification
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER
    $INSERT I_F.LD.LOANS.AND.DEPOSITS
    $INSERT I_F.ACCOUNT
    $INSERT I_F.SL.LOANS
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.BL.REGISTER
    $INSERT I_F.FACILITY
    $INSERT I_F.LIMIT
    $INSERT I_F.MM.MONEY.MARKET
    $INSERT I_F.CUSTOMER
    $INSERT I_F.MG.MORTGAGE

*-----------------------------------------------------------------------------

    GOSUB INITIALISE

    IF NOT(CONTRACT.VAL.DATE) OR NOT(CUSTOMER.KEY) OR NOT(CATEGORY) OR INVALID.CAT THEN
        RETURN
    END

*   If the Contract's customer doesnt fall within the range, then look whether its mnemonic starts with I9PV
    IF (CUSTOMER.KEY LT "152100" OR CUSTOMER.KEY GT "152399") AND (CUSTOMER.KEY LT "126100" OR CUSTOMER.KEY GT "126199") THEN
        IF MNEMONIC[1,4] NE "I9PV" AND MNEMONIC[1,4] NE 'JXPV' THEN
            RETURN
        END
    END
    
    IF MNEMONIC[1,4] EQ 'JXPV' THEN
        JX.FLAG = '1'
    END
    
    IF JX.FLAG THEN
        JX.CLASS = R.CUSTOMER<EB.CUS.TEXT,1>
        IF JX.CLASS NE '' THEN
            RETURN.CLASS = JX.CLASS
        END ELSE
            RETURN.CLASS = 'GOOD'
        END
    END ELSE
        GOSUB GET.DUE.DATE

        IF NUM(CONT.ID) OR CONT.ID[1,2] EQ "AA" THEN
            GOSUB PROCESS.AA
        END ELSE
            GOSUB PROCESS
        END
    END
                      
    
RETURN

*-----------------------------------------------------------------------------

INITIALISE:
 
    TODAY.DATE = TODAY
    INVALID.CAT = @FALSE
    CONTRACT.DUE.DAYS = ''
    BEGIN CASE
        CASE APP.NAME[1,2] EQ 'LD'
            CONTRACT.VAL.DATE = R.CONTRACT<LD.VALUE.DATE>
            CUSTOMER.KEY = R.CONTRACT<LD.CUSTOMER.ID>    ;* Customer id
            CATEGORY =  R.CONTRACT<LD.CATEGORY>
            IF CATEGORY NE "21073" AND CATEGORY NE "21072" AND CATEGORY NE "21095" AND CATEGORY NE "21096" AND CATEGORY NE "21070" AND CATEGORY NE "21071" THEN
                INVALID.CAT = @TRUE
            END
        CASE APP.NAME[1,2] EQ 'FA'
            CONTRACT.VAL.DATE = R.CONTRACT<FAC.VALUE.DATE>
            CUSTOMER.KEY = R.CONTRACT<FAC.CUSTOMER> ;* Customer id
            CATEGORY =  R.CONTRACT<FAC.CATEGORY>
            IF CATEGORY NE "49910" AND CATEGORY NE "49905" THEN
                INVALID.CAT = @TRUE
            END

        CASE APP.NAME[1,2] EQ 'SL'
            CONTRACT.VAL.DATE = R.CONTRACT<SL.LN.VALUE.DATE>
            CUSTOMER.KEY = R.CONTRACT<SL.LN.CUSTOMER> ;* Customer id
            CATEGORY =  R.CONTRACT<SL.LN.CATEGORY>
            IF CATEGORY NE "49910" AND CATEGORY NE "49905" THEN
                INVALID.CAT = @TRUE
            END

        CASE APP.NAME[1,2] EQ 'BL'
            CONTRACT.VAL.DATE = R.CONTRACT<BL.REG.START.DATE>
            CUSTOMER.KEY = R.CONTRACT<BL.REG.LIAB.CUST>   ;* Customer id
            CATEGORY =  R.CONTRACT<BL.REG.CATEGORY>
            IF CATEGORY NE "30001" THEN
                INVALID.CAT = @TRUE
            END
            
        CASE APP.NAME[1,2] EQ 'MM'
            CONTRACT.VAL.DATE = R.CONTRACT<MM.VALUE.DATE>
            CUSTOMER.KEY = R.CONTRACT<MM.CUSTOMER.ID>    ;* Customer id
            CATEGORY =  R.CONTRACT<MM.CATEGORY>
            IF CATEGORY NE "21074" THEN
                INVALID.CAT = @TRUE
            END

        CASE APP.NAME[1,2] EQ 'MG'
            CONTRACT.VAL.DATE = R.CONTRACT<MG.VALUE.DATE>
            CUSTOMER.KEY = R.CONTRACT<MG.CUSTOMER>    ;* Customer id
            CATEGORY =  R.CONTRACT<MG.CATEGORY>
            IF ABS(CATEGORY) LT 25000 OR ABS(CATEGORY) GT 25499  THEN
                INVALID.CAT = @TRUE
            END
                        
        CASE APP.NAME[1,2] EQ 'AC'
            CONTRACT.VAL.DATE = "20091223"
            CUSTOMER.KEY = R.CONTRACT<AC.CUSTOMER>   ;* Customer id
            CATEGORY =  R.CONTRACT<AC.CATEGORY>
            IF CATEGORY NE "1002" AND CATEGORY NE "1001" THEN
                INVALID.CAT = @TRUE
            END
                    
        CASE APP.NAME[1,2] EQ 'LI'
            CONTRACT.VAL.DATE = "20091223"
            CUSTOMER.KEY = R.CONTRACT<LI.LIABILITY.NUMBER>   ;* Customer id
            CATEGORY = R.CONTRACT<LI.LIMIT.PRODUCT>
            IF CATEGORY NE "6200" AND CATEGORY NE "6210" AND CATEGORY NE "6220" AND CATEGORY NE "60000" THEN
                INVALID.CAT = @TRUE
            END

        CASE NUM(CONT.ID)

            GOSUB CHECK.AA ; *

        CASE CONT.ID[1,2] EQ "AA"

*           If the Incoming CONT.ID is Arrangement Id , get the Account ID
            RET.ERR = ""
            CALL AA.GET.ARRANGEMENT.ACCOUNT.ID(CONT.ID,ACCOUNT.ID,CURRENCY,RET.ERR)
            
*           Read the Account record and set them in the param R.CONTRACT
            CALL F.READ("F.ACCOUNT", ACCOUNT.ID, R.CONTRACT, "", ERR)
 
            GOSUB CHECK.AA ; *
        
    END CASE

    CONTRACT.DUE.DAYS = ''
    R.CUSTOMER = ''
    CALL F.READ("F.CUSTOMER", CUSTOMER.KEY, R.CUSTOMER, "", ERR)
    MNEMONIC = R.CUSTOMER<EB.CUS.MNEMONIC>

RETURN

*-----------------------------------------------------------------------------
GET.DUE.DATE:

    CALL CDD('',CONTRACT.VAL.DATE,TODAY.DATE,CONTRACT.DUE.DAYS)

RETURN

*-----------------------------------------------------------------------------

PROCESS:


    BEGIN CASE
        CASE CONTRACT.DUE.DAYS GE 0 AND CONTRACT.DUE.DAYS LT 2
            RETURN.CLASS = 'GOOD'

        CASE CONTRACT.DUE.DAYS GE 2 AND CONTRACT.DUE.DAYS LT 3
            RETURN.CLASS = 'AVERAGE'

        CASE CONTRACT.DUE.DAYS GE 3
            RETURN.CLASS = 'BAD'

    END CASE

RETURN
*-----------------------------------------------------------------------------
PROCESS.AA:

    BEGIN CASE
        CASE CONTRACT.DUE.DAYS GE 0 AND CONTRACT.DUE.DAYS LT 2
            RETURN.CLASS = 'GOOD'

        CASE CONTRACT.DUE.DAYS GE 2 AND CONTRACT.DUE.DAYS LT 3
            RETURN.CLASS = 'AVERAGE'

        CASE CONTRACT.DUE.DAYS GE 3
            RETURN.CLASS = 'BAD'

    END CASE

RETURN
*-----------------------------------------------------------------------------
*** <region name= CHECK.AA>
CHECK.AA:
*** <desc> </desc>
    CUSTOMER.KEY = R.CONTRACT<AC.CUSTOMER>    ;* Customer id
    CATEGORY =  R.CONTRACT<AC.CATEGORY>
    AA.ID = R.CONTRACT<AC.ARRANGEMENT.ID>

    IF NOT(AA.ID) THEN
        IF CATEGORY NE '1001' THEN
            INVALID.CAT = @TRUE
        END
        CONTRACT.VAL.DATE = R.CONTRACT<AC.OPENING.DATE>
    END ELSE
    
        FN.ARR = "F.AA.ACCOUNT.DETAILS"
        F.ARR = ""
    
        CALL OPF(FN.ARR, F.ARR)
        CALL F.READ(FN.ARR, AA.ID , R.ARR ,F.ARR ,ERR)
    
        CONTRACT.VAL.DATE = R.ARR<AA.AD.VALUE.DATE>

        IF NOT(CONTRACT.VAL.DATE) THEN
            FN.ARR = "F.AA.ARRANGEMENT"
            F.ARR = ""

            CALL OPF(FN.ARR, F.ARR)
            CALL F.READ(FN.ARR, AA.ID , R.ARR ,F.ARR ,ERR)
            CONTRACT.VAL.DATE = R.ARR<AA.ARR.PROD.EFF.DATE>

        END
    END
    IF CATEGORY NE "1001" THEN
        INVALID.CAT = @TRUE
    END
        
RETURN
*** </region>

*-----------------------------------------------------------------------------
END
