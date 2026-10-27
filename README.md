# 包子铺 · 人生模拟（H5）

单文件、零外链、离线可玩的像素风经营模拟。规则与文案为原创重写，致敬 2014 年知乎为推广《金钱有术》做的 H5 软游戏《财务包子铺》（原作站点早已 502、源码未公开）。

## 文件

- `index.html` — 整个游戏，126 KB，CSS/JS/像素图全部内联；除了榜单那一个接口，运行期不碰任何第三方
- `netboard.sql` — 接全网榜时在 Supabase 里跑一次的建表脚本

进度存在浏览器 `localStorage`（键：`bzp.save.v1` 图鉴与局数、`bzp.hof.v1` 百商名册、`bzp.run.v1` 当前这一局、`bzp.diag.v1` 页面加载记录）。默认每个访客各存各的；接上下面的 Supabase 之后，「百商名册」变成所有玩家共用的一张榜。

## 全网榜（共享数据库）

`index.html` 里有一行开关（搜 `const NET=`）：

```js
const NET={api:"",key:"",table:"bzp_hof",timeout:7000};
```

`api` / `key` 留空 → 只用本机名册；填上后端 → 变成全网榜，任何人玩完留名，别人打开就看得到，那些名字还会在牌局里被当成 NPC 提起。**当前发布的版本已经填好，接的是 `ovugayjhtskipghifzup` 这个 Supabase 项目，线上是全网榜状态。**

要换后端或自己重建（免费，约五分钟）：

1. 到 supabase.com 用 GitHub 登录 → New project，起个名字，设个数据库密码，区域随你
2. 左侧 SQL Editor → 新建查询 → 把 `netboard.sql` 整段粘进去 → Run
3. 左侧 Project Settings → API 页，抄下 **Project URL** 和 **anon public key**
4. 改 `index.html`：
   ```js
   const NET={api:"https://<你的项目>.supabase.co/rest/v1",
              key:"<anon public key>",table:"bzp_hof",timeout:7000};
   ```
5. `git commit` + `git push`，Pages 会自动重建，几分钟后生效

清空榜单重来：在 SQL Editor 里跑 `delete from bzp_hof;`（网页上的 anon key 没有删除权限，只能在控制台删）。

行为：进首页和名册页各拉一次（最多 200 行，60 秒内不重复拉），和本机记录合并——同名取最好成绩，按净资产排，前 100 上榜，最早留名的 10 人算元从；留名时只 POST自己那一行，没发出去的下次进首页自动补发。连不上（断网、超时 7 秒）游戏照玩，页面会写明「全网榜没连上，下面显示的是本机记录」。

anon key 是 Supabase 的公开 key，写进前端页面是官方推荐用法；权限已经由 `netboard.sql` 里的 RLS 兜住——只能读、只能追加，且字段长度和数值范围有校验，没有 update / delete 策略，所以拿到源码的人也改不掉别人的成绩。

## 部署

纯静态，任意方式都行，不需要构建：

- **Netlify Drop**：把本目录整个拖到 app.netlify.com/drop
- **GitHub Pages**：建仓后把本目录内容推到 `main`，Settings → Pages → Deploy from branch → `/ (root)`，地址即 `https://<用户名>.github.io/<仓库名>/`
- **Vercel**：`vercel --prod`，framework 选 Other
- **自有服务器 / nginx / OSS / COS**：把 `index.html` 放进站点根目录即可
