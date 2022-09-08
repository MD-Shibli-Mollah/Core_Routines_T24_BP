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
* <Rating>-40</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CL.ModelReport
    SUBROUTINE E.CL.BUILD.VIEW(ENQ.DATA)
*-----------------------------------------------------------------------------
*** <region name= Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*** <doc>
* This Routine will raise the Error message if current operator is not relevant to collector.
*
*
* @author johnson@temenos.com
* @stereotype template
* @uses
* @uses
* @package retaillending.CL
*
*** </doc>
*** </region>
*** <region name= Modification History>
*** <desc>Changes done in the sub-routine</desc>
* Modification History :
*-----------------------
* 11/04/14 -  ENHANCEMENT - 908020 /Task - 988392
*          -  Loan Collection process
*
* 15/03/16  - Defect : 1633559
*             Drill down in Collection Manager Home Page throwing error 
* ----------------------------------------------------------------------------
*** </region>
* ----------------------------------------------------------------------------
*** <region name= INSERTS>
*** <desc>Inserts Section</desc>

    $USING CL.Contract
    $USING EB.Reports
    $USING EB.SystemTables

*** </region>

*-----------------------------------------------------------------------------
*** <region name= Main section>
*** <desc>Main section</desc>


    GOSUB INITIALISE
    GOSUB PROCESS
    RETURN

*** </region>


*** <region name= INITIALISE>
*** <desc>Initialise the all Required variables and Open Files</desc>

INITIALISE:
***********

    SEL.OPERATOR = EB.SystemTables.getOperator()
    F.CL.COLLECTOR.USER = ""

    RETURN


*** </region>

*** <region name= PROCESS>
*** <desc>Process for collector</desc>


PROCESS:
********
 

    tmp.OPERATOR = EB.SystemTables.getOperator()
    R.CL.COLLECTOR.USER = CL.Contract.CollectorUser.Read(tmp.OPERATOR, ERR.COLLECTOR.USER)
    EB.SystemTables.setOperator(tmp.OPERATOR)

    IF NOT(R.CL.COLLECTOR.USER) THEN
        EB.Reports.setEnqError("Current User Doesn't belongs to collector")
    END

    RETURN

*** </region>
    END


