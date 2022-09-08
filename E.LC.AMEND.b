* @ValidationCode : MjotMjk2OTM0MDM5OkNwMTI1MjoxNjE0MzM5NjU2NTUyOnNpbmRodXM6NjowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjEwMS4yMDIwMTIyNi0wNjE4OjE5NzoxNTI=
* @ValidationInfo : Timestamp         : 26 Feb 2021 17:10:56
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sindhus
* @ValidationInfo : Nb tests success  : 6
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 152/197 (77.1%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202101.20201226-0618
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* <Rating>208</Rating>
$PACKAGE LC.ModelBank

SUBROUTINE E.LC.AMEND
*
* Subroutine to return changes in amount due to amendments.
*
********************************************************************
*
*
* 27/02/07 - BG_100013043
*            CODE.REVIEW changes.
* 07/02/13 - Defect 498863 / Task 583569
*            Since new fields are introduced in LC,positions are modified
*            to display the LC details in enquiry.
*
* 03/09/14 - Task - 1104132
*           New line to be added in the enquiry if LC is fully utilised.
*           Defect - 1092770
*
* 09/12/14 - Task : 1116645 / Enhancement : 990544
*            LC Componentization and Incorporation
*
*
* 13/11/15 - Task - 1531492
*            Amendment date to be updated in the Enquiry output from
*            LC Booking date in the audit fields.
*            Defect - 1525670
*
* 20/01/6 - Task - 1993959
*           New line should not be created if cancellation is done after LC is fully utilised through DRAWINGS
*           Ref : 1982386
*
* 08/03/18 - Task : 2494215
*            Credit Tolerence not considered in Letter of Credit Summary query.
*            Ref : 2491485
*
* 08/05/18 - Task : 2578179
*            Tolerance amount not updated in LC SUMMARY after amending LC contract to include tolerance
*            Defect : 2568622
*
* 09/05/18 - Task : 2583255
*            Incorrect Update of LC Summary on reinitiating LC.
*            Ref : 2578865
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
********************************************************************
*
    $USING EB.Reports
    $USING LC.ModelBank
    $USING LC.Contract
    $USING EB.DataAccess
    $USING EB.SystemTables

*******************************************************************
*
    LC.NUM = EB.Reports.getId()
    CURR.NO = EB.Reports.getRRecord()<LC.Contract.LetterOfCredit.TfLcCurrNo>
    O.DATE = ""
    LC.CURR.DATE = ''
    LC.DATE = ''
    O.DIFF = ""
    O.AMOUNT = ""
    NEW.AMOUNT = ''
    LC.AMOUNT = ''
    TEMP.LC.AMOUNT = ''
    LC.FULLY.UTIL = ''
    NEW.LC.FULLY.UTIL = ''
    OLD.LC.UTIL = ''
    R.LC.HIS = ''
    LC.HIS.ERR = ''
    LC.CURR.DATE = EB.Reports.getRRecord()<LC.Contract.LetterOfCredit.TfLcDateTime>     ;* Amendment date of the current LC record is fetched.
    LC.CURR.DATE = OCONV(ICONV(LC.CURR.DATE[1,6], 'D2'), 'D4')    ;* Date is converted from format - DD MMM YY to DD MMM YYYY
    O.DESC = EB.Reports.getRRecord()<400>
    O.CCY = EB.Reports.getRRecord()<408>
    O.DATE = EB.Reports.getRRecord()<401>
    O.AMOUNT = EB.Reports.getRRecord()<402>
    N.DIFF = EB.Reports.getRRecord()<403>
    O.DIFF = EB.Reports.getRRecord()<407>
    O.TXNREF = EB.Reports.getRRecord()<410>
    O.CURR.NO = EB.Reports.getRRecord()<411>
    IF CURR.NO > 1 THEN
        FOR IDX = 1 TO (CURR.NO - 1)
            HIST.ID = LC.NUM:";":IDX
            OLD.LC.AMOUNT = LC.AMOUNT
            OLD.LC.UTIL = LC.FULLY.UTIL
            LC.Contract.LetterOfCreditHis(HIST.ID,R.LC.HIS, LC.HIS.ERR)
            CR.PERCENT = R.LC.HIS<LC.Contract.LetterOfCredit.TfLcPercentageCrAmt> ;* get tolerence cr precentage
            LC.AMOUNT = R.LC.HIS<LC.Contract.LetterOfCredit.TfLcLcAmount>
            LC.FULLY.UTIL = R.LC.HIS<LC.Contract.LetterOfCredit.TfLcFullyUtilised>
            LC.DATE = R.LC.HIS<LC.Contract.LetterOfCredit.TfLcDateTime>  ;* Amendment date of the current LC record is fetched from history record
            LC.DATE = OCONV(ICONV(LC.DATE[1,6], 'D2'), 'D4') ;* Date is converted from format - DD MMM YY to DD MMM YYYY
            IF LC.AMOUNT EQ '_' THEN
                LC.AMOUNT = OLD.LC.AMOUNT         ;* BG_100013043 - S
            END     ;*BG_100013043  - E
            LC.CURRENCY = EB.Reports.getRRecord()<LC.Contract.LetterOfCredit.TfLcLcCurrency>
            IF IDX = 1 THEN
                INIT.AMOUNT = LC.AMOUNT
                INIT.CR.PERCENT = CR.PERCENT ;* previous credit tolerence
            END
            TEMP.LC.AMOUNT = LC.AMOUNT      ;*Before making LC Amount as zero if LC is fully utilised,storing the amount in Temp variable for further calculation.
            TEMP.CR.PERCENT = CR.PERCENT    ;* previous credit tolerence
            GOSUB CHECK.ON.LC.AMOUNT    ;* BG_100013043 - S / E

        NEXT IDX

        GOSUB CHECK.ON.NEW.LC.AMOUNT    ;* BG_100013043 - S / E

        IF O.AMOUNT NE "" THEN
*  Now put result in R.RECORD starting position 18
            tmp=EB.Reports.getRRecord()
            tmp<400>=O.DESC
            EB.Reports.setRRecord(tmp)
            tmp=EB.Reports.getRRecord()
            tmp<407>=O.DIFF
            EB.Reports.setRRecord(tmp)
            tmp=EB.Reports.getRRecord()
            tmp<408>=O.CCY
            EB.Reports.setRRecord(tmp)
            tmp=EB.Reports.getRRecord()
            tmp<401>=O.DATE
            EB.Reports.setRRecord(tmp)
            tmp=EB.Reports.getRRecord()
            tmp<402>=O.AMOUNT
            EB.Reports.setRRecord(tmp)
            tmp=EB.Reports.getRRecord()
            tmp<403>=N.DIFF
            EB.Reports.setRRecord(tmp)
            tmp=EB.Reports.getRRecord()
            tmp<410>=O.TXNREF
            EB.Reports.setRRecord(tmp)
            tmp=EB.Reports.getRRecord()
            tmp<411>= O.CURR.NO ;*Store CURR.NO
            EB.Reports.setRRecord(tmp)
            EB.Reports.setVmCount(DCOUNT(O.AMOUNT, @VM))
        END
    END
RETURN
**********************************************************************************************************
* BG_100013043 - S
*==================
CHECK.ON.LC.AMOUNT:
*==================

    IF (LC.AMOUNT <> INIT.AMOUNT AND LC.AMOUNT NE "_") OR (OLD.LC.UTIL EQ 'Y' AND LC.FULLY.UTIL NE 'Y') OR (OLD.LC.UTIL NE 'Y' AND LC.FULLY.UTIL EQ 'Y') OR (CR.PERCENT <> INIT.CR.PERCENT) THEN
        IF LC.FULLY.UTIL EQ 'Y' THEN   ;*If LC is fully utilised the outstanding amount should be zero
            LC.AMOUNT = 0
        END
        AMEND.NO = R.LC.HIS<LC.Contract.LetterOfCredit.TfLcAmendmentNo>
        IF O.DESC EQ "" THEN
            O.DESC = "Amend"
            O.CCY = LC.CURRENCY
            O.DR.TYPE = "-"
            O.DATE = LC.DATE  ;* Amendment date from the history record
            O.AMOUNT = LC.AMOUNT
            GOSUB CALC.DIFF.AMOUNT ;* calculate tolrence for diff amount
            N.DIFF = DIFF
            O.DIFF = AMEND.NO
            INIT.AMOUNT = TEMP.LC.AMOUNT
            INIT.CR.PERCENT =  TEMP.CR.PERCENT
            O.CURR.NO = O.CURR.NO:@VM:IDX ;*Update Curr No
        END ELSE
            O.CCY = O.CCY:@VM:LC.CURRENCY
            O.DESC = O.DESC:@VM:"Amend"
            O.DR.TYPE = O.DR.TYPE:@VM:"-"
            O.DATE = O.DATE:@VM:LC.DATE   ;* Amendment date from the history record
            O.AMOUNT = O.AMOUNT:@VM:LC.AMOUNT
            GOSUB CALC.DIFF.AMOUNT ;* calculate tolrence for diff amount
            N.DIFF = N.DIFF:@VM:DIFF
            O.DIFF = O.DIFF:@VM:AMEND.NO
            INIT.AMOUNT = TEMP.LC.AMOUNT
            INIT.CR.PERCENT =  TEMP.CR.PERCENT
            O.TXNREF = O.TXNREF:@VM:HIST.ID
            O.CURR.NO = O.CURR.NO:@VM:IDX ;*Update Curr No
        END
    END
RETURN
**********************************************************************************************************
*======================
CHECK.ON.NEW.LC.AMOUNT:
*======================
*** Check to see if current record has changed too.
    NEW.AMOUNT = EB.Reports.getRRecord()<LC.Contract.LetterOfCredit.TfLcLcAmount>
    NEW.CCY = EB.Reports.getRRecord()<LC.Contract.LetterOfCredit.TfLcLcCurrency>
    NEW.AMEND.NO = EB.Reports.getRRecord()<LC.Contract.LetterOfCredit.TfLcAmendmentNo>
    NEW.LC.FULLY.UTIL = EB.Reports.getRRecord()<LC.Contract.LetterOfCredit.TfLcFullyUtilised>
    NEW.CR.PERCENT = EB.Reports.getRRecord()<LC.Contract.LetterOfCredit.TfLcPercentageCrAmt> ;* get tolerence cr precentage
    IF (NEW.AMOUNT <> TEMP.LC.AMOUNT AND TEMP.LC.AMOUNT NE '') OR (NEW.LC.FULLY.UTIL EQ 'Y' AND LC.FULLY.UTIL NE 'Y') OR (NEW.LC.FULLY.UTIL NE 'Y' AND LC.FULLY.UTIL EQ 'Y') OR NEW.CR.PERCENT NE INIT.CR.PERCENT THEN
        IF NEW.LC.FULLY.UTIL NE 'Y' AND LC.FULLY.UTIL EQ 'Y' OR NEW.LC.FULLY.UTIL EQ 'Y' THEN
            NEW.AMOUNT = NEW.AMOUNT - TEMP.LC.AMOUNT
        END
        IF O.AMOUNT EQ "" THEN
            O.DESC = "Amend"
            O.DR.TYPE = "-"
            O.AMOUNT = NEW.AMOUNT
            O.CCY = NEW.CCY
            O.DATE = LC.CURR.DATE   ;* Amendment date from the current LC record
            DIFF = NEW.AMOUNT - TEMP.LC.AMOUNT
            N.DIFF = DIFF
            O.DIFF = NEW.AMEND.NO
            O.CURR.NO = O.CURR.NO:@VM:EB.Reports.getRRecord()<LC.Contract.LetterOfCredit.TfLcCurrNo> ;*Update current Curr No
        END ELSE
            O.DESC = O.DESC:@VM:"Amend"
            O.DR.TYPE = O.DR.TYPE:@VM:"-"
            O.CCY = O.CCY:@VM:NEW.CCY
            O.DATE = O.DATE:@VM:LC.CURR.DATE    ;* Amendment date from the current LC record
            O.AMOUNT = O.AMOUNT:@VM:NEW.AMOUNT
            IF NEW.LC.FULLY.UTIL EQ 'Y' THEN      ;*If fully utilised is set as 'Y' then calculate the difference between drawings and lc amount
                NEW.AMOUNT = EB.Reports.getRRecord()<LC.Contract.LetterOfCredit.TfLcLcAmount>
                IF NEW.CR.PERCENT THEN
                    DIFF.TOLERENCE = NEW.AMOUNT * NEW.CR.PERCENT
                    DIFF.TOLERENCE = DIFF.TOLERENCE / 100
                    NEW.AMOUNT = NEW.AMOUNT + DIFF.TOLERENCE
                END
                DIFF = NEW.AMOUNT * (-1)
            END ELSE
                IF LC.FULLY.UTIL EQ 'Y' AND NEW.LC.FULLY.UTIL EQ 'NO' THEN
                    IF NEW.CR.PERCENT THEN
                        DIFF.TOLERENCE = NEW.AMOUNT * NEW.CR.PERCENT
                        DIFF.TOLERENCE = DIFF.TOLERENCE / 100
                        NEW.AMOUNT = NEW.AMOUNT + DIFF.TOLERENCE
                    END
                    DIFF = NEW.AMOUNT
                END ELSE

                    DIFF = NEW.AMOUNT - LC.AMOUNT ;* difference in principle

                    BEGIN CASE
                        CASE NEW.CR.PERCENT AND INIT.CR.PERCENT  ;* calculate the differnce in liability amount on tolerence change
                            PREV.TOLERENCE = LC.AMOUNT * INIT.CR.PERCENT
                            PREV.TOLERENCE = PREV.TOLERENCE / 100
                            CUR.TOLERENCE = NEW.AMOUNT *  NEW.CR.PERCENT
                            CUR.TOLERENCE = CUR.TOLERENCE / 100


                            DIFF + = CUR.TOLERENCE - PREV.TOLERENCE
                        
                        CASE NEW.CR.PERCENT AND NOT(INIT.CR.PERCENT) ;* if tolerance has been included in Amendment of contract then the LC Amount is increased which is calculated as follows
                            CUR.TOLERENCE = NEW.AMOUNT *  NEW.CR.PERCENT
                            CUR.TOLERENCE = CUR.TOLERENCE / 100
                            DIFF + = CUR.TOLERENCE
        
                        CASE NOT(NEW.CR.PERCENT) AND INIT.CR.PERCENT  ;* if tolerance has been removed in Amendment of contract then the LC Amount is reduced which is calculated as follows
                            PREV.TOLERENCE = LC.AMOUNT * INIT.CR.PERCENT
                            PREV.TOLERENCE = PREV.TOLERENCE / 100
                            DIFF - = PREV.TOLERENCE
        
                    END CASE

                END
            END
        END
        N.DIFF = N.DIFF:@VM:DIFF
        O.DIFF = O.DIFF:@VM:NEW.AMEND.NO
        O.TXNREF = O.TXNREF:@VM:EB.Reports.getId()
        O.CURR.NO = O.CURR.NO:@VM:EB.Reports.getRRecord()<LC.Contract.LetterOfCredit.TfLcCurrNo> ;*Update current Curr No
    END

RETURN          ;* BG_100013043 - E

**********************************************************************************************************
*** <region name= CALC.DIFF.AMOUNT>
*** <desc>Calculate tolrence amount differnece</desc>
CALC.DIFF.AMOUNT:

    DIFF = TEMP.LC.AMOUNT - INIT.AMOUNT ;* difference in principle

    BEGIN CASE
        
        CASE CR.PERCENT AND INIT.CR.PERCENT ;* calculate the differnce in liability amount on tolerence change
            PREV.TOLERENCE = INIT.AMOUNT * INIT.CR.PERCENT
            PREV.TOLERENCE = PREV.TOLERENCE / 100
            CUR.TOLERENCE = LC.AMOUNT * CR.PERCENT
            CUR.TOLERENCE = CUR.TOLERENCE / 100
            DIFF + = CUR.TOLERENCE - PREV.TOLERENCE

            
        CASE NOT(CR.PERCENT) AND INIT.CR.PERCENT ;* if tolerance is removed and an increase/decrease in LC Amount has been included in Amendment of contract then the LC Amount is increased/decreased which is calculated as follows
            PREV.TOLERENCE = INIT.AMOUNT * INIT.CR.PERCENT
            PREV.TOLERENCE = PREV.TOLERENCE / 100
            DIFF - = PREV.TOLERENCE
            
        CASE CR.PERCENT AND NOT(INIT.CR.PERCENT) ;* if tolerance is included and an increase/decrease in LC Amount has been included in Amendment of contract then the LC Amount is increased/decreased which is calculated as follows
            CUR.TOLERENCE = LC.AMOUNT * CR.PERCENT
            CUR.TOLERENCE = CUR.TOLERENCE / 100
            DIFF + = CUR.TOLERENCE
            
    END CASE
RETURN
*** </region>

**********************************************************************************************************
END
