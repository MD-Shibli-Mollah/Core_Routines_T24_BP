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
* <Rating>-106</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE T2.ModelBank
    SUBROUTINE TCIB.AI.GET.NEXT.ID(YR.APPLICATION,YR.NEXT.ID)
*** <region name= Description>
* Attached to     : V.TCIB.EEU.GENERATE as a Call routine
* Incoming        : Application Id
* Outgoing        : External User Id
*----------------------------------------------------------------------------------------------------------------
* Description:
* By passing the external user application, the Next unique id is generated based on another exiting call routine
*-----------------------------------------------------------------------------------------------------------------
* Modification History :
* 01/07/14 - Enhancement 1001222/Task 1001223
*            TCIB : User management enhancements and externalisation
*
* 14/07/15 - Enhancement 1326996 / Task 1399946
*			 Incorporation of T components
*----------------------------------------------------------------------------------------------

    $USING EB.SystemTables
    $USING EB.TransactionControl
    $USING EB.ErrorProcessing

    GOSUB INITIALISE
    GOSUB BACKUP.COMMON.DATA
    GOSUB GET.NEXT.ID
    GOSUB RESTORE.COMMON.DATA

    RETURN
*----------------------------------------------------------------------------------
GET.NEXT.ID:
*------------
*loop to find the next id

    LOOP  ;*loop to no of iterations to fetch the next id
        GOSUB SET.DATA.FOR.NEXT.ID      ;*intialising variables for next id
        EB.TransactionControl.GetNextId(YBASEID,YTYPE) ;*Existing call routine which brings the next id for the application
        EB.SystemTables.setIdNew(EB.SystemTables.getComi());*assigning the comi variable to id.new variable
        IF ID.PREFIX THEN     ;*if id.prefix variable not null proceeed
            EB.TransactionControl.FormatId(ID.PREFIX)          ;*existing call routine to format the id
        END
        EEU.KEY = EB.SystemTables.getIdNew()
        YR.NEXT.ID = EEU.KEY  ;*assign to output parameter
    UNTIL YR.NEXT.ID NE ''
        GOSUB CHECK.NUMBER.OF.ITERATIONS          ;*check the iteration is breached
    REPEAT

    RETURN
*------------------------------------------------------------------------------------------
INITIALISE:
*-----------
* initialise and open parameters

    FN.LIVE.FILE = 'F.':YR.APPLICATION  ;*Open application with incoming
    F.LIVE.FILE = ''
    CALL OPF(FN.LIVE.FILE,F.LIVE.FILE)

    IF YR.APPLICATION NE 'AA.ARRANGEMENT' THEN    ;*check for appliation is not arrangement
        FN.INAU.FILE = 'F.':YR.APPLICATION:'$NAU' ;*read INAU file
        F.INAU.FILE = ''
        CALL OPF(FN.INAU.FILE,F.INAU.FILE)

        FN.HIS.FILE = 'F.':YR.APPLICATION:'$HIS'  ;*read history file
        F.HIS.FILE = ''
        CALL OPF(FN.HIS.FILE,F.HIS.FILE)
    END

    ITERATION.LIMIT = 99999   ;*maximum number of iterations to check
    NO.ITERATIONS = 0         ;*initialise iteration
    YR.NEXT.ID = '' ;*initialise the next id

    RETURN
*-----------------------------------------------------------------------------------------------
BACKUP.COMMON.DATA:
*-------------------
*backup the arrangement arguments to new variables to restore the same at the end

    YFUNCTION = EB.SystemTables.getVFunction()    ;*storing V fucntion variable
    YFULL.FNAME = EB.SystemTables.getFullFname()  ;*storing the full name
    YPGM.TYPE = EB.SystemTables.getPgmType()      ;*storing the application pgm type
    YCOMI = EB.SystemTables.getComi()    ;*storing the comi variable
    YID.NEW = EB.SystemTables.getIdNew()          ;*storing the id.new variable
    SAVE.APPLICATION = EB.SystemTables.getApplication()      ;*storing the application
    EB.SystemTables.setApplication(YR.APPLICATION);*storing the application

    RETURN
*------------------------------------------------------------------------------------------------
RESTORE.COMMON.DATA:
*---------------------
*restoring the common variables to its original values

    EB.SystemTables.setFullFname(YFULL.FNAME);*restoring full name
    EB.SystemTables.setVFunction(YFUNCTION);*restoring function
    EB.SystemTables.setPgmType(YPGM.TYPE);*restoring pgm type
    EB.SystemTables.setComi(YCOMI);*restoring comi variable
    EB.SystemTables.setIdNew(YID.NEW);*restoring id.new variable
    EB.SystemTables.setApplication(SAVE.APPLICATION);*restoring application

    RETURN
*------------------------------------------------------------------------------------------------
SET.DATA.FOR.NEXT.ID:
*---------------------
*initailising parameters to pass to the call rotuine to find next id

    EB.SystemTables.setComi('');*nullyfying the varaible
    EB.SystemTables.setIdNew('')
    YBASEID = ''
    EB.SystemTables.setFullFname(FN.LIVE.FILE)
    EB.SystemTables.setVFunction('I')
    EB.SystemTables.setIdN('16');
    EB.SystemTables.setIdT('S')
    EB.SystemTables.setPgmType('.IDA');
    YTYPE = 'F'     ;*argument to be passed to call routine

    RETURN
*--------------------------------------------------------------------------------------------------
CHECK.NUMBER.OF.ITERATIONS:
*----------------------------
*iteration check is done in this gosub

    NO.ITERATIONS = NO.ITERATIONS + 1   ;*incrment the iteration
    IF NO.ITERATIONS > ITERATION.LIMIT THEN       ;*check with maximum limit
        EB.SystemTables.setText('CANNOT FIND NEXT ID ':YR.APPLICATION);*error thrown when iteration breached
        EB.ErrorProcessing.FatalError('GET.NEXT.APPL.ID')
    END

    RETURN

    END
