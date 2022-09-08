* @ValidationCode : Mjo3MTg5NjQ1MTQ6Q3AxMjUyOjE1OTM3MDc3MjE3Mzc6c2hhaWt6YWtlZXJhOjE6MDowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIwMDUuMjAyMDA0MjQtMDYxODo0OjQ=
* @ValidationInfo : Timestamp         : 02 Jul 2020 22:05:21
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : shaikzakeera
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 4/4 (100.0%)
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202005.20200424-0618
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.


$PACKAGE SC.SccEntitlements
SUBROUTINE SC.ENT.INCOME.SUPP.READ(r.recId, r.record, r.Error)
*-----------------------------------------------------------------------------
*This routine performs Read operation on file SC.ENT.INCOME.SUPP
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
* 07/02/2020 - DEFECT - 3831287/38350001
*               Unable to read SC.ENT.INCOME.SUPP as access specifier is not public

*-----------------------------------------------------------------------------
    $USING SC.SccEntitlements
*-----------------------------------------------------------------------------


    GOSUB Process ; * *Do the Read Operation on concate file

RETURN

*-----------------------------------------------------------------------------

*** <region name= Process>
Process:
*** <desc>Call Read  operation on file SC.ENT.INCOME.SUPP </desc> </desc>
    r.record =  SC.SccEntitlements.EntIncomeSupp.Read(r.recId, r.Error)
RETURN
*** </region>

*-----------------------------------------------------------------------------
END
