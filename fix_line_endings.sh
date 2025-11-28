#!/bin/bash

# 修复行尾字符问题
echo "🔧 修复脚本行尾字符问题..."
sed -i "s/\r$//" diy-part2.sh
sed -i "s/\r$//" fix_dependencies.sh 2>/dev/null || true
echo "✅ 行尾字符修复完成"
