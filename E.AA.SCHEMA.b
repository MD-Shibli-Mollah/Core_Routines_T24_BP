* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-3</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.SCHEMA(IDS)
*
** Routine to build the accounting schema for an enquiry
** Will use a nofile enquiry on the product

    $USING AA.Accounting
    $USING EB.Reports

*
    COMMON/AASCHEMA/SCHEMA.LIST
*
    LOCATE "PRODUCT" IN EB.Reports.getEnqSelection()<2,1> SETTING POS THEN
    PRODUCT = EB.Reports.getEnqSelection()<4,POS>
    END ELSE
    PRODUCT = ''
    END
*
    LOCATE "ACTIVITY"IN EB.Reports.getEnqSelection()<2,1> SETTING POS THEN
    ACTIVITY = EB.Reports.getEnqSelection()<4,POS>
    END ELSE
    ACTIVITY = ''
    END
*
    LOCATE "STAGE" IN EB.Reports.getEnqSelection()<2,1> SETTING POS THEN
    STAGE = EB.Reports.getEnqSelection()<4,POS>
    END ELSE
    STAGE = ""
    END
*
    LOCATE "EFFECTIVE.DATE" IN EB.Reports.getEnqSelection()<2,1> SETTING POS THEN
    EFFECTIVE.DATE = EB.Reports.getEnqSelection()<4,POS>
    END ELSE
    EFFECTIVE.DATE = ''
    END
*
    LOCATE "CURRENCY" IN EB.Reports.getEnqSelection()<2,1> SETTING POS THEN
    CURRENCY = EB.Reports.getEnqSelection()<4,POS>
    END ELSE
    CURRENCY = ''
    END
*
    SCHEMA.LIST = ''
    ERR.MSG = ''
    AA.Accounting.BuildAccountingSchema(PRODUCT, ACTIVITY, STAGE, EFFECTIVE.DATE, CURRENCY, SCHEMA.LIST, ERR.MSG)
*
    IDX = ''
    LOOP
        IDX +=1
    WHILE SCHEMA.LIST<IDX>
        IDS<-1> = IDX ;* Pass back something
    REPEAT
*
    RETURN
*
    END
