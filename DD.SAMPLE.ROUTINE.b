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

* Version n dd/mm/yy  GLOBUS Release No. 200508 29/07/05
*-----------------------------------------------------------------------------
* <Rating>-30</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DD.Contract
    SUBROUTINE DD.SAMPLE.ROUTINE(HDR.FTR.DATA,PROCESS.DATE,DD.HEADER,OUT.FORMAT.ID,FIELD.NAME,FC,DD.ITEM.ID,TOTAL.AMOUNT,ROUTINE.OUTPUT,FIELD.OUTPUT,ROUTINE.ERROR)


* This is the SAMPLE subroutine that can be linked to the DD.OUT.FORMAT
* record - BACS.1


* Incoming parameters:
* HDR.FTR.DATA = This holds the mode for which this subroutine is called.
*                The allowed values are HEADER, FOOTER, DATA which represents
*                that this subroutine is called for getting HEADER, FOOTER & DATA
*                content
* PROCESS.DATE = The date for which the outward file is being built
* DD.HEADER    = The content of the DD.HEADER record.
* OUT.FORMAT.ID = The ID of the DD.OUT.FORMAT RECORD being used.
* FIELD.NAME    = the FIELD.NAME as defined in DD.OUT.FORMAT record
* FC            = the Multi value no for which this subroutine is called
* DD.ITEM.ID    = the DD.ITEM ids for which this subroutine is called ( FM separator)
* TOTAL.AMOUNT  = If HDR.FTR.DATA = DATA and the COMBINE.DD.ITEM = Y in the mandate
*                 for which the DATA content is being built, this field contains the
*                 TOTAL amount of all the DD.ITEM under this mandate that are being
*                 included in the outward file generated.
*                 If COMBINE.DD.ITEM is not Y , then this field will contain the
*                 amount for each DD.ITEM specified in DD.ITEM.ID.
* ROUTINE.OUTPUT = the content of the outward file record being built before calling
*                  this subroutine.


* Outgoing parameters:

* FIELD.OUTPUT   = The ouput content
* ROUTINE.ERROR = Any errors raised ( Will be logged in exception log)

*======================================================================================
* MODIFICATIONS :

* 26/09/03 - EN_10002016
*            Initial Version
*
* 16/06/05 - BG_100008760
*            Removed the condition for OUT.FORMAT.ID.
*
* 25/02/15 - Enhancement 1265068/ Task 1265069
*          - Including $PACKAGE
*
*18/09/15 - Enhancement 1265068 / Task 1475953
*         - Routine Incorporated
*=======================================================================================
    $USING EB.SystemTables
    $USING DD.Contract

    IF ( HDR.FTR.DATA[1,1] = 'H') OR (HDR.FTR.DATA[1,1] = 'F') THEN

        BEGIN CASE
            CASE FIELD.NAME = 'TOTAL AMOUNT'
                FIELD.OUTPUT = DD.HEADER<DD.Contract.Header.HdrTotAmount>
            CASE FIELD.NAME = 'TOTAL ITEM'
                FIELD.OUTPUT = DD.HEADER<DD.Contract.Header.HdrNoRecords>
        END CASE

    END

    IF HDR.FTR.DATA[1,1] = 'D' AND FIELD.NAME = 'AMOUNT' THEN
        FIELD.OUTPUT = TOTAL.AMOUNT
    END


    RETURN
    END
