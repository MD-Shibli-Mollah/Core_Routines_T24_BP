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

* Version 3 15/05/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>75</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LI.ModelBank

    SUBROUTINE E.LIM.CHK.SCTP
*-------------------------------------------------
*
* This subroutine will check the LIMIT.TXNS reference key to
* see if it is for a SC.TRADING.POSITION record, if it is then
* ODATA will be modified to have ST placed in the first two characters.
* It is used in the standard enquiry system
* and therefore all the parameters required are
* passed in I_ENQUIRY.COMMON
*
* The fields used are as follows:-
*
*
* INPUT    O.DATA          Full txn reference key
*
*
* OUTPUT  O.DATA          Modified txn reference key
*
************************************************************************
* MODIFICATION LOG:
******************
*
* 06/05/05 - EN_100002507
*            SC Non stop Phase II.
*
* 25/10/07 - CI_10052144
*            Last level drill down fails for Facility when running LIAB enq.
*--------------------------------------------------------------------------*
    $USING ST.CompanyCreation
    $USING SC.SctDealerBook
    $USING EB.Reports
    $USING EB.SystemTables


    O.DATA.VALUE = EB.Reports.getOData()
    LOCATE "SC" IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING SC.POS THEN
    STP.KEY = O.DATA.VALUE
    GOSUB SC.READ.STP
    ER = READ.ERROR ; R.SCT = STP.RECORD

    IF R.SCT THEN O.DATA.VALUE[1,2] = "ST"
    END
*
* Processing for SL and FACILITY
*
    IF O.DATA.VALUE[1,2] EQ 'SL' THEN
        ID.LEN = LEN(O.DATA.VALUE)
        BEGIN CASE
            CASE ID.LEN EQ 12
                O.DATA.VALUE = 'SPL'
            CASE ID.LEN EQ 14
                O.DATA.VALUE = 'SFL'
            CASE ID.LEN EQ 19
                O.DATA.VALUE = 'SLL'
        END CASE
        EB.Reports.setOData(O.DATA.VALUE)
        RETURN
    END

    O.DATA.VALUE = O.DATA.VALUE[1,4]
    IF O.DATA.VALUE EQ 'FDOR' THEN
        O.DATA.VALUE = 'FO'
    END
    EB.Reports.setOData(O.DATA.VALUE[1,2])
*
    RETURN

*****************
SC.READ.STP:
*****************

    REV1 = ''
    REV2 = ''
    REV3 = ''
    REV4 = ''
    READ.ERROR = ''
    STP.RECORD.ORG = ''
    STP.RECORD = ''
    NOT.READ.ALONE = 0
    LOCK.RECORD = 0

    SC.SctDealerBook.ReadStp(STP.KEY,LOCK.RECORD,NOT.READ.ALONE,REV1,REV2,STP.RECORD,STP.RECORD.ORG,READ.ERROR,REV3,REV4)

    RETURN

    END
