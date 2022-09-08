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
* <Rating>225</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.Service
    SUBROUTINE CONV.JOB.LIST.FILES.G14
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DAS.COMMON
    $INSERT I_DAS.VOC
*--------------------------------------------------------------------
*
* This routine will look at the VOC records for the JOB.LIST
* entries to see if there are duplicates. If there are
* any duplicate unix file names then we delete the VOC
* so that they will be recreated whent he next COB is run
*--------------------------------------------------------------------
* Modifications:
*
* 15/12/03 - BG_100005724
*            Creation
*
* 23/03/07 - EN_10003192
*            DAS Implementation
*--------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB CHECK.FOR.DUPS
    GOSUB REMOVE.DUPS
*
    RETURN
*
*------------------------------------------------------------------
INITIALISE:
*==========
*
    OPEN "VOC" TO F.VOC ELSE
        TEXT = "NO VOC FILE FOUND"
        CALL FATAL.ERROR("CONV.JOB.FILES.G14")
    END
*
    DUP.LIST = ''
*
    RETURN
*
*------------------------------------------------------------------
CHECK.FOR.DUPS:
*==============
** Select VOC and look at field of the records. Store and compare
** duplicates
*
    THE.LIST = dasVoc$IDlk    ;*EN_10003192 S
    THE.ARGS = "F...JOB.LIST..."
    TABLE.SUFFIX = ""
    CALL DAS("VOC",THE.LIST,THE.ARGS,TABLE.SUFFIX)
    ID.LIST = ''
    ID.LIST = THE.LIST        ;*EN_10003192 E
*

    LOOP
        REMOVE FILE.ID FROM ID.LIST SETTING YD
    WHILE FILE.ID:YD
        IF FILE.ID[5,10] = ".JOB.LIST." AND NUM(FILE.ID[".",4,1]) THEN
            READ VOC.REC FROM F.VOC, FILE.ID THEN
                FILE.LOC = VOC.REC<2>
                LOCATE FILE.LOC IN DUP.LIST<1,1> SETTING YPOS THEN    ;* Duplicate
                    LOCATE FILE.ID IN DUP.LIST<2,YPOS,1> BY "AR"  SETTING FILE.POS ELSE NULL        ;* Store files in order (don't delete list 1)
                    DUP.LIST<2,YPOS,FILE.POS> = FILE.ID
                END ELSE
                    DUP.LIST<1,YPOS> = FILE.LOC
                    DUP.LIST<2,YPOS> = FILE.ID
                END
            END
        END
    REPEAT
*
    RETURN
*
*-------------------------------------------------------------------
REMOVE.DUPS:
*===========
* Remove the VOC entry for the 2nd and nth other FIles with the same
* file location
*
    NO.LOCS = DCOUNT(DUP.LIST<1>,VM)
    FOR IND = 1 TO NO.LOCS
        NO.FILES = DCOUNT(DUP.LIST<2,IND>,SM)
        FOR IND2 = 2 TO NO.FILES
            CRT "Removing Duplicate File VOC entry ":DUP.LIST<2,IND,IND2>
            DELETE F.VOC, DUP.LIST<2,IND,IND2>
        NEXT IND2
    NEXT IND
*
    RETURN
*
END

