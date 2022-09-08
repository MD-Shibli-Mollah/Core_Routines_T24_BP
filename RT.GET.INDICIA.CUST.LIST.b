* @ValidationCode : MjoyMDgyNTYzMTYyOmNwMTI1MjoxNjE3NjIzMTE5NjI0OmtyYW1hc2hyaTotMTotMTowOjE6ZmFsc2U6Ti9BOkRFVl8yMDIxMDMuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 05 Apr 2021 17:15:19
* @ValidationInfo : Encoding          : cp1252
* @ValidationInfo : User Name         : kramashri
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_202103.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE RT.BalanceAggregation
SUBROUTINE RT.GET.INDICIA.CUST.LIST(CustList)
*-----------------------------------------------------------------------------
* Local API to return the customers for whom CRS/FATCA indicia calculation process should happen
*-----------------------------------------------------------------------------
* Modification History :
*
* 24/07/19 - Task 3248790
*            Local API to return the customers for whom CRS/FATCA indicia
*            calculation process should happen
*
* 12/10/20 - Enhancement 3972389 / Task 4016760
*            Customer Addition for Entities
*
* 07/12/20 - Enhancement 4076219 / Task 4059536
*            Customer Addition for Territories check
*
* 06/01/21 - Enhancement 4175618 / Task 4139716
*            Standing instruction indicia processing
*
* 03/02/21 - Enhancement 4175618 / Task 4210532
*            Standing instruction indicia processing - Customer addition for code coverage
*
* 11/03/21 - Enhancement 4246863 / Task 4246866
*            BIL Document Renewal changes
*
* 30/03/21 - Enhancement 4246863 / Task 4310910
*            BIL Document Renewal changes - Customer addition for code coverage
*-----------------------------------------------------------------------------
    $USING RT.BalanceAggregation
    $USING EB.API
*-----------------------------------------------------------------------------

    GOSUB BuildCustList

RETURN
*-----------------------------------------------------------------------------
BuildCustList:

* user-defined customer list
    CustList = '182370':@FM:'182371':@FM:'182372':@FM:'182373':@FM:'182374':@FM:'182375':@FM:'182376':@FM:'182377':@FM:'182378':@FM:'182379':@FM:'182380':@FM:'182381':@FM:'182382':@FM:'182383':@FM:'182384':@FM:'182385':@FM:'182386':@FM:'182387':@FM:'182388':@FM:'182389':@FM:'182390':@FM:'182391':@FM:'182392':@FM:'182393':@FM:'182394':@FM:'182399':@FM:'182400':@FM:'182401':@FM:'182402':@FM:'182403':@FM:'182407':@FM:'182408':@FM:'182411':@FM:'182412':@FM:'182413':@FM:'182414':@FM:'182470':@FM:'182471':@FM:'182472':@FM:'182473':@FM:'182474':@FM:'182475':@FM:'182476':@FM:'182477':@FM:'182478':@FM:'182479':@FM:'182480':@FM:'182481':@FM:'182482':@FM:'182483':@FM:'182484':@FM:'182485':@FM:'182486':@FM:'182487':@FM:'182488':@FM:'182489':@FM:'182325':@FM:'182326':@FM:'182327':@FM:'182328':@FM:'182329':@FM:'182330':@FM:'182331':@FM:'182332':@FM:'182333':@FM:'182334':@FM:'182335':@FM:'182336':@FM:'182339':@FM:'182340':@FM:'182341':@FM:'182342':@FM:'182343':@FM:'182344':@FM:'182345':@FM:'182346':@FM:'182347':@FM:'182348':@FM:'182349':@FM:'182354':@FM:'182355':@FM:'182356':@FM:'182357':@FM:'182358':@FM:'182362':@FM:'182363':@FM:'182366':@FM:'182367':@FM:'182368':@FM:'182369':@FM:'182490':@FM:'182491':@FM:'182494':@FM:'182495':@FM:'182496':@FM:'182497':@FM:'182498':@FM:'182499':@FM:'182502':@FM:'182503':@FM:'182504':@FM:'182505':@FM:'182506':@FM:'182507':@FM:'182508':@FM:'182509'
* Customer list for entities
    CustList<-1> = '182704':@FM:'182705':@FM:'182706':@FM:'182707':@FM:'182708':@FM:'182709':@FM:'182710':@FM:'182711':@FM:'182712':@FM:'182713':@FM:'182714':@FM:'182715':@FM:'182716':@FM:'182717':@FM:'182718':@FM:'182719':@FM:'182720':@FM:'182721':@FM:'182722':@FM:'182723':@FM:'182724':@FM:'182725':@FM:'182726':@FM:'182727':@FM:'182728':@FM:'182729'
* Customer list for Territories SI
    CustList<-1> = '182749':@FM:'182750':@FM:'182751':@FM:'182753':@FM:'182765':@FM:'182766':@FM:'182767':@FM:'182769':@FM:'182770':@FM:'182775':@FM:'182776':@FM:'182777':@FM:'182783':@FM:'182784':@FM:'182791':@FM:'182792':@FM:'182793':@FM:'182795':@FM:'182796':@FM:'182797'
* Standing instruction indicia SI
    CustList<-1> = '182251':@FM:'182252':@FM:'182253':@FM:'182254':@FM:'182255':@FM:'182256':@FM:'182257':@FM:'182258':@FM:'182259':@FM:'182260':@FM:'182261':@FM:'182262':@FM:'182263':@FM:'182264':@FM:'182265':@FM:'182266':@FM:'182267':@FM:'182268':@FM:'182269':@FM:'182270':@FM:'182271':@FM:'182272':@FM:'182273':@FM:'182274':@FM:'182275':@FM:'182276':@FM:'182277':@FM:'182278':@FM:'182279':@FM:'182280':@FM:'182281':@FM:'182282':@FM:'182283':@FM:'182284':@FM:'182285':@FM:'182286':@FM:'182287':@FM:'182288':@FM:'182289':@FM:'182290':@FM:'182291':@FM:'182292':@FM:'182293':@FM:'182294':@FM:'182295':@FM:'182296':@FM:'182297'
    CustList<-1> = '182951':@FM:'182952':@FM:'182953':@FM:'182954':@FM:'182955':@FM:'182956':@FM:'182957':@FM:'182958':@FM:'182959':@FM:'182960':@FM:'182961':@FM:'182962':@FM:'182963':@FM:'182964':@FM:'182965':@FM:'182966':@FM:'182967':@FM:'182968':@FM:'182969':@FM:'182970':@FM:'182971':@FM:'182972':@FM:'182973':@FM:'182974':@FM:'182975':@FM:'182976':@FM:'182977':@FM:'182978':@FM:'182979':@FM:'182980':@FM:'182981':@FM:'182982':@FM:'182983':@FM:'182984':@FM:'182985':@FM:'182986':@FM:'182987':@FM:'182988':@FM:'182989':@FM:'182990':@FM:'182991':@FM:'182992':@FM:'182993':@FM:'182994':@FM:'182995':@FM:'182996':@FM:'182997'

* BIL Document Renewal SI
* CRS customers
    CustList<-1> = '176441':@FM:'176442':@FM:'176443':@FM:'176444':@FM:'176445':@FM:'176446':@FM:'176447':@FM:'176448':@FM:'176449':@FM:'176450':@FM:'176451':@FM:'176452':@FM:'176453':@FM:'176454':@FM:'176477':@FM:'176478':@FM:'176479':@FM:'176480'
* FATCA Customers
    CustList<-1> = '176455':@FM:'176456':@FM:'176457':@FM:'176458':@FM:'176459':@FM:'176460':@FM:'176461':@FM:'176462':@FM:'176463':@FM:'176464':@FM:'176465':@FM:'176466':@FM:'176467':@FM:'176476':@FM:'176481':@FM:'176482'

RETURN
*-----------------------------------------------------------------------------
END

