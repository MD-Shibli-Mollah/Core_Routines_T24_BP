* @ValidationCode : MDowOk4vQToxNjE2NjY2NjIwNzA4OnZlbG11cnVnYW46MDowOjA6MTpmYWxzZTpOL0E6Ti9BOjA6MA==
* @ValidationInfo : Timestamp         : 25 Mar 2021 15:33:40
* @ValidationInfo : Encoding          : N/A
* @ValidationInfo : User Name         : velmurugan
* @ValidationInfo : Nb tests success  : 0
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 0/0 (0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-29</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE VP.Config
    SUBROUTINE AML.SELECT.API(FILE.NAME, R.DW.EXPORT, RET.LIST)
*
*-----------------------------------------------------------------------------
*
* Modification History :
*
* 14\11\11 - Task 234981
*            AML Service.
*
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
*07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*
*-----------------------------------------------------------------------------
*
    $USING EB.DataAccess
    $USING VP.Config
    $INSERT I_DAS.AML.TXN.ENTRY
    $INSERT I_DAS.AML.TXN.ENTRY.NOTES
*
    GOSUB INITIALISE
    GOSUB BUILD.BASE.LIST
*
    RETURN
*
*-----------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialising variables goes here</desc>
*
INITIALISE:
***********
*
    RET.LIST = ''
*
    RETURN
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= BUILD.BASE.LIST>
*** <desc>Building list file</desc>
*
BUILD.BASE.LIST:
****************
*
    TABLE.NAME = 'AML.TXN.ENTRY'
    TABLE.SUFFIX = ''
    THE.ARGS = ''
    THE.LIST = 'ALL.IDS'
    EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
    RET.LIST = THE.LIST
*
    RETURN
*
*** </region>
*-----------------------------------------------------------------------------
    END
