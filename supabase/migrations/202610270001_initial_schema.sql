create extension if not exists pgcrypto;

create type public.app_role as enum ('TEACHER', 'STUDENT');
create type public.lesson_block_type as enum ('TEXT', 'GRAMMAR', 'VOCABULARY', 'EXAMPLE', 'LINK');
create type public.exercise_type as enum ('TEXT_INPUT', 'TEXTAREA', 'MULTIPLE_CHOICE');
create type public.answer_status as enum ('PENDING', 'CORRECT', 'INCORRECT');

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null check (char_length(trim(name)) > 0),
  role public.app_role not null
);

create table public.lessons (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(trim(title)) > 0),
  lesson_date date not null,
  created_by uuid not null references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.lesson_blocks (
  id uuid primary key default gen_random_uuid(),
  lesson_id uuid not null references public.lessons(id) on delete cascade,
  type public.lesson_block_type not null,
  title text,
  content text not null check (char_length(trim(content)) > 0),
  position integer not null default 0 check (position >= 0)
);

create table public.exercises (
  id uuid primary key default gen_random_uuid(),
  lesson_id uuid not null references public.lessons(id) on delete cascade,
  title text not null check (char_length(trim(title)) > 0),
  instructions text,
  type public.exercise_type not null default 'TEXT_INPUT',
  is_homework boolean not null default false,
  position integer not null default 0 check (position >= 0),
  created_at timestamptz not null default now()
);

create table public.questions (
  id uuid primary key default gen_random_uuid(),
  exercise_id uuid not null references public.exercises(id) on delete cascade,
  question text not null check (char_length(trim(question)) > 0),
  position integer not null default 0 check (position >= 0)
);

create table public.answers (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.questions(id) on delete cascade,
  student_id uuid not null references public.profiles(id) on delete cascade,
  answer text not null check (char_length(trim(answer)) > 0),
  status public.answer_status not null default 'PENDING',
  corrected_answer text,
  teacher_feedback text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (question_id, student_id)
);

create index lessons_date_idx on public.lessons (lesson_date desc);
create index lesson_blocks_order_idx on public.lesson_blocks (lesson_id, position);
create index exercises_order_idx on public.exercises (lesson_id, position);
create index questions_order_idx on public.questions (exercise_id, position);
create index answers_student_idx on public.answers (student_id, status);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger lessons_set_updated_at
before update on public.lessons
for each row execute function public.set_updated_at();

create trigger answers_set_updated_at
before update on public.answers
for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, name, role)
  values (
    new.id,
    coalesce(nullif(trim(new.raw_user_meta_data ->> 'name'), ''), split_part(new.email, '@', 1)),
    'STUDENT'
  );

  return new;
end;
$$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

create or replace function public.is_teacher()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles
    where id = auth.uid() and role = 'TEACHER'
  );
$$;

create or replace function public.save_student_answer(
  target_question_id uuid,
  answer_text text
)
returns public.answers
language plpgsql
security definer
set search_path = public
as $$
declare
  saved_answer public.answers;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  if not exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'STUDENT'
  ) then
    raise exception 'Only the student can submit answers';
  end if;

  if nullif(trim(answer_text), '') is null then
    raise exception 'Answer cannot be empty';
  end if;

  if not exists (select 1 from public.questions where id = target_question_id) then
    raise exception 'Question not found';
  end if;

  insert into public.answers (question_id, student_id, answer)
  values (target_question_id, auth.uid(), trim(answer_text))
  on conflict (question_id, student_id) do update
  set answer = excluded.answer,
      status = 'PENDING',
      corrected_answer = null,
      teacher_feedback = null
  returning * into saved_answer;

  return saved_answer;
end;
$$;

create or replace function public.correct_student_answer(
  target_answer_id uuid,
  correction_status public.answer_status,
  correction_answer text default null,
  correction_feedback text default null
)
returns public.answers
language plpgsql
security definer
set search_path = public
as $$
declare
  corrected public.answers;
begin
  if not public.is_teacher() then
    raise exception 'Only the teacher can correct answers';
  end if;

  if correction_status = 'PENDING' then
    raise exception 'A correction must be correct or incorrect';
  end if;

  update public.answers
  set status = correction_status,
      corrected_answer = nullif(trim(correction_answer), ''),
      teacher_feedback = nullif(trim(correction_feedback), '')
  where id = target_answer_id
  returning * into corrected;

  if corrected.id is null then
    raise exception 'Answer not found';
  end if;

  return corrected;
end;
$$;

alter table public.profiles enable row level security;
alter table public.lessons enable row level security;
alter table public.lesson_blocks enable row level security;
alter table public.exercises enable row level security;
alter table public.questions enable row level security;
alter table public.answers enable row level security;

create policy "Authenticated users can read profiles"
on public.profiles for select to authenticated
using (true);

create policy "Authenticated users can read lessons"
on public.lessons for select to authenticated
using (true);

create policy "Teacher can create lessons"
on public.lessons for insert to authenticated
with check (public.is_teacher() and created_by = auth.uid());

create policy "Teacher can update lessons"
on public.lessons for update to authenticated
using (public.is_teacher()) with check (public.is_teacher());

create policy "Teacher can delete lessons"
on public.lessons for delete to authenticated
using (public.is_teacher());

create policy "Authenticated users can read lesson blocks"
on public.lesson_blocks for select to authenticated
using (true);

create policy "Teacher can create lesson blocks"
on public.lesson_blocks for insert to authenticated
with check (public.is_teacher());

create policy "Teacher can update lesson blocks"
on public.lesson_blocks for update to authenticated
using (public.is_teacher()) with check (public.is_teacher());

create policy "Teacher can delete lesson blocks"
on public.lesson_blocks for delete to authenticated
using (public.is_teacher());

create policy "Authenticated users can read exercises"
on public.exercises for select to authenticated
using (true);

create policy "Teacher can create exercises"
on public.exercises for insert to authenticated
with check (public.is_teacher());

create policy "Teacher can update exercises"
on public.exercises for update to authenticated
using (public.is_teacher()) with check (public.is_teacher());

create policy "Teacher can delete exercises"
on public.exercises for delete to authenticated
using (public.is_teacher());

create policy "Authenticated users can read questions"
on public.questions for select to authenticated
using (true);

create policy "Teacher can create questions"
on public.questions for insert to authenticated
with check (public.is_teacher());

create policy "Teacher can update questions"
on public.questions for update to authenticated
using (public.is_teacher()) with check (public.is_teacher());

create policy "Teacher can delete questions"
on public.questions for delete to authenticated
using (public.is_teacher());

create policy "Student reads own answers and teacher reads all"
on public.answers for select to authenticated
using (student_id = auth.uid() or public.is_teacher());

revoke all on function public.save_student_answer(uuid, text) from public;
revoke all on function public.correct_student_answer(uuid, public.answer_status, text, text) from public;
grant execute on function public.save_student_answer(uuid, text) to authenticated;
grant execute on function public.correct_student_answer(uuid, public.answer_status, text, text) to authenticated;

grant select on public.profiles, public.answers to authenticated;
grant select, insert, update, delete on public.lessons, public.lesson_blocks, public.exercises, public.questions to authenticated;
