* @ValidationCode : MjoxNjk4MTY0MzA3OkNwMTI1MjoxNTY0NTc4MDMxNTE3OnNyYXZpa3VtYXI6LTE6LTE6MDotMTpmYWxzZTpOL0E6REVWXzIwMTkwOC4wOi0xOi0x
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
* <Rating>-2</Rating>
*-----------------------------------------------------------------------------
$PACKAGE CQ.ChqSubmit
SUBROUTINE CONV.CHQ.COLL.HIST.G14.1(ID,CCH.REC,YFILE)

****************************************************
*
* 28/09/03 - EN_10002015
*            Field position in CHEQUE.COLLECTION.HIST has been
*            changed, the data record has to be mapped for
*            the new layout
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Submit as ST_ChqSubmit and include $PACKAGE
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
*************************************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
*
    OLD.CCH.REC = CCH.REC
    NEW.CCH.REC = CCH.REC
*
*Forming new array
*
    NEW.CCH.REC<5>  = OLD.CCH.REC<7> ;*AMOUNT field is moved up
    NEW.CCH.REC<6>  = OLD.CCH.REC<5> ;*ORIG.DATE.VALUE
    NEW.CCH.REC<7>  = OLD.CCH.REC<6> ;*SUSP.POSTED.TO
*
    CCH.REC = NEW.CCH.REC
RETURN
END
