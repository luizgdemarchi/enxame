const notas = [];

export function criarNota(autor, texto) {
  const nota = { id: notas.length + 1, autor, texto };
  notas.push(nota);
  return nota;
}

export function listar() {
  return [...notas];
}
