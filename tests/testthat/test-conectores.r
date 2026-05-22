
test_that("Testa conexao mock -- Local", {

    arq  <- system.file("extdata/cpart_parquet/schema.json", package = "dbinterface")
    conn <- conectamock(arq)
    expect_true(inherits(conn, "mock"))
    expect_equal(attr(conn, "uri"), sub("/schema.json", "", arq))

    arq2 <- system.file("extdata/cpart_parquet", package = "dbinterface")
    conn2 <- conectamock(arq2)
    expect_identical(conn, conn2)

    schema <- compoe_schema(arq)
    conn3 <- conectamock(schema)
    expect_identical(conn, conn3)
})

test_that("Testa conexao mock -- S3", {

    skip_if(!nzchar(Sys.getenv("AWS_ACCESS_KEY_ID")), "AWS credentials not set")
    arq  <- "s3://ons-pem-historico/hidro/rodadas-smap/sintetico/schema.json"
    conn <- conectamock(arq)
    expect_true(inherits(conn, "mock"))
    expect_equal(attr(conn, "uri"), sub("/schema.json", "", arq))

    arq2 <- "s3://ons-pem-historico/hidro/rodadas-smap/sintetico"
    conn2 <- conectamock(arq2)
    expect_identical(conn, conn2)

    schema <- compoe_schema(arq)
    conn3 <- conectamock(schema)
    expect_identical(conn, conn3)
})

test_that("conectamorgana e bloqueado enquanto a API esta offline", {
    arq <- "s3://ons-pem-historico/hidro/rodadas-smap/sintetico/schema.json"
    expect_error(conectamorgana(arq), "morgana atualmente indisponivel")
})
