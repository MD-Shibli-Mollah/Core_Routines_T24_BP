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

* Version n dd/mm/yy  GLOBUS Release No. G13.2.00 02/03/03
*-----------------------------------------------------------------------------
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE IC.Config
    SUBROUTINE CONV.ACCOUNT.ACCRUAL.G14(ID,REC,FILE)
*******************************************************
* 05/05/03 - EN_10001755
*            Conversion routine for populating values to the newly
*            added fields.
* 12/06/03 - BG_100004443
*            Changed NONE to MONTHLY as there was no 'NONE' functi
*            onality earlier. If NONE was specified it means no DAILY
*            accrual and hence MONTHLY.
* 02/02/07 - CI_10046982 / Ref: HD0701099
*            ACCOUNT.ACCRUAL not getting converted correctly when upgraded
*            from a lower release to R06 when accrual is set for a
*            particular category
*******************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT.ACCRUAL
*
    TEMP.REC=''
    TEMP.REC = REC
    REC<6> = '' ; REC<7> = '' ; REC<8> = ''
    BEGIN CASE
    CASE TEMP.REC<6> = ''
        REC<6> = 'BOTH'
        REC<7> = 'MONTHLY'
    CASE TEMP.REC<6> = 'LOCAL'
        REC<6,1> = 'FOREIGN'
        REC<6,2> = 'LOCAL'
        REC<7,1> = 'MONTHLY'
        REC<7,2> = 'DAILY'
    CASE TEMP.REC<6> = 'FOREIGN'
        REC<6,1> = 'FOREIGN'
        REC<6,2> = 'LOCAL'
        REC<7,1> = 'DAILY'
        REC<7,2> = 'MONTHLY'
    CASE TEMP.REC<6> = 'BOTH'
        REC<6> = 'BOTH'
        REC<7> = 'DAILY'
    END CASE
*
* Move the multivalue from DAILY.ACCR.CATG to ACCRUAL.CATEGORY
    DAILY.ACCR.CATEG.COUNT = DCOUNT(TEMP.REC<7>,VM)
    FOR CTR = 1 TO DAILY.ACCR.CATEG.COUNT
        REC<11,CTR> = TEMP.REC<7,CTR>
        IF TEMP.REC<8,CTR> = 'NONE' THEN
            REC<12,CTR> = 'BOTH'
            REC<13,CTR> = 'MONTHLY'
        END ELSE
            REC<12,CTR> = TEMP.REC<8,CTR>
            REC<13,CTR> = 'DAILY'
        END
    NEXT
    RETURN
END
