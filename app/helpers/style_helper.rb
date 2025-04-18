# frozen_string_literal: true

module StyleHelper
  # When appending to the primary and secondary button classes, you MUST override the default
  #   padding classes (px-# py-#) to ensure consistent padding within the buttons.
  def primary_btn_classes(append_classes = 'px-5 py-3 me-2')
    "btn #{append_classes} text-base font-medium text-white bg-gradient-to-br from-green-400 to-blue-600 " \
      'hover:bg-gradient-to-bl focus:ring-4 focus:outline-none focus:ring-green-200 dark:focus:ring-green-800 ' \
      'font-medium rounded-lg text-sm text-center mb-2'
  end

  # When appending to the primary and secondary button classes, you MUST override the default
  #   padding classes (px-# py-#) to ensure consistent padding within the buttons.
  def secondary_btn_classes(append_classes = 'px-5 py-3 me-2', style: :default)
    append_classes = append_classes.split.append(
      'hover:text-white border focus:ring-4 focus:outline-none',
      'font-medium rounded-lg text-sm text-center mb-2',
      'dark:hover:text-white'
    )
    case style
    when :danger
      append_classes.append(
        'text-red-700 border-red-700 hover:bg-red-800 focus:ring-red-300',
        'dark:border-red-500 dark:text-red-500 dark:hover:bg-red-600 dark:focus:ring-red-900'
      ).join(' ')
    else
      append_classes.append(
        'text-gray-800 border-gray-800 hover:bg-gray-900 focus:ring-gray-300',
        'dark:border-gray-600 dark:text-gray-400 dark:hover:bg-gray-600 dark:focus:ring-gray-800'
      ).join(' ')
    end
  end

  def item_action_btn_classes(style: :default)
    append_classes = [
      'text-xs font-medium hover:text-white border dark:hover:text-white focus:ring-4',
      'focus:outline-none focus:ring-blue-300 font-medium rounded-lg px-3 py-1.5 text-center me-2'
    ]
    case style
    when :danger
      append_classes.append(
        'text-red-700 border-red-700 hover:bg-red-800 focus:ring-red-300',
        'dark:border-red-500 dark:text-red-500 dark:hover:bg-red-600 dark:focus:ring-red-900'
      ).join(' ')
    else
      append_classes.append(
        'text-blue-700 border-blue-700 hover:bg-blue-800',
        'dark:border-blue-500 dark:text-blue-500 dark:hover:bg-blue-500 dark:focus:ring-blue-800'
      ).join(' ')
    end
  end

  def link_classes(*args)
    compose_class_names(
      'font-medium text-blue-600 dark:text-blue-500 hover:underline',
      args
    )
  end

  def badge_classes(*args)
    compose_class_names(
      'bg-purple-100 text-purple-800 text-xs font-medium dark:bg-purple-900 dark:text-purple-300',
      'px-2.5 py-0.5 me-2 rounded-full',
      args
    )
  end

  def default_item_action_btn_classes
    @default_action_btn_classes ||= item_action_btn_classes
  end

  def danger_item_action_btn_classes
    @danger_action_btn_classes ||= item_action_btn_classes(style: :danger)
  end

  def compose_class_names(*args)
    args.map { |arg| arg.is_a?(Hash) ? arg.map { |k, v| k if v }.compact : arg }.flatten.compact.join(' ')
  end
end
