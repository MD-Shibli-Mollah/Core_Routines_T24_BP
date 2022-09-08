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
* <Rating>0</Rating>
*-----------------------------------------------------------------------------
************************************************************************
*
    $PACKAGE ST.ChargeConfig
    SUBROUTINE CONV.COND.PRIOR.REC.G13(ID,R.RECORD,YFILE)
*
********************************************************************
* CI_10003832 - 25/09/02
*               Record routine to correct the exiting records
* of the CONDITION.PRIORITY. to the revised priority position.
*
*
* 20/10/05 - CI_10035843
*              Used Field No instead of Names - problems during upgrade
*              from lower release directly to a much higher release.
*
*********************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CONDITION.PRIORITY
*
    IF R.RECORD<38> # "" THEN
        PRI.SEQ.CNT = DCOUNT(R.RECORD<38>,VM)
        FOR I = 1 TO PRI.SEQ.CNT
            IF R.RECORD<38,I> > 8 THEN
                R.RECORD<38,I> = R.RECORD<38,I> + 2
            END
        NEXT I
    END
    RETURN

END
*********************************************************************
