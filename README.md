# 骆建志 · 嵌入式软件工程师简历

[![Build](https://github.com/bitshelf/resume/actions/workflows/build.yml/badge.svg)](https://github.com/bitshelf/resume/actions/workflows/build.yml)

## 下载

**[简历 PDF（稳定链接，随 main 自动更新）](https://github.com/bitshelf/resume/releases/download/latest/resume.pdf)**

## 预览

![简历预览](https://github.com/bitshelf/resume/releases/download/latest/preview-1.png)

## 方向

- 嵌入式 Linux BSP 移植与外设驱动调试（Rockchip 平台为主）
- Yocto / Buildroot / Debian / Ubuntu / AOSP 系统构建定制
- Linux 内核调试（ftrace、kprobe、eBPF、crash）与底层总线疑难定位（USB3.0、eMMC、PTP1588 等）

## 本地构建

```bash
./build.sh                # Linux + apt：自动检查/安装依赖并编译
# 或手动编译（需要 XeLaTeX）：
xelatex resume.tex && xelatex resume.tex
```

中文使用 TeX Live 自带的 Fandol 字体（`fontset=fandol`），不依赖系统字体，本地与 CI 构建结果一致。

## 仓库结构

```
resume.tex                  # 简历源文件（XeLaTeX + ctex + paracol 双栏）
build.sh                    # 本地构建脚本
.github/workflows/build.yml # CI：编译 PDF、生成预览图、发布 Release
assets/qrcode.png           # 左栏二维码
```
