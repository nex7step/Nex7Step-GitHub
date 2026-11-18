# Painel admin: passo a passo (uma vez só)

1. Crie um projeto grátis em supabase.com.
2. **SQL Editor > New query**: cole todo o `supabase/schema.sql` e clique em Run. Isso cria as tabelas, as regras de segurança, o bucket de imagens e cadastra os 14 produtos atuais.
3. **Authentication > Providers > Email**: desligue "Allow new users to sign up" (ninguém de fora cria conta).
4. **Authentication > Users > Add user**: crie os 2 admins (e-mail + senha, marque "Auto Confirm").
5. No SQL Editor rode (com os e-mails reais):
   `insert into admins (user_id) select id from auth.users where email in ('admin1@exemplo.com','admin2@exemplo.com');`
6. **Project Settings > API Keys**: copie a *Publishable key* (`sb_publishable_...`) para `js/config.js`, no campo `anon`. A *Project URL* fica no botão **Connect** (topo) ou em Settings > General (formato `https://xxxx.supabase.co`). **Nunca** use a Secret key no site.
7. Publique o site (GitHub Pages ou Vercel). O painel fica em `/admin/`.

Segurança: só quem está na tabela `admins` consegue criar, editar ou apagar. A chave anon é pública por natureza e pode ficar no código.
Se o banco ficar fora do ar, `produtos.html` mostra a lista de reserva embutida na página.
