module DocumentMapper
  module FilesystemStore
    extend ActiveSupport::Concern

    module ClassMethods
      def reload
        self.reset
        load_documents_from_filesystem(@@source)
      end

      def load(path)
        raise FileNotFoundError unless File.exist?(path)

        self.from_string(File.read(File.expand_path(path))).tap do |document|
          document.file_path = path
          document.after_load if document.respond_to?(:after_load)
          document.generate_accessors

          documents << document
        end
      end

      def load_documents_from_filesystem(path)
        raise FileNotFoundError unless File.directory?(path)

        reset

        @@source = path
        directory = Dir.new(File.expand_path(path))
        directory.each do |file|
          next if file[0,1] == '.'
          load([directory.path, file].join('/'))
        end
      end

      def directory=(path)
        load_documents_from_filesystem(path)
      end
    end
  end
end
