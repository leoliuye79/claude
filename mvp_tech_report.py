import markdown
from weasyprint import HTML

md_content = """
# 语言学习 AI App — MVP 技术选型报告

---

## 方案总览

| | 方案 A | 方案 B | 方案 C |
|--|--------|--------|--------|
| **名称** | Vite + React + Capacitor | Expo (React Native) | Flutter (当前) |
| **一句话** | Web 套壳，最快上线 | 原生体验，Expo 降低门槛 | 跨平台编译，已有代码 |
| **定位** | 速度优先 | 体验优先 | 已有投入 |

---

## 1. 开发效率

| 维度 | 方案 A (Capacitor) | 方案 B (Expo) | 方案 C (Flutter) |
|------|-------------------|--------------|-----------------|
| 从零到上架 | **1-2 周** | 3-4 周 | 3-4 周 |
| Claude Code 生成质量 | 最高（HTML/CSS 训练数据最多） | 高 | 中（Dart 语料少） |
| 调试效率 | Chrome DevTools，最快 | Expo Go 扫码预览，快 | 模拟器 hot reload，中等 |
| 出错修复轮次 | 1-2 轮 | 2-3 轮 | 3-5 轮 |
| 学习曲线 | 最低 | 中 | 中高 |

---

## 2. 核心功能适配

| 功能 | 方案 A (Capacitor) | 方案 B (Expo) | 方案 C (Flutter) |
|------|-------------------|--------------|-----------------|
| 聊天 UI | HTML/CSS 随便写，灵活度最高 | FlatList + 自定义组件 | ListView + Widget |
| 语音录入 | Web Speech API / Capacitor 插件 | expo-av，原生体验好 | record 插件，可用 |
| TTS 朗读 | Web Speech API，直接用 | expo-speech，原生级 | flutter_tts，可用 |
| 离线存储 | IndexedDB / SQLite (sql.js) | SQLite (expo-sqlite) | Drift + SQLite |
| 推送通知 | Capacitor 插件，够用 | expo-notifications，成熟 | firebase_messaging |
| 调用 Claude API | fetch，最简单 | fetch，简单 | http 包，简单 |

---

## 3. 产品体验

| 维度 | 方案 A (Capacitor) | 方案 B (Expo) | 方案 C (Flutter) |
|------|-------------------|--------------|-----------------|
| 滚动流畅度 | 90 分（WebView 渲染） | 98 分（原生列表） | 95 分（Skia 渲染） |
| 键盘弹出交互 | 偶尔有 WebView 适配问题 | 原生体验，完美 | 好 |
| 启动速度 | 稍慢（加载 WebView） | 快 | 快 |
| 体积 | 小（5-10MB） | 中（15-25MB） | 大（20-30MB） |
| 用户感知 | "像个网页" | "像原生 App" | "像原生 App" |

---

## 4. 自动化测试 & CI/CD

| 维度 | 方案 A (Capacitor) | 方案 B (Expo) | 方案 C (Flutter) |
|------|-------------------|--------------|-----------------|
| 单元测试 | Vitest，极快 | Jest，快 | flutter test，中等 |
| 自动修正 | ESLint --fix + Prettier | ESLint --fix + Prettier | dart fix（覆盖面窄） |
| CI 构建 | 秒级（Vite 构建） | EAS Build（云端，排队等） | 需装 Flutter SDK |
| 上架流程 | 手动 Xcode / Android Studio | EAS Submit 一键上架 | 手动 |

---

## 5. 长期演进

| 阶段 | 方案 A (Capacitor) | 方案 B (Expo) | 方案 C (Flutter) |
|------|-------------------|--------------|-----------------|
| MVP (0-1000 用户) | **最优** | 好 | 可以 |
| 增长期 (1k-10k) | 够用 | **最优** | 好 |
| 规模期 (10k+) | 可能需要迁移 | 直接扩展 | 直接扩展 |
| 加官网/落地页 | 代码直接复用 | 需另建 Web 项目 | 需另建 Web 项目 |
| 招人难度 | 最容易（前端都会） | 容易（RN 开发者多） | 较难（Flutter 人少） |

---

## 推荐结论

**MVP 阶段推荐方案 A：Vite + React + TypeScript + Capacitor**

核心逻辑：

1. MVP 阶段产品方向可能会变，代码大概率要改甚至重写
2. 花最少时间验证"用户到底要不要这个东西"才是关键
3. 体验差距在聊天类 App 里用户感知不明显
4. 验证成功后迁移到 Expo/RN 的成本远低于一开始就用重方案但产品方向错了的代价

---

## 推荐架构

```
┌─────────────────────────────────┐
│  Vite + React + TypeScript      │  ← 前端
│  + TailwindCSS                  │
│  + Capacitor (iOS/Android 壳)   │
└──────────┬──────────────────────┘
           │ HTTPS
┌──────────▼──────────────────────┐
│  Cloudflare Worker / Vercel     │  ← 轻量后端
│  Edge Function                  │
└──────────┬──────────────────────┘
           │
┌──────────▼──────────────────────┐
│  Claude API                     │  ← AI 能力
└─────────────────────────────────┘
```

---

*报告生成日期：2026-03-14*
"""

html_content = markdown.markdown(md_content, extensions=['tables', 'fenced_code'])

styled_html = f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
  @page {{
    size: A4 landscape;
    margin: 2cm;
  }}
  body {{
    font-family: sans-serif;
    font-size: 11px;
    line-height: 1.6;
    color: #1a1a1a;
  }}
  h1 {{
    font-size: 22px;
    text-align: center;
    color: #1a1a1a;
    border-bottom: 3px solid #2563eb;
    padding-bottom: 10px;
    margin-bottom: 20px;
  }}
  h2 {{
    font-size: 15px;
    color: #2563eb;
    margin-top: 25px;
    margin-bottom: 10px;
  }}
  hr {{
    border: none;
    border-top: 1px solid #e5e7eb;
    margin: 15px 0;
  }}
  table {{
    width: 100%;
    border-collapse: collapse;
    margin: 10px 0;
    font-size: 10px;
  }}
  th {{
    background-color: #2563eb;
    color: white;
    padding: 8px 10px;
    text-align: left;
    font-weight: 600;
  }}
  td {{
    padding: 6px 10px;
    border-bottom: 1px solid #e5e7eb;
  }}
  tr:nth-child(even) {{
    background-color: #f8fafc;
  }}
  strong {{
    color: #2563eb;
  }}
  code {{
    background-color: #f1f5f9;
    padding: 1px 4px;
    border-radius: 3px;
    font-size: 10px;
  }}
  pre {{
    background-color: #1e293b;
    color: #e2e8f0;
    padding: 15px;
    border-radius: 6px;
    font-size: 10px;
    line-height: 1.5;
    white-space: pre-wrap;
  }}
  pre code {{
    background: none;
    color: inherit;
  }}
  ol {{
    padding-left: 20px;
  }}
  li {{
    margin-bottom: 4px;
  }}
</style>
</head>
<body>
{html_content}
</body>
</html>"""

HTML(string=styled_html).write_pdf('/home/user/claude/MVP技术选型报告.pdf')
print("PDF generated successfully!")
