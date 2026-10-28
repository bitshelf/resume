# 骆建志 · 嵌入式软件工程师简历

HTML 是简历的唯一维护入口，PDF 由同一份 HTML 经 Chromium 打印生成，正文可选择和复制。网页适配手机，打印采用 A4 单页布局。

## 查看

- [HTML 分支 PDF](https://github.com/bitshelf/resume/releases/download/html-preview/resume.pdf)
- [HTML 分支单文件网页](https://github.com/bitshelf/resume/releases/download/html-preview/resume.html)（下载后可离线打开）
- [main 最新 PDF](https://github.com/bitshelf/resume/releases/download/latest/resume.pdf)

## 编辑和构建

直接打开 `resume.html` 可预览；修改其中的文字和 CSS 即可更新简历。页眉电话沿用原 LaTeX 源码的 `177-8870-5330`，二维码沿用 `assets/qrcode.png`。

需要 Node.js 24 和 pnpm 11.25.0：

```bash
pnpm install --frozen-lockfile
pnpm exec playwright install chromium
pnpm build
```

构建结果位于 `output/html/`：

- `resume.html`：内嵌字体与二维码的单文件 HTML，不依赖网络或其他文件。
- `resume.pdf`：从 HTML 打印生成的 A4 PDF。
- `preview-1.png`：打印布局预览。
- `preview-mobile.png`：手机预览。

可用 `CHROME_PATH` 环境变量指定本机 Chromium/Chrome/Edge 可执行文件，否则使用 Playwright 安装的 Chromium。浏览器手动打印时选择 A4、100% 缩放、无边距、关闭页眉页脚并开启背景图形。

构建会等待字体和图片加载，验证 PDF 恰好一页、手机页面无水平溢出。字体随仓库提供：Source Sans 3 与 Noto Sans SC；后者的授权见 `fonts/NotoSansSC-OFL.txt`。

## GitHub Actions

`main`、`codex/html-resume` 和 `v*` 标签推送时自动构建，PR 只验证。HTML 分支发布到独立的 `html-preview` Release；main 发布到 `latest`。使用 Release 资产分发，不占用 Actions artifact 存储。

原 `resume.tex`、`awesome-cv.cls` 和 `build.sh` 保留供历史参考，HTML 分支的 CI 不再使用 LaTeX。