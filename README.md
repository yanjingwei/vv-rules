# vv-rules

自建 Clash / mihomo 规则集，供 Marzban 订阅的 `rule-provider` 使用，替代客户端直连 `cdn.jsdelivr.net`（国内更快更稳、移动端更省内存）。

## 结构
- `rules/` — 规则文件。`.txt` 为 Loyalsoldier 的 domain/ipcidr 列表（yaml-format payload），`.yaml` 为 blackmatrix7 / SukkaLab 的 classical 列表。
- `rules/domestic-*.yaml` — **自建**（非上游），CI 不覆盖。
- `scripts/fetch-rules.sh` — 从上游抓取全部 18 个上游列表到 `rules/`。
- `.github/workflows/refresh-rules.yml` — 每日定时（含手动触发）跑抓取脚本并提交。

## 上游来源
- `Loyalsoldier/clash-rules@release`：reject / private / direct / proxy / gfw / tld-not-cn / applications / google / cncidr / lancidr / telegramcidr
- `SukkaLab/ruleset.skk.moe@master`：Clash/non_ip/ai → `skk-ai.txt`
- `blackmatrix7/ios_rule_script@master`：OpenAI / Anthropic / Claude / Tencent / ByteDance / XiaoHongShu

## 部署（NAS 定时 git pull）
NAS 用只读部署密钥定时 `git pull` 本仓库；`rules/` 目录 bind-mount 进 Marzban 容器的 `…/dashboard/build/statics/rules/`，由 nginx 下发。客户端订阅里 provider 指向 `https://cloud.weiwu.io:2083/statics/rules/<file>`。

## 首次填充
push 本仓库后，到 Actions 手动运行一次 `refresh-rules`（workflow_dispatch），即可把全部上游规则抓取并提交。
