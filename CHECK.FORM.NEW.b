* @ValidationCode : MjotMTQ1MjEyOTYwNjpDcDEyNTI6MTU3MTMwNDM2NDE1NTpuYWdhZHVyZ2E6MTowOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwMi40OjEwOjEw
* @ValidationInfo : Timestamp         : 17 Oct 2019 14:56:04
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : nagadurga
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 10/10 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201902.4
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

*-----------------------------------------------------------------------------
* <Rating>-21</Rating>
*-----------------------------------------------------------------------------
*Subroutine to check EB.MORTGAGE.FORM1 id is already existing or not
$PACKAGE OP.ModelBank
SUBROUTINE CHECK.FORM.NEW

* 04-03-16 - 1653120
*            Incorporation of components
*
* 17-10-19 - Task : 3390931 / Defect : 3387366
*            Performance issue due to selecting all records via the routine CHECK.FORM.NEW 

    $USING OP.ModelBank
    $USING EB.DataAccess
    $USING EB.SystemTables

    GOSUB INITIALISE
    GOSUB PROCESS

INITIALISE:
   
    FORM.ERR = ''
    R.FORM = ''
RETURN
PROCESS:
    R.FORM = OP.ModelBank.EbMortgageFormOne.Read(EB.SystemTables.getIdNew(),FORM.ERR) ;* Do read instead of select
    IF NOT(FORM.ERR) THEN ;*If record exist then proceed
        EB.SystemTables.setRNew(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCheckPrElig, 'No'); tmp=EB.SystemTables.getT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCheckPrElig); tmp<3>='NOINPUT'; EB.SystemTables.setT(OP.ModelBank.EbMortgageFormOne.EbMorFivThrCheckPrElig, tmp)
    END
   
RETURN
END
