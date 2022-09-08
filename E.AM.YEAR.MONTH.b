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

* Version 1 21/06/01  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-55</Rating>
*-----------------------------------------------------------------------------

    $PACKAGE AM.Foundation
    SUBROUTINE E.AM.YEAR.MONTH(ENQUIRY.DATA)

******************************************************************************
* This routine checks whether the given composite ID has valid history data
* for the given year. If it find a record return the value otherwise return
* error.
******************************************************************************
* Modification History:
*----------------------
*
* 26/04/07 - EN_10003329
*            Removal of Idesc from selection criteria.
*
* 27/09/07 - BG_100015287
*            Das select crash while selecting all ids

* 01/03/16 - 1641731
*            Incoporation of Components
******************************************************************************

    $INSERT I_DAS.AM.COMP.HIST.CONCAT

    $USING EB.DataAccess
    $USING AM.Composite
    $USING EB.SystemTables
    $USING EB.Reports


    GOSUB INITIALISE

    GOSUB OPEN.FILES

    LOCATE '@ID' IN ENQUIRY.DATA<2,1> SETTING POS.ID THEN
    AM.COMP.HIST.CONCAT.ID.LIST = ENQUIRY.DATA<4,POS.ID>
    END ELSE
    DAS.FILE.NAME = 'AM.COMP.HIST.CONCAT'
    DAS.FILE.SUFFIX = ''
    DAS.ARGS = ''
    DAS.LIST = EB.DataAccess.dasAllId      ; * BG_100015287 - S/E
    GOSUB DAS.INTERFACE
    AM.COMP.HIST.CONCAT.ID.LIST = DAS.LIST
    END

* Get the Year to check whether the composite have data for given year
    LOCATE 'YEAR' IN ENQUIRY.DATA<2,1> SETTING POS.YEAR THEN
    YEAR.MONTH = ENQUIRY.DATA<4,POS.YEAR>
    END ELSE
    YEAR.MONTH = EB.SystemTables.getToday()[1,4]
    END

    GOSUB MAIN.PROCESS

    RETURN

*----------------------------------------------------------------------------------
OPEN.FILES:
*----------
    RETURN

*----------------------------------------------------------------------------------
INITIALISE:
*----------

    YEAR.MONTH = ''
    ADD.COMP.ID = ''
    COMP.ID.LIST = ''
    RETURN

*----------------------------------------------------------------------------------
READ.AM.COMP.HIST.CONCAT:
*------------------------

    R.AM.COMP.HIST.CONCAT = ''
    AM.COMP.HIST.CONCAT.ERR = ''
    R.AM.COMP.HIST.CONCAT = AM.Composite.AmCompHistConcat.Read(AM.COMP.HIST.CONCAT.ID, AM.COMP.HIST.CONCAT.ERR)
    RETURN

*----------------------------------------------------------------------------------
MAIN.PROCESS:
*------------

    LOOP
        REMOVE AM.COMP.HIST.CONCAT.ID FROM AM.COMP.HIST.CONCAT.ID.LIST SETTING AM.COMP.POS
    WHILE AM.COMP.HIST.CONCAT.ID:AM.COMP.POS
        GOSUB READ.AM.COMP.HIST.CONCAT
        ADD.COMP.ID = ''
        * Check the year and History Id's year, If it does not matches return error
        LOOP
            REMOVE COMP.HIST.ID FROM R.AM.COMP.HIST.CONCAT SETTING POS.CON
        WHILE COMP.HIST.ID:POS.CON AND ADD.COMP.ID EQ ''
            YMONTH = FIELD(COMP.HIST.ID, '.', 2)[1,4]
            IF YMONTH EQ YEAR.MONTH THEN
                ADD.COMP.ID = AM.COMP.HIST.CONCAT.ID
            END
        REPEAT
        IF ADD.COMP.ID THEN
            COMP.ID.LIST<-1> = DQUOTE(ADD.COMP.ID)
        END
    REPEAT

    IF AM.COMP.HIST.CONCAT.ERR OR NOT(COMP.ID.LIST) THEN
        EB.Reports.setEnqError('No records match the given Criteria')
    END

    IF COMP.ID.LIST THEN
        LOCATE '@ID' IN ENQUIRY.DATA<2,1> SETTING POS.ID ELSE
        ENQUIRY.DATA<2,-1> = '@ID'
        ENQUIRY.DATA<3,-1> = 'EQ'
        CONVERT @FM TO " " IN COMP.ID.LIST
        ENQUIRY.DATA<4,-1> = COMP.ID.LIST
    END
    END

    RETURN
*---------------------------------------------------------------------------------------------
DAS.INTERFACE:
*-------------

    EB.DataAccess.Das(DAS.FILE.NAME,DAS.LIST,DAS.ARGS,DAS.FILE.SUFFIX)

    RETURN
*---------------------------------------------------------------------------------------------

    END
