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
* <Rating>-52</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LD.ModelBank
    SUBROUTINE E.TCIB.BLD.GET.CAT.LIST(ENQ.DATA)
*-----------------------------------------------------------------------------
* Attached to     : TCIB.LD.LOANS & TCIB.LD.DEPOSITS Enquiry as Build routine
* Incoming        : Enquiry name (ENQ.DATA)
* Outgoing        : ENQ.DATA - List of allowed contracts for LD
*-----------------------------------------------------------------------------
* Description:
* Subroutine to get the list of contracts defined for loans and deposits
*-----------------------------------------------------------------------------
* Modification History :
* 21/05/14 - Enhancement 1006263/Task 1025316
*            TCIB : Retail (Loans and Deposits)
*----------------------------------
* 19/06/14 - Enhancement 1006263/Task 1025316
*            TCIB : Retail (Loans and Deposits) - Defect Fixing
*----------------------------------
* 27/06/14 - Enhancement: 1001222 / Task 1001223
*            TCIB User Management
*
* 11/06/15 - Defect: 1381680 / Task 1374606
*            Loan Enquiry not fetching results when name modified
* 21/12/15 - Enhancement 1470216 / Task 1559865
* 		     EB.USER.CONTEXT cleanup of variables
*-----------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_System
    $INSERT I_F.EB.EXTERNAL.USER
    $INSERT I_F.AA.PRODUCT.ACCESS
    $INSERT I_F.LD.LOANS.AND.DEPOSITS
*
    GOSUB INIT
    GOSUB OPEN.FILE
    GOSUB PROCESS
    RETURN
*-----------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------
* Initialise all variables
*
    FN.LD.LOANS.AND.DEPOSITS = 'F.LD.LOANS.AND.DEPOSITS'
    F.LD.LOANS.AND.DEPOSITS  = ''
    Y.LD.LIST.CNT            = ''		;*Initialising variable
    Y.LD.LIST                = ''; Y.ALLOWED.LOANS = ''; Y.ALLOWED.DEPOSITS = ''; Y.ALLOWED.LD = '';*Initialising variable
    RETURN
*-----------------------------------------------------------------------------
OPEN.FILE:
*-----------------------------------------------------------------------------
*Open required files
*
    CALL OPF(FN.LD.LOANS.AND.DEPOSITS,F.LD.LOANS.AND.DEPOSITS)
    RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
* Define the category range for the Loans & Deposits.(As defined in LD.CONTYPE routine)
* Using the same build routine for both loans & deposits, so based on the enquiry name define the category range
*

    LOCATE 'CATEGORY' IN ENQ.DATA<2,1> SETTING POS THEN
    	Y.DEFAULT.START.CAT=FIELD(ENQ.DATA<4,POS,1>,"...",1)
		Y.DEFAULT.END.CAT=FIELD(ENQ.DATA<4,POS,1>,"...",2)
    END
*
    Y.ALLOWED.LOANS = System.getVariable('EXT.SMS.LOANS.SEE')        ;* List of allowed Loan contracts defined in permission
    Y.ALLOWED.DEPOSITS = System.getVariable('EXT.SMS.DEPOSITS.SEE')        ;* List of allowed Deposit contracts defined in permission
*
    Y.ALLOWED.LD = Y.ALLOWED.LOANS:@VM:Y.ALLOWED.DEPOSITS
*
    LOOP
        REMOVE Y.LD.ID FROM Y.ALLOWED.LD SETTING Y.LD.ID.POS
    WHILE Y.LD.ID:Y.LD.ID.POS
        CALL F.READ(FN.LD.LOANS.AND.DEPOSITS,Y.LD.ID,R.LD.LOANS.AND.DEPOSITS,F.LD.LOANS.AND.DEPOSITS,ERR.LD.LOANS.AND.DEPOSITS)
        IF R.LD.LOANS.AND.DEPOSITS THEN
            Y.LD.CATEGORY = R.LD.LOANS.AND.DEPOSITS<LD.CATEGORY>
            IF Y.LD.CATEGORY GE Y.DEFAULT.START.CAT AND Y.LD.CATEGORY LE Y.DEFAULT.END.CAT THEN
                Y.LD.LIST<-1>  = Y.LD.ID
                Y.LD.LIST.CNT += 1
            END
        END
    REPEAT
    GOSUB FINAL.ARRAY.VAL
    RETURN
*-----------------------------------------------------------------------------
FINAL.ARRAY.VAL:
*-----------------------------------------------------------------------------
* Finaly array value for out going parameter
*
    BEGIN CASE
    CASE Y.LD.LIST.CNT EQ '1' ;* with single contract selection criteria
        ENQ.DATA<2,3> = '@ID'
        ENQ.DATA<3,3> = 'EQ'
        ENQ.DATA<4,3> = Y.LD.LIST

    CASE Y.LD.LIST.CNT GT '1' ;* more than one contract selection criteria
        Y.LD.ID.CNT = '1'
        LOOP
            REMOVE Y.LD.VAL FROM Y.LD.LIST SETTING Y.LD.VAL.POS
        WHILE Y.LD.VAL:Y.LD.VAL.POS
            IF Y.LD.ID.CNT EQ '1' THEN
                ENQ.DATA<2,3>  = '@ID'
                ENQ.DATA<3,3>  = 'EQ'
                ENQ.DATA<4,3>  = Y.LD.VAL
            END ELSE
                ENQ.DATA<4,3>  := " ":Y.LD.VAL
            END
            Y.LD.ID.CNT += 1
        REPEAT
    CASE Y.LD.LIST.CNT EQ ''  ;* Without any contract selection creteria
        ENQ.DATA<2,3> = '@ID'
        ENQ.DATA<3,3> = 'EQ'
        ENQ.DATA<4,3> = ''
    END CASE
    RETURN
END
