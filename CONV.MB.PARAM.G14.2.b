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
* <Rating>-43</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ST.CompanyCreation
    SUBROUTINE CONV.MB.PARAM.G14.2
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_FIN.TO.INT.COMMON
*--------------------------------------------------------------------
* Modification:
* 27/01/04 - BG_100006039
*            Conversion has been modified with the calling program
*            EB.CONV.PARAM.FIN.TO.INT
*
* 13/04/04 - CI_10018968
*            Changes done to include SL.PARAMETER in Single Parameter
*            Populate List
* 07/07/04 - BG_100006909
*            Changes in CI_10018968 is reverted
*
* 10/09/04 - CI_10023000
*            Product for LMM.INSTALL.CONDS passed as LD which is now
*            changed now to LM. For RE.LMM.INSTALL.CONDS changed to RE.
*
* 26/10/04 - CI_10024205
*            PORTFOLIO.CONSTRAINT table is populated with DICT values
*            after upgrade.
*
* 05/10/05 - BG_100009521
*            Changes done to include SC.GROUP.PARAM in MULIT param list.
*
* 02/02/06 - CI_10038634
*            SL.TXN.CODES is changed from FIN to INT type file
*
* 10/05/06 - CI_10041032
*            Changes done in CI_10038634 is reversed. New conversion routine
*            is introduced for SL.TXN.CODES since this generic conversion
*            is not a re-runnable.
*------------------------------------------------------------------------
    GOSUB INITIALISE
    GOSUB POPULATE.PARAM.LIST
    GOSUB PROCESS.CONVERSION
    RETURN
*----------
INITIALISE:
*----------
    PARAM.LIST = ''  ; ID.TYPE = '' ; FILE.NAME = ''
    F.COMPANY = '' ; FN.COMPANY = ''
    F.COMPANY.CHECK = '' ; FN.COMPANY.CHECK = ''
    COMPANY.LIST = ''
    MASTER.COMPANY.ID = '' ; MASTER.MNE = ''
    RETURN
*
*-------------------
POPULATE.PARAM.LIST:
*-------------------
* ID.TYPE =        The id format for the records
*==============================================================================================
*'SINGLE' - The records would be created with id COMPANY.
*           This is recommended for files which have one
*           record in the parameter file
*==============================================================================================
    PARAM.LIST:= 'TELLER.PARAMETER*SINGLE*TT':FM
    PARAM.LIST:= 'MG.PARAMETER*SINGLE*MG':FM
    PARAM.LIST:= 'LC.PARAMETERS*SINGLE*LC':FM
    PARAM.LIST:= 'NR.PARAMETER*SINGLE*NR':FM
    PARAM.LIST:= 'DG.PARAMETER*SINGLE*DG':FM
    PARAM.LIST:= 'LMM.INSTALL.CONDS*SINGLE*LM':FM:'RE.LMM.INSTALL.CONDS*SINGLE*RE':FM
    PARAM.LIST:= 'AM.WORK.FILES*SINGLE*AM':FM
*================================================================================================
* 'MULTI' - The records would be appended with id COMPANY for all
*           companies except master company with String Id.
*           The records having the id as 'SYSTEM' would be converted
*           into Company Code
*================================================================================================
    PARAM.LIST:= 'SAVINGS.PREMIUM*MULTI*AC':FM:'IC.CHARGE.PRODUCT*MULTI*IC':FM
    PARAM.LIST:= 'PM.SC.PARAM*MULTI*PM':FM:'PM.POSN.REFERENCE*MULTI*PM':FM
    PARAM.LIST:= 'AZ.PRODUCT.PARAMETER*MULTI*AZ':FM:'AZ.SETTLEMENT.PRIORITY*MULTI*AZ':FM
    PARAM.LIST:= 'PD.PARAMETER*MULTI*PD':FM
    PARAM.LIST:= 'SC.VAL.PARAM*MULTI*SC':FM:'PORTFOLIO.CONSTRAINT*MULTI*SC':FM
    PARAM.LIST:= 'SC.GROUP.PARAM*MULTI*SC':FM
*
*=================================================================================================
* 'NOCHANGE' - The records would be created with the same id
*              If there are duplicate records in other companies - these will be appended
*              with the company id and kept on hold in other companies
*=================================================================================================
    PARAM.LIST:= 'ICA.HIERARCHY.PARAMETER*NOCHANGE*AC':FM:'NUMBER.OF.TXNS*NOCHANGE*IC':FM
    PARAM.LIST:= 'REVAL.ADDON.PERCEN*NOCHANGE*ST':FM:'EB.AF.PARAM.CHANGE*NOCHANGE*AC':FM:'STMT.NARR.PARAM*NOCHANGE*AC':FM:'GROUP.ACCRUAL.PARAM*NOCHANGE*AC':FM
    PARAM.LIST:= 'MI.STAT.DEFINITION*NOCHANGE*MI':FM:'MI.AUTO.MAPPING*NOCHANGE*MI':FM:'MI.UNIT.COST*NOCHANGE*MI':FM:'MI.STAT.TYPE*NOCHANGE*MI':FM
    PARAM.LIST:= 'AM.VAL.PARAMETER*NOCHANGE*AM'
    RETURN
*------------------
PROCESS.CONVERSION:
*------------------
*
* To get the File names to process
    LOOP
        REMOVE PARAM.FILE FROM PARAM.LIST SETTING END.OF.IDS
    WHILE PARAM.FILE
        FILE.NAME = FIELD(PARAM.FILE,'*',1)
        ID.TYPE = FIELD(PARAM.FILE,'*',2)
        PRODUCT.ID = FIELD(PARAM.FILE,'*',3)
        CALL EB.CONV.PARAM.FIN.TO.INT(FILE.NAME,ID.TYPE,PRODUCT.ID)
    REPEAT
    RETURN
END
