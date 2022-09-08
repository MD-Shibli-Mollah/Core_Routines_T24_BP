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

* Version 2 29/05/01  GLOBUS Release No. G14.1.01 11/12/03
*-----------------------------------------------------------------------------
* <Rating>578</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE EB.DatInterface
      SUBROUTINE JGLOBUS.PROFILE(FULL.SHORT,JBCPATH,JPROFILE)
*-----------------------------------------------------------------------------------
* Routine to return a full (for logging into jBASE) or short to run a jBASE program
*
* 22/05/01 - GB0101443
*            Add EBS.LOGIN paragraph into the .profile to avoid initiating too
*            many processes and 'hanging' problems when trying to logout'
*
* 23/10/01 - GLOBUS_BG_100000162
*            JGLOBUS.PROFILE has been modified to include
*            few env variables for jBASE.
*
* 12/11/01 - GLOBUS_BP_100000218
*            Ensure that the bins are set correctly in PATH (they were
*            previously missing the $HOME portion.
*
* 18/01/02 - GLOBUS_BG_100000379
*            Changes made so that GLOBUS displays the
*            correct machine date
*
* 28/02/2002 - GLOBUS_BG_100000497
*             $LIBPATH is appended to the LIBPATH , Lang settings were
*             done and JBCBASETMP will have ttyno as  part of name instead of process id.
*            This will recycle the tmp files and will stop the growth of size of the temp directory
*            The changes done in BG_100000379 is removed since LANG is included it will take care
*            of date and language problems.
* 21/11/02 - GLOBUS_EN_10001510
*            Included EX.INTEGRITY to make GAC work in jBASE
*
* 24/11/03 - GLOBUS_BG_100005705
*            Record locking flag - environment variable added
* 08/12/03 - GLOBUS_BG_100005770
*            Latest Changes to .profile . Execution of the VOC para loginproc
*            included.
*------------------------------------------------------------------------------------
*
      GOSUB INITIALISATION
      IF FULL.SHORT = "FULL" THEN
         GOSUB FULL.PROFILE
      END ELSE
         GOSUB SHORT.PROFILE
      END
*
      RETURN
*----------------------------------------------------------------------------------
INITIALISATION:
*
      JPROFILE = ""
*
      IF JBCPATH = "" THEN
         JBCPATH = "/usr/jbc"            ; * Default location of jBASE
      END
* GLOBUS_BG_100005770 S
      OPEN '','VOC' TO F.VOC ELSE
         PRINT 'Cannot Open VOC !!!!!!!'
      END

      R.VOC = 'PQN'
      R.VOC<-1> = 'OSTART GLOBUS Y/N'
      R.VOC<-1> ='IP%1'
      R.VOC<-1> = 'IF %1 # "Y" IF %1 # "y" GO 99'
      R.VOC<-1> = 'HEBS.TERMINAL.SELECT'
      R.VOC<-1> = 'P'
      R.VOC<-1> = 'HEX'
      R.VOC<-1> = 'P'
      R.VOC<-1> = 'HEX.INTEGRITY'
      R.VOC<-1> = 'PX'
      R.VOC<-1> = '99 Hjsh -s jsh'
      R.VOC<-1> = 'PX'

      WRITE R.VOC TO F.VOC,'loginproc'
* GLOBUS_BG_100005770 E
*
      RETURN
*----------------------------------------------------------------------------------
FULL.PROFILE:
*
      JPROFILE<-1> = '#!/bin/ksh'        ; * GLOBUS_BG_100005770 S/E
      JPROFILE<-1> = '# -------------------- Profile.Ksh -----------------------------'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '# .profile template for korn shell to execute j shell'
      JPROFILE<-1> = '# after configuring the environment'
      JPROFILE<-1> = '# After creating a user and his home directory you'
      JPROFILE<-1> = '# should append this file to the .profile in ${HOME}'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '#         ######     #     #####  #######'
      JPROFILE<-1> = '#       # #     #   # #   #     # #'
      JPROFILE<-1> = '#       # #     #  #   #  #       #'
      JPROFILE<-1> = '#       # ######  #     #  #####  #####'
      JPROFILE<-1> = '#       # #     # #######       # #'
      JPROFILE<-1> = '#  #    # #     # #     # #     # #'
      JPROFILE<-1> = '#   ####  ######  #     #  #####  #######'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '# Set up the port, if it ever goes wild, then typing a single "X"'
      JPROFILE<-1> = '# should hopefully put it back, using the sequence Ctrl-J (^J), X, Ctrl-J (^J)'
      JPROFILE<-1> = '# whereby Ctrl-J means new line.'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '# Certain control characters used in some system stty settings may clash with'
      JPROFILE<-1> = '# control characters used within the JED/JSH programs, thus making the function'
      JPROFILE<-1> = '# appear not to work. In this case the clashing stty settings can be safely set'
      JPROFILE<-1> = '# to undefined thus allowing the control character to be processed by JED/JSH.'
      JPROFILE<-1> = '# e.g. Undefine stty "flush" character. stty flush ^-, where ^ is uparrow and '
      JPROFILE<-1> = '# - is the minus character. Alternatively JED can be configured to use alternative'
      JPROFILE<-1> = '# control characters via the .jedsrc file. See knowledge base.'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '# stty intr ^C kill  icanon opost echo echoe echok onlcr -lcase tab3'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '# undefine common stty settings to avoid clash with some terminfo and jed controls'
      JPROFILE<-1> = 'stty quit ^- dsusp ^- susp ^- erase ^h'
      JPROFILE<-1> = 'alias X="stty $(stty -g)"'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '# To set the default umask to 002. This allows the CREATE-FILE to create files with'
      JPROFILE<-1> = '# default permissions of 664. i.e. rw-rw-r--. '
      JPROFILE<-1> = '# Read/Write User, Read/Write Group, ReadOnly Others'
      JPROFILE<-1> = '# This enables file access permissions to be more easily controlled via user groups.'
      JPROFILE<-1> = '# Also in the case of network file access, unix locks required read/write access.'
      JPROFILE<-1> = '# '
      JPROFILE<-1> = '#umask 002'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '# Configure default prompt'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = 'PS1="$(uname)-\$PWD: "'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = 'export HOME=$PWD'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '# Configure ENV for environment'
      JPROFILE<-1> = 'ENV=${HOME}/.env'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '# default to vi editor and vi options and cd to home'
      JPROFILE<-1> = 'VISUAL=/usr/bin/vi'
      JPROFILE<-1> = 'set -o vi'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '# Set up the directory of where jBASE is being run from.'
      JPROFILE<-1> = '# The JBCRELEASEDIR shows where the executables, libraries, scripts etc.'
      JPROFILE<-1> = '# can be found for the particular release you want to run. The '
      JPROFILE<-1> = '# JBCGLOBALDIR shows where a few of the global constants can be'
      JPROFILE<-1> = '# found, such as the configuration file for the record locking'
      JPROFILE<-1> = '# mechanism -- these should be common to all releases running on'
      JPROFILE<-1> = '# the same system'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '# If undefined, they will resort to /usr/jbc as a default. However, they'
      JPROFILE<-1> = '# are initialised in this script to the default, so that if you move'
      JPROFILE<-1> = '# to another test release at a later stage, it makes it very easy to'
      JPROFILE<-1> = '# update the JBCRELEASEDIR variable to say /usr/testjbc and all the'
      JPROFILE<-1> = '# other variables fall in to place.'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = 'export JBCRELEASEDIR=':JBCPATH
      JPROFILE<-1> = 'export JBCGLOBALDIR=':JBCPATH
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '#    Set up the shared object file name where we will resolve'
      JPROFILE<-1> = '#    all the calls to subroutines made via. the CALL @Var() statements.'
      JPROFILE<-1> = '#    The default is $HOME/lib. If you want to use shared objects other'
      JPROFILE<-1> = '#    than in the default, set up a : delimited path of directory names'
      JPROFILE<-1> = '#    and/or object name to search in, by setting the JBCOBJECTLIST variable.'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '#    NOTE: When executing programs the PATH environment variable is used.'
      JPROFILE<-1> = '#    When locating subroutines the JBCOBJECTLIST environment variable is used'
      JPROFILE<-1> = '#    else by default the $HOME/lib directory. Therefore when cataloging ensure'
      JPROFILE<-1> = '# 	 that either the default $HOME/bin or $HOME/lib directories areused to store'
      JPROFILE<-1> = '#    the executables and shared libraries or else the environment variables'
      JPROFILE<-1> = '#	 JBCDEV_BIN and JBCDEV_LIB are configured to match PATH and JBCOBJECTLIST.'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '#	 e.g. If JBCOBJECTLIST were configured below then the directory /apps/myapp/lib'
      JPROFILE<-1> = '#	 would be used to locate any subroutines called by my main program. In this case'
      JPROFILE<-1> = '#	 the subroutines should of been cataloged with JBC_DEVLIB=/app1/myapp/lib also.'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = 'export JBCOBJECTLIST=$HOME/globuspatchlib:$HOME/globuslib:$HOME/lib'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '#    During the search for a shared object, if an object is specified'
      JPROFILE<-1> = '#    without a path component, e.g. "libsubroutines.so" , then AIX'
      JPROFILE<-1> = '#    will use LIBPATH to find out what directory the object is in,'
      JPROFILE<-1> = '#    and SVR4 systems will use LD_LIBRARY_PATH and HPUX the SHLIB_PATH.'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = 'export LD_LIBRARY_PATH=$JBCRELEASEDIR/lib:/usr/ccs/lib:/usr/lib'     ; * BG_100000497 ; * GLOBUS_BG_100005770 S/E
      JPROFILE<-1> = 'export LIBPATH=$JBCRELEASEDIR/lib:/usr/ccs/lib:/usr/lib'   ; * BG_100000497 ; * GLOBUS_BG_100005770 S/E Removed $LIBPATH
      JPROFILE<-1> = 'export SHLIB_PATH=$JBCRELEASEDIR/lib:${SHLIB_PATH:-/usr/lib:/lib}'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '# Set up path of where to find data files. By default if the JEDIFILEPATH'
      JPROFILE<-1> = '# is not set then files will be looked for first in the $HOME directory and'
      JPROFILE<-1> = '# if not found then in the "." current directory.'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = 'export JEDIFILEPATH=$HOME'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '# Set up the path to the SAVEDLIST file'
      JPROFILE<-1> = '# '
      JPROFILE<-1> = 'export JBCLISTFILE=$HOME/\&SAVEDLISTS\&'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '# Set up base directory where we keep the spooler (default == /usr/jspooler)'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '#export JBCSPOOLERDIR=/usr/jspooler'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '# Set up where the MD and SYSTEM files can be found.'
      JPROFILE<-1> = '# By default, the MD and SYSTEM files are undefined, so Q pointers'
      JPROFILE<-1> = '# and other considerations (such as PQ procs from jsh) will not work.'
      JPROFILE<-1> = 'export JEDIFILENAME_MD=$HOME/VOC'      ; * GLOBUS_BG_100005770 S/E (JEDIFILENAME_MD should point to $HOME/VOC )
      JPROFILE<-1> = 'export JEDIFILENAME_SYSTEM=$JBCRELEASEDIR/src/SYSTEM'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '# Setup the Unix PATH environment variable. This variable specifies the location and '
      JPROFILE<-1> = '# order in which directories will be search to find the command line executable.'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = 'export PATH=/usr/vac/bin:$JBCRELEASEDIR/bin:$PATH:.:/usr/local/bin:$HOME/bin:$HOME/globuspatchbin:$HOME/globusbin:/usr/ccs/bin:/usr/ucb'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '# To see jBASE man pages enable and export the MANPATH environment variable'
      JPROFILE<-1> = '# and set pager to "pg" or "more" as required.'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = 'export MANPATH=$JBCRELEASEDIR/man'
      JPROFILE<-1> = '#export PAGER=pg'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '# Set the environment variable JBCDEV_LIB & JBCDEV_BIN. These'
      JPROFILE<-1> = '# variable will decide the place where the bin and lib directories'
      JPROFILE<-1> = '# will reside in your environment. Any development done in jbase'
      JPROFILE<-1> = '# will be placed into these locations. If the source being compiled'
      JPROFILE<-1> = '# is an executable it will be placed into the bin folder and if it is'
      JPROFILE<-1> = '# a subroutine it will be placed into a shared library in the lib folder'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = 'export JBCDEV_BIN=$HOME/bin'
      JPROFILE<-1> = 'export JBCDEV_LIB=$HOME/lib'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '# Tell jBASE where to create the tmp folder that it uses'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = 'TTYNO=`tty | cut  -f4 -d\/`'           ; * GLOBUS_BG_100000497 S
      JPROFILE<-1> = 'export JBCBASETMP=$HOME/jBASEWORK/tmp_$TTYNO'
      JPROFILE<-1> = 'rm $JBCBASETMP 2>/dev/null'
      JPROFILE<-1> = 'rm $JBCBASETMP]D 2>/dev/null'
      JPROFILE<-1> = 'export LANG=en_US'           ; * GLOBUS_BG_100000497 S/E
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '# This variable sets the jBASE emulation to be prime.'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = 'export JBCEMULATE=prime'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = 'export JBASE_WARNLEVEL=30'   ; * GLOBUS_BG_100005770 S/E ( Warn level should be set to 30 )
      JPROFILE<-1> = 'export JBASE_INHIBIT_ZERO_USED=1'
      JPROFILE<-1> = 'export JEDIENABLEQ2Q=1'
      JPROFILE<-1> = 'export JBASE_MAX_OPEN_FILES=10000'     ; * GLOBUS_BG_100005770 S/E
      JPROFILE<-1> = 'export JBC_UNLOCK_LASTCLOSE=1'         ; * Added for Locking problem
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '# We have now set up all the environment variable requried by jBASE.'
      JPROFILE<-1> = '# We must run the jbcconnect command, so that these variables remain'
      JPROFILE<-1> = '# for the entire session (unless purposely amended).'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '#'                 ; * GLOBUS_BG_100005770 ( Removed JBCCONNECT )
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '# You can now start to add any jBASE programs in your .profile at this stage.'
      JPROFILE<-1> = '# TERM 80,10,,,,132,60'
      JPROFILE<-1> = '# SP-ASSIGN =PRINTRONIX'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '# Now we work out if we want to go straight into GLOBUS or go to jBASE'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '# If you wish to use OFS online via EB.AUTO.INIT.PROCESS, uncomment'
      JPROFILE<-1> = '# the following four lines of script:'
      JPROFILE<-1> = '# First we check if there are any auto processes to run. The program'
      JPROFILE<-1> = '# EB.AUTO.INIT.PROCESS checks the table EB.AUTO.PROCESS for a record'
      JPROFILE<-1> = '# with an id of the user. If this is found (defined in OFS.SOURCE)'
      JPROFILE<-1> = '# the EB.AUTO.INIT.PROCESS will run the routine, an ultimately logout'
      JPROFILE<-1> = '# Where nothing is found, the routine terminates normally.'
      JPROFILE<-1> = '# Hence we examine the $? code. A non zero seems to indicate that the'
      JPROFILE<-1> = '# process DID something, so get out. This will need to be tested'
      JPROFILE<-1> = '# on a site by site basis.'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '#EB.AUTO.INIT.PROCESS'       ; * BG_100000497
      JPROFILE<-1> = '#if [ $? != 0 ]; then'       ; * GLOBUS_BG_100005770 S ( Comment out all lines below till "exec $JBCRELEASEDIR/bin/jsh -s jsh -" )
      JPROFILE<-1> = '#    exit'
      JPROFILE<-1> = '#fi'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '# Now we ask our traditional question.'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '#echo "\nSTART GLOBUS Y/N=\c"'
      JPROFILE<-1> = '#read answer'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '# If we want to start GLOBUS, do so and then exit. This prevents:'
      JPROFILE<-1> = '# a) Too many processes being spawned and'
      JPROFILE<-1> = '# b) Processes being left "hanging"'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '#if [ "$answer" = Y -o "$answer" = y ]; then'
      JPROFILE<-1> = '# start GLOBUS here!'
      JPROFILE<-1> = '#    EBS.TERMINAL.SELECT'
      JPROFILE<-1> = '#    EX'
      JPROFILE<-1> = '#    EX.INTEGRITY'           ; *  EN_10001510 S/E
      JPROFILE<-1> = '#    exit'
      JPROFILE<-1> = '#fi'
      JPROFILE<-1> = '# Otherwise we just start the jshell...'
      JPROFILE<-1> = '#'
      JPROFILE<-1> = '#--------------- End of Profile.Ksh -----------------'
      JPROFILE<-1> = '# Now enter the jsh to complete the login..>'
      JPROFILE<-1> = '#exec $JBCRELEASEDIR/bin/jsh -s jsh -'
      JPROFILE<-1> = 'exec $JBCRELEASEDIR/bin/jpqn $JEDIFILENAME_MD/loginproc'   ; * GLOBUS_BG_100005770 E ( Execute the loginproc Para )
*
      RETURN
*------------------------------------------------------------------------
SHORT.PROFILE:
* Just enough to run a program
*
      JPROFILE<-1> = 'export HOME=$PWD'
      JPROFILE<-1> = 'ENV=${HOME}/.env'
      JPROFILE<-1> = 'export JBCRELEASEDIR=':JBCPATH
      JPROFILE<-1> = 'export JBCGLOBALDIR=':JBCPATH
      JPROFILE<-1> = 'export JBCOBJECTLIST=$HOME/globuspatchlib:$HOME/globuslib:$HOME/lib'
      JPROFILE<-1> = 'export LD_LIBRARY_PATH=$JBCRELEASEDIR/lib:/usr/ccs/lib:/usr/lib'     ; * BG_100000497 ; * GLOBUS_BG_100005770 S
      JPROFILE<-1> = 'export LIBPATH=$JBCRELEASEDIR/lib:/usr/ccs/lib:/usr/lib'   ; * BG_100000497  ; * GLOBUS_BG_100005770 E
      JPROFILE<-1> = 'export SHLIB_PATH=$JBCRELEASEDIR/lib:${SHLIB_PATH:-/usr/lib:/lib}'
      JPROFILE<-1> = 'export JEDIFILEPATH=$HOME'
      JPROFILE<-1> = 'export JEDIFILENAME_MD=VOC'
      JPROFILE<-1> = 'export JEDIFILENAME_SYSTEM=$JBCRELEASEDIR/src/SYSTEM'
      JPROFILE<-1> = 'export PATH=/usr/vac/bin:$JBCRELEASEDIR/bin:$PATH:.:/usr/local/bin:$HOME/bin:$HOME/globuspatchbin:$HOME/globusbin:/usr/ccs/bin:/usr/ucb'
      JPROFILE<-1> = 'export JBCDEV_BIN=$HOME/bin'
      JPROFILE<-1> = 'export JBCDEV_LIB=$HOME/lib'
      JPROFILE<-1> = 'TTYNO=`tty | cut  -f4 -d\/`'           ; * GLOBUS_BG_100000497 S
      JPROFILE<-1> = 'export JBCBASETMP=$HOME/jBASEWORK/tmp_$TTYNO'
      JPROFILE<-1> = 'rm $JBCBASETMP 2>/dev/null'
      JPROFILE<-1> = 'rm $JBCBASETMP]D 2>/dev/null'
      JPROFILE<-1> = 'export LANG=en_US'           ; * GLOBUS_BG_100000497 S/E
      JPROFILE<-1> = 'export JBCEMULATE=prime'
      JPROFILE<-1> = 'export JBBASE_WARNLEVEL=6'
      JPROFILE<-1> = 'export JBASE_INHIBIT_ZERO_USED=1'
      JPROFILE<-1> = 'export JEDIENABLEQ2Q=1'
      JPROFILE<-1> = 'export JBC_UNLOCK_LASTCLOSE=1'         ; * Added for Locking problem
*
      RETURN
*-------------------------------------------------------------------------------------------
   END
