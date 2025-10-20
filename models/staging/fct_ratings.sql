{{ config(materialized='view') }}

select
    -- Avaliações (Fato)
    t1.userid,
    t1.rating,
    t1.timestamp,

    -- Informações do Filme (Dimensão - JOIN)
    t2.movie_id,
    t2.title,
    t2.release_year

from 
    {{ source('raw_movielens', 'ratings') }} t1 -- Tabela ratings bruta
inner join
    {{ ref('stg_movies') }} t2                 -- Modelo de Staging de filmes (limpo)
on 
    t1.movieid = t2.movie_id
where 
    t2.release_year is not null -- Filtra filmes onde não foi possível extrair o ano