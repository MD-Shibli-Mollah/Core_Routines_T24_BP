* @ValidationCode : MjotODYxODY5MzU2OkNwMTI1MjoxNTQzNDk3ODkyMDkyOnNiaGFyYXRoaToxOjA6MDotMTpmYWxzZTpOL0E6REVWXzIwMTgxMC4yMDE4MDkyMS0xMTMwOjE2OjE2
* @ValidationInfo : Timestamp         : 29 Nov 2018 18:54:52
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sbharathi
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 16/16 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201810.20180921-1130
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE VL.Config
SUBROUTINE VL.AML.TIMESTAMP
**********************************************************************
* Routine to populate AML.TIMESTAMP local field in FOREX application with system time. When we receive multiple responses from AML,
* T24 should act only on the latest response of the transaction. To achieve this time stamp component will be
* sent to AML during the request mapping.
*
*******************************************************************************************
* 27/11/2018 - Creation of new Routine
*
*************************************************************************************************
    $USING EB.SystemTables
    $USING EB.API
    $USING VL.Config
    $USING EB.LocalReferences

    AML.POS = ''
    AMLTIMESTAMP = ''
    SS.REC = ''
    tmpLocRef = ''
    
*Get the current application name
    APPL = EB.SystemTables.getApplication()

    
* Get the standard selection record for the calling application
    EB.API.GetStandardSelectionDets(APPL, SS.REC )

    LOCATE "LOCAL.REF" IN SS.REC<EB.SystemTables.StandardSelection.SslSysFieldName,1> SETTING FLD.POS THEN
        AMLTIMESTAMP = SS.REC<EB.SystemTables.StandardSelection.SslSysFieldNo,FLD.POS,1>
    END

        
*To fetch the local reference field AML.TIMESTAMP
   
    EB.LocalReferences.GetLocRef(APPL,'AML.TIMESTAMP',AML.POS)
*Setting R.NEW and sending the time stamp value to the request would be done only when AML.POS is set. If client does not setup for local reference then it will be having null or negative value.
    IF AML.POS NE '' THEN
        tmpLocRef = EB.SystemTables.getRNew(AMLTIMESTAMP)
        tmpLocRef<1,AML.POS> = TIMESTAMP()
        EB.SystemTables.setRNew(AMLTIMESTAMP,tmpLocRef)
    END
RETURN
 

    
    
END
