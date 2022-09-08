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
* <Rating>-30</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.UPD.DATE.TIME(LINE.RET)
*------------------------------------------------------------------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Task of the sub-routine</desc>
* Program Description
*
*   This subroutine will update the date and time of extraction in the record to be extracted in OC.TRADE.DATA.
*   The routine will be attached in the POST.UPDATE.RTN field of DFE.MAPPING.
*
* *** </region>
*------------------------------------------------------------------------------------------------------------------------------------

*** <region name= Arguments>
*
*
*** </region>
*------------------------------------------------------------------------------------------------------------------------------------
*** <region name = Modification History>
*** <desc>Modification Summary</desc>
* Modification History:
*
*13/07/15 - Enhancement 1177306 / Task 1252426
*           Creation of Routine (DFE configuration)
*
*01/09/15 - Defect 1455183 / Task 1455556
*           Compilation errors in Tresury vertical-Insert not found.
*
* 21/09/15 - Enhancement 1461371 / Task 1461382
*            OTC Collateral and Valuation Reporting.
*
* 30/12/15 - EN_1226121 / Task 1568411
*			 Incorporation of the routine
*** </region>
*------------------------------------------------------------------------------------------------------------------------------------



    $USING EB.SystemTables
    $USING EB.API
    $USING EB.Utility
    $USING OC.Reporting
    $USING EB.DataAccess


    OC.TRA.ID = EB.Utility.getCTxnId()      ;*Txn id of oc.trade.data
    R.OC.TRA = EB.Utility.getCApplRec()     ;*oc.trade.data array

*The insert I_F.OC.TRADE.DATA has not been released under core (generated automatically on authorisation of TX.TXN.BASE.PARMS for OC.TRADE.DATA).
*System is unable to find out the insert I_F.OC.TRADE.DATA on compilation when defined.
*Hence,the field positions were used instead of field names.


    IF R.OC.TRA<5> EQ '' THEN  ;* Dont update time stamp for delegated report. Time would be added when extracting for own book itself.
        R.OC.TRA<5> = TIMEDATE()         ;*update system date and time in the oc.trade.data record.
        EB.DataAccess.FWrite(EB.Utility.getCFnFileNameArray()<1>,OC.TRA.ID,R.OC.TRA)      ;*write to oc.trade.data
    END



    RETURN
