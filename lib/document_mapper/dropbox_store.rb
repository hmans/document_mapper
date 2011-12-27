require 'open-uri'

module DocumentMapper
  module DropboxStore
    extend ActiveSupport::Concern

    module ClassMethods
      def reload
        self.reset
        load_documents_from_dropbox(@@source)
      end

      def fetch_url(url, options = {})
        if options[:cache]
          # puts "using cache: "+url
          cache_key = "#{url}:#{options[:modified]}"

          options[:cache].get(cache_key) || begin
            # puts "[miss]"
            open(url).read.tap do |response|
              options[:cache].set(cache_key, response)
            end
          end
        else
          # puts "skipping cache: "+url
          open(url).read
        end
      end

      def load(url, options = {})
        self.from_string(fetch_url(url, options)).tap do |document|
          document.file_path = url.gsub(/\?dl=1$/, '')
          document.after_load if document.respond_to?(:after_load)
          document.generate_accessors

          documents << document
        end
      end

      def load_documents_from_dropbox(index_url, options = {})
        json = open(index_url).read

        JSON.parse(json).each do |entry|
          url = "#{entry['url']}".gsub(/^https:/, "http:")
          load(url, options.merge(modified: entry['modified']))
        end
      end
    end
  end
end
