from pathlib import Path
from playwright.sync_api import sync_playwright
import json
import os

root = Path(__file__).resolve().parents[1]
ui = root / "UI"
errors = []
external_requests = []
checks = []
with sync_playwright() as p:
    browser = p.chromium.launch(executable_path=os.environ.get("CHROMIUM_PATH", "/usr/bin/chromium"), headless=True, args=["--no-sandbox"])
    page = browser.new_page(viewport={"width": 1200, "height": 960}, device_scale_factor=1)
    page.on("pageerror", lambda err: errors.append(str(err)))
    page.on("request", lambda req: external_requests.append(req.url) if req.url.startswith(("https://", "http://")) else None)
    page.set_content((ui/"index.html").read_text(encoding="utf-8"), wait_until="load")
    page.wait_for_timeout(200)
    assert page.locator(".demo-banner").inner_text().startswith("交互演示")
    checks.append("Persistent demo disclosure")
    page.locator("[data-action=main]").click()
    assert page.locator("#dialog").is_visible()
    assert "不会弹出真实系统授权" in page.locator("#dialog").inner_text()
    page.locator("[data-action=prepare]").click()
    assert "等待系统确认" in page.locator(".hero h2").inner_text()
    page.locator("[data-action=main]").click()
    assert "配置已启用" in page.locator(".hero h2").inner_text()
    page.locator("[data-action=main]").click()
    assert "过滤已关闭" in page.locator(".hero h2").inner_text()
    checks.append("Demo setup -> waiting -> enabled -> disabled")

    page.locator(".tabbar [data-page=rules]").click()
    assert page.locator(".rule-card").count() == 3
    page.locator("#ruleSearch").fill("ads.example")
    assert page.locator(".rule-card").count() == 1
    page.locator(".rule-card").click()
    assert "未测试" in page.locator("#dialog").inner_text()
    page.locator("[data-action=close]").click()
    page.locator("#ruleSearch").fill("no-match")
    assert page.locator(".empty").is_visible()
    checks.append("Rule search, details and empty state")

    page.locator(".tabbar [data-page=diagnostics]").click()
    page.locator("[data-action=check]").click()
    assert "以下均为演示" in page.locator("#page").inner_text()
    assert "未发送真实网络请求" in page.locator("#page").inner_text()
    checks.append("Diagnostic output remains explicitly simulated")

    page.locator(".tabbar [data-page=settings]").click()
    page.locator("[data-theme-choice=dark]").click()
    assert page.locator("#device").get_attribute("data-theme") == "dark"
    page.locator("[data-action=clear]").click()
    assert "已清除演示事件" in page.locator("#dialog").inner_text()
    page.locator("[data-action=close]").click()
    checks.append("Appearance and event clearing")

    # Reset the prototype and capture four design states.
    page.goto("about:blank")
    page.set_content((ui/"index.html").read_text(encoding="utf-8"), wait_until="load")
    page.wait_for_timeout(100)
    page.locator("#device").screenshot(path=str(ui/"01_overview.png"))
    page.locator(".tabbar [data-page=rules]").click()
    page.locator("#device").screenshot(path=str(ui/"02_rules.png"))
    page.locator(".tabbar [data-page=diagnostics]").click()
    page.locator("#device").screenshot(path=str(ui/"03_diagnostics.png"))
    page.locator(".tabbar [data-page=settings]").click()
    page.locator("[data-theme-choice=dark]").click()
    page.locator("#device").screenshot(path=str(ui/"04_settings_dark.png"))

    # Verify the phone layout fits narrow browsers and each tab remains reachable.
    page.set_viewport_size({"width": 375, "height": 812})
    for name in ["overview", "rules", "diagnostics", "settings"]:
        page.locator(f".tabbar [data-page={name}]").click()
        assert page.evaluate("document.documentElement.scrollWidth <= innerWidth")
        assert page.locator(f".tabbar [data-page={name}]").is_visible()
    checks.append("375px responsive layout and four reachable tabs")
    page.screenshot(path=str(ui/"mobile_settings.png"))

    # Basic keyboard access, without claiming full accessibility certification.
    page.keyboard.press("Tab")
    checks.append("Keyboard focus path exercised")
    browser.close()

report = {
    "checks_passed": checks,
    "javascript_errors": errors,
    "external_http_requests": external_requests,
    "scope": "Browser prototype only; no iOS filtering or Apple SDK runtime tests"
}
assert not errors, errors
assert not external_requests, external_requests
(root/"docs/UI_TEST_RESULTS.json").write_text(json.dumps(report, ensure_ascii=False, indent=2)+"\n", encoding="utf-8")
print(json.dumps(report, ensure_ascii=False, indent=2))
