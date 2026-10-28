-- Importacao integral do Digital English Notebook.
-- Execute depois das migrations 001, 002 e 003.
-- O script e idempotente: aulas importadas sao identificadas por source_reference.

begin;
do $$
declare
  teacher_id uuid;
  imported_lesson_id uuid;
begin
  select id into teacher_id from public.profiles where role = 'TEACHER' order by name limit 1;
  if teacher_id is null then raise exception 'Configure o perfil TEACHER antes da importacao.'; end if;

  insert into public.lessons (title, lesson_date, created_by, source_reference)
  values ('Introductions and Verb To Be', '2026-03-02'::date, teacher_id, 'digital-notebook:0')
  on conflict (source_reference) do update
  set title = excluded.title, lesson_date = excluded.lesson_date
  returning id into imported_lesson_id;
  delete from public.lesson_blocks where lesson_id = imported_lesson_id;
  insert into public.lesson_blocks (lesson_id, type, title, content, position) values
    (imported_lesson_id, 'TEXT', 'Identificacao original', 'First class - 02/03/2026', 0),
    (imported_lesson_id, 'LINK', 'Material externo', 'https://www.canva.com/design/DAHC1iutj-M/h6_3-2hfR3-adR0wMCLcUA/edit?utm_content=DAHC1iutj-M&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton', 1),
    (imported_lesson_id, 'TEXT', '', 'Dificuldades :
I´m tired - Estou cansado
How are you? - Como você está
Good afternoon - Boa Tarde
Good evening - Boa noite (Entrada)
I´m angry - Estou bravo
Quando a palavra começar com vogal usar AN e não A.
Ex:  I am a Developer;
EX: I am an agronomist;
It- Animal e objeto  is
You- Você are
We- Nós are
They- Eles are', 2),
    (imported_lesson_id, 'IMAGE', 'Material visual do caderno', 'image4.png', 3),
    (imported_lesson_id, 'TEXT', '', 'You- Vocês are
Verb to be NEGATIVE
Para  usar o verb to  be em frases negativas apenas acrescentamos NOT.', 4),
    (imported_lesson_id, 'TEXT', 'ATIVIDADE', 'Complete:
I _am__ tired.
She _is__ happy.
They _are__ friends.
He _is__ a doctor.
We _are__ ready.
You _are__ late.
Transforme:
I am tired.  - I am not tired.
She is married. - She is not married.
They are ready. - They are not ready.
He is busy.  He is not busy.
How old is he?17
Where is he from?Canada
What his name?
Peter', 5),
    (imported_lesson_id, 'TEXT', 'HOMEWORK', 'Escrever um pequeno texto:
"My name is… I am … years old. I am from… I am … I am not …"
Hi, My name is Joao, I am nineteen years old, I am from Blumenau.
I am a Developer Engineer, I am not a Support Assistant. ✔️
Gravar áudio lendo o texto. - Feito.', 6);

  insert into public.lessons (title, lesson_date, created_by, source_reference)
  values ('Personal Pronouns and Verb To Be', '2026-03-05'::date, teacher_id, 'digital-notebook:70')
  on conflict (source_reference) do update
  set title = excluded.title, lesson_date = excluded.lesson_date
  returning id into imported_lesson_id;
  delete from public.lesson_blocks where lesson_id = imported_lesson_id;
  insert into public.lesson_blocks (lesson_id, type, title, content, position) values
    (imported_lesson_id, 'TEXT', 'Identificacao original', 'Second class - 05/03/2026', 0),
    (imported_lesson_id, 'TEXT', '', '1.Ligue os pronomes pessoais ( personal pronouns) ao seu significado em português.
-I            Ele - He ✔️
-You      Você You ✔️
-He        Ele ou ela (para animais, objetos) It ✔️
-She      Nós - We ✔️
- It         Vocês - You ✔️
-We        Eu - I ✔️
-You       Eles ou elas( para pessoas)  - They ✔️
- They     Ela She ✔️
2.Complete com am, is, are:  is - é - singular - uma pessoa
are - são - plural - mais de uma pessoa
*I _am___ ✔️ Eu sou / Estou
*You _are___ ✔️ Você é / Está
He _is__ ✔️ Ele é / Está
She _is___ ✔️ Elá é / Está
It _is___ ✔️ Ele é /  Está
We _are___ ✔️Nós somos / Estamos
*You _are___ ✔️ Vocês são /  Estão
They __are__ ✔️ Eles  são / Estão
3.Escreva na forma contraída = abreviada
I´m ✔️
You´re ____ ✔️
He´s ____ ✔️
She`s ____ ✔️
It`s ____ ✔️
We`re ____ ✔️
You `re____ ✔️
They`re ____ ✔️
4.Escreva o pronome pessoal ( personal pronouns) correto:
a) Peter = _ He ___ ✔️
b) The dog = _It___ ✔️
c) Suellen = _She___ ✔️
d) The books= __They_  The books está no plural, e IT é singular então neste caso mesmo sendo objeto usaremos THEY.
e) Lucy = _She___ ✔️
f. ) Laura = __She__ ✔️
g) The cat = _It___ ✔️
h) Lucy and I = We_ ✔️
i) Frank and Maggy = _They___ ✔️
j) Paul and Mile = ___They_ ✔️
5.Complete com o verbo to be. Preste atenção na tradução:
a. _They___ are_ my friends . ✔️
Eles são meus amigos.
b. _We___ _are__ happy. ✔️
Nós estamos/somos felizes.
c. _She`s__ ___ my mother . ✔️
Ela é minha mãe.
d. _You`re___ ___ a student. ✔️
Você é um estudante.
e. _He`s___ ___ my father.✔️
Ele é meu pai.
f. __I´m__ ___ student. ✔️
Eu sou estudante.
6.Complete, escrevendo a forma correta do verbo to be negativa ( am, is , are) no presente do indicativo :
a ) She  _is not___ a dentist.   b) She ´s__not__ a tennis player.  c) We´re not artists.
d) He _is not___ a doctor.       e) I´m_not___ a boy.                       f) She `s_not___ my friend.
g) They _are not_ boys.        h)They ´re not____ engineers.         i) They´re__not__ girls.
j) He`s not___ a Singer.       k) You´re_not___ a student of English.   l) It`s not____ a house.
Verb to be QUESTION
Para fazer pergunta com o verbo to be, eu só troco a posição: o verbo vem antes da pessoa', 1),
    (imported_lesson_id, 'TEXT', 'ATIVIDADE', 'Transforme as frases em perguntas.
Exemplo: You are happy. → Are you happy?
She is your sister. Is she yout sister?
He is tired.  is He tired?
They are at school.  Are they at school?
We are ready. Are we ready?
You are a student. Are you a student?
It is cold today.  Is it cold today?
He is your friend.  is  he your friend?
They are from Brazil Are they from Brazil?
Formas contraídas
I''m  You''re He''s She''s It''s We''re They''re', 2);

  insert into public.lessons (title, lesson_date, created_by, source_reference)
  values ('Feelings and Basic States', '2026-03-16'::date, teacher_id, 'digital-notebook:163')
  on conflict (source_reference) do update
  set title = excluded.title, lesson_date = excluded.lesson_date
  returning id into imported_lesson_id;
  delete from public.lesson_blocks where lesson_id = imported_lesson_id;
  insert into public.lesson_blocks (lesson_id, type, title, content, position) values
    (imported_lesson_id, 'TEXT', 'Identificacao original', 'Third class - 16/03/2026', 0),
    (imported_lesson_id, 'VOCABULARY', 'NEW VOCABULARY', 'NEW VOCABULARY', 1),
    (imported_lesson_id, 'TEXT', 'Feelings / Basic States', 'Feelings = sentimentos / como nos sentimos
Basic states = sensações básicas
Happy - Feliz Sad - Triste Tired - Cansado Hungry - Fome Thirsty - Sede Excited - animado
Calm - Calmo Good - Bem/Bom Bad - Ruim/ Mal/ Mau Ready - Pronto
Sick - Doente
Bored - Entediado
Scared - Assustado
angry -  bravo', 2),
    (imported_lesson_id, 'GRAMMAR', 'GRAMMAR', 'Sometimes we want to make the feeling stronger.
Usamos duas palavras muito comuns:
very = muitoreally = realmente / muito', 3),
    (imported_lesson_id, 'EXAMPLE', 'Examples', 'I am tired.I am very tired.-
I am happy.I am really happy.', 4),
    (imported_lesson_id, 'TEXT', 'Listening Exercise', 'Tired  ok                                           6. Sick
Hungry                                           7. Bored
Thirsty                                           8. Scared
Excited                                          9. Happy ok
Calm   ok                                      10. Sad ok', 5),
    (imported_lesson_id, 'TEXT', 'Reading Exercise', 'Hello!
My name is Mark.
Today I am very tired.
I am hungry and thirsty.
But I am really happy today.
I am calm and ready to study.
read- ler
ready- pronto
Questions OK
1.Is Mark tired? Yes, Mark is tired
2.Is Mark hungry? Yes, he is hungry and thirsty.
3.Is Mark sad? No, he is happy.
4.Is Mark calm? Yes, he is calm.', 6),
    (imported_lesson_id, 'TEXT', 'Writing Exercise', 'Write 5 sentences
1- I am hungry.
2-  I am not thirsty.
3 - Are we Sad?
4-  She is really happy.
5- They are very tired.
Video Activity', 7),
    (imported_lesson_id, 'LINK', 'Material externo', 'https://en.islcollective.com/english-esl-video-lessons/vocabulary-practice/general-vocabulary-practice/adjectives/the-emoji-movie-emotions-galore-positive-negative/18275', 8);

  insert into public.lessons (title, lesson_date, created_by, source_reference)
  values ('Activities and Homework', '2026-03-19'::date, teacher_id, 'digital-notebook:218')
  on conflict (source_reference) do update
  set title = excluded.title, lesson_date = excluded.lesson_date
  returning id into imported_lesson_id;
  delete from public.lesson_blocks where lesson_id = imported_lesson_id;
  insert into public.lesson_blocks (lesson_id, type, title, content, position) values
    (imported_lesson_id, 'TEXT', 'Identificacao original', '4th class 19/03/2026', 0),
    (imported_lesson_id, 'TEXT', 'ACTIVITIES (vale como homework também):', 'Instructions: - Leia com atenção; -Não pesquise; -Anote/envie suas dúvidas; - Você pode voltar e consultar as atividades e dicas deste caderno.
Remember: One good decision today can change everything and every mistake is proof that you are trying. I trust and love you!
*Uma boa decisão hoje pode mudar tudo e todo erro é prova de que você está tentando. Eu confio e amo você - Te amo! obrigado
Escreva um mini texto *introducing yourself*  in English:
R: Hello! Good Night! Today is a very good day.The day is calm to relax, and play games or assist movie. And watch soccer Corinthians, I am happy or not.
Complete usando A ou AN:
REGRA: Use A antes de palavras que começam com som de consoante a dog, a car, a house
Use AN antes de palavras que começam com som de vogal an apple, an elephant, an orange
Atenção: é o som, não só a letra!           an hour (o “h” não é pronunciado)
a) She has a white dog. (Ela tem um cachorro branco.)
b) He wants  a   piece of that cake. (Ele quer um pedaço daquele bolo.)
c) I love to eat  an   apple every morning. ( Eu amo comer uma maça toda manhã.)
d) She has  an   interesting idea. ( Ela tem uma ideia interessante.)
e) My dad got  a   new job. (Meu pai conseguiu um emprego novo.)
f) Sarah wants to be  a dancer. (Sarah quer ser uma dançarina.)
g) I will take  a   taxi. (Eu pegarei um táxi.)
h) Maria is  a  good girl. ( Maria é uma boa garota)
i) My cousin wants to be  an    astronaut. ( Meu primo quer ser um astronauta)
j) She is a  girl. (Ela é uma garota)
k) He is  a  boy. ( Ele é um garoto)
l) I need to buy  a  backpack. (Eu preciso comprar uma mochila)
Complete o diálogo utilizando you - I´m - very - you - Hi - And - are - I - I´m :
A- _Hi__ Daniel! How _are___  __you__?
B- Hey Ana! _i´m__ really fine today. _And__ you?
A- I´m feeling _very___ tired! _I_ worked a lot!
B- _I´m__ sorry for that. I hope things get better for _you__!
Transforme as frases no que se pede entre parênteses, e traduza:
ex: He is a happy person. ( negative)
He is not (isn´t) a happy person.
Ele não é uma pessoa feliz
1-  She is really calm. (negative) She is not really calm - Ela não está realmente calma
2- You are not happy. (affirmative) You are happy - Você está feliz
3- I am not tired. (affirmative) I am tired - Estou cansado
4- You are hungry. (Interrogative) Are you hungry? - Você está com fome?
5- Is she sad? (negative) She is not sad - Ela não está triste.
6  You are not a developer. (Interrogative) Are you a developer?  - Você é um desenvolvedor?
5. Abrevie o verb to be:
You are not happy.  You´re not happy
She is angry. She´s angry
We are tired. We´re tired.
They are not thirsty. They´re not thirsty
He is scared. He´s scared
6. Grave um áudio lendo as frases da sua resposta dos números 4 e 5.', 1);

  insert into public.lessons (title, lesson_date, created_by, source_reference)
  values ('Cardinal Numbers', '2026-03-19'::date, teacher_id, 'digital-notebook:273')
  on conflict (source_reference) do update
  set title = excluded.title, lesson_date = excluded.lesson_date
  returning id into imported_lesson_id;
  delete from public.lesson_blocks where lesson_id = imported_lesson_id;
  insert into public.lesson_blocks (lesson_id, type, title, content, position) values
    (imported_lesson_id, 'TEXT', 'Identificacao original', '5th class - 19/03/2026', 0),
    (imported_lesson_id, 'TEXT', 'NUMBERS', 'NUMBERS', 1),
    (imported_lesson_id, 'TEXT', 'Numbers are very essential in our daily routine.', 'In English numbers need to follow a logic. Just like in Portuguese.
Números Cardinais (1 a 20)
0 - zero
1 - one
2 - two
3 - three
4 - four
5 - five
6 - six
7 - seven
8 - eight
9 - nine
10 - ten
11 - eleven
12 - twelve
13 - thirteen
14 - fourteen
15 - fifteen
16 - sixteen
17 - seventeen
18 - eighteen
19 - nineteen
20 - twenty
Dezenas (20 a 100)
Para formar números compostos (ex: 21, 35), usa-se a dezena + hífen + unidade. Exemplo, 27 twenty-seven. 44 forty-four…
20 - twenty (ex: twenty-one, twenty-two)
30 - thirty
40 - forty
50 - fifty
60 - sixty
70 - seventy
80 - eighty
90 - ninety
100 - one hundred / a hundred
Números Grandes
1,000 - one thousand
10,000 - ten thousand
100,000 - one hundred thousand
1,000,000 - one million
IMPORTANT assim como nos números cardinais, nos números grandes seguimos a mesma lógica. Exemplo, 612  six hundred and twelve      1.224.000 one million two hundred and twenty-four thousand
Now LET´S TRY
Complete the numbers in English
21 →  Twenty-one
34 → _Thirty-four_________
45 → _forty-five_________
58 → __fifty-eight ________
67 → ___sixty-seven_______
72 → ___seventy-two_______
89 → ___eighty-nine_______
93 → __ninety -three________
2.Listen and write the number
25
13
40
68
90
32
15
77
30
58
3.Answer
How old are you?
How many people are in your family?
How many hours do you work?
What is your favorite number?
How old is your girlfriend?
Tell me your phone number.
4. Guess  the price.', 2);

  insert into public.lessons (title, lesson_date, created_by, source_reference)
  values ('Ordinal Numbers and Dates', '2026-03-30'::date, teacher_id, 'digital-notebook:349')
  on conflict (source_reference) do update
  set title = excluded.title, lesson_date = excluded.lesson_date
  returning id into imported_lesson_id;
  delete from public.lesson_blocks where lesson_id = imported_lesson_id;
  insert into public.lesson_blocks (lesson_id, type, title, content, position) values
    (imported_lesson_id, 'TEXT', 'Identificacao original', '6th class - 30/03/2026', 0),
    (imported_lesson_id, 'TEXT', 'Ordinal numbers usado para posições e datas', 'irregular example
1 → one → 1st (first)2 → two → 2nd (second)3 → three → 3rd (third)
regular example
4th – fourth
5th – fifth
6th – sixth
7th – seventh
8th – eighth
9th – ninth
10th – tenth
logical:
21st → twenty-first22nd → twenty-second23rd → twenty-third
Except for the irregular numbers, we use ‘-th’ at the end of the word.', 1),
    (imported_lesson_id, 'IMAGE', 'Material visual do caderno', 'image2.png', 2),
    (imported_lesson_id, 'TEXT', '', 'activity
Write:
1 → First 52 → fifty - second  3 → third 5 → fifth 13 → thirteenth 21 → Twenty - first
Days of the Week
Monday - segunda-feira
Tuesday - terça-feira
Wednesday - quarta-feira
Thursday - quinta-feira
Friday - sexta-feira
Saturday - sábado
Sunday - domingo', 3),
    (imported_lesson_id, 'TEXT', 'PRACTICE', 'Complete
Monday
Tuesday
Wednesday
Friday
sunday
Put in order
Sunday – Tuesday – Monday – Friday
Monday
Tuesday
Friday
Sunday
Months
January - Janeiro
February - Fevereiro
March - Março
April - Abril
May - Maio
June - Junho
July - Julho
August - Agosto
September - Setembro
October - Outubro
November - Novembro
December - Dezembro', 4),
    (imported_lesson_id, 'TEXT', 'Answer:', 'When were you born?I were born in June
When was your mom born? She was born in May
When is Christmas? Is in December
When is Easter?Is in April
What month did you start dating your girlfriend?In  February.
When is the most famous party in Blumenau?In October.
Dates
Month, ordinal
Ex:May 12th
April 1st
October 25th', 5),
    (imported_lesson_id, 'TEXT', 'Answer', 'When is your birthday?June 24th, 2006.
When is my birthday?May 12th, 2008.
When is your sister´s birthday? September 1st, 2023.
What day is today? March, 30th 2026
What day was yesterday? Sunday
What date is next Wednesday? April 1st, 2026.', 6),
    (imported_lesson_id, 'TEXT', 'LISTENING AND READING ACTIVITY', '1.True or false
Daniel is 25 years old. false
He is from a big city. false
On Monday, he is nervous true.
The café is big. false
Lucas is friendly. true
On Thursday, Daniel is scared. true
The park is beautiful.true
On Saturday, Daniel is alone.false
On Sunday, he is ready to go home. true
2. Answer according to the text
What is his name? Daniel
How old is he? 32 years old
Where is he from? small city
Where is he now? big
How does he feel on Monday? nervous
Why is the city difficult for him? There was many people and he was alone
What is near his hotel? café
Who is Lucas? Waiter
How does Daniel feel on Wednesday? Happy
How does he feel on Sunday? Calm and grateful
My name is Daniel. I am 32 years old. I am from a small town. Now I am in a big city.
Today is Monday. I am nervous. The city is big. The streets are busy. There are many people. I am alone.
On Tuesday, I am still a little nervous, but I am okay. There is a café near my hotel. The café is small and nice.
On Wednesday, I am happy. The waiter is Lucas. He is 28 years old. He is friendly. We are friends.
On Thursday, I am not nervous. I am calm. The city is not scary. It is interesting.
On Friday, I am excited. There is a park. The park is beautiful. There are families and children. They are happy.
On Saturday, I am very happy. I am not alone. I am with my friend Lucas.
On Sunday, I am calm and grateful. It is my last day. I am ready to go home.
3. Find in the text
A word that means “feliz” → ______
A word that means “calmo” → ______
A word that means “assustador” → ______
A word that means “amigável” → ______
A word that means “sozinho” → ______
4. Complete
On Monday, Daniel is nervous
On Wednesday, he is  happy
On Thursday, he calm
On Saturday, he is with  Lucas
On Sunday, he is calm and grateful
M
Maneiras de dizer eu não entendi
-I don´t understand (Eu não entendi)
-I don´t get it (Eu não saquei)
-Come again? (Pode repetir?)
I´m very proud of you, and happy with your progress! I love you so much!!!!❤️', 7);

  insert into public.lessons (title, lesson_date, created_by, source_reference)
  values ('In and On with Months and Dates', '2026-04-06'::date, teacher_id, 'digital-notebook:501')
  on conflict (source_reference) do update
  set title = excluded.title, lesson_date = excluded.lesson_date
  returning id into imported_lesson_id;
  delete from public.lesson_blocks where lesson_id = imported_lesson_id;
  insert into public.lesson_blocks (lesson_id, type, title, content, position) values
    (imported_lesson_id, 'TEXT', 'Identificacao original', '7th class - 04/06/2026', 0),
    (imported_lesson_id, 'TEXT', '', 'Hey!
How are you today?
What day is today?
What is the date today?', 1),
    (imported_lesson_id, 'TEXT', 'IN AND ON WITH MONTHS AND DATES', 'IN AND ON WITH MONTHS AND DATES', 2),
    (imported_lesson_id, 'TEXT', 'ON - DAYS/DATES', 'ex: On Monday
On March, 10th', 3),
    (imported_lesson_id, 'TEXT', 'IN - MONTHS/YEARS', 'ex: In July
In 2024
Complete:
1- I study _on__ Monday.
2- My birthday is _in__ September.
3- My mom´s birthday is _on__ October, 23rd.
Read the text. Underline the prepositions (in / on). Some are wrong. Correct them.
My name is Ana.
My birthday is on February 3rd. - For Days/Dates use on.
And I´m very excited because I will see my parents in Paris.
(Pela lógica tratando de um país acredito que faz mais sentido o in)
The last time I went there was in 2018.
My flight is on the 1st, on Saturday. (Deve se utilizar on)
Use the correct preposition
My vacation starts _in__ June.
The meeting is _on__ April 3rd.
I have English class _on__ Monday.
The party is _on__ July 10th.
We travel _in__ 2027.
She studies _on__ Friday.
The test is _on__ August 22nd.
I was born __in_ January.
They will meet __on_ Tuesday.
The event is _on__ November 5th.
He has a game _on__ Saturday.', 4),
    (imported_lesson_id, 'VOCABULARY', 'FAMILY - vocabulary', 'mother/mom - mãe
father/dad - pai
brother - irmão
sister - irmã
friend - amigo(a)
girlfriend - namorada
boyfriend - namorado
grandmother/grandma - vó
grandfather/grandpa - vô
parents - pais', 5),
    (imported_lesson_id, 'VOCABULARY', 'family - família', 'grandparents - avós
daughter - filha
son - filho', 6),
    (imported_lesson_id, 'TEXT', 'POSSESSIVES', 'POSSESSIVES', 7),
    (imported_lesson_id, 'TEXT', 'MY - MEU', 'MY - MEU', 8),
    (imported_lesson_id, 'TEXT', 'YOUR - SEU/SUA/SEUS/SUA', 'YOUR - SEU/SUA/SEUS/SUA', 9),
    (imported_lesson_id, 'TEXT', 'HER - DELA', 'HER - DELA', 10),
    (imported_lesson_id, 'TEXT', 'HIS - DELE', 'HIS - DELE', 11),
    (imported_lesson_id, 'TEXT', 'OUR - NOSSO/NOSSA', 'OUR - NOSSO/NOSSA', 12),
    (imported_lesson_id, 'TEXT', 'THEIR - DELES/DELAS', 'ITS -', 13),
    (imported_lesson_id, 'EXAMPLE', 'EXAMPLE', 'EXAMPLE', 14),
    (imported_lesson_id, 'TEXT', 'THIS IS MY MOTHER', 'THIS IS MY MOTHER', 15),
    (imported_lesson_id, 'TEXT', 'HER NAME IS ANA', 'HER NAME IS ANA', 16),
    (imported_lesson_id, 'TEXT', 'HIS CAR IS NEW', 'HIS CAR IS NEW', 17),
    (imported_lesson_id, 'VOCABULARY', 'THIS IS OUR FAMILY', 'THIS IS OUR FAMILY', 18),
    (imported_lesson_id, 'TEXT', 'THEIR HOUSE IS BIG', 'THEIR HOUSE IS BIG', 19),
    (imported_lesson_id, 'TEXT', 'YOUR GIRLFRIEND IS BEAUTIFUL', 'YOUR GIRLFRIEND IS BEAUTIFUL', 20),
    (imported_lesson_id, 'TEXT', 'ITS NAME IS BENJI', 'Activity', 21),
    (imported_lesson_id, 'LINK', 'Material externo', 'https://www.todamateria.com.br/exercicios-sobre-possessive-adjectives-adjetivos-possessivos-em-ingles-com-gabarito/', 22),
    (imported_lesson_id, 'LINK', 'Material externo', 'https://wordwall.net/pt/resource/10102685/possessive-adjectives', 23),
    (imported_lesson_id, 'TEXT', '', 'Mini game (speaking)
tell me a phrase with…', 24);

  insert into public.lessons (title, lesson_date, created_by, source_reference)
  values ('Simple Present', '2026-04-13'::date, teacher_id, 'digital-notebook:604')
  on conflict (source_reference) do update
  set title = excluded.title, lesson_date = excluded.lesson_date
  returning id into imported_lesson_id;
  delete from public.lesson_blocks where lesson_id = imported_lesson_id;
  insert into public.lesson_blocks (lesson_id, type, title, content, position) values
    (imported_lesson_id, 'TEXT', 'Identificacao original', '8th class - 04/13/2026', 0),
    (imported_lesson_id, 'GRAMMAR', 'Simple Present', 'O Simple Present é o tempo verbal usado para falar de:
Hábitos
coisas que fazemos sempre
“I wake up early.”
Rotina
“I go to school.”
Gostos e preferências
“I like music.”
Verdades gerais
“The sun rises in the east.”
Resumindo: We use Simple Present to talk about things that are part of your life.
So, we use simple present for routines, habits and things we like.
Structure
I/ You/ We/ They + verb + complement
He/ She/ It + verb + s + complement
Para I, You, We, They, usamos o verbo na forma normal.
Exemplo: I play
You study
Para He, She, It acrescentamos S no verbo.
Exemplo: He plays
She works
She (play / plays) tennis.
2.They (eat / eats) pizza.
3.He (like / likes) music.
4.We (study / studies) together.
5.It (run / runs) fast.
6.I (watch / watches) TV.
She likes__ (like) chocolate.
2.I _play_ (play) soccer on weekends.
3.He _studys_ (study) English every day.
4.They watches__ (watch) movies at night.
5.It _eats_ ss(eat) a lot.
He _plays_ (play) video games every day.
2. I _like_ (like) pizza.
3.She _reads_ (read) books at night.
4.We _go_ (go) to school together.
5.It _drinks_ (drink) water.
6.They _work_ (work) in the morning.
7.He _eats_ (eat) lunch at 12 p.m.
8.You _study_ (study) a lot.', 1),
    (imported_lesson_id, 'TEXT', 'REGRAS DO S', 'Regra geral:
só adiciona S
play → plays
like → likes
Verbos terminados em:
ch / sh / x / s / o
Adiciona ES
watch → watches
go → goes
fix → fixes
Verbos terminados em “y”, se antes do “y” tem consoante:
study → studies
try → tries;
Se tem vogal:
play → plays
She __watches____ (watch) TV every day.
2.He __goes____ (go) to school by bus.
3.It ___fixes___ (fix) everything.
4.She __studies___ (study) a lot.
5.He __washes____ (wash) the car.
6.She __tries____ (try) hard.
7.He __teaches____ (teach) English.
8.It ___mixes___ (mix) the ingredients.
Complete com S, ES ou IES
1.He watches__ TV.
2.She goes__ to the gym.
3.He studies__ English.
4.It fixes__ the computer.
5.She tries__ again.
6.He washes__ the car', 2),
    (imported_lesson_id, 'TEXT', 'ACTIVITY', '1. Reescreva as frases abaixo com o pronome he ou she.
a. I study ...He studies............................... (He)
b. We work .....She works.............................(She)
c. They go .......He...goes........................ (He)
d. I speak  ....She speaks............................. (She)
e. You play .........She plays......................... (She)
2. Complete as sentenças abaixo com a forma correta dos verbos em parênteses.
A) I .......go............................ (go) to school everyday.
B)She .......goes............................ (go) to school everyday.
C)They .............speak...................... (speak) English very well.
D)He .................speaks.................. (speak) English very well.
E)You ................watch................... (watch) this TV show every morning.
3.Reescreva as sentenças a seguir na forma negativa.
A)We go to church every Sunday. We do not  go to church every Sunday.
B)They study English on Saturdays. They don´t study English on Saturdays.
C)He reads the newspaper every morning. He doesn’t  read the newspaper every morning.
D) I work at Banco Itaú. I don´t work at Bank Itaú.
E)She has three kids. She doesn´t have three kids.
have-has', 3);

  insert into public.lessons (title, lesson_date, created_by, source_reference)
  values ('Simple Present Exercises', '2026-04-16'::date, teacher_id, 'digital-notebook:715')
  on conflict (source_reference) do update
  set title = excluded.title, lesson_date = excluded.lesson_date
  returning id into imported_lesson_id;
  delete from public.lesson_blocks where lesson_id = imported_lesson_id;
  insert into public.lesson_blocks (lesson_id, type, title, content, position) values
    (imported_lesson_id, 'TEXT', 'Identificacao original', '9th Class - 04/16/2026', 0),
    (imported_lesson_id, 'TEXT', 'EXERCISES', '1.Desembaralhe as palavras formando uma frase no simple present:
my / after / I /  dinner / do /  homework. - I do my homework after dinner.
opens / the / for / he / door / me. - He opens the door for me.
lot / she / a / works. - She works a lot.
like / movies  / together / they / watch / to. They like to watch movies together.
travel / we / month / every. We  travel every month.
his / a / he / car / washes / week / new / once. He washes his new car once a week.
2. True if it is correct or False if it is wrong:
I likes ice cream.F
He love to play games.F
We dance together. T
She likes japonese food.T
They have two cars T
I start to listen to music everyday.T
3. Complete:
On Sunday I ride a bike.
On Monday they play Soccer.
On Tuesday he goes to college.
On Wednesday she studies a lot.
On Thursday we study a lot.
On Friday he plays after 22pm.
On Saturday you paint your nails.
4. Answer:
What do you do in the morning?I wake up, make my coffee, organize my room and my things, and read.
Where do you work?At a Tech Businesses
What do you like to eat at night? I like to eat real food at night.
Do you like to study?I don´t like it a lot.
What do you like to do in your free time? I like to play, stay with my family and with my girlfriend.
5.Complete with the simple present:
My mother…works….. (work) on Sunday.
Sara …likes…. (like) to play tennis.
My dog …sleeps…. (sleep) a lot during the day.
I …want…. (want) more ice cream.
She never  plays. (play) chess
They …walk…. (walk) to school.
He …drives…. (drive) a car
The bus …arrives…. (arrive) at 9am.
This girl …speaks…. (speak) Italian.
My father …works….. (work) long hours.
6.Let´s take a look and talk:', 1),
    (imported_lesson_id, 'LINK', 'Material externo', 'https://youtu.be/EAZfuEQoQDA?si=g4PaKt0QLcGvIN8Z', 2),
    (imported_lesson_id, 'TEXT', '', '7. Game:
Today we are going to play Snakes and ladders.
Rules: We only play if we can complete the challenge.
Create questions for your friend, try to use SIMPLE PRESENT
The challenge is to answer a question, create a sentence… that your friend will ask you.
GOOD LUCK!! https://poki.com/br/g/snakes-and-ladders
próxima ver a número 6
tarefa é número 5', 3);

  insert into public.lessons (title, lesson_date, created_by, source_reference)
  values ('Simple Present - Negative', '2026-06-04'::date, teacher_id, 'digital-notebook:771')
  on conflict (source_reference) do update
  set title = excluded.title, lesson_date = excluded.lesson_date
  returning id into imported_lesson_id;
  delete from public.lesson_blocks where lesson_id = imported_lesson_id;
  insert into public.lesson_blocks (lesson_id, type, title, content, position) values
    (imported_lesson_id, 'TEXT', 'Identificacao original', '10th Class - 06/04/2026', 0),
    (imported_lesson_id, 'GRAMMAR', 'Simple Present - Negative', 'Structure: subject + do/does + not + verb
Para:
I / You / We / They
usamos do not (don’t)
I don’t like pizza
They don’t study
Para:
He / She / It
usamos does not (doesn’t)
He doesn’t like pizza
She doesn’t study', 1),
    (imported_lesson_id, 'TEXT', 'IMPORTANTE:', 'quando usa does, o verbo VOLTA ao normal
exemplo:
He doesn’t likes
He doesn’t like
Então, quando usamos DOES, não usamos S.', 2),
    (imported_lesson_id, 'TEXT', 'ACTIVITY', 'Make negative present simple sentences.
I - not - like coffee - I don’t like coffee
I - not - live in Paris - I don’t live in Paris.
She - not - come from Spain -  She doesn’t  come from Spain
Julie and Lucy - not - play football - Julie and Lucy don’t play football
The sun - not - go round the earth - The sun doesn’t go round the earth', 3),
    (imported_lesson_id, 'LINK', '2.', 'https://agendaweb.org/exercises/verbs/present/negative-test.htm', 4),
    (imported_lesson_id, 'LINK', '3.', 'https://elt.oup.com/student/project/level1/unit04/grammar/exercise3?srsltid=AfmBOooN18noxn7Tt0lIRXGBD_rnmlAnLKqVZVO4Q4qKQ1wDlgo0FVSq&cc=br&selLanguage=pt', 5),
    (imported_lesson_id, 'GRAMMAR', 'Simple Present - Interrogative', 'Assim como na forma negativa, na interrogativa também usamos o mesmo auxiliar
DO/DOES, e seguimos uma estrutura padrão :
Do/Does + sujeito + verbo (forma base)
ex: Do you study English?
Does she work here?
IMPORTANTE: Quando usamos DOES, o verbo volta para a forma normal (sem "s"):
ex: Does he play soccer?
Agora vamos aprender a responder em Inglês, seguindo a mesma lógica da pergunta.
ex:Do you like chocolate?
Yes, I do/ No, I don`t
Percebe-se que em casos de perguntas simples como essas utilizamos as mesmas palavras da pergunta.', 6),
    (imported_lesson_id, 'TEXT', 'ACTIVITY', 'Write the question:
A) Yes, I work on Saturday.
Q- Do you work on Saturday?
B)No, he doesn`t go to the party.
Q- Does he go to the party?
C)Yes, they like to watch movies every Saturday night.
Q- Do they like to watch movies every Saturday night?
D) No, we don´t like to travel.
Q-  Do you like to travel?
Make simple questions and answer:
A)you - drink alcohol
Do you like to drink alcohol?
No, I don’t like to drink alcohol.
B)she - live in London
Does she live in London?
No, she doesn’t live in London.
C)It - snow here in the winter
Does it snow here in the winter?
No, it doesn’t snow here.  It''s very hot.
D)they - study French
Do they study French?
No, they  don’t  study French.', 7),
    (imported_lesson_id, 'LINK', 'Material externo', 'https://www.eslgamesplus.com/present-simple-verbs-game/', 8);

  insert into public.lessons (title, lesson_date, created_by, source_reference)
  values ('Review - Simple Present', '2026-05-19'::date, teacher_id, 'digital-notebook:845')
  on conflict (source_reference) do update
  set title = excluded.title, lesson_date = excluded.lesson_date
  returning id into imported_lesson_id;
  delete from public.lesson_blocks where lesson_id = imported_lesson_id;
  insert into public.lesson_blocks (lesson_id, type, title, content, position) values
    (imported_lesson_id, 'TEXT', 'Identificacao original', '11TH CLASS - 05/19/2026', 0),
    (imported_lesson_id, 'GRAMMAR', 'REVIEW SIMPLE PRESENT', '1. Complete with the right conjugation of the Simple Present Tense.
Follow the example:', 1),
    (imported_lesson_id, 'EXAMPLE', 'Example: Anneloves    the Jane Austin''s work. (love)', 'a) Cayo _______goes_________to the College tonight. (go)
b) My parents ______has_________ Italian and French classes on Thurdays every week. (have)
c) Louise _______works_____________at the Brad''s Office. (work)
d) I _________eat__________ bread with nuts jelly every morning. (eat)
e) The plain _____arrives__________ at 08:00 in the city. (arrive)
2.Now turn the sentences below into negative form:
a) Why do you want to be here?
b) What''s your favourite kind of movie?
c) Do you like your mother?
d) Does he live alone?
e) Does she like you?
a)_______You  don´t_want to be here_________________________________________
b)________You  don''t have favourite kind of movie____________________________
c)_________You don´t like your mother______________________________
d)____He doesn''t_live alone___________________________________________
e)____She doesn''t  like you______________________________________________
3.Read the sentences and try to find the mistakes. Then write it correctly.
a) My cat are very cute and beautiful, I love it!
My cat is very cute and beautiful, I love it! (Quando falamos de animais e no singular usamos is, por ser singular)
b) They are a really big and lovely family.
c) She is just like her mother are.
She is just like her mother. (O are não  precisa existir no final, ele fica sobrando ali)
d) We''s very proud of our brother!
We are very proud of our brother! OR We´re very proud of our brother! ( Quando falamos de we, estamos nos referindo a mais de uma pessoa, por isso usamos o auxiliar are).
e) Let''s saw the game now!
Let´s see the game now! ( See e saw são  os mesmos verbos mas em tempos diferente, see = ver = presente, saw = vimos = passado, neste caso usamos see porque ao final da frase entendemos que é uma situação atual com a palavrinha now, que significa agora).
Observação geral: O exercício foi bem solucionada, gostaria de pedir apenas para que em atividades como essa você deixe a frase que eu coloquei para auxiliar minha correção. Exemplo, frase 1 - I likes to dance - resposta: I like to dance. Não mude a própria frase, mas sim reescreva.', 2);

  insert into public.lessons (title, lesson_date, created_by, source_reference)
  values ('Homework and General Review', '2026-05-21'::date, teacher_id, 'digital-notebook:884')
  on conflict (source_reference) do update
  set title = excluded.title, lesson_date = excluded.lesson_date
  returning id into imported_lesson_id;
  delete from public.lesson_blocks where lesson_id = imported_lesson_id;
  insert into public.lesson_blocks (lesson_id, type, title, content, position) values
    (imported_lesson_id, 'TEXT', 'Identificacao original', '12ND CLASS - 21/05/2026', 0),
    (imported_lesson_id, 'TEXT', '', 'Make exercise 3 from the last class', 1),
    (imported_lesson_id, 'TEXT', 'Homework', '1. Write numbers 1 - 20 using the words below:
three - fifteen - twenty - five - eleven - one - seven - thirteen - seventeen - two - six - twelve - four - ten - eighteen - nine - fourteen - sixteen - eight - nineteen
one                                                11. eleven
two                                                12. twelve
three                                              13. thirteen
four                                                14. fourteen
five                                                 15.fifteen
six                                                  16.sixteen
seven                                             17.seventeen
eight                                               18.eighteen
nine                                                19.nineteen
ten                                                 20.twenty
Tudo correto, muito bem! Referente aos numbers o que eu queria pedir pra ti é veja e reveja. Ele é um conteúdo que vais pegar na prática e eu percebi uma certa dificuldade, com isso também incluirei ele mais vezes nas aulas.', 2),
    (imported_lesson_id, 'GRAMMAR', '2. Complete (Greetings + Verb To Be + Feelings) and translate:', 'a) Hello! How _are____ you today? -Olá, como você está hoje? b) I _am___ happy. Eu estou feliz c) She __is___ very tired. Ela está muito cansada d) They __are____ really excited. Eles estão realmente animados. (peguei do Feelings). e) We __are____ not sad. Nós não estamos tristes.
Muito bemmm! Realmente, os feelings você pegou bem, very good!', 3),
    (imported_lesson_id, 'TEXT', '3. Choose the correct alternative (Affirmative / Negative / Interrogative)', 'a) ___Are___ you ready? - Você está pronto? ( ) Is ( ) Are
b) She __is____ not hungry. - Ela não está com fome. ( ) is ( ) are
c) ___Are___ they at home? - Eles estão em casa? ( ) Is ( ) Are
d) I ___am___ a student. - Eu sou um estudante. ( ) am ( ) is
Uau! I´m so happy! Muito bom teres colocado a tradução sem eu ter pedido, gosto assim hehe.', 4),
    (imported_lesson_id, 'TEXT', '4. Complete com VERY ou REALLY', 'a) I am ___really___ happy today. b) She is __really____ tired. c) They are _ very_____ excited. d) He is ___very___ hungry. (fiquei na dúvida)
Sua dúvida  é compreensível porque realmente não parece natural, eu confesso ter essa impressão. No entanto, está é a atividade que eu te disse que era só completar porque aqui não tem certo ou errado, ela depende da intensidade da situação.
really = mais usado para dar ênfase (mais emocional)
very = mais neutro, intensidade normal', 5),
    (imported_lesson_id, 'TEXT', '5. Complete with A or AN', 'a) I have __ a____ brother. b) She is __an____ engineer. c) This is __an____ apple. d) He is ___a___ teacher
Perfect!', 6),
    (imported_lesson_id, 'TEXT', '6. Numbers (Cardinal & Ordinal)', 'a) How many people are in your family? → ________Fourth__________________
Aqui vamos usar o four, normal. Porque quando falamos de quantidade usamos o cardinal, já para ordem e posição usamos os  ordinais.
b) Write the ordinal: 1 → _ First ___ 2 → __ Second __ 3 → _ third ___ 10 → ___ tenth __
c) My birthday is on the ____twelfth__ of May.
Very good!', 7),
    (imported_lesson_id, 'TEXT', '7. Days and Months + IN / ON', 'a) Today is _Sunday___ (day of the week). b) I study on ___Monday and Thursday___ (day). c) My birthday is __ in Twenty-fourth____ June. ( ) in ( ) on
Aqui temos dois pontos. O primeiro que foi erro meu ao digitar, a frase correta seria: My birthday is _____ June twenty-fourth, e aí o correto seria usar ON, não sei se o seu erro se deu pelo meu, mas de qualquer forma fica de lembrete, pois é muito comum.
on → dias e datas → on Monday, on June 24th
in → meses, anos → in June, in 2020
d) My birthday is __on____ March 5th. ( ) in ( ) on
Tirando a letra C, o restante tudo certo.', 8),
    (imported_lesson_id, 'VOCABULARY', '7. Family + Possessives and translate', 'a) My __ mother’s____ (mother / mother’s) name is Ana.  - O nome da minha mãe é Ana. b) This is my __father’s____ (father / father''s) car. O carro do meu pai, isso? isso  c) I have a ____sister__ (brother / sister). Eu tenho uma irmã. d) My favorite person is my _all!_____. Todos são meus favoritos!
Neste caso, de querer dizer que todos são seus favoritos, a frase precisa mudar. Poderíamos dizer: I love them all - All of them are my favorite - My favorite people are my family.
Observação geral: Coloquei uma atividade que tinha uma parte (a,b,c) com conteúdos que ainda não vimos na teoria, lembro de ter explicado pra você mas de forma vaga… mesmo assim, foi boa!', 9),
    (imported_lesson_id, 'GRAMMAR', '8. Simple Present (Routine)', 'a) I _ study_____ (study) English every day. b) She __ works____ (work) on Monday. Regra do S! c) They __ watch____ (watch) TV at night.
d) Do you study on Saturday? → ___No, I_do not study on Saturday_____________________
e) What do you do after school? → ____I don´t study, I  work all day.
Observação geral: Aqui tivemos um erro repetido, então vamos recordar a estrutura da frase no simple present. Vamos pensar assim, temos dois tipos de frases:
1.a  que não usa AM, IS, ARE. Porque ela já tem o verbo.
Exemplo: She works on Monday.
2.a que não tem verbo de ação. Ela fala de estado, característica, sentimento.
Exemplo:I am happy.
Nessa não tem ação aí usamos o verb to be
O que acontece neste caso, de fazer como fizesse, estamos usando dois verbos um ao lado do outro numa mesma frase. (hmm etendi, mas é bom conversar sobre thanks)
9.  Change the sentences
a) I am happy. → (negative) → _____I am not happy_____________________
b) She is tired. → (interrogative) → __Is she tired?________________________
c) They are at home. → (negative) → _____They are not at home._____________________
All correct, congrats! thanks', 10),
    (imported_lesson_id, 'TEXT', '10. Answer with complete answer (Mixed Practice)', 'a) Hello! How are you today? ___Hello! I am really happy_______________________
b) Are you very tired or excited?______I am very excited!____________________
c) How many people are in your family? _______Four people___________________
Aqui vamos usar o four, normal. Porque quando falamos de quantidade usamos o cardinal, já para ordem e posição usamos os  ordinais.
d) What do you do on Monday? _____I work during the today and study English at 20:00pm__________
e) Is your birthday in July? ______No,  my birthday is in June.____________________
Vou te passar um bizu pra responder perguntas. ( mt bom kkk bizu)
Presta atenção porque geralmente conseguimos responder com a própria pergunta, como neste caso da atividade. Então primeiro vamos entender a pergunta, assim:', 11),
    (imported_lesson_id, 'TEXT', 'IS YOUR (MY) BIRTHDAY (OBJETO DA FRASE) IN JULY (COMPLEMENTO)?', 'Vamos pensar da seguinte maneira, se a pergunta questiona sobre mim eu vou responder com MY, porque your (seu/sua) diz sobre mim. Por isso na hora de responder eu sei  que vou responder com No, my birthday is in June. (hmmm etendi obrigado vou aderir)
f) Do you have a brother or a sister? ______I have one sister :> ____________________
Adverbs of frequency
Adverbs of frequency are used to indicate how often something happens.
The most common adverbs are never, sometimes, often, usually, always.
Ex: - I always wake up at 7am.
- She never drinks coffee.
- They usually study at night.
Important: Na frase a estrutura é pessoa+advérbio+complement
Never - nunca
Sometimes - às vezes
Often - frequentemente
Usually - geralmente
Always - sempre', 12),
    (imported_lesson_id, 'IMAGE', 'Material visual do caderno', 'image3.png', 13),
    (imported_lesson_id, 'TEXT', '', 'Complete:
I ___usually___ wake up at _6:30am____.
I __often____ study English.
I ___always___ use my phone at night.
I ___often___ eat vegetables.
2. Write 5 sentences about your routine using the new vocabulary:
I always drink coffee in the morning.
I usually make my sandwich for the day.
I never poop in the morning.
My girlfriend and I are always happy together.
I always like having lunch between 11:30am and 12:00am.', 14),
    (imported_lesson_id, 'LINK', '3.', 'https://learnenglishkids.britishcouncil.org/grammar-vocabulary/grammar-practice/adverbs-frequency', 15);

  insert into public.lessons (title, lesson_date, created_by, source_reference)
  values ('Adverbs of Frequency Practice', '2026-05-25'::date, teacher_id, 'digital-notebook:1004')
  on conflict (source_reference) do update
  set title = excluded.title, lesson_date = excluded.lesson_date
  returning id into imported_lesson_id;
  delete from public.lesson_blocks where lesson_id = imported_lesson_id;
  insert into public.lesson_blocks (lesson_id, type, title, content, position) values
    (imported_lesson_id, 'TEXT', 'Identificacao original', '13RD CLASS - 05/25/2026', 0),
    (imported_lesson_id, 'TEXT', '', 'Sobre a correção: Num geral foi muito boa, certeza que serviu para auxiliar na fixação, de pouco em pouco a gente chega lá. (Obrigado! te amo gata)
Como hoje não conseguirei te dar aula, vou deixar instruções para treinar mais um pouco.
1- Rewrite the complete sentence using the adverb in brackets in its correct position.
They read a book. (sometimes) - They sometimes read a book.
Peter gets angry. (never) - Peter never gets angry.
I take sugar in my coffee. (always) - I always take sugar in my coffee
Christine smokes. (usually) Chirstine usually smokes
Frank and Ramon are hungry. (often) - Frank and Ramon are often hungry
2- Try again.
Volte na lista que fizesse e refaça:
-number eight
-number ten, letter D.
3- Write a paragraph: tell me about your routine using adverbs of frequency.
HI! My name is João Arthur, I always drink coffee in the morning.I usually go to Brusque, to my girlfriend''s house,  she often do the
lunch for me, I love her!
4- Record the audio and send it to me.
5- Answer:
a)What is your name?
My name is João Arthur
b)How old are you?
I am nineteen years old.
c)Are you happy today?
Yes, I am really happy.
d)Do you study every day?
No, I don''t. I study on Monday and Thursday.
e)Do you always do your homework?
Yes, I am a really good student.
f)Do you watch TV at night?
Sometimes.
g)Does your mother work?
At the moment, she doesn´t.
h)Does your mother drink coffee?
Yes,she loves coffee.
i)Is there a TV in your house?
Yes, three.
j)What is your phone number?
four-seven-nine-nine-two-eight-four-three-three-zero-three
Note: I love you! And I´m really proud of your progress ❤️
Ver resposta', 1);

  insert into public.lessons (title, lesson_date, created_by, source_reference)
  values ('Correcao', '2026-06-01'::date, teacher_id, 'digital-notebook:1060')
  on conflict (source_reference) do update
  set title = excluded.title, lesson_date = excluded.lesson_date
  returning id into imported_lesson_id;
  delete from public.lesson_blocks where lesson_id = imported_lesson_id;
  insert into public.lesson_blocks (lesson_id, type, title, content, position) values
    (imported_lesson_id, 'TEXT', 'Identificacao original', '14th class - 06/01/2026', 0),
    (imported_lesson_id, 'TEXT', '', '-Correção', 1);

  insert into public.lessons (title, lesson_date, created_by, source_reference)
  values ('Simple Present Review', '2026-06-08'::date, teacher_id, 'digital-notebook:1062')
  on conflict (source_reference) do update
  set title = excluded.title, lesson_date = excluded.lesson_date
  returning id into imported_lesson_id;
  delete from public.lesson_blocks where lesson_id = imported_lesson_id;
  insert into public.lesson_blocks (lesson_id, type, title, content, position) values
    (imported_lesson_id, 'TEXT', 'Identificacao original', '15th class - 06/08/2026', 0),
    (imported_lesson_id, 'TEXT', '', 'The best way to predict your future is to create it.
Beautiful message!
It doesn´t have much news
Let´s review Simple Present:
a) Complete with the correct verb
I _study_____ (study) every day.
She __studies____ (study) every day.
They _play_____ (play) soccer.
He __plays____ (play) soccer.
We __watch____ (watch) TV at night.
My mother ___works___ (work) a lot.
b) Make it negative:
I study every day.   - I don´t study every day.
She drinks coffee. - She doesn''t  drink coffee.
He plays soccer. - He doesn''t play soccer.
They watch TV. -  They don''t watch TV.
c) Make it a question:
You study every day. - Do you study every day?
She works a lot. - Does she work a lot?
He drinks coffee. Does he drink coffee?
They play soccer. Do they play soccer?
d) Choose the correct option:
She (play / plays) soccer.
He (drink / drinks) coffee.
They (watch / watches) TV.
My father (work / works) a lot.
I (study / studies) English.
e) Complete with always / usually / sometimes / never
I __usually____ study at night.
She _sometimes_____ drinks coffee.
He _always_____ plays video games.
We __sometimes____ watch TV together.
2.   That is something wrong!
3. Write a test about your routine
R:  I always wake up at 6:30am, I make my coffee and sandwich. I go to work, usually by bike or by bus, I work all day. After work, I study and after that I play games or watch TV, then I go to bed.', 1),
    (imported_lesson_id, 'LINK', '4.', 'https://www.cambridgeenglish.org/learning-english/parents-and-children/activities-for-children/a2-level/f-rw-01-which-number/', 2),
    (imported_lesson_id, 'TEXT', '', 'c-
a-
m-
i-
+-
l-
i-
n-
d-
a-
CODE: cami+linda
…loading
🔓', 3);

  insert into public.lessons (title, lesson_date, created_by, source_reference)
  values ('WH Questions', '2026-06-22'::date, teacher_id, 'digital-notebook:1114')
  on conflict (source_reference) do update
  set title = excluded.title, lesson_date = excluded.lesson_date
  returning id into imported_lesson_id;
  delete from public.lesson_blocks where lesson_id = imported_lesson_id;
  insert into public.lesson_blocks (lesson_id, type, title, content, position) values
    (imported_lesson_id, 'TEXT', 'Identificacao original', '16th class - 06/22/2026', 0),
    (imported_lesson_id, 'TEXT', 'REVIEW NUMBERS', 'REVIEW NUMBERS', 1),
    (imported_lesson_id, 'LINK', '1..', 'https://www.cambridgeenglish.org/learning-english/parents-and-children/activities-for-children/a2-level/f-rw-01-which-number/', 2),
    (imported_lesson_id, 'LINK', '2.', 'https://www.gamestolearnenglish.com/numbers/#game', 3),
    (imported_lesson_id, 'GRAMMAR', 'WH - QUESTIONS', 'São palavras interrogativas usadas para obter informações específicas, exigindo respostas detalhadas, ao invés de sim ou não.
Principais WH - questions:
What? (O quê? / Qual?): Usado para perguntar sobre coisas, ideias ou ações.
Ex: What is your name? (Qual é o seu nome?)
Where? (Onde? / Aonde?): Usado para perguntar sobre lugares ou localizações.
Ex: Where do you live? (Onde você mora?)
When? (Quando?): Usado para perguntar sobre tempo, datas ou momentos.
Ex: When is your birthday? (Quando é seu aniversário?)
Who? (Quem?): Usado para perguntar sobre o sujeito/pessoas.
Ex:Who is your mom?', 4),
    (imported_lesson_id, 'LINK', 'Material externo', 'https://agendaweb.org/exercises/grammar/questions/what-who-when-where.htm', 5),
    (imported_lesson_id, 'LINK', 'Material externo', 'https://agendaweb.org/exercises/grammar/questions/what-where-when-who.htm', 6),
    (imported_lesson_id, 'TEXT', '', 'Now answer 5 the questions from the exercise 2.
1.What is your name ?
My name is João.
2. What is your phone number ?
47992843303
3. Who speaks English here ?
My girlfriend speaks English.
4. Where are you from ?
I am from Blumenau.
5.What is your favourite hobby ?
My favourite hobby is cooking with my girlfriend.', 7);

  insert into public.lessons (title, lesson_date, created_by, source_reference)
  values ('WH Questions - Activities', '2026-07-06'::date, teacher_id, 'digital-notebook:1149')
  on conflict (source_reference) do update
  set title = excluded.title, lesson_date = excluded.lesson_date
  returning id into imported_lesson_id;
  delete from public.lesson_blocks where lesson_id = imported_lesson_id;
  insert into public.lesson_blocks (lesson_id, type, title, content, position) values
    (imported_lesson_id, 'TEXT', 'Identificacao original', '16th class - 07/06/2026', 0),
    (imported_lesson_id, 'TEXT', 'ANSWER:', '1. (USF) A questão abaixo refere-se ao diálogo apresentado a seguir:A: I didn’t pay the billB: _________ not ?C: Because ________ was incorrect
a) which – youb) where – wec) how – theyd) why – ite) who – me
2. (UFSC) A: She didn’t call you yesterday. B: ________ not? C: Because ________ was busy.
a) where – she b) why – she c) when – her d) how – hers e) who – her
3. (PUC) A: ________ did you go last night? B: I went to a party with my friends.
a) What b) Where c) Who d) Why e) How
4. (ENEM) A: ________ is your best friend? B: Julia is.
a) What b) Where c) Who d) Which e) When
5. (FUVEST) A: ________ are you late? B: Because I missed the bus.
a) What b) Who c) Where d) Why e) Which', 1),
    (imported_lesson_id, 'TEXT', 'READING PRACTICE', 'READING PRACTICE', 2),
    (imported_lesson_id, 'TEXT', 'My name is John', 'Hi! Nice to meet you! My name is John Smith. I am 19 and a student in college. I go to college in New York. My favorite courses are Geometry, French, and History. English is my hardest course. My professors are very friendly and smart. It’s my second year in college now. I love it!
I live in a big house on Ivy Street. It’s near the college campus. I share the house with three other students. Their names are Bill, Tony, and Paul. We help each other with homework. On the weekend, we play football together.
I have a younger brother. He just started high school. He is 14 and lives with my parents. They live on Mulberry Street in Boston. Sometimes they visit me in New York. I am happy when they visit. My Mom always brings me sweets and candy when they come. I really miss them, too!
Questão 1:
Where does John Smith go to college?
a Paris
b Boston
c Berlin
d New York
Questão 2:
What is John Smith’s hardest course?
a French
b Art
c English
d Math
Questão 3:
Who shares a house with John Smith?
a Frank, Tony, and Mike
b Anna, Margaret, and Tanya
c Bill, Tony, and Paul
d Bill, John, and Tom
Questão 4:
How old is John Smith’s younger brother?
a eleven
b thirteen
c seven
d fourteen
Questão 5:
What does John Smith’s Mom bring him when they visit?
a Candy and ice cream
b Flowers and coffee
c Fruits and vegetables
d Sweets and candy', 3),
    (imported_lesson_id, 'TEXT', 'LET''S TALK', '-Choose a number between 1-22 and answer.
What is your name? (fácil)
What do you do every day? (médio)
Why do you like English? (difícil)
How are you today? (fácil)
Where do you live? (fácil)
What do you eat for breakfast? (médio)
Who is your best friend? (fácil)
What is your favorite food and why? (difícil)
Where do you study? (médio)
How old are you? (fácil)
What do you do on the weekend? (médio)
Why do you study English? (difícil)
Is your house big? (fácil)
How do you go to school? (médio)
Who do you live with? (médio)
What do you want to be? (difícil)
Are you happy today? (fácil)
Where do you want to go in the future? (difícil)
What do you like to do? (médio)
Who is your favorite person and why? (difícil)
How often do you study English? (difícil)
Is your teacher nice? (fácil )', 4);

  insert into public.lessons (title, lesson_date, created_by, source_reference)
  values ('Revision Activity', '2026-07-19'::date, teacher_id, 'digital-notebook:1223')
  on conflict (source_reference) do update
  set title = excluded.title, lesson_date = excluded.lesson_date
  returning id into imported_lesson_id;
  delete from public.lesson_blocks where lesson_id = imported_lesson_id;
  insert into public.lesson_blocks (lesson_id, type, title, content, position) values
    (imported_lesson_id, 'TEXT', 'Identificacao original', '19/07/2026', 0),
    (imported_lesson_id, 'TEXT', '', 'Atividade de revisão
1- Leia e responda as questões, resposta completa:
My name is Ana. I am 14 years old. I live in Brazil. I study every day. I like pizza. I am very happy.
Perguntas:
1. What is her name?
R:Her name is Ana.
2. How old is she?R: She is 14 years old.
3. Where does she live?R: She lives in Brazil.
4. What does she do every day?
R: She studies every day.
5. How does she feel?
R: She is very happy.
⁠
2- Complete as questões com WH-Questions:
1. _What_ is your name?
2.  _Where_ do you live?
3. _Who_ is your best friend?
4. Why are you late?
5. What__ do you study?
3- Complete as frases com Advérbios de frequência (always/usually/sometimes/never) e depois traduza (?) as frases:
1. I _usually_ drink water in the morning.
2. I _usually_ play video games. (todo dia) - KKKKK
3. I _sometimes_ eat vegetables. (às vezes)
4. I _never_ go to bed late. (nunca)
5. I _usually study English after school.
4- Faça um texto falando sobre seu dia, e depois envie um áudio lendo ou apenas grave um áudio contando sobre seu dia.
My day is go very good! - My day is going very well.
At morning I watched  F1 - In the morning -, then I went to house grandmother for launch. - grandmother´s house for lunch-
The afternoon I watched finish world fifa cup, Manitos are very sad! - In the afternoon I watched the final of the world cup
The night is dedicated is list of English and study IA, after I go play games. - The night will be dedicated to the English list and to study IA, after I will play games.
Gostei, achei que consegui me virar bem até no texto!
(Opção 1 - desenvolve habilidades de escrita e leitura.
Opção 2 - desenvolve habilidades cognitivas para rápido raciocínio)', 1);

  insert into public.lessons (title, lesson_date, created_by, source_reference)
  values ('Rooms Vocabulary', '2026-07-20'::date, teacher_id, 'digital-notebook:1262')
  on conflict (source_reference) do update
  set title = excluded.title, lesson_date = excluded.lesson_date
  returning id into imported_lesson_id;
  delete from public.lesson_blocks where lesson_id = imported_lesson_id;
  insert into public.lesson_blocks (lesson_id, type, title, content, position) values
    (imported_lesson_id, 'TEXT', 'Identificacao original', '17th class - 07/20/2026', 0),
    (imported_lesson_id, 'TEXT', '', '-Correção', 1),
    (imported_lesson_id, 'VOCABULARY', 'NEW VOCABULARY: ROOMS', 'NEW VOCABULARY: ROOMS', 2),
    (imported_lesson_id, 'IMAGE', 'Material visual do caderno', 'image6.png', 3),
    (imported_lesson_id, 'TEXT', '-ANSWER:', 'My House
I live in a big house with my family. In my house, there is a living room, a kitchen, a bathroom, and three bedrooms.
The living room is where my family spends time together. The kitchen is next to the living room. There is also a bathroom in the house.
Upstairs, there are three bedrooms. My parents sleep in one bedroom, and I have my own bedroom. There is another bedroom for guests.
I like my house because it has many rooms. My favorite room is my bedroom.
How many bedrooms are there in the house? - The house has three bedrooms.
What rooms are mentioned in the text? - Living room, kitchen, bathroom,bedroom.
Where is the kitchen? - The kitchen is next to the living room.
Who sleeps in the bedrooms? - In one bedroom my parents, and I have my own bedroom, and another bedroom for guests.
What is the writer’s favorite room? -  My bedroom.', 4);

  insert into public.lessons (title, lesson_date, created_by, source_reference)
  values ('There Is and There Are', '2026-07-27'::date, teacher_id, 'digital-notebook:1284')
  on conflict (source_reference) do update
  set title = excluded.title, lesson_date = excluded.lesson_date
  returning id into imported_lesson_id;
  delete from public.lesson_blocks where lesson_id = imported_lesson_id;
  insert into public.lesson_blocks (lesson_id, type, title, content, position) values
    (imported_lesson_id, 'TEXT', 'Identificacao original', '18th class - 07/27/2026', 0),
    (imported_lesson_id, 'TEXT', '', 'Remember:
Determine os nomes corretos a cada cômodo com as opções abaixo:
Laundry - Home Office - Balcony - Backyard - Garage - Kitchen - Living Room - Front Yard - Bedroom - Dining Room - Bathroom', 1),
    (imported_lesson_id, 'IMAGE', 'Material visual do caderno', 'image1.jpg', 2),
    (imported_lesson_id, 'TEXT', '', '1- bathroom - 2- Bedroom - 3- Home Office - 4- Laundry - 5- Living room - 6- balcony- 7- kitchen- 8- backyard - 9- dining room - 10- front yard - 11-garage', 3),
    (imported_lesson_id, 'GRAMMAR', 'There is and there are', 'There is and there are', 4),
    (imported_lesson_id, 'GRAMMAR', 'There is = há / existe (singular)', 'There is = há / existe (singular)', 5),
    (imported_lesson_id, 'GRAMMAR', 'There are = há / existem (plural)', 'exemplo:There is a kitchen in the house.', 6),
    (imported_lesson_id, 'VOCABULARY', 'There are three rooms in my house.', 'There are three rooms in my house.', 7),
    (imported_lesson_id, 'GRAMMAR', 'There is not = não há/ não existe (singular)', 'There is not = não há/ não existe (singular)', 8),
    (imported_lesson_id, 'GRAMMAR', 'There are not = não há/ não existem (plural)', '(forma curta: isn’t / aren’t)
exemplo: There is not a garage.', 9),
    (imported_lesson_id, 'VOCABULARY', 'There are not two bathrooms.', 'interrogative:Is there a kitchen?
Are there two bedrooms?
Activity
Complete  and translate:
There _is__ a living room.
There _are__ two bedrooms.
There _is__ a bathroom.
There _are__ three rooms in the house.
There _is__ a garden here.
I sleep in the _bedroom_____.
My mom doesn´t let me eat in the _bedroom_____.
We don´t like to share __bathroom_____.
We have two parking spaces in our __garage____.
Kids like to play outside in the __front yard and backyard____.
Describe:', 10),
    (imported_lesson_id, 'IMAGE', 'Material visual do caderno', 'image5.png', 11),
    (imported_lesson_id, 'TEXT', '', 'There are two bedrooms, two bathrooms, a kitchen and a dining room, a living room and a garage, with one parking space. It has a front yard and a backyard.
There are three bedrooms, two bathrooms, a kitchen, a living room, and a dining room. It has only a balcony.
The house has two bedrooms, a living room, one bathroom, a kitchen, a laundry, and front yard and backyard, and one parking space.
The house has three bedrooms, living room, laundry, kitchen, three bathrooms, balcony and one parking space.
Let''s Talk
My dream house
-How many rooms does your dream house have?
-Do you want a balcony?
-Do you want a home office?
-Do you prefer a big backyard or a small backyard?
-What is your favorite room?', 12);

  insert into public.lessons (title, lesson_date, created_by, source_reference)
  values ('Rooms and Home Practice', '2026-08-12'::date, teacher_id, 'digital-notebook:1347')
  on conflict (source_reference) do update
  set title = excluded.title, lesson_date = excluded.lesson_date
  returning id into imported_lesson_id;
  delete from public.lesson_blocks where lesson_id = imported_lesson_id;
  insert into public.lesson_blocks (lesson_id, type, title, content, position) values
    (imported_lesson_id, 'TEXT', 'Identificacao original', 'Class 19th - 08/12/2026', 0),
    (imported_lesson_id, 'TEXT', 'Answer:', '1.Where do you sleep?
I sleep in my bedroom.
2.Where do you cook?
I cook in my kitchen.
3.Where do you work?
I work at Débito Direto, I am a Developer Junior.
4.Where do you watch TV?
I watch TV in the living room or bedroom.
5.Where do you take a shower?
I take a shower in my bathroom.
Comuns activities
Sleep - Dormir
Cook - Cozinhar
Work - Trabalhar
Study - Estudar
Watch TV - Assistir TV
Eat - Comer
Take a shower - Tomar banho
Do the laundry - Lavar as roupas
Park the car - Estacionar o carro
Relax - Relaxar
-Vamos usar a estrutura do simple present para criar frases completas. Formule frases utilizando as palavras sugeridas:
work, home office - I work in the home office.
cook, kitchen - I cook in the kitchen.
sleep, bedroom - I sleep in the bedroom.
relax, living room - I use the living room for relaxing.
park the car, garage - I have a garage for parking the car.
- Fale sobre sua casa em 30 segundos, você pode se preparar escrevendo suas ideias antes para se preparar, para isso você tem 5 minutos.
My house has three bedrooms, two bathrooms, one kitchen, a living room, and a laundry, and we have two parking spaces.
My favorite room is my bedroom, because I can relax, play games, watch TV, study.', 1);

  insert into public.lessons (title, lesson_date, created_by, source_reference)
  values ('Simple Past', '2026-08-17'::date, teacher_id, 'digital-notebook:1383')
  on conflict (source_reference) do update
  set title = excluded.title, lesson_date = excluded.lesson_date
  returning id into imported_lesson_id;
  delete from public.lesson_blocks where lesson_id = imported_lesson_id;
  insert into public.lesson_blocks (lesson_id, type, title, content, position) values
    (imported_lesson_id, 'TEXT', 'Identificacao original', '20TH CLASS - 08/17/2026', 0),
    (imported_lesson_id, 'GRAMMAR', 'Simple past', 'Take a look:
I work from home.
I worked from home yesterday.
I watch TV at night.
I watched TV last night.
I play games on weekends.
I played games last weekend.
Usamos o Simple Past para falar de ações que aconteceram e terminaram no passado.
Palavras que ajudam a identificar:
yesterday
last night
last week
last month
last year
two days ago
in 2025
E para utilizar escrevemos da seguinte estrutura:
Subject + verb in the past + complement
EX: I worked yesterday.
She watched a movie last night.
We visited my parents last weekend.
Verbs - comumente nos verbos em frases do simple present acrescentamos -ed ou -ied ao final dos verbos.
Live - lived; Work - worked; Study - studied; Dance - danced
No entanto temos também os verbos irregulares, estes são os verbos exceção pois não seguem essa mesma regra, eles geralmente mudam a forma de escrever e em alguns casos até permanecem sempre iguais.
Cut - cut; Eat - ate; Go - went; Put - put
Neste conteúdo contaremos com um material auxiliar, que ajudará você a trabalhar com simple past, conforme você for praticando perceberá que cada vez mais o uso dela não será necessário. A tabela ficará numa guia separada, para melhor organização, ela contém muitos verbos mas não todos, por isso nós poderemos acrescentar verbos quando preciso.', 1),
    (imported_lesson_id, 'TEXT', 'ACTIVITY', '-Transforme as frases em simple past, e traduza os verbos:
I watch TV at night.  I watched TV at night.- Assisti
I play video games. I played video games.- Joguei
I clean my room. I cleaned my room. - Limpei
I study English. I studied English. - Estudei
I cook dinner. I cooked dinner. - Cozinhei
I visit my family. I visited my family. -Visitei', 2),
    (imported_lesson_id, 'LINK', 'Material externo', 'https://agendaweb.org/exercises/verbs/past-simple/regular-verbs-write.html', 3),
    (imported_lesson_id, 'LINK', 'Material externo', 'https://agendaweb.org/exercises/verbs/simple-past-irregular-1.htm', 4),
    (imported_lesson_id, 'LINK', 'Material externo', 'https://create.kahoot.it/solo?quizId=d219f0bd-3b97-4aa1-884c-0c97963b3756&gameMode=tapToCollect', 5);

  insert into public.lessons (title, lesson_date, created_by, source_reference)
  values ('English Game Night', '2026-08-20'::date, teacher_id, 'digital-notebook:1430')
  on conflict (source_reference) do update
  set title = excluded.title, lesson_date = excluded.lesson_date
  returning id into imported_lesson_id;
  delete from public.lesson_blocks where lesson_id = imported_lesson_id;
  insert into public.lesson_blocks (lesson_id, type, title, content, position) values
    (imported_lesson_id, 'TEXT', 'Identificacao original', '21st class - 08/20/2026', 0),
    (imported_lesson_id, 'TEXT', 'ENGLISH GAME NIGHT', '1.The alphabet game
2.Hangman
3.Stop
4.Who am I?
5. Gartic', 1);

  insert into public.lessons (title, lesson_date, created_by, source_reference)
  values ('Simple Past Review and Negative', '2026-08-24'::date, teacher_id, 'digital-notebook:1438')
  on conflict (source_reference) do update
  set title = excluded.title, lesson_date = excluded.lesson_date
  returning id into imported_lesson_id;
  delete from public.lesson_blocks where lesson_id = imported_lesson_id;
  insert into public.lesson_blocks (lesson_id, type, title, content, position) values
    (imported_lesson_id, 'TEXT', 'Identificacao original', '22nd class - 08/24/2026', 0),
    (imported_lesson_id, 'TEXT', '', 'Revisão: simple past
1.Complete with the correct form:
I _saw___ her at school yesterday. (See)
She _talked___ with me this morning. (Talk)
We __went__ to the beach on Saturday. (Go)
Peter and Ana _drank___ with me. (Drink)
My little sister __went__ to school for the first time. (Go)
I __started__ at the gym last week. (Start)
He _bought__ a car last month. (Buy)
2.Translate the sentences below:
I saw a blue bird this afternoon.
- Eu vi um pássaro azul à tarde.
She went to Chile with her parents.
- Ela  foi ao Chile com seus pais.
My brother and my sister prepared a surprise for me.
- Meu Irmão e minha irmã prepararam uma surpresa para mim.
My family liked you.
- Minha família gostou de você.
I answered the teacher.
Eu respondi a professora.
We decided to stay home yesterday.
Nós decidimos ficar em casa ontem.
Note: o primeiro verbo já mostra o tempo verbal da frase, então o segundo verbo pode estar com o “to”, com -ing, ou na sua forma normal.
3.(PUC-GO) Complete the following text using the correct past tense conjugation of the verbs in parenthesis in English:
Last night Susan (go) ___went________ to her friend’s birthday party. She (dance) ____danced________ with her boyfriend, and (eat) ____ate________ cake. After they (leave) _______left_____ the party, Susan and her boyfriend (decide) _____decided_______ to go and watch a movie at the theater. They (see) _____saw_______ the new Transformer’s movie, and then they went home. When she (get) _______got_____ home, Susan (take) ____took________ a shower and (fall) ________feel____ quickly asleep.
Choose the correct option from the ones listed below:
a) go/ dance / eat / leave / decide / see / get / take / fall.x- b) went / danced / ate / left / decided / saw / got / took / fell.c) will go / will dance / will eat / will leave / will decide / will see / will get / will take / will fall.d) had gone / had danced / had eaten / had left / had decided / had seen / had gotten / had taken / had fallen.
4.Put the verbs in the correct form and translate:
Eat- Ate - comer
Help- helped - ajuda
Stop- stopped - parar
Talk-  Talked - falar
Dance- danced - dançar
Do-  did - fazer
Learn- Learned - Aprender', 1),
    (imported_lesson_id, 'GRAMMAR', 'Simple Past — Negative', 'Usamos o Simple Past para falar sobre coisas que  aconteceram no passado.', 2),
    (imported_lesson_id, 'TEXT', 'Estrutura:', 'Subject + did not (didn''t) + base verb + complement
Importante: depois de didn''t, o verbo volta para a sua forma base.', 3),
    (imported_lesson_id, 'EXAMPLE', 'Examples:', 'I worked yesterday. → Eu trabalhei ontem.
I didn''t work yesterday. → Eu não trabalhei ontem.
She watched a movie.
She didn''t watch a movie.
We visited our friends.
We didn''t visit our friends.
❌ I didn''t worked yesterday.❌ She didn''t watched a movie.
Depois de didn''t, não usamos o verbo no passado.
✅ I didn''t work yesterday. ✅ She didn''t watch a movie.
Isso acontece porque did já indica que estamos falando sobre o passado.', 4),
    (imported_lesson_id, 'TEXT', 'Forma completa e contraída:', 'did not = forma completa
didn''t = forma contraída, mais comum na conversação
I did not study yesterday. I didn''t study yesterday.', 5),
    (imported_lesson_id, 'TEXT', 'Com verbos irregulares', 'A regra é a mesma:
I went to work. → I didn''t go to work.
She ate pizza. → She didn''t eat pizza.
They had dinner. → They didn''t have dinner.
Regra principal para lembrar:', 6),
    (imported_lesson_id, 'TEXT', 'DIDN''T + BASE VERB', 'DIDN''T + BASE VERB', 7),
    (imported_lesson_id, 'TEXT', 'LIST OF ACTIVITY - HOMEWORK', 'LIST OF ACTIVITY - HOMEWORK', 8),
    (imported_lesson_id, 'GRAMMAR', 'Simple Past & Simple Past Negative', 'Simple Past & Simple Past Negative', 9),
    (imported_lesson_id, 'TEXT', 'Activity 1 — Complete the sentences', 'Complete the sentences with the correct form of the verb.
Yesterday, I worked (work) all day.
She __watched______ (watch) a movie last night.
We ___visited_____ (visit) our friends last weekend.
He didn''t__play_____ (not/play) video games yesterday.
They _didn`t_cook__ (not/cook) dinner last night.
I ___didn''t_ study____ (not/study) English yesterday.', 10),
    (imported_lesson_id, 'TEXT', 'Activity 2 — Correct the mistakes', 'Find and correct the mistakes.
I didn''t watch TV last night.
She didn''t worked yesterday. - work
We didn''t visited our grandparents.- visit
He didn''t played soccer. - play
They didn''t cooked dinner.- cook', 11),
    (imported_lesson_id, 'TEXT', 'Activity 3 — Make it negative', 'Rewrite the sentences in the negative form.', 12),
    (imported_lesson_id, 'EXAMPLE', 'Example: She watched a movie. → She didn''t watch a movie.', 'I worked yesterday. I didn´t work yesterday.
He played video games. He didn´t play video games
We visited our family. We didn´t visit our family.
They cooked dinner. They didn´t cook dinner
She studied English. She didn''t study English.
Activity 4 — Put the words in order
Put the words in the correct order.
yesterday / worked / I / from home - I worked from home yesterday.
didn''t / last night / watch / she / TV - She didn´t watch TV last night.
our friends / visited / we / last weekend - We visited our friends last weekend.
didn''t / he / yesterday / study - He didn''t study yesterday.
dinner / they / didn''t / cook - They didn´t cook dinner', 13),
    (imported_lesson_id, 'TEXT', 'Activity 5 — About you', 'Write 6 sentences about your last weekend:
3 things you did
I did  one cockpit for play games.
I ride in a car on Sunday.
I ate pizza on Saturday.
3 things you didn''t do
I didn''t  go to church. :<
I didn´t wash my car.
I didn''t see my girlfriend.
Use at least 3 different time expressions, such as:
yesterday • last night • last weekend • two days ago', 14),
    (imported_lesson_id, 'EXAMPLE', 'Example:', 'Last Saturday, I worked in the morning. I watched a movie at night. I didn''t go out with my friends.
1 -  Yesterday I didn´t get to wash my car.
2 - I drank Monster Energy last night.
3 - I was with my girlfriend last weekend', 15);

  insert into public.lessons (title, lesson_date, created_by, source_reference)
  values ('Simple Past - Questions', '2026-09-02'::date, teacher_id, 'digital-notebook:1556')
  on conflict (source_reference) do update
  set title = excluded.title, lesson_date = excluded.lesson_date
  returning id into imported_lesson_id;
  delete from public.lesson_blocks where lesson_id = imported_lesson_id;
  insert into public.lesson_blocks (lesson_id, type, title, content, position) values
    (imported_lesson_id, 'TEXT', 'Identificacao original', '23rd class - 09/02/2026', 0),
    (imported_lesson_id, 'GRAMMAR', 'SIMPLE PAST QUESTION', 'No passado, usamos DID para fazer perguntas.
Estrutura:
Did + subject + verb (base form) + complement?
Importante: depois de did, o verbo volta para a forma normal.', 1),
    (imported_lesson_id, 'EXAMPLE', 'Examples:', 'Did you work yesterday?
Did she study English?
Did they travel last weekend?
Did he play soccer?
❌ Did you worked yesterday? ✅ Did you work yesterday?', 2),
    (imported_lesson_id, 'TEXT', 'Short answers', 'Yes:
Yes, I did.
Yes, he did.
Yes, she did.
Yes, they did.
No:
No, I didn''t.
No, he didn''t.
No, she didn''t.
No, they didn''t.', 3),
    (imported_lesson_id, 'TEXT', 'ACTIVITY', '1. Complete com did e o verbo entre parênteses.
__Did____ you _work_____ (work) yesterday?
__Did____ she ___watch___ (watch) TV last night?
__Did____ they ___travel___ (travel) last weekend?
__Did____ he ____play__ (play) soccer?
__Did____ you ____cook__ (cook) dinner?
__Did____ your parents __visit____ (visit) you?
2. Transforme as frases afirmativas em perguntas.', 4),
    (imported_lesson_id, 'EXAMPLE', 'Example:', 'You watched a movie. → Did you watch a movie?
You worked yesterday. - Did you work yesterday?
She studied English. - Did she study English?
They visited their friends. Did they visit their friends?
He played video games. Did he play video games?
You cleaned your room.  Did you clean your room?
3. Answer with Yes, I did / No, I didn''t.
Did you work yesterday? - Yes, I worked yesterday.
Did you wake up early yesterday? Yes, I woke up early yesterday.
Did you use your computer yesterday? Yes, I used my computer yesterday.
Did you watch a movie last week? Yes, I watched a movie last week.
Did you cook something last weekend? No, I didn''t cook anything last weekend.
Did you go out last weekend? Yes, I went out last weekend.
Did you study English yesterday? No, I didn´t study English yesterday.
Did you play any games this week? Yes, I played some games.
Positive → something
Question → anything
Negative → anything', 5),
    (imported_lesson_id, 'TEXT', 'Something × Any — regra resumida', '✅ Afirmativa: something / some I played some games.
❓ Pergunta: anything / any Did you play any games?
❌ Negativa: anything / any I didn''t play any games.
👉 Resumo: Positive → SOME Question → ANY Negative → ANY', 6),
    (imported_lesson_id, 'LINK', '4.', 'https://www.elllo.org/class/A1/A1-23-Past-Tense.html', 7),
    (imported_lesson_id, 'TEXT', '', 'tradução', 8),
    (imported_lesson_id, 'TEXT', 'Conversa 1', 'Homem: O que você fez ontem?Mulher: Nada demais. Eu só fiquei em casa e limpei a casa.Homem: Que tédio!Mulher: É, foi mesmo. E você? O que você fez?Homem: Eu dirigi até as montanhas e fiz uma trilha.Mulher: Parece divertido!Homem: Foi. Eu me diverti muito.', 9),
    (imported_lesson_id, 'TEXT', 'Conversa 2', 'Homem: Você fez alguma coisa neste fim de semana?Mulher: Fiz. Peguei o trem para a cidade e encontrei minha amiga.Homem: Ah, é? O que vocês fizeram?Mulher: Nós almoçamos e fomos fazer compras.Homem: Você comprou alguma coisa?Mulher: Não, não comprei. Eu só fui olhar as vitrines. Estou tentando economizar dinheiro.Homem: Eu também!', 10),
    (imported_lesson_id, 'TEXT', 'Conversa 3', 'Homem: Como foi o seu dia?Mulher: Terrível. Eu estava muito ocupada.Homem: Ah, que pena.Mulher: É, nós estávamos muito ocupados na hora do almoço. Uma pessoa ligou dizendo que estava doente, então estávamos com poucos funcionários.Homem: Isso não é bom. Como vocês conseguiram dar conta?Mulher: O chefe veio e nos ajudou.', 11),
    (imported_lesson_id, 'TEXT', 'Conversa 4', 'Homem: Você falou com o Bob?Mulher: Falei. Ele disse que estava arrependido.Homem: O que ele disse?Mulher: Ele disse que não teve a intenção de ficar bravo com você.Homem: Bom, mas ele ficou. Ele me fez chorar.Mulher: Eu sei. Mas ele está realmente arrependido por isso.', 12);

  insert into public.lessons (title, lesson_date, created_by, source_reference)
  values ('Date Ideas', '2026-09-09'::date, teacher_id, 'digital-notebook:1637')
  on conflict (source_reference) do update
  set title = excluded.title, lesson_date = excluded.lesson_date
  returning id into imported_lesson_id;
  delete from public.lesson_blocks where lesson_id = imported_lesson_id;
  insert into public.lesson_blocks (lesson_id, type, title, content, position) values
    (imported_lesson_id, 'TEXT', 'Identificacao original', '23rd class - 09/09/2026', 0),
    (imported_lesson_id, 'TEXT', 'Class: Dates Ideas', 'Class: Dates Ideas', 1),
    (imported_lesson_id, 'TEXT', '1. WARM-UP 💬', '1. WARM-UP 💬', 2),
    (imported_lesson_id, 'TEXT', 'Answer the questions:', 'What is your favorite type of date?
Do you prefer going out or staying at home?
What is a good date for you?When we really can enjoy and without cell phone
What was your favorite date?The second time we went to Florianopólis and when we went out together with the new car.
What date would you like to have? A complete day doing different things, like trail.', 3),
    (imported_lesson_id, 'VOCABULARY', '2. DATE VOCABULARY 💕', '2. DATE VOCABULARY 💕', 4),
    (imported_lesson_id, 'TEXT', '🍔 FOOD DATES', 'Homemade Burger Night — Noite do hambúrguer caseiro
Pizza Night — Noite da pizza
Ice Cream Date — Date de sorvete
Picnic — Piquenique
Breakfast for Dinner — Café da manhã no jantar
Cook Together — Cozinhar juntos
Try a New Restaurant — Experimentar um restaurante novo', 5),
    (imported_lesson_id, 'TEXT', '🎬 AT-HOME DATES', 'Movie Night — Noite de filme
Game Night — Noite de jogos
Karaoke Night — Noite de karaokê
Board Game Night — Noite de jogos de tabuleiro
Paint Together — Pintar juntos
Cook a New Recipe — Fazer uma receita nova
Series Marathon — Maratona de séries', 6),
    (imported_lesson_id, 'TEXT', '🌙 GOING OUT', 'Sunset/Sunrise Date — Date no pôr do sol/nascer do sol
Night Drive — Passeio de carro à noite
Go for a Walk — Dar uma caminhada
Stargazing — Observar as estrelas
Explore a New Place — Explorar um lugar novo
Bookstore Date — Date em uma livraria
Tourist Day — Dia de turista', 7),
    (imported_lesson_id, 'TEXT', '😂 DIFFERENT DATES', '$10 Date — Date de R$10
Blind Taste Test — Teste de sabor vendado
Recreate Our First Date — Recriar nosso primeiro date
Childhood Games Night — Noite de brincadeiras da infância
Pick Each Other''s Outfit — Escolher a roupa um do outro
Random Destination Date — Date com destino aleatório', 8);

  insert into public.lessons (title, lesson_date, created_by, source_reference)
  values ('Would Like and English Level Assessment', '2026-09-17'::date, teacher_id, 'digital-notebook:1680')
  on conflict (source_reference) do update
  set title = excluded.title, lesson_date = excluded.lesson_date
  returning id into imported_lesson_id;
  delete from public.lesson_blocks where lesson_id = imported_lesson_id;
  insert into public.lesson_blocks (lesson_id, type, title, content, position) values
    (imported_lesson_id, 'TEXT', 'Identificacao original', '23rd class - 09/17/2026', 0),
    (imported_lesson_id, 'GRAMMAR', '1. GRAMMAR — WOULD LIKE', 'We use would like to talk about something we would like to have or do.
Would like = gostaria de', 1),
    (imported_lesson_id, 'TEXT', 'AFFIRMATIVE', 'Subject + would like + ...
I would like a pizza.Eu gostaria de uma pizza.
I would like to go out.Eu gostaria de sair.', 2),
    (imported_lesson_id, 'TEXT', 'CONTRACTIONS', 'I would → I''d
You would → You''d
He would → He''d
She would → She''d
We would → We''d
They would → They''d', 3),
    (imported_lesson_id, 'EXAMPLE', 'Examples:', 'I''d like a pizza.
I''d like to go out.
We''d like to watch a movie.', 4),
    (imported_lesson_id, 'TEXT', '2. WOULD YOU LIKE...? 💬', 'We use Would you like...? to ask if someone would like something.', 5),
    (imported_lesson_id, 'TEXT', 'WITH A NOUN:', 'Would you like + noun?
Would you like a pizza?
Would you like some ice cream?', 6),
    (imported_lesson_id, 'TEXT', 'WITH AN ACTIVITY:', 'Would you like + to + verb?
Would you like to watch a movie?
Would you like to go for a walk?
Would you like to have a picnic?
Would you like to try a new restaurant?', 7),
    (imported_lesson_id, 'TEXT', '3. ANSWERS', '3. ANSWERS', 8),
    (imported_lesson_id, 'TEXT', '✅ YES', 'Yes, I would.
Yes, I''d love to!
Sure!', 9),
    (imported_lesson_id, 'TEXT', '❌ NO', 'No, I wouldn''t.
Not really.', 10),
    (imported_lesson_id, 'EXAMPLE', 'Examples:', 'Would you like to have a picnic?
Yes, I''d love to!', 11),
    (imported_lesson_id, 'TEXT', '4. COMPLETE THE SENTENCES ✏️', 'Complete with would or to.
I __would____ like to watch a movie.
Would you like ___to___ go for a walk?
I ___would___ like a pizza.
Would you like __to____ have a picnic?
We ___would___ like to try a new restaurant.
Would you like ___to___ play a board game?', 12),
    (imported_lesson_id, 'TEXT', '5. CREATE THE QUESTIONS 💬', 'Put the words in the correct order.
like / Would / to / watch / you / a movie? - Would  you like to watch a movie?
you / Would / go / like / to / out? - Would you like to go out?
like / Would / have / you / to / a picnic? Would you like to have a picnic?
try / Would / like / you / to / a new restaurant? Would you like to try a new restaurant?', 13),
    (imported_lesson_id, 'TEXT', '6. WHAT WOULD YOU CHOOSE? 🎯', 'Choose one option and answer the question.', 14),
    (imported_lesson_id, 'TEXT', '1.', '🍔 Homemade Burger Night🎬 Movie Night
Which one would you like?
I''d like to _have_both at the _same night.__________________________.', 15),
    (imported_lesson_id, 'TEXT', '2.', '🌅 Sunset Date🎲 Game Night
Which one would you like?
I''d like to _ have a _game night____________________________.', 16),
    (imported_lesson_id, 'TEXT', '3.', '🍦 Ice Cream Date🍕 Pizza Night
Which one would you like?
I''d like to ___have a pizza night___________________________.', 17),
    (imported_lesson_id, 'TEXT', '4.', '🚗 Night Drive🌳 Picnic
Which one would you like?
I''d like to ____have a picnic__________________________.', 18),
    (imported_lesson_id, 'TEXT', '7. LET''S... 💡', 'Let''s + verb is used to make a suggestion.
Let''s watch a movie.
Let''s cook together.
Let''s go for a walk.
Let''s have a picnic.', 19),
    (imported_lesson_id, 'TEXT', 'Compare:', 'Would you like to watch a movie?Você gostaria de assistir a um filme?
Yes! Let''s watch a movie!Sim! Vamos assistir a um filme!', 20),
    (imported_lesson_id, 'TEXT', '8. MAKE A SUGGESTION', 'Use Let''s... to complete the sentences.
We have a movie night.
→ Let''s have a movie night_____________________________.
We go for a walk.
→ Let''s __walk____________________________.
We cook together.
→ Let''s ___cook together___________________________.
We have a picnic.
→ Let''s have a picninc____________________________.
We play a board game.
→ Let''s __play a board game____________________________.', 21),
    (imported_lesson_id, 'TEXT', '9. 💕 OUR DATE BOARD', 'Now we''re going to create OUR DATE BOARD.
Choose the dates you would like to include.
For each option, ask:
Would you like to add this to our Date Board?', 22),
    (imported_lesson_id, 'TEXT', 'Answer:', 'Yes, I''d love to!
or
No, I wouldn''t.
If you choose it: Let''s add it!', 23),
    (imported_lesson_id, 'TEXT', 'DATE BOARD', 'DATE BOARD', 24),
    (imported_lesson_id, 'LINK', 'Material externo', 'https://gartic.io/022k5bDc', 25),
    (imported_lesson_id, 'TEXT', 'HOMEWORK🏠', 'HOMEWORK🏠', 26),
    (imported_lesson_id, 'TEXT', 'Create 5 date suggestions.', 'Write five questions using Would you like to...?
Would you like to __________________________?
Would you like to __________________________?
Would you like to __________________________?
Would you like to __________________________?
Would you like to __________________________?', 27),
    (imported_lesson_id, 'TEXT', 'Now choose your favorite:', 'I''d like to __________________________________ because __________________________________.', 28),
    (imported_lesson_id, 'TEXT', 'ENGLISH LEVEL ASSESSMENT', 'Student: João ArthurDate: ____ / ____ / ______Score: ______ / 100', 29),
    (imported_lesson_id, 'GRAMMAR', 'PART 1 — GRAMMAR: SIMPLE PRESENT', '10 points — 1 point each', 30),
    (imported_lesson_id, 'TEXT', 'A. Complete the sentences with the correct form of the verbs in parentheses.', 'He __works________ (work) with computers.
I _____study_____ (study) English every week.
She ______not live____ (not/live) in the city.
My brother ______play____ (play) video games after work.
They _____not speak_____ (not/speak) French.', 31),
    (imported_lesson_id, 'TEXT', 'B. Choose the correct alternative.', '_____Does_____ he work on Saturdays?a) Dob) Doesc) Is
My father ____goes______ to work every morning.a) gob) goesc) going
She doesn''t ___like_______ coffee.a) likesb) likec) liking
We ____study______ English online.a) studiesb) studyc) studying
_____Are_____ they live together?a) Doesb) Arec) Do', 32),
    (imported_lesson_id, 'TEXT', 'PART 2 — NEGATIVE SENTENCES AND QUESTIONS', '10 points — 2 points each
Rewrite the sentences according to the instructions.
He works every day.Make it negative: He doesn’t work every day.
They play video games at night.Make it negative: They don''t play video games at night.
She likes programming.Make it a question:  Likes she programming?
You speak English at work.Make it a question: Speak you English at work?
He studies in the morning.Make it negative: He doesn’t study in the morning.', 33),
    (imported_lesson_id, 'TEXT', 'PART 3 — POSSESSIVES', '10 points — 2 points each', 34),
    (imported_lesson_id, 'TEXT', 'A. Rewrite the sentences using the possessive ''s.', 'The computer of João. João’s computer;
The car of my father. - Father’s car.
The bedroom of my sister. Sister’s bedroom.
The phone of my girlfriend. Girlfriend’s phone.
The house of my parents. Parent’s house.', 35),
    (imported_lesson_id, 'GRAMMAR', 'PART 4 — THERE IS / THERE ARE', '10 points — 1 point each
Complete the sentences with there is, there are, there isn''t or there aren''t.
_There is_____ a computer in my home office.
_There are___ two bedrooms in my house.
_There isn’t___ a garage in my apartment.
_There aren’t___ any chairs in the kitchen.
_There is_____ a bathroom next to the bedroom.
_There are____ three people in the living room.
_There is___ a garden behind the house.
_There aren’t___ any windows in this room.
_There is__ a table in the dining room.
_There are___ two cars in the garage.', 36),
    (imported_lesson_id, 'VOCABULARY', 'PART 5 — VOCABULARY', '10 points — 1 point each', 37),
    (imported_lesson_id, 'TEXT', 'A. Match the English words to their meanings.', 'Write the correct letter next to each word.
(__b_) Bedroom
(_a_) Backyard
(_c_) Laundry
(_e_) Dining room
(_d_) Balcony
a) Área externa nos fundos da casab) Quartoc) Área para lavar roupas ou lavanderiad) Sacada ou varandae) Sala de jantar', 38),
    (imported_lesson_id, 'TEXT', 'B. Complete the sentences with the correct words.', 'Use: sleep, asleep, speak, talk, short-staffed
I usually ______sleep____ seven hours a night.
The baby is ___asleep_______. Please be quiet.
I can ___talk_______ English and Portuguese.
We need to ____speak______ about our plans for the weekend.
The restaurant is ____short-staffed______ today. There aren''t enough employees.', 39),
    (imported_lesson_id, 'GRAMMAR', 'PART 6 — SIMPLE PAST: AFFIRMATIVE', '10 points — 1 point each
Complete the sentences using the Simple Past form of the verbs in parentheses.
Yesterday, I ____worked______ (work) until 6 p.m.
He ___went_______ (go) to the supermarket.
We ____watched______ (watch) a movie last night.
She ___had______ (have) lunch with her family.
They _____played_____ (play) video games yesterday.
I ____saw______ (see) my friends on Saturday.
He ____studied______ (study) English last night.
We ____ate______ (eat) pizza for dinner.
She ___bought_______ (buy) a new phone last month.
I _____wrote_____ (write) an email yesterday.', 40),
    (imported_lesson_id, 'GRAMMAR', 'PART 7 — SIMPLE PAST: NEGATIVE AND QUESTIONS', '10 points — 2 points each', 41),
    (imported_lesson_id, 'TEXT', 'A. Rewrite the sentences.', 'He worked yesterday.Make it negative:  He didn’t work yesterday
They went to the park.Make it negative: They didn’t went to the park.
She watched a movie last night.Make it a question: Did she watch a movie last night?
You studied English yesterday.Make it a question: Did you study English yesterday?
He bought a new computer.Make it negative: He didn’t bought a new computer.', 42),
    (imported_lesson_id, 'TEXT', 'PART 8 — READING COMPREHENSION', '10 points
Read the text carefully.', 43),
    (imported_lesson_id, 'TEXT', 'A Busy Weekend', 'Lucas works with computers during the week. He usually wakes up at 7 a.m. and starts working at 8 a.m. He enjoys his job, but sometimes he feels tired because he has many tasks to complete.
Last Saturday, Lucas didn''t work. He woke up late and had breakfast with his girlfriend. After breakfast, they went shopping. His girlfriend wanted to buy some clothes, but Lucas didn''t buy anything because he was only interested in window shopping.
In the afternoon, they visited his parents. His mother prepared lunch, and his father talked about his new car. In the evening, Lucas stayed home, played video games, and watched a movie.
On Sunday, he studied English for an hour because he wants to improve his communication skills.', 44),
    (imported_lesson_id, 'TEXT', 'Answer the questions in English.', 'What does Lucas do during the week? - Lucas works with computers during the week.
What time does he usually start working? - 8 a.m
Did Lucas work last Saturday? -  Not.
What did Lucas and his girlfriend do after breakfast? - they went shopping.
Why didn''t Lucas buy anything? -  because he was only interested in window shopping.
Who did Lucas visit in the afternoon? -,they visited his parents.
What did Lucas do in the evening? - Lucas stayed home, played video games, and watched a movie.
How long did he study English on Sunday? One hour.
Find a word or expression in the text that means "olhar vitrines sem necessariamente comprar".interested in window shopping.
Why does Lucas study English?
because he wants to improve his communication skills.', 45),
    (imported_lesson_id, 'TEXT', 'PART 9 — WRITING', '10 points', 46),
    (imported_lesson_id, 'TEXT', 'Write about your life and your last weekend.', 'Write 8–10 sentences in English.
You can use these questions to help you:
What do you do during the week?
What time do you wake up?
What do you do at work?
Who do you live with?
What did you do last weekend?
Did you go anywhere?
What did you eat?
Did you study English?
What didn''t you do?
My text:', 47),
    (imported_lesson_id, 'TEXT', 'END OF TEST', 'Please review your answers before submitting the test.', 48);
end;
$$;
commit;
