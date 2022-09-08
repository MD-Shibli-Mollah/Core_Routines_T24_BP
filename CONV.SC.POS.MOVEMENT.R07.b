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

*
*-----------------------------------------------------------------------------
* <Rating>-88</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE SC.ScvValuationUpdates
    SUBROUTINE CONV.SC.POS.MOVEMENT.R07
*-----------------------------------------------------------------------------
* Conversion routine for SC.POS.MOVEMENT concat file
*-----------------------------------------------------------------------------
* Modification History:
* 27/09/09 - EN_10003081
*            Re-design SC.POS.MOVEMENT concat file
*
* 20/11/09 - HD0944947(8155)
*            SC.POS.MOVEMENT file is converted only for the master company.
*
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_DAS.COMMON
    $INSERT I_DAS.COMPANY

* Equate field numbers to position manually, do no use $INSERT
    EQU SUFFIXES TO 3
    EQU FILE.CONTROL.CLASS TO 6

    SAVE.ID.COMPANY = ID.COMPANY
    SEL.COMP.LIST = DAS.COMPANY$REAL.COMPANIES
    CALL DAS('COMPANY',SEL.COMP.LIST,'','')


    LOOP
        REMOVE K.COMPANY FROM SEL.COMP.LIST SETTING MORE.COMPANIES
    WHILE K.COMPANY:MORE.COMPANIES

        IF K.COMPANY NE ID.COMPANY THEN
            CALL LOAD.COMPANY(K.COMPANY)
        END
        SC.INSTALLED = ''
        LOCATE 'SC' IN R.COMPANY(EB.COM.APPLICATIONS)<1,1> SETTING SC.INSTALLED THEN
            GOSUB COMPANY.INITIALISATION    ;* specific COMPANY initialisation

            GOSUB PROCESS.FILE    ;* perform required action on company file


        END

    REPEAT

    IF ID.COMPANY NE SAVE.ID.COMPANY THEN
        CALL LOAD.COMPANY(SAVE.ID.COMPANY)
    END

    RETURN

*-----------------------------------------------------------------------------
PROCESS.FILE:
* perform required action on company specific file

* do not use EB.READLIST as large volumes can cause hanging

    SELECT F.FILENAME
    END.OF.LIST = 0

    LOOP
        READNEXT POS.ID ELSE
            END.OF.LIST = 1
        END
    UNTIL END.OF.LIST
        IF FIELD(POS.ID,'.',2) THEN
            CONTINUE
        END
        * use READ, not F.READ
        READ R.POS.MVMT FROM F.FILENAME,POS.ID THEN
            * preform specific file conversion here
            GOSUB CONVERSION.PROCESS
        END
        DELETE F.FILENAME, POS.ID
    REPEAT

    RETURN

*-----------------------------------------------------------------------------
CONVERSION.PROCESS:

    NO.OF.POS.MVMT = DCOUNT(R.POS.MVMT,@FM)
    FOR POS.NO = 1 TO NO.OF.POS.MVMT
        POS.MVMT.ID = POS.ID:'.':R.POS.MVMT<POS.NO,1>
        R.NEW.POS.MVMT = ''
        READ R.NEW.POS.MVMT FROM F.FILENAME,POS.MVMT.ID THEN
            R.NEW.POS.MVMT<-1> = R.POS.MVMT<POS.NO,2>
        END ELSE
            R.NEW.POS.MVMT = R.POS.MVMT<POS.NO,2>
        END
        WRITE R.NEW.POS.MVMT ON F.FILENAME,POS.MVMT.ID
    NEXT POS.NO
    RETURN

*------------------------------------------------------------------------------
COMPANY.INITIALISATION:
* specific COMPANY initialisation
* open files and read records specific to each company

    UNAUTH.REQD = 0
    HIST.REQD = 0

    F.FILENAME = ''
    PGM.NAME = 'SC.POS.MOVEMENT'
    ID = 'F.':PGM.NAME
    CALL OPF(ID,F.FILENAME)



    RETURN




    END
