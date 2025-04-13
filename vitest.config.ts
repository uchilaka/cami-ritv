import { defineConfig } from 'vitest/config'

import fs from 'fs'
import path from 'path'
import { parse } from 'comment-json'
import type { CompilerOptions } from 'typescript'

const tsConfigFile = path.join(path.resolve('./'), 'tsconfig.json')
const tsConfig = parse(fs.readFileSync(tsConfigFile).toString(), undefined, true) as Record<string, unknown>
const { paths } = tsConfig!.compilerOptions as CompilerOptions

console.debug(`Paths detected in TSConfig file: ${tsConfigFile}`, { paths })

export default defineConfig({
    test: {
        environment: 'jsdom', // or 'node'
        // TODO: review the eslint plugin https://github.com/saqqdy/eslint-plugin-vitest-globals#readme
        globals: true,
        // https://vitest.dev/config/#coverage
        coverage: {
            include: ['app/frontend/**/*'],
        },
    },
    resolve: {
        alias: {
            '@': path.resolve('./app/frontend'),
            '@/components': path.resolve('./app/frontend/components'),
            '@/features': path.resolve('./app/frontend/features'),
            '@/hooks': path.resolve('./app/frontend/hooks'),
            '@/pages': path.resolve('./app/frontend/pages')
        },
    },
})
