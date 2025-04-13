import fs from 'fs'
import path from 'path'
import { parse } from 'comment-json'
import type { CompilerOptions } from 'typescript'

export const tsConfigFile = path.join(path.resolve('./'), 'tsconfig.app.json')

const tsConfig = parse(fs.readFileSync(tsConfigFile).toString(), undefined, true) as Record<string, unknown>

export const compilerOptions = tsConfig.compilerOptions as CompilerOptions

export default tsConfig
