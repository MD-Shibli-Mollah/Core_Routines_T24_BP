* @ValidationCode : Mjo0NzA3NjE5MDY6Q3AxMjUyOjE1ODQ2MTYzNTU2MDc6cnZhcmFkaGFyYWphbjotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDMuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 19 Mar 2020 16:42:35
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : rvaradharajan
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202003.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>595</Rating>
*-----------------------------------------------------------------------------
* Version 2 16/05/01  GLOBUS Release No. 200511 31/10/05
*
*************************************************************************
*
$PACKAGE SC.SccReports
SUBROUTINE E.DIV.COUP.ENTL.HEADER
*
*************************************************************************
*
* Modification History:
*
* 17/04/97 - GB9700451
*            New sub-routine used to build information to be used on the
*            enquiry DIV.COUP.ENTL
*
* 22/6/15 - 1322379 Task:1334804
*           Incorporation of components
*
* 03/02/2020 - Enhancement 3568228 / Task 3569215
*            Changing reference of routines that have been moved from ST to CG
*************************************************************************
*
    $USING EB.Reports
    $USING SC.SccEventCapture
    $USING SC.ScoSecurityMasterMaintenance
    $USING CG.ChargeConfig
    $USING ST.Customer
    $USING EB.ErrorProcessing
    $INSERT I_CustomerService_NameAddress
    $USING EB.SystemTables

    GOSUB INITIALISATION
*
    GOSUB DO.THE.PROCESSING
*
RETURN

*
*------------------------------------------------------------------
*
INITIALISATION:
*-------------
*
    DIARY.ID = EB.Reports.getOData()
*

RETURN
*
*-----------------------------------------------------------------
*
DO.THE.PROCESSING:
*----------------
*


    R.DIARY = SC.SccEventCapture.Diary.Read(DIARY.ID, READ.ERR)
* Before incorporation : CALL F.READ("F.DIARY",DIARY.ID,R.DIARY,tmp.F.DIARY,READ.ERR)


    EB.Reports.setOData("")

    IF NOT(READ.ERR) THEN
*
** Fill up the details in O.DATA
*


        R.SECURITY.MASTER = SC.ScoSecurityMasterMaintenance.SecurityMaster.Read(R.DIARY<SC.SccEventCapture.Diary.DiaSecurityNo>, READ.ERR)
* Before incorporation : CALL F.READ("F.SECURITY.MASTER",R.DIARY<SC.SccEventCapture.Diary.DiaSecurityNo>,R.SECURITY.MASTER,tmp.F.SECURITY.MASTER,READ.ERR)



        EB.Reports.setOData(R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmDescript>:">")
        EB.Reports.setOData(R.DIARY<SC.SccEventCapture.Diary.DiaEventType>:">")
        EB.Reports.setOData(R.DIARY<SC.SccEventCapture.Diary.DiaRate>:">")
        EB.Reports.setOData(R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmNoOfPayments>:">")
        EB.Reports.setOData(R.DIARY<SC.SccEventCapture.Diary.DiaCurrency>:">")
        EB.Reports.setOData(R.DIARY<SC.SccEventCapture.Diary.DiaExDate>:">")
        EB.Reports.setOData(R.DIARY<SC.SccEventCapture.Diary.DiaPayDate>:">")
        EB.Reports.setOData(R.DIARY<SC.SccEventCapture.Diary.DiaSourceTaxPerc>:">")
        EB.Reports.setOData(R.DIARY<SC.SccEventCapture.Diary.DiaForeignCharges>:">")
        EB.Reports.setOData(R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmSecurityCurrency>:">")
        EB.Reports.setOData(R.DIARY<SC.SccEventCapture.Diary.DiaValueDate>:">")
        EB.Reports.setOData(R.DIARY<SC.SccEventCapture.Diary.DiaLocalTaxPerc>:">")

        IF R.DIARY<SC.SccEventCapture.Diary.DiaCommissionCode> THEN


            R.FT.COMMISSION.TYPE = CG.ChargeConfig.FtCommissionType.Read(R.DIARY<SC.SccEventCapture.Diary.DiaCommissionCode>, READ.ERR)
* Before incorporation : CALL F.READ("F.FT.COMMISSION.TYPE",R.DIARY<SC.SccEventCapture.Diary.DiaCommissionCode>,R.FT.COMMISSION.TYPE,tmp.F.FT.COMMISSION.TYPE,READ.ERR)


            IF NOT(READ.ERR) THEN
                EB.Reports.setOData(R.FT.COMMISSION.TYPE<CG.ChargeConfig.FtCommissionType.FtFouPercentage>)
            END ELSE
                EB.Reports.setOData(">")
            END
        END ELSE
            EB.Reports.setOData(">")
        END
        EB.Reports.setOData(R.DIARY<SC.SccEventCapture.Diary.DiaDepNo>:">")
        NO.OF.DEPOTS = DCOUNT(R.DIARY<SC.SccEventCapture.Diary.DiaDepNo>,@VM)

        DEPOT.NAMES = ""
        FOR I = 1 TO NO.OF.DEPOTS
            DEPOT.ID = R.DIARY<SC.SccEventCapture.Diary.DiaDepNo,I>

            customerKey = DEPOT.ID
            customerNameAddress = ''
            prefLang = EB.SystemTables.getLngg()
            CALL CustomerService.getNameAddress(customerKey,prefLang,customerNameAddress)
            IF EB.SystemTables.getEtext() = '' THEN
                DEPOT.NAME<1,I> = customerNameAddress<NameAddress.name1>
            END ELSE
                DEPOT.NAME<1,I> = 'Name not found'
                EB.SystemTables.setEtext('')
            END

        NEXT I
        EB.Reports.setOData(DEPOT.NAMES:">")
    END

RETURN
*
*------------------------------------------------------------------
*
PROGRAM.ABORT:
*------------

    EB.ErrorProcessing.FatalError("E.DIV.COUP.ENTL.HEADER")

RETURN
*
*------------------------------------------------------------------
*
END
