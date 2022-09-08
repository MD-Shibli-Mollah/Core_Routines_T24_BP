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

* Version 3 02/06/00  GLOBUS Release No. G10.2.02 29/03/00
*-----------------------------------------------------------------------------
* <Rating>-26</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE LC.Contract

    SUBROUTINE LC.DUP.FLDS(AF.LIST)

    ! GB9901566
    ! Routine to check for duplicates.
    ! Incoming is AF.LIST


* 04/09/02 - EN_10001035
*            Converting error messages to error codes.
*
* 20/02/07 - BG_100013043
*            CODE.REVIEW changes.
*
* 13/06/07 - CI_10049752
*            Issue in amending LC Type and Pay Details
*
* 15/12/14 - Task        : 1199082
*			 LC Componentization and Incorporation
*			 Enhancement : 990544
*
*********************************************************************************************

    $USING LC.Contract
    $USING EB.ErrorProcessing
    $USING EB.SystemTables

    NO.OF.FLDS = DCOUNT(AF.LIST,@FM)
    NO.OF.VLS = DCOUNT(EB.SystemTables.getRNew(AF.LIST<1>),@VM)
    EB.SystemTables.setEtext("")
    FOR VAL.NO = 1 TO (NO.OF.VLS - 1)
        FOR N.VAL.NO = (VAL.NO + 1) TO NO.OF.VLS

            GOSUB CHECK.ERROR ;*  BG_100013043 - S / E
            IF EB.SystemTables.getEtext() ="ERROR" THEN
                EXIT          ;* BG_100013043 - S
            END     ;* BG_100013043 - E
        NEXT N.VAL.NO
        IF EB.SystemTables.getEtext() ="ERROR" THEN
            EXIT    ;* BG_100013043 - S
        END         ;* BG_100013043 - E
    NEXT VAL.NO
    IF EB.SystemTables.getEtext() THEN
        EB.ErrorProcessing.StoreEndError()
    END
    RETURN
*********************************************************************************************
* BG_100013043 - S
CHECK.ERROR:
    FOR FLD.NO =1 TO NO.OF.FLDS
        YTEMP = AF.LIST<FLD.NO>
        IF EB.SystemTables.getRNew(YTEMP)<1,VAL.NO> <> EB.SystemTables.getRNew(YTEMP)<1,N.VAL.NO> THEN
            EXIT
        END
        IF FLD.NO = NO.OF.FLDS THEN
            ! GB0000504+
            EB.SystemTables.setEtext("LC.RTN.DUP.ENTRY")
            EB.SystemTables.setAf(YTEMP)
            EB.SystemTables.setAv(N.VAL.NO)  ;* CI_10049752 S/E
            ! GB0000504-
            EXIT
        END
    NEXT FLD.NO
    RETURN          ;* BG_100013043 - E
*********************************************************************************************
    END
