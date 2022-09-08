* @ValidationCode : MjoxNTkwMTUzODc6Q3AxMjUyOjE2MTA1NDYyMzA3NjE6cGF2aXRocmEubW9oYW46LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTAxLjIwMjAxMjI2LTA2MTg6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Jan 2021 19:27:10
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : pavithra.mohan
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202101.20201226-0618
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>652</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqIssue

SUBROUTINE CHEQUE.ISSUE.FIELD.DEFINITIONS
*-----------------------------------------------------------------------------
*
*----------------------------------------------------------------------------------------
* Modification History :
*
* 19/02/99 - GB9900129
*            Add new reserved fields.
*
*            This application must additionally check to see that if the
*            field CHEQUE.NOS.USED has been set to 'YES' the cheque nos.
*            being issued here do not exist in the field CHEQUE.NOS.USED
*
*            If the CHEQUE.REGISTER field on the ACCOUNT.PARAMETER record
*            has been set to 'YES' and the CHEQUE.TYPE of the cheques being
*            issued have not been linked to a TRANSACTION record then an
*            error must be thrown at the user. The concat file TRN.CHQ.TRNS
*            could be used to check this.
*
* 06/09/01 - GLOBUS_EN_10000101
*            Enhanced Cheque.Issue to collect charges at each Status
*            and link to Soft Delivery
*            Changed Cheque.Issue to standard template
*            Changed all values captured in ER to capture in E
*            - All the variables are set in I_CI.COMMON
*
*            New fields added to the template are
*            - Cheque.Status
*            - Chrg.Code
*            - Chrg.Amount
*            - Tax.Code
*            - Tax.Amt
*            - Waive.Charges
*            - Class.Type       : -   Link to Soft Delivery
*            - Message.Class    : -      -  do  -
*            - Activity         : -      -  do  -
*            - Delivery.Ref     : -      -  do  -
*
* 17/10/01 - GLOBUS_BG_100000146
*            Modification of definition of field NOTES corrected
*
* 20/11/01 - GLOBUS_CI_10000527
*            Modifying N array of field CHQ.NO.START with correct format
*
* 14/02/02 - GLOBUS_EN_10000353
*            Introduce the fields STOCK.REGISTER,STOCK.NUMBER, SERIES.ID for stock
*            application.
*
*18/03/02 -  GLOBUS_BG_100000738
*            STOCK.REGISTER,SERIES.ID & AUTO.CHEQUE.NO made noinputtable field.
*
* 26/03/02 - GLOBUS_BG_100000778
*            Include check field validation for STOCK.REG. & SERIES.ID
*
* 12/07/05 - EN_10002578
*            Browser issues in CC.
*            SERIES.ID and STOCK.REG is made as inputtable fields.
*            This is because, when SERIES.ID is made as HOT.FIELD to populate CHQ.NO.START, check.fields will
*            will not get trigerred for SERIES.ID, as this is defined as NOINPUT field in template level.
*
* 14/12/06 - BG_100012531
*            Problem with CHQ.NO.START field.
*
* 07/02/07 - EN_10003189
*            When LAST.EVENT.SEQ of CHEQUE.REGISTER reaches 99999 no new cheque issue record
*            is being allowed to input.
*
* 28/06/07 - CI_10051630
*            T array fields are made as inputtable for easy handling of Browser.
*
* 04/03/09 - CI_10061060
*            The length of cheque number is increased
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Issue as ST_ChqIssue and include $PACKAGE
*
* 14/08/15 - Enhancement 1265068 / Task 1387491
*           - Routine incorporated
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*13/01/2021 - Enhancement 3784714 / Task 3784714
*            Introduced new field TAX.ID and TAX.AMOUNT for tax code,tax amount based on charge amount
* -----------------------------------------------------------------------------------------
*
    $USING CQ.ChqConfig
    $USING EB.Delivery
    $USING EB.API
    $USING EB.SystemTables
    $USING CQ.ChqIssue

*
*-----------------------------------------------------------------------------
    GOSUB INITIALISE

    GOSUB DEFINE.FIELDS

RETURN
*
*-----------------------------------------------------------------------------
*
DEFINE.FIELDS:

    OBJECT.ID="ACCOUNT"
    CQ.ChqIssue.setCqMaxLen("")
    MAX.LEN = CQ.ChqIssue.getCqMaxLen()
    EB.API.GetObjectLength(OBJECT.ID,MAX.LEN)
    CQ.ChqIssue.setCqMaxLen(MAX.LEN)
    ID.LEN=13+CQ.ChqIssue.getCqMaxLen()      ;* EN_10003189 - S/E
*
    EB.SystemTables.setIdF("CHEQUE.TYPE.NO"); EB.SystemTables.setIdN(ID.LEN:'.1'); EB.SystemTables.setIdT("A")
    Z = 0

*EN_10000101 -s
    Z +=1 ; EB.SystemTables.setF(Z, 'CHEQUE.STATUS'); EB.SystemTables.setN(Z, '2..C'); EB.SystemTables.setT(Z, '')
    EB.SystemTables.setCheckfile(Z, 'CHEQUE.STATUS':@FM:CQ.ChqConfig.ChequeStatus.ChequeStsDescription)
*EN_10000101 -e
    Z +=1 ; EB.SystemTables.setF(Z, 'ISSUE.DATE'); EB.SystemTables.setN(Z, '11..C'); EB.SystemTables.setT(Z, 'D')
    Z +=1 ; EB.SystemTables.setF(Z, 'NUMBER.ISSUED'); EB.SystemTables.setN(Z, '5..C'); EB.SystemTables.setT(Z, '')
    Z +=1 ; EB.SystemTables.setF(Z, 'CURRENCY'); EB.SystemTables.setN(Z, '3..C'); EB.SystemTables.setT(Z, 'CCY'); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    Z +=1 ; EB.SystemTables.setF(Z, 'CHARGES'); EB.SystemTables.setN(Z, '019..C'); EB.SystemTables.setT(Z, 'AMT'); tmp=EB.SystemTables.getT(Z); tmp<2,2>=CQ.ChqIssue.ChequeIssue.ChequeIsCurrency; EB.SystemTables.setT(Z, tmp)
    Z +=1 ; EB.SystemTables.setF(Z, 'CHARGE.DATE'); EB.SystemTables.setN(Z, '11..C'); EB.SystemTables.setT(Z, 'D')

* GLOBUS_EN_10000353 -S

** GLOBUS_BG_100000738 -S

    Z+=1 ; EB.SystemTables.setF(Z, "STOCK.REG"); EB.SystemTables.setN(Z, "35..C"); EB.SystemTables.setT(Z, "A");* GLOBUS_BG_100000778  ;*EN_10002578 S
    EB.SystemTables.setCheckfile(Z, "STOCK.REGISTER":@FM:@FM:"L")
    Z+=1 ; EB.SystemTables.setF(Z, "SERIES.ID"); EB.SystemTables.setN(Z, "35..C"); tmp=EB.SystemTables.getT(Z); tmp<1>="A"; EB.SystemTables.setT(Z, tmp);* GLOBUS_BG_100000778 ;*EN_10002578 E

** GLOBUS_BG_100000738 -E

* GLOBUS _EN_10000353 -E

*     Chq.No.Start is accepted only when status is like 'ISSUE',
*     otherwise it is not accepted

*      Z +=1 ; F(Z)='CHQ.NO.START' ; N(Z)='14..C' ; T(Z)='' ; T(Z)<3>='NOCHANGE'  ; *EN_10000101
    Z +=1 ; EB.SystemTables.setF(Z, 'CHQ.NO.START'); EB.SystemTables.setN(Z, '0035..C'); EB.SystemTables.setT(Z, '')

*      Z +=1 ; F(Z)='XX.NOTES' ; N(Z)='35' ; T(Z)='A'      ; * EN_10000101 - commented
*      Z +=1 ; F(Z)='NOTES' ; N(Z)='35' ; T(Z)='TEXT'         ; * EN_10000101
    Z +=1 ; EB.SystemTables.setF(Z, 'XX.NOTES'); EB.SystemTables.setN(Z, '35'); EB.SystemTables.setT(Z, 'S'); tmp=EB.SystemTables.getT(Z); tmp<7>='TEXT'; EB.SystemTables.setT(Z, tmp);* BG_100000146

*EN_10000101 -s
    Z +=1 ; EB.SystemTables.setF(Z, 'XX<CHG.CODE'); EB.SystemTables.setN(Z, '20..C'); EB.SystemTables.setT(Z, 'CHG'); tmp=EB.SystemTables.getT(Z); tmp<2>='CHG':@VM:'COM'; EB.SystemTables.setT(Z, tmp)
    Z +=1 ; EB.SystemTables.setF(Z, 'XX>CHG.AMOUNT'); EB.SystemTables.setN(Z, '019..C'); EB.SystemTables.setT(Z, 'AMT'); tmp=EB.SystemTables.getT(Z); tmp<2,2>=CQ.ChqIssue.ChequeIssue.ChequeIsCurrency; EB.SystemTables.setT(Z, tmp)
    Z +=1 ; EB.SystemTables.setF(Z, 'XX<TAX.CODE'); EB.SystemTables.setN(Z, '3..C'); EB.SystemTables.setT(Z, 'CHG'); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    Z +=1 ; EB.SystemTables.setF(Z, 'XX>TAX.AMT'); EB.SystemTables.setN(Z, '019..C'); EB.SystemTables.setT(Z, 'AMT'); tmp=EB.SystemTables.getT(Z); tmp<2,2>=CQ.ChqIssue.ChequeIssue.ChequeIsCurrency; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)

    Z +=1 ; EB.SystemTables.setF(Z, 'WAIVE.CHARGES'); EB.SystemTables.setN(Z, '3.1.C'); tmp=EB.SystemTables.getT(Z); tmp<2>='YES_NO'; EB.SystemTables.setT(Z, tmp)
    Z += 1 ; EB.SystemTables.setF(Z, 'XX<CLASS.TYPE'); EB.SystemTables.setN(Z, '20..C');
    tmp=EB.SystemTables.getT(Z); tmp<2>="USERDEFINE.1_USERDEFINE.2_USERDEFINE.3_USERDEFINE.4_USERDEFINE.5_USERDEFINE.6_USERDEFINE.7_USERDEFINE.8_USERDEFINE.9"; EB.SystemTables.setT(Z, tmp)
    Z += 1 ; EB.SystemTables.setF(Z, 'XX>MESSAGE.CLASS'); EB.SystemTables.setN(Z, '15..C'); EB.SystemTables.setT(Z, 'SSS')
    EB.SystemTables.setCheckfile(Z, "EB.MESSAGE.CLASS":@FM:EB.Delivery.MessageClass.McDescription)
    Z +=1 ; EB.SystemTables.setF(Z, 'ACTIVITY'); EB.SystemTables.setN(Z, '5'); EB.SystemTables.setT(Z, 'A'); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    Z +=1 ; EB.SystemTables.setF(Z, 'XX.DELIVERY.REF'); EB.SystemTables.setN(Z, '16'); EB.SystemTables.setT(Z, 'A'); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
* EN_10000101 -e

* GB9900129 (Starts)

** GLOBUS_EN_10000353 - S

    Z+=1 ; EB.SystemTables.setF(Z, "AUTO.CHEQUE.NUMBER"); EB.SystemTables.setN(Z, "20"); tmp=EB.SystemTables.getT(Z); tmp<1>="A"; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<3>="NOINPUT"; EB.SystemTables.setT(Z, tmp)

** GLOBUS_EN_10000353 - E
    
    Z+=1 ; EB.SystemTables.setF(Z, "XX<TAX.ID"); EB.SystemTables.setN(Z, "16");EB.SystemTables.setT(Z, "A") ;  tmp=EB.SystemTables.getT(Z);tmp<3>="NOINPUT"; EB.SystemTables.setT(Z, tmp)
    Z+=1 ; EB.SystemTables.setF(Z, "XX>TAX.AMOUNT"); EB.SystemTables.setN(Z, "19");EB.SystemTables.setT(Z, "AMT"); tmp=EB.SystemTables.getT(Z);tmp<3>="NOINPUT"; EB.SystemTables.setT(Z, tmp)
    Z+=1 ; EB.SystemTables.setF(Z, "RESERVED.7"); EB.SystemTables.setN(Z, "35"); tmp=EB.SystemTables.getT(Z); tmp<1>="A"; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<3>="NOINPUT"; EB.SystemTables.setT(Z, tmp)
    Z+=1 ; EB.SystemTables.setF(Z, "RESERVED.6"); EB.SystemTables.setN(Z, "35"); tmp=EB.SystemTables.getT(Z); tmp<1>="A"; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<3>="NOINPUT"; EB.SystemTables.setT(Z, tmp)
    Z+=1 ; EB.SystemTables.setF(Z, "RESERVED.5"); EB.SystemTables.setN(Z, "35"); tmp=EB.SystemTables.getT(Z); tmp<1>="A"; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<3>="NOINPUT"; EB.SystemTables.setT(Z, tmp)
    Z+=1 ; EB.SystemTables.setF(Z, "RESERVED.4"); EB.SystemTables.setN(Z, "35"); tmp=EB.SystemTables.getT(Z); tmp<1>="A"; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<3>="NOINPUT"; EB.SystemTables.setT(Z, tmp)
    Z+=1 ; EB.SystemTables.setF(Z, "RESERVED.3"); EB.SystemTables.setN(Z, "35"); tmp=EB.SystemTables.getT(Z); tmp<1>="A"; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<3>="NOINPUT"; EB.SystemTables.setT(Z, tmp)
    Z+=1 ; EB.SystemTables.setF(Z, "RESERVED.2"); EB.SystemTables.setN(Z, "35"); tmp=EB.SystemTables.getT(Z); tmp<1>="A"; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<3>="NOINPUT"; EB.SystemTables.setT(Z, tmp)
    Z+=1 ; EB.SystemTables.setF(Z, "RESERVED.1"); EB.SystemTables.setN(Z, "35"); tmp=EB.SystemTables.getT(Z); tmp<1>="A"; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<3>="NOINPUT"; EB.SystemTables.setT(Z, tmp)
* GB9900129 (Ends)
    Z+=1 ; EB.SystemTables.setF(Z, 'XX.LOCAL.REF'); EB.SystemTables.setN(Z, '35'); EB.SystemTables.setT(Z, 'A')
* EN_10000101 -s
    Z+=1 ; EB.SystemTables.setF(Z, 'XX.STMT.NO'); EB.SystemTables.setN(Z, "35"); tmp=EB.SystemTables.getT(Z); tmp<1>='A'; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    Z+=1 ; EB.SystemTables.setF(Z, 'XX.OVERRIDE'); EB.SystemTables.setN(Z, "35"); tmp=EB.SystemTables.getT(Z); tmp<1>='A'; EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
* EN_10000101 -e
******
    EB.SystemTables.setV(Z + 9)
RETURN
*
*-----------------------------------------------------------------------------
*
INITIALISE:
*----------
    EB.SystemTables.clearF()
    EB.SystemTables.clearN()
    EB.SystemTables.clearT()
    EB.SystemTables.clearCheckfile()
    EB.SystemTables.clearConcatfile()
    EB.SystemTables.setIdCheckfile(""); EB.SystemTables.setIdConcatfile("AL")

RETURN
*-----------(Initialise)

*-----------------------------------------------------------------------------

END
*-----(End of Cheque.Issue.Field.Definitions)
