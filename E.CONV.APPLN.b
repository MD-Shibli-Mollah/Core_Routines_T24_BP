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
* <Rating>-42</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.CONV.APPLN
**************************************************************************
*   Modification log
*   ----------------
*
* 28/09/04 - CI_10023532
*            New subroutine to fetch the correct APPLICATION for
*            securities related txns.
*
* 20/10/04 - CI_10024070
*            The RECORD.ID is suffixed with company mnemonic if a cross
*            company txn. is made and results in wrong population of appln. to
*            O.DATA. The "if condn."  is changed for "DIARY" related record.
*
* 30/06/05 - CI_10031552
*            The problem, empty window in drilldown has been rectified by making
*            NEW.BASE.APPLN in the enquiry STMT.ENT.BOOK refer to AC.CHARGE.REQUEST.
*
* 20/08/05 - CI_10033663
*            Problem in display of capitalised IC.CHARGE from STMT.GEN.CHG file in
*            the ENQ STMT.ENT.BOOK. If APPL.ID is 'ICGC' then set the base file as
*            STMT.GEN.CHG
*            Reg: TTS0501991
*
* 23/11/05 - BG_100009726
*            Problem in display of stmt entry from CHEQUE.COLLETION file in
*            the ENQ STMT.ENT.BOOK. If APPL.ID is 'CQ' then set the base file as
*            either TELLER or FUNDS.TRANSFER
*            Ref :TTS0502140
*
* 21/06/06 - CI_10041992
*            Unable to drilldown to see the PD.CAPTURE record through STMT.ENT.BOOK enquiry.
*
* 28/05/07 - CI_10049383
*            STMT.ENT.BOOK not showing the CHEQUE.ISSUE record while drill down.
*
* 16/12/08 - CI_10059479(CSS REF:HD0835810)
*            Changes done to display the MG.PAYMENT record corectly during drilldown.
*
* 29/07/10 - Defect 70530 / CI_10070980
*            If APPL.DRILLDOWN is set to 'NO' then return without assigning the application.
*
***********************************************************************************
    $USING EB.Reports

    APPLICATION.DRILLDOWN = ''
    LOCATE 'APPL.DRILLDOWN' IN EB.Reports.getDFields() SETTING ADD.POS THEN
    APPLICATION.DRILLDOWN = EB.Reports.getDRangeAndValue()<ADD.POS>
    END
    IF APPLICATION.DRILLDOWN EQ 'NO' THEN
        EB.Reports.setOData('')
        RETURN
    END
    IN.O.DATA = EB.Reports.getOData()
    OUT.O.DATA = ''
    APPLN.ID = FIELD(IN.O.DATA,":",1)
    RECORD.ID = FIELD(IN.O.DATA,":",2)

    PRODUCT.ENT = INDEX(RECORD.ID,'.',1)

* Diary related STMT.ENTRY will have SYSTEM.ID as "SCCA" whose appln. in EB.SYSTEM.ID is
* ENTITLEMENT. The below changes will change it to DIARY to fetch the DIARY txns. when drilled down.

    IF APPLN.ID = 'SCCA' AND RECORD.ID[1,2] = 'DI' AND NOT(PRODUCT.ENT) THEN
        OUT.O.DATA = 'DIARY'
    END

    IF APPLN.ID = 'AC' AND RECORD.ID[1,2] = 'CH' THEN
        OUT.O.DATA= "AC.CHARGE.REQUEST"
    END

    IF APPLN.ID = 'ICGC' THEN
        OUT.O.DATA = "STMT.GEN.CHG"
    END

    IF APPLN.ID = 'CQ' THEN
        GOSUB PROCESS.CQ
    END

    IF RECORD.ID[1,4] = 'PDCA' THEN     ;* CI_10041992 S
        OUT.O.DATA = "PD.CAPTURE"
    END   ;* CI_10041992 E


    IF APPLN.ID = 'MG' AND RECORD.ID['.',2,1] NE '' THEN
        OUT.O.DATA = "MG.PAYMENT"
    END

    EB.Reports.setOData(OUT.O.DATA)

    RETURN
*******************************************
PROCESS.CQ:
****************
    BEGIN CASE

        CASE RECORD.ID[1,2] = 'TT'
            OUT.O.DATA = "TELLER"

        CASE RECORD.ID[1,2] = 'FT'
            OUT.O.DATA = "FUNDS.TRANSFER"

        CASE 1
            OUT.O.DATA = 'CHEQUE.ISSUE'

    END CASE

    RETURN
*-----------------------------------------------------------------------------
    END
