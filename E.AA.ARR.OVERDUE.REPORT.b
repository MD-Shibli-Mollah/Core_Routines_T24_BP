* @ValidationCode : Mjo0NDIyMjE2NTpDcDEyNTI6MTU2NTI2MTM3MzU5MDphcm9vYmE6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwNy4yMDE5MDYxMi0wMzIxOjE0Mjo2Ng==
* @ValidationInfo : Timestamp         : 08 Aug 2019 16:19:33
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : arooba
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 66/142 (46.4%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201907.20190612-0321
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-42</Rating>
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* This subroutine is attached to the NOFILE enquiry AA.ARR.OVERDUE.REPORT
*
* This routine will select the list of arrangements with PRODUCT.LINE EQ LENDING from AA.ARRANGEMENT. With AA ID it will read AA.ACCOUNT.DETAILS.
* Using the bill details present here, reads all the bills with bill status equal to AGING or BILL.STATUS equal to DUE and BILL.TYPE eq ACT.CHARGE
* and SET.STATUS equal to UNPAID and BILL.DATE less than TODAY for the selected arrangement's and display the overdue details.
* The final array will contain the arrangement ID, Currency, Principal amount and other details
*
* Nofile enquiry was written because the multi set fields consisting BILL data in AA.ACCOUNT.DETAILS had to be read and displayed only if in case the
* above mentioned condition's match.
*
*=================================================================================================================
*                            M O D I F I C A T I O N S
*=================================================================================================================
*
*** <region name= Modification History>
*** <desc>Changes done in the sub-routine</desc>
* Modification History
*
* 04/08/12 - Task : 458133
*            Ref : Defect 458035
*            While calculating number of days include even hoildays to get exact number of days after bill generation.
*
* 16/09/13 - Task : 784060
*            Ref : Defect 778177
*            When same property class(INTEREST and CHARGE) has more than one property for a bill system failed
*	         to fetch the correct amount for the property class.
*
* 09/09/15 - Task : 1447056
*            Enhancement : 1434821
*            Get the GL Custoemr by calling AA.GET.ARRANGEMENT.CUSTOMER routine.
*
*06/08/19 - Task : 3268068
*            Defect : 3266195
*            Performance Fix for launching enquiry without passing any criteria
*
*
*** </region>
*------------------------------------------------------------------------------------------------------------------

$PACKAGE AA.ModelBank
SUBROUTINE E.AA.ARR.OVERDUE.REPORT(FINAL.ARR)

    $INSERT I_DAS.AA.ARRANGEMENT
    $INSERT I_DAS.COMMON

    $USING AA.Framework
    $USING AA.PaymentSchedule
    $USING AA.ProductFramework
    $USING EB.API
    $USING EB.SystemTables
    $USING EB.Reports


    GOSUB INITIALISE
    GOSUB GET.AA.IDS
    GOSUB PROCESS

RETURN

************
INITIALISE:
************
* Initialisations done here

    F.AA.ACCOUNT.DETAILS = ""

    F.AA.ARRANGEMENT = ""

    F.AA.BILL.DETAILS = ""

    Y.FLAG = "NEW"
    Y.TEMP.POS = ""
    Y.POS = 1
    Y.DUMMY = ""
    YSEP = "#"

    Y.AA.ID = ""
    Y.AA.CUST = ""
    Y.AA.CCY = ""
    Y.PRODUCT = ""
    Y.OD.STATUS = ""

RETURN

**********
GET.AA.IDS:
**********

    LOCATE 'OD.STATUS' IN EB.Reports.getEnqSelection()<2,1> SETTING OD.STATUS.POS THEN
        Y.OD.STATUS =  EB.Reports.getEnqSelection()<4,OD.STATUS.POS>

        TMP=EB.Reports.getEnqSelection()
        DEL TMP<2,OD.STATUS.POS>
        EB.Reports.setEnqSelection(TMP)

        TMP=EB.Reports.getEnqSelection()
        DEL TMP<3,OD.STATUS.POS>
        EB.Reports.setEnqSelection(TMP)


        TMP=EB.Reports.getEnqSelection()
        DEL TMP<4,OD.STATUS.POS>
        EB.Reports.setEnqSelection(TMP)
    END

    LOCATE 'PRODUCT' IN EB.Reports.getEnqSelection()<2,1> SETTING PRODUCT.POS THEN
        Y.PRODUCT =  EB.Reports.getEnqSelection()<4,PRODUCT.POS>
    END

    ARGUMENTS<1> = EB.Reports.getEnqSelection()<2>
    ARGUMENTS<2> = EB.Reports.getEnqSelection()<3>
    ARGUMENTS<3> = EB.Reports.getEnqSelection()<4>

    ARGUMENTS<1,-1> = "PRODUCT.LINE"
    ARGUMENTS<2,-1> = "EQ"
    ARGUMENTS<3,-1> = "LENDING"

    TABLE.NAME   = "AA.ARRANGEMENT"
    TABLE.SUFFIX = ""
    DAS.LIST     = DasAaArrangement$OverdueReport

    CALL DAS(TABLE.NAME, DAS.LIST, ARGUMENTS, TABLE.SUFFIX)

RETURN

*******
PROCESS:
********

    LOOP
        REMOVE AA.ARR.ID FROM DAS.LIST SETTING AA.POS
    WHILE AA.ARR.ID:AA.POS

        R.AA.ACCOUNT.DETAILS = AA.PaymentSchedule.AccountDetails.Read(AA.ARR.ID, ERR.AA.DET)
        Y.AA.ARR.STATUS = R.AA.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdArrAgeStatus>
        IF Y.OD.STATUS AND Y.OD.STATUS NE Y.AA.ARR.STATUS THEN
            CONTINUE
        END

        R.ARR.REC = AA.Framework.Arrangement.Read(AA.ARR.ID, ERR.AA)
        Y.EFF.DATE<1> = EB.SystemTables.getToday()
        AA.INFO<1> = AA.ARR.ID
        AA.Framework.GetArrangementProduct(AA.INFO,Y.EFF.DATE,R.ARR.REC,Y.PRD,Y.PROPERTY.LIST)

        IF Y.PRODUCT AND Y.PRODUCT NE Y.PRD THEN
            CONTINUE
        END
**Bill datas should not be read for the arrangement which is in close and pending closure status.
**If there are more closed contracts then it will loop through to get the bill details which is not required.
**Hence to avoid this condition had been added to avoid looping for closed and pending closure arrangements.
        IF NOT(R.ARR.REC<AA.Framework.Arrangement.ArrArrStatus,1> MATCHES "CLOSE":@VM"PENDING.CLOSURE") THEN

            GOSUB GET.BILL.DATA

            FOR I=1 TO Y.BILL.CNT
                Y.SM.CNT = DCOUNT(Y.BILL.IDS<1,I>,@SM)
                FOR K=1 TO Y.SM.CNT
                    IF Y.BILL.STATUS<1,I,K> EQ 'AGING' OR (Y.BILL.STATUS<1,I,K> EQ 'DUE' AND Y.BILL.TYPE<1,I,K> EQ 'ACT.CHARGE' AND Y.SET.STATUS<1,I,K> EQ 'UNPAID' AND Y.BILL.DATE<1,I,K> LT EB.SystemTables.getToday()) THEN
                        GOSUB BILL.PROCESS
                    END
                NEXT K
            NEXT I

            GOSUB GET.AA.TOTAL
        END
    REPEAT

RETURN

*************
GET.AA.TOTAL:
*************
    Y.FLAG = "NEW"
    IF Y.TEMP.POS THEN
        FINAL.ARR<Y.TEMP.POS> := YSEP:Y.TOTAL
        Y.TEMP.POS = ""
        Y.TOTAL = ""
    END

RETURN

**************
GET.BILL.DATA:
**************

    Y.BILL.STATUS = R.AA.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdBillStatus>
    Y.BILL.IDS = R.AA.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdBillId>

    Y.BILL.TYPE = R.AA.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdBillType>
    Y.SET.STATUS = R.AA.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdSetStatus>
    Y.BILL.DATE = R.AA.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdBillPayDate>

    Y.BILL.CNT = DCOUNT(Y.BILL.IDS,@VM)

RETURN

*************
BILL.PROCESS:
*************

    R.AA.BILL.DETAILS = AA.PaymentSchedule.BillDetails.Read(Y.BILL.IDS<1,I,K>, ERR.BILL)

    CALL AA.GET.ARRANGEMENT.CUSTOMER(AA.ARR.ID, "", "", "", "", Y.AA.CUST, RET.ERROR)
    Y.AA.CCY = R.ARR.REC<AA.Framework.ArrangementSim.ArrCurrency>
    Y.ARR.STATUS = "AA.OVERDUE.STATUS*":Y.AA.ARR.STATUS

    GOSUB GET.DUE.AMT

    Y.DUE.DATE = R.AA.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdBillPayDate,I>
    NO.OF.DAYS = "C"
    tmp.TODAY = EB.SystemTables.getToday()
    EB.API.Cdd("",Y.DUE.DATE,tmp.TODAY,NO.OF.DAYS)
    EB.SystemTables.setToday(tmp.TODAY)
    Y.DAYS = NO.OF.DAYS
    Y.BILL.ST = Y.BILL.STATUS<1,I,K>

    GOSUB PREPARE.OUT.ARR

RETURN

****************
PREPARE.OUT.ARR:
****************

    IF Y.FLAG EQ 'NEW' THEN
        Y.FLAG = ""
        FINAL.ARR<Y.POS> = AA.ARR.ID:YSEP:Y.AA.CUST:YSEP:Y.PRD:YSEP:Y.ARR.STATUS:YSEP:Y.AA.CCY:YSEP:Y.DUMMY:YSEP:Y.DUE.DATE:YSEP
        FINAL.ARR<Y.POS> := Y.BILL.IDS<1,I,K>:YSEP:Y.PRIN:YSEP:Y.INT:YSEP:Y.PEN:YSEP:Y.OTH:YSEP:Y.DUE.AMT:YSEP:Y.DAYS:YSEP:Y.BILL.ST
        Y.TEMP.POS = Y.POS
        Y.POS +=1
        Y.TOTAL += Y.DUE.AMT
    END ELSE
        FINAL.ARR<Y.POS> = "######":Y.DUE.DATE:YSEP
        FINAL.ARR<Y.POS> := Y.BILL.IDS<1,I,K>:YSEP:Y.PRIN:YSEP:Y.INT:YSEP:Y.PEN:YSEP:Y.OTH:YSEP:Y.DUE.AMT:YSEP:Y.DAYS:YSEP:Y.BILL.ST
        Y.POS +=1
        Y.TOTAL += Y.DUE.AMT
    END
    Y.PRIN = ""
    Y.INT = ""
    Y.PEN = ""
    Y.OTH = ""
    Y.DUE.AMT = ""

RETURN

***********
GET.DUE.AMT:
***********

    Y.PROPERTY = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdProperty>
    Y.PROP.CNT = DCOUNT(Y.PROPERTY,@VM)
    FOR J=1 TO Y.PROP.CNT
        GOSUB PROCESS.PROPERTY
    NEXT J
    Y.DUE.AMT = Y.PRIN + Y.INT + Y.PEN + Y.OTH

RETURN

****************
PROCESS.PROPERTY:
****************

    R.AA.PROPERTY = AA.ProductFramework.Property.CacheRead(Y.PROPERTY<1,J>, ERR.PROP)
    Y.CLASS = R.AA.PROPERTY<AA.ProductFramework.Property.PropPropertyClass>
    IF Y.CLASS EQ "ACCOUNT" THEN
        Y.PRIN = R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOsPropAmount,J>
    END
    IF Y.CLASS EQ "INTEREST" THEN
        Y.INT += R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOsPropAmount,J>
    END
    IF Y.CLASS NE "ACCOUNT" AND Y.CLASS NE "INTEREST" THEN
        Y.OTH += R.AA.BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOsPropAmount,J>
    END
    Y.CLASS = ""

RETURN

END
