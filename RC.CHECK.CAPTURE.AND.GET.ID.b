* @ValidationCode : MjotMTQ0MjY4Njg5OkNwMTI1MjoxNTgxNTAxMDA0MDAxOnJ2YXJhZGhhcmFqYW46MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMi4yMDIwMDExNy0yMDI2OjUxOjI3
* @ValidationInfo : Timestamp         : 12 Feb 2020 15:20:04
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rvaradharajan
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 27/51 (52.9%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202002.20200117-2026
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-67</Rating>
*-----------------------------------------------------------------------------
$PACKAGE RC.Capture
SUBROUTINE RC.CHECK.CAPTURE.AND.GET.ID(ENTRY.REC, HANDOFF.REC, RC.DETAIL.ID, CAPTURE.FLAG, RC.INFO)

* This routine first checks whether this entry or handoff needs to be capture.
* And then forms the RC.DETAIL id for the incoming arguments.
* It the required information from the incoming entry rec or handoff rec.
*
* The RC.DETAIL.ID structure would be:
* <settlement.account>DELIM
* <due.date>DELIM
* <eb.product.id>DELIM
* <eb.system.id or AA.PRODUCT.GROUP.id>DELIM
* <PROD.CATEGORY.CODE or AA.PRODUCT.id>DELIM
* <Unique serial number for Non-AA or bill reference for AA>
*
* Incoming:
**********
* ENTRY.REC - Entry in the format of STMT.ENTRY
* HANDOFF.REC - Record in the format of I_RC.HANDOFF
*
* Outgoing:
***********
* RC.DETAIL.ID - RC detail record id.
*
*-----------------------------------------------------------------------------
* Modifications:
****************
* 04/07/2013 - Enhancement -608301 / Task - 608303
*              New routine created.
*
* 10/12/2013 - Enhancement -694232 / Task - 709291
*              Routine is tuned to capture block funds
*
* 13/08/15 - SI 1368859 / Enh 1341985
* 			 Include the time into the RC.DETAIL id but only for those records
*            which came from the T24DDAServiceImpl.createManualReuqest for
*            external systems generating payment requests and who have an RC.TYPE
*            of AFCA
*
*
* 02/12/2020 - Enhancement 3569391 / Task 3569392
*               To get id for RC.DETAIL when there are multiple accounts for settlement
*-----------------------------------------------------------------------------

    $USING AC.EntryCreation
    $USING RC.Capture
    $USING EB.API
    $USING EB.SystemTables
    $USING RC.Interface

    GOSUB INITIALISE

    GOSUB CHECK.CAPTURE.ELIGIBILITY

    IF CAPTURE.FLAG EQ 'YES' THEN
        GOSUB GET.RC.DETAIL.ID
    END

RETURN
*-----------------------------------------------------------------------------
INITIALISE:
**********

    RC.DETAIL.ID = ''
    EB.SYSTEM.ID.LOC = ''
    LOCKING.ID = ''
    CAPTURE.FLAG = ''
    RC.INFO = ''
    SIGN.ON.COMPANY = EB.SystemTables.getIdCompany()
    RC.CAPTURE.ID = ''

    IF HANDOFF.REC THEN
        RC.CAPTURE.ID = HANDOFF.REC<RC.Interface.TransEbProductId>
    END ELSE
        RC.CAPTURE.ID = ENTRY.REC<AC.EntryCreation.StmtEntry.SteSystemId>[1,2]

* For entries raised for contracts(Ex: LD repayment..)
        IF ENTRY.REC<AC.EntryCreation.StmtEntry.SteCrfProdCat> THEN
            CATEGORY.VAL = ENTRY.REC<AC.EntryCreation.StmtEntry.SteCrfProdCat>
        END ELSE
            CATEGORY.VAL = ENTRY.REC<AC.EntryCreation.StmtEntry.SteProductCategory>
        END
    END



RETURN
*-----------------------------------------------------------------------------
CHECK.CAPTURE.ELIGIBILITY:
*************************

    CAPTURE.FLAG = ""
    RC.Capture.CaptureEntry(RC.CAPTURE.ID, ENTRY.REC, HANDOFF.REC, SIGN.ON.COMPANY, CAPTURE.FLAG, RC.INFO)

RETURN
*-----------------------------------------------------------------------------

GET.RC.DETAIL.ID:
****************

* The RC.DETAIL ID has 6 components.

    BEGIN CASE
        CASE  ENTRY.REC NE ''
* Form RC.DETAIL id. for capturing at entry level
            EB.SYSTEM.ID.LOC = ENTRY.REC<AC.EntryCreation.StmtEntry.SteSystemId>
* Non-AA transaction : <settlement.account>*<debit.date>*<eb.system.id>*<product.category>*<seq. number>
            LOCKING.ID = ENTRY.REC<AC.EntryCreation.StmtEntry.SteValueDate> : '*':EB.SYSTEM.ID.LOC[1,2] :'*': EB.SYSTEM.ID.LOC
            GOSUB GET.SEQ.NUM
            RC.DETAIL.ID = ENTRY.REC<AC.EntryCreation.StmtEntry.SteAccountNumber> : '*': LOCKING.ID : '*' : CATEGORY.VAL : '*' : SEQ.NUM

        CASE HANDOFF.REC NE ''
            IF HANDOFF.REC<RC.Interface.TransEbProductId> EQ 'AA' THEN
* Form RC.DETAIL id for capturing at application level
*For AA: <settlement.account>*<debit.date>*<eb.product.id>*<aa.product.group>*<aa.product>*<BILL.NO>
                RC.DETAIL.ID = HANDOFF.REC<RC.Interface.TransSettlementAccount,1>:'*':HANDOFF.REC<RC.Interface.TransValueDate>:'*':HANDOFF.REC<RC.Interface.TransEbProductId>:'*':HANDOFF.REC<RC.Interface.TransAaProdGroup>:'*':HANDOFF.REC<RC.Interface.TransAaProduct>:'*':HANDOFF.REC<RC.Interface.TransRef>
            END ELSE        ;*rc.detail.id created for blocked funds
                VALUE.DATE = HANDOFF.REC<RC.Interface.TransValueDate>
                IF LEN(HANDOFF.REC<RC.Interface.TransBookDate>) > 8 THEN          ;* take date and time from book date field. This previously unused field has been updated in AFCA.RC.HANDOFF with the time appended to the date for ACFA prioritisation
                    VALUE.DATE = HANDOFF.REC<RC.Interface.TransBookDate>
                END
                RC.DETAIL.ID = HANDOFF.REC<RC.Interface.TransSettlementAccount>:'*': VALUE.DATE :'*':HANDOFF.REC<RC.Interface.TransEbProductId>:'*':HANDOFF.REC< RC.Interface.TransEbSystemId>:'*': HANDOFF.REC<RC.Interface.TransCategory>:'*':HANDOFF.REC<RC.Interface.TransRef>
            END
    END CASE

RETURN
*-----------------------------------------------------------------------------
GET.SEQ.NUM:
*************

    TM = ''
    DT = DATE()
    EB.API.AllocateUniqueTime(TM)
    CONVERT "." TO "" IN TM
    SEQ.NUM = DT:TM


RETURN
*-----------------------------------------------------------------------------

END
