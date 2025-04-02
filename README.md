# 📊 Documentação – Dashboard Power BI: Satisfação vs Tempo de Resposta

---

## 🧠 Objetivo do Dashboard

> Considerando o que foi descrito na questão 2 do _"CASES DATA ANALYST"_, o objetivo é testar a ideia de que, **quanto mais tempo demoramos para resolver uma solicitação, pior é a nota que o usuário dá para o atendimento**.
>
> Para analisar isso, juntamos os dados das duas tabelas:
>
> - Uma com as **avaliações dos usuários**
> - Outra com o **tempo de resposta**
>
> Usamos **apenas os registros que têm tanto a nota quanto o tempo registrados**, para conseguir fazer essa comparação de forma precisa e confiável.

---

<details>
<summary>📂 Fontes de Dados</summary>

### 1. `tabela_satisfacao_log.csv`
- Origem: CSV
- Consulta: `tabela_satisfacao_log`
- Campos:
  - `ticket_id`: identificador único do chamado
  - `updated_at`: data e hora da última atualização da avaliação
  - `score`: avaliação textual, com valores possíveis: `"good"` ou `"bad"`

### 2. `tabela_ticket_metricas.csv`
- Origem: CSV
- Consulta: `tabela_ticket_metricas`
- Campos:
  - `ticket_id`: identificador único do chamado
  - `status`: status do chamado
  - `tempo_de_resposta`: tempo total de resposta em minutos

</details>

---

<details>
<summary>🔧 Atualização dos Dados</summary>

- A atualização dos dados é feita por meio do parâmetro `FilePath`.
- Este parâmetro está localizado em:
  - **Pasta `Parameters` > Parâmetro `FilePath`**
- Para atualizar:
  1. Navegue até o parâmetro.
  2. Altere o valor para o novo caminho dos arquivos `.csv`.

</details>

---

<details>
<summary>⚙️ Power Query – Consulta <code>tabela_satisfacao_log</code></summary>

- Importa dados do CSV.
- Promove os cabeçalhos e altera os tipos das colunas.
- Remove colunas não utilizadas.
- Remove registros com score nulo ou diferente de `good` ou `bad`.
- Agrupa por `ticket_id`.
- Mantém somente a **última avaliação** para cada ticket.

```m
let
    Fonte = Csv.Document(File.Contents(FilePath & "tabela_satisfacao_log.csv"),[Delimiter=";", Columns=10, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos",{{"ticket_id", type text}, {"updated_at", type text}, {"score", type text}, {"", type text}, {"_1", type text}, {"_2", type text}, {"_3", type text}, {"_4", type text}, {"_5", type text}, {"_6", type text}}),
    #"Outras Colunas Removidas" = Table.SelectColumns(#"Tipo Alterado",{"ticket_id", "updated_at", "score"}),
    #"Valor Substituído" = Table.ReplaceValue(#"Outras Colunas Removidas"," UTC","",Replacer.ReplaceText,{"updated_at"}),
    #"Tipo Alterado1" = Table.TransformColumnTypes(#"Valor Substituído",{{"updated_at", type datetime}}),
    #"Removendo Registros Não Avaliados" = Table.SelectRows(#"Tipo Alterado1", each ([score] = "good" or [score] = "bad")),
    #"Agrupando por Ticket" = Table.Group(#"Removendo Registros Não Avaliados", {"ticket_id"}, {{"TodasLinhas", each _, type table [ticket_id=Int64.Type, updated_at=datetime, score=text]}}),
    #"Linha Máxima" = Table.AddColumn(#"Agrupando por Ticket", "LinhaMax", each Table.Max([TodasLinhas], "updated_at")),
    #"Removendo Coluna TodasLinhas" = Table.RemoveColumns(#"Linha Máxima",{"TodasLinhas"}),
    #"Expandindo LinhaMax" = Table.ExpandRecordColumn(#"Removendo Coluna TodasLinhas", "LinhaMax", {"updated_at", "score"}, {"updated_at", "score"})
in
    #"Expandindo LinhaMax"
```

</details>

---

<details>
<summary>⚙️ Power Query – Consulta <code>tabela_ticket_metricas</code></summary>

- Importa os dados do CSV.
- Promove cabeçalhos e define os tipos de dados corretamente.

```m
let
    Fonte = Csv.Document(File.Contents(FilePath & "tabela_ticket_metricas.csv"),[Delimiter=";", Columns=3, Encoding=1252, QuoteStyle=QuoteStyle.None]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos",{{"ticket_id", type text}, {"status", type text}, {"tempo_de_resposta", Int64.Type}})
in
    #"Tipo Alterado"
```

</details>

---

<details>
<summary>📐 Medidas DAX (com propriedades completas)</summary>

### 🎫 **Tickets Avaliados**
```dax
COUNTROWS('tabela_ticket')
```
- **Formato**: Número inteiro, 0 casas decimais
- **Separador de milhar**: Sim
- **Oculto**: Não
- **Tabela**: `_medidas`
- **Sinônimo**: tickets avaliados

---

### ✅ **Tickets Positivos**
```dax
CALCULATE(
    COUNTA(tabela_ticket[ticket_id]),
    tabela_ticket[score] = "good"
)
```
- Contabiliza os tickets com avaliação positiva.
- **Formato**: Número inteiro
- **Separador de milhar**: Sim
- **Oculto**: Não
- **Tabela**: `_medidas`
- **Sinônimo**: tickets positivos

---

### ❌ **Tickets Negativos**
```dax
CALCULATE(
    COUNTA(tabela_ticket[ticket_id]),
    tabela_ticket[score] = "bad"
)
```
- Contabiliza os tickets com avaliação negativa.
- **Formato**: Número inteiro
- **Separador de milhar**: Sim
- **Oculto**: Não
- **Tabela**: `_medidas`
- **Sinônimo**: tickets negativos

---

### ⏱️ **TME (Tempo Médio de Resposta Formatado)**
```dax
VAR AvgMinutos = AVERAGE(tabela_ticket[tempo_de_resposta])
VAR Dias = INT(AvgMinutos / 1440)
VAR Horas = INT(MOD(AvgMinutos, 1440) / 60)
VAR Minutos = MOD(AvgMinutos, 60)
RETURN FORMAT(Dias, "0") & "d " & FORMAT(Horas, "0") & "h " & FORMAT(Minutos, "0") & "m"
```
- Converte tempo médio de resposta (em minutos) para dias, horas e minutos.
- **Formato**: Texto
- **Tabela**: `_medidas`
- **Sinônimo**: tme

---

### 📈 **% Taxa de Satisfação**
```dax
DIVIDE([Tickets Positivos], [Tickets Avaliados])
```
- Calcula o percentual de tickets com nota `"good"`.
- **Formato**: Percentual, 1 casa decimal
- **Separador de milhar**: Não
- **Tabela**: `_medidas`
- **Sinônimo**: % taxa de satisfação

---

### 📉 **% Taxa de Insatisfação**
```dax
DIVIDE([Tickets Negativos], [Tickets Avaliados])
```
- Calcula o percentual de tickets com nota `"bad"`.
- **Formato**: Percentual, 1 casa decimal
- **Separador de milhar**: Não
- **Tabela**: `_medidas`
- **Sinônimo**: % taxa de insatisfação

---

### 🟢🔴 **Tickets Avaliados | Ícone**
```dax
SWITCH(
    TRUE(),
    [Tickets Positivos] = 1, "🟢",
    "🔴"
)
```
- Representa visualmente a avaliação com ícones.
- **Formato**: Texto
- **Tabela**: `_medidas`
- **Sinônimo**: tickets avaliados | icone

---

### ☀️ Tickets Avaliados por Período

#### 🌅 **Manhã**
```dax
CALCULATE(
    COUNTA(tabela_ticket[ticket_id]),
    tabela_ticket[Periodo_Dia] = "Manhã"
)
```

#### 🌇 **Tarde**
```dax
CALCULATE(
    COUNTA(tabela_ticket[ticket_id]),
    tabela_ticket[Periodo_Dia] = "Tarde"
)
```

#### 🌙 **Noite**
```dax
CALCULATE(
    COUNTA(tabela_ticket[ticket_id]),
    tabela_ticket[Periodo_Dia] = "Noite"
)
```
- Todas formatadas como número inteiro, sem casas decimais.
- **Tabela**: `_medidas`
- **Ocultas**: Não

</details>

---

<details>
<summary>📊 Visualizações Aplicadas no Dashboard</summary>

- **KPIs principais em destaque**:
  - Total de tickets avaliados, positivos, negativos e TME

- **Gráfico de Rosca**:
  - Percentual de satisfação e insatisfação geral

- **Gráfico de Barras Horizontais**:
  - Avaliações segmentadas por período do dia (manhã, tarde, noite)

- **Gráfico de Colunas Empilhadas (100%)**:
  - Percentual de satisfação/insatisfação por faixas de tempo de resposta:
    - 0–24h, 24–48h, 48–72h, 72–96h, 96–120h, 120h+

✅ Todas essas visualizações **respondem diretamente à hipótese analisada** e fornecem excelente leitura dos dados com clareza visual e comparação rápida.

</details>

---

### 🎯 Missão

> Considerando essas bases de dados (enviadas em CSV), crie uma visualização que possibilite testar nossa hipótese requisitada por nosso cliente. Apresente para o time de Clientes seus insights e sugestões sobre qual deveria ser a estratégia da área com base em suas conclusões.

---

### ✅ Hipótese

**Quanto maior o tempo de resposta dos tickets, pior é a avaliação dada pelo usuário.**

---

### 📈 Conclusões Baseadas na Análise

- A hipótese foi **confirmada**: quanto maior o tempo de resposta, **maior a chance de o usuário dar uma nota negativa**.
  - Os atendimentos resolvidos em até 24h concentram a maior parte das avaliações **positivas**.
  - A partir de 48h, a **insatisfação cresce consideravelmente**.
  - Nas faixas acima de 96h, a **maioria das avaliações são negativas**.

- O **tempo médio de resposta atual (8h32m)** está dentro de uma faixa segura, mas há faixas de risco em crescimento acima de 72h.

- **Distribuição das avaliações por turno do dia**:
  - A **maior parte das avaliações positivas são registradas pela manhã**.
  - Isso indica que os usuários costumam avaliar com mais boa vontade ou positividade nesse período.
  - Portanto, o **horário da avaliação influencia o tom da resposta**, o que **não está necessariamente relacionado com o turno em que o atendimento foi feito**.

---

### 💡 Insights e Recomendações Estratégicas

1. **Reduzir o tempo de resposta dos tickets**
   - Priorizar chamados com mais de 24h para resposta imediata.
   - Criar alertas automáticos para tickets que ultrapassem 48h ou 72h.

2. **Aproveitar o comportamento positivo do usuário pela manhã**
   - Quando possível, incentivar ou solicitar feedback logo pela manhã.
   - Enviar **solicitações de avaliação programadas** nesse período para aumentar a taxa de satisfação.

3. **Evitar que tickets "durmam" no sistema**
   - Chamados que passam da faixa de 72h apresentam queda significativa nas avaliações positivas.
   - É fundamental manter um fluxo ágil e acompanhar SLAs de perto.

4. **Mensurar o tempo entre resolução e avaliação**
   - Considerar adicionar esse indicador futuramente, para analisar se a **proximidade da resolução** com o momento da **avaliação** influencia o resultado.

---

### 🧭 Estratégia Recomendada para a Área de Clientes

A área de Clientes deve adotar uma abordagem focada em **agilidade operacional** e **sensibilidade ao comportamento do usuário**, com foco em:

- Resolver tickets prioritários **em menos de 24h**.
- **Automatizar pedidos de avaliação** nos períodos de maior propensão a boas notas (especialmente pela manhã).
- **Monitorar faixas de tempo críticas**, agindo antes que os tickets ultrapassem 48h e entrem em zonas de risco.
- Criar uma rotina de revisão para **ajustes na alocação de tarefas** conforme volume e tempo médio por faixa.

Essas ações combinadas aumentarão a satisfação do usuário, melhorarão os indicadores de atendimento e fortalecerão a relação com o cliente final.
