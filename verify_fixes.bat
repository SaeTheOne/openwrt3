@echo off
setlocal enabledelayedexpansion

echo ========== 验证修复脚本 ==========
echo.

:: 检查diy-part1.sh中的视频feeds移除代码
echo 1. 检查diy-part1.sh中的视频feeds移除代码:
findstr /i "video feeds.conf.default" diy-part1.sh
if %errorlevel% equ 0 (
    echo [✓] 成功: diy-part1.sh包含视频feeds移除代码
) else (
    echo [✗] 失败: diy-part1.sh中未找到视频feeds移除代码
)
echo.

:: 检查workflow中的视频feeds移除步骤
echo 2. 检查workflow中的视频feeds移除步骤:
if exist ".github\workflows\openwrt-builder.yml" (
    findstr /i "rm -rf feeds/video" ".github\workflows\openwrt-builder.yml"
    if %errorlevel% equ 0 (
        echo [✓] 成功: workflow文件包含视频feeds移除步骤
        for /f %%a in ('findstr /i "rm -rf feeds/video" ".github\workflows\openwrt-builder.yml" ^| find /c "/"') do (
            echo    发现 %%a 个视频feeds移除命令
        )
    ) else (
        echo [✗] 失败: workflow文件中未找到视频feeds移除步骤
    )
) else (
    echo [✗] 失败: 找不到workflow文件
)
echo.

:: 检查错误诊断增强
echo 3. 检查编译错误诊断增强:
if exist ".github\workflows\openwrt-builder.yml" (
    findstr /i "ERROR_LOG grep" ".github\workflows\openwrt-builder.yml"
    if %errorlevel% equ 0 (
        echo [✓] 成功: workflow包含增强版错误诊断功能
    ) else (
        echo [✗] 失败: workflow中未找到增强版错误诊断功能
    )
)
echo.

:: 检查additional_configs.txt是否简化
echo 4. 检查additional_configs.txt是否简化:
if exist "additional_configs.txt" (
    echo 配置文件前10行:
    head -n 10 additional_configs.txt 2>nul || (
        echo 使用type命令显示前10行:
        for /l %%i in (1,1,10) do (
            set /p line=<additional_configs.txt
            if defined line echo !line!
        )
    )
    echo [✓] 验证: additional_configs.txt存在
) else (
    echo [✗] 失败: 找不到additional_configs.txt文件
)
echo.

:: 检查feeds验证步骤
echo 5. 检查feeds验证步骤:
if exist ".github\workflows\openwrt-builder.yml" (
    findstr /i "verify_feeds" ".github\workflows\openwrt-builder.yml"
    if %errorlevel% equ 0 (
        echo [✓] 成功: workflow包含feeds验证步骤
    ) else (
        echo [✗] 失败: workflow中未找到feeds验证步骤
    )
)
echo.

echo ========== 验证完成 ==========
pause