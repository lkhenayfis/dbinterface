#' Pacote \code{dbinterface}
#' 
#' Backend Para Acesso A Bancos De Dados `mock` E Relacionais
#' 
#' Este pacote fornece funcionalidade backend para interface com bancos `mock`
#' localizados em um diretorio local ou em um bucket S3, alem de bancos relacionais tradicionais.
#' A versao atual suporta particionamento de dados, porem apenas operacoes de leitura
#' estao implementadas. Criacao de novas tabelas e escrita nas existentes
#' serao adicionadas em versoes futuras.
#' 
#' @name dbinterface
#' 
#' @import data.table utils
"_PACKAGE"