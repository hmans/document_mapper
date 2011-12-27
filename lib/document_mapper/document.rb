require 'active_model'

module DocumentMapper
  module Document
    extend ActiveSupport::Concern
    include ActiveModel::AttributeMethods
    include AttributeMethods::Read
    include ToHtml
    include YamlParsing

    attr_accessor :attributes, :content

    def ==(other_document)
      return false unless other_document.is_a? Document
      self.file_path == other_document.file_path
    end

    included do
      cattr_accessor :documents
      @@documents = []
    end

    module ClassMethods
      def reset
        self.documents = []
      end

      def reload
        self.reset
        # this method is overwritten by the *Store mixins.
      end

      def from_string(s)
        new.tap do |document|
          document.parse_content(s)
        end
      end

      def select(options = {})
        results = self.documents.dup
        options[:where].each do |selector, selector_value|
          results = results.select do |document|
            next unless document.attributes.has_key? selector.attribute
            document_value = document.send(selector.attribute)
            operator = OPERATOR_MAPPING[selector.operator]
            document_value.send operator, selector_value
          end
        end

        if options[:order_by].present?
          order_attribute = options[:order_by].keys.first
          asc_or_desc = options[:order_by].values.first
          results = results.select do |document|
            document.attributes.include? order_attribute
          end
          results = results.sort_by do |document|
            document.send order_attribute
          end
          results.reverse! if asc_or_desc == :desc
        end

        results
      end

      def where(hash)
        Query.new(self).where(hash)
      end

      def order_by(field)
        Query.new(self).order_by(field)
      end

      def offset(number)
        Query.new(self).offset(number)
      end

      def limit(number)
        Query.new(self).limit(number)
      end

      def all
        documents
      end

      def first
        documents.first
      end

      def last
        documents.last
      end

      def attributes
        documents.map(&:attributes).map(&:keys).flatten.uniq.sort
      end
    end
  end
end
