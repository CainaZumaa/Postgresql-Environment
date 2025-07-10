# Procedimentos Armazenados

## Descrição
Procedimentos SQL para operações complexas e automatizadas no banco de dados de futebol.

## Procedimentos Disponíveis

### 1. `atualizar_estatisticas_jogador(player_id INTEGER)`
**Utilidade**: Atualiza estatísticas consolidadas de um jogador
**Ação**: Calcula e atualiza médias de performance, total de partidas, etc.
**Uso**: Manutenção automática de dados agregados

### 2. `gerar_relatorio_temporada(season_name TEXT)`
**Utilidade**: Gera relatório completo de uma temporada
**Ação**: Calcula estatísticas de todos os times, jogadores e partidas
**Uso**: Relatórios periódicos de performance

### 3. `limpar_dados_antigos(anos_antigos INTEGER)`
**Utilidade**: Remove dados antigos para otimizar performance
**Ação**: Remove partidas, eventos e odds de temporadas antigas
**Uso**: Manutenção e limpeza do banco

## Características
- Operações em lote
- Automatização de tarefas repetitivas
- Manutenção de integridade dos dados 