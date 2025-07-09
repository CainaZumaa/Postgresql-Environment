WITH source_data AS (
    SELECT *
    FROM staging.clientes
)
SELECT
    id,
    nome,
    email
FROM source_data
WHERE email IS NOT NULL