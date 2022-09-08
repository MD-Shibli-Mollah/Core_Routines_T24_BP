* @ValidationCode : MjoxMjAyMTI1ODI0OkNwMTI1MjoxNTY0NTc4MDU0NjQ0OnNyYXZpa3VtYXI6MjowOjA6LTE6ZmFsc2U6Ti9BOkRFVl8yMDE5MDguMDo2Mjo1OQ==
* @ValidationInfo : Timestamp         : 31 Jul 2019 18:30:54
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 59/62 (95.1%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-4</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqSubmit
SUBROUTINE CONV.CHEQUE.TYPE.AC.200705(ACC.NO,CTA.REC,YFILE)

********************************************************************************
*
* 20/02/07 - EN_10003213
*            Count the no of cheques that has been stopped and add those in
*            STOPPED.CHQS field of CHEQUE.REGISTER.
*
* 22/08/14 - Defect 1086246/Task 1094320
*            Modified das to select to improve performance problem
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Submit as ST_ChqSubmit and include $PACKAGE
*
* 25/11/15 - Defect 1537233 / Task 1543939
*            Modified the conversion selection to payment.stop to improve the performance
*
* 14/11/17 - Defect 2332080 / Task 2343861
*            Record variable to read CHEQUE.TYPE.ACCOUNT should not be
*            the same as incoming PAYMENT.STOP record.
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
********************************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DAS.CHEQUES.STOPPED
    $INSERT I_F.CHEQUE.TYPE.ACCOUNT
    

    IF R.ACCOUNT.PARAMETER<38> <> "YES" THEN      ;* check for field CHEQUE.REGISTER
        RETURN
    END
   
    FILE.MNEMONIC = FIELD(YFILE,".",1)  ;* Company mnemonic
    FILE.NAME.LENGTH = LEN(YFILE)
    FILE.MNE.LENGTH = LEN(FILE.MNEMONIC)
    FILE.NAME = YFILE[FILE.MNE.LENGTH+2,FILE.NAME.LENGTH]  ;* Extract only the File name exclusing Company mnemonic
        
    IF FILE.NAME NE "PAYMENT.STOP" THEN  ;* Process only Live Payment stop records
        RETURN
    END
    
    GOSUB OPEN.FILES

    GOSUB FORM.ID.LIST
    IF ID.LIST ='' THEN
        RETURN
    END
    GOSUB FORM.STOP.LIST
    GOSUB UPDATE.CHEQUE.REGISTER
RETURN
OPEN.FILES:
    FN.CHEQUES.STOPPED ='F.CHEQUES.STOPPED' ; FV.CHEQUES.STOPPED =''
    CALL OPF(FN.CHEQUES.STOPPED, FV.CHEQUES.STOPPED)

    FN.CHEQUE.REGISTER ='F.CHEQUE.REGISTER' ; FV.CHEQUE.REGISTER =''
    CALL OPF(FN.CHEQUE.REGISTER,FV.CHEQUE.REGISTER)
    
    FN.CHQ.TYPE.ACCT = 'F.CHEQUE.TYPE.ACCOUNT' ; F.CHQ.TYPE.ACCT = ''
    CALL OPF(FN.CHQ.TYPE.ACCT,F.CHQ.TYPE.ACCT)
         
RETURN

FORM.ID.LIST:

    THE.LIST = DAS.CHEQUES.STOPPED$ACCT
    THE.ARGS = ACC.NO:"*"
    CALL DAS("CHEQUES.STOPPED",THE.LIST ,THE.ARGS,'')
    ID.LIST = THE.LIST
RETURN

FORM.STOP.LIST:
* Get the count of stopped cheques for each cheque type for the account
    CHQ.TYPE.REC = ''  ;* Record variable to hold Cheque type account record
    CALL F.READ(FN.CHQ.TYPE.ACCT,ACC.NO,CHQ.TYPE.REC,F.CHQ.TYPE.ACCT,ERR.CODE)  ;* Retrieve Cheque type account record
    STOP.CNT.LIST = ''; STOP.TYPE.LIST = RAISE(CHQ.TYPE.REC)
    LOOP
        REMOVE ID FROM ID.LIST SETTING IDPOS
    WHILE ID:IDPOS
        READ CS.REC  FROM FV.CHEQUES.STOPPED,ID THEN
            NO.OF.TYPE = DCOUNT(CS.REC<3>,@VM)
            FOR NO.REP = 1 TO NO.OF.TYPE
                CHQ.TYPE = CS.REC<3,NO.REP>
                LOCATE CHQ.TYPE IN STOP.TYPE.LIST<1> SETTING CHQ.TYPE.POS THEN
                    STOP.CNT.LIST<CHQ.TYPE.POS> += 1
                END
            NEXT NO.REP
        END
    REPEAT
RETURN
UPDATE.CHEQUE.REGISTER:

    NO.REP1 = DCOUNT(STOP.TYPE.LIST,@FM)
    FOR CRPOS = 1 TO NO.REP1
        CR.TYPE.ID = STOP.TYPE.LIST<CRPOS>
        CR.ID = CR.TYPE.ID:'.':ACC.NO
        READ CR.REC FROM FV.CHEQUE.REGISTER,CR.ID THEN
            CR.REC<9> = STOP.CNT.LIST<CRPOS> ;    ;* Increment STOPPED.CHQS field
            WRITE CR.REC TO FV.CHEQUE.REGISTER,CR.ID
        END
    NEXT CRPOS

RETURN
END
