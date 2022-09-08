* @ValidationCode : Mjo5Nzk3MTYwMDg6Q3AxMjUyOjE1NjQ1NzIzNjQyNjI6c3JhdmlrdW1hcjotMTotMTowOi0xOmZhbHNlOk4vQTpERVZfMjAxOTA4LjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 Jul 2019 16:56:04
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

* Version 3 02/06/00  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-42</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CQ.ChqPaymentStop
    SUBROUTINE CONV.CHEQUES.PRESENTED.G11
*-----------------------------------------------------------------------------
* Conversion routine to populate the CHEQUES.PRESENTED file from the PRESENTED.CHQS
* field in CHEQUE.REGISTER. Once populated it zaps this field.
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_PaymentStop as ST_ChqPaymentStop and include $PACKAGE
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CHEQUE.REGISTER
    $INSERT I_F.CHEQUES.PRESENTED
*-----------------------------------------------------------------------------

    GOSUB INITIALISATION
    GOSUB SELECT.CHEQUE.REGISTER

    LOOP REMOVE CHEQUE.REGISTER.ID FROM ID.LIST SETTING D WHILE CHEQUE.REGISTER.ID:D
        READU R.CHEQUE.REGISTER FROM F.CHEQUE.REGISTER, CHEQUE.REGISTER.ID THEN
            GOSUB WRITE.CHEQUES.PRESENTED
            R.CHEQUE.REGISTER<CHEQUE.REG.PRESENTED.CHQS> = ""
            WRITE R.CHEQUE.REGISTER TO F.CHEQUE.REGISTER, CHEQUE.REGISTER.ID
                CNT+=1
                IF CNT[2]="00" THEN
                    MSG = 'Processed ':CNT:' of ':TOTAL.SELECTED
                    CALL DISPLAY.MESSAGE(MSG,1)
                END
            END
        REPEAT

        CALL DISPLAY.MESSAGE("Cheque processing complete",1)

        RETURN
        *-----------------------------------------------------------------------------
INITIALISATION:

        FN.CHEQUE.REGISTER="F.CHEQUE.REGISTER"
        CALL OPF(FN.CHEQUE.REGISTER,F.CHEQUE.REGISTER)

        CALL OPF('F.CHEQUES.PRESENTED',F.CHEQUES.PRESENTED)
        CNT = 0

        RETURN
        *-----------------------------------------------------------------------------
SELECT.CHEQUE.REGISTER:

        SELECT.COMMAND = "SELECT ":FN.CHEQUE.REGISTER:" WITH PRESENTED.CHQS"
        CALL EB.READLIST(SELECT.COMMAND,ID.LIST,"",TOTAL.SELECTED,"")

        RETURN
        *-----------------------------------------------------------------------------
WRITE.CHEQUES.PRESENTED:

        CHEQUE.LIST = R.CHEQUE.REGISTER<CHEQUE.REG.PRESENTED.CHQS>

        LOOP REMOVE CHEQUE.ID FROM CHEQUE.LIST SETTING CD WHILE CHEQUE.ID:CD
            FIRST.CHEQUE = CHEQUE.ID["-",1,1]
            LAST.CHEQUE = CHEQUE.ID["-",2,1]
            IF LAST.CHEQUE = "" THEN
                LAST.CHEQUE = FIRST.CHEQUE
            END
            FOR CHEQUE.ID = FIRST.CHEQUE TO LAST.CHEQUE
                FMT.CHEQUE.ID = CHEQUE.ID + 0          ; * Drop leading zeros
                FMT.CHEQUE.ID = FMT(FMT.CHEQUE.ID,LEN(FMT.CHEQUE.ID):'R')  ; * Back to a string
                CHEQUES.PRESENTED.ID = CHEQUE.REGISTER.ID:"-":FMT.CHEQUE.ID
                WRITE "" TO F.CHEQUES.PRESENTED, CHEQUES.PRESENTED.ID
                NEXT CHEQUE.ID
            REPEAT

            RETURN
            *-----------------------------------------------------------------------------
        END
