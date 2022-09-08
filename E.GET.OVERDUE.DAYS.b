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

*----------------------------------------------------------------
* <Rating>-40</Rating>
*----------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.GET.OVERDUE.DAYS
*
* New routine has been developed to display the number of days passed the due date.
*
*----------------------------------------------------------------
*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine </desc>
* Modification History
*
* 14/05/14 - Task : 997863
*            Defect : 984124
*            The OD days returned based on the BILL.STATUS
*
* 25/01/16 - Task : 1605438
*            Defect ID : 1593519
*            Compilation Warnings - Retail for TAFC compatibility on DEV area.
*
*** </region>
*-----------------------------------------------------------------------------


    $USING EB.Reports
    $USING EB.SystemTables

    GOSUB INIT
    GOSUB PROCESS
    RETURN

INIT:

    OD.DAYS = EB.Reports.getOData()
    FROM.DATE = FIELD(OD.DAYS,"*",1)
    BILL.STATUS = FIELD(OD.DAYS,"*",2)
    RETURN

PROCESS:

    BEGIN CASE
        CASE BILL.STATUS EQ "Due"
            GOSUB GET.NO.DAYS
        CASE BILL.STATUS EQ "Aging"
            GOSUB GET.NO.DAYS
        CASE 1
            EB.Reports.setOData("");* For other bill status the return value will be always Null
    END CASE
    RETURN

GET.NO.DAYS:
* this block will execute only for Due,Grace,Deliquent & Non Accrual Basis
    TO.DATE = EB.SystemTables.getToday()
    FROM.DATE.COUNT = ICONV(FROM.DATE,"D")
    TO.DATE.COUNT = ICONV (TO.DATE,"D")
    IF FROM.DATE.COUNT LT TO.DATE.COUNT  THEN        ;* No need to show the OD days for Furture dated contract
        NO.OF.DAYS = TO.DATE.COUNT - FROM.DATE.COUNT
        EB.Reports.setOData(NO.OF.DAYS)
    END ELSE
        EB.Reports.setOData("")
    END
    RETURN
    END
