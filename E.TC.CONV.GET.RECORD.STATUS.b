* @ValidationCode : MjoxOTU4NTA2ODc5OkNwMTI1MjoxNTUzMTg0MjUwODA3OmRtYXRlaToxOjA6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTAzLjE6MTY6MTU=
* @ValidationInfo : Timestamp         : 21 Mar 2019 18:04:10
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : dmatei
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 15/16 (93.7%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201903.1
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE EB.Channels
SUBROUTINE E.TC.CONV.GET.RECORD.STATUS
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
* 12/02/2019 - Enhancement 2875458 / Task 3025789 - Migration to IRIS R18
*
*-----------------------------------------------------------------------------
    $USING EB.Reports
    $USING EB.ARC
*-------------------------------------------------------------------------------
    GOSUB INITIALISE                  ;* Initialise variables
    GOSUB BUILD.OUTPUT ;* Build final output array
RETURN
*--------------------------------------------------------------------------------
*** <region name= INITIALISE>
*** <desc>Initialise the variables</desc>
INITIALISE:
    externalUserId = ''
    recordStatus = ''
	recExternalUserNAU = ''

RETURN
*** </region>
*--------------------------------------------------------------------------------
*** <region name= BUILD.OUTPUT>
*** <desc>build the output for the conversion routine</desc>
BUILD.OUTPUT:
* get the arrangement ID
    externalUserId = EB.Reports.getOData()

* read the NAU record for the current externalUser ID
	recExternalUserNAU = EB.ARC.ExternalUser.ReadNau(externalUserId, "")
* get the record status for the NAU record
	recordStatus = recExternalUserNAU<EB.ARC.ExternalUser.XuRecordStatus>
* set the output for the conversion routine
	IF recExternalUserNAU NE '' THEN
        EB.Reports.setOData(recordStatus)
	END ELSE
        EB.Reports.setOData("")
	END

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
