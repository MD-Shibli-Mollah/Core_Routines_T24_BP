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
* <Rating>-77</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.MB.TXN.ENTRY.FILL
*
****************************************************************************
* Subroutine Type : Subroutine
* Attached to     : Enquiry TXN.ENTRY
* Purpose         : This subroutine is used by the TXN.ENTRY enquiry
*                   It is used to read in either a STMT.ENTRY or CATEG.ENTRY record whose
*                   id is passed in the O.DATA variable prefixed with 'S' for Statement
*                   entry or 'C' for Categ entry
*                   It will pass back in R.RECORD either the STMT.ENTRY or CATEG.ENTRY record
* @author         : Model Bank
*
*
* 01/11/95 - GB9501033
*            Read from supplied company mnemonic
*            format is ID*mnemonic
*
* 17/07/05 - BG_100009108
*            If the entries ( stmt or categ) are netted ,those
*            entries should be read from the STMT and CATEG.ENTRY.DETAIL
*            files. According to the type , the ids are
*            prefixed with T for Netted stmt entry, N for netted categ
*            entry and will pass back through O.DATA
****************************************************************************

    $USING AC.EntryCreation
    $USING ST.CompanyCreation
    $USING ST.Config
    $USING EB.DataAccess
    $USING AC.ModelBank
    $USING EB.SystemTables
    $USING EB.Reports

*
****************************************************************************
*
    ENT.ID = EB.Reports.getOData()["*",1,1]
    CO.MNEMONIC = EB.Reports.getOData()["*",2,1]
    SAVE.ID.COMPANY = EB.SystemTables.getIdCompany()
    IF CO.MNEMONIC THEN
        LEAD.MNE = ''
        ST.CompanyCreation.GetCompany(CO.MNEMONIC,"",LEAD.COMP.ID,LEAD.MNE)
        CO.MNEMONIC = LEAD.MNE
        IF LEAD.COMP.ID NE EB.SystemTables.getIdCompany() THEN
            ST.CompanyCreation.LoadCompany(LEAD.COMP.ID)
        END
    END
    IF ENT.ID[1,1] EQ 'S' THEN
        ENT.ID = ENT.ID[2,99]
        GOSUB READ.STMT.ENTRY
        STMT = 1
        EB.Reports.setRRecord(ENT.REC)
    END
    IF ENT.ID[1,1] EQ 'C' THEN
        ENT.ID = ENT.ID[2,99]
        GOSUB READ.CATEG.ENTRY
        STMT = 0
        EB.Reports.setRRecord(ENT.REC)
    END

    IF ENT.ID[1,1] EQ 'E' THEN
        ENT.ID = ENT.ID[2,99]
        GOSUB READ.CONSOL.ENTRY
    END

    IF ENT.ID[1,1] EQ 'R' THEN
        ENT.ID = ENT.ID[2,99]
        GOSUB READ.SPEC.ENTRY
    END

    IF ENT.ID[1,1] EQ 'D' THEN
        ENT.ID = ENT.ID[2,99]
        GOSUB READ.CONSOL.SPEC.ENTRY
    END

    IF EB.SystemTables.getIdCompany() NE SAVE.ID.COMPANY THEN
        ST.CompanyCreation.LoadCompany(SAVE.ID.COMPANY)
    END
    RETURN
*
****************************************************************************
*
READ.STMT.ENTRY:
*
*
    ENT.REC = ''
    ENT.REC = AC.EntryCreation.StmtEntry.Read(ENT.ID, ER)
    IF ER THEN
        ER = ''
        ENT.REC = AC.EntryCreation.StmtEntryDetail.Read(ENT.ID, ER)
        IF NOT(ER) THEN
            EB.Reports.setOData('T':ENT.ID);* Stmt entry id which is netted
        END
    END

*     Check for Booking Date to be today
    IF ENT.REC<AC.EntryCreation.StmtEntry.SteBookingDate> NE EB.SystemTables.getToday() THEN
        EB.Reports.setLine(EB.Reports.getLine() - 1)
    END
*
    RETURN
*
****************************************************************************
*
READ.CATEG.ENTRY:
*
    ENT.REC = ''
    ENT.REC = AC.EntryCreation.CategEntry.Read(ENT.ID, ER)
    IF ER THEN
        ER = ''
        ENT.REC = AC.EntryCreation.CategEntryDetail.Read(ENT.ID, ER)
        * Before incorporation : CALL F.READ("F.CATEG.ENTRY.DETAIL",ENT.ID,ENT.REC,F.CATEG.ENTRY.DETAIL,ER)
        IF NOT(ER) THEN
            EB.Reports.setOData('N':ENT.ID);* Categ entry id which is netted
        END
    END

*     Check for Booking Date to be today
    IF ENT.REC<AC.EntryCreation.CategEntry.CatBookingDate> NE EB.SystemTables.getToday() THEN
        EB.Reports.setLine(EB.Reports.getLine() - 1)
    END

    RETURN
*
****************************************************************************
*

READ.CONSOL.ENTRY:
    ENT.REC = ''
    ENT.REC = AC.EntryCreation.ConsolEntToday.Read(ENT.ID, ER)
*-- Inserting new condition for CONSOL entries
    CONSOL.PROD = ENT.REC<AC.EntryCreation.ConsolEntToday.ReCetProduct>
    BKG.DATE = ENT.REC<AC.EntryCreation.ConsolEntToday.ReCetBookingDate>

    IF CONSOL.PROD NE 'FT' AND CONSOL.PROD NE 'TT' AND CONSOL.PROD NE 'DC' THEN

        tmp=EB.Reports.getRRecord(); tmp<23>=ENT.REC<AC.EntryCreation.ConsolEntToday.ReCetTxnRef>; EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord(); tmp<11>=ENT.REC<AC.EntryCreation.ConsolEntToday.ReCetValueDate>; EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord(); tmp<25>=ENT.REC<AC.EntryCreation.ConsolEntToday.ReCetBookingDate>; EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord(); tmp<1>=ENT.REC<AC.EntryCreation.ConsolEntToday.ReCetType>; EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord(); tmp<8>=ENT.REC<AC.EntryCreation.ConsolEntToday.ReCetCustomer>; EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord(); tmp<12>=ENT.REC<AC.EntryCreation.ConsolEntToday.ReCetCurrency>; EB.Reports.setRRecord(tmp)
        IF ENT.REC<AC.EntryCreation.ConsolEntToday.ReCetForeignDr> THEN
            tmp=EB.Reports.getRRecord(); tmp<13>=ENT.REC<AC.EntryCreation.ConsolEntToday.ReCetForeignDr>; EB.Reports.setRRecord(tmp)
        END ELSE
            tmp=EB.Reports.getRRecord(); tmp<13>=ENT.REC<AC.EntryCreation.ConsolEntToday.ReCetForeignCr>; EB.Reports.setRRecord(tmp)
        END
        IF ENT.REC<AC.EntryCreation.ConsolEntToday.ReCetLocalDr> THEN
            tmp=EB.Reports.getRRecord(); tmp<3>=ENT.REC<AC.EntryCreation.ConsolEntToday.ReCetLocalDr>; EB.Reports.setRRecord(tmp)
        END ELSE
            tmp=EB.Reports.getRRecord(); tmp<3>=ENT.REC<AC.EntryCreation.ConsolEntToday.ReCetLocalCr>; EB.Reports.setRRecord(tmp)
        END
    END

*-- End of addition

    RETURN
**************************************************************************
READ.SPEC.ENTRY:

    ENT.REC = ''
    ENT.REC = AC.EntryCreation.ReSpecEntryDetail.Read(ENT.ID, ER)
* Before incorporation : CALL F.READ("F.RE.SPEC.ENTRY.DETAIL",ENT.ID,ENT.REC,F.SPEC.ENT.TODAY,ER)
    BKG.SPEC.DATE = ENT.REC<AC.EntryCreation.ReConsolSpecEntry.ReCseBookingDate>
    tmp=EB.Reports.getRRecord(); tmp<23>=ENT.REC<AC.EntryCreation.ReConsolSpecEntry.ReCseDealNumber>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<11>=ENT.REC<AC.EntryCreation.ReConsolSpecEntry.ReCseValueDate>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<25>=ENT.REC<AC.EntryCreation.ReConsolSpecEntry.ReCseBookingDate>; EB.Reports.setRRecord(tmp)
    TXN.CODE  = ENT.REC<AC.EntryCreation.ReConsolSpecEntry.ReCseTransactionCode>
    tmp=EB.Reports.getRRecord(); tmp<8>=ENT.REC<AC.EntryCreation.ReConsolSpecEntry.ReCseCustomerId>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<12>=ENT.REC<AC.EntryCreation.ReConsolSpecEntry.ReCseCurrency>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<13>=ENT.REC<AC.EntryCreation.ReConsolSpecEntry.ReCseAmountFcy>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<3>=ENT.REC<AC.EntryCreation.ReConsolSpecEntry.ReCseAmountLcy>; EB.Reports.setRRecord(tmp)
    ENT.TXN.REC = ""
    ENT.TXN.REC = AC.EntryCreation.ReTxnCode.Read(TXN.CODE, TXN.ER)
    tmp=EB.Reports.getRRecord(); tmp<1>=ENT.TXN.REC<AC.EntryCreation.ReTxnCode.ReTxnShortDesc>; EB.Reports.setRRecord(tmp)

    IF BKG.SPEC.DATE NE EB.SystemTables.getToday() THEN
        EB.Reports.setLine(EB.Reports.getLine() - 1)
    END

    RETURN
******************************************************************************
*
READ.CONSOL.SPEC.ENTRY:

    CONSOL.ENT.REC = ''
    CONSOL.ENT.REC = AC.EntryCreation.ReConsolSpecEntry.Read(ENT.ID, ER1)
* Before incorporation : CALL F.READ("F.RE.CONSOL.SPEC.ENTRY",ENT.ID,CONSOL.ENT.REC,F.CONSOL.SPEC.ENT.TODAY,ER1)
    BKG.SPEC.DATE = CONSOL.ENT.REC<AC.EntryCreation.ReConsolSpecEntry.ReCseBookingDate>
    tmp=EB.Reports.getRRecord(); tmp<23>=CONSOL.ENT.REC<AC.EntryCreation.ReConsolSpecEntry.ReCseDealNumber>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<11>=CONSOL.ENT.REC<AC.EntryCreation.ReConsolSpecEntry.ReCseValueDate>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<25>=CONSOL.ENT.REC<AC.EntryCreation.ReConsolSpecEntry.ReCseBookingDate>; EB.Reports.setRRecord(tmp)
    TXN.CODE  =  CONSOL.ENT.REC<AC.EntryCreation.ReConsolSpecEntry.ReCseTransactionCode>
    tmp=EB.Reports.getRRecord(); tmp<8>=CONSOL.ENT.REC<AC.EntryCreation.ReConsolSpecEntry.ReCseCustomerId>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<12>=CONSOL.ENT.REC<AC.EntryCreation.ReConsolSpecEntry.ReCseCurrency>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<13>=CONSOL.ENT.REC<AC.EntryCreation.ReConsolSpecEntry.ReCseAmountFcy>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<3>=CONSOL.ENT.REC<AC.EntryCreation.ReConsolSpecEntry.ReCseAmountLcy>; EB.Reports.setRRecord(tmp)
    ENT.TXN.REC = ""
    ENT.TXN.REC = AC.EntryCreation.ReTxnCode.Read(TXN.CODE, TXN.ER)
* Before incorporation : CALL F.READ("F.RE.TXN.CODE",TXN.CODE,ENT.TXN.REC,F.TXN,TXN.ER)
    tmp=EB.Reports.getRRecord(); tmp<1>=ENT.TXN.REC<AC.EntryCreation.ReTxnCode.ReTxnShortDesc>; EB.Reports.setRRecord(tmp)

    RETURN
*******************************************************************************
    END
