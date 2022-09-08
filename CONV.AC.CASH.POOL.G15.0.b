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
* <Rating>288</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE PO.Cashpooling
SUBROUTINE CONV.AC.CASH.POOL.G15.0(CP.ID,CP.REC,CP.FILE)
    $INSERT I_COMMON
    $INSERT I_EQUATE
*******************************************************
* Modification History:
* *********************
*
* 14/10/08 -  CI_10058247
*             Record routine to write the cash pool group id in the
*             cash pool Id account and Link accounts.
*******************************************************************************
    EQU AC.CP.GROUP.ID TO 1
    EQU AC.CP.LINK.ACCT TO 7
    EQU AC.CP.RECORD.STATUS TO 41
    EQU AC.CASH.POOL.GROUP TO 173
    IF CP.REC<AC.CP.RECORD.STATUS> EQ 'IHLD' THEN RETURN    ;* * do not excecute for hold records
    IF INDEX(CP.ID,";",1) THEN RETURN   ;* do not excecute for hist records
    FN.ACCOUNT = "F.ACCOUNT"
    FV.ACCOUNT = ""
    CALL OPF(FN.ACCOUNT,FV.ACCOUNT)
    LINK.ACT = CP.REC<AC.CP.LINK.ACCT>  ;* LINK.ACCT
    LINK.ACT<1,-1> = CP.ID
    ACC.CNT = DCOUNT(LINK.ACT,VM)
    FOR ACC.NO =  1 TO ACC.CNT
        UPD.ACCT = LINK.ACT<1,ACC.NO>
        READ ACT.REC FROM FV.ACCOUNT, UPD.ACCT ELSE ACT.REC = ''
        IF ACT.REC THEN
            IF ACT.REC<AC.CASH.POOL.GROUP> THEN
                GP.IND = FIELD(ACT.REC<AC.CASH.POOL.GROUP>,"_",2)
                GP.IND = GP.IND + 1
                ACT.REC<AC.CASH.POOL.GROUP> = CP.REC<AC.CP.GROUP.ID>:"_":GP.IND
            END ELSE
                ACT.REC<AC.CASH.POOL.GROUP> = CP.REC<AC.CP.GROUP.ID>:"_1"
            END
            WRITE ACT.REC ON FV.ACCOUNT,UPD.ACCT
        END
    NEXT ACC.NO
    RETURN
END
