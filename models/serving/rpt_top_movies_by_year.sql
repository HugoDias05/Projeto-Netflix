{{ config(
    materialized='table', 
    schema='serving_movielens' 
) }}

with annual_summary as (
    select
        release_year,
        movie_id,
        title,
        -- Calcula a média da avaliação
        avg(rating) as avg_rating,
        -- Conta o número de avaliações (para garantir relevância)
        count(rating) as total_ratings

    from {{ ref('fct_ratings') }}

    -- Garante que só consideramos filmes com, no mínimo, 100 avaliações (Regra de Negócio)
    group by 1, 2, 3
    having count(rating) >= 100 
),

ranked_movies as (
    select
        release_year,
        title,
        avg_rating,
        total_ratings,

        -- Ranqueia os filmes por ano com base na média de avaliação
        rank() over (
            partition by release_year 
            order by avg_rating desc, total_ratings desc
        ) as rank_by_year

    from annual_summary
)

-- Resultado final: Filmes no top 10 de avaliação média por ano
select *
from ranked_movies
where rank_by_year <= 10
order by release_year desc, rank_by_year asc