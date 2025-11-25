
test_that("Validadores de tipo de arquivo", {

    # testes padrao ------------------------------------------------------

    expect_equal(valida_tipo_arquivo("csv"), ".csv")
    expect_equal(valida_tipo_arquivo("parquet"), ".parquet")
    expect_equal(valida_tipo_arquivo("parquet.gzip"), ".parquet.gzip")
    expect_equal(valida_tipo_arquivo("json"), ".json")

    expect_equal(valida_tipo_arquivo("csv"), valida_tipo_arquivo(".csv"))
    expect_equal(valida_tipo_arquivo("parquet"), valida_tipo_arquivo(".parquet"))
    expect_equal(valida_tipo_arquivo("parquet.gzip"), valida_tipo_arquivo(".parquet.gzip"))
    expect_equal(valida_tipo_arquivo("json"), valida_tipo_arquivo(".json"))

    expect_error(valida_tipo_arquivo("tipo_qualquer"))
})

test_that("Selecao de writer_fun", {

    # CSV ----------------------------------------------------------------

    ff <- switch_writer_func(".csv", FALSE)
    expect_equal(ff, inner_writer_csv)

    ff <- switch_writer_func("csv", FALSE)
    expect_equal(ff, inner_writer_csv)

    ff <- switch_writer_func(".csv", TRUE)
    expect_equal(ff, outer_writer_s3(inner_writer_csv))

    ff <- switch_writer_func("csv", TRUE)
    expect_equal(ff, outer_writer_s3(inner_writer_csv))

    # PARQUET ------------------------------------------------------------

    ff <- switch_writer_func(".parquet", FALSE)
    expect_equal(ff, inner_writer_parquet)

    ff <- switch_writer_func("parquet", FALSE)
    expect_equal(ff, inner_writer_parquet)

    ff <- switch_writer_func(".parquet", TRUE)
    expect_equal(ff, outer_writer_s3(inner_writer_parquet))

    ff <- switch_writer_func("parquet", TRUE)
    expect_equal(ff, outer_writer_s3(inner_writer_parquet))

    # PARQUET.GZIP -------------------------------------------------------

    ff <- switch_writer_func(".parquet.gzip", FALSE)
    expect_equal(ff, inner_writer_parquet_gzip)

    ff <- switch_writer_func("parquet.gzip", FALSE)
    expect_equal(ff, inner_writer_parquet_gzip)

    ff <- switch_writer_func(".parquet.gzip", TRUE)
    expect_equal(ff, outer_writer_s3(inner_writer_parquet_gzip))

    ff <- switch_writer_func("parquet.gzip", TRUE)
    expect_equal(ff, outer_writer_s3(inner_writer_parquet_gzip))

    # JSON ---------------------------------------------------------------

    ff <- switch_writer_func(".json", FALSE)
    expect_equal(ff, inner_writer_json)

    ff <- switch_writer_func("json", FALSE)
    expect_equal(ff, inner_writer_json)

    ff <- switch_writer_func(".json", TRUE)
    expect_equal(ff, outer_writer_s3(inner_writer_json))

    ff <- switch_writer_func("json", TRUE)
    expect_equal(ff, outer_writer_s3(inner_writer_json))

    # ERROS --------------------------------------------------------------

    expect_error(ff <- switch_writer_func("tipo_qualquer", FALSE))
    expect_error(ff <- switch_writer_func("tipo_qualquer", TRUE))
})
