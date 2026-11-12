#!/usr/bin/env python3
"""Capture a journal guidelines / submission portal page with Playwright.

Purpose: journal official guidelines and portal pages are often JS-rendered or
anti-bot protected, so plain HTTP fetch (web_fetch / requests) fails. This helper
drives a real Chromium via Playwright, saves the visible text + HTML snapshot,
and prints the exact ingest command for the medpaper pipeline.

Usage (from the paper workspace venv):
  .venv\\Scripts\\python.exe F:\\deepseek\\工作流\\medpaper-helpers\\capture_guidelines.py ^
      --url "https://www.example.com/instructions-for-authors" ^
      --out "F:\\deepseek\\工作流\\papers\\<slug>\\08_submission\\captures" ^
      --kind guidelines            # or: --kind portal
      [--headed]                   # visible browser; use when captcha/login is expected
      [--wait-for "h1"]            # optional CSS selector to wait for
      [--wait-ms 15000]            # extra settle time after load (default 8000)
      [--manual-minutes 3]         # keep browser open for manual captcha/login (default 0)

Notes:
  - If --headed and --manual-minutes > 0: the page opens visibly, the user may
    solve a captcha / log in manually, then the script re-reads the page and
    saves it. It polls for navigation every 5 s until the timeout.
  - Output: <out>/<timestamp>_<kind>_source.txt (YAML header + visible text),
    <out>/<timestamp>_<kind>.html (raw snapshot), sha256 recorded in the header.
  - The *_source.txt file is then fed to: uv run python tools/wf.py guidelines ingest
    (Gemini engine) — for the paper workspace that command is
    .venv\\Scripts\\python.exe tools\\wf.py guidelines ingest --from <file> --url <url>
"""
from __future__ import annotations

import argparse
import hashlib
import sys
import time
from datetime import datetime, timezone
from pathlib import Path


def main() -> int:
    ap = argparse.ArgumentParser(description="Playwright page capturer for medpaper")
    ap.add_argument("--url", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--kind", default="guidelines", choices=["guidelines", "portal", "indexing"])
    ap.add_argument("--headed", action="store_true")
    ap.add_argument("--wait-for", default=None, help="CSS selector to wait for")
    ap.add_argument("--wait-ms", type=int, default=8000)
    ap.add_argument("--manual-minutes", type=int, default=0,
                    help="keep browser open for manual captcha/login, then re-capture")
    args = ap.parse_args()

    try:
        from playwright.sync_api import sync_playwright
    except ImportError:
        print("playwright is not installed in this venv. Run: "
              ".venv\\Scripts\\python.exe -m playwright install chromium")
        return 2

    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)
    ts = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    base = out_dir / f"{ts}_{args.kind}"

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=not args.headed)
        ctx = browser.new_context(user_agent=(
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
            "(KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"))
        page = ctx.new_page()
        try:
            page.goto(args.url, wait_until="domcontentloaded", timeout=60000)
            if args.wait_for:
                try:
                    page.wait_for_selector(args.wait_for, timeout=20000)
                except Exception:
                    print(f"WARN: selector '{args.wait_for}' not found; continuing")
            time.sleep(args.wait_ms / 1000.0)

            if args.manual_minutes > 0:
                print(f"Browser is VISIBLE. Please solve captcha / log in now. "
                      f"Waiting up to {args.manual_minutes} min, polling for navigation...")
                start = time.time()
                initial = page.url
                deadline = start + args.manual_minutes * 60
                while time.time() < deadline:
                    if page.url != initial:
                        print(f"Navigation detected -> {page.url}")
                        time.sleep(args.wait_ms / 1000.0)
                        break
                    time.sleep(5)
                else:
                    print("No navigation detected; capturing the current page anyway.")

            final_url = page.url
            html = page.content()
            text = page.evaluate("document.body ? document.body.innerText : ''")
        finally:
            browser.close()

    html_path = base.with_suffix(".html")
    html_path.write_text(html, encoding="utf-8")
    text_path = base.with_suffix(".source.txt") if args.kind == "guidelines" else base.with_suffix(".txt")
    sha = hashlib.sha256(text.encode("utf-8")).hexdigest()
    header = (
        f"# captured page\n"
        f"kind: {args.kind}\n"
        f"url: {final_url}\n"
        f"captured_at: {datetime.now(timezone.utc).isoformat()}Z\n"
        f"sha256: {sha}\n"
        f"html_snapshot: {html_path.name}\n"
        f"---\n"
    )
    text_path.write_text(header + text, encoding="utf-8")
    print(f"SAVED: {text_path}")
    print(f"HTML : {html_path}")
    print(f"SHA256: {sha}")
    print(f"FINAL URL: {final_url}")
    print("NEXT (medpaper gemini engine): .venv\\Scripts\\python.exe tools\\journal.py register "
          f"--url {final_url} --file {text_path} --why \"official {args.kind} captured via Playwright; "
          f"sha256 {sha}\" --retrieved-at <actual-retrieval-date>")
    print("ALT (kiro engine): wf guidelines ingest --from <file> --url <url>")
    return 0


if __name__ == "__main__":
    sys.exit(main())
