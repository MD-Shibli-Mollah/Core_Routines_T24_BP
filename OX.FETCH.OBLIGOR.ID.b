* @ValidationCode : Mjo3NTE0NjYyNzk6Y3AxMjUyOjE1OTY3OTgyMTEwODQ6a3JhbWFzaHJpOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMjAwOC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 07 Aug 2020 16:33:31
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : kramashri
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202008.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE OX.ObligorObject
SUBROUTINE OX.FETCH.OBLIGOR.ID(FIELD.VALUE.ID,TXN.ID,FILE.ID)
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*
* 07/08/2020 - Defect 3898659 / Task 3898526
*              New routine to fetch obligor ID from Links file to populate FV
*-----------------------------------------------------------------------------
    $USING EB.SystemTables
    $USING OX.ObligorObject
*-----------------------------------------------------------------------------

** FV id Format : SCRPT200530138004-23.EOD-GET.OX.ID-JOINT.10015270203-6

    GOSUB INITIALISE
    GOSUB PROCESS
    
RETURN
*-----------------------------------------------------------------------------
INITIALISE:
    
    FILE.ID = ''
    CONT.PART = ''
    CONTRACT.ID = ''
    READ.ER = ''
    R.LINKS = ''
    
RETURN
*-----------------------------------------------------------------------------
PROCESS:
    
    CONT.PART = FIELD(FIELD.VALUE.ID,"-", 4)
    CONTRACT.ID = FIELD(CONT.PART,".", 2)

* Return if contract id is null
    IF NOT(CONTRACT.ID) THEN
        RETURN
    END

* Read Obligor links record to get the obligor ID
    R.LINKS = OX.ObligorObject.ObligorLinks.Read(CONTRACT.ID, READ.ER)
    IF R.LINKS<1> THEN
        FILE.ID = R.LINKS<1>
    END
    
RETURN
*-----------------------------------------------------------------------------
END


