* @ValidationCode : MjotMTA0NDU2NzcwOkNwMTI1MjoxNTE0NTI4NTU4Mjg4Om1hbmlzZWthcmFua2FyOjE6MDowOi0xOmZhbHNlOk4vQTpERVZfMjAxNzEyLjIwMTcxMTE5LTAxMjQ6MTc6MTc=
* @ValidationInfo : Timestamp         : 29 Dec 2017 11:52:38
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : manisekarankar
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 17/17 (100.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201712.20171119-0124
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 2 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>-2</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AC.ModelBank

SUBROUTINE E.SEB.SEL.CRITERIA
*-----------------------------------------------------------------------------
*
* This subroutine will return the selection criteria for the next
* STMT.ENT.BOOK enquiry to show the linked accounts
* Modification History:
*
* 21/12/17 - Defect 2359566 / Task 2389833
*            Field concatenation which was removed by component code is fixed
*
*-----------------------------------------------------------------------------
    $USING EB.Reports
*
    ORIG.ACCT = EB.Reports.getOData()
    EB.Reports.setOData('')
*
    NO.SEL.ITEMS = DCOUNT(EB.Reports.getEnqSelection()<2>,@VM)
    FOR YI = 1 TO NO.SEL.ITEMS
        IF EB.Reports.getEnqSelection()<2,YI> MATCHES "ACCOUNT":@VM:"ACCOUNT.NUM" THEN
            SEL.ITEM = EB.Reports.getEnqSelection()<2,YI>:' EQ ':ORIG.ACCT
        END ELSE
            tmp = EB.Reports.getEnqSelection()<4,YI>
            SEL.ITEM = EB.Reports.getEnqSelection()<2,YI>:" ":EB.Reports.getEnqSelection()<3,YI>:" ":CONVERT(@SM," ",tmp)
        END
        IF EB.Reports.getOData() THEN
            EB.Reports.setOData(EB.Reports.getOData():'>':SEL.ITEM) ;* Concatenate with existing value
        END ELSE
            EB.Reports.setOData(SEL.ITEM)
        END
    NEXT YI
*
RETURN
*-----------------------------------------------------------------------------
END
