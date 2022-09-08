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
* <Rating>-23</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE OC.Reporting

    SUBROUTINE OC.SELECT.OWN.BOOK.REPORTS(Y.ARG)

*------------------------------------------------------------------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Task of the sub-routine</desc>
* Program Description
*
*  The purpose of the routine is to filter the records for
*  own book reporting.
*
*
*** </region>
*------------------------------------------------------------------------------------------------------------------------------------

*** <region name= Arguments>
*
* Incoming/Outgoing:
*
*  Y.ARG = contains the ID of record.
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
* 30/12/15 - EN_1226121 / Task 1568411
*			 Incorporation of the routine
*
*** </region>
*------------------------------------------------------------------------------------------------------------------------------------

    $USING EB.Utility

*The routine will return the output argument only for reporting models '1' and '2' and for zero reporting model no id will be returned.

*The insert I_F.OC.TRADE.DATA has not been released under core (generated automatically on authorisation of TX.TXN.BASE.PARMS for OC.TRADE.DATA).
*System is unable to find out the insert I_F.OC.TRADE.DATA on compilation when defined.
*Hence,the field positions were used instead of field names.


    IF EB.Utility.getCApplRec()<6> NE '0' THEN

    END ELSE

        Y.ARG=''

    END

    RETURN


