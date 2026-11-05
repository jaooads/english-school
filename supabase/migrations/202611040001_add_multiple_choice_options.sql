create table public.question_options (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.questions(id) on delete cascade,
  option_text text not null check (char_length(trim(option_text)) > 0),
  position integer not null default 0 check (position >= 0)
);

create index question_options_order_idx
on public.question_options (question_id, position);

alter table public.question_options enable row level security;

create policy "Authenticated users can read question options"
on public.question_options for select to authenticated
using (true);

create policy "Teacher can create question options"
on public.question_options for insert to authenticated
with check (public.is_teacher());

create policy "Teacher can update question options"
on public.question_options for update to authenticated
using (public.is_teacher()) with check (public.is_teacher());

create policy "Teacher can delete question options"
on public.question_options for delete to authenticated
using (public.is_teacher());

grant select, insert, update, delete on public.question_options to authenticated;
