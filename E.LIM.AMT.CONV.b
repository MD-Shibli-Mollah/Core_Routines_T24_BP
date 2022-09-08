* @ValidationCode : MjotMTUyNTI2NTY1OTpDcDEyNTI6MTU1MjQ4NjQwMzU5NDpzcmVlY2hhcmFuOjQ6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDMuMjAxOTAyMDktMDQwMToxNToxMw==
* @ValidationInfo : Timestamp         : 13 Mar 2019 19:43:23
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sreecharan
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 13/15 (86.6%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201903.20190209-0401
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE LI.ModelBank
SUBROUTINE E.LIM.AMT.CONV
*-----------------------------------------------------------------------------
* Conversion routine to round off and format the length of amount fields in LIAB
* Liab enq was using comversion and Lenth format as MD0, and 20R, which is triggered
* even whent the row is empty (i.e. in case of joint customers, customer MVs can be
* higher than timecode MVs so amounts could be NULL which is ignored here
*-----------------------------------------------------------------------------
* Modification History :
*
* 21/11/17 - EN 2232234 / Task 2232237
*            Creation of this routine
*
* 04/04/18 - defect 2528827 / task 2535030
*            on launching LIM.TRADE enquiry,limit amount must be formatted by 20R
*            so that amount gets displayed
*
* 3/2/19 - Defect 3015788 / Task 3016210
*          Support for duplicate enquiries to LIAB & LIM.TRADE, duplicate enquiry
*          is expected to have LIAB or LIM.TRADE as a part of enquiry name.
*-----------------------------------------------------------------------------
    $USING EB.Reports
*-----------------------------------------------------------------------------

    AmtBeforeConv = EB.Reports.getOData()
    Key = EB.Reports.getId()
    EnqName = EB.Reports.getEnqSelection()<1,1>
* this conversion routine has been attached currrntly to LIM.TRADE and LIAB enquiries only
* if enquiry is LIAB, then format with 20R,
* if enquiry is LIM.TRADE, then format with 20R
    IF AmtBeforeConv NE '' OR Key[1,2] NE "LI" THEN
        AmtAfterConv = AmtBeforeConv
        BEGIN CASE
            CASE INDEX(EnqName,"LIAB",1)
                AmtAfterConv = OCONV(AmtBeforeConv, "MD0,")
                AmtAfterConv = FMT(AmtAfterConv, "20R,")
            CASE INDEX(EnqName,"LIM.TRADE",1)
                AmtAfterConv = FMT(AmtAfterConv, "20R")
        END CASE
        EB.Reports.setOData(AmtAfterConv)
    END

RETURN
END
