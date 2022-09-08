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
* <Rating>-47</Rating>
*-----------------------------------------------------------------------------

    $PACKAGE RE.ConsolidationRegeneration
    SUBROUTINE CONV.REGEN.AC.PL.R07
*______________________________________________________________________________________
*
* This conversion routine is generic routine to remove the obsolete the batch processes
* for REGEN processes as it is now being multi-threaded, For example, REGEN.CRF.ACCOUNT
* and REGEN.CRF.PRFT.LOSS are now multi-threaded, which have to be removed.
*______________________________________________________________________________________
*
* Modification logs:
* -----------------
* 27/07/06 - GLOBUS_BG_100012474
*            New routine
*
* 23/11/06 - GLOBUS_BG_100012388
*            Below REGEN batch records added to remove from batch.
*            REGEN.CRF.MM, REGEN.CRF.LD, REGEN.CRF.PD, REGEN.CRF.SC.
*
* 26/04/07 - EN_10003317
*            MG to update EB.CONTRACT.BALANCES
*
* 13/06/07 - EN_10003355
*            MD to update EB.CONTRACT.BALANCES
*
* 16/09/07 - CI_10051520 /REF: HD0716424
*            Modified routine for removing RE.RECREATE.ACCOUNT related PGM files too.
*
* 30/10/07 - EN_10003508/Ref:SAR-2007-03-08-0002
*            LC to update EB.CONTRACT.BALANCES.
*
* 02/10/07 - BG_100015641
*            FX to update ECB. Changes done to remove the REGEN.CRF.FOREX
*            as this will now done generically thro RE.REGEN.REQUEST.
*
* 19/11/07 - BG_100015917
*            Batch TX.TI.END.OF.DAY need to be removed as it is marked OB
*
* 10/12/07 - BG_100016236
*            TX.TI.END.OF.DAY removed from here and added in CONV.DELETE.OB.BATCHES.R08
*______________________________________________________________________________________
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
*______________________________________________________________________________________
*
*** <region name= Main Process>

*--   Just add the obsolete regen batch process here to remove if it exists
*--   in the upgraded area.
    OB.BATCH.LIST = 'REGEN.CRF.ACCOUNT':@FM:'REGEN.CRF.PRFT.LOSS':@FM:'REGEN.CRF.MM':@FM:'REGEN.CRF.MD'
    OB.BATCH.LIST := @FM:'REGEN.CRF.LD':@FM:'REGEN.CRF.PD':@FM:'REGEN.CRF.SC':@FM:'REGEN.CRF.MG':@FM:'REGEN.CRF.LC'
    OB.BATCH.LIST := @FM:'REGEN.CRF.FOREX'

    GOSUB INITIALISE          ;* Initialise and open files here

    SEL.CMD = 'SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ "N"'
    COMPANY.LIST = ''
    CALL EB.READLIST(SEL.CMD, COMPANY.LIST ,'' , '' , '')

    LOOP
        REMOVE OB.PROCESS.ID FROM OB.BATCH.LIST SETTING OB.POS
    WHILE OB.PROCESS.ID:OB.POS DO

*--      In case, it is single company area, delete it here itself.
        CALL F.DELETE(FN.BATCH, OB.PROCESS.ID)

        IDX = 0
        LOOP
            IDX += 1
            COMP.ID = COMPANY.LIST<IDX>
        WHILE COMP.ID DO

            R.COMP = '' ; YERR = ''
            CALL F.READ(FN.COMPANY, COMP.ID, R.COMP, F.COMPANY, YERR)
            COMP.MNE = R.COMP<EB.COM.MNEMONIC>

*--         In case, multi-company area, form BATCH process id with company mnemonic.
            BATCH.ID = COMP.MNE:'/':OB.PROCESS.ID

*--         Delete the batch process record.
            CALL F.DELETE(FN.BATCH, BATCH.ID)

        REPEAT
    REPEAT

*--      Delete the related PGM files

    CALL F.DELETE(FN.PGM.FILE,'RE.RECREATE.ACCOUNT')
    CALL F.DELETE(FN.PGM.FILE,'RE.RECREATE.AC')
    CALL F.DELETE(FN.PGM.FILE,'RE.RECREATE.ALL')
    CALL F.DELETE(FN.PGM.FILE,'RE.RECREATE.AL')

    RETURN
*** </region>
*______________________________________________________________________________________
*
*** <region name= INITIALISE>
INITIALISE:
*----------

    FN.COMPANY = 'F.COMPANY'
    F.COMPANY = ''
    CALL OPF(FN.COMPANY, F.COMPANY)

    FN.BATCH = 'F.BATCH'
    F.BATCH = ''
    CALL OPF(FN.BATCH, F.BATCH)

    FN.PGM.FILE = 'F.PGM.FILE'
    F.PGM.FILE = ''
    CALL OPF(FN.PGM.FILE,F.PGM.FILE)

    RETURN
*** </region>
*______________________________________________________________________________________

END
