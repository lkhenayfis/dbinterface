################################# FUNCOES PARA QUERY DE MOCK BANCOS ################################

#' Checa Existencia De Particoes Locais
#' 
#' Avalia se uma tabela local corresponde a conjunto de particoes ou nao
#' 
#' @param conexao objeto de conexao ao banco (mock ou morgana)
#' @param query lista detalhando a query como retornado por \code{\link{parseargs}}
#'
#' @return booleano indicando se a tabela e particionada ou nao

checa_particao <- function(conexao, query) {
    tabfrom <- conexao$tabelas[[query$FROM]]
    tempart <- !is.null(tabfrom$particoes)
    return(tempart)
}

#' Leitor De Tabelas Em Mock Bancos
#' 
#' Abstracao para leitura de arquivos csv ou parquet
#' 
#' @param tabela objeto de classe \code{tabela} cujos arquivos componentes devem ser listados
#' @param arquivo nome do arquivo componente de \code{tabela} a ser lido, sem extensao
#' @param ... demais argumentos que possam ser passados para o leitor interno
#' 
#' @return data.table contendo a tabela lida

le_tabela_mock <- function(tabela, arquivo, ...) {
    rf  <- attr(tabela, "reader_func")
    arq <- file.path(attr(tabela, "uri"), paste0(arquivo, attr(tabela, "tipo_arquivo")))
    dat <- rf(arq, ...)
    return(dat)
}

#' Executores Internos De Query Local
#' 
#' Realizam queries em bancos de dados locais, com ou sem particao
#' 
#' @param conexao objeto de conexao ao banco (mock ou morgana)
#' @param query lista detalhando a query como retornado por \code{\link{parseargs}}
#'
#' @return dado recuperado do banco ou erro caso a query nao possa ser realizada
#'
#' @importFrom dplyr collect
#' 
#' @name query_local

#' @rdname query_local

proc_query_mock_spart <- function(conexao, query) {

    # quando vem de proc_query_mock_cpart, FROM e um vetor de duas poscoes, indicando a tabela
    # abstrata de onde ler na primeira e o arquivo componente na segunda
    # a implementacao e feita com head e tail porque, no caso de tabelas nao particionadas, FROM tem
    # somente uma posicao mesmo (com [1] e [2] causa erro)
    dat <- le_tabela_mock(
        conexao$tabelas[[head(query$FROM, 1)]],
        tail(query$FROM, 1)
    )

    for (q in query$WHERE) dat <- apply_where(dat, q)
    dat <- collect(dat)
    tryDT(dat)

    dat <- apply_select(dat, query$SELECT)

    return(dat)
}

#' @rdname query_local

proc_query_mock_cpart <- function(conexao, query) {

    master <- attr(conexao$tabelas[[query$FROM]], "master")
    colspart <- colnames(master)
    colspart <- colspart[colspart != "tabela"]

    querymaster <- query[c("SELECT", "FROM", "WHERE")]
    querymaster$SELECT <- "tabela"
    if (length(querymaster$WHERE) > 0) querymaster$WHERE <- querymaster$WHERE[colspart]
    querymaster$WHERE <- querymaster$WHERE[lengths(querymaster$WHERE) > 0]

    for (q in querymaster$WHERE) master <- apply_where(master, q)
    master <- collect(master)

    tabelas <- master$tabela

    drop_where <- !(names(query$WHERE) %in% colspart)
    query$WHERE <- query$WHERE[drop_where]

    dat <- lapply(tabelas, function(tabela) {
        querytabela <- query
        querytabela$FROM <- c(query$FROM, tabela)

        proc_query_mock_spart(conexao, querytabela)
    })

    # quanto se esta lendo arquivos rds contendo objetos genericos, nao tabulares, nao e possivel
    # fazer rbindlist (e nem faz sentido tentar combinar)
    # isto existe para o caso de se estarem lendo modelos ajustados
    # nestes casos, uma lista de modelos volta
    dat <- tryCatch(rbindlist(dat), error = function(e) dat)

    return(dat)
}

# AUXILIARES ---------------------------------------------------------------------------------------

collect.default <- function(x, ...) x

apply_where <- function(dt, wheres) {
    cc <- list(quote(dplyr::filter), substitute(dt), wheres)
    cc <- as.call(cc)
    eval(cc, parent.frame(), parent.frame())
}

apply_select <- function(dt, selects) UseMethod("apply_select")

apply_select.default <- function(dt, selects) dt
apply_select.data.table <- function(dt, selects) {
    dt[, .SD, .SDcols = selects]
}

tryDT <- function(x) UseMethod("tryDT")
tryDT.default <- function(x) x
tryDT.data.frame <- function(x) as.data.table(x)
