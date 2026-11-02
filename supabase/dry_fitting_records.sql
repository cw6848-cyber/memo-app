-- Dry Fitting 계산기(dry-fitting.html)용 테이블
-- Supabase 대시보드 → SQL Editor에 붙여넣고 Run 하세요. (memo-app과 같은 프로젝트)

create table if not exists public.dry_fitting_records (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null default auth.uid() references auth.users (id) on delete cascade,
  created_at    timestamptz not null default now(),
  hn            text,                 -- 호선
  target        text not null default 'Propeller',
  test_date     date,                 -- 검사일
  inspector     text,                 -- 점검자
  step          numeric not null default 0.5,  -- 이동거리 간격 (mm)
  ref_pressures text,                 -- 기준 압력 목록 (쉼표 구분)
  pressures     jsonb not null,       -- 거리별 압력 배열 (kgf/cm²)
  criteria      jsonb,                -- 판정 기준 입력값
  slope         numeric,              -- 기울기 (kgf/cm²/mm)
  intercept     numeric,
  x0            numeric,              -- 0 kgf/cm² 교점 (mm)
  r2            numeric,
  verdict       text,                 -- 양호 / 확인 필요 / 불량
  verdict_note  text
);

create index if not exists dry_fitting_records_user_id_idx on public.dry_fitting_records (user_id);

alter table public.dry_fitting_records enable row level security;

-- 본인 기록만 조회·추가·수정·삭제
drop policy if exists "dry_fitting own select" on public.dry_fitting_records;
drop policy if exists "dry_fitting own insert" on public.dry_fitting_records;
drop policy if exists "dry_fitting own update" on public.dry_fitting_records;
drop policy if exists "dry_fitting own delete" on public.dry_fitting_records;

create policy "dry_fitting own select" on public.dry_fitting_records
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "dry_fitting own insert" on public.dry_fitting_records
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "dry_fitting own update" on public.dry_fitting_records
  for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "dry_fitting own delete" on public.dry_fitting_records
  for delete to authenticated using ((select auth.uid()) = user_id);
