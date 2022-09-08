* @ValidationCode : MjotMTY5NDkyNTM2ODpDcDEyNTI6MTU0Mjc5MDkzMTYzODpyYXZpbmFzaDotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxODExLjIwMTgxMDIyLTE0MDY6LTE6LTE=
* @ValidationInfo : Timestamp         : 21 Nov 2018 14:32:11
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ravinash
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 4 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>98</Rating>
*-----------------------------------------------------------------------------
* Modification History
*
* 26/10/18 - Enhancement 2822523 / Task 2829963
*          - Incorporation of EB_Service component
*-----------------------------------------------------------------------------
$PACKAGE EB.Service
SUBROUTINE E.SELECT.BATCH.DATES(ENQ.ARG)
*
* Select routine for enquiry BATCH.DATES.
* loops through and calls E.BATCH.DATES for each batch record.
* If R.RECORD comes back and is not null then that batch record
* has an invalid run date.
*

    $INSERT I_COMMON
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.DATES
 
    FN.BATCH = 'F.BATCH'
    F.BATCH = ''
    CALL OPF(FN.BATCH, F.BATCH)

    NEXT.WORKING.DAY = R.DATES(EB.DAT.NEXT.WORKING.DAY)

    COMMAND = "SELECT F.BATCH"
    BATCH.LIST = ''
    CALL EB.READLIST(COMMAND, BATCH.LIST, '', '', '')
*
    LOOP
        REMOVE ID FROM BATCH.LIST SETTING BATCH.MARK
    WHILE ID : BATCH.MARK

*     READ RECORD AND BEGIN CHECK *

        READ R.RECORD FROM F.BATCH,ID
        ELSE R.RECORD = ''
        CALL E.BATCH.DATES
        IF R.RECORD <> '' THEN
            ENQ.ARG<-1> = ID
        END
    REPEAT
RETURN

END
