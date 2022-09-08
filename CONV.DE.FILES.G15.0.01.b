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
* <Rating>71</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DE.Config
    SUBROUTINE CONV.DE.FILES.G15.0.01
**********************************************
* This routine needs to be run when upgrading to G15.0.01
* as few files in the delivery processing have been
* restructured to provide better performance while running
* the generic interface as T24 service.
*********************************************
* 07/09/2004 - BG_100007188
*              WRITE is missing for DE.O.REPAIR/DE.I.REPAIR
*********************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE

* The files that will be converted by this routine are as follows:
* 1. DE.O.PRI
* 2. DE.I.PRI
* 3. DE.O.REPAIR
* 4. DE.I.REPAIR
* 5. DE.O.AWAK
* 6. DE.O.PRI.<Interface>
*
    FILE.LIST = ''
    FILE.LIST<-1> = 'F.DE.O.PRI'
    FILE.LIST<-1> = 'F.DE.I.PRI'
    FILE.LIST<-1> = 'F.DE.O.REPAIR'
    FILE.LIST<-1> = 'F.DE.I.REPAIR'
    FILE.LIST<-1> = 'F.DE.O.AWAK'
*
* Read all interface records and load the file names of DE.O.PRI.<Interface> based on that.
*
    FN.DE.CARRIER = 'F.DE.CARRIER'; F.DE.CARRIER = ''
    CALL OPF(FN.DE.CARRIER,F.DE.CARRIER)
*
    SEL.CMD = 'SELECT ':FN.DE.CARRIER
    CARR.LIST = ''
    CALL EB.READLIST(SEL.CMD,CARR.LIST,'','','')
*
    LOOP
        REMOVE CARR.ID FROM CARR.LIST SETTING MORE.ID
    WHILE CARR.ID:MORE.ID
        FILE.LIST<-1> = 'F.DE.O.PRI.':CARR.ID
    REPEAT
*
* Now, start converting the records one by one.
*
    LOOP
        REMOVE FILE.NAME FROM FILE.LIST SETTING MORE.FILE
    WHILE FILE.NAME:MORE.FILE
        IF FILE.NAME NE '' THEN GOSUB SELECT.RECORDS
    REPEAT
    RETURN
*
SELECT.RECORDS:
*************
    SEL.CMD = ''
    SEL.CMD = 'SELECT ':FILE.NAME
    ID.LIST =  ''
    CALL EB.READLIST(SEL.CMD,ID.LIST,'','','')
    LOOP
        REMOVE ID.TO.PROCESS FROM ID.LIST SETTING FOUND
    WHILE ID.TO.PROCESS:FOUND
        GOSUB WRITE.NEW.RECORDS
    REPEAT
    RETURN
*
WRITE.NEW.RECORDS:
************
* Read each ID selected and write each key stored as a separate record
*
    RECORDS.TO.PROCESS = ''
    F.FILE.NAME = ''; CALL OPF(FILE.NAME,F.FILE.NAME)
    READ RECORDS.TO.PROCESS FROM F.FILE.NAME, ID.TO.PROCESS THEN

* Write record with new ID
        LOOP
            REMOVE REC.ID FROM RECORDS.TO.PROCESS SETTING ID.FOUND
        WHILE REC.ID:ID.FOUND
            IF FILE.NAME EQ 'F.DE.O.REPAIR' OR FILE.NAME EQ 'F.DE.I.REPAIR' THEN
                NEW.ID = REC.ID
            END ELSE
                NEW.ID = ID.TO.PROCESS:'-':REC.ID
            END
            WRITE '' TO F.FILE.NAME, NEW.ID
        REPEAT

* Delete old records now
        DELETE F.FILE.NAME,ID.TO.PROCESS
    END
*
    RETURN


END
