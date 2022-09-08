* @ValidationCode : MjoxMTYyOTEzMjE0OmNwMTI1MjoxNDkyMDg1MjE4NTQzOmRpdnlhbGFrc2htaXY6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTcwMS4wOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Apr 2017 17:36:58
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : divyalakshmiv
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201701.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

    $PACKAGE RE.IFConfig
    SUBROUTINE CONV.RE.FIN.DETAILS.PARAM.201612(ReDfParamId)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*
** 27/01/2017 - Defect 1998062 / Task 2000448
**              For better naming convention RE.DF.PARAMETER is renamed to RE.FIN.DETAILS.PARAM
**              RE.DF.PARAMETER table is made obsolete.
*-----------------------------------------------------------------------------
    $USING RE.IFConfig
    $USING EB.DataAccess
    $USING AC.EntryCreation

*-----------------------------------------------------------------------------
    GOSUB INITIALISE
    GOSUB PROCESS

    RETURN
*-----------------------------------------------------------------------------
INITIALISE:
*---------
    FnReDfParamVal = AC.EntryCreation.getFnReDfParameter()
    FReDfParamVal = AC.EntryCreation.getFReDfParameter()
    FnReFinDetailsParamVal = AC.EntryCreation.getFnReFinDetParam()
    FReFinDetailsParamVal = AC.EntryCreation.getFReFinDetParam()

    RETURN
*-----------------------------------------------------------------------------
PROCESS:
*------

    ReDfParamRec = ''

    EB.DataAccess.FReadu(FnReDfParamVal,ReDfParamId,ReDfParamRec,FReDfParamVal,Retry,DfParamErr)

    IF ReDfParamRec THEN
        EB.DataAccess.FWrite(FnReFinDetailsParamVal,ReDfParamId,ReDfParamRec)
        EB.DataAccess.FDelete(FnReDfParamVal, ReDfParamId)
    END

    RETURN
*-----------------------------------------------------------------------------
    END
