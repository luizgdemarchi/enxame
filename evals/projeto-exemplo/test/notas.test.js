import { test } from 'node:test';
import assert from 'node:assert';
import { criarNota, listar } from '../src/notas.js';

test('criarNota devolve a nota criada', () => {
  const n = criarNota('ana', 'olá');
  assert.equal(n.autor, 'ana');
  assert.equal(n.texto, 'olá');
});

test('listar inclui a nota criada', () => {
  criarNota('bia', 'oi');
  assert.ok(listar().some((n) => n.autor === 'bia'));
});
