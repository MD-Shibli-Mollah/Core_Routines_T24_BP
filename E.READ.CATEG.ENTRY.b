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

* Version 2 25/10/00  GLOBUS Release No. G11.0.00 29/06/00
*-----------------------------------------------------------------------------
* <Rating>-18</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.READ.CATEG.ENTRY
*-----------------------------------------------------------------------------
*
** This subroutine is used in CATEG.ENT.BOOK.STD to extract the
** correct amount depending on which currency is specified in the
** selection criteria. If a currency is defined use the foreign
** amount, if not use local. Always put the amount in the foreign
** amount field.
** A running balance is also kept
** Also where a record is keyed PLCLOSE update the amount with the
** ooposite of the current running balance. This is the amount
** required to close out PL for that year.
*
*-----------------------------------------------------------------------------
*
    $USING AC.EntryCreation
    $USING AC.ModelBank
    $USING EB.SystemTables
    $USING EB.Reports


    PREVIOUS.BAL = EB.Reports.getYrunningBal()        ; * Store balance
    IF EB.Reports.getRRecord()<AC.EntryCreation.CategEntry.CatValueDate> = "" AND EB.Reports.getRRecord()<AC.EntryCreation.CategEntry.CatTransactionCode> THEN
        tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.CategEntry.CatValueDate>=EB.Reports.getRRecord()<AC.EntryCreation.CategEntry.CatBookingDate>; EB.Reports.setRRecord(tmp);* Only set for real entry
    END
*
    IF EB.Reports.getRRecord()<AC.EntryCreation.CategEntry.CatCurrency> MATCHES "":@VM:EB.SystemTables.getLccy() THEN   ; * Always have a foreign amount
        tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.CategEntry.CatAmountFcy>=EB.Reports.getRRecord()<AC.EntryCreation.CategEntry.CatAmountLcy>; EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.CategEntry.CatCurrency>=EB.SystemTables.getLccy(); EB.Reports.setRRecord(tmp)
    END
*
** If the enquiry has crossed a different financial year then
** reset balance to zero
*
    YRMTH = EB.Reports.getRRecord()<AC.EntryCreation.CategEntry.CatBookingDate>[1,6]
    YRMTH.PREV = EB.Reports.getPreviousCeRec()<AC.EntryCreation.CategEntry.CatBookingDate>[1,6]
    IF YRMTH NE YRMTH.PREV AND YRMTH.PREV THEN
        LOCATE YRMTH.PREV IN EB.Reports.getYrMthBal()<1,1> BY "AR" SETTING YPOS ELSE
        NULL
    END
    tmp=EB.Reports.getYrMthBal(); tmp<1,YPOS>=YRMTH.PREV; EB.Reports.setYrMthBal(tmp); * Store previous month end
    tmp=EB.Reports.getYrMthBal(); tmp<2,YPOS>=EB.Reports.getYrunningBal(); EB.Reports.setYrMthBal(tmp); * Store abalance at month end
    LOCATE YRMTH IN EB.Reports.getYearStartDates()<1> SETTING YPOS THEN
    EB.Reports.setYrunningBal(0)
    END
    END
*
    IF EB.Reports.getYcurrencyPos() THEN
        TOT.BAL = EB.Reports.getYrunningBal() + EB.Reports.getRRecord()<AC.EntryCreation.CategEntry.CatAmountFcy>
        EB.Reports.setYrunningBal(TOT.BAL)
    END ELSE                           ; * Enquiries always look at AMOUNT.FCY
        tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.CategEntry.CatCurrency>=EB.SystemTables.getLccy(); EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.CategEntry.CatAmountFcy>=EB.Reports.getRRecord()<AC.EntryCreation.CategEntry.CatAmountLcy>; EB.Reports.setRRecord(tmp)
        TOT.BAL = EB.Reports.getYrunningBal() + EB.Reports.getRRecord()<AC.EntryCreation.CategEntry.CatAmountLcy>
        EB.Reports.setYrunningBal(TOT.BAL)
    END
*
    EB.Reports.setPreviousCeRec(EB.Reports.getRRecord()); * Store for next time
    tmp=EB.Reports.getPreviousCeRec(); tmp<AC.EntryCreation.CategEntry.CatAmountFcy>=PREVIOUS.BAL; EB.Reports.setPreviousCeRec(tmp)
*
    RETURN
*-----------------------------------------------------------------------------
    END
