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
* <Rating>-8</Rating>
*-----------------------------------------------------------------------------


    $PACKAGE AZ.Config
    SUBROUTINE CONV.AZ.ACCT.BAL.G14.2(AC.BAL.ID,AC.BAL.REC,YFILE)
* THIS IS A ROUTINE TO CONVERT AZ.ACCT.BAL RECORD

********************************************************************************

* 27/11/03 - EN_10002091
*            New fields added to AZ.ACCT.BAL for which data record,
*            has to be properly mapped to new field layout.
*
* 17/02/04 - BG_100006170
*            Bug fixes for record missing error at the time of calling DBR.
*            In the AC.BAL.ID variable have a Whole AZ.ACCT.BAL.HIST ID.
*            It is not same as ACCOUNT.ID. Now we passing the ACCOUNT.ID only
*
********************************************************************************


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT


* Here new field currency is added as the first field and date field
* is moved up.
* Two new fields are added to it called TYPE.B and SUB.ACCT

    OLD.AC.BAL.REC = AC.BAL.REC
    NEW.AC.BAL.REC = ''

    YAC.BAL.ID = FIELD(AC.BAL.ID,'-',1) ;* BG_100006170 - S
    CALL DBR("ACCOUNT":FM:AC.CURRENCY:FM:".A",YAC.BAL.ID,AZ.CCY)      ;* BG_100006170 - E

    NEW.AC.BAL.REC<1> = AZ.CCY          ;* NEW FIELD CURRENCY ADDED
    NEW.AC.BAL.REC<2> = OLD.AC.BAL.REC<6>         ;* DATE FIELD MOVED UP
    NEW.AC.BAL.REC<3> = OLD.AC.BAL.REC<1>         ;* PRINCIPAL
    NEW.AC.BAL.REC<4> = OLD.AC.BAL.REC<2>         ;* INTEREST
    NEW.AC.BAL.REC<5> = OLD.AC.BAL.REC<3>         ;* CHARGES
    NEW.AC.BAL.REC<6> = ''    ;* NEW FIELD TYPE.B
    NEW.AC.BAL.REC<7> = ''    ;* NEW FIELD SUB.ACCT
    NEW.AC.BAL.REC<8> = OLD.AC.BAL.REC<4>         ;* TYPE.N
    NEW.AC.BAL.REC<9> = OLD.AC.BAL.REC<5>         ;* TYPE.A
    NEW.AC.BAL.REC<10> = OLD.AC.BAL.REC<7>        ;* CONSL.BAL


* The below are the reserved fields that are added.

    FOR I = 11 TO 20
        NEW.AC.BAL.REC<I> = ''
    NEXT I

* Since this is called for AZ.ACCT.BAL.HIST also notes also has to be updated.

    IF OLD.AC.BAL.REC<8> THEN
        NEW.AC.BAL.REC<21> = OLD.AC.BAL.REC<8>
    END

    AC.BAL.REC = NEW.AC.BAL.REC

    RETURN
END
