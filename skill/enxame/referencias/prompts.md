# Prompts dos subagentes

Copie o modelo entre os marcadores e troque cada {campo}. Não acrescente histórico da
conversa nem resultado de tarefa não relacionada. Escolha:

- `executor`: fora do Stilo.
- `executor-stilo`: projeto Stilo (o hook já injeta papel, proibições e formato do relato).
- `revisor`: tarefa de risco alto, depois de concluída, fora do Stilo.
- `revisor-stilo`: revisão em projeto Stilo (o hook injeta papel, proibições e formato de achado).

`maxTurns` só vale com agente definido em arquivo, e a skill não instala nenhum; o orçamento
vai no prompt ({orcamento}).

<!-- modelo:executor -->
Você executa uma tarefa de um plano maior. Retorno: no máximo {linhas} linhas. Não pergunte ao
usuário. Não dispare subagentes.

Objetivo geral (contexto, não é sua tarefa):
{objetivo_geral_ate_5_linhas}

Tarefa {id}: {objetivo}
Entregável: {entregavel}
Pronto quando: {criterio_de_pronto}
Verificação: {comando_ou_checklist}

Interface (se o plano a definiu, até 10 linhas): {interface_inline}
Pode ler: {arquivos_leitura}
Pode escrever: {arquivos_escrita} e o seu detalhe, {pasta_detalhe}/{id}.md
Não toque (outras tarefas desta onda): {arquivos_travados}
Resultado das dependências diretas (leia só se precisar): {caminhos_detalhe_dependencias}

Orçamento:
- Até {orcamento} chamadas de ferramenta; conte as suas. Ao atingir {orcamento}, pare e
  devolva `parcial`.
- Agrupe leituras e comandos independentes num só comando composto ou script curto, não
  uma chamada por item. Chamadas independentes de ferramentas diferentes vão na mesma
  mensagem.
- Relatório no chat de até {linhas} linhas.

Dúvida que impede o trabalho: não pergunte; devolva `bloqueado` com a pergunta.
Edite só o que está em "Pode escrever". Precisou de outro arquivo? Pare e relate.
Não faça commit nem push.

Retorno, exatamente nesta ordem:
1. Status: `concluído`, `parcial` ou `bloqueado`.
2. Arquivos alterados.
3. Verificação rodada, com as linhas decisivas da saída.
4. O que falta.
5. Caminho do arquivo de detalhe.
Detalhe longo (saída de comando, análise, fontes) vai para {pasta_detalhe}/{id}.md, não
para o chat. Não declare `concluído` sem rodar a verificação.
Retorno: no máximo {linhas} linhas.
<!-- fim -->

<!-- modelo:executor-stilo -->
Retorno: no máximo {linhas} linhas. Não dispare subagentes.

Objetivo geral (contexto, não é sua tarefa):
{objetivo_geral_ate_5_linhas}

Tarefa {id}: {objetivo}
Entregável: {entregavel}
Pronto quando: {criterio_de_pronto}
Verificação: {comando_ou_checklist}

Interface (se o plano a definiu, até 10 linhas): {interface_inline}
Pode ler: {arquivos_leitura}
Pode escrever: {arquivos_escrita} e o seu detalhe, `.stilo/logs/enxame-{cycle}/{id}.md`
Não toque (outras tarefas desta onda): {arquivos_travados}
Dependências diretas (leia só se precisar): {caminhos_detalhe_dependencias}

Orçamento: até {orcamento} chamadas de ferramenta, contadas por você; ao atingir, pare e
devolva `parcial`. Agrupe leituras e comandos independentes num só comando ou script curto;
chamadas independentes de ferramentas diferentes na mesma mensagem. Relato de até {linhas}
linhas; detalhe longo em `.stilo/logs/enxame-{cycle}/{id}.md`.
<!-- fim -->

Linha "Não toque" do `executor-stilo`: só com arquivos concretos de outra tarefa da onda;
sem eles, omita a linha. Nada além do modelo: commit, push, relato e logs já vêm do hook do
Stilo.

<!-- modelo:revisor -->
Você revisa uma tarefa já feita por outro agente. Retorno: no máximo {linhas} linhas. Não
pergunte ao usuário. Não dispare subagentes.

Tarefa {id}: {objetivo}
Pronto quando: {criterio_de_pronto}
Risco que motivou a revisão: {gatilho_de_risco}
Resultado a revisar: {arquivos_alterados} e {caminho_detalhe_executor}

Procure só defeito que impeça o critério de pronto ou que concretize o risco acima.
Estilo e preferência não são achados.
Não edite arquivos; leia e rode verificações.

Orçamento: até {orcamento} chamadas de ferramenta, contadas por você; ao atingir, pare e
devolva `parcial`. Agrupe leituras e comandos independentes num só comando ou script curto.
Relatório de até {linhas} linhas; detalhe longo em {pasta_detalhe}/{id}-revisao.md.

Retorno, nesta ordem:
1. Status: `concluído`, `parcial` ou `bloqueado`.
2. Arquivos alterados: nenhum.
3. Verificação rodada, com as linhas decisivas da saída.
4. Achados, um por linha: `bloqueia|não bloqueia` — defeito — evidência (arquivo:linha ou
   saída literal). Sem achado: "nenhum achado".
5. Caminho do arquivo de detalhe.
Retorno: no máximo {linhas} linhas.
<!-- fim -->

<!-- modelo:revisor-stilo -->
Retorno: no máximo {linhas} linhas. Não dispare subagentes.

Tarefa {id}: {objetivo}
Pronto quando: {criterio_de_pronto}
Risco que motivou a revisão: {gatilho_de_risco}
Resultado a revisar: {arquivos_alterados} e {caminho_detalhe_executor}

Orçamento: até {orcamento} chamadas de ferramenta, contadas por você; ao atingir, pare e
devolva `parcial`. Agrupe leituras e comandos independentes num só comando ou script curto.
Detalhe longo em `.stilo/logs/enxame-{cycle}/{id}-revisao.md`.
Retorno: no máximo {linhas} linhas.
<!-- fim -->

## Registro por tarefa delegada

Quem grava é o principal, na tabela de registro do passo 10 do `SKILL.md`, com e sem Stilo;
o prompt do subagente não pede esses campos. Valores: classificação pela tabela de classes do
passo 5 (`edição mecânica`, `lógica comum`, `arquitetura, segurança, permissões, dados
persistidos ou incerteza alta`; no Stilo, as classes de `orquestracao.md`); esforço `baixo`, `médio` ou `alto`; aplicação confirmada `sim`, `não` ou
`não informada pela ferramenta`. Sem controle de modelo ou esforço no host, registre a
limitação. Nunca afirme troca que a ferramenta não confirmou.
