@echo off

:: ��ȡ�ű�����·��
set script_path=%~dp0
:: ����ű�����Ŀ¼,��Ϊ���Ӱ��ű���ִ�еĳ���Ĺ���Ŀ¼
set old_cd=%cd%
cd /d %~dp0

echo=
echo ---------------------------------------------------------------
echo ���depot_tools
echo ---------------------------------------------------------------
set depot_tools_path=%script_path%depot_tools
if exist %depot_tools_path% (
    echo %depot_tools_path% �Ѵ���
) else (
    echo %depot_tools_path% �����ڣ�����depot_tools
    call git clone --depth=1 https://chromium.googlesource.com/chromium/tools/depot_tools.git
)
:: if�Ӿ��ERRORLEVEL�ò�����ȷ��ֵ������git clone����õ������ж�
if not %ERRORLEVEL% == 0 (
    echo depot_tools����ʧ��
    goto return
)

:: ������������
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

:: ����gclient sync��Ҫ�⼸����������
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

echo=
echo ---------------------------------------------------------------
echo ��ʼ��depot_tools
echo ---------------------------------------------------------------
call gclient

if not %ERRORLEVEL% == 0 (
    echo ��ʼ��depot_toolsʧ��
    goto return
)

echo=
echo ---------------------------------------------------------------
echo ͬ��webrtc����
echo ---------------------------------------------------------------
set webrtc_path=%script_path%webrtc
set webrtc_src_path=%webrtc_path%/src
if not exist %webrtc_path% (
    md %webrtc_path%
)
cd %webrtc_path%
if not exist %webrtc_src_path% (
    call fetch --nohooks webrtc
)
call gclient sync --force

if not %ERRORLEVEL% == 0 (
    echo webrtcͬ��ʧ��
    goto return
)

cd %webrtc_src_path%
:: webrtc����release https://webrtc.org/release-notes/
:: ���ڵ�ǰ����release��֧m76������
:: m76 === depot_tools 61d3d4b0bd55ee9027a831d27210ddfcbb9531a7
call git checkout -b branch-heads/m76 refs/remotes/branch-heads/m76
:: call git pull
:: �л���֧�Ժ����sync����ͬ����ͬ��֧��build tools
:: �����ټ�--nohooks�����򲻻�����webrtc\src\buildtools\win\gn.exe�ȱ��빤��
call gclient sync

if not %ERRORLEVEL% == 0 (
    echo webrtcͬ��ʧ��
    goto return
)

echo=
echo ---------------------------------------------------------------
echo ����webrtc
echo ---------------------------------------------------------------

call python %script_path%script/custom_webrtc.py
if not %ERRORLEVEL% == 0 (
    echo ����webrtcʧ��
    goto return
)

echo allͬ���ɹ�

:return
:: �ָ�����Ŀ¼
cd %old_cd%