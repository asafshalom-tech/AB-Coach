-- A/B Coach Studio v3: run ONCE in Supabase Dashboard → SQL Editor.
-- Public frontend must ONLY use the project's Publishable / anon key. NEVER use service_role.
-- Row-Level Security ensures each authenticated account can access only its own row.
create table if not exists public.coaching_states (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
create or replace function public.set_coaching_state_updated_at()
returns trigger language plpgsql set search_path = public as $$
begin new.updated_at = now(); return new; end; $$;
drop trigger if exists coaching_states_updated_at on public.coaching_states;
create trigger coaching_states_updated_at
before insert or update on public.coaching_states
for each row execute function public.set_coaching_state_updated_at();
alter table public.coaching_states enable row level security;
revoke all on public.coaching_states from anon;
grant select,insert,update,delete on public.coaching_states to authenticated;
drop policy if exists "Users can read their own training" on public.coaching_states;
create policy "Users can read their own training" on public.coaching_states
for select to authenticated using ((select auth.uid()) = user_id);
drop policy if exists "Users can create their own training" on public.coaching_states;
create policy "Users can create their own training" on public.coaching_states
for insert to authenticated with check ((select auth.uid()) = user_id);
drop policy if exists "Users can update their own training" on public.coaching_states;
create policy "Users can update their own training" on public.coaching_states
for update to authenticated using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);
drop policy if exists "Users can delete their own training" on public.coaching_states;
create policy "Users can delete their own training" on public.coaching_states
for delete to authenticated using ((select auth.uid()) = user_id);
