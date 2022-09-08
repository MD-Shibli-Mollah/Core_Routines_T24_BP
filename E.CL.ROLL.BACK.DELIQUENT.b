* @ValidationCode : Mjo5NDUwNzI4OTg6Q3AxMjUyOjE1ODY0MzM2ODgzMTk6cGF2aXRocmFzcmk6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMi4yMDIwMDExNy0yMDI2Ojk0OjY5
* @ValidationInfo : Timestamp         : 09 Apr 2020 17:31:28
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : pavithrasri
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 69/94 (73.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>126</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CL.ModelReport
SUBROUTINE E.CL.ROLL.BACK.DELIQUENT(VALUES.LIST)
*------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*** <doc>
* Routine Type : NO-FILE routine
*  This routine used to find out forwared Total No of ovedue's and oustanding Amounts.
* @author johnson@temenos.com
* @stereotype template
* @uses ENQUIRY>CL.ROLL.FWD.DELI.REP
* @uses
* @package retaillending.CL
*
*** </doc>
*** </region>
*** <region name= Modification History>
*** <desc>Changes done in the sub-routine</desc>

* Modification History :
*-----------------------
* 11/04/14 -  ENHANCEMENT - 908020 /Task - 988392
*          -  Loan Collection Process
*
* 06/04/20 - Defect:3626482 / Task:3678993
*            Zero value in percentage tag while executing this enquiry CL.ROLL.BACK.DELIQUENT.
*
*** </region>

*** <region name= Arguments>
*** <desc>Input and output arguments required for the sub-routine</desc>
* Arguments
*
* Input :
*
*
*
*
* Output
*
* VALUES.LIST = It return final result
*
*** </region>

*** <region name= INSERTS>
*** <desc>File inserts and common variables used in the sub-routine</desc>

    $USING CL.Contract
    $USING EB.Reports
    $USING EB.SystemTables
    $USING EB.API
    $USING EB.DataAccess

*** </region>

*** <region name= MAIN PROCESS>
*** <desc>Main control logic in the sub-routine</desc>
   
    GOSUB INITIALISE
    GOSUB PROCESSFILES

RETURN
*** </region>


*** <region name= INITIALISE>
*** <desc>Initialise local variables and file variables</desc>
*------------------------------------------------------------------------

INITIALISE:
***********

* Initialise all the required variables.

    TOTAL.BUCKET.BUFF = ''
    DIM TOTAL.BUCKET.BUFF(200)
    VALUES.LIST = ''
    FINAL.LIST = ''
    NEW.FORM = ''
    FN.CL.ITEM.BUCKET="F.CL.ITEM.BUCKET"
    F.CL.ITEM.BUCKET=""
    ENQ.SEL.POS = ''
    R.SORTLIST = ''
    LOCATE 'START.DATE' IN EB.Reports.getEnqSelection()<2,1> SETTING ENQ.SEL.POS THEN
        FROM.DATE = EB.Reports.getEnqSelection()<4,ENQ.SEL.POS>
    END ELSE
        YCUR.DAY = EB.SystemTables.getToday()[7,2]
        YCUR.MONTH = EB.SystemTables.getToday()[5,2]
        YCUR.YEAR = EB.SystemTables.getToday()[1,4]
        IF YCUR.MONTH = 1 THEN
            YCUR.MONTH = 12
            YCUR.YEAR -= 1
        END ELSE
            YCUR.MONTH -= 1
            YCUR.MONTH = FMT(YCUR.MONTH,"2'0'R")
        END

        FROM.DATE = YCUR.YEAR:YCUR.MONTH:YCUR.DAY
        EB.API.Cdt("",FROM.DATE,"+1C")
        tmp=EB.Reports.getEnqSelection(); tmp<2,-1>='START.DATE'; EB.Reports.setEnqSelection(tmp)
        tmp=EB.Reports.getEnqSelection(); tmp<3,-1>='EQ'; EB.Reports.setEnqSelection(tmp)
        tmp=EB.Reports.getEnqSelection(); tmp<4,-1>=FROM.DATE; EB.Reports.setEnqSelection(tmp)
    END

    EB.DataAccess.Opf(FN.CL.ITEM.BUCKET,F.CL.ITEM.BUCKET)

RETURN

*** </region>

*** <region name= PROCESS FILES>
*** <desc>Main Process to form the Array and return to Enquiry</desc>

PROCESSFILES:
*************

* Select all the Item Bucket files.

    CMD.SELECT = "SELECT ":FN.CL.ITEM.BUCKET
    EB.DataAccess.Readlist(CMD.SELECT,SEL.LIST,"",SEL.CNT,SEL.ERR)
    LOOP
        REMOVE CL.ITEM FROM SEL.LIST SETTING Y.POS
    WHILE CL.ITEM:Y.POS
        R.CL.ITEM.BUCKET = CL.Contract.ItemBucket.Read(CL.ITEM, ERR.CL.ITEM)
        TOT.CNT.BUC.DATE = DCOUNT(R.CL.ITEM.BUCKET<CL.Contract.ItemBucket.BkBucketDate>,@VM)
        LOCATE FROM.DATE IN R.CL.ITEM.BUCKET<CL.Contract.ItemBucket.BkBucketDate,1> BY "AL" SETTING BUC.DATE.POS THEN
            IF BUC.DATE.POS EQ TOT.CNT.BUC.DATE THEN
                IF BUC.DATE.POS GT '1' THEN
                    PREVIOUS.BUCKET = R.CL.ITEM.BUCKET<CL.Contract.ItemBucket.BkBucket,BUC.DATE.POS-1>
                END ELSE
                    PREVIOUS.BUCKET = '0'
                END
                CURRENT.BUCKET = R.CL.ITEM.BUCKET<CL.Contract.ItemBucket.BkBucket,TOT.CNT.BUC.DATE>
                IF CURRENT.BUCKET AND CURRENT.BUCKET LT PREVIOUS.BUCKET THEN
                    GOSUB TOTAL
                    GOSUB CHECK.BUCKET.SLIP
                END
                IF NOT(CURRENT.BUCKET) THEN
                    CURRENT.BUCKET = 'SLIPPAGE'
                    GOSUB TOTAL
                    GOSUB CHECK.BUCKET.SLIP
                END
            END
        END

    REPEAT

  
    TOT.CNT.SORT.LIST = DCOUNT(R.SORTLIST,@FM)
    FOR INIT.SORT.ID = 1 TO TOT.CNT.SORT.LIST
        CURRENT.BUCKET = FIELD(R.SORTLIST<INIT.SORT.ID>,'*',1)
        IF CURRENT.BUCKET NE 'SLIPPAGE' THEN
            PERCENTAGE = VALUES.LIST<INIT.SORT.ID,3> * 100 / TOTAL.BUCKET.BUFF(CURRENT.BUCKET)
        END ELSE
            PERCENTAGE = VALUES.LIST<INIT.SORT.ID,3> * 100 / TOT.SLIPPAGE
        END
        VALUES.LIST<INIT.SORT.ID,4> = PERCENTAGE


    NEXT INIT.SORT.ID

    CHANGE @VM TO '*' IN VALUES.LIST
RETURN

*** </region>

*** <region name= TOTAL>
*** <desc>Add the Total Ovedue Amount & Total Oustanding Amount in the sort List</desc>

TOTAL:
******

    
    SORT.ID = CURRENT.BUCKET:'*':PREVIOUS.BUCKET
    LOCATE SORT.ID IN R.SORTLIST BY "AL" SETTING SORT.ID.POS THEN
        VALUES.LIST<SORT.ID.POS,2> += 1
        VALUES.LIST<SORT.ID.POS,3> += R.CL.ITEM.BUCKET<CL.Contract.ItemBucket.BkCurOverdueAmt>
        VALUES.LIST<SORT.ID.POS,3> += R.CL.ITEM.BUCKET<CL.Contract.ItemBucket.BkCurOutsAmt>
    END ELSE
        INS SORT.ID BEFORE R.SORTLIST<SORT.ID.POS>
        NEW.FORM<1,1> = SORT.ID
        NEW.FORM<1,2> = 1
        NEW.FORM<1,3> = R.CL.ITEM.BUCKET<CL.Contract.ItemBucket.BkCurOverdueAmt> + R.CL.ITEM.BUCKET<CL.Contract.ItemBucket.BkCurOutsAmt>
        NEW.FORM<1,4> = 0
        INS NEW.FORM BEFORE VALUES.LIST<SORT.ID.POS>
    END

RETURN


*** </region>

*** <region name= BUCKET SLIP>
*** <desc>Here we calcualte the Slipage Oustanding & Overdue Amounts</desc>

CHECK.BUCKET.SLIP:
******************

* Find out the Slipage and Non - slipage Total bucket overdue Amount and Outstanding Amount.

    IF CURRENT.BUCKET NE 'SLIPPAGE' THEN
        TOTAL.BUCKET.BUFF(CURRENT.BUCKET) += R.CL.ITEM.BUCKET<CL.Contract.ItemBucket.BkCurOverdueAmt>
        TOTAL.BUCKET.BUFF(CURRENT.BUCKET) += R.CL.ITEM.BUCKET<CL.Contract.ItemBucket.BkCurOutsAmt>
    END ELSE
        TOT.SLIPPAGE += R.CL.ITEM.BUCKET<CL.Contract.ItemBucket.BkCurOverdueAmt>
        TOT.SLIPPAGE += R.CL.ITEM.BUCKET<CL.Contract.ItemBucket.BkCurOutsAmt>
    END


RETURN

*** </region>
*------------------------------------------------------------------------
END
