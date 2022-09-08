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
* <Rating>-18</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE IC.Config
    SUBROUTINE IC.BUILD.COMP.ACCTS(ARGS)

    $USING IC.Config
    $USING EB.API
***************************************************************************************
* 14/08/09 - EN_1004283
*            add hook for local routine to adjust compensation account start and end dates and start period
*            for calculation
****************************************************************************************
* This routine is a very simple example to show how the process works
* It should not be used in a live situation
* It is important that a real version of this routine should have minimal I/O
* arguments
* ARGS<1> Account number
* ARGS<2> period start - can be modified
* ARGS<3> period end
* ARGS<4> calculation type "A" = accrual "S" = capitalisation "C" = correction
*         "I" Information only; can be used to test this routine when called from INFO.ACCT.XX (XX = DR,DR2,CR,CR2,CH)
* ARGS<5> compensation accounts - can be modified
* ARGS<6> start dates for joining group   - can be returned
* ARGS<7> DATES FOR LEAVING GROUP - can be returned
*
*
***************************************************************************
*
*
    PSTART = ARGS<2>
    IF NOT(PSTART) THEN
        RETURN
    END
    IF ARGS<4> = "C" THEN     ;* just change for corrections
        EB.API.Cdt("",PSTART,"+02C")      ;* change period start
        ARGS<2> = PSTART
    END
    IF ARGS<5,1> THEN
        EB.API.Cdt("",PSTART,"+01C")      ;* add a day to the start date for 1st comp account
        ARGS<6,1> = PSTART
        EB.API.Cdt("",PSTART,"+10C")      ;* add 10 days to the start date for 1st comp account
        ARGS<7,1> = PSTART
    END

    RETURN
    END
