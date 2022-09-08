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
* <Rating>96</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE DX.Trade
      SUBROUTINE CONV.DX.TRADE.G13.1(YID,YREC,YFILE)


* 29/01/03 - GLOBUS_BG_100003274
*          - Forward patching from 131dev
*
* 11/02/04 - GLOBUS_CI_100017292
*            The ETEXT is not being used, instead the 
*            Error is being displayed when contract code is
*            not available.
*

$INSERT I_COMMON
$INSERT I_EQUATE
$INSERT I_F.DX.CONTRACT.MASTER
$INSERT I_F.DX.TRADE

      COUNT.VM1 = ''
      COUNT.VM2 = ''
      R.CONTRACT = ''

      IF INDEX(YFILE, "$HIS", 1) THEN RETURN  ; *CI_100017292 S/E

      FN.DX.CONTRACT.MASTER = "F.DX.CONTRACT.MASTER"
      F.DX.CONTRACT.MASTER = ''

      CALL OPF(FN.DX.CONTRACT.MASTER, F.DX.CONTRACT.MASTER)

      CONTRACT.ID = YREC<1>   ; *CI_100017292 S/E
      Y.ERR = ''  ; *CI_100017292 S/E
      CALL F.READ(FN.DX.CONTRACT.MASTER,CONTRACT.ID,R.CONTRACT,F.DX.CONTRACT.MASTER,Y.ERR)
                               ; *CI_100017292 - S
      IF Y.ERR <> '' THEN
         CRT "**** Error - Contract Master : " : CONTRACT.ID : " not found for Trade : ": YID 
      END   ; *CI_100017292 - E


* Main prog

      COUNT.VM1 = DCOUNT(YREC<34>,VM)
      TEMP1 = YREC<34>
      FOR I = 1 TO COUNT.VM1
         YREC<86,I> = R.CONTRACT<DX.CM.PREM.POST.OFFSET>
      NEXT I
      COUNT.VM2 = DCOUNT(YREC<98>,VM)
      FOR I = 1 TO COUNT.VM2
         YREC<154,I> = R.CONTRACT<DX.CM.PREM.POST.OFFSET>
      NEXT I
      YREC<84> = ''
      YREC<85> = ''
      FOR J = 87 TO 97
         YREC<J> = ''
      NEXT J

* blank the fields on the secondary side

      YREC<152> = ''
      YREC<153> = ''
      FOR K = 155 TO 165
         YREC<K> = ''
      NEXT K

      YREC<209> = ''

      RETURN
   END
