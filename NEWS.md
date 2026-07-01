# dbinterface 0.10.0

## Breaking changes

- Removidas as funcoes `conectabanco`, `registra_credenciais`, `registra_banco`, `lista_credenciais`, `lista_bancos` — toda a superficie de cache de credenciais foi descartada junto com o suporte a bancos relacionais.
- `parsearg` (e todos os metodos `parsearg.campo_*`) nao recebem mais o argumento
  `is_mock`; o caminho de query estruturada agora e o unico caminho ativo.
- `conectamorgana` agora levanta erro enquanto a API morgana permanece offline.
  A chamada falha com a mensagem `"Servico morgana atualmente indisponivel -- API offline"`.

## Bug fixes

- Corrige inconsistencia entre o atributo `reader_fun` esperado em `le_tabela_mock`
  e o atributo `reader_func` produzido por `new_tabela`. O nome canonico passa a
  ser `reader_func` em ambos os lados.
- Reformula executoras de query para funcionar corretamente quando lidando com arquivos rds que nao
  contem dados tabulares (ex modelos ajustados)

## Misc

- `DBI` e `RPostgreSQL` removidos de `Suggests`; o pacote nao depende mais de
  bancos relacionais.
- Representacao interna de query agora e estruturada: `SELECT` e um vetor de
  caracteres e `WHERE` e uma lista de objetos `language`. A serializacao para
  string SQL foi removida do caminho principal.
- Funcoes internas do caminho morgana (`roda_query.morgana`, `collate_query`,
  `decode_output`) foram preservadas no codigo-fonte para reativacao futura —
  veja o playbook abaixo.

### Playbook de reanimacao do morgana

Quando a API morgana voltar a estar disponivel, a reativacao do conector
requer dois passos: (1) remover a chamada a `stop()` no topo do corpo de
`conectamorgana` (a logica preservada abaixo do `stop()` ja prepara o objeto
de conexao); e (2) re-conectar o caminho de query estruturada a serializacao
SQL esperada por `roda_query.morgana`. O passo (2) pode ser feito de duas
formas: reintroduzir um ramo `is_mock` nos metodos `parsearg.*`, ou escrever
uma funcao auxiliar `expr2sql` que `roda_query.morgana` chame no lugar de
`collate_query`. A logica original de serializacao SQL esta preservada no
historico do git e pode ser reintroduzida como helper independente.

# dbinterface 0.9

## New features

- Add suporte a leitura de arquivos `.rds`
- Add script `funcoes-escrita.r` com o backend necessario para implementacao de escrita de dados

# dbinterface 0.8.2

## Bug fixes

- Corrige erro em leitura de parquets gerados abstratamente. Aparentemente parquets gerados pelo R
  guardam seus atributos de R originais, de modo que a leitura de um `data.table` salvo como parquet
  volta como `data.table`.
  `proc_query_mock_spart` contava com trabalhar em `data.tables` sem realizar a verificacao, que foi
  agora adicionada

# dbinterface 0.8.1

## New features

- Leitura de tabelas mock em `parquet.gzip` agora e realizada por _lazy loading_, economizando tempo
  e memoria na manipulacao de grandes datasets nao particionados

## Misc

- Tira checks de CI para Windows e Mac; só se testa Ubuntu agora
- Dependencias para conexao com banco relacional passam para `Suggests`; toda essa parte da
  funcionalidade agora e opcional
- Argumentos de subset em `getfromdb` que nao correspondem a campos tabela sendo acessada nao mais
  causam erro. Estes agora sao ignorados no processamento de `parseargs`

# dbinterface 0.7

## New features

- Foi adicionada a opcao de conexao com mocks no S3 como cliente do morgana atraves do conector
  `conectamorgana`

## Misc

- Suporte a bancos relacionais padrao foi, por hora, deprecado
- Funcoes antigas do pacote, tailor-made para o banco original, foram deprecadas e removidas
- Modifica padrao de estrutura dos bancos mock. Agora e necessario respeitar determinada hierarquia
  de diretorios e providenciar um arquivo schema.json especificando o banco e tabelas individuais
- Tambem foi modificado o padrao de particionamento. Nao sera mais usada uma tabela mestra, como
  anteriormente; esta informacao agora faz parte da chave `partitions` do schema.json da tabela
- Conjunto de dados teste atualizado para o novo padrao
- Essencialmente todo o backend do pacote foi reestruturado e reorganizado de maneira mais coerente
- A testagem foi refeita inteiramente do zero, estando agora muito mais robusta e confiavel

# dbinterface 0.6

## Bug fixes

- `conectabucket` dava erro em repos particionados pois a identificacao do tipo de arquivos
  olhava para o JSON, erroneamente. Isso foi corrigido

## Misc

- Toda a representacao de tabelas e a forma como argumentos de query sao interpretados para composicao
  das strings de query foi reformulada. Agora e possivel utilizar o backend de `dbinterface` para
  conexao com bancos de estrutura arbitraria. A seguir sao dados mais detalhes
- Foram incluidas duas novas classes: `tabela` e `campo`
  - `tabela`s sao representacoes simbolicas das tabelas no banco, sendo compostas por uma lista detalhando
    quais colunas (campos) constam naquela tabela
  - similarmente, `campo` e uma classe para detalhar as caracteristicas de cada coluna que compoe uma
    tabela, incluindo a possibilidade de queries por chaves estrangeiras passando por proxys
- O parse de argumentos para query foi reformulado para lidar com os objetos `campo` genericos
- Uma nova funcao de baixo nivel `getfromtabela` foi introduzida, permitindo interface para leitura
  com quaisquer tabelas em bancos arbitrarios

# dbinterface 0.5

## New features

- Bancos mock locais passam a demandar a presenca de um arquivo `.PARTICAO.json` detalhando quais
  tabelas do banco sao particionadas. A identificacao de particao passa a ser feita usando este
  diretorio ao inves de listar os arquivos na pasta, que pode ser muito lento. Dois novos atributos
  foram adicionados aos objetos `local`:
  - `tempart`: booleano indicando se pelo menos uma das tabelas possui particao
  - `particoes`: vetor logico indicando quais tabelas sao particionadas
- Adiciona suporte a leitura de arquivos parquet em bancos mock locais
- Adicionado conector a buckets S3 na AWS. Esta funcionalidade e essencialmente igual a conexao com
  bancos mock locais, apenas lendo arquivos do bucket ao inves de um diretorio local
- Conectores a bancos mock (local ou bucket S3) passam a ter mais um atributo:
  - `reader_fun`: funcao dedicada de leitura, pois varia dependendo do tipo de arquivo e fonte
    (local ou bucket)
- Conectores a bancos mock passaram a receber mais um argumento `extensao`. Isto permite que as
  extensoes de arquivos em banco mock ja sejam informadas a priori, sem perder tempo identificando
  na hora

## Misc

- Muda conectores para um arquivo proprio `R/misc.r -> R/conectores.r`

# dbinterface 0.4

## New features

- Conexao local agora suporta arquivamentos com particao. A implementacao de particionamento em
  diretorios e similar aquela de bancos, porem com algumas especificicidades. Ver `?conectalocal`
  para mais detalhes

## Misc

- A capitalizacao automatica de `usinas` e `modelos` foi retirada, sendo agora necessario que o
  usuario informe codigos de usinas e nomes de modelos em letras maiusculas, tal qual estes nomes
  estao salvos no banco

# dbinterface 0.3.2

## Bug fixes

- Corrige bug de query de usinas quando o codigo continha a string "IN". Dentro da adequacao para
  query em dados locais isto estava sendo substituido para "%in%" e retornando resultados errados

# dbinterface 0.3.1

## Bug fixes

- Corrige problema no teste de `parsedatas` em sistemas operacionais linux
- Passa a exportar `conectalocal`

# dbinterface 0.3

## New features

- Adiciona suporte ao pacote para leitura da tabela de ventos de reanalise
- Adiciona suporte a "archives" locais, isto e, um diretorio com estrutura similar a de um banco,
  porem cujas tabelas sao arquivos csv

## Bug fixes

- Corrige o erro nas queries em 2017 e 2018. Esse problema se dava na conversao de horarios de
  virada de horario de verao, pois meia noite e meia noite e meia "nao existem". Foi introduzida
  uma funcao para execucao das queries que controla o tz da coluna de datas para evitar o erro.

# dbinterface 0.2

## New features

- Adapta funcoes `getverificado` e `getprevisto` para o novo schema do banco
- `parsedatas` ganha argumento `query`, um booleano indicando se deve ser retornada a query ou
  apenas as datas expandidas
- Adiciona funcoes `getusinas` e `getmodelos` para pegar informacoes qualitativas a respeito das
  usinas e modelos de previsao meteorologica presentes no banco

# dbinterface 0.1

Este pacote contem funcoes para facilitacao do acesso aos bancos de dados associados a area de
energias renovaveis da PEM. Isto inclui acesso, escrita e resgate de informacoes acerca dos bancos
disponiveis.
