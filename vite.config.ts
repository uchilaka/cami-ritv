import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import ReactPlugin from '@vitejs/plugin-react'
import { viteAliasConfigFromFactory } from './app/frontend/utils/aliasFactory'

export default defineConfig({
  plugins: [
    RubyPlugin(),
    ReactPlugin(),
  ],
  resolve: {
    alias: viteAliasConfigFromFactory(),
  }
})
