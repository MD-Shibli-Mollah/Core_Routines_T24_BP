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
* <Rating>-28</Rating>
*-----------------------------------------------------------------------------
* Version 2 15/05/01  GLOBUS Release No. 200511 31/10/05
************************************************************************
*
    $PACKAGE PC.Contract
    SUBROUTINE PC.SETUP.COMMON(PC.PER.DATE)
*
*   Common subroutine called by  PC modules to initialise
*   variables in the common area of I_PC.COMMON.
*
* Arguments : 1. PC.PER.DATE - If there is a date passed , then the
*                routine will initialise and set all variables in
*                I_PC.COMMON
*             2. If no date is passed , variables are initialised
*
***********************************************************************

    $USING ST.CompanyCreation
    $USING EB.Utility
    $USING EB.ErrorProcessing
    $USING PC.Contract
    $USING EB.SystemTables


* Set/reset common variable
    EB.SystemTables.setCPcClosingDate(PC.PER.DATE)

    BEGIN CASE

        CASE PC.PER.DATE
            GOSUB SET.COMMON.VARS

        CASE 1
            GOSUB RESET.COMMON.VARS

    END CASE

    RETURN



SET.COMMON.VARS:

* Save common variables
    R.DATES.DYN = EB.SystemTables.getDynArrayFromRDates()
    PC.Contract.setDynArrayToDatesSave(R.DATES.DYN)
    PC.Contract.setTodaySave(EB.SystemTables.getToday())
    PC.Contract.setLccySave(EB.SystemTables.getLccy())
    R.COMPANY.DYN = EB.SystemTables.getDynArrayFromRCompany()
    PC.Contract.setDynArrayToCompanySave(R.COMPANY.DYN)

*
    EB.SystemTables.clearRDates()
    ERTXT = ''
    R.DATES.DYN = EB.Utility.Dates.Read(EB.SystemTables.getIdCompany(), ERTXT)
    EB.SystemTables.setDynArrayToRDates(R.DATES.DYN)
    IF ERTXT THEN
        EB.SystemTables.setText(ERTXT)
        EB.ErrorProcessing.FatalError('SYSTEM RECORD MISSING FROM DATES FILE')
    END

    EB.SystemTables.clearRCompany()
    ERTXT = ''


    R.COMPANY.DYN = ST.CompanyCreation.Company.Read(EB.SystemTables.getIdCompany(), ERTXT)
    EB.SystemTables.setDynArrayToRCompany(R.COMPANY.DYN)
    IF ERTXT THEN
        EB.SystemTables.setText(ERTXT)
        EB.ErrorProcessing.FatalError('SYSTEM RECORD MISSING IN COMPANY FILE')
    END


    ST.CompanyCreation.LoadCompany(EB.SystemTables.getIdCompany())


    RETURN


RESET.COMMON.VARS:

    DATES.SAVE.DYN = PC.Contract.getDynArrayFromDatesSave()
    EB.SystemTables.setDynArrayToRDates(DATES.SAVE.DYN)
    EB.SystemTables.setToday(PC.Contract.getTodaySave())

* Reset common variables
    PC.Contract.clearDatesSave()
    PC.Contract.setTodaySave('')
    PC.Contract.setLccySave('')
    PC.Contract.clearCompanySave()
    ST.CompanyCreation.LoadCompany(EB.SystemTables.getIdCompany())

    RETURN

    END
