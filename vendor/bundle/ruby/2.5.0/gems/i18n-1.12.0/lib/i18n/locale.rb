# frozen_string_literal: true

module I18n
  module Locale
  autoload :Fallbacks, 'i18n/locale/fallbacks'
  autoload :Tag,       'i18n/locale/tag'
  I18n.locale = :ro
  end
end
