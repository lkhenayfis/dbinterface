
test_that("Testes de modificacao de query", {

    # baseado em uma tabela fake
    tabela1 <- new_tabela(
        "tabela_teste",
        list(
            new_campo("codigo", "string"),
            new_campo("id", "int"),
            new_campo("data", "date"),
            new_campo("valor", "float")
        ),
        "/qualquer/caminho/local/",
        ".csv"
    )

    parsed_2 <- parseargs(tabela1, c("data", "valor"), data = "2000/")
    expect_equal(parsed_2$SELECT, c("data", "valor"))
    expect_equal(parsed_2$FROM, "tabela_teste")
    expect_true(is.list(parsed_2$WHERE))
    expect_equal(names(parsed_2$WHERE), "data")
    expect_equal(parsed_2$WHERE$data,
        str2lang("(data >= as.POSIXct('2000-01-01 00:00:00')) & (data < as.POSIXct('3999-01-01 00:00:01'))"))

    parsed_3 <- parseargs(tabela1, c("codigo", "data", "valor"), codigo = c("A", "B"))
    expect_equal(parsed_3$SELECT, c("codigo", "data", "valor"))
    expect_equal(parsed_3$FROM, "tabela_teste")
    expect_true(is.list(parsed_3$WHERE))
    expect_equal(names(parsed_3$WHERE), "codigo")
    attributes(parsed_3$WHERE$codigo) <- NULL
    expect_equal(parsed_3$WHERE$codigo, str2lang("codigo == 'A' | codigo == 'B'"))
})

test_that("Leitura de dados mock -- Local", {

    arq  <- system.file("extdata/cpart_parquet/schema.json", package = "dbinterface")
    conn <- conectamock(arq)

    # checagem de particionamento ----------------------------------------

    expect_true(!checa_particao(conn, list(FROM = "subbacias")))
    expect_true(checa_particao(conn, list(FROM = "assimilacao")))

    # leitura de tabela sem particao -------------------------------------

    query <- parseargs(
        conn$tabelas$subbacias, c("codigo", "nome", "bacia_smap"),
        codigo = "BAIXOIG")
    dat1  <- suppressWarnings(proc_query_mock_spart(conn, query))
    expect_snapshot_value(unlist(dat1), style = "deparse")

    dat1.1 <- suppressWarnings(getfromdb(conn, "subbacias", c("codigo", "nome", "bacia_smap"), codigo = "BAIXOIG"))
    expect_identical(dat1, dat1.1)

    # leitura de tabela com particao -------------------------------------

    query <- parseargs(conn$tabelas$previstos, c("data_previsao", "codigo", "rsolo"),
        dia_previsao = 1, data_previsao = "2020-01-01", codigo = "AVERMELHA")
    dat1  <- suppressWarnings(proc_query_mock_cpart(conn, query))
    expect_snapshot_value(unlist(dat1), style = "deparse")

    dat1.1 <- suppressWarnings(getfromdb(conn, "previstos", c("data_previsao", "codigo", "rsolo"),
        dia_previsao = 1, data_previsao = "2020-01-01", codigo = "AVERMELHA"))
    expect_identical(dat1, dat1.1)

})

test_that("Leitura de dados mock -- Local RDS", {

    arq  <- system.file("extdata/models-db/schema.json", package = "dbinterface")
    conn <- conectamock(arq)

    # checagem de particionamento ----------------------------------------

    expect_true(!checa_particao(conn, list(FROM = "elementos")))
    expect_true(checa_particao(conn, list(FROM = "modelos")))

    # leitura de tabela com particao -------------------------------------

    read <- getfromdb(conn, "modelos", codigo = 1)
    expect_true(is.list(read))
    expect_true(length(read) == 1)
    expect_true(inherits(read[[1]], "lm"))

})

test_that("Leitura de dados mock -- S3", {

    skip_if(!nzchar(Sys.getenv("AWS_ACCESS_KEY_ID")), "AWS credentials not set")
    # existe um problema de timeout ainda nao controlado nas conexoes com a aws, ainda mais em
    # casos de bancos muito grandes
    # para evitar isso aqui, e agilizar o teste, e feita uma simplificacao
    schema <- aws.s3::s3read_using(jsonlite::read_json,
        bucket = "s3://ons-pem-historico/", object = "hidro/rodadas-smap/sintetico/schema.json")
    schema$tables <- schema$tables[c(5, 6)]
    conn <- conectamock(schema)

    # checagem de particionamento ----------------------------------------

    expect_true(!checa_particao(conn, list(FROM = "subbacias")))
    expect_true(checa_particao(conn, list(FROM = "vazoes")))

    # leitura de tabela sem particao -------------------------------------

    query <- parseargs(conn$tabelas$subbacias, c("codigo", "nome", "bacia_smap"), codigo = "BAIXOIG")
    dat1  <- suppressWarnings(proc_query_mock_spart(conn, query))
    expect_snapshot_value(unlist(dat1), style = "deparse")

    dat1.1 <- suppressWarnings(getfromdb(conn, "subbacias", c("codigo", "nome", "bacia_smap"), codigo = "BAIXOIG"))
    expect_identical(dat1, dat1.1)

    # leitura de tabela com particao -------------------------------------

    query <- parseargs(conn$tabelas$vazoes, c("data", "codigo", "vazao"),
        codigo = "AVERMELHA", data = "2020-01-01")
    dat1  <- suppressWarnings(proc_query_mock_cpart(conn, query))
    expect_snapshot_value(unlist(dat1), style = "deparse")

    dat1.1 <- suppressWarnings(getfromdb(conn, "vazoes", c("data", "codigo", "vazao"),
        codigo = "AVERMELHA", data = "2020-01-01"))
    expect_identical(dat1, dat1.1)

})
