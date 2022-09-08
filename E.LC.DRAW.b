* @ValidationCode : MjoyMDM2Mzg1MjI4OkNwMTI1MjoxNjE0MzM5NjU2NTk5OnNpbmRodXM6NDowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMS4yMDIwMTIyNi0wNjE4OjI3MToxOTM=
* @ValidationInfo : Timestamp         : 26 Feb 2021 17:10:56
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sindhus
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 193/271 (71.2%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202101.20201226-0618
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 5 06/06/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>-119</Rating>
*
$PACKAGE LC.ModelBank

SUBROUTINE E.LC.DRAW
*
***********************************************************************
* Subroutine to return drawing information under a particular LC
***********************************************************************
*
* 30/04/96 - GB9600539
*            Should use F.READ, not F.READU
*
* 23/03/06 - CI_10039964
*            If Draw type is CR, then the Display of this Drawing details is stopped.
*            FR should also be stooped along with CR type.
*
*
* 23/02/07 - BG_100013043
*            CODE.REVIEW changes.
*
* 02/12/09 - CI_10067980
*            The R.Bal column in LC.SUMMARY is updated wrongly for Cumulative LC.
*            REF : HD0943686
*
* 12/06/12 - Defect 414047 / Task 420961
*            Drawing details for CR and FR contracts should get displayed.For
*            Draw type FR,there not be any impact in the previous outstanding amount.
* 07/02/13 - Defect 498863 / Task 583569
*            Since new fields are introduced in LC,positions are modified
*            to display the LC details in enquiry.
*
* 29/11/13 - Task - 851208
*     Outstanding Balance of a drawing has to be zero if it fully utilises the LC amount
*       Def : 845715
*
* 04/02/14 - Defect 854321 / Task 905572
*            Position is set wrongly while populating drawings value.
*
* 03/09/14 - Task - 1104132
*            Outstanding amount should be zero if LC is fully utilised.
*            Defect - 1092770
*
* 09/12/14 - Task : 1116645 / Enhancement : 990544
*            LC Componentization and Incorporation
*
* 06/08/15 - Task : 1430031
*            VM is not changed to @VM.
*            Enhancement : 1219719
*
* 20/03/17 - Task - 1993959
*           Outstanding amount should be updated correctly while increasing LC amount
*           Ref : 1982386
*
* 28/03/17 - Task - 2069075
*           Variable I to be modified as NO.OF.DRAW
*           Ref : 2068898
*
* 25/5/18 - Task - 2604609
*           Outstanding balance in LC.SUMMARY output� shows wrong balance.
*           Ref : 2600101
*
* 11/06/18 - Task : 2622266
*			Enquiry LC.SUMMARY shows wrong outstanding amount
*			Ref: 2620035
*
* 13/07/18 - Task : 2674340
*            Wrong outstanding balance is getting displayed for amendment of fully utilized LC.
*            Defect : 2671429
*
* 12/02/21 - Task : 4227018
*            LC.SUMMARY display for upgraded contracts
*            Ref : 4208913
***********************************************************************
    $USING EB.Reports
    $USING LC.ModelBank
    $USING LC.Contract

*
***********************************************************************
*
    COUNT.NO.OF.LC = ''
    COUNT.NO.OF.DR = ''
    SELL.AMOUNT = ''
    DRAW.AMOUNT.DISPLAY = ''
    DRAW.AMOUNT = ''
    O.FULL.UTIL = ''
    CURR.NO = ''
    HIST.REC = ''
    HIST.REC.ERR = ''
    LC.FULLY.UTIL = ''
    LC.LIAB.AMT = ''
    HIST.REC = ''
    LC.NUM = EB.Reports.getId()
    DRWG.NO = EB.Reports.getRRecord()<LC.Contract.LetterOfCredit.TfLcNextDrawing>
    O.DATE = EB.Reports.getRRecord()<401>
    O.CCY = EB.Reports.getRRecord()<408>
    O.TYPE = EB.Reports.getRRecord()<407>
    O.AMOUNT = EB.Reports.getRRecord()<403>
    O.DIFF = EB.Reports.getRRecord()<407>
    O.DESC = EB.Reports.getRRecord()<400>
    O.TXNREF = EB.Reports.getRRecord()<410>
    O.CURR.NO = EB.Reports.getRRecord()<411>
    NO.OF.DRAW = ''
    FOR NO.OF.DRAW = 1 TO (DRWG.NO - 1)
        IF NO.OF.DRAW < 10 THEN
            CONC = '0':NO.OF.DRAW
        END ELSE
            CONC = NO.OF.DRAW
        END

        DRAW.ID = LC.NUM:CONC
        DRAW.REC = ''
        IO.ERR = ''

        DRAW.REC = LC.Contract.tableDrawings(DRAW.ID,  IO.ERR)
        IF NOT(IO.ERR) THEN
            GOSUB MAIN.PROCESS          ;* BG_100013043 - S / E
        END
    NEXT NO.OF.DRAW

    GOSUB ASSIGN.FINAL.VALUES
    IF EB.Reports.getRRecord()<167> EQ 'CM' THEN
        GOSUB DATA.FOR.CUMMULATIVE.LC   ;*Collecting the data for displaying the cummulative type of lc.
    END ELSE
        GOSUB CALC.OUTS.BAL   ;*Find Amount and Outstanding balance
        NO.OF.LINES = DCOUNT(O.AMOUNT, @VM)
        FOR IDX = 1 TO NO.OF.LINES
            IF O.AMOUNT<1,IDX> EQ 0 THEN
                DEL O.AMOUNT<1,IDX>
                DEL O.DESC<1,IDX>
                DEL O.DIFF<1,IDX>
                DEL O.CCY<1,IDX>
                DEL O.DATE<1,IDX>
                DEL O.TYPE<1,IDX>
                DEL O.RBAL<1,IDX>
                DEL O.TXNREF<1,IDX>
                DEL O.CURR.NO<1,IDX>
            END
        NEXT IDX
        GOSUB ASSIGN.FINAL.VALUES
        tmp=EB.Reports.getRRecord()
        tmp<402>=O.RBAL
        EB.Reports.setRRecord(tmp)
    END
  
RETURN
*************************************************************************************************************
************************
DATA.FOR.CUMMULATIVE.LC:
************************
    NO.OF.CUMM = ''
    FOR NO.OF.CUMM = 1 TO (DRWG.NO - 1)
        IF NO.OF.CUMM < 10 THEN
            CONC = '0':NO.OF.CUMM       ;*Forming the drawing record ID.
        END ELSE
            CONC = NO.OF.CUMM
        END
        DRAW.ID = LC.NUM:CONC
        DRAW.REC = ''
        IO.ERR = ''
        DRAW.REC = LC.Contract.tableDrawings(DRAW.ID,  IO.ERR)
        IF NOT(IO.ERR) THEN
            GOSUB CHECK.FOR.CUMMULATIVE.LC        ;*Finding out the drawing  belongs to which frequency and collecing the amount.
        END
    NEXT NO.OF.CUMM
    COUNT.NO.OF.LC = DCOUNT(DRAW.AMOUNT,@FM)
    FOR LC.IDX = 1 TO COUNT.NO.OF.LC
        COUNT.NO.OF.DR = DCOUNT(DRAW.AMOUNT<LC.IDX>,@VM)
        SELL.AMOUNT = EB.Reports.getRRecord()<21> + EB.Reports.getRRecord()<77,LC.IDX>    ;*adding the lc amount with the forward amount from the previous freq.
        FOR DRAW.IDX = 1 TO COUNT.NO.OF.DR
            SELL.AMOUNT =  SELL.AMOUNT - DRAW.AMOUNT<LC.IDX,DRAW.IDX> ;*finding the balance amount for the current frequency
            DRAW.AMOUNT.DISPLAY<-1> = SELL.AMOUNT
        NEXT DRAW.IDX
    NEXT LC.IDX
    O.RBAL = EB.Reports.getRRecord()<21>:@FM:DRAW.AMOUNT.DISPLAY
    CONVERT @FM TO @VM IN O.RBAL
    tmp=EB.Reports.getRRecord()
    tmp<409>=O.RBAL
    EB.Reports.setRRecord(tmp)
RETURN

*************************
CHECK.FOR.CUMMULATIVE.LC:
*************************
    DR.SET = DCOUNT(EB.Reports.getRRecord()<63>,@VM)
    FOR DRAW.IDX = 1 TO DR.SET
        IF DRAW.REC<LC.Contract.Drawings.TfDrAcptTmBand> EQ EB.Reports.getRRecord()<66,DRAW.IDX> THEN ;*Drawing ACTP.TM.BAND is checked with the lc draw set  ACPT.TM.BAND for find the drawing belongs to which freq.
            DRAW.AMOUNT<DRAW.IDX,-1> = DRAW.REC<LC.Contract.Drawings.TfDrDocAmtLcCcy>
        END
    NEXT DRAW.IDX
RETURN
*****************************************************************************************************************
* BG_100013043 - S
*============
MAIN.PROCESS:
*============
    IF O.DATE EQ '' THEN
        O.DATE = DRAW.REC<LC.Contract.Drawings.TfDrValueDate>
        O.TYPE = DRAW.REC<LC.Contract.Drawings.TfDrDrawingType>
        O.CCY = EB.Reports.getRRecord()<LC.Contract.LetterOfCredit.TfLcLcCurrency>
        O.AMOUNT = DRAW.REC<LC.Contract.Drawings.TfDrDocAmtLcCcy> * -1
        O.DESC = 'NEGTOTN'
        O.DIFF = CONC
        O.FULL.UTIL = DRAW.REC<LC.Contract.Drawings.TfDrFullyUtilised>        ;* the current drawing fully utilises LC amount or not
    END ELSE
        GOSUB BUILD.O.REC
    END
RETURN
*************************************************************************************************************
*============
BUILD.O.REC:
*============
    IF DRAW.REC<LC.Contract.Drawings.TfDrMaturityReview> NE '' THEN
        CORRECT.DATE = DRAW.REC<LC.Contract.Drawings.TfDrMaturityReview>
    END ELSE
        CORRECT.DATE = DRAW.REC<LC.Contract.Drawings.TfDrValueDate>
    END
    LOCATE CORRECT.DATE IN O.DATE<1,1> BY 'AR' SETTING POS THEN
        POS = DCOUNT(O.AMOUNT,@VM)       ;*Count the positions and then insert drawings values in R.RECORD
        POS = POS + 1
    END ELSE
        V$ERROR = ""
    END
    IF POS THEN
        INS CORRECT.DATE BEFORE O.DATE<1,POS>
        INS DRAW.REC<LC.Contract.Drawings.TfDrDrawingType> BEFORE O.TYPE<1,POS>
        INS EB.Reports.getRRecord()<LC.Contract.LetterOfCredit.TfLcLcCurrency> BEFORE O.CCY<1,POS>
        IF EB.Reports.getRRecord()<167> EQ 'CM' THEN
            INS (DRAW.REC<LC.Contract.Drawings.TfDrDocAmtLcCcy> * -1) BEFORE O.AMOUNT<1,-1>     ;*TO append the drawing amount in the array to display.
        END ELSE
            INS (DRAW.REC<LC.Contract.Drawings.TfDrDocAmtLcCcy> * -1) BEFORE O.AMOUNT<1,POS>
        END
        DRAW.TYPE = DRAW.REC<LC.Contract.Drawings.TfDrDrawingType>
        GOSUB GET.DRAW.TYPE.DESC
        INS DR.DESC BEFORE O.DESC<1,POS>
        IF EB.Reports.getRRecord()<167> EQ 'CM' THEN
            O.DIFF<1,1> = 00
            INS CONC BEFORE O.DIFF<1,-1>          ;*TO append the darwing number to dispaly
        END ELSE
            INS CONC BEFORE O.DIFF<1,POS>
        END
        INS DRAW.ID BEFORE O.TXNREF<1,POS>
        INS DRAW.REC<LC.Contract.Drawings.TfDrFullyUtilised> BEFORE O.FULL.UTIL<1,POS>  ;*append the fully utilised field values of all the drawings
    END
RETURN          ;* BG_100013043 - E
*************************************************************************************************************
*** <region name= CALC.OUTS.BAL>
*==============*
CALC.OUTS.BAL:
*==============*
*** <desc>Find Amount and Outstanding balance </desc>
    FLAG1 = 0
    X = 2
    COUNT.FULL.UTIL = 0
    FOR NO.OF.DRAW = 1 TO EB.Reports.getVmCount()     ;* For all the drawings under the current LC
        DR.TYPE = FIELD(O.TYPE,@VM,NO.OF.DRAW)
        FULL.UTIL = FIELD(O.FULL.UTIL,@VM,NO.OF.DRAW)
        CURR.NO = EB.Reports.getRRecord()<LC.Contract.LetterOfCredit.TfLcCurrNo>
        IF NOT(DR.TYPE) AND CURR.NO > 1 AND (NOT(O.DESC<1,NO.OF.DRAW> EQ 'Amend' AND LC.FULLY.UTIL EQ 'Y')) THEN   ;*Only for LC's system should read history records of LC
            IF O.DESC<1,NO.OF.DRAW> MATCHES 'Opening':@VM:'Amend':@VM:'Pre-Advice' THEN ;*For Opening and Amendment of LC
                HIST.ID = LC.NUM:";":O.CURR.NO<1,NO.OF.DRAW> ;*Form history record id using curr no
            END ELSE
                HIST.ID = LC.NUM : ";" : NO.OF.DRAW
            END
            LC.Contract.LetterOfCreditHis(HIST.ID, HIST.REC, HIS.REC.ERR)
            IF NOT(HIST.REC) THEN       ;*Get LC fully utilised and liability amount values from history or current LC record
                LC.FULLY.UTIL = EB.Reports.getRRecord()<LC.Contract.LetterOfCredit.TfLcFullyUtilised>
                LC.LIAB.AMT = EB.Reports.getRRecord()<LC.Contract.LetterOfCredit.TfLcLiabilityAmt>
            END ELSE
                LC.FULLY.UTIL = HIST.REC<LC.Contract.LetterOfCredit.TfLcFullyUtilised>
                LC.LIAB.AMT = HIST.REC<LC.Contract.LetterOfCredit.TfLcLiabilityAmt>
            END
        END
        IF NOT(DR.TYPE MATCHES 'CO':@VM:'CR':@VM:'DC':@VM:'FR':@VM:'RD') THEN         ;* Not in case of FR,RD,DC,CR,CO
            GOSUB CALCULATE.AMOUNT
            IF AMOUNT LT 0 AND AMOUNT THEN
                AMOUNT = 0
            END
            IF NO.OF.DRAW EQ 1 THEN
                O.RBAL = AMOUNT         ;* Outstanding balance of the first drawing under the current LC
            END ELSE
                O.RBAL = O.RBAL:@VM:AMOUNT         ;* Outstanding balance of successive drawings
            END
        END ELSE
            O.RBAL = O.RBAL:@VM:AMOUNT
        END
    NEXT NO.OF.DRAW

RETURN
*************************************************************************************************************
*** <region name= CALCUALTE.AMOUNT>
*==============*
CALCULATE.AMOUNT:
*==============*
*** <desc>Calculates the amount based on fully utilised value in LC and Drawings </desc>
    BEGIN CASE
        CASE DR.TYPE AND FULL.UTIL EQ 'Y'          ;*For drawings fully utilised value, this case gets executed
            AMOUNT = 0
            COUNT.FULL.UTIL = COUNT.FULL.UTIL+1
            IF DR.TYPE AND NOT(FLAG1) THEN
                REINST.AMT<1,-1> = O.RBAL<1,NO.OF.DRAW-1>
                FLAG1 = 1
            END
            
        CASE O.DESC<1,NO.OF.DRAW> EQ 'Amend' AND LC.FULLY.UTIL EQ 'Y' AND LC.LIAB.AMT EQ 0    ;*For LC fully utilised this case gets executed
            AMOUNT = 0  ;*Outstanding balance is zero
            LC.FULLY.UTIL = ''
            IF AMOUNT EQ 0 AND O.DESC<1,NO.OF.DRAW> EQ 'Amend' THEN
                IF O.RBAL<1,NO.OF.DRAW-1> EQ 0 AND EB.Reports.getRRecord()<402,NO.OF.DRAW> GT 0 THEN
                    REINST.AMT<1,-1> = EB.Reports.getRRecord()<402,NO.OF.DRAW>
                END ELSE
                    REINST.AMT<1,-1> = O.RBAL<1,NO.OF.DRAW-1>
                END
            END
            IF NOT(O.TYPE<1,NO.OF.DRAW+1> MATCHES '-':@VM:'') AND O.RBAL<1,NO.OF.DRAW-1> THEN
                tmp = EB.Reports.getRRecord()
                tmp<402,NO.OF.DRAW> = (O.RBAL<1,NO.OF.DRAW-1> - EB.Reports.getRRecord()<LC.Contract.LetterOfCredit.TfLcDrawings> ) * (-1)
                EB.Reports.setRRecord(tmp)
            END
        
        CASE 1
            IF DR.TYPE AND NOT(FLAG1) THEN
                REINST.AMT<1,-1> = O.RBAL<1,NO.OF.DRAW-1>
                FLAG1 = 1
                AMOUNT = REINST.AMT<1,1>
            END
            IF AMOUNT EQ 0 AND NOT(O.DESC<1,NO.OF.DRAW> MATCHES 'Amend':@VM:'Opening') THEN
                AMOUNT = REINST.AMT<1,X>
                X = X+1
            END
            AMOUNT = EB.Reports.getRRecord()<403,NO.OF.DRAW> + AMOUNT          ;* Outstanding balance of successive drawings is calculated from the previous drawing's balance
           
    END CASE
    
RETURN

*** </region>
*************************************************************************************************************
*** <region name= GET.DRAW.TYPE.DESC>
*** <desc>Decide draw type description</desc>

GET.DRAW.TYPE.DESC:

    BEGIN CASE
        CASE DRAW.TYPE EQ 'SP' ;*Sight Payment
            DR.DESC = "Sight Payment"
        CASE DRAW.TYPE EQ 'AC' ;*Acceptance Drawings
            DR.DESC = "Acceptance of Documents"
        CASE DRAW.TYPE EQ 'DP' ;*Deffered Payment
            DR.DESC = "Deferred Payments"
        CASE DRAW.TYPE EQ 'DC' ;* Document checking
            DR.DESC = "Document Checking"
        CASE DRAW.TYPE EQ 'MA' ;*Maturity of acceptance Drawings
            DR.DESC = "Matured Acceptance"
        CASE DRAW.TYPE EQ 'MD' ;*Maturity of Deffered drawings
            DR.DESC = "Matured Deferred Payments"
        CASE DRAW.TYPE EQ 'CR' ;* collection rejection
            DR.DESC = "Docs Rejection"
        CASE DRAW.TYPE EQ 'REIM' ;* For Reimbursement LC's the Description must be set as Claim Settled
            DR.DESC = "Claim Settled"
        CASE DRAW.TYPE EQ 'FR' ;* final rejection
            DR.DESC = "Final Rejection"
        CASE DRAW.TYPE EQ 'MX' ;*Mixed Payemnt
            DR.DESC = "Mixed Payment"
        CASE DRAW.TYPE EQ 'CO' ;* ;* L/C Collection is also to be considered for Summary
            DR.DESC = "L/C Collection"
        CASE DRAW.TYPE EQ 'RD' ;* Registration of documents
            DR.DESC = "Registration of Documents"
    END CASE
    
RETURN
**** </region>
**------------------------------------------------------------------------------------
*** <region name= ASSIGN.FINAL.VALUES>
*** <desc> </desc>
ASSIGN.FINAL.VALUES:
    
    EB.Reports.setVmCount(DCOUNT(O.AMOUNT, @VM))
    AMOUNT = ''
    tmp=EB.Reports.getRRecord()
    tmp<401>=O.DATE
    EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord()
    tmp<407>=O.TYPE
    EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord()
    tmp<408>=O.CCY
    EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord()
    tmp<403>=O.AMOUNT
    EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord()
    tmp<400>=O.DESC
    EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord()
    tmp<410>=O.TXNREF
    EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord()
    tmp<407>=O.DIFF
    EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord()
    tmp<411>= O.CURR.NO ;*Store CURR.NO
    EB.Reports.setRRecord(tmp)
    
RETURN
**** </region>
**------------------------------------------------------------------------------------
END
