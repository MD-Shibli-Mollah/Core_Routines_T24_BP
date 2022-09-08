* @ValidationCode : MjotOTcyOTkyMTA4OkNwMTI1MjoxNTM0NTg3NDM5MDk5OnNpdmFjaGVsbGFwcGE6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTgwOC4yMDE4MDcyMS0xMDI2OjU4OjUx
* @ValidationInfo : Timestamp         : 18 Aug 2018 15:47:19
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sivachellappa
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 51/58 (87.9%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201808.20180721-1026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE AA.Channels
SUBROUTINE E.TC.CONV.AA.PRODUCT.DETAILS
*---------------------------------------------------------------------------
*----------------------------------------------------------------------------
* Description:
* This routine is used to return the list of eligible products' Minimum and Maximum period (Term)
* for the applying customer.
*-----------------------------------------------------------------------------
* Subroutine type : CONVERSION
* Attached to     : Enquiry record TC.AA.PRODUCT
* Incoming        : O.DATA(Product)
* Outgoing        : O.DATA(Minimum and Maximum period - Term)
*-----------------------------------------------------------------------------
*---------------------------------------------------------------------------
* Modification History :
*----------------------------------------------------------------------------


    $USING EB.Reports
    $USING AA.ProductFramework
    $USING AA.TermAmount

    GOSUB INITIALISE
    GOSUB PROCESS
*
RETURN
*---------------------------------------------------------------------------
*** <region name= Initialise>
INITIALISE:
* Initialise the required variables
    IN.ARGS = EB.Reports.getOData() ;* Get Product value
    RESULT.SET = '' ;* Initialise Result array
    EFF.DATE='' ;* Initialise effective date
    CURRENCY.COUNT='' ;* Initialise currency count
    CURRENCY.ID='' ;* Initialise currency
    CURRENCY='' ;* Initialise currency array
    MIN.TERM ='' ;* Initialise minimum period
    MAX.TERM ='' ;* Initialise maximum period
    MIN.TERM.ARRAY ='' ;* Initialise minimum period array
    MAX.TERM.ARRAY ='' ;* Initialise maximum period array
    PRODUCT.LINE='';* Initialise product line
    PRODUCT='' ;* Initialise product
    NR.TYPE='' ;* Initialise NR Type variable
    NR.VALUE='' ;* Initialise NR Type value
*
RETURN
***</region>
*-------------------------------------------------------------------------
*** <region name= Process>
PROCESS:
*To retrieve the min and max term or period of the product
    PRODUCT.LINE=FIELD(IN.ARGS,"-",1)
    PRODUCT=FIELD(IN.ARGS,"-",2)
    CURRENCY=FIELD(IN.ARGS,"-",3)
    CURRENCY = CHANGE(CURRENCY,'|',@VM)
    EFF.DATE=FIELD(IN.ARGS,"-",4)
    IF(PRODUCT.LINE EQ "DEPOSITS") THEN
        CURRENCY.COUNT = DCOUNT(CURRENCY,@VM) ;* Count the number of currency item.
        GOSUB PROCESS.PRODUCT.DETAILS
    END

    EB.Reports.setOData(RESULT.SET) ;* Return the min and max term or period of the product
  
RETURN
***</region>
*--------------------------------------------------------------------
*** <region name= Process the min and max term>

* Build an array with the min and max term or period for the selected product
PROCESS.PRODUCT.DETAILS:
    FOR CCY.CNT= 1 TO CURRENCY.COUNT ;* loop for each currency for the selected product.
        CURRENCY.ID = CURRENCY<1,CCY.CNT>
        AA.ProductFramework.GetProductConditionRecords(PRODUCT, CURRENCY.ID, EFF.DATE, OUT.PROPERTY.LIST, OUT.PROPERTY.CLASS.LIST, OUT.ARRANGEMENT.LINK.TYPE,OUT.PROPERTY.CONDITION.LIST,RET.ERR)
        LOCATE 'TERM.AMOUNT' IN OUT.PROPERTY.CLASS.LIST<1> SETTING TERM.POS THEN
            PROD.PROPERTY.RECORD = RAISE(OUT.PROPERTY.CONDITION.LIST<TERM.POS>)
            NR.TYPE = PROD.PROPERTY.RECORD<AA.TermAmount.TermAmount.AmtNrType>
            NR.VALUE = PROD.PROPERTY.RECORD<AA.TermAmount.TermAmount.AmtNrValue>
            FIND "MINPERIOD" IN NR.TYPE SETTING FM.POS,VM.POS,SM.POS
            THEN  MIN.TERM = NR.VALUE<FM.POS,VM.POS,SM.POS> ELSE  MIN.TERM = '0D'
            FIND "MAXPERIOD" IN NR.TYPE SETTING FM.POS,VM.POS,SM.POS
            THEN  MAX.TERM = NR.VALUE<FM.POS,VM.POS,SM.POS> ELSE MAX.TERM = '0D'
            IF(MIN.TERM EQ '0D' AND MAX.TERM EQ '0D') THEN  ;* If both the values are not set, instead of assigning '0D', it is made as 'null'
                MIN.TERM = ''
                MAX.TERM = ''
            END
            IF NOT(MIN.TERM.ARRAY) THEN
                MIN.TERM.ARRAY = MIN.TERM
            END ELSE
                MIN.TERM.ARRAY := '|':MIN.TERM ;* Form array for minimum period
            END
            IF NOT(MAX.TERM.ARRAY) THEN
                MAX.TERM.ARRAY = MAX.TERM
            END ELSE
                MAX.TERM.ARRAY := '|':MAX.TERM ;* Form array for maximum period
            END
        END
    NEXT CCY.CNT
    
    RESULT.SET = MIN.TERM.ARRAY:'*':MAX.TERM.ARRAY;* Result array with minimum and maximum period
*
RETURN

***</region>
*-----------------------------------------------------------------------------

END
