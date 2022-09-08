* @ValidationCode : MjotMzIxNTU4MTU3OkNwMTI1MjoxNjE0MzM5NjY2MzEwOnNpbmRodXM6MjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMS4yMDIwMTIyNi0wNjE4OjY5OjQy
* @ValidationInfo : Timestamp         : 26 Feb 2021 17:11:06
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sindhus
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 42/69 (60.8%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202101.20201226-0618
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-38</Rating>
*-----------------------------------------------------------------------------
$PACKAGE LC.ModelBank

SUBROUTINE E.LC.OPEN
*
* Enquiry subroutine to return opening amount of an LC.
*
* 30/04/96 - GB9600539
*            Should use F.READ, not F.READU
* 07/02/13 - Defect 498863 / Task 583569
*            Since new fields are introduced in LC,positions are modified
*            to display the LC details in enquiry.
*
* 04/02/14 - Defect 854321 / Task 905572
*            While calculation LC amount for live and history record of LC
*            system does not consider tolerance and add covered amount.
*
* 30/07/14 - Task - 1050502
*            Description for Pre-Advised LCs should be 'Pre-Advice'.
*            Defect - 1069229
*
* 09/09/14 - Task - 1108733
*            Common variable R.NEW while used as a Dimensioned array
*            has to be declared with a standard array size - C$SYSDIM
*            defined in I_COMMON.
*            Defect - 1108576
*
* 09/12/14 - Task : 1116645 / Enhancement : 990544
*            LC Componentization and Incorporation.
*
* 12/02/21 - Task : 4227018
*            LC.SUMMARY display for upgraded contracts
*            Ref : 4208913
************************************************************************
*

    $USING EB.Reports
    $USING LC.ModelBank
    $USING LC.Contract
    $USING EB.SystemTables
*
************************************************************************
*

    LC.NUM = EB.Reports.getId()
    HIST.ID = EB.Reports.getId():";1"
    LC.OPERATION = ''
    CURR.NO = EB.Reports.getRRecord()<LC.Contract.LetterOfCredit.TfLcCurrNo>
    IF CURR.NO EQ 1 THEN
        tmp=EB.Reports.getRRecord()
        tmp<407>=""
        EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord()
        tmp<408>=EB.Reports.getRRecord()<LC.Contract.LetterOfCredit.TfLcLcCurrency>
        EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord()
        tmp<401>=EB.Reports.getRRecord()<LC.Contract.LetterOfCredit.TfLcIssueDate>
        EB.Reports.setRRecord(tmp)
        LC.RECORD = EB.Reports.getRRecord()
        GOSUB POPULATE.LC.AMOUNT
        tmp=EB.Reports.getRRecord()
        tmp<402>=EB.Reports.getRRecord()<LC.Contract.LetterOfCredit.TfLcLiabilityAmt>
        EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord()
        tmp<410>=LC.NUM
        EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord()
        tmp<411>= '1' ;*Set Curr No in new position
        EB.Reports.setRRecord(tmp)
    END ELSE
        HIST.REC = ''
        LC.Contract.LetterOfCreditHis(HIST.ID, HIST.REC, IO.ERR)
        tmp=EB.Reports.getRRecord()
        tmp<407>=""
        EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord()
        tmp<408>=HIST.REC<LC.Contract.LetterOfCredit.TfLcLcCurrency>
        EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord()
        tmp<401>=HIST.REC<LC.Contract.LetterOfCredit.TfLcIssueDate>
        EB.Reports.setRRecord(tmp)
        LC.RECORD = HIST.REC
        GOSUB POPULATE.LC.AMOUNT
        tmp=EB.Reports.getRRecord()
        M1 = HIST.REC<LC.Contract.LetterOfCredit.TfLcLiabilityAmt>
        tmp<402>=HIST.REC<LC.Contract.LetterOfCredit.TfLcLiabilityAmt>
        EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord()
        tmp<410>=HIST.ID
        EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord()
        tmp<411>= '1'  ;*Set Curr No in new position
        EB.Reports.setRRecord(tmp)
    END

    LC.OPERATION = EB.Reports.getRRecord()<LC.Contract.LetterOfCredit.TfLcOperation>      ;* Operation in LC record
    IF LC.OPERATION EQ "P" THEN         ;* LC being a Pre-Advised LC.
        tmp=EB.Reports.getRRecord()
        tmp<400>="Pre-Advice"
        EB.Reports.setRRecord(tmp)      ;* Description to be 'Pre-Advice'
    END ELSE
        tmp=EB.Reports.getRRecord()
        tmp<400>="Opening"
        EB.Reports.setRRecord(tmp)      ;* Description to be 'Opening'
    END
*
RETURN

*** <region name= POPULATE.LC.AMOUNT>
*** <desc> </desc>
*******************
POPULATE.LC.AMOUNT:
*******************

    EB.SystemTables.setDynArrayToRNew(LC.RECORD)    ;*R.NEW needs to get populated to get value from LC.CALC.AMOUNT routine
    GET.LC.AMT = LC.RECORD<LC.Contract.LetterOfCredit.TfLcLcAmount>
    LC.Contract.CalcAmount(GET.LC.AMT)     ;*To include the tolerance amount
    GET.LC.AMT = GET.LC.AMT + SUM(LC.RECORD<LC.Contract.LetterOfCredit.TfLcAddCoveredAmt>)   ;*Add Add Covered amount also.
    tmp=EB.Reports.getRRecord()
    tmp<403>=GET.LC.AMT
    EB.Reports.setRRecord(tmp)
RETURN
*** </region>

END
