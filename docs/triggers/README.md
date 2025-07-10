# Triggers

## Descrição
Triggers SQL para manter integridade dos dados e auditoria automática.

## Triggers Disponíveis

### 1. `auditoria_jogador_changes()`
**Utilidade**: Registra todas as mudanças na tabela de jogadores
**Trigger**: AFTER INSERT/UPDATE/DELETE na tabela `player`
**Ação**: Cria log de auditoria com data, usuário e tipo de operação
**Uso**: Rastreamento de mudanças nos dados

### 2. `validar_odds_match()`
**Utilidade**: Valida se as odds inseridas são consistentes
**Trigger**: BEFORE INSERT/UPDATE na tabela `match_odds`
**Ação**: Verifica se odds estão em range válido (0.1 a 100)
**Uso**: Garantir qualidade dos dados de apostas

### 3. `atualizar_contador_partidas()`
**Utilidade**: Mantém contadores atualizados automaticamente
**Trigger**: AFTER INSERT/DELETE na tabela `match`
**Ação**: Atualiza contadores de partidas por time e temporada
**Uso**: Manter estatísticas sempre atualizadas

## Características
- Garantia de integridade dos dados
- Auditoria automática
- Validação em tempo real 