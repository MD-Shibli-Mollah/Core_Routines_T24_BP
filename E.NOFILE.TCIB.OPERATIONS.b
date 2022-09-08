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
* <Rating>-91</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE T2.ModelBank
    SUBROUTINE E.NOFILE.TCIB.OPERATIONS(Y.FINAL.ARRAY)
*--------------------------------------------------------------------------------------------------------------------
* Routine type       : Nofile
* Attached To        : STANDARD.SELECTION>NOFILE.TCIB.BEN.LIST.AI
* Purpose            : This routine used to get the role operations from arrangemnt/channel permissions
*---------------------------------------------------------------------------------------------------------------------
* Modification History
*--------------------
*
* 15/01/14 - Enhancement - 696313/Task - 696344
*            TCIB-Corporate- Phase1- Webservice to expose Role based functionalities
*
* 28/05/14 - Enhancement 920989/Task 988778
*            TCIB : Retail (Loans and Deposits)
*
* 04/07/14 - Enhancement 1007033 / Task 1035684
*            Show CR opportunities for TCIB customers
*
* 08/07/14 - Enhancement 920989 / Task 1032322
*            TCIB : Retail (Loans and Deposits) - LD licensing has checked agianst LD,AL,AD products.
*
* 08/07/14 - Enhancement 1001222 / Task 1001223
*            TCIB User management, removed existing Non AA user flow
*
* 14/07/15 - Enhancement 1326996 / Task 1399946
*			 Incorporation of T components
*
* 07/01/16 - Enhancement 1572530 / Task
*			 POA Integration in TCIB
*
* 5/02/16 - Defect 1495552 / Task 1503738
*			 TCIB : Retail - MF and DX products checked
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

    Y.EXT.ID = EB.ErrorProcessing.getExternalUserId();
    ARRANGEMENT.ID =  System.getVariable('EXT.ARRANGEMENT')
    IF ARRANGEMENT.ID NE 'EXT.ARRANGEMENT' THEN
        * Getting the Information from Arrangement User Rights
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
        Y.ARRAY = TC.INITIAL:'*':AALD.FLAG:'*':CR.FLAG:'*':PAYMENT.FLAG:"*":LOCAL.CURRENCY:'*':MF.FLAG:'*':DX.FLAG  

        IF TC.OPERATION NE '' THEN     ;* Get the TC.OPERATIONS first value and add in the final array
            Y.ARRAY = TC.INITIAL:'*':AALD.FLAG:'*':CR.FLAG:'*':PAYMENT.FLAG:"*":LOCAL.CURRENCY:"*":MF.FLAG:'*':DX.FLAG:'*':TC.OPERATION<1,1>
        END
    END
    Y.FINAL.ARRAY<-1> = Y.ARRAY
*
    IF TC.OPERATION NE '' THEN
        TC.OPERATIONS.DCOUNT = DCOUNT(TC.OPERATION,@VM)
        FOR YR.V1 = 2 TO TC.OPERATIONS.DCOUNT     ;* Get the remaining operation values and add in the final array
            Y.FINAL.ARRAY<-1> = "*":"*":"*":"*":"*":"*":"*":TC.OPERATION<1,YR.V1>
        NEXT YR.V1
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
    Y.SPF.PRODUCT = EB.SystemTables.getRSpfSystem()<EB.SystemTables.Spf.SpfProducts>    ;* Get the list of all product from spf
    CHANGE @VM TO @FM IN Y.SPF.PRODUCT
*
    LOCATE 'LD' IN Y.SPF.PRODUCT SETTING Y.PROD.POS THEN    ;* Locate the LD module in the list
    LD.FLAG  = 'LD'       ;* If LD moudle is available in SPF, then set the LD flag
    END
*
    LOCATE 'PI' IN Y.SPF.PRODUCT SETTING Y.PIPOS THEN       ;*Locate the PI module in the list
    PI.FLAG = 'PI'			;* If PI module is available in SPF then set the PI flag
    END
*
    LOCATE 'FT' IN Y.SPF.PRODUCT SETTING Y.FTPOS THEN
    FT.FLAG = 'FT'			;* If FT module is available in SPF then set the FT flag
    END
*
    LOCATE 'AL' IN Y.SPF.PRODUCT SETTING Y.PROD.POS THEN
    AL.FLAG  = 'AL'
    END   ;*If AL moudle is available in SPF, then set the AL flag
*
    LOCATE 'AD' IN Y.SPF.PRODUCT SETTING Y.PROD.POS THEN
    AD.FLAG  = 'AD'
    END   ;*If AD moudle is available in SPF, then set the AD flag
*
    LOCATE 'DX' IN Y.SPF.PRODUCT SETTING POS THEN
        DX.FLAG='DX'	;*If DX module is present in SPF, then set the DX Flag
    END
*
    LOCATE 'MF' IN Y.SPF.PRODUCT SETTING POS1 THEN
        MF.FLAG='MF'	;*If MF module is present in SPF, then set the MF Flag
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
