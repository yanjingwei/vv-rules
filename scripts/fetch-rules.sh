#!/usr/bin/env bash
# Fetch upstream Clash/mihomo rule lists into rules/.
# Individual failures are non-fatal (existing file is kept); the job only fails
# if EVERY fetch fails (i.e. a total network outage), so partial refreshes still commit.
set -uo pipefail
cd "$(dirname "$0")/.."
mkdir -p rules

total=0
fail=0
fetch() { # <url> <dest-filename>
  local url="$1" dest="rules/$2" tmp
  total=$((total + 1))
  tmp="$(mktemp)"
  if curl -fsSL --retry 3 --retry-delay 2 --max-time 90 "$url" -o "$tmp" && [ -s "$tmp" ]; then
    mv "$tmp" "$dest"
    echo "OK    $2 ($(wc -l < "$dest" | tr -d ' ') lines)"
  else
    rm -f "$tmp"
    echo "FAIL  $2  <-  $url" >&2
    fail=$((fail + 1))
  fi
}

# Loyalsoldier clash-rules (@release) — domain / ipcidr lists (yaml-format payload)
LS="https://raw.githubusercontent.com/Loyalsoldier/clash-rules/release"
for f in reject private direct proxy gfw tld-not-cn applications google cncidr lancidr telegramcidr; do
  fetch "$LS/$f.txt" "$f.txt"
done

# SukkaLab — AI non-ip classical list
fetch "https://raw.githubusercontent.com/SukkaLab/ruleset.skk.moe/master/Clash/non_ip/ai.txt" "skk-ai.txt"

# blackmatrix7 — classical yaml rulesets
BM="https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash"
fetch "$BM/OpenAI/OpenAI.yaml"         "openai.yaml"
fetch "$BM/Anthropic/Anthropic.yaml"   "anthropic.yaml"
fetch "$BM/Claude/Claude.yaml"         "claude.yaml"
fetch "$BM/Tencent/Tencent.yaml"       "tencent.yaml"
fetch "$BM/ByteDance/ByteDance.yaml"   "bytedance.yaml"
fetch "$BM/XiaoHongShu/XiaoHongShu.yaml" "xiaohongshu.yaml"

echo "----"
echo "fetched $((total - fail))/$total  (failures: $fail)"
# Fail the job only on a total outage so a single flaky upstream doesn't block refresh.
[ "$fail" -lt "$total" ]
