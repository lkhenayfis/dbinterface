################################# FUNCOES GERAIS USADAS NO PACOTE ##################################

#' Conexao Com Mock Bancos
#' 
#' Gera a conexao com um mock banco, correspondente a um diretorio local ou s3
#' 
#' Os bancos mock de \code{dbinterface} correspondem a arquivos de dados, em `csv` ou `parquet`, em
#' diretorios locais ou buckets no s3 dentro. Para correto funcionamento desta implementacao se 
#' espera uma certa estrutura de arquivos e diretorios de tal modo que o pacote consiga encontrar
#' os dados relevantes. Recomenda-se ler a vignette
#' `vignette("estrutura-mock", package = "dbinterface")` para maiores detalhes a respeito desta
#' estrutura de mock banco.
#' 
#' A conexao com bancos mock possui apenas um argumento de entrada: `schema`. Este e ou o caminho a
#' um arquivo json explicitando a estrutura geral do banco ou uma lista contendo o este json ja 
#' lido (a estrutura de schema.json se encontra detalhada na vignette supracitada). O schema de 
#' pode conter uma chave opcional \code{uri}. Ela e opcional pois so seria utilizada no caso das
#' \code{uri} das tabelas serem caminhos relativos. Caso \code{schema} seja passado como um caminho
#' e o json lido nao possua essa chave, sera adicionada como igual ao caminho \code{schema}.
#' 
#' @param schema lista contendo o schema do banco, correspondente aos conteudos de um arquivo
#'     \code{schema.json} para banco, ou o caminho de um arquivo deste tipo ou diretorio que o 
#'     contenha. Veja Detalhes
#' 
#' @examples
#'
#' arq_schema <- system.file("extdata/cpart_parquet/schema.json", package = "dbinterface")
#' conn <- conectamock(arq_schema)
#'
#' @return objeto de conexao com o mock banco
#'
#' @export

conectamock <- function(schema) new_mock(schema)

#' Conexao Com S3 Via Morgana
#' 
#' Gera uma conexao mock a um banco no s3, porem realizando queries atraves da engine morgana
#' 
#' A conexao com um banco S3 via morgana e essencialmente a mesma coisa que um mock banco no s3, com
#' um unico elemento de diferenca sendo a necessidade de uma chave de API para uso das funcoes.
#' 
#' O argumento \code{x_api_key} existe para receber esta chave. Por padrao sera buscada uma variavel
#' de ambiente \code{"X_API_KEY"} na secao para este argumento. Esta e a abordagem recomendada, de
#' modo que informacoes pessoais e sensiveis nao ficam expostas hardcoded.
#' 
#' O objeto de saida e, para todos os efeitos, identico a uma conexao mock com o s3. Possui apenas 
#' um atributo adicional que e a chave de api passada originalmente
#' 
#' @param schema lista contendo o schema do banco, correspondente aos conteudos de um arquivo
#'     \code{schema.json} para banco, ou o caminho de um arquivo deste tipo ou diretorio que o 
#'     contenha. Veja \code{\link{conectamock}}
#' @param x_api_key chave de api para uso das funcoes que compoem o morgana na aws. Veja Detalhes
#'
#' @return objeto de conexao com o mock banco via morgana
#'
#' @note
#'
#' O servico morgana esta atualmente offline. Chamar `conectamorgana()` ira sempre
#' levantar um erro. O corpo da funcao abaixo da chamada a `stop()` foi preservado
#' verbatim para permitir reativacao com uma unica edicao quando a API morgana
#' retornar -- veja a secao 3 da especificacao para o playbook de reanimacao.
#'
#' @examples
#' \dontrun{
#' conn <- conectamorgana("caminho/para/schema.json")
#' }
#'
#' @export

conectamorgana <- function(schema, x_api_key = Sys.getenv("X_API_KEY")) {

    stop("Servico morgana atualmente indisponivel -- API offline")
    # === codigo abaixo preservado para reativacao quando a API morgana retornar ===

    if (!requireNamespace("httr2", quietly = TRUE)) {
        stop("Conexao como cliente do morgana exige pacote 'httr2'")
    }

    if (x_api_key == "") stop("Nao foi possivel encontrar uma chave de API -- veja '?conectamorgana'")

    out <- new_mock(schema, TRUE)
    class(out) <- c("morgana", class(out))
    attr(out, "x_api_key") <- x_api_key

    return(out)
}

new_mock <- function(schema, morgana = FALSE) {

    is_char <- is.character(schema)
    is_file <- is_char && grepl("schema\\.json$", schema)

    if (is_char && !is_file) schema <- file.path(schema, "schema.json")
    if (is_char) schema <- compoe_schema(schema) else schema <- compoe_schema(, schema)

    tabelas <- lapply(schema$tables, schema2tabela, no_master = morgana)
    names(tabelas) <- vapply(tabelas, "[[", "nome", FUN.VALUE = character(1L))

    out <- list(tabelas = tabelas)
    class(out) <- "mock"
    attr(out, "uri") <- schema$uri
    out
}

#' @export

print.mock <- function(x, ...) {
    cat("* Banco 'mock' com tabelas: \n\n")
    for (t in x$tabelas) {
        print(t)
        cat("\n")
    }
}