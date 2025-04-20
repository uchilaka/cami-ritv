import { viteAliasConfigFromFactory } from '@/utils/aliasFactory'
import { describe, it, expect } from 'vitest'
import find from 'lodash.find'
import path from 'path'

/**
 * The following code is needed to get the __dirname variable in ESM:
 * https://iamwebwiz.medium.com/how-to-fix-dirname-is-not-defined-in-es-module-scope-34d94a86694d
 */
import { fileURLToPath } from 'url'
const __filename = fileURLToPath(import.meta.url) // get the resolved path to the file
const __dirname = path.dirname(__filename) // get the name of the directory

describe('aliasFactory', () => {
  const aliases = viteAliasConfigFromFactory()

  console.debug({ aliases })

  it('configures the @components alias', () => {
    const matcher = {
      find: '@/components/',
      replacement: path.resolve(__dirname, '../../frontend/components'),
    }
    expect(find(aliases, matcher)).toBeDefined()
  })

  it.skip('configures the @lib alias', () => {
    const matcher = {
      find: '@/lib',
      replacement: path.resolve(__dirname, '../../frontend/components/lib'),
    }
    expect(find(aliases, matcher)).toBeDefined()
  })

  it.skip('configures the @views alias', () => {
    const matcher = {
      find: '@/views',
      replacement: path.resolve(__dirname, '../../frontend/views'),
    }
    expect(find(aliases, matcher)).toBeDefined()
  })

  it.skip('configures the @entrypoints alias', () => {
    const matcher = {
      find: '@/entrypoints',
      replacement: path.resolve(__dirname, '../../frontend/entrypoints'),
    }
    expect(find(aliases, matcher)).toBeDefined()
  })

  it('configures the @hooks alias', () => {
    const matcher = {
      find: '@/hooks/',
      replacement: path.resolve(__dirname, '../../frontend/hooks'),
    }
    expect(find(aliases, matcher)).toBeDefined()
  })

  it('configures the @pages alias', () => {
    const matcher = {
      find: '@/pages/',
      replacement: path.resolve(__dirname, '../../frontend/pages'),
    }
    expect(find(aliases, matcher)).toBeDefined()
  })

  it.skip('configures the @routes alias', () => {
    const matcher = {
      find: '@/routes',
      replacement: path.resolve(__dirname, '../../frontend/routes'),
    }
    expect(find(aliases, matcher)).toBeDefined()
  })

  it('configures the @features alias', () => {
    const matcher = {
      find: '@/features/',
      replacement: path.resolve(__dirname, '../../frontend/features'),
    }
    expect(find(aliases, matcher)).toBeDefined()
  })
})
