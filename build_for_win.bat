@echo off

:: ��ȡ�ű�����·��
set script_path=%~dp0
:: ����ű�����Ŀ¼,��Ϊ���Ӱ��ű���ִ�еĳ���Ĺ���Ŀ¼
set old_cd=%cd%
cd /d %~dp0

:: ������������
set debug_mode="false"

echo=
echo=
echo ---------------------------------------------------------------
echo ���������[debug/release]
echo ---------------------------------------------------------------

:: ���������� /i���Դ�Сд
if /i "%1"=="debug" (
    set debug_mode="true"
    goto param_ok
)
if /i "%1"=="release" (
    set debug_mode="false"
    goto param_ok
)

echo "waring: unkonow build mode -- %1, default debug"
set debug_mode="true"
goto param_ok

:param_ok

:: ��ʾ
if /i %debug_mode% == "true" (
    echo ��ǰ����汾Ϊdebug�汾
) else (
    echo ��ǰ����汾Ϊrelease�汾
)

:: ������������
set depot_tools_path=%script_path%depot_tools
set PATH=%depot_tools_path%;%PATH%

set GYP_GENERATORS=ninja
set GYP_MSVS_VERSION=2017
set DEPOT_TOOLS_WIN_TOOLCHAIN=0

:: ����vcvarsall.bat·��
for /f "tokens=* delims=" %%o in ('call python script/find_vcvarsall_path.py') do (
    set vcvarsall=%%o
)
echo vcvarsall·��=%vcvarsall%
if "%vcvarsall%" == "" (
    echo δ�ҵ�vcvarsall·��    
    goto return
)

:: ע��vc����
set cpu_mode=x86
if /i %cpu_mode% == x86 (
    call "%vcvarsall%" %cpu_mode%
) else (
    call "%vcvarsall%" %cpu_mode%
)

if not %errorlevel%==0 (
    echo "vcvarsall ע��ʧ��"
    goto return
)

:: ����vs·����ͨ��for��call�Ľ�����浽����GYP_MSVS_OVERRIDE_PATH
for /f "tokens=* delims=" %%o in ('call python script/find_vs_path.py') do (
    set GYP_MSVS_OVERRIDE_PATH=%%o
)
echo vs·��=%GYP_MSVS_OVERRIDE_PATH%
if "%GYP_MSVS_OVERRIDE_PATH%" == "" (
    echo δ�ҵ�vs·��    
    goto return
)

:: fix: No supported Visual Studio can be found
set vs2017_install=%GYP_MSVS_OVERRIDE_PATH%

:: �������·��
:: set gn=%script_path%buildtools\win\gn.exe
:: set ninja=%script_path%buildtools\win\ninja.exe
set gn=gn
set ninja=ninja
set dispatch_path=%script_path%out

if /i %debug_mode% == "true" (
    set dispatch_path=%script_path%out\debug
) else (
    set dispatch_path=%script_path%out\release
)

:: ����webrtcĿ¼
cd webrtc\src

echo=
echo=
echo ---------------------------------------------------------------
echo gn����ninja�ű�
echo ---------------------------------------------------------------

:: ninja file
set args=is_debug=%debug_mode%
set args=%args% target_cpu=\"x86\"

:: ����H264����֧��
set args=%args% proprietary_codecs=true

:: m76 not need
::set args=%args% ffmpeg_branding=\"Chrome\"

set args=%args% is_win_fastlink=true
set args=%args% use_lld=false
set args=%args% is_clang=false
set args=%args% use_rtti=false
set args=%args% rtc_build_examples=true
set args=%args% rtc_build_tools=false
set args=%args% rtc_enable_protobuf=false
set args=%args% rtc_include_tests=false

if /i %debug_mode% == "true" (
    set args=%args% enable_iterator_debugging=true
)

call %gn% gen %dispatch_path% --ide=vs2017 --args="%args%"

if not %errorlevel%==0 (
    echo "generate ninja failed"
    goto return
)

echo=
echo=
echo ---------------------------------------------------------------
echo ��ʼninja����
echo ---------------------------------------------------------------

:: build
:: call %ninja% -C %dispatch_path% examples     ����ָ��target��examples
:: Ĭ�ϱ���target��default
call %ninja% -C %dispatch_path%
if not %errorlevel%==0 (
    echo "ninja build failed"  
    goto return
)

echo=
echo=
echo ---------------------------------------------------------------
echo ��ɣ�
echo ---------------------------------------------------------------

:return

:: �ָ�����Ŀ¼
cd %old_cd%