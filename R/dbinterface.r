#' Pacote \code{dbinterface}
#'
#' Backend Para Acesso A Bancos Mock e Morgana
#'
#' Este pacote fornece funcionalidade backend para interface com bancos `mock`
#' localizados em um diretorio local ou em um bucket S3, e com bancos `morgana`,
#' que sao bancos no S3 acessados via API. Suporta particionamento de dados.
#'
#' O conector morgana esta temporariamente desabilitado enquanto a API permanece offline;
#' chamar \code{conectamorgana} levanta erro. A versao atual expoe apenas operacoes de
#' leitura via \code{getfromdb}. Funcoes internas para escrita existem no codigo-fonte
#' mas ainda nao estao expostas em API publica.
#' 
#' @name dbinterface
#' 
#' @import data.table utils
"_PACKAGE"