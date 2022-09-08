* @ValidationCode : MjotNTgzNTU4NjEwOmNwMTI1MjoxNTQxMDUwODM1OTYzOmthcnRoaWtleWFua2FuZGFzYW15Oi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTgwNy4yMDE4MDYyMS0wMjIxOi0xOi0x
* @ValidationInfo : Timestamp         : 01 Nov 2018 11:10:35
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : karthikeyankandasamy
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201807.20180621-0221
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 2 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>-11</Rating>
*-----------------------------------------------------------------------------
$PACKAGE SC.ScoReports
SUBROUTINE E.SC.PORT.MODEL.REC.COUNT
*************************************************************************
*
* A count of the number of records in the file SC.PORT.MODEL
*
*************************************************************************
*
* Modification History
*
* 22/02/07 - EN_10003206
*            Securities DAS Phase II (Product: SC)
*
* 12/02/15 - Defect:1250871 / Task: 1252690
*            !HUSHIT is not supported in TAFJ, hence changed to use HUSHIT().
*
* 31/10/18 -  Enhancement:2822501 Task:2826453
*             Componentization - II - Private Wealth
*************************************************************************
    $USING EB.DataAccess
    $USING SC.SctModelling
    $USING EB.SystemTables
    $USING EB.Reports

    $INSERT I_DAS.SC.PORT.MODEL

*******************************************

*******************************************
    REC.COUNT = 0
*
* select records in SC.PORT.MODEL
*
    EB.Reports.setOData('NO RECORDS')
    CALL HUSHIT(1)
            
    KEY.LIST           = EB.DataAccess.dasAllId ; * EN_10003206 S
    THE.ARGS           = ""
    DAS.TABLE.SUFFIX   = ""

    EB.DataAccess.Das('SC.PORT.MODEL', KEY.LIST, THE.ARGS, DAS.TABLE.SUFFIX)
    IF EB.SystemTables.getE() THEN
        KEY.LIST = ""
    END
      
    CALL HUSHIT(0)
      
    IF KEY.LIST NE '' THEN         ; * EN_10003206 E
*
* count the number of records in file - SC.PORT.MODEL
*
        REC.COUNT = DCOUNT(KEY.LIST,@FM)
*
* pass count to enquiry
*
        EB.Reports.setOData(REC.COUNT)
    END
END
