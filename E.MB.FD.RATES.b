* @ValidationCode : MjoyMDgyOTE0NTk1OkNwMTI1MjoxNTk5NjU2Mzk5NjQzOmFyb29iYToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMDA4LjIwMjAwNzMxLTExNTE6MjU6MjM=
* @ValidationInfo : Timestamp         : 09 Sep 2020 18:29:59
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : arooba
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 23/25 (92.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.20200731-1151
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-10</Rating>
*-----------------------------------------------------------------------------
* 22/10/12- New Development
* Purpose - The routine is attached as a field conversion routine in enquiry AI.AA.FD.RATES
*-----------------------------------------------------------------------------

*** <region name= Modification History>
*** <desc>Changes done in the sub-routine</desc>
* Modification History
*
* 14/07/20 - Defect : 3840241
*            Task : 3855200
*            The enquiry TC.PERIODIC.INTEREST display the junk characters in Amount field while projecting in UXPB screen.
*
*** </region>
*-----------------------------------------------------------------------------
$PACKAGE AD.ModelBank
SUBROUTINE E.MB.FD.RATES
    
    $USING EB.Reports
    $USING ST.RateParameters
    
    GOSUB PROCESS

RETURN

PROCESS:
*******

    RATE=EB.Reports.getOData()
    
    COMP.DEP=FIELD(RATE,"~",2)
    IF COMP.DEP NE "YES" THEN      ;*This check is performed in order to avoid the component dependency. New logic is applicable only if YES value returned from enquiry.
        RATE.FIELD=FIELD(RATE," ",2)

        EB.Reports.setOData(">":RATE.FIELD)
    
    END ELSE
 
***In UXPB architecture we have difficulty in handling sub values in enquiries. So the enquiry has been redesigned such that Amt field to be directly retrieved from application field.
        R.RECORD = EB.Reports.getRRecord()
    
        AMT.CNT = DCOUNT(R.RECORD<ST.RateParameters.PeriodicInterest.PiAmt>,@VM)
        FOR YCNT = 1 TO AMT.CNT
            IF R.RECORD<ST.RateParameters.PeriodicInterest.PiAmt,YCNT> THEN
                SM.CNT = DCOUNT(R.RECORD<ST.RateParameters.PeriodicInterest.PiAmt,YCNT>,@SM)
                FOR XCNT = 1 TO SM.CNT
                    IF XCNT LT SM.CNT THEN
                        R.RECORD<ST.RateParameters.PeriodicInterest.PiAmt,YCNT,XCNT> = "Upto ":R.RECORD<ST.RateParameters.PeriodicInterest.PiAmt,YCNT,XCNT>
                    END ELSE
                        R.RECORD<ST.RateParameters.PeriodicInterest.PiAmt,YCNT,XCNT> = "> ":FIELDS(R.RECORD<ST.RateParameters.PeriodicInterest.PiAmt,YCNT,XCNT-1>,"Upto ",2)
                    END
                NEXT XCNT
            END
        NEXT YCNT
    
        EB.Reports.setRRecord(R.RECORD)
    
    END

RETURN



END
