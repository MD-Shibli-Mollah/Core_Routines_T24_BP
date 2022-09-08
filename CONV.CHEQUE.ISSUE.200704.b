* @ValidationCode : MjotNTM4OTc5MzM6Q3AxMjUyOjE1NjQ1NzE0NTYzNDg6c3JhdmlrdW1hcjotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxOTA4LjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 Jul 2019 16:40:56
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-42</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqIssue
SUBROUTINE CONV.CHEQUE.ISSUE.200704(CI.ID,CI.REC,YFILE)

********************************************************************************
* 07/02/07 - EN_10003189
*            Conversion routine to add zeros to the sequence no which has 5
*            characters. Any sequence no which is less than 5 is left as it is
*            since they are manual input.
*
* 02/02/10 - DFT:15257;TASK:18776
*            CHEQUE.ISSUE$HIS not opened after upgrade from R06 to R08
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Issue as ST_ChqIssue and include $PACKAGE
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
********************************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN

INITIALISE:
    U.MNE = ''
    SAVE.CI.ID = ''
    CHQ.ISS.REC = ''
    ZEROS.TO.BE.ADDED = '' ; I = ''
    U.MNE = FIELD(YFILE,'.',1)

    FN.CHEQUE.ISSUE = YFILE
    FV.CHEQUE.ISSUE = ''
    CALL OPF(FN.CHEQUE.ISSUE,FV.CHEQUE.ISSUE)

    FN.CHQ.ISS.ACC = U.MNE:'.':'CHEQUE.ISSUE.ACCOUNT'
    FV.CHQ.ISS.ACC = ''

    CALL OPF(FN.CHQ.ISS.ACC,FV.CHQ.ISS.ACC)
RETURN

PROCESS:
    DELETE FV.CHEQUE.ISSUE,CI.ID

    CHQ.TYPE = FIELD(CI.ID,'.',1)
    ACC.NO = FIELD(CI.ID,'.',2)
    SEQ.NO = FIELD(CI.ID,'.',3)

    HIS.NO = FIELD(SEQ.NO,';',2)
    SEQ.NO = FIELD(SEQ.NO,';',1)
    IF LEN(SEQ.NO) EQ '5' THEN
        SEQ.NO = '00':SEQ.NO
    END
    SAVE.CI.ID = CI.ID
    CI.ID = CHQ.TYPE:'.':ACC.NO:'.':SEQ.NO

    IF HIS.NO THEN
        CI.ID:= ';':HIS.NO
    END ELSE
        GOSUB PROCESS.CHEQUE.ISSUE.ACCOUNT ;*For live record update the CHEQUE.ISSUE.ACCOUNT
    END
RETURN

PROCESS.CHEQUE.ISSUE.ACCOUNT:

    READ CHQ.ISS.REC FROM FV.CHQ.ISS.ACC,ACC.NO THEN
        LOCATE SAVE.CI.ID IN CHQ.ISS.REC<1> SETTING POS THEN
            CHQ.ISS.REC<POS> = CI.ID
        END
        WRITE CHQ.ISS.REC TO FV.CHQ.ISS.ACC,ACC.NO
    END
RETURN

END
