-- Este modelo usa VIEW para a Staging Layer para economia e agilidade
{{ config(materialized='view') }} 

with source as (
    -- Referencia a tabela bruta
    select
        movieid,
        title,
        genres
    from
        {{ source('raw_movielens', 'movies') }}
),

cleaned as (
    select
        -- Padronização
        cast(movieid as integer) as movie_id,
        title,
        genres,

        -- *Extração do Ano de Lançamento* (Regex nativo do BigQuery)
        cast(regexp_extract(title, r'\((\d{4})\)') as integer) as release_year

    from source
)

select * from cleaned