#!/usr/bin/env python3
"""make-readme-images.py: makes every image the READMEs use, from the kit itself.

  python3 scripts/make-readme-images.py              all of it (needs Google Chrome for the PNGs)
  python3 scripts/make-readme-images.py --svg-only   only the pixel badges, divider and heart

Writes:
  docs/img/step-01.svg .. step-05.svg   pixel step badges for "Start here"
  docs/img/divider.svg                  a gold pixel hairline
  docs/img/heart.svg                    a gold pixel heart
  docs/hero.png                         a y2k-blog window, founders-kit.exe, with the front page inside
  docs/triptych.png                     the wallpaper in all three motifs: analog | cyberpunk | y2k-blog
Colours, fonts and words come from examples/style.rocha-coded.json, so the README always matches the kit.
"""
import argparse
import base64
import json
import os
import shutil
import subprocess
import sys
import tempfile
from datetime import date

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, os.path.join(ROOT, "pink-terminal"))
from rocha_style import load_style  # noqa: E402

DIGITS = {  # a 3x5 pixel font, so the badges need no font at all
    "0": ["111", "101", "101", "101", "111"], "1": ["010", "110", "010", "010", "111"],
    "2": ["111", "001", "111", "100", "111"], "3": ["111", "001", "111", "001", "111"],
    "4": ["101", "101", "111", "001", "001"], "5": ["111", "100", "111", "001", "111"]}
HEART = ["0110110", "1111111", "1111111", "0111110", "0011100", "0001000"]
CHROMES = ["/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", "google-chrome", "chromium", "chromium-browser"]


def rects(grid, x0, y0, cell, fill):
    return "".join(f'<rect x="{x0 + c * cell}" y="{y0 + r * cell}" width="{cell}" height="{cell}" fill="{fill}"/>'
                   for r, row in enumerate(grid) for c, v in enumerate(row) if v == "1")


def badges(p, out):
    for n in range(1, 6):
        text = f"{n:02d}"
        body = rects(DIGITS[text[0]], 8, 6, 3, p["paper"]) + rects(DIGITS[text[1]], 22, 6, 3, p["paper"])
        svg = (f'<svg xmlns="http://www.w3.org/2000/svg" width="40" height="27" viewBox="0 0 40 27" shape-rendering="crispEdges">'
               f'<title>step {n}</title><rect width="40" height="27" fill="{p["gold"]}"/>'
               f'<rect x="2" y="2" width="36" height="23" fill="{p["hero"]}"/>{body}</svg>\n')
        with open(os.path.join(out, f"step-{text}.svg"), "w", encoding="utf-8") as fh:
            fh.write(svg)
    with open(os.path.join(out, "divider.svg"), "w", encoding="utf-8") as fh:
        fh.write(f'<svg xmlns="http://www.w3.org/2000/svg" width="600" height="3" viewBox="0 0 600 3" shape-rendering="crispEdges">'
                 f'<title>divider</title><defs><pattern id="d" width="12" height="3" patternUnits="userSpaceOnUse">'
                 f'<rect width="6" height="3" fill="{p["gold"]}"/></pattern></defs><rect width="600" height="3" fill="url(#d)"/></svg>\n')
    with open(os.path.join(out, "heart.svg"), "w", encoding="utf-8") as fh:
        fh.write(f'<svg xmlns="http://www.w3.org/2000/svg" width="21" height="18" viewBox="0 0 21 18" shape-rendering="crispEdges">'
                 f'<title>heart</title>{rects(HEART, 0, 0, 3, p["gold"])}</svg>\n')


def chrome():
    for c in CHROMES:
        path = c if os.path.isabs(c) else shutil.which(c)
        if path and os.path.exists(path):
            return path
    sys.exit("needs Google Chrome to render the PNGs (or run with --svg-only)")


def shoot(browser, html_path, png_path, w, h):
    subprocess.run([browser, "--headless=new", "--disable-gpu", "--hide-scrollbars", f"--window-size={w},{h}",
                    "--virtual-time-budget=9000", f"--screenshot={png_path}", f"file://{html_path}"],
                   check=True, capture_output=True)


FONTS = ("https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,400;0,9..144,900;1,9..144,400"
         "&family=Bricolage+Grotesque:opsz,wght@12..96,400;12..96,800&family=DM+Mono:wght@400;500&family=Silkscreen&display=block")


def hero_html(style, today):
    p, ln = style["palette"], style["lines"]
    heart = base64.b64encode(f'<svg xmlns="http://www.w3.org/2000/svg" width="84" height="84">{rects(HEART, 32, 34, 3, p["accent"])}</svg>'.encode()).decode()
    return f'''<!doctype html><html><head><meta charset="utf-8"><title>founders-kit.exe</title>
<link href="{FONTS}" rel="stylesheet"><style>
:root {{ --ground:{p["hero"]}; --wine:{p["wine"]}; --ink:{p["ink"]}; --cream:{p["paper"]}; --blush:{p["paper_pink"]}; --candy:{p["accent"]}; --gold:{p["gold"]}; }}
* {{ box-sizing:border-box; margin:0; padding:0; }}
html,body {{ width:1600px; height:1000px; background: var(--blush) url("data:image/svg+xml;base64,{heart}"); }}
.win {{ position:absolute; left:40px; top:28px; width:1520px; height:944px; background:var(--cream); border:4px solid var(--ground); box-shadow: 0 22px 44px rgba(20,4,15,.35); }}
.bar {{ height:50px; background:var(--ground); color:var(--cream); font:400 22px 'Silkscreen', monospace; display:flex; align-items:center; justify-content:space-between; padding:0 18px; }}
.btns span {{ display:inline-block; width:26px; height:24px; margin-left:10px; background:var(--gold); border:2px solid var(--ink); }}
.body {{ display:flex; gap:22px; padding:20px; }}
.page {{ flex:1; height:760px; display:flex; flex-direction:column; justify-content:space-between; background:var(--cream); color:var(--ink); padding:22px 34px 26px; border:1px solid rgba(59,18,48,.25);
  background-image: radial-gradient(rgba(59,18,48,.045) 1px, transparent 1px); background-size:5px 5px; }}
.ears {{ display:flex; justify-content:space-between; font:800 14px 'Bricolage Grotesque'; }}
.ears .box {{ border:2px solid var(--ink); padding:3px 9px; }}
h1 {{ font:900 100px/1 'Fraunces', serif; font-variation-settings:"opsz" 144; text-align:center; letter-spacing:-2px; margin:6px 0 4px; }}
.dateline {{ display:flex; justify-content:space-between; border-top:3px solid var(--ink); border-bottom:1px solid var(--ink); padding:6px 2px; font:500 12px 'DM Mono'; letter-spacing:1.5px; text-transform:uppercase; }}
.breaking {{ align-self:flex-start; display:inline-block; background:var(--wine); color:var(--cream); font:800 16px 'Bricolage Grotesque'; padding:5px 13px; margin:14px 0 6px; }}
h2 {{ font:900 66px/0.98 'Fraunces', serif; font-variation-settings:"opsz" 144; letter-spacing:-1px; }}
.deck {{ font:italic 400 22px/1.32 'Fraunces', serif; margin:10px 0 14px; max-width:820px; }}
.cols {{ display:grid; grid-template-columns:repeat(3,1fr); gap:0 24px; border-top:1px solid var(--ink); padding-top:12px; }}
.story {{ border-right:1px solid rgba(59,18,48,.35); padding-right:20px; }} .story:last-child {{ border-right:0; }}
.kick {{ font:800 12px 'Bricolage Grotesque'; color:var(--wine); display:block; margin-bottom:2px; }}
h3 {{ font:900 22px/1.1 'Fraunces', serif; margin-bottom:4px; }} h3 span {{ color:var(--wine); font-style:italic; font-weight:400; }}
.story p {{ font:400 16px/1.42 'Fraunces', serif; margin-bottom:11px; }}
.side {{ width:300px; display:flex; flex-direction:column; gap:16px; }}
.box {{ border:3px solid var(--ground); background:var(--blush); }}
.box b {{ display:block; background:var(--ground); color:var(--cream); font:400 15px 'Silkscreen', monospace; padding:6px 10px; }}
.box div {{ padding:12px; font:800 19px 'Bricolage Grotesque'; color:var(--ink); }}
.count {{ font:500 15px/2 'DM Mono'; color:var(--ink); }}
.count i {{ font-style:normal; background:var(--ink); color:var(--candy); padding:2px 5px; margin:0 1px; }}
.marquee {{ position:absolute; left:0; right:0; bottom:44px; height:40px; background:var(--wine); color:var(--cream); font:500 17px 'DM Mono'; white-space:nowrap; overflow:hidden; line-height:40px; padding-left:16px; }}
.updated {{ position:absolute; left:20px; bottom:12px; font:400 13px 'DM Mono'; color:var(--ink); }}
</style></head><body><div class="win">
<div class="bar"><span>founders-kit.exe</span><span class="btns"><span></span><span></span><span></span></span></div>
<div class="body"><div class="page">
  <div class="ears"><span class="box">rocha coded</span><span>free tools from the rocheverse</span><span class="box">late edition</span></div>
  <h1>{ln["masthead"].title()}</h1>
  <div class="dateline"><span>New York City, {today}</span><span>Thriving in transformational times</span><span>Six pieces, all free</span></div>
  <span class="breaking">breaking news</span>
  <h2>{ln["headline"].replace(" FOUNDER ", " FOUNDER<br>", 1)}</h2>
  <p class="deck">Claude Code, made safe for founders. Six small pieces check what she shipped, keep her voice, verify every claim and ask before anything goes live.</p>
  <div class="cols">
    <div class="story"><span class="kick">morning report</span><h3>Every page she shipped <span>checked before breakfast</span></h3><p>A quiet sweep runs at dawn. It only speaks when something changes.</p>
      <span class="kick">society pages</span><h3>Assistant <span>stops asking twice</span></h3><p>One list, one default each.</p></div>
    <div class="story"><span class="kick">style</span><h3>No copy ships <span>off-voice</span></h3><p>Claude reads her voice file before it writes a word in public.</p>
      <span class="kick">corrections</span><h3>Every claim <span>checked twice</span></h3><p>Interview, draft, humanize, fact-check, verify.</p></div>
    <div class="story"><span class="kick">house rules</span><h3>Nothing ships <span>without her yes</span></h3><p>Security checks before every push.</p>
      <span class="kick">interiors</span><h3>Terminal goes <span>plum and cream</span></h3><p>A pixel leopard in the status line.</p></div>
  </div></div>
  <div class="side">
    <div class="box"><b>about me</b><div>six small pieces for claude code</div></div>
    <div class="box"><b>mood</b><div>✧ {ln["stamp"].lower()}</div></div>
    <div class="box"><b>currently reading</b><div>{ln["masthead"].lower()}</div></div>
    <div class="box"><b>guestbook</b><div>sign my guestbook ✧</div></div>
    <div class="count">you are visitor no. <i>0</i><i>0</i><i>0</i>,<i>7</i><i>7</i><i>7</i></div>
  </div></div>
<div class="marquee">✧ {ln["scrawl"]} ✧ {ln["scrawl"]} ✧ {ln["scrawl"]} ✧ {ln["scrawl"]} ✧ {ln["scrawl"]} ✧</div>
<div class="updated">last updated {today.lower()}</div>
</div></body></html>'''


def triptych(browser, tmp, out_png, today):
    style_path = os.path.join(ROOT, "examples", "style.rocha-coded.json")
    shots = []
    for motif in ("analog", "cyberpunk", "y2k-blog"):
        svg = os.path.join(tmp, f"{motif}.svg")
        subprocess.run([sys.executable, os.path.join(ROOT, "pink-terminal", "make-wallpaper.py"), "--style", style_path,
                        "--motif", motif, "--date", today, "--out", svg], check=True, capture_output=True)
        html = os.path.join(tmp, f"{motif}.html")
        with open(svg, encoding="utf-8") as fh, open(html, "w", encoding="utf-8") as oh:
            oh.write('<!doctype html><meta charset="utf-8"><style>html,body{margin:0}svg{width:100vw;height:100vh;display:block}</style>' + fh.read())
        png = os.path.join(tmp, f"{motif}.png")
        shoot(browser, html, png, 960, 600)
        shots.append((motif, png))
    p = json.load(open(style_path))["palette"]
    cells = "".join(f'<figure><img src="file://{png}"><figcaption>{m}</figcaption></figure>' for m, png in shots)
    page = os.path.join(tmp, "triptych.html")
    with open(page, "w", encoding="utf-8") as fh:
        fh.write(f'''<!doctype html><meta charset="utf-8"><link href="{FONTS}" rel="stylesheet"><style>
html,body {{ margin:0; width:1600px; height:400px; background:{p["hero"]}; }}
body {{ display:flex; gap:28px; padding:34px 40px; box-sizing:border-box; }}
figure {{ margin:0; flex:1; }} img {{ width:100%; display:block; border:3px solid {p["gold"]}; }}
figcaption {{ font:400 18px 'Silkscreen', monospace; color:{p["paper"]}; text-align:center; margin-top:12px; }}
</style>{cells}''')
    shoot(browser, page, out_png, 1600, 400)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--svg-only", action="store_true")
    ap.add_argument("--date", default="", help='printed date, like "27 Oct 2026" (default: today)')
    args = ap.parse_args()
    today = args.date or date.today().strftime("%d %b %Y")
    style, _ = load_style(os.path.join(ROOT, "examples", "style.rocha-coded.json"))
    img = os.path.join(ROOT, "docs", "img")
    os.makedirs(img, exist_ok=True)
    badges(style["palette"], img)
    print("wrote docs/img: step-01..05.svg, divider.svg, heart.svg")
    if args.svg_only:
        return
    browser = chrome()
    with tempfile.TemporaryDirectory() as tmp:
        hero = os.path.join(tmp, "hero.html")
        with open(hero, "w", encoding="utf-8") as fh:
            fh.write(hero_html(style, today))
        shoot(browser, hero, os.path.join(ROOT, "docs", "hero.png"), 1600, 1000)
        triptych(browser, tmp, os.path.join(ROOT, "docs", "triptych.png"), today)
    print("wrote docs/hero.png and docs/triptych.png")


if __name__ == "__main__":
    main()
