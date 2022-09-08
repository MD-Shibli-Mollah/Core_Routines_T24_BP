* @ValidationCode : MjotNDE5MDU1NjUwOkNwMTI1MjoxNjE1NDgyMjI5NzYxOmpheWFsYWtzaG1pbnI6LTE6LTE6MDoxOmZhbHNlOk4vQTpERVZfMjAyMTAzLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 11 Mar 2021 22:33:49
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : jayalakshminr
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE RT.Regulation
SUBROUTINE GET.INDICIA.CUST.LIST(CustList)
*-----------------------------------------------------------------------------
* Local API to return the customers for whom CRS/FATCA indicia calculation process should happen
*-----------------------------------------------------------------------------
* Modification History :
*
* 24/07/19 - Task 3248790
*            Local API to return the customers for whom CRS/FATCA indicia
*            calculation process should happen
*
* 11/03/21 - Enhancement 4020994 / Task 4278949
*            Migration from ST to RT
*-----------------------------------------------------------------------------

    $USING RT.Regulation
    $USING EB.API
*-----------------------------------------------------------------------------

    GOSUB BuildCustList

RETURN
*-----------------------------------------------------------------------------
BuildCustList:

* user-defined customer list
    CustList = '182370':@FM:'182371':@FM:'182372':@FM:'182373':@FM:'182374':@FM:'182375':@FM:'182376':@FM:'182377':@FM:'182378':@FM:'182379':@FM:'182380':@FM:'182381':@FM:'182382':@FM:'182383':@FM:'182384':@FM:'182385':@FM:'182386':@FM:'182387':@FM:'182388':@FM:'182389':@FM:'182390':@FM:'182391':@FM:'182392':@FM:'182393':@FM:'182394':@FM:'182399':@FM:'182400':@FM:'182401':@FM:'182402':@FM:'182403':@FM:'182407':@FM:'182408':@FM:'182411':@FM:'182412':@FM:'182413':@FM:'182414':@FM:'182470':@FM:'182471':@FM:'182472':@FM:'182473':@FM:'182474':@FM:'182475':@FM:'182476':@FM:'182477':@FM:'182478':@FM:'182479':@FM:'182480':@FM:'182481':@FM:'182482':@FM:'182483':@FM:'182484':@FM:'182485':@FM:'182486':@FM:'182487':@FM:'182488':@FM:'182489':@FM:'182325':@FM:'182326':@FM:'182327':@FM:'182328':@FM:'182329':@FM:'182330':@FM:'182331':@FM:'182332':@FM:'182333':@FM:'182334':@FM:'182335':@FM:'182336':@FM:'182339':@FM:'182340':@FM:'182341':@FM:'182342':@FM:'182343':@FM:'182344':@FM:'182345':@FM:'182346':@FM:'182347':@FM:'182348':@FM:'182349':@FM:'182354':@FM:'182355':@FM:'182356':@FM:'182357':@FM:'182358':@FM:'182362':@FM:'182363':@FM:'182366':@FM:'182367':@FM:'182368':@FM:'182369':@FM:'182490':@FM:'182491':@FM:'182494':@FM:'182495':@FM:'182496':@FM:'182497':@FM:'182498':@FM:'182499':@FM:'182502':@FM:'182503':@FM:'182504':@FM:'182505':@FM:'182506':@FM:'182507':@FM:'182508':@FM:'182509'
    
RETURN
*-----------------------------------------------------------------------------
END
