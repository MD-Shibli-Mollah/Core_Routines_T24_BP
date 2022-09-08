* @ValidationCode : Mjo0ODU0MDcwOkNwMTI1MjoxNTE4NjAxMzkxOTc1OmhhcnJzaGVldHRncjotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxODAxLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 14 Feb 2018 15:13:11
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : harrsheettgr
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201801.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE SW.Schedules
SUBROUTINE CONV.SWAP.SCHEDULES.SAVE.201803.SELECT
*-----------------------------------------------------------------------------
*
* Author: harrsheettgr@temenos.com
*-----------------------------------------------------------------------------
*
* Description: A new conversion is introduced to change the existing design of swap schedule save record
* As part of the change a multithreaded conversion job is introduced to carry out the conversion
* And the select routine performs the select of necessary files needed for conversion
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 10/01/18 - Enh 2388600  / Task 2388603
*            Swap schedule save structure change (Swap / SWUS) and Conversion
*
*-----------------------------------------------------------------------------
*** <region name= Inserts>
    
    $USING EB.DataAccess
    $USING EB.Service
    
    $INSERT I_DAS.SWAP
    
*** </region>
*-----------------------------------------------------------------------------
    
    GOSUB SelectInauSwap ; *Invokes DAS to fetch the INAU swap deals in the environment

RETURN
*-----------------------------------------------------------------------------
*** <region name= SelectInauSwap>
SelectInauSwap:
*** <desc>Invokes DAS to fetch the INAU swap deals in the environment </desc>
    
    ListParameters = ""
    ListParameters<2> = "F.SWAP$NAU"
    EB.Service.BatchBuildList(ListParameters,"")
    
RETURN
*** </region>
*-----------------------------------------------------------------------------

END

