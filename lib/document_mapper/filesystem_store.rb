module DocumentMapper
  module FilesystemStore
    extend ActiveSupport::Concern

    module ClassMethods
      def reload
        self.reset
        load_documents_from_filesystem(@@path)
      end

      def load_documents_from_filesystem(path)
        raise FileNotFoundError unless File.directory?(path)
        reset

        @@path = path
        directory = Dir.new(File.expand_path(path))
        directory.each do |file|
          next if file[0,1] == '.'
          self.from_file([directory.path, file].join('/'))
        end
      end

      def directory=(path)
        load_documents_from_filesystem(path)
      end
    end
  end
end
