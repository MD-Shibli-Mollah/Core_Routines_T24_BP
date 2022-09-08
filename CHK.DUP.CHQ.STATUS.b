* @ValidationCode : MjoxMDMxNTcyODgxOkNwMTI1MjoxNTY0NTcxMTY5MDUzOnNyYXZpa3VtYXI6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAxOTA4LjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 Jul 2019 16:36:09
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version n dd/mm/yy  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>1289</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CQ.ChqFees
    SUBROUTINE CHK.DUP.CHQ.STATUS

* check for duplicate & null values
* Incoming: AF
*           F(x)
*           R.NEW(x)
* 20/09/02 - EN_10001178
*            Conversion of error messages to error codes.
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Fees as ST_ChqFees and include $PACKAGE
*
*07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
    $USING EB.SystemTables
    $USING EB.ErrorProcessing
    $USING CQ.ChqFees 


    YCOUNT = COUNT(EB.SystemTables.getRNew(EB.SystemTables.getAf()),@VM)+(EB.SystemTables.getRNew(EB.SystemTables.getAf())<>"")
    IF EB.SystemTables.getF(EB.SystemTables.getAf())[4,2] <> "XX" THEN         ; *  for cheque.status

        YT.DOUBLE = ""
        Y.EMPTY = 0
        FOR I = 1 TO YCOUNT
            EB.SystemTables.setAv(I)
            YFD = EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,EB.SystemTables.getAv()>
            IF YFD = "" THEN
                Y.EMPTY += 1
                * value in cheque.status can be NULL (once)
                IF Y.EMPTY > 1 THEN
                    EB.SystemTables.setEtext("ST.RTN.INP.OR.LINEDELETION.MISS")
                    EB.ErrorProcessing.StoreEndError()
                END
            END ELSE
                LOCATE YFD IN YT.DOUBLE<1> SETTING X ELSE X = 0
                IF X THEN EB.SystemTables.setEtext("ST.RTN.DUP"); EB.ErrorProcessing.StoreEndError()
                ELSE YT.DOUBLE<-1> = YFD
            END
        NEXT I
    END ELSE                           ; *  for cheque.code
        FOR I = 1 TO YCOUNT
            EB.SystemTables.setAv(I)
            YCOUNT.AS = COUNT(EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,EB.SystemTables.getAv()>,@SM)+(EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,EB.SystemTables.getAv()><>"")
            IF YCOUNT.AS EQ 0 THEN YCOUNT.AS = 1
            YT.DOUBLE = ""
            FOR J = 1 TO YCOUNT.AS
                EB.SystemTables.setAs(J)
                YFD = EB.SystemTables.getRNew(EB.SystemTables.getAf())<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()>
                IF YFD EQ "" THEN
                    IF EB.SystemTables.getAs() = 1 THEN
                        IF YCOUNT > 1 OR YCOUNT.AS > 1 THEN
                            EB.SystemTables.setEtext("ST.RTN.INP.OR.LINEDELETION.MISS")
                            EB.ErrorProcessing.StoreEndError()
                            * sub field 1 can't be empty, when more fields defined
                        END
                    END ELSE
                        EB.SystemTables.setEtext("ST.RTN.INP.OR.LINEDELETION.MISS")
                        EB.ErrorProcessing.StoreEndError()
                        * except first sub field, no other field can be empty
                    END
                END ELSE
                    LOCATE YFD IN YT.DOUBLE<1> SETTING X ELSE X = 0
                    IF X THEN EB.SystemTables.setEtext("ST.RTN.DUP"); EB.ErrorProcessing.StoreEndError()
                    ELSE YT.DOUBLE<-1> = YFD
                END
            NEXT J
        NEXT I
    END

    RETURN


    END
