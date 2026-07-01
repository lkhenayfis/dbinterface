library(data.table)
library(jsonlite)

DIR <- "./inst/extdata/models-db/"

suppressWarnings(dir.create(DIR))

schema_geral <- list(
    application =  "teste-rds",
    name =  "",
    description = "",
    version =  1,
    modifiedTime = "",
    tables = list(
        list(
            name = "elementos",
            uri = "./elementos"
        ),
        list(
            name = "modelos",
            uri = "./modelos"
        )
    )
)

write_json(schema_geral, file.path(DIR, "schema.json"), pretty = TRUE, auto_unbox = TRUE)

# ELEMENTOS ---------------------

elementos <- data.table(
    nome = LETTERS[1:3], codigo = 1:3
)

schema_elementos <- list(
    name = "elementos",
    description = "",
    uri = "./elementos",
    fileType =  ".csv",
    columns = list(
        list(
            name =  "nome",
            type =  "string"
        ),
        list(
            name =  "codigo",
            type =  "int"
        )
    )
)

suppressWarnings(dir.create(file.path(DIR, "elementos")))

write_json(schema_elementos, file.path(DIR, "elementos", "schema.json"), pretty = TRUE, auto_unbox = TRUE)
fwrite(elementos, file.path(DIR, "elementos", "elementos.csv"))

# MODELOS ---------------------

schema_modelos <- list(
    name = "modelos",
    description = "",
    uri = "./modelos",
    fileType =  ".rds",
    columns = list(
        list(
            name =  "codigo",
            type =  "int"
        )
    ),
    partitions = list(
        list(
            name =  "codigo",
            type =  "int"
        )
    )
)

set.seed(1235)
mods <- lapply(seq_len(2L), function(i) {
    x <- rnorm(20)
    y <- rnorm(20)
    lm(y ~ x)
})


suppressWarnings(dir.create(file.path(DIR, "modelos")))

write_json(schema_modelos, file.path(DIR, "modelos", "schema.json"), pretty = TRUE, auto_unbox = TRUE)
for (i in 1:2) saveRDS(mods[[i]], file.path(DIR, "modelos", sprintf("modelos-codigo=%s.rds", i)))
