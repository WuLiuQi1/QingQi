# 浏览器交互原型

直接用浏览器打开 `index.html`。它不需要服务器、账号或联网资源；这是评审 UI 的方式，不是正式 App 的实现技术。

可体验：
- 四个页面的导航与独立滚动。
- 演示设置 → 等待确认 → 演示启用 → 关闭。
- 规则搜索、详情和无结果状态。
- 演示诊断、本次配置事件与清除。
- 跟随系统 / 浅色 / 深色外观。

所有规则、版本、授权和自检均为示例，不能用于证明真实过滤能力。

`preview.png` 是四个页面的实际浏览器截图总览。单页面 PNG 为同一原型的截图，底部 Tab 固定，超出首屏的内容可以滚动。

## 重跑浏览器检查
需要 Python、Playwright 与可用 Chromium。安装测试依赖后，设置本机 Chromium 可执行文件路径：

```sh
CHROMIUM_PATH=/path/to/chromium python qa_playwright.py
```

脚本会更新截图与 `docs/UI_TEST_RESULTS.json`。这不是 iOS 真机测试。
