* @ValidationCode : MjozMDA3NDMxMTc6Q3AxMjUyOjE0OTA4NjgwMzUxMDU6YmlrYXNocmFuamFuOjE6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxNzAyLjA6MTc6Nw==
* @ValidationInfo : Timestamp         : 30 Mar 2017 15:30:35
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bikashranjan
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 7/17 (41.1%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-6</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE ST.ModelBank

    SUBROUTINE E.CONV.COMP.CHECK

*-----------------------------------------------------------------------------
* PURPOSE     : Routine to check whether the complaint exist for the customer
* AUTHOR      : Abinanthan K B
* CREATED ON  : 11/02/2011
*
*------------------------------------------------------------------------------
* Modification History:
* ---------------------
*
* 23/04/15 - Enhancement 1263702
*            Changes done to Remove the inserts and incorporate the routine
*
** 30/03/17 - Defect 2066462 / Task 2071787
*            Changes done to run the enq even CR module i s not installed.
*------------------------------------------------------------------------------

    $INSERT I_DAS.CR.CONTACT.LOG
    $USING EB.Reports
    $USING EB.DataAccess
    $USING EB.SystemTables
    $USING ST.CompanyCreation

    LOCATE 'CR' IN EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComApplications)<1,1> SETTING CR.INSTALLED ELSE
    CR.INSTALLED = ''
    END

    IF CR.INSTALLED THEN
        TABLE.NAME   = "CR.CONTACT.LOG"
        TABLE.SUFFIX = ""
        DAS.LIST     = DAS.COMPLAINT$COMP.STAT
        ARGUMENTS = EB.Reports.getOData():@FM:"'COMPLAINT'":@FM:"'CONFIRMED'":@FM:"'REJECTED'"

        EB.DataAccess.Das(TABLE.NAME, DAS.LIST, ARGUMENTS, TABLE.SUFFIX)

        IF DAS.LIST NE "" THEN
            EB.Reports.setOData(1)
        END ELSE
            EB.Reports.setOData('')
        END

    END

    RETURN
*-----------------------------------------------------------------------------

    END
