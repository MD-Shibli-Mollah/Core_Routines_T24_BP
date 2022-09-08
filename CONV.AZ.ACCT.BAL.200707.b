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
* <Rating>-76</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AZ.Config
    SUBROUTINE CONV.AZ.ACCT.BAL.200707
*---------------------------------------------------------------------------------------
* This is a FILE.ROUTINE which is attached to CONVERSION.DETAILS>CONV.AZ.ACCT.BAL.200707
* This routine copies AZ.PEN.CHARGE.CODE and AZ.PEN.AMOUNT from AZ.PENAL.CHARGE file to
* AZ.ACCT.BAL file. As AZ.PENAL.CHARGE has been made obsolete, this conversion copies
* charge information from every record and updates corresponding AZ.ACCT.BAL record.
* SAR Ref: SAR-2005-02-10-0002
*---------------------------------------------------------------------------------------
* 18/04/07 - EN_10003299
*            New routine.
*
* 10/08/07 - BG_100014877
*            Instead of OPF API, direct OPEN is used to open AZ.PENAL.CHARGE file.
*---------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_DAS.COMPANY
    $INSERT I_DAS.AZ.PENAL.CHARGE

    SAVE.ID.COMPANY = ID.COMPANY

    THE.LIST = DAS.COMPANY$REAL.COMPANIES
    CALL DAS('COMPANY',THE.LIST,'','')
    COMPANY.LIST = THE.LIST

    LOOP
        REMOVE K.COMPANY FROM COMPANY.LIST SETTING YDLIM
    WHILE K.COMPANY:YDLIM

        NO.SRC.FILE = ''

        IF ID.COMPANY NE K.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
        END

        LOCATE 'AZ' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING AZ.INSTALLED THEN
            GOSUB OPEN.FILES

            IF NO.SRC.FILE THEN
                CONTINUE
            END

            GOSUB PROCESS
        END
    REPEAT

    IF ID.COMPANY NE SAVE.ID.COMPANY THEN
        CALL LOAD.COMPANY(SAVE.ID.COMPANY)
    END

    RETURN

OPEN.FILES:
*---------

    FN.AZ.ACCT.BAL = 'F.AZ.ACCT.BAL'
    FV.AZ.ACCT.BAL = ''
    CALL OPF(FN.AZ.ACCT.BAL,FV.AZ.ACCT.BAL)

    YMNEMONIC = R.COMPANY(EB.COM.MNEMONIC)
    FN.AZ.PENAL.CHARGE = 'F':YMNEMONIC:'.AZ.PENAL.CHARGE'
    FV.AZ.PENAL.CHARGE = ''

    OPEN FN.AZ.PENAL.CHARGE TO FV.AZ.PENAL.CHARGE ELSE
* Unable to open the source file. No conversion to perform in this company.
        NO.SRC.FILE = 1
        RETURN
    END

    FN.AZ.ACCOUNT = 'F.AZ.ACCOUNT'
    FV.AZ.ACCOUNT = ''
    CALL OPF(FN.AZ.ACCOUNT,FV.AZ.ACCOUNT)

    RETURN

PROCESS:
*-------

    PEN.ID = ''
    PEN.CHG.IDS = ''

*Select all the record IDs from AZ.PENAL.CHARGE
    THE.LIST = 'ALL.IDS'
    CALL DAS("AZ.PENAL.CHARGE",THE.LIST,'','')
    PEN.CHG.IDS = THE.LIST

    LOOP
        REMOVE PEN.ID FROM PEN.CHG.IDS SETTING Y.DLIM
    WHILE PEN.ID:Y.DLIM

        R.ACCT.BAL = ''
        R.PENAL.CHARGE = ''

*Extract ACCOUNT Number and DATE from the every selected AZ.PENAL.CHARGE ID
        AZ.ID = FIELD(PEN.ID,'-',1)
        CHG.DATE = FIELD(PEN.ID,'-',2)

*Get the charge code and charge amount from every AZ.PENAL.CHARGE record
        READ R.PENAL.CHARGE FROM FV.AZ.PENAL.CHARGE,PEN.ID THEN

            READ R.ACCT.BAL FROM FV.AZ.ACCT.BAL,AZ.ID ELSE
*If there is no AZ.ACCT.BAL record for AZ.ID, then assign AZ.CURRENCY to ACCT.BAL record
                GOSUB INIT.ACCT.BAL
            END

            GOSUB MOVE.CHG.FIELDS

            GOSUB WRITE.FILES

        END

    REPEAT
    RETURN

INIT.ACCT.BAL:
*------------

    R.AZ.ACCOUNT = ''
    READ R.AZ.ACCOUNT FROM FV.AZ.ACCOUNT,AZ.ID THEN
        R.ACCT.BAL<1> = R.AZ.ACCOUNT<3> ;*Field - CURRENCY
    END

    RETURN

MOVE.CHG.FIELDS:
*---------------

    Y.CHG.CODE = LOWER(R.PENAL.CHARGE<1>)         ;*Field - AZ.PEN.CHARGE.CODE
    Y.CHG.AMT = LOWER(R.PENAL.CHARGE<2>)          ;*Field - AZ.PEN.AMOUNT
*Copy the penalty details to AZ.ACCT.BAL record
    LOCATE CHG.DATE IN R.ACCT.BAL<18,1> BY 'AR' SETTING DT.POS THEN
        CHG.POS = DCOUNT(R.ACCT.BAL<19>,SM) + 1
        R.ACCT.BAL<19,DT.POS,CHG.POS> = Y.CHG.CODE
        R.ACCT.BAL<20,DT.POS,CHG.POS> = Y.CHG.AMT
    END ELSE
        INS CHG.DATE BEFORE R.ACCT.BAL<18,DT.POS> ;*Field - AZ.ACCT.PEN.DATE
        INS Y.CHG.CODE BEFORE R.ACCT.BAL<19,DT.POS>         ;*Field - AZ.ACCT.PEN.CHG.CODE
        INS Y.CHG.AMT BEFORE R.ACCT.BAL<20,DT.POS>          ;*Field - AZ.ACCT.PEN.CHG.AMT
    END

    RETURN

WRITE.FILES:
*----------

*Copy to AZ.ACCT.BAL and delete the record from AZ.PENAL.CHARGE
    WRITE R.ACCT.BAL TO FV.AZ.ACCT.BAL,AZ.ID
    DELETE FV.AZ.PENAL.CHARGE,PEN.ID

    RETURN

END
*---------------------------------------* End of routine *---------------------------------------*
