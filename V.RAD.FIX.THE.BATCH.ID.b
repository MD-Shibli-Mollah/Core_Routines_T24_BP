* @ValidationCode : Mjo5MzQ4MDg5MTI6Q3AxMjUyOjE1NDI3OTQxNDcyOTM6cG1haGE6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTgxMS4yMDE4MTAyMi0xNDA2Oi0xOi0x
* @ValidationInfo : Timestamp         : 21 Nov 2018 15:25:47
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : pmaha
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>99</Rating>
*-----------------------------------------------------------------------------
$PACKAGE EB.Updates
SUBROUTINE V.RAD.FIX.THE.BATCH.ID
*
* Subroutine attached to version record BATCH,BUILD.CONTROL as ID.RTN
* to change the '#' in the ID, to '/'. BUILD.CONTROL (more specifically
* BCON.AUTHORISE.DL.RESTORE) would change '/' in the BATCH id, to '#'.
* So does OFS.AUTO.FUNCTION.MANAGER.
*
* OFS would nt support '/' in the ID and hence this workaround.
*===================================================================
* Modification History:
*
* 22/SEP/2006 - Naveen U.M.
*               Make this routine support to applications DE.TRANSLATION and TSA.SERVICE
**
* 12/11/18 - Enhancement 2822523 / Task 2850296
*          - Incorporation of EB_Updates component
*===================================================================
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_XML.EQUATE

*    IF APPLICATION NE 'BATCH' THEN RETURN ;* 22/SEP/2006 - Naveen s
    IF APPLICATION MATCHES NOT('BATCH':@VM:'DE.TRANSLATION':@VM:'TSA.SERVICE') THEN RETURN  ;* 22/SEP/2006 - Naveen e

    IF ID.NEW THEN
        ID.NEW = CHANGE(ID.NEW,'#','/')
    END ELSE
        COMI = CHANGE(COMI,'#','/')
    END

RETURN
END
