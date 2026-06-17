# hcahps-dbt-healthcare
nd-to-end healthcare data warehouse built on Snowflake and dbt. Loads CMS HCAHPS patient survey data into a star schema with four dimension tables and one fact table using a medallion architecture (Raw, Staging, Marts, Reports). Includes dbt tests for primary keys, referential integrity, and data quality. Built as part of the DEA portfolio.
