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
* <Rating>-26</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DE.Messaging
    SUBROUTINE DE.SAMPLE.OFS.POST.ROUTINE(R.OFS.DATA)

*** Description
*** Post routine for the OFS source record, which is used for the MT102(repititive payments) message type
*** to update the Inward transaction id and OFS request details id in DE.I.HEADER record.

    $USING DE.Config
    $USING DE.Messaging


    GOSUB INITIALISE
    GOSUB MAIN

    RETURN
*------------------------------------------------------------------------

INITIALISE:

    R.DE.I.HEADER.REC = ''

    IN.DEL.REF.ID = ''

    RETURN

MAIN:
    X = FIELD(R.OFS.DATA, "DELIVERY.INREF:1:1=",2)
    IN.DEL.REF.ID = FIELD(X,",",1)      ;* Get the DE.I.HEADER id from the ofs data

    IF IN.DEL.REF.ID THEN
        TXN.REF = FIELD(R.OFS.DATA,'/',1)   ;* Inward transaction reference
        OFS.REQ.DET.ID = FIELD(R.OFS.DATA,'/',2)      ;* OFS request detail id

        R.DE.I.HEADER.REC = DE.Config.IHeader.Read(IN.DEL.REF.ID, HEAD.ERR)    ;* Read the DIH record

        R.DE.I.HEADER.REC<DE.Config.IHeader.HdrOfsReqDetKey,-1> = OFS.REQ.DET.ID
        R.DE.I.HEADER.REC<DE.Config.IHeader.HdrT24InwTransRef,-1> = TXN.REF
        DE.Config.IHeaderWrite(IN.DEL.REF.ID,R.DE.I.HEADER.REC,'')
    END

    RETURN

    END
