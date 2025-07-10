# Documentação dos Objetos de Dados

Este diretório contém a documentação dos objetos de dados criados para o banco de dados de futebol normalizado.

## Estrutura

- **functions/**
- **procedures/**
- **triggers/**
- **views/**

## Objetivos

Todos os objetos foram criados com foco na **utilidade prática** para análise de dados de futebol.

## Banco de Dados

O banco contém 12 tabelas normalizadas com dados de:
- Jogadores e seus atributos
- Times e suas características
- Partidas e eventos
- Temporadas e ligas
- Odds de apostas 

## Docker compose (subir 1 parte)

docker compose up -d maquina1 maquina2 maquina3 dw grafana postgresql-exporter