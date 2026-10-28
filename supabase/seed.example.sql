-- Seed opcional para validar a interface com uma aula representativa do caderno.
-- Execute manualmente no SQL Editor após criar Camila e configurar seu perfil como TEACHER.
-- O conteúdo abaixo foi preservado da aula de 02/09/2026 do Digital English Notebook.

do $$
declare
  teacher_id uuid;
  seeded_lesson_id uuid;
  seeded_exercise_id uuid;
begin
  select id into teacher_id
  from public.profiles
  where role = 'TEACHER'
  order by name
  limit 1;

  if teacher_id is null then
    raise exception 'Crie e configure o perfil TEACHER antes de executar o seed.';
  end if;

  if exists (
    select 1 from public.lessons
    where lesson_date = '2026-09-02' and title = 'Simple Past Question'
  ) then
    raise notice 'A aula representativa já existe. Nenhum dado foi criado.';
    return;
  end if;

  insert into public.lessons (title, lesson_date, created_by)
  values ('Simple Past Question', '2026-09-02', teacher_id)
  returning id into seeded_lesson_id;

  insert into public.lesson_blocks (lesson_id, type, title, content, position)
  values
    (
      seeded_lesson_id,
      'GRAMMAR',
      'Simple Past Question',
      E'No passado, usamos DID para fazer perguntas.\n\nEstrutura:\nDid + subject + verb (base form) + complement?\n\nImportante: depois de did, o verbo volta para a forma normal.',
      0
    ),
    (
      seeded_lesson_id,
      'EXAMPLE',
      'Examples',
      E'Did you work yesterday?\nDid she study English?\nDid they travel last weekend?\nDid he play soccer?\n\n❌ Did you worked yesterday?\n✅ Did you work yesterday?',
      1
    ),
    (
      seeded_lesson_id,
      'TEXT',
      'Short answers',
      E'Yes, I did.\nYes, he did.\nYes, she did.\nYes, they did.\n\nNo, I didn''t.\nNo, he didn''t.\nNo, she didn''t.\nNo, they didn''t.',
      2
    ),
    (
      seeded_lesson_id,
      'LINK',
      'Listening practice',
      'https://www.elllo.org/class/A1/A1-23-Past-Tense.html',
      3
    );

  insert into public.exercises (lesson_id, title, instructions, type, is_homework, position)
  values (
    seeded_lesson_id,
    'Complete com did e o verbo entre parênteses',
    'Complete each question using did and the verb in parentheses.',
    'TEXT_INPUT',
    false,
    0
  )
  returning id into seeded_exercise_id;

  insert into public.questions (exercise_id, question, position)
  values
    (seeded_exercise_id, '_____ you _____ (work) yesterday?', 0),
    (seeded_exercise_id, '_____ she _____ (watch) TV last night?', 1),
    (seeded_exercise_id, '_____ they _____ (travel) last weekend?', 2),
    (seeded_exercise_id, '_____ he _____ (play) soccer?', 3),
    (seeded_exercise_id, '_____ you _____ (cook) dinner?', 4),
    (seeded_exercise_id, '_____ your parents _____ (visit) you?', 5);
end;
$$;
