################################### LEITURA DE ARQUIVOS GENERICA ###################################

#' Seleciona Funcao Escritora Por Tipo E Fonte De Arquivo
#' 
#' Para uma dada \code{extensao} de arquivo e sua origem (local ou s3) retorna uma funcao para 
#' escrita do mesmo
#' 
#' @param extensao string indicando a extensao de arquivo, preferencialmente precedida de "."
#' @param s3 booleano indidicano se o arquivo esta no s3 ou nao
#' 
#' @examples 
#' 
#' # para escrita    de um json
#' fun1 <- dbinterface:::switch_writer_func("json", FALSE)
#' identical(body(fun1)[[1]], jsonlite::write_json)
#' 
#' # para escrita de um csv
#' fun2 <- dbinterface:::switch_writer_func(".csv", FALSE)
#' identical(body(fun2)[[1]], data.table::fwrite)
#' 
#' @return funcao cujo primeiro argumento e o objeto a ser salvo e o segundo o caminho
#'     (local ou s3) do arquivo

switch_writer_func <- function(extensao, s3 = FALSE) {
    extensao <- valida_tipo_arquivo(extensao)
    inner_writer <- eval(parse(text = paste0("inner_writer", gsub("\\.", "_", extensao))))

    if (s3) {
        if (!requireNamespace("aws.s3", quietly = TRUE)) {
            stop("Pacote 'aws.s3' e necessario para leitura de arquivos no s3")
        }
        writer_func <- outer_writer_s3(inner_writer)
    } else {
        writer_func <- outer_writer_local(inner_writer)
    }

    return(writer_func)
}

valida_tipo_arquivo <- function(tipo) {
    if (!grepl("^\\.", tipo)) tipo <- paste0(".", tipo)
    suport <- c(".rds", ".csv", ".json", ".parquet", ".parquet.gzip")
    if (!(tipo %in% suport)) {
        msg <- paste0("Tipo de arquivo nao permitido -- deve ser um de (",
            paste0(suport, collapse = ", "), ")")
        stop(msg)
    }

    if (grepl("parquet", tipo) && !requireNamespace("arrow", quietly = TRUE)) {
        stop("Pacote 'arrow' e necessario para leitura de arquivos parquet")
    }

    return(tipo)
}

# FUNCOES DE LEITURA INTERNAS ----------------------------------------------------------------------

inner_writer_rds <- function(x, file, ...) saveRDS(x, file, ...)

inner_writer_json <- function(x, file, ...) jsonlite::write_json(x, file, ...)

inner_writer_csv <- function(x, file, ...) data.table::fwrite(x, file, ...)

inner_writer_parquet <- function(x, file, ...) arrow::write_parquet(x, file, ...)

inner_writer_parquet_gzip <- function(x, file, ...) arrow::write_parquet(x, file, ...)

# FUNCOES DE LEITURA EXTERNAS ----------------------------------------------------------------------

outer_writer_local <- function(inner_fun, ...) inner_fun

outer_writer_s3 <- function(inner_fun, ...) {
    function(x, file, ...) {
        file <- strsplit(file, "/")[[1]]
        bucket <- do.call(file.path, as.list(c(head(file, 3), "")))
        object <- do.call(file.path, as.list(c(file[-seq(3)])))
        aws.s3::s3write_using(x, inner_fun, object = object, bucket = bucket, ...)
    }
}