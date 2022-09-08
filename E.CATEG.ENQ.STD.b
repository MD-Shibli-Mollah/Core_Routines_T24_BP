* @ValidationCode : MjotNTY4ODI4OTQzOmNwMTI1MjoxNjE1NDE0ODkyMjM0OmJjYXBvb3J2YTozOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTAzLjIwMjEwMzAxLTA1NTY6Njg6NjU=
* @ValidationInfo : Timestamp         : 11 Mar 2021 03:51:32
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : bcapoorva
* @ValidationInfo : Nb tests success  : 3
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 65/68 (95.5%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.20210301-0556
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


* Version 5 25/10/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-39</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank
 
SUBROUTINE E.CATEG.ENQ.STD
* GB9600621 display message here.
***********************************************************************
*               MODIFICATION LOG
*               ----------------
* 14/25/96 - GB9600621
*            Display a message during the build process.
*
* 17/01/05 - CI_10026361
*            Indefinite looping due to wrong condn check - recitified.
*
* 28/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
* 27/09/16 - Defect 1856468 / Task 1873343
*            Due to the componentisation the routine E.CATEG.ENQ.STD is overwriting the old entry ids,
*            instead of appending with existing ID, Code changed to correct the same
*
* 14/01/17 - Defect 1902802 / Task 2019865
*            Common variable OFS$ENQ.KEYS is reassigned to Zero if no record selected for the enquiry output.
*
* 03/03/21 - Defect 4254726 / Task 4261810
*             The Balances at Period Start is showing wrong balance in Enquiry CATEG.ENT.BOOK.STD output.
*
***********************************************************************

    $USING EB.Reports
    $USING EB.SystemTables
    $USING AC.EntryCreation
    $USING EB.OverrideProcessing

    EB.SystemTables.setMessage('CALCULATING OPENING BALANCE')
    tmp.MESSAGE = EB.SystemTables.getMessage()
    EB.OverrideProcessing.DisplayMessage(tmp.MESSAGE,3)

MAIN.PARA:
*=========
*
* Select file to be read
*
    KEY.LIST = EB.Reports.getId():@FM:EB.Reports.getEnqKeys()
    EB.Reports.setEnqKeys(""); * Build list of keys for enquiry
    EB.Reports.setPreviousCeRec(""); EB.Reports.setYrMthBal("")
    IF NOT(EB.Reports.getYendDate()) THEN
        EB.Reports.setYendDate(EB.Reports.getYstartDate())
    END
*
* Read the correct record and store in R.RECORD
*
    YEND = ""
    OPEN.BAL = 0
        
    LOOP
        REMOVE Y.ID FROM KEY.LIST SETTING YD
    UNTIL Y.ID = "" OR YEND
        GOSUB READ.FILE
        BEGIN CASE
            CASE Y.ID[1,7] = "PLCLOSE" AND EB.Reports.getEnqKeys() = ""     ; * Ignore
*
            CASE EB.Reports.getRRecord()<AC.EntryCreation.CategEntry.CatBookingDate> LT EB.Reports.getYstartDate()
                IF EB.Reports.getYcurrencyPos() THEN
                    OPEN.BAL += EB.Reports.getRRecord()<AC.EntryCreation.CategEntry.CatAmountFcy>
                    EB.Reports.setYcatOpenBal(OPEN.BAL)
                END ELSE
                    OPEN.BAL += EB.Reports.getRRecord()<AC.EntryCreation.CategEntry.CatAmountLcy>
                    EB.Reports.setYcatOpenBal(OPEN.BAL)
                END
            CASE EB.Reports.getRRecord()<AC.EntryCreation.CategEntry.CatBookingDate> LE EB.Reports.getYendDate()  ; * Good record
                IF EB.Reports.getEnqKeys() THEN
                    EB.Reports.setEnqKeys(EB.Reports.getEnqKeys():@FM:Y.ID)
                END ELSE
                    EB.Reports.setEnqKeys(Y.ID)
                END
            CASE 1                       ; * After enquiry period
                YEND = 1
        END CASE
    REPEAT
    EB.Reports.setOData(EB.Reports.getYcatOpenBal())
    EB.Reports.setYrunningBal(EB.Reports.getYcatOpenBal()); * Set the running balance to the opening
    tmp=EB.Reports.getPreviousCeRec(); tmp<AC.EntryCreation.CategEntry.CatBookingDate>=EB.Reports.getYstartDate(); EB.Reports.setPreviousCeRec(tmp); * Set to ensure correct break
*
    tmp.ENQ.KEYS = EB.Reports.getEnqKeys()
    IF NOT(tmp.ENQ.KEYS) THEN
*
** Set up a dummy record for use in the enquiry to show no entries
*
        EB.Reports.setId('DUMMY.ID':EB.SystemTables.getTno())
        EB.Reports.setRRecord('')
        tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.CategEntry.CatPlCategory>=EB.Reports.getYCatNo(); EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.CategEntry.CatCurrency>=EB.Reports.getYccy(); EB.Reports.setRRecord(tmp)
        tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.CategEntry.CatBookingDate>=EB.Reports.getYendDate(); EB.Reports.setRRecord(tmp)
        EB.Reports.setOfsEnqKeys(0)  ;* Common variable is reassigned to Zero if no record selected for the enquiry output.
    END ELSE
        Y.ID = EB.Reports.getEnqKeys()<1>
        GOSUB READ.FILE
        EB.Reports.setId(Y.ID)
        tmp = EB.Reports.getEnqKeys()
        DEL tmp<1>
        EB.Reports.setEnqKeys(tmp)
        EB.Reports.setOfsEnqKeys(DCOUNT(EB.Reports.getEnqKeys(),@FM)+1)
    END
*
* GB9600621 Now clear out the message
*
    EB.SystemTables.setMessage(' ')
    tmp.MESSAGE = EB.SystemTables.getMessage()
    EB.OverrideProcessing.DisplayMessage(tmp.MESSAGE, '3')
*
RETURN
*
READ.FILE:
*=========
*
    R.CATEG.ENTRY = AC.EntryCreation.tableCategEntry(Y.ID, ERR)
    EB.Reports.setRRecord(R.CATEG.ENTRY)
    IF ERR THEN
        tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.CategEntry.CatBookingDate>=99999999; EB.Reports.setRRecord(tmp)
    END

    IF EB.Reports.getRRecord()<AC.EntryCreation.CategEntry.CatCurrency> MATCHES "":@VM:EB.SystemTables.getLccy() THEN
        tmp=EB.Reports.getRRecord(); tmp<AC.EntryCreation.CategEntry.CatAmountFcy>=EB.Reports.getRRecord()<AC.EntryCreation.CategEntry.CatAmountLcy>; EB.Reports.setRRecord(tmp); * makes calculation easier
    END

RETURN
*-----------------------------------------------------------------------------
*
END
