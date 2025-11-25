#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# 确保feeds.conf.default存在并移除视频相关feeds
if [ -f "feeds.conf.default" ]; then
    # 移除可能包含video的feeds行
    sed -i '/video/d' feeds.conf.default
    # 确保保留核心feeds但排除video相关内容
    echo "配置feeds.conf.default文件，排除视频相关feeds"
else
    echo "警告：feeds.conf.default不存在，将在后续步骤中处理视频feeds移除"
fi

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
#echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> "feeds.conf.default"

# echo "src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main" >> "feeds.conf.default"
# echo "src-git momo https://github.com/nikkinikki-org/OpenWrt-momo.git;main" >> "feeds.conf.default"
# echo 'src-git istore https://github.com/linkease/istore;main' >> feeds.conf.default

# 在更新feeds之前确保视频相关目录被删除
if [ -d "feeds/video" ]; then
    echo "删除已存在的视频feeds目录"
    rm -rf feeds/video
fi
