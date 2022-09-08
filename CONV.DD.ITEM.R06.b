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
* <Rating>309</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DD.Contract
    SUBROUTINE CONV.DD.ITEM.R06
***********************************************************************
* Conversion routine to select DD.ITEMs. Process those records which does
* not contain any DD.PARAMETER information.
* Update DD.ITEM with DD.PARAMETER using the Mandate reference.
* Also update the ID of the REASON.CODE in DD.ITEM got by reading
* the OUT.FORMAT.ID for DD.PARAMETER.
*
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
***********************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DD.PARAMETER
    $INSERT I_F.DD.DDI
    $INSERT I_F.DD.ITEM

    GOSUB INITIALISE
    GOSUB SELECT.RECORDS
    GOSUB PROCESS.RECORDS

    RETURN

PROCESS.RECORDS:

    LOOP
        REMOVE DDITEM.ID FROM SEL.LIST SETTING DPOS
    WHILE DDITEM.ID:DPOS
        READ R.DD.ITEM FROM F.DD.ITEM,DDITEM.ID ELSE R.DD.ITEM = ''
        IF R.DD.ITEM THEN
            IT.MANDATE = R.DD.ITEM<DD.ITEM.MANDATE.REF>
            READ R.DD.DDI FROM F.DD.DDI,IT.MANDATE ELSE R.DD.DDI = ''

            DDI.PARAM = R.DD.DDI<DD.DDI.PARAM.ID>
            IF DDI.PARAM THEN
                READ R.DD.PARAM FROM F.DD.PARAMETER,DDI.PARAM ELSE R.DD.PARAM = ''
                DD.RE.CODE = FIELD(R.DD.PARAM<DD.PAR.DD.OUT.FORMAT>,".",1)
                R.DD.ITEM<DD.ITEM.PARAM.ID> = DDI.PARAM
                R.DD.ITEM<DD.ITEM.REASON.CODE.ID> = DD.RE.CODE
                WRITE R.DD.ITEM TO F.DD.ITEM,DDITEM.ID ON ERROR NULL
            END
        END
    REPEAT

    RETURN

INITIALISE:

    FN.DD.ITEM = 'F.DD.ITEM' ; F.DD.ITEM = ''
    FN.DD.DDI = 'F.DD.DDI' ; F.DD.DDI = ''
    FN.DD.PARAMETER = 'F.DD.PARAMETER' ; F.DD.PARAMETER = ''
    CALL OPF(FN.DD.ITEM,F.DD.ITEM)
    CALL OPF(FN.DD.DDI,F.DD.DDI)
    CALL OPF(FN.DD.PARAMETER,F.DD.PARAMETER)
    SEL.LIST = ''
    NO.OF.RECS = ''
    SYS.ERROR = ''

    RETURN

SELECT.RECORDS:

    SEL.CMD =    "SELECT ": FN.DD.ITEM : " WITH PARAM.ID EQ '' "
    CALL EB.READLIST(SEL.CMD, SEL.LIST, "", NO.OF.RECS, SYS.ERROR)

    RETURN

END
