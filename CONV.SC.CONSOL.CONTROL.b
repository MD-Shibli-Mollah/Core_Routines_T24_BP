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
* <Rating>1601</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.SctDealerBook
    SUBROUTINE CONV.SC.CONSOL.CONTROL

* This is a conversion routine for SAR-2005-06-27-0003, EN_10002657.
* This conversion routine is a file routine which will read the record CONSOL.CONTROL
* from the file SC.SOD.ACCR and raises call EB.ACCOUNTING for each values for each company.
* In EOD, spec entries are raised in EOD.CONSOL.UPDATE

********************************************************************************************
* 03/01/06 - CI_10037807
*            New Conversion routine
*
* 18/02/08 - BG_100017156
*            As only Spec entries are raised, EB.ENTRY.REC.UPDATE is called and thereby preventing
*            self balancing entries.
*
********************************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.STMT.ENTRY
    $INSERT I_F.COMPANY
    $INSERT I_F.SEC.ACC.MASTER          ;* BG_100017156

INITIALISE:

    DIM HOLD.R.NEW(C$SYSDIM)
    MAT HOLD.R.NEW = ''
    HOLD.ID.NEW = ''

SAVE.COMMON:

    HOLD.ID.NEW = ID.NEW
    MAT HOLD.R.NEW = MAT R.NEW
    SAVE.V = V

PROCESS:

    ORIG.COMPANY = ID.COMPANY
    SEL.CMD = "SSELECT F.COMPANY WITH CONSOLIDATION.MARK EQ 'N'"

    COM.LIST = '' ;  YSEL = 0
    CALL EB.READLIST(SEL.CMD,COM.LIST,'',YSEL,'')
    LOOP
        REMOVE K.COMPANY FROM COM.LIST SETTING COMPANY.POS
    WHILE K.COMPANY:COMPANY.POS
        IF K.COMPANY NE ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
        END
        LOCATE 'SC' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING FOUND.POS THEN
            FN.SC.SOD.ACCR = 'F.SC.SOD.ACCR'
            FV.SC.SOD.ACCR = ''
            CALL OPF(FN.SC.SOD.ACCR,FV.SC.SOD.ACCR)

            FN.SC.TRADING.POSITION = 'F.SC.TRADING.POSITION'
            FV.SC.TRADING.POSITION = ''
            CALL OPF(FN.SC.TRADING.POSITION,FV.SC.TRADING.POSITION)

            FN.SEC.ACC.MASTER = 'F.SEC.ACC.MASTER'
            FV.SEC.ACC.MASTER = ''
            CALL OPF(FN.SEC.ACC.MASTER,FV.SEC.ACC.MASTER)

            V = 68

            CALL F.READ(FN.SC.SOD.ACCR,'CONSOL.CONTROL',R.SC.SOD.ACCR,FV.SC.SOD.ACCR,READ.ERR)

            IF R.SC.SOD.ACCR THEN
                NO.OF.ENTRIES = DCOUNT(R.SC.SOD.ACCR,FM)
                FOR I = 1 TO NO.OF.ENTRIES
                    R.SOD.ACCR = R.SC.SOD.ACCR<I>

                    R.ACCT = ''
                    ID.NEW = R.SOD.ACCR<1,17>
                    STP.SIZE = 74
                    CALL F.MATREAD(FN.SC.TRADING.POSITION,ID.NEW,MAT R.NEW,STP.SIZE,FV.SC.TRADING.POSITION,STP.READ.ERR)
                    SEC.ACC.MASTER.ID = FIELD(ID.NEW,'.',1)

* In a multi Book Environment the Entries should be raised to that company where the SAM has been created.
                    IF C$MULTI.BOOK THEN
                        CALL F.READ(FN.SEC.ACC.MASTER,SEC.ACC.MASTER.ID,R.SEC.ACC.MASTER,FV.SEC.ACC.MASTER,SAM.READ.ERR)
                        SEC.ACC.MASTER.CO.CODE = R.SEC.ACC.MASTER<SC.SAM.CO.CODE>         ;* BG_100017156
                        SAVE.ID.COMPANY  = ID.COMPANY
                        IF SEC.ACC.MASTER.CO.CODE NE ID.COMPANY THEN
                            ID.COMPANY = SEC.ACC.MASTER.CO.CODE
                            CALL LOAD.COMPANY(ID.COMPANY)
                        END
                    END
                    R.ACCT<1,AC.STE.ACCOUNT.NUMBER> = ''
                    R.ACCT<1,AC.STE.COMPANY.CODE> = ID.COMPANY
                    R.ACCT<1,AC.STE.CURRENCY> = R.SOD.ACCR<1,2>
                    IF R.ACCT<1,AC.STE.CURRENCY> EQ LCCY THEN
                        IF R.SOD.ACCR<1,4> = '' THEN LCY.AMT = R.SOD.ACCR<1,5> ELSE LCY.AMT = R.SOD.ACCR<1,4>
                        R.ACCT<1,AC.STE.AMOUNT.LCY> = LCY.AMT
                    END ELSE
                        IF R.SOD.ACCR<1,4> = '' THEN FCY.AMT = R.SOD.ACCR<1,5> ELSE FCY.AMT = R.SOD.ACCR<1,4>
                        IF R.SOD.ACCR<1,6> = '' THEN LCY.AMT = R.SOD.ACCR<1,7> ELSE LCY.AMT = R.SOD.ACCR<1,6>
                        R.ACCT<1,AC.STE.AMOUNT.LCY> = LCY.AMT
                        R.ACCT<1,AC.STE.AMOUNT.FCY> = FCY.AMT
                        R.ACCT<1,AC.STE.EXCHANGE.RATE> = R.SOD.ACCR<1,20>
                        R.ACCT<1,AC.STE.POSITION.TYPE> = "TR"
                    END

                    R.ACCT<1,AC.STE.PL.CATEGORY> = ''
                    R.ACCT<1,AC.STE.CUSTOMER.ID> = R.SOD.ACCR<1,18>
                    R.ACCT<1,AC.STE.PRODUCT.CATEGORY> = R.SOD.ACCR<1,22>
                    R.ACCT<1,AC.STE.VALUE.DATE> = TODAY
                    R.ACCT<1,AC.STE.OUR.REFERENCE> = R.SOD.ACCR<1,17>
                    R.ACCT<1,AC.STE.CURRENCY.MARKET> = "1"
                    R.ACCT<1,AC.STE.TRANS.REFERENCE> = R.SOD.ACCR<1,17>
                    R.ACCT<1,AC.STE.SYSTEM.ID> = "SC"
                    R.ACCT<1,AC.STE.BOOKING.DATE> = TODAY
                    R.ACCT<1,AC.STE.SUPPRESS.POSITION> = 'Y'
                    R.ACCT<1,AC.STE.CRF.TYPE> = R.SOD.ACCR<1,3>
                    R.ACCT<1,AC.STE.CRF.TXN.CODE> = R.SOD.ACCR<1,19>
                    R.ACCT<1,AC.STE.CRF.CURRENCY> = ''
                    R.ACCT<1,AC.STE.CRF.MAT.DATE> = R.SOD.ACCR<1,9>
                    R.ACCT<1,AC.STE.CRF.PROD.CAT> = R.SOD.ACCR<1,22>
* BG_100017156 S
                    CURRTIME = ""       ;* Used for Id update
                    TDATE = DATE()      ;* Date part
                    CALL ALLOCATE.UNIQUE.TIME(CURRTIME)
                    UNIQUE.ID = TDATE:CURRTIME
                    R.ACCT = RAISE(R.ACCT)
                    CALL EB.ENTRY.REC.UPDATE(UNIQUE.ID,R.ACCT,'R')
* BG_100017156 E
                    IF C$MULTI.BOOK THEN
                        IF SAVE.ID.COMPANY NE ID.COMPANY THEN
                            ID.COMPANY = SAVE.ID.COMPANY
                            CALL LOAD.COMPANY(ID.COMPANY)
                        END
                    END

                NEXT I
                CALL F.DELETE(FN.SC.SOD.ACCR,'CONSOL.CONTROL')
            END     ;* END OF R.SC.SOD.ACCR
        END         ;* END OF LOCATE
    REPEAT

*
* Restore the original company
    IF ID.COMPANY NE ORIG.COMPANY THEN
        CALL LOAD.COMPANY(ORIG.COMPANY)
    END

RESTORE.COMMON:

    MAT R.NEW = MAT HOLD.R.NEW
    ID.NEW = HOLD.ID.NEW
    V = SAVE.V

    RETURN

END
