@rem
@rem        This script should create an Oracle Database.
@rem        The values specified are quite minimal, on purpose.
@rem        The Idea is to have a quick database at hand, when needed.
@rem        The created database won't be good enough for a production
@rem        database.
@rem
@rem
@rem        Most probably, this script should be run as administrator
@rem       (cf comment below regarding DIM-00014)
@rem

@     SET   ORACLE_HOME=c:\Oracle\product\11.2.0\dbhome_1
@     SET   ORACLE_SID=ORA_MANUALLY_CREATED
@     SET   DB_NAME=DBMANUAL


@     SET   SYSDBA_PASSWORD=IamSysdba
@     SET   SYSTEM_PASSWORD=IamSystem

@rem  SET   Used in 'create database' statement:
@     SET   CHARACTER_SET=AL32UTF8
@     SET   NATIONAL_CHARACTER_SET=AL16UTF16

@     SET   DB_BLOCK_SIZE=8192

@rem  SET   Where will 'create database' statement go?
@     SET   TEMP_DIR=c:\temp

@rem        Make sure, correct oradim, sqlplus etc will be invoked.
@rem        The variable might already have been set by
@rem        Oracle's installer.
@rem  SET   PATH=%ORACLE_HOME%\bin;%PATH%


@rem 'file root directory'
@rem  ----------------------------------------------------
@rem  
@rem        As we're creating a simple database, we
@rem        specify one single root for the files to
@rem        be created by the database:

@set        DB_FILE_ROOT=c:\tools\Oracle\%DB_NAME%_Files
@rmdir      /q /s %DB_FILE_ROOT% > nul
@mkdir      %DB_FILE_ROOT%


@rem 'Control Files'
@rem  ----------------------------------------------------
@rem  
@rem        We need to decide for control files.
@rem  
@rem        The value of this environement variable will be
@rem        used when the Initialization Parameter Files are
@rem        created.
@rem        Currently, only one control file is used.
@rem  
@     SET   CONTROL_FILES=(%DB_FILE_ROOT%\control_file_01.ctl)


@rem  The 'Initialization Parameter File'
@rem  ----------------------------------------------------

@rem        On Windows, the default directory for the
@rem        Initialization Parameter File is: ORACLE_HOME\database
@rem        The following environment variable will
@rem        point to this location:

@     SET   PFILE_PATH=%ORACLE_HOME%\database
@rem  
@rem        Note: on Unix, the default is ORACLE_HOME/dbs
@rem        ----------------------------------------------------

@rem        On Windows, the default filename for the
@rem        Initialization Parameter File is: initORACLE_SID.ora
@rem        The following environment variable will
@rem        point to this location:

@set        PFILE_NAME=init%ORACLE_SID%.ora


@rem        Full Name (path and name) of Initialization Parameter File:

@     SET   PFILE=%PFILE_PATH%\%PFILE_NAME%


@rem        oh, oh, dangerous: %PFILE_PATH% might contain
@rem        other important pfiles   
@     REM   rmdir /s %PFILE_PATH% 2> nul
@     REM   mkdir %PFILE_PATH%

@rem        Creating the 'Initialization Parameter File'
@rem        ----------------------------------------------------


@echo       DB_NAME=%DB_NAME%>               %PFILE%
@echo       DB_BLOCK_SIZE=%DB_BLOCK_SIZE%>>  %PFILE%
@echo       CONTROL_FILES=%CONTROL_FILES%>>  %PFILE%
@echo       UNDO_TABLESPACE=UNDO_TS>>        %PFILE%
@rem
@rem
@rem        local_listener='(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521))' >> %PFILE%



@rem
@rem  Create the Oracle Instance.
@rem  ----------------------------------------------------
@rem       
@rem        In Windows, the instance is implemented
@rem        as a service.

@           oradim -NEW -SID %ORACLE_SID% -STARTMODE MANUAL

@rem        Note:
@rem        If the command throws a 'DIM-00014' error message, the
@rem        command should be run as administrator


@rem        ----------------------------------------------------
@rem        The 'Password File'
@rem
@rem        The Password File is needed so as to be able
@rem        to connect "as sysdba" (see later.)

@rem        On Windows, the default directory for the
@rem        Password File is: ORACLE_HOME\database (as is for the 
@rem        Initialization Parameter File).
@rem        The following environment variable will
@rem        point to this location:

@     SET   PWD_PATH=%ORACLE_HOME%\database

@rem        Note: on Unix, the default is ORACLE_HOME/dbs
@rem        ----------------------------------------------------

@rem       On Windows, the default filename for the
@rem       Password File is: pwdORACLE_SID.ora
@rem      (ORACLE_SID should have been set in 001.sid.bat)
@rem       The following environment variable will
@rem       point to this location:

@     SET  PWD_NAME=pwd%ORACLE_SID%.ora

@rem       -----------------------------------
@rem       Full Name (path and name) of Password File
@rem
@     SET  PWDFILE=%PWD_PATH%\%PWD_NAME%

@     DEL  %PWDFILE% 2> nul

@rem       Create password file using 'orapwd':
@          orapwd file=%PWDFILE% password=%SYSDBA_PASSWORD%


@rem       Create the 'SQL Script' that will create the database
@rem       ----------------------------------------------------


@set       SCRIPT=%TEMP_DIR%\create_db_script.sql

@echo   startup nomount > %SCRIPT%
@REM    ---------------------------------------------------
@echo   CREATE DATABASE %DB_NAME% >> %SCRIPT%
@echo      USER SYS IDENTIFIED BY %SYSDBA_PASSWORD% >> %SCRIPT%
@echo      USER SYSTEM IDENTIFIED BY %SYSTEM_PASSWORD% >> %SCRIPT%
@echo      LOGFILE GROUP 1 ('%DB_FILE_ROOT%\redo01a.log','%DB_FILE_ROOT%\redo01b.log') SIZE 100M BLOCKSIZE 512, >> %SCRIPT%
@echo              GROUP 2 ('%DB_FILE_ROOT%\redo02a.log','%DB_FILE_ROOT%\redo02b.log') SIZE 100M BLOCKSIZE 512 >> %SCRIPT%

@rem       currently, only two log file group. At least two are required to prevent
@rem          ORA-01518: CREATE DATABASE must specify more than one log file
@rem       Make sure to have the commas right when uncommenting the following line:
@rem
@rem @echo              GROUP 3 ('%DB_FILE_ROOT%\redo03a.log','%DB_FILE_ROOT%\redo03b.log') SIZE 100M BLOCKSIZE 512  >> %SCRIPT%

@echo      -- MAXLOGFILES 5 >> %SCRIPT%
@echo      MAXLOGMEMBERS 5 >> %SCRIPT%
@echo      MAXLOGHISTORY 1 >> %SCRIPT%
@echo      MAXDATAFILES 100 >> %SCRIPT%
@echo      CHARACTER SET %CHARACTER_SET%  >> %SCRIPT%
@echo      NATIONAL CHARACTER SET %NATIONAL_CHARACTER_SET%  >> %SCRIPT%
@REM       ---------------------------------------------------
@echo      EXTENT MANAGEMENT LOCAL >> %SCRIPT%
@echo      DATAFILE '%DB_FILE_ROOT%\system01.dbf' SIZE 325M REUSE >> %SCRIPT%
@echo      SYSAUX DATAFILE '%DB_FILE_ROOT%\sysaux01.dbf' SIZE 325M REUSE >> %SCRIPT%
@REM       ---------------------------------------------------
@echo      DEFAULT TABLESPACE users >> %SCRIPT%
@echo         DATAFILE '%DB_FILE_ROOT%\users01.dbf' >> %SCRIPT%
@echo         SIZE 500M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED >> %SCRIPT%
@REM       ---------------------------------------------------
@echo      DEFAULT TEMPORARY TABLESPACE temp_ts >> %SCRIPT%
@echo         TEMPFILE '%DB_FILE_ROOT%\temp01.dbf' >> %SCRIPT%
@echo         SIZE 20M REUSE >> %SCRIPT%
@REM       ---------------------------------------------------
@REM       -- TODO: NOte UNDO_TS also specified in Initialization Paramter File!
@echo      UNDO TABLESPACE undo_ts >> %SCRIPT%
@echo         DATAFILE '%DB_FILE_ROOT%\undo01.dbf' >> %SCRIPT%
@echo         SIZE 200M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED; >> %SCRIPT%
@REM    ---------------------------------------------------
@echo   exit >> %SCRIPT%


@       sqlplus sys/%SYSDBA_PASSWORD% as sysdba @%SCRIPT%

@       sqlplus sys/%SYSDBA_PASSWORD% as sysdba @build_data_dictionary.sql

@       sqlplus system/%SYSTEM_PASSWORD% @install_product_user_profile.sql

@rem    -------------------------------------------
@rem    Create listener service

@       sc create OracleOraDb11g_home1TNSListener binPath= %ORACLE_HOME%\bin\tnslsnr.exe start= demand

@rem    The listener service can be deleted with
@rem        sc delete OracleOraDb11g_home1TNSListener
@rem
@rem    The service can be started with
@rem        net start OracleOraDb11g_home1TNSListener
@rem    and stopped with
@rem        net stop OracleOraDb11g_home1TNSListener

@rem    --------------------------------------------
@rem    Create tnsadmin.ora file

@echo %DB_NAME%= >> %ORACLE_HOME%\NETWORK\ADMIN\tnsnames.ora
@echo    (DESCRIPTION= >> %ORACLE_HOME%\NETWORK\ADMIN\tnsnames.ora
@echo      (ADDRESS= >> %ORACLE_HOME%\NETWORK\ADMIN\tnsnames.ora
@echo         (PROTOCOL=tcp) >> %ORACLE_HOME%\NETWORK\ADMIN\tnsnames.ora
@echo         (HOST=localhost) >> %ORACLE_HOME%\NETWORK\ADMIN\tnsnames.ora
@echo         (PORT=1521) >> %ORACLE_HOME%\NETWORK\ADMIN\tnsnames.ora
@echo      ) >> %ORACLE_HOME%\NETWORK\ADMIN\tnsnames.ora
@echo      (CONNECT_DATA= >> %ORACLE_HOME%\NETWORK\ADMIN\tnsnames.ora
@echo         (SID=%ORACLE_SID%) >> %ORACLE_HOME%\NETWORK\ADMIN\tnsnames.ora
@echo         (GLOBAL_NAME=%DB_NAME%) >> %ORACLE_HOME%\NETWORK\ADMIN\tnsnames.ora
@echo      ) >> %ORACLE_HOME%\NETWORK\ADMIN\tnsnames.ora
@echo   ) >> %ORACLE_HOME%\NETWORK\ADMIN\tnsnames.ora

@rem    --------------------------------------------
@rem    Create listener.ora file

@echo   listener=(ADDRESS=(PROTOCOL=tcp)(HOST=localhost)(PORT=1521)) >> %ORACLE_HOME%\NETWORK\ADMIN\listener.ora
