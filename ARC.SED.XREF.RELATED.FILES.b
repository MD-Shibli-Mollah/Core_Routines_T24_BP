* @ValidationCode : MjoxMzI1MjM2NDk6Q3AxMjUyOjE1Mjc1MTEyNTQwMTA6c2hpdmFrdW1hcnM6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTgwNS4yMDE4MDQxOC0xMzU1Oi0xOi0x
* @ValidationInfo : Timestamp         : 28 May 2018 18:10:54
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : shivakumars
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201805.20180418-1355
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-39</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.Archiving
SUBROUTINE ARC.SED.XREF.RELATED.FILES(ID.SED.XREF,R.STMT.ENTRY.DETAIL.XREF,SPARE.3,SPARE.2,SPARE.1)
*<<----------------------------------------------------------------------------->>
*   DESCRIPTION:
* <<------------>>
*  1. As STATEMENT archival processing is non-genric, we cannot attach routines in RELATED.FILES.RTN field. But as per the
*     the new requirement we do archival of STMT.ENTRY.DETAIL.XREF along with STMT.ENTRY. So we need to handle RELATED.FILES.RTN
*     logic for STMT.ENTRY.DETAIL.XREF. This routine does that.
*  2. This can be modified to call the local routines which client desires to attach in RELATED.FILES.RTN field for archiving
*     files related to STMT.ENTRY.DETAIL.XREF. And if segmentation is enabled, this is to archive STMT.ENTRY.DETAIL and not XREF.
**<<----------------------------------------------------------------------------->>
*  Incoming Arguments:
*<<------------------>>
*   ID.SED.XREF = STMT.ENTRY.DETAIL.XREF id. Or it will be STMT.ENTRY.DETAIL id, if segmentation is enabled.
*   R.STMT.ENTRY.DETAIL.XREF / BLANK  = STMT.ENTRY.DETAIL.XREF record. It will be empty if segmentation is enabled.
*                                       i.e. If segmentation is set, read STMT.ENTRY.DETAIL record within this routine
*                                       as it will not be passed by core archiving process.
*<<----------------------------------------------------------------------------->>
*   Modification History:
*<<----------------------->>
* 09/04/15 - Defect 1298679 / Task 1311405
*            Introducing new routine to call the routies related to archival of STMT.ENTRY.DETAIL.XREF files.
*
* 12/04/18 - SI_2433304 / EN_2444024 / Task_2444185
*            Modified to cater for segmentation
*<<----------------------------------------------------------------------------->>
* Inserts.
*
*<<----------------------------------------------------------------------------->>
*** Archival process.
*
    $USING EB.Archiving

RETURN
*<<----------------------------------------------------------------------------->>

END
