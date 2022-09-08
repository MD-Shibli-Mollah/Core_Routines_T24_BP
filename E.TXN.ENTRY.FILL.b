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
* Version 3 25/10/00  GLOBUS Release No. 200511 31/10/05
*
****************************************************************************
*
    $PACKAGE AC.ModelBank

    SUBROUTINE E.TXN.ENTRY.FILL
*
****************************************************************************
*
* This subroutine is used by the TXN.ENTRY enquiry.
* It is used to read in either a STMT.ENTRY or CATEG.ENTRY record whose
* id is passed in the O.DATA variable prefixed with 'S' for Statement
* entry or 'C' for Categ entry.
*
* It will pass back in R.RECORD either the STMT.ENTRY or CATEG.ENTRY
* record.
*
* 01/11/95 - GB9501033
*            Read from supplied company mnemonic
*            format is ID*mnemonic
*
* 08/04/05 - CI_10029072
*            get correct lead comany mnemonic
*
* 17/07/05 - BG_100009095
*            If the entries ( stmt or categ) are netted ,those
*            entries should be read from the STMT and CATEG.ENTRY.DETAIL
*            files. According to the type , the ids are
*            prefixed with T for Netted stmt entry, N for netted categ
*            entry and will pass back through O.DATA.
*
****************************************************************************
*
    $USING EB.SystemTables
    $USING EB.Reports
    $USING ST.CompanyCreation
    $USING AC.EntryCreation
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
    END ELSE
        ENT.ID = ENT.ID[2,99]
        GOSUB READ.CATEG.ENTRY
        STMT = 0
    END

    EB.Reports.setRRecord(ENT.REC)

    IF EB.SystemTables.getIdCompany() NE SAVE.ID.COMPANY THEN
        ST.CompanyCreation.LoadCompany(SAVE.ID.COMPANY)
    END

    RETURN
*
****************************************************************************
*
READ.STMT.ENTRY:
*
    ENT.REC = ''
    ENT.REC = AC.EntryCreation.StmtEntry.Read(ENT.ID, ER)
* Before incorporation : CALL F.READ("F.STMT.ENTRY",ENT.ID,ENT.REC,F.STMT.ENTRY.PATH,ER)
    IF ER THEN
        ER = ''
        ENT.REC = AC.EntryCreation.StmtEntryDetail.Read(ENT.ID, ER)
* Before incorporation : CALL F.READ("F.STMT.ENTRY.DETAIL",ENT.ID,ENT.REC,F.STMT.ENTRY.DETAIL.PATH,ER)
        IF NOT(ER) THEN
            EB.Reports.setOData('T':ENT.ID); * Stmt entry id which is netted
        END
    END

    RETURN
*
****************************************************************************
*
READ.CATEG.ENTRY:
*
    ENT.REC = ''
    ENT.REC = AC.EntryCreation.CategEntry.Read(ENT.ID, ER)
* Before incorporation : CALL F.READ("F.CATEG.ENTRY",ENT.ID,ENT.REC,F.CATEG.ENTRY.PATH,ER)
    IF ER THEN
        ER = ''
        ENT.REC = AC.EntryCreation.CategEntryDetail.Read(ENT.ID, ER)
* Before incorporation : CALL F.READ("F.CATEG.ENTRY.DETAIL",ENT.ID,ENT.REC,F.CATEG.ENTRY.DETAIL.PATH,ER)
        IF NOT(ER) THEN
            EB.Reports.setOData('N':ENT.ID); * Categ entry id which is netted
        END
    END

    RETURN
*
****************************************************************************
*
    END
