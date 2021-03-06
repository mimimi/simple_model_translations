module SimpleModelTranslations
  class TranslationHelper
    def initialize(record, translation_association = :translations)
      @record = record
      @translation_association = translation_association
    end

    def find_translation_by_locale(locale)
      translations.detect { |t| t.locale.to_sym == locale }
    end

    def find_or_build_translation_by_locale(locale)
      find_translation_by_locale(locale) || build_translation_for_locale(locale)
    end

    def build_translation_for_locale(locale)
      translations.build(:locale => locale, foreign_object_key => @record)
    end

    def current_locale_for_translation
      I18n.locale
    end

    def default_locale_for_translation
      I18n.default_locale
    end

    def current_translation
      @current_translation || find_translation_by_locale(current_locale_for_translation) || find_translation_by_locale(default_locale_for_translation)
    end

    def find_or_build_current_translation
      find_or_build_translation_by_locale(current_locale_for_translation)
    end
    
    def force_translation_with_locale(locale)
      translation = 
        if translations.loaded?
          find_translation_by_locale(locale)
        else
          translations.find_by_locale(locale)
        end
      if translation
        @record.readonly!
        @current_translation = translation
      else
        raise ActiveRecord::RecordNotFound.new("Cannot use translation with locale '#{locale}' for object '#{@record}'")
      end
    end
    
    private
      def foreign_object_key
        @record.class.name.underscore.to_sym
      end
      
      def cached_translations
        @cached_translations ||= {}
      end
      
      def translations
        @record.send(@translation_association)
      end
  end
end