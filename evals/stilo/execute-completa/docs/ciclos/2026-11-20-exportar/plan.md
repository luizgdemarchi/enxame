# Plano: exportar notas

### Tarefa T01 — Módulo de exportação
ID: T01
Especialista: backend
Files:
- Create: src/exportar.js
Depends-on: nenhum
Resources: nenhum

### Tarefa T02 — CLI exportar
ID: T02
Especialista: backend
Files:
- Create: src/cli.js
Depends-on: T01
Resources: nenhum

### Tarefa T03 — Prévia do JSON
ID: T03
Especialista: backend
Files:
- Create: test/previa-json.test.js
Depends-on: T05
Resources: port:127.0.0.1:4173

### Tarefa T04 — Prévia do CSV
ID: T04
Especialista: backend
Files:
- Create: test/previa-csv.test.js
Depends-on: T02, T03, T05
Resources: port:127.0.0.1:4173

### Tarefa T05 — Servidor de prévia
ID: T05
Especialista: backend
Files:
- Create: src/previa.js
Depends-on: T01
Resources: port:127.0.0.1:4173
