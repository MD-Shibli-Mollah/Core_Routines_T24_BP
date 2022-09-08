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

*-----------------------------------------------------------------------------------
* <Rating>-50</Rating>
*------------------------------------------------------------------------------------
	$PACKAGE T5.ModelBank
    SUBROUTINE E.MB.DX.BUILD.DATA.TCIB(ENQ.DATA)
*------------------------------------------------------------------------------------
* It is copy of E.MB.DX.BUILD.DATA core routine by using TCIB WEALTH and attached as
* BUILD.ROUTINE to TCIB.WEALTH.DX.FUT.PRICE.CHANGE Enquiry.
* @author mkeerthi@temenos.com
* INCOMING PARAMETER  - @Id which is customer no.
* OUTGOING PARAMETER  - ENQ.DATA
*------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* 17/02/2014 - Enhancement/Task_641974/927795
*              To Select the DX.MARKET.PRICE records based on the customer.
*
* 31/10/2014 - Defect-1147642/Task-1155693 
*              TCIB Wealth : Table alignment is not proper in my watch list.
*
* 14/07/15 - Enhancement 1326996 / Task 1399917
*	       Incorporation of T components	
*
* 24/12/2015 - Defect 1579021 / Task - 1580172
*              No records is displaying in Options & Futures under My Watchlist in Trading tab
*--------------------------------------------------------------------------------------

    $INSERT I_DAS.DX.REP.POSITION
    $INSERT I_DAS.DX.MARKET.PRICE
    $INSERT I_DAS.DX.CONTRACT.MASTER
    
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING EB.Reports
    $USING DX.Configuration
    $USING DX.Pricing
    $USING DX.Position
    
    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB PROCESS

    RETURN
*---------------------------------------------------------------------------------
INITIALISE:
*----------


* Initialise the Variables
	DEFFUN System.getVariable()
    RET.ARR = ''
    DX.CM.ID = ''
    DAS.TABLE.SUFFIX = ''
    THE.ARGS = ''
    EEU.CUSTOMER = System.getVariable("EXT.SMS.CUSTOMERS")  ;* get the Proxy customer id.
    CHANGE @SM TO ' ' IN EEU.CUSTOMER ;* Change SM to space

    RETURN
*-----------------------------------------------------------------------------
OPEN.FILES:
*----------
* Open the files
    FN.DX.REP = 'F.DX.REP.POSITION'
    F.DX.REP = ''
    EB.DataAccess.Opf(FN.DX.REP,F.DX.REP)
    RETURN
*-----------------------------------------------------------------------------
PROCESS:
********
*To Select the DX.MARKET.PRICE records based on the Customer.

    SEL.CMD = "SELECT ":FN.DX.REP:" WITH CUSTOMER EQ ":EEU.CUSTOMER   ;* Select the DX.REP.POSITION Records based on the Customer
    EB.DataAccess.Readlist(SEL.CMD,SEL.LIST,'',NO.OF.REC,ERR)
    IF SEL.LIST NE "" THEN
        LOOP
            REMOVE DX.CM.ID FROM SEL.LIST SETTING POS
        WHILE DX.CM.ID:POS
            R.DX.DEP = ''
            Y.DX.ERR = ''
            R.DX.DEP = DX.Position.RepPosition.Read(DX.CM.ID,Y.DX.ERR)
            Y.CONTRACT = R.DX.DEP<DX.Position.RepPosition.RpContract>
            Y.DX.MARKET.ID = R.DX.DEP<DX.Position.RepPosition.RpCobPriceId>
            R.DX.MP = DX.Pricing.MarketPrice.Read(Y.DX.MARKET.ID,Y.DX.MP.ERR)
            Y.QUOTE.PRICE = R.DX.MP<DX.Pricing.MarketPrice.MktQuotePrice>
            IF Y.QUOTE.PRICE NE "" THEN
                RET.ARR<-1> = Y.DX.MARKET.ID
            END
        REPEAT

        CONVERT @FM TO " " IN RET.ARR
    END

    ENQ.DATA<2,1> = "@ID"
    ENQ.DATA<3,1> = "EQ"
    ENQ.DATA<4,1> = RET.ARR   ;* Assign the Array values to @ID.

    RETURN

END

