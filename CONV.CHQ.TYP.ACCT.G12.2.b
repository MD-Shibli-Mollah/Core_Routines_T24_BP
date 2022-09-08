* @ValidationCode : MjoxNzEyOTk2MTQ3OkNwMTI1MjoxNTY0NTc4MDMxNTYzOnNyYXZpa3VtYXI6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTkwOC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 Jul 2019 18:30:31
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
* <Rating>42</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqSubmit
SUBROUTINE CONV.CHQ.TYP.ACCT.G12.2(CHQ.REG.ID,R.CHEQ.REG,FV.CHEQ.REG)

*      Conversion routine to pick up the CHQ.TYPE from CHEQUE.REGISTER id in
*      all the branches and update the CHEQUE.TYPE.ACCOUNT.

* 18/05/02 - GLOBUS_BG_100001067
*            Conversion done only if CHEQUE.REGISTER in ACCOUNT.PARAMETER IS "yes"
*
* 27/01/03 - CI_10006448
*            Change the F.READU and F.WRITE to READ and WRITE,
*            to avoid locks and dump the record into the disk straight instead of the cache.
*
* 13/11/03 - CI_10014719
*            If the record not fount in CHEQUE.TYPE.ACCOUNT, create a new record
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Submit as ST_ChqSubmit and include $PACKAGE
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
*-------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT.PARAMETER   ; * GLOBUS_BG_100001067

    FN.CHEQ.TYP.ACCT = "F.CHEQUE.TYPE.ACCOUNT"
    FV.CHEQ.TYP.ACCT = ""
    CALL OPF(FN.CHEQ.TYP.ACCT,FV.CHEQ.TYP.ACCT)
    CHQ.TYP.REC = ""                   ; **CI_10006448 - S/E.

    IF R.ACCOUNT.PARAMETER<AC.PAR.CHEQUE.REGISTER> = "YES" THEN      ; * GLOBUS_BG_100001067
        HIS.OR.NOT = INDEX(CHQ.REG.ID, ';',1)
        IF NOT(HIS.OR.NOT) THEN

            ACCT.ID = FIELD(CHQ.REG.ID,".",2)
            CHQ.TYPE = FIELD(CHQ.REG.ID,".",1)

**            CALL F.READU("F.CHEQUE.TYPE.ACCOUNT",ACCT.ID,CHQ.TYP.REC,FV.CHEQ.TYP.ACCT,ERR2,"")
            READ CHQ.TYP.REC FROM FV.CHEQ.TYP.ACCT, ACCT.ID THEN       ; ** CI_10006448 - S/E.
                LOCATE CHQ.TYPE IN CHQ.TYP.REC<1,1> SETTING POS ELSE
                    CHQ.TYP.REC<1,-1> = CHQ.TYPE
                    WRITE CHQ.TYP.REC TO FV.CHEQ.TYP.ACCT, ACCT.ID       ; ** CI_10006448 - S/E.
                END
* CI_10014719 - S
            END ELSE
                CHQ.TYP.REC = CHQ.TYPE
                WRITE CHQ.TYP.REC TO FV.CHEQ.TYP.ACCT, ACCT.ID
* CI_10014719 - E
            END


**            CALL F.WRITE("F.CHEQUE.TYPE.ACCOUNT",ACCT.ID,CHQ.TYP.REC) ;** Change F.WRITE to WRITE and move within loop statement.
        END
    END                                ; * GLOBUS_BG_100001067
RETURN
END
