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

*---------------------------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* <Rating>-21</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE T4.ModelBank
    SUBROUTINE E.TCIB.BLD.MAKER.CHECK(ENQ.DATA)
*--------------------------------------------------------------------
*-------------------------------------------------------------------------------------------------------
* Developed By : Temenos Application Management
* Program Name : E.NOFILE.TCIB.AC.LIST.CORP
*-----------------------------------------------------------------------------------------------------------------
* Description   : It's a  Nofile Enquiry used to Display the Current customers Accounts for version dropdown
* Linked With   : Standard.Selection for the Enquiry
* @Author       : manikandant@temenos.com
* In Parameter  : NILL
* Out Parameter : FINAL.ARRAY
* Enhancement   : 696318
*-----------------------------------------------------------------------------------------------------------------
* Modification Details:
*=====================
*
* 14/07/15 - Enhancement 1326996 / Task 1399947
*			 Incorporation of T components
*-----------------------------------------------------------------------------------------------------------------

    $USING EB.SystemTables

    GOSUB INIT

    RETURN

*--------------------------------------------------------------------------------------------------------------------
INIT:
*----
    DEFFUN System.getVariable()

    EXTERNAL.ID =  System.getVariable("EXT.EXTERNAL.USER")
    Y.EXTERNAL.ID = '_':EXTERNAL.ID:'_'

    Y.INPUTTER.ID = '...':Y.EXTERNAL.ID:'...'

    ENQ.DATA<2,1> = "INPUTTER"
    ENQ.DATA<3,1> = 'UL'
    ENQ.DATA<4,1> = Y.INPUTTER.ID

    RETURN
    END
