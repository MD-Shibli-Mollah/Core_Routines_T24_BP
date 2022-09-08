* @ValidationCode : MjoxMzI0ODgzMTc3OkNwMTI1MjoxNTc5MTY4NTI2ODEzOnlncmFqYXNocmVlOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwMS4yMDE5MTIxMy0wNTQwOi0xOi0x
* @ValidationInfo : Timestamp         : 16 Jan 2020 15:25:26
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ygrajashree
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202001.20191213-0540
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version 4 27/02/01  GLOBUS Release No. G11.2.00 28/03/01
*-----------------------------------------------------------------------------
* <Rating>-44</Rating>
$PACKAGE DE.Inward
SUBROUTINE SAMPLE.IN(GENERIC.DATA,MISN,TYPE,R.MSG,MAT R.HEAD,ERR.MSG)
*
* Sample subroutine to show how a routine to handle incoming messages
* and the ACKs and NAKs for outward messages could be written
*
*
* P A R A M E T E R S
* ===================
*
* IN
* ==
*
* GENERIC.DATA        -  Miscellaneous data available to subroutine
*             <1>     -  Message key e.g. D199707105379202.1
*             <2>     -  Debug flag
*             <3>     -  PDE (1 if PDE, 0 otherwise)
*             <4>     -  Interface reference number/id
*             <5>     -  Interactive flag
*             <6>     -  Received stamp (to update header on ACKs)
*             <7>     -  From address (to update header on ACKs)
*                        Layout of GENERIC.DATA is described in the
*                        insert I_DE.GENERIC.DATA
*
* MISN                -  Message sequence number (5 digit number)
*
* TYPE                -  Type of message.  Must be one of the following:
*                        ACK - ack to an outward message
*                        NAK - nak to an outward message
*                        MSG - incoming message
*
* R.MSG               -  Formatted message to be sent
*
* R.DE.HEADER         -  Delivery header record.  Update any field on
*                        this with information which is available on
*                        the message header/trailer.
*
* OUT
* ===
*
* ERROR.MSG           -  Used for NAKs - should contain the reason why
*                        the message could not be sent.
*                        Set to "STOP" to terminate DE.CC.GENERIC
*
* 21/02/07 - BG_100013037
*            CODE.REVIEW changes.
*
* 20/08/15 - Enhancement 1265068/ Task 1464647
*          - Routine incorporated
*
* 16/01/20 - Task 3538382
*	     	 Correction for regression errors
*********************************************************************************************
    $USING EB.SystemTables
    $USING EB.API
    $USING DE.Config
    $USING DE.Outward
    $USING EB.DataAccess
*
* Initialise variables
*
    MISN = ''
    TYPE = ''
    R.MSG = ''
    ERR.MSG = ''
    DIM R.HEAD(EB.SystemTables.SysDim)
    PASSEDNO = ''
    DEFFUN CHARX(PASSEDNO)
*
* Open the message file.  Stop the carrier control program if the
* file does not exist
*
    EB.DataAccess.Opf('F.DE.I.MSG.SAMPLE',F.DE.I.MSG.SAMPLE)
    IF EB.SystemTables.getEtext() THEN
        ERR.MSG = 'STOP'
        RETURN
    END
*
* Select the first record on the message file
*
    SELECT F.DE.I.MSG.SAMPLE
    LOOP
        READNEXT ID ELSE
            ID = '' ;* BG_100013037 - S
        END         ;* BG_100013037 - E
    WHILE ID <> ''
*
        CLEARSELECT ;* Do not want to process any messages other than the first one
*
* Read the message from the outward file
*
        EB.DataAccess.FRead('F.DE.I.MSG.SAMPLE',ID,R.MSG,F.DE.I.MSG.SAMPLE,ER)
*
* In this example, if the message starts "O.", it is an ACK or NAK for
* an outward message
        IF ID[1,2] = 'O.' THEN
            MISN = ID[3,9]
*
* If the message is an "ACK", set the message type
*
            IF R.MSG<1> = 'ACK' THEN
                TYPE = 'ACK'
                GENERIC.DATA<DE.Outward.DeGenInRcvStamp> = ''      ;* Get from ACK message if available
                GENERIC.DATA<DE.Outward.DeGenInFromAddress> = ''   ;* Get from ACK message if available
            END
*
* If the message is a "NAK", set the message type and error message
*
            IF R.MSG<1> = 'NAK' THEN
                TYPE = 'NAK'
                ERROR.MSG = R.MSG<2>
            END

        END ELSE
*
* Must be an incoming message
*
            MISN = ID
            TYPE = 'MSG'
            X = INDEX(R.MSG,'1:F',1)
            R.HEAD(DE.Config.IHeader.HdrFromAddress) = R.MSG[X+5,12]
            X = INDEX(R.MSG,'2:I',1)
            R.HEAD(DE.Config.IHeader.HdrMessageType) = R.MSG[X+3,3]
            R.MSG = FIELD(R.MSG,CHARX(013):CHARX(010),2)
        END
*
* Delete the message from the message file (so that it will not be
* processed again)
*
        EB.DataAccess.FDelete('F.DE.I.MSG.SAMPLE',ID)

        RETURN

    REPEAT

RETURN
END
