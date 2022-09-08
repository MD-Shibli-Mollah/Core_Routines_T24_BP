* @ValidationCode : N/A
* @ValidationInfo : Timestamp : 19 Jan 2021 11:14:56
* @ValidationInfo : Encoding : Cp1252
* @ValidationInfo : User Name : N/A
* @ValidationInfo : Nb tests success : N/A
* @ValidationInfo : Nb tests failure : N/A
* @ValidationInfo : Rating : N/A
* @ValidationInfo : Coverage : N/A
* @ValidationInfo : Strict flag : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version : N/A
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-15</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE FX.Config
    SUBROUTINE CONV.FX.PARAMETERS.G14.0
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
*********************************************************************
* Modifications:
* --------------
*
* 04/06/03 - BG_100004342
*            Creation
*
* 30/07/03 - BG_100004905
*            Since the file FX.PARAMETERS is a INT level file, we need
*            not try to open it for each and every company.
*            Also stop the variable ETEXT from being set.
*
* 02/12/08 - BG_100021115
*            Rating reduction for FX.
*
**********************************************************************

** Subroutine reads ACCOUNT.CLASS records and adds them to the FX.PARAMETERS
** record. Any values in FX.REVAL.PARAMETERS are also added.
** The routine will delete the FX.REVAL.PARAMETERS record at the end
*
    F.ACCOUNT.CLASS = ""
    CALL OPF("F.ACCOUNT.CLASS", F.ACCOUNT.CLASS)
*
    F.COMPANY = ''
    CALL OPF("F.COMPANY", F.COMPANY)
*
** Store account class categories
*
    ACCOUNT.CLASS.ID.LIST = "RESFWDCR_RESFWDDR_RESSWAPCR_RESSWAPDR"
    CONVERT "_" TO FM IN ACCOUNT.CLASS.ID.LIST
    ACCOUNT.CLASS.CAT.LIST = "" ; CNT = ''
    LOOP
        CNT += 1
        REMOVE ACL.ID FROM ACCOUNT.CLASS.ID.LIST SETTING YD
    WHILE ACL.ID:YD
        READ ACL.REC FROM F.ACCOUNT.CLASS, ACL.ID ELSE
            ACL.REC = ''
        END
        ACCOUNT.CLASS.CAT.LIST<CNT> = ACL.REC<3,1>
    REPEAT
*
    F.FX.REVAL.PARAMETERS = ''
    CALL OPF("F.FX.REVAL.PARAMETERS", F.FX.REVAL.PARAMETERS)
*
** Get the reval parameter rec
*
    READ FX.REVAL.PARAM.REC FROM F.FX.REVAL.PARAMETERS, "SYSTEM" ELSE
        FX.REVAL.PARAM.REC = ''
    END
*
** Add the ACCOUNT.CLASS value to the fields in FX.PARAM
** Add the FX.REVAL.PARAM fields to the NEW fields in FX.PARAM
*
    ETEXT = ''
    F.FX.PARAMETERS = ''
    YF.FX.PARAMETERS = "F.FX.PARAMETERS":FM:"NO.FATAL.ERROR"
    CALL OPF(YF.FX.PARAMETERS, F.FX.PARAMETERS)
*
    IF NOT(ETEXT) THEN
        READU FX.PARAMS.REC FROM F.FX.PARAMETERS, "FX.PARAMETERS" THEN
            FX.PARAMS.REC<9> = ACCOUNT.CLASS.CAT.LIST<1>    ;* RESFWDCR
            FX.PARAMS.REC<10> = FX.REVAL.PARAM.REC<1>
            FX.PARAMS.REC<14> = ACCOUNT.CLASS.CAT.LIST<2>   ;* RESFWDDR
            FX.PARAMS.REC<15> = FX.REVAL.PARAM.REC<2>
            FX.PARAMS.REC<21> = ACCOUNT.CLASS.CAT.LIST<3>   ;* RESSWAPCR
            FX.PARAMS.REC<22> = FX.REVAL.PARAM.REC<3>
            FX.PARAMS.REC<27> = ACCOUNT.CLASS.CAT.LIST<4>   ;* RESSWAPDR
            FX.PARAMS.REC<28> = FX.REVAL.PARAM.REC<4>
            INS "SY_CONV.FX.PARAMETERS.G14.0" BEFORE FX.PARAMS.REC<37,1>
            WRITE FX.PARAMS.REC TO F.FX.PARAMETERS, "FX.PARAMETERS"
            DELETE F.FX.REVAL.PARAMETERS, "SYSTEM"
        END ELSE
            RELEASE F.FX.PARAMETERS, "FX.PARAMETERS"
        END
    END
*
    RETURN
*
END
