-- =========================================================
-- NOVUS LHK Campus Platform - Supabase Full Schema (Reset)
-- 适用场景：全新环境/允许清空历史数据
-- 警告：会 DROP 现有业务表，请先确认是否需要保留数据
-- =========================================================

BEGIN;

-- 1) 清理旧表（按依赖逆序）
DROP TABLE IF EXISTS registrations CASCADE;
DROP TABLE IF EXISTS announcements CASCADE;
DROP TABLE IF EXISTS activities CASCADE;
DROP TABLE IF EXISTS welfares CASCADE;
DROP TABLE IF EXISTS suggestions CASCADE;
DROP TABLE IF EXISTS tournaments CASCADE;
DROP TABLE IF EXISTS logs CASCADE;

-- 2) 公告表
CREATE TABLE announcements (
  id SERIAL PRIMARY KEY,
  title TEXT,
  content TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3) 活动表
CREATE TABLE activities (
  id SERIAL PRIMARY KEY,
  emoji TEXT,
  title TEXT,
  description TEXT,
  event_time TIMESTAMPTZ DEFAULT NOW(),
  location TEXT,
  capacity INT,
  registered_count INT DEFAULT 0,
  closed BOOLEAN DEFAULT FALSE,
  deadline DATE,
  banner_url TEXT
);

-- 4) 活动报名表
CREATE TABLE registrations (
  id SERIAL PRIMARY KEY,
  student_id TEXT,
  student_name TEXT,
  class_name TEXT,
  activity_id INT,
  activity_title TEXT,
  registered_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 防止同一学生重复报名同一活动（前端已有校验，数据库再兜底）
CREATE UNIQUE INDEX registrations_unique_activity_student_idx
  ON registrations (activity_id, student_id);

-- 5) 福利物品表
CREATE TABLE welfares (
  id SERIAL PRIMARY KEY,
  title TEXT,
  tags TEXT,
  types TEXT,
  address TEXT,
  image_url TEXT,
  description TEXT,
  rules TEXT,
  expiry DATE
);

-- 6) 学生意见箱表（对齐前端字段契约）
CREATE TABLE suggestions (
  id SERIAL PRIMARY KEY,
  is_anonymous BOOLEAN DEFAULT TRUE,
  class_name TEXT,
  student_id TEXT,
  content TEXT,
  image_url TEXT,
  replied BOOLEAN DEFAULT FALSE,
  is_public BOOLEAN DEFAULT FALSE,
  reply_text TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 7) 赛事抽签表（支持发布/删除/改名）
CREATE TABLE tournaments (
  id SERIAL PRIMARY KEY,
  title TEXT,
  pairings JSONB,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 确保 pairings 是数组结构，避免脏数据
ALTER TABLE tournaments
  ADD CONSTRAINT tournaments_pairings_is_array_chk
  CHECK (pairings IS NULL OR jsonb_typeof(pairings) = 'array');

-- 8) 审计日志表
CREATE TABLE logs (
  id SERIAL PRIMARY KEY,
  timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  action TEXT,
  operator TEXT
);

-- 9) 禁用 RLS（前端可免登录直连读写）
ALTER TABLE announcements DISABLE ROW LEVEL SECURITY;
ALTER TABLE activities DISABLE ROW LEVEL SECURITY;
ALTER TABLE registrations DISABLE ROW LEVEL SECURITY;
ALTER TABLE welfares DISABLE ROW LEVEL SECURITY;
ALTER TABLE suggestions DISABLE ROW LEVEL SECURITY;
ALTER TABLE tournaments DISABLE ROW LEVEL SECURITY;
ALTER TABLE logs DISABLE ROW LEVEL SECURITY;

-- 10) 显式授权给 Supabase 常用角色（避免仅建表但前端无权限）
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE
  announcements,
  activities,
  registrations,
  welfares,
  suggestions,
  tournaments,
  logs
TO anon, authenticated, service_role;

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;

-- 11) 默认日志
INSERT INTO logs (timestamp, action, operator)
VALUES (
  '2026-07-18 22:15:34',
  '系统启动：初始化 NOVUS 本地沙盒缓存成功。',
  'system'
);

ALTER TABLE public.activities
  ADD COLUMN IF NOT EXISTS is_draw boolean DEFAULT false;

ALTER TABLE public.activities
  ADD COLUMN IF NOT EXISTS draw_mode text DEFAULT 'none';

COMMIT;
