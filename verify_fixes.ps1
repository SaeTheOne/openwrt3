Write-Host "========== 验证修复脚本 ==========" -ForegroundColor Cyan

# 检查diy-part1.sh中的视频feeds移除代码
Write-Host "`n1. 检查diy-part1.sh中的视频feeds移除代码:" -ForegroundColor Green
$diyContent = Get-Content -Path ".\diy-part1.sh" -Raw
if ($diyContent -match "feeds/video") {
    Write-Host "✅ 成功: diy-part1.sh包含视频feeds移除代码"
    # 显示相关代码片段
    $diyContent -split "`n" | Where-Object { $_ -match "video" -or $_ -match "feeds.conf.default" } | ForEach-Object { 
        Write-Host "   $_"
    }
} else {
    Write-Host "❌ 失败: diy-part1.sh中未找到视频feeds移除代码"
}

# 检查workflow中的视频feeds移除步骤
Write-Host "`n2. 检查workflow中的视频feeds移除步骤:" -ForegroundColor Green
$workflowPath = ".\.github\workflows\openwrt-builder.yml"
if (Test-Path $workflowPath) {
    $workflowContent = Get-Content -Path $workflowPath -Raw
    if ($workflowContent -match "remove.*video.*feeds") {
        Write-Host "✅ 成功: workflow文件包含视频feeds移除步骤"
        # 计算视频feeds移除步骤的数量
        $removeCount = ($workflowContent | Select-String -Pattern "rm -rf feeds/video" -AllMatches).Matches.Count
        Write-Host "   发现 $removeCount 个视频feeds移除命令"
    } else {
        Write-Host "❌ 失败: workflow文件中未找到视频feeds移除步骤"
    }
} else {
    Write-Host "❌ 失败: 找不到workflow文件"
}

# 检查错误诊断增强
Write-Host "`n3. 检查编译错误诊断增强:" -ForegroundColor Green
if ($workflowContent -match "增强版错误诊断" -and $workflowContent -match "ERROR_LOG") {
    Write-Host "✅ 成功: workflow包含增强版错误诊断功能"
    # 检查是否包含关键的诊断命令
    if (($workflowContent -match "grep -i error") -and ($workflowContent -match "grep -i video")) {
        Write-Host "   增强版错误诊断包含所有必要的检查命令"
    }
} else {
    Write-Host "❌ 失败: workflow中未找到增强版错误诊断功能"
}

# 检查additional_configs.txt是否简化
Write-Host "`n4. 检查additional_configs.txt是否简化:" -ForegroundColor Green
if (Test-Path ".\additional_configs.txt") {
    $configContent = Get-Content -Path ".\additional_configs.txt" -Raw
    if ($configContent -notmatch "video" -and $configContent -notmatch "xkeyboard") {
        Write-Host "✅ 成功: additional_configs.txt已简化，不包含视频相关配置"
        # 显示配置文件中的主要部分
        Write-Host "   配置文件前10行:" -ForegroundColor Yellow
        Get-Content -Path ".\additional_configs.txt" -TotalCount 10 | ForEach-Object { 
            Write-Host "   $_"
        }
    } else {
        Write-Host "❌ 失败: additional_configs.txt可能包含视频相关配置"
    }
} else {
    Write-Host "❌ 失败: 找不到additional_configs.txt文件"
}

# 检查feeds验证步骤
Write-Host "`n5. 检查feeds验证步骤:" -ForegroundColor Green
if ($workflowContent -match "验证feeds配置" -and $workflowContent -match "verify_feeds") {
    Write-Host "✅ 成功: workflow包含feeds验证步骤"
} else {
    Write-Host "❌ 失败: workflow中未找到feeds验证步骤"
}

Write-Host "`n========== 验证完成 ==========" -ForegroundColor Cyan