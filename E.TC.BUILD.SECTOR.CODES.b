* @ValidationCode : MjoxNDc2NDA2OTUxOkNwMTI1MjoxNTIyODM5MzM4MjkzOmxzaWxlYTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE4MDMuMTotMTotMQ==
* @ValidationInfo : Timestamp         : 04 Apr 2018 13:55:38
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : lsilea
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201803.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
$PACKAGE ST.Channels
SUBROUTINE E.TC.BUILD.SECTOR.CODES(enqData)
*-----------------------------------------------------------------------------
* @author     :  lsilea@temenos.com
*-----------------------------------------------------------------------------
* Modification History :
*
* 26/01/18 - Defect 2452421 / Task 2535071
*            Build routine called from TC.SECTOR.CODES enquiry
*            Reads the Sector codes defined in CHANNEL.PARAMETER
*-----------------------------------------------------------------------------
    $USING EB.ARC

    GOSUB Initialise
    GOSUB Process

RETURN

*-----------------------------------------------------------------------------------------------------------------
Initialise:
*-----------------------------------------------------------------------------------------------------------------

* Initialise all

    channelParameterRec = ''
    channelParameterErr = ''
    paramSectorCodeList = ''

RETURN

*-----------------------------------------------------------------------------------------------------------------
Process:
*-----------------------------------------------------------------------------------------------------------------

    GOSUB BuildCodesList
    GOSUB FormSelection

RETURN

*-----------------------------------------------------------------------------------------------------------------
BuildCodesList:
*-----------------------------------------------------------------------------------------------------------------

* Get the list of allowed Sector Codes as defined in CHANNEL.PARAMETER table
    channelParameterRec = EB.ARC.ChannelParameter.Read('SYSTEM', channelParameterErr )

    paramSectorCodeList = CHANGE (channelParameterRec<EB.ARC.ChannelParameter.CprExtUserSector>, @VM, ' ')

RETURN

*-----------------------------------------------------------------------------------------------------------------
FormSelection:
*-----------------------------------------------------------------------------------------------------------------

* Form the enquiry selection
    enqData<1,1> = 'TC.SECTOR.CODES'
    enqData<2,1> = 'SECTOR.CODE'
    enqData<3,1> = 'EQ'
    enqData<4,1> = paramSectorCodeList
    
RETURN

END ;* Program end
