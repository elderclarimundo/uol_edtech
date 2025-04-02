# 📊 Documentação das Métricas - Dashboard Power BI

Este documento descreve as medidas DAX utilizadas no dashboard Power BI, incluindo seus cálculos, formatações e propriedades.

---

## 🔢 Métricas Principais

<details>
<summary><strong>🎟️ Tickets Avaliados</strong></summary>

```dax
COUNTROWS('tabela_ticket')
```

**Propriedades:**
- **Nome:** Tickets Avaliados  
- **Tabela Inicial:** _medidas  
- **Sinônimo:** tickets avaliados  
- **Oculto:** Não  
- **Formato:** Número Inteiro  
- **Separador de milhares:** Sim  
- **Casas Decimais:** 0  
- **Categoria de Dados:** Não categorizado

</details>

<details>
<summary><strong>✅ Tickets Positivos</strong></summary>

```dax
CALCULATE(
    COUNTA(tabela_ticket[ticket_id]),
    tabela_ticket[score] = "good"
)
```

**Propriedades:**
- **Nome:** Tickets Positivos  
- **Tabela Inicial:** _medidas  
- **Sinônimo:** tickets positivos  
- **Oculto:** Não  
- **Formato:** Número Inteiro  
- **Separador de milhares:** Sim  
- **Casas Decimais:** 0  
- **Categoria de Dados:** Não categorizado

</details>

<details>
<summary><strong>❌ Tickets Negativos</strong></summary>

```dax
CALCULATE(
    COUNTA(tabela_ticket[ticket_id]),
    tabela_ticket[score] = "bad"
)
```

**Propriedades:**
- **Nome:** Tickets Negativos  
- **Tabela Inicial:** _medidas  
- **Sinônimo:** tickets negativos  
- **Oculto:** Não  
- **Formato:** Número Inteiro  
- **Separador de milhares:** Sim  
- **Casas Decimais:** 0  
- **Categoria de Dados:** Não categorizado

</details>

<details>
<summary><strong>⏱️ TME (Tempo Médio de Espera)</strong></summary>

```dax
VAR AvgMinutos = AVERAGE(tabela_ticket[tempo_de_resposta])
VAR Dias = INT(AvgMinutos / 1440)  -- 1440 minutos = 1 dia
VAR Horas = INT(MOD(AvgMinutos, 1440) / 60)
VAR Minutos = MOD(AvgMinutos, 60)
RETURN
FORMAT(Dias, "0") & "d " & FORMAT(Horas, "0") & "h " & FORMAT(Minutos, "0") & "m"
```

**Propriedades:**
- **Nome:** TME  
- **Tabela Inicial:** _medidas  
- **Sinônimo:** tme  
- **Oculto:** Não  
- **Formato:** Texto  
- **Separador de milhares:** Sim  
- **Casas Decimais:** 0  
- **Categoria de Dados:** Não categorizado

</details>

---

## 📈 Métricas Percentuais

<details>
<summary><strong>😊 % Taxa de Satisfação</strong></summary>

```dax
DIVIDE([Tickets Positivos], [Tickets Avaliados])
```

**Propriedades:**
- **Nome:** % Taxa de Satisfação  
- **Tabela Inicial:** _medidas  
- **Sinônimo:** % taxa de satisfação  
- **Oculto:** Não  
- **Formato:** Porcentagem  
- **Separador de milhares:** Não  
- **Casas Decimais:** 1  
- **Categoria de Dados:** Não categorizado

</details>

<details>
<summary><strong>😞 % Taxa de Insatisfação</strong></summary>

```dax
DIVIDE([Tickets Negativos], [Tickets Avaliados])
```

**Propriedades:**
- **Nome:** % Taxa de Insatisfação  
- **Tabela Inicial:** _medidas  
- **Sinônimo:** % taxa de insatisfação  
- **Oculto:** Não  
- **Formato:** Porcentagem  
- **Separador de milhares:** Não  
- **Casas Decimais:** 1  
- **Categoria de Dados:** Não categorizado

</details>

---

## 🔔 Indicadores Visuais

<details>
<summary><strong>🟢🔴 Tickets Avaliados | Ícone</strong></summary>

```dax
SWITCH(
    TRUE(),
    [Tickets Positivos] = 1, "🟢",
    "🔴"
)
```

**Propriedades:**
- **Nome:** Tickets Avaliados | Icone  
- **Tabela Inicial:** _medidas  
- **Sinônimo:** tickets avaliados | icone  
- **Oculto:** Não  
- **Formato:** Texto  
- **Separador de milhares:** Não  
- **Casas Decimais:** 0  
- **Categoria de Dados:** Não categorizado

</details>

---

## 🌞 Análise por Período do Dia

<details>
<summary><strong>🌅 Tickets Avaliados | Manhã</strong></summary>

```dax
CALCULATE(
    COUNTA(tabela_ticket[ticket_id]),
    tabela_ticket[Periodo_Dia] = "Manhã"
)
```

**Propriedades:**
- **Nome:** Tickets Avaliados | Manhã  
- **Tabela Inicial:** _medidas  
- **Sinônimo:** tickets avaliados | manhã  
- **Oculto:** Não  
- **Formato:** Número Inteiro  
- **Separador de milhares:** Não  
- **Casas Decimais:** 0  
- **Categoria de Dados:** Não categorizado

</details>

<details>
<summary><strong>🌇 Tickets Avaliados | Tarde</strong></summary>

```dax
CALCULATE(
    COUNTA(tabela_ticket[ticket_id]),
    tabela_ticket[Periodo_Dia] = "Tarde"
)
```

**Propriedades:**
- **Nome:** Tickets Avaliados | Tarde  
- **Tabela Inicial:** _medidas  
- **Sinônimo:** tickets avaliados | tarde  
- **Oculto:** Não  
- **Formato:** Número Inteiro  
- **Separador de milhares:** Não  
- **Casas Decimais:** 0  
- **Categoria de Dados:** Não categorizado

</details>

<details>
<summary><strong>🌃 Tickets Avaliados | Noite</strong></summary>

```dax
CALCULATE(
    COUNTA(tabela_ticket[ticket_id]),
    tabela_ticket[Periodo_Dia] = "Noite"
)
```

**Propriedades:**
- **Nome:** Tickets Avaliados | Noite  
- **Tabela Inicial:** _medidas  
- **Sinônimo:** tickets avaliados | noite  
- **Oculto:** Não  
- **Formato:** Número Inteiro  
- **Separador de milhares:** Não  
- **Casas Decimais:** 0  
- **Categoria de Dados:** Não categorizado

</details>
