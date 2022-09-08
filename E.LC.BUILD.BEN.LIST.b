* @ValidationCode : MjotMjMxOTIzMjI4OkNwMTI1MjoxNTQyMTk4MzkyNDkzOnNyYXZpY2hhcmFuOi0xOi0xOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE4MTEuMjAxODEwMjItMTQwNjotMTotMQ==
* @ValidationInfo : Timestamp         : 14 Nov 2018 17:56:32
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravicharan
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201811.20181022-1406
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 4 06/06/01  GLOBUS Release No. G12.0.00 29/06/01
*-----------------------------------------------------------------------------
* <Rating>1375</Rating>
*-----------------------------------------------------------------------------
$PACKAGE LC.Foundation
SUBROUTINE E.LC.BUILD.BEN.LIST(Y.LC.LIST, CUST.ACC.MNE)

    $INSERT I_DAS.LETTER.OF.CREDIT

    $USING EB.Reports
    $USING EB.SystemTables
    $USING LC.ModelBank
    $USING LC.Contract
    $USING EB.DataAccess


    ! Enquiry routine to select the Live and the Unauthorised
    ! LC files to pick up all the LCs and DRs where the beneficiary
    ! customer number being passed into this routine is a
    ! beneficiary of the LC.

    ! This program will pick up records from both the live
    ! and the Unauthorised files and send them back to the
    ! enquiry or the calling routine

    ! This routine will be called either directly by the enquiry
    ! select or by another enyuiry routine (E.LIM.LIAB.SELECTION)
    ! in which case the incoming Y.LC.LIST will have the Customer
    ! number that will have to be processed.

    ! Outgoing: Y.LC.LIST will be set to contain all the LCs
    ! for this customer or set to Null if no LCs are found for
    ! this customer

* 21/09/98 - GB9801141 / G99800168
*            Added input parameter for company mnemonic.
*
* 08/04/10 - TASK:38770
*            Converting the SELECT to DAS.
*            DEFECT : 19983
*
* 21/02/11 - TASK:155973
*            variable is DAS.LETTER.OF.CREDIT$BENE.REV, not DAS.LETTER.OF.CREDIT$BENE.RE.
*            DEFECT : 155937
*
* 13/03/12 - TASK : 334092
*            Allowing more than 99 drawings under a LETTER.OF.CREDIT
*            REF : 323657
*
* 30/12/14 - Task:1210894
*			 LC Componentization and Incorporation
*			 Enhancement : 990544
*
* 03/02/16 - Task : 1468316
*            LC Componentization and Incorporation
*            Defect : 1607315
*
* 29/10/18 - Task : 2831555
*			 Componentization II - EB.DataAccess should be used instead of I_DAS.COMMON.
*		     Strategic Initiative : 2822484
*
*---------------------------------------------------------------------------
    GOSUB INITIALISE

    GOSUB PROCESS.LC.FILE

    GOSUB ASSEMBLE.LC.IDS

RETURN
!---------------------------------------------------------------
INITIALISE:
    !---------

    ! Open files
* GB9801141
    IF NOT(CUST.ACC.MNE) THEN
        CUST.ACC.MNE = ""
    END
    FN.LETTER.OF.CREDIT$NAU = 'F':CUST.ACC.MNE:'.LETTER.OF.CREDIT$NAU' :@FM: 'NO.FATAL.ERROR'
    FV.LETTER.OF.CREDIT$NAU = ''
    EB.DataAccess.Opf(FN.LETTER.OF.CREDIT$NAU, FV.LETTER.OF.CREDIT$NAU)

    FN.LC.BENEFICIARY = 'F':CUST.ACC.MNE:'.LC.BENEFICIARY' :@FM: 'NO.FATAL.ERROR'
    FV.LC.BENEFICIARY = ''
    EB.DataAccess.Opf(FN.LC.BENEFICIARY, FV.LC.BENEFICIARY)

    ! Initialise Variables
    NAU.LC.LIST = '' ; REV.LC.LIST = ''
    AUTH.LC.LIST = '' ; TEMP.LC.LIST = ''

    IF Y.LC.LIST = '' THEN             ; ! Called from Enquiry Select
        LOCATE "LC.BENEFICIARY" IN EB.Reports.getDFields()<1> SETTING YPOS ELSE YPOS = ''
        IF YPOS = '' THEN GOSUB PROG.ABORT
        Y.CURR.CUST = EB.Reports.getDRangeAndValue()<YPOS>
    END ELSE                           ; ! Called from E.LIM.LIAB.SELECTION
        Y.CURR.CUST = Y.LC.LIST
    END
    Y.LC.LIST = ''
    IF Y.CURR.CUST = '' THEN GOSUB PROG.ABORT


RETURN
!---------------------------------------------------------------
PROCESS.LC.FILE:
    !--------------

    ! Now select the Unauth file where this customer is the beneficiary
    TABLE.NAME = 'LETTER.OF.CREDIT'
    THE.LIST = DAS.LETTER.OF.CREDIT$BENE
    THE.ARGS<1> = Y.CURR.CUST
    THE.ARGS<2> = 'INAU'
    THE.ARGS<3> = 'CNAU'
    TABLE.SUFFIX = '$NAU'
    EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
    LC.LIST = THE.LIST

    ! Now select the Unauth file to get any LCs that have been
    ! reversed
    TABLE.NAME = 'LETTER.OF.CREDIT'
    THE.LIST = DAS.LETTER.OF.CREDIT$BENE.REV
    THE.ARGS<1> = Y.CURR.CUST
    THE.ARGS<2> = 'RNAU'
    TABLE.SUFFIX = '$NAU'
    EB.DataAccess.Das(TABLE.NAME,THE.LIST,THE.ARGS,TABLE.SUFFIX)
    REV.LC.LIST = THE.LIST

    ! Now get the list of all the Authorised LC records where
    ! this customer is the beneficiary
    ! Dont Select the live file as it could be large, instead
    ! read LC.BENEFICIARY concat file and then, determine
    ! if it is an Export LC
    YLC.BEN.REC = '' ; Y.READ.ERR= ''
    EB.DataAccess.FRead(FN.LC.BENEFICIARY, Y.CURR.CUST, YLC.BEN.REC, FV.LC.BENEFICIARY, YREAD.ERR)

    IF YREAD.ERR = '' THEN
        ! If the LC is in the Reversed list then drop it !!!
        AUTH.LC.LIST = ''
        LOOP REMOVE LC.ID FROM YLC.BEN.REC SETTING YEOL
        WHILE LC.ID:YEOL
            LOCATE LC.ID IN REV.LC.LIST<1> SETTING YPOS ELSE YPOS = ''
            IF YPOS # '' THEN GOTO LC.REPEAT       ; ! LC has been reversed

            LOCATE LC.ID IN NAU.LC.LIST<1> SETTING YPOS ELSE YPOS = ''
            IF YPOS # '' THEN GOTO LC.REPEAT       ; ! LC is in the Unauth file
            AUTH.LC.LIST<-1> = LC.ID
LC.REPEAT:
        REPEAT
    END

RETURN
!--------------------------------------------------------------
ASSEMBLE.LC.IDS:
    !--------------
    ! Combine the Unauth and the Live LC lists to get one list
    ! of all LCs associated with this beneficiary

    IF NAU.LC.LIST # '' THEN
        YFILE = 'LETTER.OF.CREDIT$NAU'
        LOOP REMOVE BEN.LC FROM NAU.LC.LIST SETTING BEN.EOL
        WHILE BEN.LC:BEN.EOL
            GOSUB PROCESS.DR.FILE
        REPEAT
    END

    IF AUTH.LC.LIST # '' THEN
        YFILE = 'LETTER.OF.CREDIT'
        LOOP REMOVE BEN.LC FROM AUTH.LC.LIST SETTING BEN.EOL
        WHILE BEN.LC:BEN.EOL
            GOSUB PROCESS.DR.FILE
        REPEAT
    END

RETURN
!-------------------------------------------------------------
PROCESS.DR.FILE:
    !--------------
    ! Check for any Drawings done on the LCs and add them
    ! to the list if they are of AC or DP type but NOT
    ! Discounted

    Y.LC.LIST<-1> = BEN.LC
    EB.DataAccess.Dbr(YFILE:@FM:LC.Contract.LetterOfCredit.TfLcNextDrawing,BEN.LC,NEXT.DR)
    IF NEXT.DR < 2 THEN GOTO DR.RETURN

    FOR DR.NO = 1 TO (NEXT.DR-1)
        IF DR.NO GT 99 THEN ;*ID of drawings will gets changed to 15 digits after 99 drawings.
            DR.ID = BEN.LC:FMT(DR.NO,"3'0'R")
        END ELSE
            DR.ID = BEN.LC:FMT(DR.NO,"2'0'R")
        END
        ! Check the Unauth DR file first and if not present, check the live
        DR.NAU.REC = ''
        DR.NAU.ER = ''
        DR.NAU.REC = LC.Contract.Drawings.ReadNau(DR.ID,DR.NAU.ER)
        DR.TYPE = DR.NAU.REC<LC.Contract.Drawings.TfDrDrawingType>
        DR.DISC = DR.NAU.REC<LC.Contract.Drawings.TfDrDiscountAmt>
        IF DR.TYPE = '' THEN
            DR.ER = ''
            DR.REC = ''
            DR.REC = LC.Contract.tableDrawings(DR.ID,DR.ER)
            DR.TYPE = DR.REC<LC.Contract.Drawings.TfDrDrawingType>
            DR.DISC= DR.REC<LC.Contract.Drawings.TfDrDiscountAmt>
        END
        IF NOT(DR.TYPE MATCHES 'AC':@VM:'DP') THEN GOTO NEXT.DR.NO

        IF DR.DISC # '' THEN GOTO NEXT.DR.NO

        Y.LC.LIST<-1> = DR.ID
NEXT.DR.NO:
    NEXT DR.NO

DR.RETURN:
RETURN
!-------------------------------------------------------------
PROG.ABORT:
    !---------

RETURN TO PROG.ABORT

RETURN
!------------------------------------------------------------
END
