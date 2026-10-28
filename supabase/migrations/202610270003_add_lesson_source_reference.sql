alter table public.lessons
add column if not exists source_reference text unique;
