-- Daily Expense Tracker — Supabase Schema
-- Run this in your Supabase SQL Editor to set up the database

-- Create expenses table
create table if not exists expenses (
  id          uuid        default gen_random_uuid() primary key,
  description text        not null,
  category    text        not null,
  amount      numeric     not null,
  date_time   timestamptz not null,
  created_at  timestamptz default now()
);

-- Index for fast date filtering (used by daily report)
create index if not exists idx_expenses_date_time
  on expenses (date_time);

-- Optional: Row Level Security (enable if using Supabase Auth)
-- alter table expenses enable row level security;

-- Handy view: today's expenses (EAT = UTC+3)
create or replace view today_expenses as
select *
from expenses
where date_time::date = (now() at time zone 'Africa/Nairobi')::date
order by date_time desc;

-- Handy view: spending by category for today
create or replace view today_by_category as
select
  category,
  sum(amount)   as total,
  count(*)      as num_transactions
from expenses
where date_time::date = (now() at time zone 'Africa/Nairobi')::date
group by category
order by total desc;
