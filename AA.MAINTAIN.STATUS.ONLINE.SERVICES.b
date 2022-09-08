* @ValidationCode : MjoxNzAxMjUzNjIzOkNwMTI1MjoxNTcxNzM3Mzg3NTU2OnN1ZGhhcmFtZXNoOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkxMC4yMDE5MDkyMC0wNzA3Oi0xOi0x
* @ValidationInfo : Timestamp         : 22 Oct 2019 15:13:07
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sudharamesh
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201910.20190920-0707
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

    $PACKAGE AO.Framework
    SUBROUTINE AA.MAINTAIN.STATUS.ONLINE.SERVICES(ARRANGEMENT.ID, ACTIVITY.ID, EFFECTIVE.DATE)
*-----------------------------------------------------------------------------
* This routine updates the ARR.STATUS field in AA.ARRANGEMENT for Online Services products
* based on the Activity on different stage.
*
*-----------------------------------------------------------------------------
* Modification History:
*
* 03/10/16 - Enhancement 1812222 / Task 1905849
*            Tc Permissions property class
*
*  21/10/19 - Enhancement : 2851854
*             Task : 3396231
*             Code changes has been done as a part of AA to AF Code segregation
*-----------------------------------------------------------------------------
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>
* Inserts
    $USING EB.SystemTables
    $USING AA.Framework
    $USING AO.Framework
    $USING AF.Framework

*** </region>
*------------------------------------------------------------------------------
*** <region name= Main control>
*** <desc>Main Process in the sub-routine</desc>

    GOSUB INITIALISE
    GOSUB DO.PROCESS

    RETURN
***</region>
*------------------------------------------------------------------------------
*** <region name= Initialisation section>
*** <desc>Routine specific local variables are initialised here</desc>
INITIALISE:
*
    R.ARRANGEMENT = ''
    RET.ERROR = ''
    AAA.STATUS = AF.Framework.getC_arractivitystatus()
    R.ARRANGEMENT = AA.Framework.getRArrangement()    ;* Arrangement record
*
    RETURN
***</region>
*------------------------------------------------------------------------------
*** <region name= Status Check>
*** <desc>Check for the status of Arrangement ACtivity </desc>
DO.PROCESS:
*
    BEGIN CASE
        CASE AAA.STATUS EQ 'UNAUTH'
            GOSUB UNAUTH.STATUS.UPDATE
        CASE AAA.STATUS EQ 'AUTH'
            GOSUB AUTH.STATUS.UPDATE
        CASE AAA.STATUS EQ 'AUTH-REV'
            GOSUB REV.STATUS.UPDATE
    END CASE
*
    RETURN
***</region>
*------------------------------------------------------------------------------
*** <region name= Unauth Status>
*** <desc>Update UNAUTH</desc>
UNAUTH.STATUS.UPDATE:
*
    IF ACTIVITY.ID EQ 'NEW' THEN
        R.ARRANGEMENT<AA.Framework.Arrangement.ArrArrStatus> = 'UNAUTH'
        GOSUB WRITE.ARRANGEMENT
    END
*
    RETURN
***</region>
*------------------------------------------------------------------------------
*** <region name= Auth Status>
*** <desc>Update AUTH</desc>
AUTH.STATUS.UPDATE:
*
    IF ACTIVITY.ID EQ 'NEW' THEN
        IF EFFECTIVE.DATE LE EB.SystemTables.getToday() THEN ;*for the current date
            R.ARRANGEMENT<AA.Framework.Arrangement.ArrArrStatus> = 'AUTH'
        END ELSE    ;*for the future date
            R.ARRANGEMENT<AA.Framework.Arrangement.ArrArrStatus> = 'AUTH-FWD'
        END
        GOSUB WRITE.ARRANGEMENT
    END
*
    IF EFFECTIVE.DATE LE EB.SystemTables.getToday() AND R.ARRANGEMENT<AA.Framework.Arrangement.ArrArrStatus> = 'AUTH-FWD' THEN
        R.ARRANGEMENT<AA.Framework.Arrangement.ArrArrStatus> = 'AUTH'
        GOSUB WRITE.ARRANGEMENT
    END
*
    RETURN
***</region>
*------------------------------------------------------------------------------
*** <region name= Reverse Status>
*** <desc>Update Reverse</desc>
REV.STATUS.UPDATE:
*
    R.ARRANGEMENT<AA.Framework.Arrangement.ArrArrStatus> = 'REVERSED' ;*Reversed Status
    GOSUB WRITE.ARRANGEMENT
*
    RETURN
***</region>
*------------------------------------------------------------------------------

*** <region name= Update Arranegment>
*** <desc>Write the updated AA.ARRANGEMENT record</desc>
WRITE.ARRANGEMENT:
*
    AA.Framework.ArrangementWrite(ARRANGEMENT.ID,R.ARRANGEMENT,"")
*
    RETURN
***</region>
*------------------------------------------------------------------------------
    END
