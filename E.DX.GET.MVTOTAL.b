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

* Version 3 02/06/00  GLOBUS Release No. 200512 09/12/05
*-----------------------------------------------------------------------------
* <Rating>-31</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.ModelBank
    SUBROUTINE E.DX.GET.MVTOTAL
*-----------------------------------------------------------------------------
* Program Description
*-----------------------------------------------------------------------------
* Modification History :
*
* 21/08/08 - BG_100019614 - aleggett@temenos.com
*            Convert CACHE.READs and CACHE.DBRs for non-parameter tables to F.READs
*            Cache should only be used for small tables of static data.  Overuse of
*            cache adversely affects system performance.
*
* 04/06/15 - EN-1322379 / Tak-1328842
*            Incorporation of DX_ModelBank
*
*-----------------------------------------------------------------------------
    $USING EB.Reports
    $USING EB.API
*-----------------------------------------------------------------------------

    GOSUB INITIALISE

    GOSUB MAIN.PROCESS

    EB.Reports.setOData(MVTOTAL)

    RETURN

*-----------------------------------------------------------------------------
INITIALISE:

* Local variables

    REF.APPLICATION = EB.Reports.getREnq()<EB.Reports.Enquiry.EnqFileName>

    REF.ID = EB.Reports.getId()

    FIELD.NAME = EB.Reports.getOData()

    CACHE = 0 

    FIELD.DATA = ''
    FIELD.DEFS = ''
    FIELD.ERR = ''

    RETURN

*-----------------------------------------------------------------------------
MAIN.PROCESS:

* Get field data

    EB.API.Getfield (REF.APPLICATION,REF.ID,FIELD.NAME,FIELD.DATA,CACHE,FIELD.DEFS,'',FIELD.ERR)

* Total up multivalues

    MVTOTAL = SUM(FIELD.DATA)

    RETURN

*-----------------------------------------------------------------------------
*
    END
