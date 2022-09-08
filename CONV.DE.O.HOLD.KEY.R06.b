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
* <Rating>266</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DE.Config
    SUBROUTINE CONV.DE.O.HOLD.KEY.R06
************************************************************************
* 05/08/05 - EN_10002607
*            DE.O.HOLD.FILE will now contain IDs of the form DeliverId.Msgno
*            It contains three fields STATUS, DATE and TIME.
*            So all existing records have to be converted to the new format, such
*            that the Id of the hold file will now be present in the STATUS field.
************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DE.O.HOLD.KEY

    GOSUB INITIALISE
    GOSUB SELECT.RECORDS
    IF NUM.LIST > 0 THEN
        GOSUB PROCESS.RECORDS
        GOSUB REMOVE.RECORDS
    END

    RETURN
*
INITIALISE:
    FN.DE.O.HOLD.KEY = 'F.DE.O.HOLD.KEY'
    F.DE.O.HOLD.KEY = ''
    CALL OPF(FN.DE.O.HOLD.KEY,F.DE.O.HOLD.KEY)
    NUM.LIST = 0

    RETURN
*
SELECT.RECORDS:
    READ KEYLIST FROM F.DE.O.HOLD.KEY,'KEYLIST' ELSE KEYLIST=''
    NUM.LIST = DCOUNT(KEYLIST,FM)

*    SEL.CMD = 'SELECT ':FN.DE.O.HOLD.KEY
*    CALL EB.READLIST(SEL.CMD,IDS.LIST,'',NUM.LIST,'')

    RETURN
*
PROCESS.RECORDS:
    LOOP
        REMOVE ID.HOLD FROM KEYLIST SETTING IPOS
    WHILE ID.HOLD:IPOS
        READ R.HOLD FROM F.DE.O.HOLD.KEY,ID.HOLD ELSE R.HOLD=''
        IF R.HOLD THEN
            TOT.CNT = DCOUNT(R.HOLD,FM)
            RNEW.REC = ''
            FOR IND.HOLD = 1 TO TOT.CNT

                REC.ID = R.HOLD<IND.HOLD>
                RNEW.REC<DE.HKEY.STATUS> = ID.HOLD
                IF LEN(ID.HOLD) > 10 THEN
                    RNEW.REC<DE.HKEY.DATE> = ID.HOLD[6,8]
                    RNEW.REC<DE.HKEY.TIME> = ID.HOLD[15,5]
                END ELSE
*        RNEW.REC<DE.HKEY.DATE> = TODAY
                    RNEW.REC<DE.HKEY.TIME> = ID.HOLD[6,5]
                END
                WRITE RNEW.REC TO F.DE.O.HOLD.KEY,REC.ID ON ERROR NULL


            NEXT IND.HOLD
            DELETE F.DE.O.HOLD.KEY,ID.HOLD
        END

    REPEAT

    RETURN
*
REMOVE.RECORDS:

    DELETE F.DE.O.HOLD.KEY,'KEYLIST'

    RETURN
*
END
