module DocumentMapper
  module YamlParsing
    def file_path=(file_path)
      file_path = File.expand_path(file_path)
      file_name = File.basename(file_path)
      extension = File.extname(file_path)
      attributes.update({
        :file_path => file_path,
        :file_name => file_name,
        :extension => extension.sub(/^\./, ''),
        :file_name_without_extension => File.basename(file_path, extension)
      })

      if !attributes.has_key? :date
        begin
          match = attributes[:file_name].match(/(\d{4})-(\d{1,2})-(\d{1,2}).*/)
          year, month, day = match[1].to_i, match[2].to_i, match[3].to_i
          attributes[:date] = Date.new(year, month, day)
        rescue NoMethodError => err
        end
      end

      if attributes.has_key? :date
        attributes[:year]  = attributes[:date].year
        attributes[:month] = attributes[:date].month
        attributes[:day]   = attributes[:date].day
      end

      after_load if respond_to?(:after_load)
    end

    def read_yaml(yaml)
      @content = yaml

      self.attributes ||= {}

      if @content =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
        @content = @content[($1.size + $2.size)..-1]
        attributes.update(YAML.load($1).symbolize_keys)
      end
    end

    def generate_accessors
      self.class.define_attribute_methods(attributes.keys)
      attributes.keys.each { |attr| self.class.define_read_method(attr) }
    end
  end
end
