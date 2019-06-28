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

set GYP_GENERATORS=msvs
set GYP_MSVS_OVERRIDE_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community
set GYP_MSVS_VERSION=2017

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
:: is_component_build=false   static lib
call %gn% gen %dispatch_path% --args="is_debug=%debug_mode% rtc_include_tests=false rtc_build_examples=false rtc_enable_protobuf=false rtc_build_tools=false"
if not %errorlevel%==0 (
    echo "generate ninja failed"
    exit 1
)

echo=
echo=
echo ---------------------------------------------------------------
echo ��ʼninja����
echo ---------------------------------------------------------------

:: build
call %ninja% -C %dispatch_path%
if not %errorlevel%==0 (
    echo "ninja build failed"  
    exit 1
)

:: �ָ�����Ŀ¼
cd %old_cd%

echo=
echo=
echo ---------------------------------------------------------------
echo ��ɣ�
echo ---------------------------------------------------------------