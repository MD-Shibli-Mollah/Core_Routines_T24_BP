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

* Version 3 02/06/00  GLOBUS Release No. G12.2.00 04/04/02
*-----------------------------------------------------------------------------
* <Rating>-16</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE RE.ModelBank
    SUBROUTINE E.GET.RE.OPEN.BAL
*
** Subroutine to extract the balance for a given report line
** in the currency specified in the selection CURRENCY
** from the common array C$BAL.ARRAY built in E.BUILD.RE.OPEN.BAL
**
** IN O.DATA = Report.Line
** OUT O.DATA = Balance
*
*******************************************************************
*
* CHANGE CONTROL
* --------------
*
* 08/10/98 - GB9801203
*            The search key contains a dot whereas it is expected
*            to have a -
*            Also the C$BAL.ARRAY fields are built in fields 1,2,3
*            whereas accesed from 1,3,4
*
* MODIFICATION.HISTORY:
* 07/11/02 - CI_10004620
*            Modification done to show OPENING.BALANCE & CLOSING.BALANCE
*
* 04/10/07 - BG_100015329
*            Changes done to get close balance correctly.
*
********************************************************************   
    $USING EB.SystemTables
    $USING EB.Reports
    $USING RE.ModelBank
*
    LOCATE 'REPORT.NAME' IN EB.Reports.getEnqSelection()<2,1> SETTING POS THEN
        REPNAME = EB.Reports.getEnqSelection()<4,POS> 
    END ELSE
        RETURN      ;* No report specified
    END

    LOCATE 'CURRENCY' IN EB.Reports.getEnqSelection()<2,1> SETTING POS THEN
        CCY = EB.Reports.getEnqSelection()<4,POS>
    END ELSE
        CCY = ''
    END
*
    OPEN.BAL = 0

    RKEY = EB.Reports.getOData()
    RKEY1 = REPNAME
    RKEY2 = FIELD(RKEY,'.',2)
    SEARCH.KEY = RKEY1:'-':RKEY2:'*':CCY

    LOCAL.CBALARRAY = RE.ModelBank.getCBalArray()
    LOCATE SEARCH.KEY IN LOCAL.CBALARRAY<1,1> SETTING POS THEN
        OPEN.BAL = LOCAL.CBALARRAY<3,POS>
    END
    RE.ModelBank.setCBalArray(LOCAL.CBALARRAY)
*
    IF OPEN.BAL = "" THEN
        OPEN.BAL = 0
    END
    EB.Reports.setOData(OPEN.BAL)
*
    RETURN
*
END
