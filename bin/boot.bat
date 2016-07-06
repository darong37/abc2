@if(0)==(0) ECHO OFF
rem 
rem %~1         - すべての引用句 (") を削除して、%1 を展開します。 
rem %~f1        - %1 を完全修飾パス名に展開します。 
rem %~d1        - %1 をドライブ文字だけに展開します。 
rem %~p1        - %1 をパスだけに展開します。 
rem %~n1        - %1 をファイル名だけに展開します。 
rem %~x1        - %1 をファイル拡張子だけに展開します。 
rem %~s1        - 展開されたパスは、短い名前だけを含みます。 
rem %~a1        - %1 をファイル属性に展開します。 
rem %~t1        - %1 をファイルの日付/時刻に展開します。 
rem %~z1        - %1 をファイルのサイズに展開します。 
rem %~$PATH:1   - PATH 環境変数に指定されているディレクトリを検索し、 
rem                最初に見つかった完全修飾名に %1 を展開します。 
rem                環境変数名が定義されていない場合、または 
rem                検索してもファイルが見つからなかった場合は、 
rem                この修飾子を指定すると空の文字列に展開されます。 

setlocal

rem このバッチが存在するフォルダをカレントに 
pushd %0\.. 

rem 変数定義
set APPLNAM=%~n0
set BASEDIR=%~dp0
set CURRENT=%CD%

set DEFENV=%BASEDIR%..\conf\def.env.txt
FOR /F "usebackq delims== tokens=1,2" %%a IN ("%DEFENV%") DO SET %%a=%%b

echo Mail: %MAILADRESS%

set TODAY=%DATE:/=%
set NOW=%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%

set ShellFolders=HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders 
FOR /F "TOKENS=1,2,*" %%I IN ('REG QUERY "%ShellFolders%" /v "Desktop"') DO IF "%%I"=="Desktop" SET RESULT=%%K 

CALL :Trim %RESULT%

setx "DESKTOP" "%TRIM%"

rem 自分自身をWSH 実行
echo on
cscript.exe //nologo //E:JScript "%~f0" %*
echo off

rem echo ■BATによる後処理です。■



timeout 5
rem pause

endlocal

GOTO :EOF

REM ###########################################################################
REM TRIM処理
REM ###########################################################################
:Trim
SET TRIM=%*
GOTO :EOF

@end

///////////////////////////////////////////////////////////////////////////////
//// Main
///////////////////////////////////////////////////////////////////////////////
var shell = new ActiveXObject("WScript.Shell"); 
var fso = new ActiveXObject( "Scripting.FileSystemObject" ); 

//スクリプト名を含まないフルパスを編集する 
var base = WScript.ScriptFullName; 
var name = WScript.ScriptName; 


base = base.replace(name,""); 
base = base.replace("\\bin\\",""); 
//shell.Popup(base, 0, "BASE", 1); 


//環境変数へアクセスする 
var env = shell.Environment('VOLATILE');  //ログインの環境変数 
//var env = shell.Environment('USER');    //ユーザーの環境変数 


//環境変数の書き込み 
//設定 
env.item("ABC")       = base; 
env.item("ABC_APPS")  = base + "\\apps" ; 
env.item("ABC_BIN")   = base + "\\bin"  ; 
env.item("ABC_CONF")  = base + "\\conf" ; 
env.item("ABC_DAILY") = base + "\\daily"; 
env.item("ABC_EACH")  = base + "\\each" ; 
env.item("ABC_FILES") = base + "\\files"; 

env.item("ABC_LOGS")  = base + "\\files\\logs"; 
env.item("ABC_TEMP")  = base + "\\files\\temp"; 


//機能設定 
env.item("TOOL_DIFF")   = '"C:\Program Files\WinMerge\WinMergeU.exe"' ; 
env.item("TOOL_EDITOR") = '"C:\Program Files\sakura\sakura.exe"' ; 


// TODAY 設定
var date = new Date(); 

y = date.getFullYear(); 
m = date.getMonth() + 1; 
d = date.getDate(); 
m = ('0' + m).slice(-2); 
d = ('0' + d).slice(-2); 

var wkdr = base + "\\daily\\" + y + m + d; 
env.item("ABC_TODAY") = wkdr;


// 作業フォルダ作成 
if ( ! fso.FolderExists(wkdr) ) {
  // 日付フォルダ作成
  fso.CreateFolder(wkdr);
  
  // Prevリンク削除
  var prev  = base + "\\daily\\prev"
  var today = base + '\\daily\\today';

  // Prevリンク削除
  shell.Run( 'cmd /C rmdir     "'+prev +'"'           ,0 );
  WScript.Echo('rmdir     "'+prev +'"');
  WScript.Sleep( 1000 );
  
  shell.Run( 'cmd /C rename    "'+today+'" "'+prev+'"',0 );
  WScript.Echo('rename    "'+today+'" "'+prev+'"');
  WScript.Sleep( 1000 );

  shell.Run( 'cmd /C mklink /D "'+today+'" "'+wkdr+'"',0 );
  WScript.Echo('mklink /D "'+today+'" "'+wkdr+'"');
} else {
  WScript.Echo(wkdr + ' は作成済みです');
}

fso=null;
shell=null;
