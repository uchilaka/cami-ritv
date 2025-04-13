import path from 'path'
import omit from 'lodash.omit'
import uniqBy from 'lodash.uniqby'

import { compilerOptions } from './tsConfig'

// const tsConfigFile = path.join(path.resolve('./'), 'tsconfig.app.json')
// const tsConfig = parse(fs.readFileSync(tsConfigFile).toString(), undefined, true) as Record<string, unknown>
// const compilerOptions = tsConfig.compilerOptions as CompilerOptions

interface AliasSet {
  aliases: string[]
  replacement: string
}

interface ModuleAlias {
  find: string
  replacement: string
}

type SupportedTsPathPattern = Record<string, string[]>

/**
 * IMPORTANT: DO NOT EXPORT THIS IN THE index.ts FILE! These are helper functions
 *   for Vite configuration - not for the application code.
 */
export const aliasFactory = () => {
  const pathsToProcess = omit(compilerOptions.paths as SupportedTsPathPattern, ['@/*']) as SupportedTsPathPattern
  return Object.entries(pathsToProcess).map<AliasSet>(([find, [replacement]]) => {
    const findWithoutAsterisk = find.replace(/\*$/, '')
    const replacementEndsWithSlash = replacement.endsWith('/')
    const replacementWithoutAsterisk = path.resolve(__dirname, `../../../${replacement.replace(/\*$/, '')}`)
    /**
     * TODO: It doesn't seem migrating over to this variant (e.g. @component instead of @/component)
     *   is working. Investigate why and fix it - or more likely simplify this code a bit by skipping
     *   the generation of the alternative find.
     */
    const altFind = findWithoutAsterisk.replace(/^@\//, '@')
    return { aliases: [findWithoutAsterisk, altFind], replacement: `${replacementWithoutAsterisk}${replacementEndsWithSlash ? '/' : ''}` }
  })
}

export const viteAliasConfigFromFactory = () =>
  uniqBy(
    aliasFactory().reduce<ModuleAlias[]>(
      (acc, { aliases, replacement }) => [...acc, ...aliases.map((find) => ({ find, replacement }))],
      [],
    ),
    'find',
  )
