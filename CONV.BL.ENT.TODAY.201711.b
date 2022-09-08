* @ValidationCode : MjoxNjM4MzYwNzk2OkNwMTI1MjoxNTA3NTQ1MDU2OTgyOnNzdWdhbnRoaToyOjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTcxMC4yMDE3MDkxNS0wMDA4OjEzOjEz
* @ValidationInfo : Timestamp         : 09 Oct 2017 16:00:56
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ssuganthi
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 13/13 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201710.20170915-0008
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE BL.Foundation
SUBROUTINE CONV.BL.ENT.TODAY.201711(BL.ENT.ID,BL.ENT.REC,BL.ENT.FILE)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 01/08/17 - Task : 2217428
*            BL.ENT.TODAY record id to be modified.
*            Ref : 2212741
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING BL.Foundation
  
*-----------------------------------------------------------------------------

    BL.CNT = DCOUNT(BL.ENT.REC<BL.Foundation.EntToday.TdyEndDate>,@VM)
    IF BL.ENT.ID MATCHES '8N' THEN
        IF BL.ENT.ID EQ EB.SystemTables.getToday() THEN
            FOR BL.REG.CNT = 1 TO BL.CNT
                BL.ENT.TODAY.ID = BL.ENT.REC<BL.Foundation.EntToday.TdyEndDate><1,BL.REG.CNT>
                BL.ENT.TODAY.REC<1> = BL.ENT.ID
                BL.Foundation.EntToday.Write(BL.ENT.TODAY.ID, BL.ENT.TODAY.REC)
            NEXT BL.REG.CNT
            BL.Foundation.EntToday.Delete(BL.ENT.ID)
        END ELSE
            BL.Foundation.EntToday.Delete(BL.ENT.ID)
        END
    END
END
