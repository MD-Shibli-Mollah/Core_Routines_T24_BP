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
* <Rating>-135</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Trade
    SUBROUTINE CONV.DX.FXOTC.TRANS.R13(DX.TRANS.ID, R.DX.TRANS, FN.DX.TRANS)
*-----------------------------------------------------------------------------
*
* Conversion routine to change the ID and record details of DX.REP.POSITION and
* DX.MARKET.PRICE along with the change in DX.TRANSACTION
*
*-----------------------------------------------------------------------------
*
* Modification History:
* --------------------
* 10/08/12 - EN-360341 / Task-242183
*            Enhancement on creating currency pairs for FX-OTC options
*
* 21/02/14 - Defect-915226 / Task-922456
*            The symbol "*" is converted to ":" in market price, position and transaction records.
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DX.TRADE
    $INSERT I_F.DX.TRANSACTION
    $INSERT I_F.DX.REP.POSITION
    $INSERT I_F.DX.REP.POS.LAST
    $INSERT I_F.DX.REP.POS.HIST
    $INSERT I_F.DX.MARKET.PRICE
    $INSERT I_F.DX.MARKET.PRICE.HISTORY

    GOSUB INITIALISE

* Market price and rep position are updated only for trades

    IF SOURCE.REF = "DXTRA" THEN
        GOSUB MAIN.PROCESS
        IF DONT.PROCESS THEN ; * Position and market price id are converted for the first transaction in rep position .
            RETURN
        END
        GOSUB POSITION.PROCESS
        GOSUB POSITION.LAST
        GOSUB POSITION.HISTORY
        GOSUB MARKET.PRICE.PROCESS
        GOSUB MARKET.PRICE.HISTORY
    END

    RETURN
*
INITIALISE:
*----------
* Initialisation of variables and open files

    FN.DX.TRADE = 'F.DX.TRADE'
    F.DX.TRADE =''
    CALL OPF(FN.DX.TRADE,F.DX.TRADE)

    FN.DX.REP.POSITION = 'F.DX.REP.POSITION'
    F.DX.REP.POSITION = ''
    CALL OPF(FN.DX.REP.POSITION,F.DX.REP.POSITION)

    FN.DX.REP.POS.LAST = 'F.DX.REP.POS.LAST'
    F.DX.REP.POS.LAST = ''
    CALL OPF(FN.DX.REP.POS.LAST,F.DX.REP.POS.LAST)


    FN.DX.REP.POS.HIST = 'F.DX.REP.POS.HIST'
    F.DX.REP.POS.HIST = ''
    CALL OPF(FN.DX.REP.POS.HIST,F.DX.REP.POS.HIST)

    FN.DX.MARKET.PRICE = 'F.DX.MARKET.PRICE'
    F.DX.MARKET.PRICE = ''
    CALL OPF(FN.DX.MARKET.PRICE,F.DX.MARKET.PRICE)

    FN.DX.MARKET.PRICE.HISTORY = 'F.DX.MARKET.PRICE.HISTORY'
    F.DX.MARKET.PRICE.HISTORY = ''
    CALL OPF(FN.DX.MARKET.PRICE.HISTORY,F.DX.MARKET.PRICE.HISTORY)

    DX.TRADE.ID = FIELD(DX.TRANS.ID,'.',1)
    SOURCE.REF = DX.TRADE.ID[1,5]
    R.DX.REP.POS = ''
    CHK.SYMB = ''
    DONT.PROCESS = ''

    RETURN
*
CHECK.SYMBOL:
*------------
    IF CHK.SYMB THEN
        USE.SYMB = "*"
    END ELSE
        USE.SYMB = ":"
    END

    RETURN
*
MAIN.PROCESS:
*------------

* The LAST.REP.POS in transaction record, DELIVERY.CCY
* and OPTION.STYLE information are updated

    CALL F.READ(FN.DX.TRADE,DX.TRADE.ID,R.DX.TRADE.REC,F.DX.TRADE,TRADE.ERR)
    DELIV.CCY = R.DX.TRADE.REC<28>   ;*Delivery currency
    OPTION.STYLE = R.DX.TRADE.REC<15> ;*Option Style
    OPT.FIRST.PART = OPTION.STYLE[1,1] ;* First character of option style is alone updated to position
    OLD.REP.POS = R.DX.TRANS<12>  ;*Previous position id
    CHK.SYMB = INDEX(OLD.REP.POS,"*",1)
    GOSUB CHECK.SYMBOL
    CONC.PART.1 = FIELD(OLD.REP.POS,USE.SYMB,1) ;*Portfolio inforamtion
    CONC.PART.2 = FIELD(OLD.REP.POS,USE.SYMB,2) ;*Contract information
    CONC.PART.3 = FIELD(OLD.REP.POS,USE.SYMB,3) ;*Exotics
    NEW.REP.POS = CONC.PART.1:':':CONC.PART.2:'/':DELIV.CCY:'/':OPT.FIRST.PART:':':CONC.PART.3 ;*New position id

* Fields to be updated to transaction record
    R.DX.TRANS<12> = NEW.REP.POS
    R.DX.TRANS<203> = DELIV.CCY
    R.DX.TRANS<204> = OPTION.STYLE
    READ R.DX.REP.POS FROM F.DX.REP.POSITION, OLD.REP.POS THEN
        IF R.DX.REP.POS<11,1> NE DX.TRANS.ID THEN ; * If the current trasaction is not the first transaction in rep position then skip processing.
            DONT.PROCESS = 1
        END
    END ELSE ; *If record not found in list then dont process.
        DONT.PROCESS = 1
    END

    RETURN

*
POSITION.PROCESS:
*----------------
* Change the posiiton record to include the delivery currency and option style
* parameter in both ID and in record

    OLD.POSN.ID = OLD.REP.POS
    NEW.POSN.ID = NEW.REP.POS

    READU R.DX.REP.POS FROM F.DX.REP.POSITION, OLD.POSN.ID THEN

        R.DX.REP.POS<77> = OPT.FIRST.PART   ;*OPTION.STYLE update
        * Updation of COB.PRICE.ID
        OLD.COB.PRICE = R.DX.REP.POS<74> ;*Previous market price id
        IF CHK.SYMB THEN
            CONVERT "*" TO ":" IN OLD.COB.PRICE
        END

        REP.COB.PART.1 = FIELD(OLD.COB.PRICE,':',1) ;* Priceset value
        REP.COB.PART.2 = FIELD(OLD.COB.PRICE,':',2) ;* Contract inforamation
        REP.COB.PART.3 = FIELD(OLD.COB.PRICE,':',3) ;*Exotics
        NEW.COB.PRICE = REP.COB.PART.1:':':REP.COB.PART.2:'/':DELIV.CCY:'/':OPT.FIRST.PART:':':REP.COB.PART.3 ;*New market price ID
        R.DX.REP.POS<74> = NEW.COB.PRICE

        WRITE R.DX.REP.POS ON F.DX.REP.POSITION, NEW.POSN.ID          ;*Updates the new position record
            DELETE F.DX.REP.POSITION , OLD.POSN.ID    ;*Deletes the old position record

            END ELSE

                RELEASE F.DX.REP.POSITION, OLD.POSN.ID    ;*Release the lock if the record doesnot exists

            END

            RETURN

            *
POSITION.LAST:
            *-------------
            * Change the DX.REP.POS.LAST record to include the correct DX.REP.POSITION
            * in both ID and in record

            OLD.POSN.ID = OLD.REP.POS ;*Old position id
            NEW.POSN.ID = NEW.REP.POS ;*New position id

            READU R.DX.REP.POS.LAST FROM F.DX.REP.POS.LAST, OLD.POSN.ID THEN
                IF CHK.SYMB THEN
                    CONVERT "*" TO ":" IN R.DX.REP.POS.LAST
                END

                REP.PART.1 = FIELD(R.DX.REP.POS.LAST,':',1) ;*Portfolio
                REP.PART.2 = FIELD(R.DX.REP.POS.LAST,':',2) ;*Contract information
                REP.PART.3 = FIELD(R.DX.REP.POS.LAST,':',3) ;*Exotics
                REP.PART.4 = FIELD(R.DX.REP.POS.LAST,':',4) ;*Date
                R.DX.REP.POS.LAST.NEW = REP.PART.1:':':REP.PART.2:'/':DELIV.CCY:'/':OPT.FIRST.PART:':':REP.PART.3:':':REP.PART.4 ;*New position id

                WRITE R.DX.REP.POS.LAST.NEW ON F.DX.REP.POS.LAST, NEW.POSN.ID ;*Updates the new position record
                    DELETE F.DX.REP.POS.LAST , OLD.POSN.ID    ;*Deletes the old position record

                    END ELSE

                        RELEASE F.DX.REP.POS.LAST, OLD.POSN.ID    ;*Release the lock if the record doesnot exists

                    END

                    RETURN

                    *
POSITION.HISTORY:
                    *----------------
                    * Change the history of position record to include the correct DX.REP.POSITION
                    * in both ID and in record

                    OLD.POSN.ID = OLD.REP.POS ;*Old position id
                    GOSUB CHECK.SYMBOL
                    POS.SEL= "SELECT ":FN.DX.REP.POS.HIST:" WITH @ID LIKE ...":OLD.POSN.ID:"..."
                    CALL EB.READLIST(POS.SEL,POS.LIST,'',NO.OF.POS,POS.ERR)
                    LOOP
                        REMOVE POS.ID FROM POS.LIST SETTING POS.POSN
                    WHILE POS.ID : POS.POSN

                        NEW.POS.ID = ''
                        HIST.PART.1 = FIELD(POS.ID,USE.SYMB,1) ;*Portfolio
                        HIST.PART.2 = FIELD(POS.ID,USE.SYMB,2) ;*Contract information
                        HIST.PART.3 = FIELD(POS.ID,USE.SYMB,3) ;*Exotics
                        HIST.PART.4 = FIELD(POS.ID,USE.SYMB,4) ;*Date
                        NEW.POS.ID = HIST.PART.1:':':HIST.PART.2:'/':DELIV.CCY:'/':OPT.FIRST.PART:':':HIST.PART.3:':':HIST.PART.4 ;* New position ID


                        READU R.DX.REP.POS.HIST FROM F.DX.REP.POS.HIST, POS.ID THEN
                            R.DX.REP.POS.HIST<77> = OPT.FIRST.PART   ;*OPTION.STYLE update
                            * Updation of COB.PRICE.ID
                            OLD.HIST.PRICE = R.DX.REP.POS.HIST<74>
                            HIST.COB.PART.1 = FIELD(OLD.HIST.PRICE,USE.SYMB,1) ;*Price set
                            HIST.COB.PART.2 = FIELD(OLD.HIST.PRICE,USE.SYMB,2) ;* contract information
                            HIST.COB.PART.3 = FIELD(OLD.HIST.PRICE,USE.SYMB,3) ;*Exotics
                            NEW.HIST.PRICE = HIST.COB.PART.1:':':HIST.COB.PART.2:'/':DELIV.CCY:'/':OPT.FIRST.PART:':':HIST.COB.PART.3 ;*New price id
                            R.DX.REP.POS.HIST<74> = NEW.HIST.PRICE

                            WRITE R.DX.REP.POS.HIST ON F.DX.REP.POS.HIST, NEW.POS.ID  ;*Updates the new position record
                                DELETE F.DX.REP.POS.HIST , POS.ID     ;*Deletes the old position record

                                END ELSE

                                    RELEASE F.DX.REP.POS.HIST, POS.ID     ;*Release the lock if the record doesnot exists

                                END

                            REPEAT

                            RETURN
                            *

MARKET.PRICE.PROCESS:
                            *-------------------
                            * Change the market price record to include the delivery currency and option style
                            * parameter in both ID and in record
                            GOSUB CHECK.SYMBOL
                            PRICE.ID = CONC.PART.2:USE.SYMB:CONC.PART.3
                            SEL.STMT = "SELECT F.DX.MARKET.PRICE WITH @ID LIKE ...":PRICE.ID:"..."
                            CALL EB.READLIST(SEL.STMT,SEL.LIST,'',NO.OF.REC,SEL.ERR)
                            LOOP
                                REMOVE SEL.ID FROM SEL.LIST SETTING SEL.POS
                            WHILE SEL.ID : SEL.POS

                                NEW.MKT.ID = ''
                                MKT.PART.1 = FIELD(SEL.ID,USE.SYMB,1) ;*Price set
                                MKT.PART.2 = FIELD(SEL.ID,USE.SYMB,2) ;*Contract information
                                MKT.PART.3 = FIELD(SEL.ID,USE.SYMB,3) ;*Exotics
                                READU R.DX.MKT.PRICE FROM F.DX.MARKET.PRICE, SEL.ID THEN

                                    NEW.MKT.ID = MKT.PART.1:':':MKT.PART.2:'/':DELIV.CCY:'/':OPT.FIRST.PART:':':MKT.PART.3
                                    R.DX.MKT.PRICE<9> = DELIV.CCY;*Delivery currency
                                    R.DX.MKT.PRICE<10> = OPT.FIRST.PART ;*First character of option style alone updated
                                    WRITE R.DX.MKT.PRICE ON F.DX.MARKET.PRICE, NEW.MKT.ID     ;*Updates the new market price record
                                        DELETE F.DX.MARKET.PRICE , SEL.ID     ;*Deletes the old market price record

                                        END ELSE

                                            RELEASE F.DX.MARKET.PRICE, SEL.ID     ;*Release the lock if the record does not exists
                                        END

                                    REPEAT

                                    RETURN
                                    *

MARKET.PRICE.HISTORY:
                                    *--------------------
                                    * Change the market price history record to include the delivery currency and option style
                                    * parameter in both ID and in record
                                    GOSUB CHECK.SYMBOL
                                    HIST.ID = CONC.PART.2:USE.SYMB:CONC.PART.3
                                    HIST.SEL.STMT = "SELECT ":FN.DX.MARKET.PRICE.HISTORY:" WITH @ID LIKE ...":HIST.ID:"..."
                                    CALL EB.READLIST(HIST.SEL.STMT,HIST.LIST,'',NO.OF.HIST.REC,HIST.ERR)
                                    LOOP
                                        REMOVE HIST.SEL.ID FROM HIST.LIST SETTING HIST.POS
                                    WHILE HIST.SEL.ID : HIST.POS

                                        MKT.HIST.PART.1 = FIELD(HIST.SEL.ID,USE.SYMB,1) ;*price set
                                        MKT.HIST.PART.2 = FIELD(HIST.SEL.ID,USE.SYMB,2) ;*contract information
                                        MKT.HIST.PART.3 = FIELD(HIST.SEL.ID,USE.SYMB,3) ;*exotics
                                        MKT.HIST.PART.4 = FIELD(HIST.SEL.ID,USE.SYMB,4) ;*date
                                        NEW.MKT.HIST.ID = MKT.HIST.PART.1:':':MKT.HIST.PART.2:'/':DELIV.CCY:'/':OPT.FIRST.PART:':':MKT.HIST.PART.3:':':MKT.HIST.PART.4 ;*new history id
                                        READU R.DX.MKT.HIST.PRICE FROM F.DX.MARKET.PRICE.HISTORY, HIST.SEL.ID THEN

                                            R.DX.MKT.HIST.PRICE<9> = DELIV.CCY ;*delivery currency
                                            R.DX.MKT.HIST.PRICE<10> = OPT.FIRST.PART ;*first charcter of option style updated
                                            WRITE R.DX.MKT.HIST.PRICE ON F.DX.MARKET.PRICE.HISTORY, NEW.MKT.HIST.ID       ;*Updates the new market price record
                                                DELETE F.DX.MARKET.PRICE.HISTORY , HIST.SEL.ID  ;*Deletes the old market price record

                                                END ELSE

                                                    RELEASE F.DX.MARKET.PRICE.HISTORY, HIST.SEL.ID  ;*Release the lock if the record does not exists
                                                END

                                            REPEAT

                                            RETURN

                                            *
                                        END
