import { Meta, StoryObj } from '@storybook/react'

import MarkdownEditor from '.'

const meta = {
  title: 'Components/MarkdownEditor',
  component: MarkdownEditor,
} satisfies Meta<typeof MarkdownEditor>

export default meta

type Story = StoryObj<typeof meta>

export const Default: Story = {
  args: {
    label: 'Description',
  },
}
