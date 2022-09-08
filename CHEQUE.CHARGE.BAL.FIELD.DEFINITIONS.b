* @ValidationCode : MjotMTEwNzc2MTc4MDpDcDEyNTI6MTU2NDU3MTE2ODk1OTpzcmF2aWt1bWFyOi0xOi0xOjA6MTpmYWxzZTpOL0E6REVWXzIwMTkwOC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 Jul 2019 16:36:08
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : sravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201908.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* Version n dd/mm/yy  GLOBUS Release No. 200508 30/06/05
*-----------------------------------------------------------------------------
* <Rating>-12</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE CQ.ChqFees
    SUBROUTINE CHEQUE.CHARGE.BAL.FIELD.DEFINITIONS
*-----------------------------------------------------------------------------
* Modification History :
*
* 02/03/15 - Enhancement 1265068 / Task 1269515
*           - Rename the component CHQ_Fees as ST_ChqFees and include $PACKAGE
*
*07/07/15 -  Enhancement 1265068
*			 Routine incorporated
*
* 30/07/19 - Enhancement 3220240 / Task 3220250
*            TI Changes - Component moved from ST to CQ.
*
*-----------------------------------------------------------------------------

    $USING EB.API
	$USING EB.SystemTables
	$USING CQ.ChqFees 

*-----------------------------------------------------------------------------

    GOSUB INITIALISE                   ; * Special Initialising

    GOSUB DEFINE.FIELDS

    RETURN
*-----------(Main)

*-----------------------------------------------------------------------------
INITIALISE:
*----------
    OBJECT.ID="ACCOUNT"
    MAX.LEN=""
    EB.API.GetObjectLength(OBJECT.ID,MAX.LEN)
    ID.LEN=11+MAX.LEN
    EB.SystemTables.clearF()
    EB.SystemTables.clearN()
    EB.SystemTables.clearT()
    EB.SystemTables.clearCheckfile()
    EB.SystemTables.clearConcatfile()
    EB.SystemTables.setIdCheckfile(""); EB.SystemTables.setIdConcatfile("")

    RETURN
*-----------(Initialise)


*-----------------------------------------------------------------------------
DEFINE.FIELDS:
*-------------
    EB.SystemTables.setIdF("CHEQUE.BAL.ID"); EB.SystemTables.setIdN(ID.LEN :'.1'); EB.SystemTables.setIdT("A")
*
    Z=0
*
    Z +=1 ; EB.SystemTables.setF(Z, 'XX<CHEQUE.STATUS'); EB.SystemTables.setN(Z, '2'); EB.SystemTables.setT(Z, ''); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    Z +=1 ; EB.SystemTables.setF(Z, 'XX-STATUS.DATE'); EB.SystemTables.setN(Z, '11'); EB.SystemTables.setT(Z, 'D'); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    Z +=1 ; EB.SystemTables.setF(Z, 'XX-CHRG.ACCOUNT'); EB.SystemTables.setN(Z, '16..C'); EB.SystemTables.setT(Z, ''); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    Z +=1 ; EB.SystemTables.setF(Z, 'XX-CHRG.CCY'); EB.SystemTables.setN(Z, '3'); EB.SystemTables.setT(Z, ''); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    Z +=1 ; EB.SystemTables.setF(Z, 'XX-EXCH.RATE'); EB.SystemTables.setN(Z, '19'); EB.SystemTables.setT(Z, 'AMT'); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    Z +=1 ; EB.SystemTables.setF(Z, 'XX-XX<CHRG.CODE'); EB.SystemTables.setN(Z, '11'); EB.SystemTables.setT(Z, 'A'); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    Z +=1 ; EB.SystemTables.setF(Z, 'XX-XX-CHRG.LCY.AMT'); EB.SystemTables.setN(Z, '19'); EB.SystemTables.setT(Z, 'AMT'); tmp=EB.SystemTables.getT(Z); tmp<2,2>=EB.SystemTables.getLccy(); EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    Z +=1 ; EB.SystemTables.setF(Z, 'XX-XX-CHRG.FCY.AMT'); EB.SystemTables.setN(Z, '19'); EB.SystemTables.setT(Z, 'AMT'); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    Z +=1 ; EB.SystemTables.setF(Z, 'XX-XX>CHRG.DATE'); EB.SystemTables.setN(Z, '11'); EB.SystemTables.setT(Z, 'D'); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    Z +=1 ; EB.SystemTables.setF(Z, 'XX-XX<TAX.CODE'); EB.SystemTables.setN(Z, '11'); EB.SystemTables.setT(Z, 'A'); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    Z +=1 ; EB.SystemTables.setF(Z, 'XX-XX-TAX.LCY.AMT'); EB.SystemTables.setN(Z, '19'); EB.SystemTables.setT(Z, 'AMT'); tmp=EB.SystemTables.getT(Z); tmp<2,2>=EB.SystemTables.getLccy(); EB.SystemTables.setT(Z, tmp); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)
    Z +=1 ; EB.SystemTables.setF(Z, 'XX>XX>TAX.FCY.AMT'); EB.SystemTables.setN(Z, '19'); EB.SystemTables.setT(Z, 'AMT'); tmp=EB.SystemTables.getT(Z); tmp<3>='NOINPUT'; EB.SystemTables.setT(Z, tmp)

*
* Live files DO NOT require V = Z + 9 as there are not audit fields.
* But it does require V to be set to the number of fields
*
    EB.SystemTables.setV(Z)

    RETURN
*-----------(Define.Fields)
*-----------------------------------------------------------------------------

    END
*-----(End of Routine)
