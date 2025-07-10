# Funções SQL

## Descrição
Funções SQL para cálculos e análises úteis no contexto de dados de futebol.

## Funções Disponíveis

### 1. `calcular_media_jogador(player_id BIGINT)`
**Utilidade**: Calcula a média geral de atributos de um jogador
**Parâmetros**: `player_id` - ID do jogador (BIGINT)
**Retorna**: Média numérica dos atributos (overall_rating, potential, etc.)
**Uso**: Análise de performance individual
**Nota**: Compatível com o tipo BIGINT usado nas tabelas

### 2. `calcular_estatisticas_time(team_id INTEGER, season_name TEXT)`
**Utilidade**: Calcula estatísticas básicas de um time em uma temporada
**Parâmetros**: 
- `team_id` - ID do time (INTEGER)
- `season_name` - Nome da temporada (TEXT)
**Retorna**: Vitórias, empates, derrotas, gols marcados/sofridos
**Uso**: Relatórios de performance do time

### 3. `calcular_odds_media(match_id INTEGER)`
**Utilidade**: Calcula a média das odds de todas as casas de apostas para uma partida
**Parâmetros**: `match_id` - ID da partida (INTEGER)
**Retorna**: Média das odds de vitória, empate e derrota
**Uso**: Análise de probabilidades de apostas

## Características
- Foco em cálculos práticos e úteis
- Reutilizáveis em diferentes consultas
- Performance otimizada
- Compatibilidade com tipos de dados das tabelas 