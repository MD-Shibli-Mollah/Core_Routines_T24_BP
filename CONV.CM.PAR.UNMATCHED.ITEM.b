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
* <Rating>-24</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CM.Contract
    SUBROUTINE CONV.CM.PAR.UNMATCHED.ITEM(CM.PAR.UN.ITEM.ID, R.CM.PAR.UN.ITEM, Y.FILE)
******************************************************************************
* Conversion for CM.PAR.UNMATCHED.ITEM. Earlier the structure of this file is
* that there will be n number of delivery id's w.r.t. message key. Now it is
* an ID only file. i.e., the ID of this file will be like this:
* MESSAGE.ID||PARTIAL.MATCH.KEY.
******************************************************************************
* Modification History:
*
* 09/12/09 - EN_10004452 / Defect: 18713
*            SAR Ref:2009-09-22-0002
*            Conversion routine for CM.PAR.UNMATCHED.ITEM
*            1. If more than one MESSAGE.KEY exists then, form the new ID as
*            MESSAGE.KEY||Incoming.ID for all the messages and perform write.
*            2. If the MESSAGE.KEY list contains only one id, then change the
*            Incoming ID as MESSAGE.KEY||Incoming.ID and return with a blank
*            record and write will happen in core.
*
******************************************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
    CHK.ID.FMT = INDEX(CM.PAR.UN.ITEM.ID, '||', 1)
    IF CHK.ID.FMT THEN
        RETURN
    END
*    
    GOSUB INITIALISE
    GOSUB UPDATE.CM.PAR.UNMATCH
*
    RETURN
*
******************************************************************************
INITIALISE:
******************************************************************************
*
    F.CM.PAR.UNMATCHED.ITEM = ''
    FN.CM.PAR.UNMATCHED.ITEM = 'F.CM.PAR.UNMATCHED.ITEM'
    CALL OPF(FN.CM.PAR.UNMATCHED.ITEM, F.CM.PAR.UNMATCHED.ITEM)

    Y.CM.PAR.UN.ITEM.ID = ''
    Y.CM.PAR.UN.ITEM.REC = ''
    
    DELETE F.CM.PAR.UNMATCHED.ITEM, CM.PAR.UN.ITEM.ID       ;* Delete the original
    CM.PAR.UN.ITEM.COUNT = DCOUNT(R.CM.PAR.UN.ITEM<1>,VM)   ;* Get the count of total message ID
*
    RETURN
*
******************************************************************************
UPDATE.CM.PAR.UNMATCH:
******************************************************************************
*
    FOR ITEM.POS = 1 TO CM.PAR.UN.ITEM.COUNT
        IF ITEM.POS EQ CM.PAR.UN.ITEM.COUNT THEN  ;* We don't write this record now, will be updated in conversion.details.run
            CM.PAR.UN.ITEM.ID = R.CM.PAR.UN.ITEM<1,ITEM.POS>:'||':CM.PAR.UN.ITEM.ID
            R.CM.PAR.UN.ITEM = ''
        END ELSE
            Y.CM.PAR.UN.ITEM.ID = R.CM.PAR.UN.ITEM<1,ITEM.POS>:'||':CM.PAR.UN.ITEM.ID
            WRITE Y.CM.PAR.UN.ITEM.REC TO F.CM.PAR.UNMATCHED.ITEM, Y.CM.PAR.UN.ITEM.ID    ;* Write it now
        END
    NEXT ITEM.POS
*
    RETURN
*
END
