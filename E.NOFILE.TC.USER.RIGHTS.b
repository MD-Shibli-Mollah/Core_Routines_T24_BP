* @ValidationCode : MTotMTA2NjIzMDE4ODpVVEYtODoxNDY5NjI5Njg4Njk5OnJzdWRoYToxOjA6MDoxOmZhbHNlOk4vQQ==
* @ValidationInfo : Timestamp         : 27 Jul 2016 19:58:08
* @ValidationInfo : Encoding          : UTF-8
* @ValidationInfo : User Name         : rsudha
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*--------------------------------------------------------------------------------------------------------------------
    $PACKAGE   T2.ModelBank
    SUBROUTINE E.NOFILE.TC.USER.RIGHTS(FINAL.ARRAY)
*--------------------------------------------------------------------------------------------------------------------
* Description
*------------
* This routine used to validate license modules and user right operations
*
*---------------------------------------------------------------------------------------------------------------------
* Routine type       : Nofile
* Attached To        : STANDARD.SELECTION>NOFILE.TC.USER.RIGHTS
* IN Parameters      : NA
* Out Parameters     : FINAL.ARRAY
*                      TC.INITIAL, AALD.FLAG, CR.FLAG, PAYMENT.FLAG, LOCAL.CURRENCY, MF.FLAG, DX.FLAG, TC.OPERATION
*
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*---------------------
* 26/05/16 - Enhancement - 1694539 / Task - 1745220
*            TCIB16 Product Development
*
*---------------------------------------------------------------------------------------------------------------------
*
    $USING AA.Framework
    $USING AA.ARC
    $USING EB.ErrorProcessing
    $USING EB.SystemTables
    $USING ST.CompanyCreation
*
    GOSUB INTIALISE
    GOSUB PROCESS
    RETURN
*---------------------------------------------------------------------------------------------------------------------
INTIALISE:
*--------
** Initialise all variables
    DEFFUN System.getVariable()
    RETURN
*----------------------------------------------------------------------------------------------------------------------
PROCESS:
*------
*Get Home screen,Operations and LD,CR flag

    EXT.USER.ID = EB.ErrorProcessing.getExternalUserId();
    ARRANGEMENT.ID =  System.getVariable('EXT.ARRANGEMENT')
    IF ARRANGEMENT.ID NE 'EXT.ARRANGEMENT' THEN ;* Getting the Information from Arrangement User Rights
        PROP.CLASS = "USER.RIGHTS"
        TEMPLATE = ''
        PROPERTY = ''
        PROPERTY.DATE = ''
        BASE.ARR.REC = ''
        PROPERTY.RECORD = ''
        REC.ERR = ''
        GOSUB CHECK.PROPERTY.CONDITIONS ;* Check there is property conditions defined for User rights
        USER.RIGHT.REC = R.PROPERTY.CLASS.COND
        TC.INITIAL = USER.RIGHT.REC<AA.ARC.UserRights.UsrRgtTcInitial>
        TC.OPERATION = USER.RIGHT.REC<AA.ARC.UserRights.UsrRgtTcOperations>
    END
*
    IF TC.INITIAL NE '' THEN  ;* Get the TC.INITIAL value from channel permission
        GOSUB CHECK.SPF.PRD.LICENSE
        GOSUB CHECK.CR.INSTALLED
        LOCAL.CURRENCY = EB.SystemTables.getLccy()
        TC.OPERATION.ARRAY = TC.INITIAL:'*':AALD.FLAG:'*':CR.FLAG:'*':PAYMENT.FLAG:"*":LOCAL.CURRENCY:'*':MF.FLAG:'*':DX.FLAG

        IF TC.OPERATION NE '' THEN     ;* Get the TC.OPERATIONS first value and add in the final array
            TC.OPERATION.ARRAY = TC.INITIAL:'*':AALD.FLAG:'*':CR.FLAG:'*':PAYMENT.FLAG:"*":LOCAL.CURRENCY:"*":MF.FLAG:'*':DX.FLAG:'*':TC.OPERATION<1,1>
        END
    END
    FINAL.ARRAY<-1> = TC.OPERATION.ARRAY
*
    IF TC.OPERATION NE '' THEN
        TC.OPERATIONS.DCOUNT = DCOUNT(TC.OPERATION,@VM)
        FOR OPERATION.CNT = 2 TO TC.OPERATIONS.DCOUNT     ;* Get the remaining operation values and add in the final array
            FINAL.ARRAY<-1> = "*":"*":"*":"*":"*":"*":"*":TC.OPERATION<1,OPERATION.CNT>
        NEXT OPERATION.CNT
    END
    RETURN
*---------------------------------------------------------------------------------------------------------------------
CHECK.PROPERTY.CONDITIONS:
*------------------------
* Check whether there is property conditions that apply to arrangement
    R.PROPERTY.CLASS.COND = ""
    ARR.ID = ""
    NEW.ARRANGEMENT.ID = ARRANGEMENT.ID:'//AUTH'  ;*read the AUTH record directly
    AA.Framework.GetArrangementConditions(NEW.ARRANGEMENT.ID,PROP.CLASS,'','',ARR.ID,R.PROPERTY.CLASS.COND,ERR.MSG)
    EB.SystemTables.setEtext(ERR.MSG)
    R.PROPERTY.CLASS.COND = RAISE(R.PROPERTY.CLASS.COND)    ;* Raise the Position of the record
    RETURN
*--------------------------------------------------------------------------------------------------------------
CHECK.SPF.PRD.LICENSE:
*-------------------
*To check the LD,AL,AD,FT and PI modules in SPF
*
    SPF.PRODUCT = EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfProducts>    ;* Get the list of all product from spf
    CHANGE @VM TO @FM IN SPF.PRODUCT
*
    LOCATE 'LD' IN SPF.PRODUCT SETTING LD.POS THEN    ;* Locate the LD module in the list
    LD.FLAG  = 'LD'       ;* If LD moudle is available in SPF, then set the LD flag
    END
*
    LOCATE 'PI' IN SPF.PRODUCT SETTING PI.POS THEN       ;*Locate the PI module in the list
    PI.FLAG = 'PI'          ;* If PI module is available in SPF then set the PI flag
    END
*
    LOCATE 'FT' IN SPF.PRODUCT SETTING FT.POS THEN
    FT.FLAG = 'FT'          ;* If FT module is available in SPF then set the FT flag
    END
*
    LOCATE 'AL' IN SPF.PRODUCT SETTING AL.POS THEN
    AL.FLAG  = 'AL'
    END   ;*If AL moudle is available in SPF, then set the AL flag
*
    LOCATE 'AD' IN SPF.PRODUCT SETTING AD.POS THEN
    AD.FLAG  = 'AD'
    END   ;*If AD moudle is available in SPF, then set the AD flag
*
    LOCATE 'DX' IN SPF.PRODUCT SETTING DX.POS THEN
    DX.FLAG='DX'    ;*If DX module is present in SPF, then set the DX Flag
    END
*
    LOCATE 'MF' IN SPF.PRODUCT SETTING MF.POS THEN
    MF.FLAG='MF'    ;*If MF module is present in SPF, then set the MF Flag
    END
*
    BEGIN CASE
        CASE LD.FLAG AND (AL.FLAG OR AD.FLAG)
            AALD.FLAG = 'BOTH'    ;* Assign Both flag
        CASE LD.FLAG AND (AL.FLAG EQ '' OR AD.FLAG EQ '')
            AALD.FLAG = 'LD'      ;* Assign LD flag
        CASE LD.FLAG EQ '' AND (AL.FLAG OR AD.FLAG)
            AALD.FLAG = 'AA'      ;* Assign AA flag
    END CASE
*
    BEGIN CASE
        CASE PI.FLAG AND FT.FLAG
            PAYMENT.FLAG = 'BOTH'       ;*Assign both flag
        CASE PI.FLAG AND (FT.FLAG EQ '')
            PAYMENT.FLAG = 'PI'
        CASE FT.FLAG AND (PI.FLAG EQ '')
            PAYMENT.FLAG = 'FT'
    END CASE
*
    RETURN
*--------------------------------------------------------------------------------------------------------------
CHECK.CR.INSTALLED:
*-----------------
* To check CR product installed

    CR.INSTALLED = ''
    IF EB.SystemTables.getApplication() NE "BATCH" AND EB.SystemTables.getApplication() NE "TSA.SERVICE" THEN   ;*Don't do while installing the product.
        LOCATE 'CR' IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING CR.INSTALLED ELSE
        CR.INSTALLED = ''
    END
    IF CR.INSTALLED THEN
        CR.FLAG = "CR"
    END
    END

    RETURN
*---------------------------------------------------------------------------------------------------------------
    END
