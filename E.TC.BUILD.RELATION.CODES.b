* @ValidationCode : MjoxMjA0OTk5MDY5OkNwMTI1MjoxNTI0MTM1ODE0Njk4OmthcnRoaWNrbToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxODAzLjA6MjA6MjA=
* @ValidationInfo : Timestamp         : 19 Apr 2018 14:03:34
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : karthickm
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 20/20 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201803.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------------------------------------------
$PACKAGE ST.Channels
SUBROUTINE E.TC.BUILD.RELATION.CODES(enqData)
*-----------------------------------------------------------------------------------------------------------------
* @author     :  lsilea@temenos.com
*-----------------------------------------------------------------------------------------------------------------
* Modification History :
*
* 26/01/18 - Defect 2452421 / Task 2535071
*            Build routine called from TC.RELATION.CODES enquiry
*            Reads from CHANNEL.PARAMETER all Relation Codes defined for CORPORATE.USER Relation Type
*
* 18/04/18 - Defect 2553358 / Task 2555422
*            Cant create Indirect User through TCUA application
*
*-----------------------------------------------------------------------------------------------------------------

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
    paramRelCodeList = ''

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

* Get the list of allowed Relation Codes as defined in CHANNEL.PARAMETER table
    channelParameterRec = EB.ARC.ChannelParameter.Read('SYSTEM', channelParameterErr )

* Get the list of 'CORPORATE.USER' relationship codes
    LOCATE 'CORPORATE.USER' IN channelParameterRec<EB.ARC.ChannelParameter.CprRelationType,1> SETTING paramRelCodePos THEN
        paramRelCodeList = CHANGE (channelParameterRec<EB.ARC.ChannelParameter.CprRelationCode, paramRelCodePos>, @SM, ' ')
    END

RETURN

*-----------------------------------------------------------------------------------------------------------------
FormSelection:
*-----------------------------------------------------------------------------------------------------------------

* Form the enquiry selection
    enqData<1,1> = 'TC.RELATION.CODES'
    enqData<2,1> = 'RELATION.CODE'
    enqData<3,1> = 'EQ'
    enqData<4,1> = paramRelCodeList
    
RETURN

END ;* Program end
