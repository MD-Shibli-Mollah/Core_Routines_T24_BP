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
* <Rating>-7</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.ModelBank
    SUBROUTINE E.AA.SCHEMA.RECORD
*
** Enquiry routine to build stmt entry format record to display the accounting
** schema for a product.
** The routine will build R.RECORD in the format of a STMT entry. THis has been
** constructed by the routine AA.BUILD.ACCOUNTING.SCHEMA using the soft accounting
** tables

    $USING AC.EntryCreation
    $USING EB.Reports

*
    COMMON/AASCHEMA/SCHEMA.LIST
*
** Id is an index number
** Details of the activity, property, action and rule id used are in
** AA.ITEM.REF field
*
    ITEM.NO = EB.Reports.getOData()
    EB.Reports.setRRecord(RAISE(SCHEMA.LIST<ITEM.NO>))
    VMCOUNT = DCOUNT(EB.Reports.getRRecord()<AC.EntryCreation.StmtEntry.SteNarrative>,@VM)
*
    RETURN
    END
