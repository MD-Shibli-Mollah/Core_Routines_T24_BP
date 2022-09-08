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
* <Rating>-29</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AC.ModelBank

    SUBROUTINE E.MB.CONSTRUCT.ENTRY
*-----------------------------------------------------------------------------

*Description:
*    Conversion routine attached to enquiry NAU.FWD.ENTRY to convert VM to FM
*           inorder to display each entry as a row
*--------------------------------------------------------------------------------
* Version No: 1.0
* ------------------
*
* Change History
* --------------
*
*12-09-08 : BG_100019949
*          routine restructure
*
*----------------------------------------------------------------------------------


    $USING EB.Reports
    $USING AC.EntryCreation

    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN

INITIALISE:

*Initialise varaibles

    IN.RECORD = ""
    OUT.RECORD = ""
    COUNT.FM = ""
    COUNT.VM = ""

    RETURN

PROCESS:

* Get the hold record and count the number of entries.
* Form an array with entries stored as FM delimited and each fields as value delimited.

    IN.RECORD = EB.Reports.getRRecord()
    COUNT.FM = DCOUNT(IN.RECORD,@FM)
    IF EB.Reports.getFullFileName()[".",3,99] = "ENTRY.HOLD" THEN
        DEL IN.RECORD<COUNT.FM>         ;* Remove balance details
        COUNT.FM -= 1
    END

    FIELD.ID = AC.EntryCreation.StmtEntry.SteAccountNumber

    COUNT.VM = 1
    LOOP
    WHILE (COUNT.VM <= COUNT.FM)

        IF FIELD.ID <= AC.EntryCreation.StmtEntry.SteContractIntKey THEN
            OUT.RECORD<FIELD.ID,COUNT.VM> = IN.RECORD<COUNT.VM,FIELD.ID>
            FIELD.ID += 1
        END ELSE
            COUNT.VM += 1
            FIELD.ID = AC.EntryCreation.StmtEntry.SteAccountNumber
        END
    REPEAT

    EB.Reports.setRRecord(OUT.RECORD)
    EB.Reports.setVmCount(COUNT.FM)

    RETURN
*-----------------------------------------------------------------------------

    END
