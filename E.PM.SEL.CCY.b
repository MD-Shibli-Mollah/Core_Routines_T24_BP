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

* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-27</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PM.Reports
    SUBROUTINE E.PM.SEL.CCY(ID.LIST)

* This routine will allow the user to input a CCY code via an
* ENAUIRY.SELECT screen prompt. It is intended for use only with PM
* enquiries which make use of the PM.ENQ.PARAM file to perform selection
* via the routine E.PM.SEL.POSN.CLASS. This and other PM routines make use
* of a labelled common area (I_PM.ENQ.COMMON) to pass information. The
* routine E.PM.INT.COMMON will use the enquiry common variables
* D.FIELDS, D.LOGICAL.OPERANDS and D.RANGE.AND.VALUE to load the common
* common variables.

* note: this routine returns a value in ID.LIST only to fool the routine
* CONCAT.LIST.PROCESSOR into thinking it has a valid select list.
*-----------------------------------------------------------------------------
* Modification History:
*
* 01/02/11 - Defect-116490 / Task-133726
*            Albanian Lec currency 'ALL' is fetching data's of all the currencies
*            instead of the data of that currency
*
* 26/10/15 - EN_1226121 / Task 1511358
*	      	 Routine incorporated
*
*-----------------------------------------------------------------------------
    $USING EB.Reports


INITIALISE:
*==========
    ID.LIST = ''
    LOCATE 'CCY' IN EB.Reports.getDFields()<1> SETTING ID.POS THEN
* Do nothing
    END ELSE
    ID.LIST = '2'
    END

* Set ID.LIST to a to the currency requested. This is to convince the
* routine CONCAT.LIST.PROCESSOR that it has a emaningfule select list !!
    IF ID.LIST NE '2' THEN
        ID.LIST = EB.Reports.getDRangeAndValue()<ID.POS>
    END

    RETURN


******
    END
