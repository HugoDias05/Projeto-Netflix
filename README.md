# 🎬 Projeto ELT: Ranking de Filmes MovieLens 20M

Este projeto demonstra a aplicação de princípios de **Analytics Engineering** e **ELT (Extract, Load, Transform)** utilizando ferramentas *cloud-native* para transformar dados brutos de avaliações em uma tabela de relatórios pronta para consumo em BI.

O objetivo principal é responder ao requisito de negócio: **"Quais são os 10 filmes mais bem avaliados por ano de lançamento, considerando apenas filmes com, no mínimo, 100 avaliações para garantir relevância?"**

---

## 💻 Stack Tecnológico

| Categoria | Tecnologia | Uso no Projeto |
| :--- | :--- | :--- |
| **Data Source** | MovieLens 20M Dataset (CSV) | Fonte dos dados brutos. |
| **Data Warehouse** | **Google BigQuery** | Camada de armazenamento e processamento (`Raw`, `Staging`, `Serving`). |
| **Data Staging** | Google Cloud Storage (GCS) | Utilizado como *staging area* para carregar arquivos grandes (508MB+). |
| **Transformação** | **dbt (Data Build Tool)** | Orquestração e transformação dos modelos de dados (Camada T do ELT). |
| **Visualização** | Power BI | Ferramenta para consumir a tabela de relatórios final. |

---

## 🗺️ Arquitetura do Pipeline ELT

O pipeline de dados segue a abordagem ELT e a estrutura de três camadas (Camada 1: Raw, Camada 2: Staging, Camada 3: Serving):

1.  **Extract & Load (E/L):** Os arquivos CSV brutos foram carregados no **GCS** e, em seguida, carregados no dataset `raw_movielens` no BigQuery.
2.  **Transform (T):** O **dbt** executa o código SQL/Jinja, aplicando lógica de negócio e criando os modelos nas camadas `staging_movielens` e `serving_movielens`.
3.  **Serve:** O Power BI se conecta diretamente à tabela final (`rpt_top_movies_by_year`).



---

## 🧬 Modelagem de Dados (dbt Models)

O projeto utiliza um design orientado a dimensão e fatos (Kimball), dividido em três modelos principais:

| Modelo | Função | Materialização | Descrição |
| :--- | :--- | :--- | :--- |
| `stg_movies` | **Staging/Dimensão** | `view` | Limpa a tabela `movies` e, crucialmente, extrai o **`release_year`** do campo `title` usando `regexp_extract`. |
| `fct_ratings` | **Fato** | `view` | Conecta as avaliações (`ratings`) com o filme limpo (`stg_movies`), criando a base de dados central para calcular métricas. |
| `rpt_top_movies_by_year` | **Reporting/Serving** | `table` | **Modelo Final.** Agrega as notas por filme, aplica o filtro de relevância (`HAVING count(rating) >= 100`) e usa a função de janela (`rank() over...`) para classificar o Top 10 de cada ano. |

---

## 🚀 Guia de Execução

Para replicar o projeto, siga as etapas e comandos na pasta `movielens_dbt/`:

1.  **Verificação:** `dbt debug` para checar a conexão do BigQuery (Localização: `southamerica-east1`).
2.  **Execução do Pipeline:** O comando a seguir constrói todas as três camadas (Staging e Serving) na ordem correta:
    ```bash
    dbt run
    ```
3.  **Conexão BI:** Conecte o Power BI (usando o conector nativo e especificando a Localização `southamerica-east1`) à tabela final: `serving_movielens.rpt_top_movies_by_year`.



