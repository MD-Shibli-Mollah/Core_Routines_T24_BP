* @ValidationCode : MjoxODk5MDc0NTYyOkNwMTI1MjoxNTMyMzYyMTQ4MTY5Omtqb2huc29uOjI6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxODA3LjIwMTgwNjIxLTAyMjE6MjM6MTc=
* @ValidationInfo : Timestamp         : 23 Jul 2018 17:09:08
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : kjohnson
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 17/23 (73.9%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201807.20180621-0221
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE FT.ModelBank
SUBROUTINE V.MB.BN.EXPOSURE.DATE
*-------------------------------------------------
* 17/10/17 - Defect 2292224 / Task 2310004
*          - Defect Debit and Credit exposure dates for BN FT screen.
*
* 23/07/18 - Defect 2668467 / Task 2690312
*            Use COMI to default value as routine is a field validation
*            and therefore R.NEW is not set. 
*
*----------------------------------------------------
    $USING EB.SystemTables
    $USING FT.Contract
    $USING FT.ModelBank
*
*Defaulting processing date,debit/credit value date to today ,if the date is less than
*today. so that it wont cause any problem if user input an transaction while date change during cob.
*

    BEGIN CASE
        CASE EB.SystemTables.getAf() = FT.Contract.FundsTransfer.ProcessingDate
            IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ExposureDate) EQ '' THEN
                BEGIN CASE
                    CASE EB.SystemTables.getComi() NE ''
                        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.ExposureDate, EB.SystemTables.getComi())
                    CASE EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ProcessingDate) NE ''
                        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.ExposureDate, EB.SystemTables.getRNew(FT.Contract.FundsTransfer.ProcessingDate))
                    CASE 1
                        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.ExposureDate, EB.SystemTables.getToday())
                END CASE
            END
        CASE EB.SystemTables.getAf() = FT.Contract.FundsTransfer.CreditValueDate
            IF EB.SystemTables.getRNew(FT.Contract.FundsTransfer.DebitValueDate) EQ '' THEN
                BEGIN CASE
                    CASE EB.SystemTables.getComi() NE ''
                        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.DebitValueDate, EB.SystemTables.getComi())
                    CASE 1
                        EB.SystemTables.setRNew(FT.Contract.FundsTransfer.DebitValueDate, EB.SystemTables.getRNew(FT.Contract.FundsTransfer.CreditValueDate))
                END CASE
            END
    END CASE

RETURN
END
