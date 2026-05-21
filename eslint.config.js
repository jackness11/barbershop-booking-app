// ESLint 10 flat config.
// Usa FlatCompat para componer los presets legacy de eslint-config-next
// con la config de prettier. Funciona estable cross-version.
import { FlatCompat } from '@eslint/eslintrc';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const compat = new FlatCompat({
  baseDirectory: __dirname,
});

export default [
  ...compat.extends('next/core-web-vitals', 'next/typescript', 'prettier'),
  {
    ignores: ['.next/**', 'node_modules/**', 'next-env.d.ts', 'src/types/database.types.ts'],
  },
];
