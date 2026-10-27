# 包子铺 · 人生模拟（H5）

单文件、零外链、离线可玩的像素风经营模拟。规则与文案为原创重写，致敬 2014 年知乎为推广《金钱有术》做的 H5 软游戏《财务包子铺》（原作站点早已 502、源码未公开）。

## 文件

- `index.html` — 整个游戏，122 KB，无任何外部请求（CSS/JS/像素图全部内联）

进度存在浏览器 `localStorage`（键：`bzp.save.v1` 图鉴与局数、`bzp.hof.v1` 百商名册、`bzp.run.v1` 当前这一局、`bzp.diag.v1` 页面加载记录）。因此每个访客各存各的，名册不是全服榜。

## 部署

纯静态，任意方式都行，不需要构建：

- **Netlify Drop**：把本目录整个拖到 app.netlify.com/drop
- **GitHub Pages**：建仓后把本目录内容推到 `main`，Settings → Pages → Deploy from branch → `/ (root)`，地址即 `https://<用户名>.github.io/<仓库名>/`
- **Vercel**：`vercel --prod`，framework 选 Other
- **自有服务器 / nginx / OSS / COS**：把 `index.html` 放进站点根目录即可
