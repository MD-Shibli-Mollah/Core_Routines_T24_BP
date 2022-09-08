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
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PM.Engine
    SUBROUTINE CONV.PM.TRAN.ACTIVITY.G132(RECORD.ID,R.PMTA.REC,FILE)
*
*
*
* This routine was written to populate the respective applications in
* the field APPLICATION of each PM.TRAN.ACTIVITY record which got
* raised through various applications.
* It is a RECORD ROUTINE.
* This is related to the cd EN_10001647.(SAR-2002-10-17-0003)
*
*
* 21/07/04 - CI_10021190
*            Related to the SAR-2002-10-17-0003 (EN_10001647)
*
* 11/08/04 - CI_10022026
*            END stmt. added.
*
* 19/08/04 - CI_10022291
*            Changes made for Data Capture related PMTA's.
*
* 23/09/04 - CI_10023416
*            Change made for FT related PMTA's.
*
* 13/04/06 - CI_10040528
*            Variable uninitialised error when the conversion's record routine is executed
*            for an FT contract in PTA.In this case APPL.FILE remains uninitialised.
*
*************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.PM.TRAN.ACTIVITY
*************************************************************************

    SKIP.PROCESS = ''
    APPL.FILE = ''
    APPLN = RECORD.ID[1,2]

    BEGIN CASE
    CASE APPLN EQ 'DC'
        APPL.FILE = 'DATA.CAPTURE'
    CASE APPLN EQ 'DI'
        IF LEN(RECORD.ID) GT 16 THEN
            APPL.FILE = 'ENTITLEMENT'
        END ELSE
            APPL.FILE = 'DIARY'
        END

* STO generated FT's related PMTA's application field contains "STO.PAYMENTS" - now changed.
    CASE APPLN EQ 'FT'
        R.PMTA.REC<PM.APPLICATION> = 'FUNDS.TRANSFER'

    CASE RECORD.ID[1,4] EQ 'SECT'
        APPL.FILE = 'SECURITY.TRANSFER'

    CASE 1
        CALL PROCESS.SOFT.FILE(APPL.FILE,RECORD.ID,APPLN)

    END CASE

    IF APPL.FILE NE "ACCOUNT" AND NOT(R.PMTA.REC<PM.APPLICATION>) THEN
        R.PMTA.REC<PM.APPLICATION> = APPL.FILE
    END

    RETURN
END
