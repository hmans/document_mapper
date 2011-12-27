require 'open-uri'

module DocumentMapper
  module DropboxStore
    extend ActiveSupport::Concern

    module ClassMethods
      def reload
        self.reset
        load_documents_from_dropbox(@@source)
      end

      def load(url)
        self.from_string(open(url).read).tap do |document|
          document.file_path = url.gsub(/\?dl=1$/, '')
          document.after_load if document.respond_to?(:after_load)
          document.generate_accessors

          documents << document
        end
      end

      def load_documents_from_dropbox(index_url)
        json = open(index_url).read

        JSON.parse(json).each do |entry|
          url = "#{entry['url']}".gsub(/^https:/, "http:")
          puts url
          load(url)
        end
      end
    end
  end
end
