* @ValidationCode : MjoxNTg2NTUxNjcwOkNwMTI1MjoxNTU5NTU0MTUwMzE5OnN1ZGhhcmFtZXNoOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwMi4yMDE5MDExNy0wMzQ3Oi0xOi0x
* @ValidationInfo : Timestamp         : 03 Jun 2019 14:59:10
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sudharamesh
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201902.20190117-0347
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-155</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.SEL.PROPERTY.COND(ID.LIST)
*
** Enquiry selection routine to return a list of records for a
** NOFILE enquiry showing all property conditions of a number of property
** classes
*
** Selection:
** BUILD.STAGE - DESIGNER, PROOF or CATALOGUE (default DESIGNER) EQ
** EFFECTIVE.DATE - EQ will show the properties effective for that date GT, LT
** CLASS - Will give a list if property conditions EQ
** CCY - EQ give only the following currency
** TARGET.PRODUCT - Used to filter conditions for Classic Products
**
** Returned
** ID.LIST - list of ids selected in the format
**           Property File Name _ Property Condition Id

    $USING AA.ProductFramework
    $USING EB.DataAccess
    $USING AA.Framework
    $USING EB.SystemTables
    $USING EB.Reports
    $USING AF.Framework

*
*
    GOSUB INITIALISE
    GOSUB BUILD.SELECTION
    GOSUB BUILD.LIST
*
    RETURN
*
INITIALISE:
*
    ID.LIST = ''
*
    RETURN
*
BUILD.SELECTION:
*
* Decide if we are looking at the designer, proof or catalogue versino
*
    FIND.ITEM = 'BUILD.STAGE'
    GOSUB FIND.SELECTION.ITEM ;* Find the entered selection criteria
    BEGIN CASE      ;* Tie to the file name
        CASE FIND.VALUE MATCHES "":@VM:"DESIGNER"
            BUILD.STAGE = "DES"
            APPL.TYPE = AA.Framework.Product
        CASE FIND.VALUE = "CATALOGUE"
            BUILD.STAGE = "CAT"
            APPL.TYPE = AA.Framework.Publish
        CASE 1
            BUILD.STAGE = "PRF"
            APPL.TYPE = AA.Framework.Proof
    END CASE
*
* Workout if we are looking for the version as at a date or a list
*
    FIND.ITEM = "EFFECTIVE.DATE"
    GOSUB FIND.SELECTION.ITEM
    IF FIND.OPERAND = '' THEN
        EFF.CHECK = "ALL"
    END ELSE
        EFF.CHECK = FIND.OPERAND
    END
    IF FIND.VALUE = '' THEN
        EFF.DATE = EB.SystemTables.getToday()
    END ELSE
        IF FIND.VALUE = "!TODAY" THEN
            FIND.VALUE = EB.SystemTables.getToday()
        END
        EFF.DATE = FIND.VALUE
    END
*
    FIND.ITEM = 'CURRENCY'
    GOSUB FIND.SELECTION.ITEM
    CCY.LIST = FIND.VALUE
*
    FIND.ITEM = "CLASS"
    GOSUB FIND.SELECTION.ITEM
    CLASS.LIST = FIND.VALUE
*
    FIND.ITEM = "PROPERTY"
    GOSUB FIND.SELECTION.ITEM
    PROPERTY.LIST = FIND.VALUE
*
    FIND.ITEM = "TARGET.PRODUCT"
    GOSUB FIND.SELECTION.ITEM
    TARGET.LIST = FIND.VALUE
*
    FIND.ITEM = "CONDITION.NAME"
    GOSUB FIND.SELECTION.ITEM
    CONDITION.NAME = FIND.VALUE
*
    RETURN
*
BUILD.LIST:
*
    IF PROPERTY.LIST THEN
        GOSUB BUILD.CLASS.LIST
    END
*
    IF CLASS.LIST = '' AND NOT(PROPERTY.LIST) THEN
        GOSUB GET.CLASS.LIST
    END
*
    LOOP
        REMOVE CLASS.ID FROM CLASS.LIST SETTING YD
    WHILE CLASS.ID
        GOSUB GET.CLASS.RECORDS
    REPEAT
*
    RETURN
*
BUILD.CLASS.LIST:
*
    LOOP
        REMOVE PROP.ID FROM PROPERTY.LIST SETTING YD
    WHILE PROP.ID
        PROP.REC = ''
        PROP.REC = AA.ProductFramework.Property.CacheRead(PROP.ID, "")
        IF PROP.REC<AA.ProductFramework.Property.PropPropertyClass> THEN
            LOCATE PROP.REC<AA.ProductFramework.Property.PropPropertyClass> IN CLASS.LIST<1,1,1> SETTING CPOS ELSE
            CLASS.LIST<1,1,CPOS> = PROP.REC<AA.ProductFramework.Property.PropPropertyClass>
        END
    END
    REPEAT
*
    RETURN
*
GET.CLASS.RECORDS:
*
** Process list of classes to get condition records for the class
*
    EB.SystemTables.setEtext('')
    FN.CLASS.COND = "F.AA.PRD.":BUILD.STAGE:".":CLASS.ID:@FM:"NO.FATAL.ERROR"
    EB.DataAccess.Opf(FN.CLASS.COND, F.CLASS.COND)
    IF NOT(EB.SystemTables.getEtext()) THEN
        *
        SEL.CMD = "SSELECT ":FN.CLASS.COND
        IF TARGET.LIST THEN
            SEL.CMD := " WITH TARGET.PRODUCT EQ ":CONVERT(@SM," ",TARGET.LIST)
        END
        IF CONDITION.NAME AND BUILD.STAGE = "DES" THEN
            IF TARGET.LIST THEN
                SEL.CMD := " AND "
            END
            SEL.CMD := " WITH @ID LIKE '":'"':CONDITION.NAME:'-"...':"'"
        END
        EB.DataAccess.Readlist(SEL.CMD, PRP.LIST, "", "", "")
        DATE.CHECK = ''       ;* Array of ccy and dates for checking latest
        LOOP
            REMOVE PRP.ID FROM PRP.LIST SETTING YD
        WHILE PRP.ID          ;* Check the dates
            ID.BITS = ''      ;* Pass back the decomposed id
            AF.Framework.PropertyDecomposeId(CLASS.ID, APPL.TYPE, PRP.ID, ID.BITS, "")
            ID.ADD = 1        ;* Assume id is alright
            GOSUB MATCH.CCY
            GOSUB MATCH.DATE
            GOSUB ADD.TO.LIST
        REPEAT
        *
        IF DATE.CHECK THEN    ;* Add dated ids to the list
            PRP.LIST = DATE.CHECK<3>
            ID.ADD = 1
            LOOP
                REMOVE PRP.ID FROM PRP.LIST SETTING YD
            WHILE PRP.ID
                GOSUB ADD.TO.LIST
            REPEAT
        END
        *
    END
*
    RETURN
*
MATCH.DATE:
*
    BEGIN CASE
        CASE ID.ADD = 0 ;* Ignore it the ccy is wrong
        CASE EFF.CHECK = "ALL"
            ID.ADD = 1
        CASE EFF.CHECK = "GE"
            IF ID.BITS<AA.Framework.IdcEffDate> < EFF.DATE THEN
                ID.ADD = 0
            END
        CASE EFF.CHECK = "GT"
            IF ID.BITS<AA.Framework.IdcEffDate> <= EFF.DATE THEN
                ID.ADD = 0
            END
        CASE EFF.CHECK = "LE"
            IF ID.BITS<AA.Framework.IdcEffDate> > EFF.DATE THEN
                ID.ADD = 0
            END
        CASE EFF.CHECK = "LT"
            IF ID.BITS<AA.Framework.IdcEffDate> >= EFF.DATE THEN
                ID.ADD = 0
            END
        CASE ID.BITS<AA.Framework.IdcEffDate> = EFF.DATE      ;* Exact match
            GOSUB UPDATE.DATE.CHECK
            ID.ADD = 0  ;* Add it later
        CASE ID.BITS<AA.Framework.IdcEffDate> > EFF.DATE      ;* No match
            ID.ADD = 0
        CASE 1          ;* Store the latest before the date
            GOSUB UPDATE.DATE.CHECK         ;* Keep a list of dated records by currency so we get the closest match
            ID.ADD = 0
    END CASE
*
    RETURN
*
MATCH.CCY:
*
    IF CCY.LIST THEN
        IF ID.BITS<AA.Framework.IdcCcy> THEN
            LOCATE ID.BITS<AA.Framework.IdcCcy> IN CCY.LIST<1,1,1> SETTING CCY.POS ELSE
            ID.ADD = 0    ;* No match
        END
    END
    END
*
    RETURN
*
GET.CLASS.LIST:
*
** Get a list of all property classes
*
    SEL.CMD = "SELECT F.AA.PROPERTY.CLASS"
    EB.DataAccess.Readlist(SEL.CMD, CLASS.LIST, "", "", "")
*
    RETURN
*
ADD.TO.LIST:
*
    IF ID.ADD THEN
        ID.LIST<-1> = FN.CLASS.COND[".",2,99]:"_":PRP.ID
    END
*
    RETURN
*
*-----------------------------------------------------------------------------

*** <region name= FIND.SELECTION.ITEM>
FIND.SELECTION.ITEM:
*** <desc>Find the entered selection criteria</desc>
    FIND.VALUE = ''
    FIND.OPERAND = ''
    LOCATE FIND.ITEM IN EB.Reports.getEnqSelection()<2,1> SETTING EPOS THEN
    FIND.OPERAND = EB.Reports.getEnqSelection()<3,EPOS>
    FIND.VALUE = EB.Reports.getEnqSelection()<4,EPOS>
    CONVERT " " TO @SM IN FIND.VALUE
    END

    RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= UPDATE.DATE.CHECK>
UPDATE.DATE.CHECK:
*** <desc>Keep a list of dated records by currency so we get the closest match</desc>
    CHECK.ID = ID.BITS<AA.Framework.IdcCondNo>:"-":ID.BITS<AA.Framework.IdcCcy>
    LOCATE CHECK.ID IN DATE.CHECK<1,1> SETTING DPOS ELSE
    DATE.CHECK<1,DPOS> = CHECK.ID
    END
    IF DATE.CHECK<2,DPOS> LT ID.BITS<AA.Framework.IdcEffDate> THEN
        DATE.CHECK<2,DPOS> = ID.BITS<AA.Framework.IdcEffDate>
        DATE.CHECK<3,DPOS> = PRP.ID
    END
    RETURN
*** </region>
    END
