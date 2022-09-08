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
* <Rating>-67</Rating>
*-----------------------------------------------------------------------------
* Version 5 31/05/01  GLOBUS Release No. G12.0.00 29/06/01
    $PACKAGE SC.SctSettlement
    SUBROUTINE E.SC.SETT.BUILD.REC
*
*************************************************************************
*** <region name= Modification History>
*** <desc>Modification History </desc>
*
* 11/10/00 - GB0002583
*            Contractual & Actual Settlement Enhancement
*            Called from ENQUIRY SC.UNSETTLED.RPT
*
* 23/10/00 - GB0002722
*            Bug - Variable "SC.SET.CUS.UNSETTLED.NOM" and
*            "SC.SET.CUS.UNSETTLED.AMT" never assigned a value.
*
* 28/11/00 - GB0003090
*            Bug - Improper data type.
*
* 20/02/01 - GB0100463
*            The previous fix is not necessary.
*            Add in the Security enrichment in R.RECORD<22>.
*            Also report the CR & DR values separately.
*
* 13/08/2001 - GLOBUS_BG_100000029
*              Bug - 1) Including the signs for the cash side in
*              enquiry.
*              2) The nominals were automatically settled, when the
*              cash side of the transaction was settled.
*              3) TRANS.CODE value was picked up from the R.NEW,
*              that's been fixed now.
*
* 23/04/08 - GLOBUS_BG_100018233 cgraf@temenos.com
*            VNA after introduction of customer level settlement records
*
* 25/11/08 - GLOBUS_BG_100020996 - dgearing@temenos.com
*            Remove commented out code, remove unused code
*
* 20/07/10 - 68871: Amend SC routines to use the Customer Service API's
*
* 27-01-16 - 1605749
*            Incorporation of components
*************************************************************************
*** </region>
*** <region name= Inserts>
*** <desc>Inserts </desc>
    $INSERT I_CustomerService_NameAddress

    $USING SC.SctSettlement
    $USING SC.ScoPortfolioMaintenance
    $USING SC.ScoSecurityPositionUpdate
    $USING SC.ScoSecurityMasterMaintenance
    $USING EB.SystemTables
    $USING EB.Reports

*** </region>
*************************************************************************

    GOSUB OPEN.FILES

    GOSUB BUILD.R.RECORD

    RETURN

**************************************************************************
OPEN.FILES:
*----------

    RETURN

**************************************************************************
BUILD.R.RECORD:
*--------------

    YKEY = EB.Reports.getOData()
    EB.Reports.setVmCount(1)
    EB.Reports.setSmCount(1)

    R.SC.SETTLEMENT = ""
    R.SC.SETTLEMENT = SC.SctSettlement.Settlement.ReadNau(YKEY, ER)
* Before incorporation : CALL F.READ('F.SC.SETTLEMENT$NAU',YKEY,R.SC.SETTLEMENT,F.SC.SETTLEMENT$NAU,ER)
    IF ER THEN
        R.SC.SETTLEMENT = SC.SctSettlement.Settlement.Read(YKEY, ER)
        * Before incorporation : CALL F.READ('F.SC.SETTLEMENT',YKEY,R.SC.SETTLEMENT,F.SC.SETTLEMENT,ER)
        IF ER THEN
            RETURN
        END
    END

    tmp=EB.Reports.getRRecord(); tmp<11>=R.SC.SETTLEMENT<SC.SctSettlement.Settlement.SettSecurityNumber>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<12>=R.SC.SETTLEMENT<SC.SctSettlement.Settlement.SettDepository>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<13>=R.SC.SETTLEMENT<SC.SctSettlement.Settlement.SettTradeDate>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<14>=R.SC.SETTLEMENT<SC.SctSettlement.Settlement.SettValueDate>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<15>=R.SC.SETTLEMENT<SC.SctSettlement.Settlement.SettTradeCcy>; EB.Reports.setRRecord(tmp)

* Determine the Sc.Settlement is a CR or DR stock movement

    TRANS.CODE = R.SC.SETTLEMENT<SC.SctSettlement.Settlement.SettTransCode>
* Now get the Security Short Name
    SM.SHORT.NAME = ''
    ERR = ''
    R.SECURITY.MASTER = SC.ScoSecurityMasterMaintenance.SecurityMaster.Read(R.SC.SETTLEMENT<SC.SctSettlement.Settlement.SettSecurityNumber>, ERR)
* Before incorporation : CALL F.READ('F.SECURITY.MASTER',R.SC.SETTLEMENT<SC.SctSettlement.Settlement.SettSecurityNumber>,R.SECURITY.MASTER,'',ERR)
    ENRI2=R.SECURITY.MASTER<SC.ScoSecurityMasterMaintenance.SecurityMaster.ScmShortName>
    X = EB.SystemTables.getLngg()
    IF X > 1 AND ENRI2<1,X> = "" THEN
        X = 1
    END
    SM.SHORT.NAME = ENRI2<1,X>
    tmp=EB.Reports.getRRecord(); tmp<22>=SM.SHORT.NAME; EB.Reports.setRRecord(tmp)

    MAX.BROKER = DCOUNT(R.SC.SETTLEMENT<SC.SctSettlement.Settlement.SettBrokerNo>,@VM)
    FOR I = 1 TO MAX.BROKER
        GOSUB ADD.BROKER.DETS ; *Add broker settlement details
    NEXT I
    tmp=EB.Reports.getRRecord(); tmp<20,1>="Broker :"; EB.Reports.setRRecord(tmp)
    I = DCOUNT(EB.Reports.getRRecord()<20>,@VM) + 1    ; *BG_100018233 Add a line to the array
    tmp=EB.Reports.getRRecord(); tmp<20,I>=" "; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<20,I+1>="Portfolio :"; EB.Reports.setRRecord(tmp)

    MAX.PORT = DCOUNT(EB.Reports.getRRecord()<SC.SctSettlement.SettleCust.SetCusSecPosKey>,@VM)
    FOR J = 1 TO MAX.PORT
        GOSUB ADD.CUSTOMER.DETS ; *Add customer settlement details
    NEXT J

    GOSUB ADD.BLANK.LINE ; *Add blank like

    EB.Reports.setVmCount(DCOUNT(EB.Reports.getRRecord()<16>,@VM))

    RETURN
*
*-----------------------------------------------------------------------------
*** <region name= ADD.BROKER.DETS>
ADD.BROKER.DETS:
*** <desc>Add broker settlement details </desc>

    customerKey = R.SC.SETTLEMENT<SC.SctSettlement.Settlement.SettBrokerNo,I>
    customerNameAddress = ''
    prefLang = EB.SystemTables.getLngg()
    CALL CustomerService.getNameAddress(customerKey,prefLang,customerNameAddress)
    IF EB.SystemTables.getEtext() = '' THEN
        SHORT.NAME = customerNameAddress<NameAddress.shortName>
    END ELSE
        SHORT.NAME = 'Name not found'
        EB.SystemTables.setEtext('')
    END

    tmp=EB.Reports.getRRecord(); tmp<16,I>=R.SC.SETTLEMENT<SC.SctSettlement.Settlement.SettBrokerNo,I>; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<17,I>=SHORT.NAME; EB.Reports.setRRecord(tmp)
* The values are picked up from BR.NOM.OUTSTAND & BR.AMT.OUTSTAND
* to get the latest values in their respective fields, instead of
* the fields TOTAL.NOMINAL & TOTAL.BR.AMT. The values of the fields
* TOTAL.NOMINAL & TOTAL.BR.AMT doesn't change as they are no input
* fields. Hence, those two fields are used for the latest update.
    BR.NOM = R.SC.SETTLEMENT<SC.SctSettlement.Settlement.SettBrNomOutstand,I>
    tmp=EB.Reports.getRRecord(); tmp<18,I>=BR.NOM; EB.Reports.setRRecord(tmp)
    BR.AMT = R.SC.SETTLEMENT<SC.SctSettlement.Settlement.SettBrAmtOutstand,I>
    tmp=EB.Reports.getRRecord(); tmp<19,I>=BR.AMT; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<20,I>=""; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<21,I>=""; EB.Reports.setRRecord(tmp)

    RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= ADD.CUSTOMER.DETS>
ADD.CUSTOMER.DETS:
*** <desc>Add customer settlement details </desc>

    I = I + 1
    PORTFOLIO.ID = FIELD(EB.Reports.getRRecord()<SC.SctSettlement.SettleCust.SetCusSecPosKey,J>,".",1,1)
    SHORT.NAME = ""
    ERR = ''
    R.SECURITY.MASTER = SC.ScoSecurityMasterMaintenance.SecurityMaster.Read(PORTFOLIO.ID, ERR)
* Before incorporation : CALL F.READ('F.SECURITY.MASTER',PORTFOLIO.ID,R.SECURITY.MASTER,'',ERR)
    SHORT.NAME=R.SECURITY.MASTER<SC.ScoPortfolioMaintenance.SecAccMaster.ScSamAccountName>
    tmp=EB.Reports.getRRecord(); tmp<16,I>=PORTFOLIO.ID; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<17,I>=SHORT.NAME; EB.Reports.setRRecord(tmp)
    CU.NOM = R.SC.SETTLEMENT<SC.SctSettlement.Settlement.SettCuNomOutstand,J>
    tmp=EB.Reports.getRRecord(); tmp<18,I>=CU.NOM; EB.Reports.setRRecord(tmp)
    CU.AMT = R.SC.SETTLEMENT<SC.SctSettlement.Settlement.SettCuAmtOutstand,J>
    tmp=EB.Reports.getRRecord(); tmp<19,I>=CU.AMT; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<21,I>=TRANS.CODE; EB.Reports.setRRecord(tmp)

    RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= ADD.BLANK.LINE>
ADD.BLANK.LINE:
*** <desc>Add blank like </desc>

    tmp=EB.Reports.getRRecord(); tmp<16,I+1>=""; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<17,I+1>=""; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<18,I+1>=""; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<19,I+1>=""; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<20,I+1>=""; EB.Reports.setRRecord(tmp)
    tmp=EB.Reports.getRRecord(); tmp<21,I+1>=""; EB.Reports.setRRecord(tmp)

    RETURN

*** </region>

    END


