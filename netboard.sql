-- 包子铺 · 人生模拟 —— 全网百商榜
-- 用法：Supabase 控制台 → SQL Editor → 粘贴整段 → Run
-- 跑完之后，把 index.html 里的 NET={api:"",key:""} 填上项目地址和 anon key 即可。

-- 1) 建表。append-only：没有主键冲突，玩家重复留名会多出一行，
--    客户端合并时按名字取最好成绩，所以不需要 update 权限。
create table if not exists public.bzp_hof (
  id   bigserial primary key,
  nm   text   not null,           -- 名号（≤8 字）
  net  bigint not null,           -- 净资产（元）
  e    text   not null,           -- 结局代号
  f    text   not null,           -- 业态
  d    int    not null,           -- 收摊在第几天
  ts   bigint not null            -- 客户端时间戳（毫秒）
);
create index if not exists bzp_hof_net_idx on public.bzp_hof (net desc);

-- 2) 打开行级安全。没写 select/insert 策略 = 匿名 key 什么都干不了。
alter table public.bzp_hof enable row level security;

-- 3) 所有人可读（这是全服榜的意义）。
drop policy if exists "bzp_hof_read" on public.bzp_hof;
create policy "bzp_hof_read" on public.bzp_hof
  for select to anon, authenticated using (true);

-- 4) 任何人可插入一条，但字段必须过校验；无 update / delete 策略，
--    所以拿到页面源码的人也改不动、删不掉别人的成绩。
drop policy if exists "bzp_hof_append" on public.bzp_hof;
create policy "bzp_hof_append" on public.bzp_hof
  for insert to anon, authenticated with check (
    char_length(nm) between 1 and 8
    and net >= 0 and net <= 1000000000000
    and char_length(e) <= 24
    and char_length(f) <= 24
    and d between 0 and 30
    and ts > 0
  );

-- 5) 让 PostgREST 认这张表（Supabase 默认已暴露 public schema；
--    如果是自建 PostgREST 才需要这句）。
notify pgrst, 'reload schema';

-- 自检：手工插一条，再查出来，然后删掉测试行
insert into public.bzp_hof (nm,net,e,f,d,ts)
  values ('测试甲', 100000, 'E_RELATIVE', '包子铺', 12, 1793000000000);
select * from public.bzp_hof order by net desc limit 5;
delete from public.bzp_hof where nm = '测试甲';
