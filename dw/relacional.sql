BEGIN;

-- Configuração para unir os dois bancos
CREATE EXTENSION IF NOT EXISTS postgres_fdw;
CREATE SCHEMA IF NOT EXISTS staging;

CREATE SERVER maquina1_server
  FOREIGN DATA WRAPPER postgres_fdw
  OPTIONS (host 'maquina1', dbname 'maquina1', port '5432');

CREATE USER MAPPING FOR postgres
  SERVER maquina1_server
  OPTIONS (user 'postgres', password 'postgres');

IMPORT FOREIGN SCHEMA public
  LIMIT TO (clientes)
  FROM SERVER maquina1_server
  INTO staging;

-- tabelas a serem criadas no DW
CREATE TABLE clientes (
    id SERIAL CONSTRAINT pk_clientes PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    data_cadastro DATE DEFAULT CURRENT_DATE
);



COMMIT;
