* @ValidationCode : MTotMTk5MjgyNDE4NjpjcDEyNTI6MTQ3MDIyNDAyNjg1OTpja2lyYW46LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxNjA4LjA=
* @ValidationInfo : Timestamp         : 03 Aug 2016 17:03:46
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : ckiran
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201608.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-------------------------------------------------------------------------
* <Rating>-11</Rating>
*-------------------------------------------------------------------------
* Modification History:
* ---------------------
* 04/06/15 - EN-1322379 / Tak-1328842
*            Incorporation of DX_ModelBank
*
* 02/08/16 - Defect 1813941 / Task 1813947
*            USR.FLD.NAME is not defaulted when exotic type is defined.
*
*--------------------------------------------------------------------------
    $PACKAGE DX.ModelBank
    SUBROUTINE E.DX.USER.FLD.UPD

    $USING DX.Trade
    $USING DX.Configuration
    $USING EB.SystemTables

    GOSUB POPULATE.VALUE
    RETURN

POPULATE.VALUE:
    DX.TRADE.ID = EB.SystemTables.getIdNew()
    DX.OPTION.TYPE.ID = EB.SystemTables.getRNew(DX.Trade.Trade.TraExoticType)
    R.DX.OPTION.TYPE = ""
    YERR = ''
    R.DX.OPTION.TYPE = DX.Configuration.OptionType.Read(DX.OPTION.TYPE.ID, YERR)
    COUNT.FLD = DCOUNT(R.DX.OPTION.TYPE<DX.Configuration.OptionType.OtUsrFldName>,@VM)
     FOR I = 1 TO COUNT.FLD
        tmp.AV = EB.SystemTables.getAv()
        tmp=EB.SystemTables.getRNew(DX.Trade.Trade.TraUsrFldName); tmp<1,tmp.AV,I>=R.DX.OPTION.TYPE<DX.Configuration.OptionType.OtUsrFldName,I>; EB.SystemTables.setRNew(DX.Trade.Trade.TraUsrFldName, tmp)
        tmp=EB.SystemTables.getRNew(DX.Trade.Trade.TraUsrFldText); tmp<1,tmp.AV,I>=R.DX.OPTION.TYPE<DX.Configuration.OptionType.OtUsrFldText,I>; EB.SystemTables.setRNew(DX.Trade.Trade.TraUsrFldText, tmp)
        tmp=EB.SystemTables.getRNew(DX.Trade.Trade.TraUsrFldPrice); tmp<1,tmp.AV,I>=R.DX.OPTION.TYPE<DX.Configuration.OptionType.OtUsrFldPrice,I>; EB.SystemTables.setRNew(DX.Trade.Trade.TraUsrFldPrice, tmp)
        tmp=EB.SystemTables.getRNew(DX.Trade.Trade.TraUsrFldVal); tmp<1,tmp.AV,I>=DX.TRADE.ID;EB.SystemTables.setRNew(DX.Trade.Trade.TraUsrFldVal, tmp)
    
     NEXT I  

    RETURN
    END
