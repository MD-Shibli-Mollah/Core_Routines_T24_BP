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

* Version 3 16/02/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-3</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PD.ModelBank
    SUBROUTINE E.PD.BALANCES.CHECK
**************************************************************************
*
* This routine is used by the PD balance enquiry to determine the PD
* amount type and the associated value. This subroutine needs to determine
* the PD amount type ie. PRincipal, INterest, PEnalty Interest and
* PS (PEnalty interest spread). Additionally, CHarges, COmmission and
* TX (Tax amounts) will be accummulated into an 'OTHER' bucket.
*
* Incoming : O.DATA (contains AMT.TYPE and CURR.OS.AMT attributes)
* Outgoing : O.DATA (contains amounts for PR, IN, PE, PS and OTHER)
*
* 30/09/97 - GB9701100
*
**************************************************************************

    $USING EB.Reports
    $USING PD.Config

*  determine which bucket amounts fall into and build O.DATA accordingly

    PD.AMOUNT.TYPES = EB.Reports.getRRecord()<PD.Config.Balances.BalAmtType>
    PD.OVERDUE.AMTS = EB.Reports.getRRecord()<PD.Config.Balances.BalCurrOsAmt>
    NO.OF.BUCKETS = DCOUNT(PD.AMOUNT.TYPES,@VM)
    ENQUIRY.DATA = ''

    FOR V$LOOP = 1 TO NO.OF.BUCKETS
        BUCKET.TYPE = PD.AMOUNT.TYPES<1,V$LOOP>[1,2]
        OVERDUE.AMOUNT = PD.OVERDUE.AMTS<1,V$LOOP>

        BEGIN CASE
            CASE BUCKET.TYPE = 'PR'      ; * principal
                VALUE = 1
            CASE BUCKET.TYPE = 'IN'      ; * interest
                VALUE = 2
            CASE BUCKET.TYPE = 'PE'      ; * penalty interest
                VALUE = 3
            CASE BUCKET.TYPE = 'PS'      ; * penalty spread
                VALUE = 4
            CASE 1                       ; * others (see above)
                VALUE = 5
        END CASE

        ENQUIRY.DATA<1,VALUE> += OVERDUE.AMOUNT
    NEXT V$LOOP

    ENQUIRY.DATA<1,6> = SUM(ENQUIRY.DATA<1>)

    tmp=EB.Reports.getRRecord(); tmp<PD.Config.Balances.BalCurrOsAmt>=ENQUIRY.DATA; EB.Reports.setRRecord(tmp)

    RETURN
    END
