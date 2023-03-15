module Watir
  module Generator
    class Base
      def generate(spec_url, io = StringIO.new)
        @spec_url = spec_url
        @io = io

        extract_spec
        cleanup_spec

        write_header
        write_class_defs
        write_container_methods
        write_footer

        io
      end

      private

      def generator
        @generator ||= WebIDL::Generator.new(visitor)
      end

      def visitor
        @visitor ||= visitor_class.new
      end

      def extractor
        @extractor ||= extractor_class.new(@spec_url)
      end

      def extract_spec
        @tag2interfaces    = extractor.process
        @sorted_interfaces = extractor.sorted_interfaces

        raise "error extracting spec: #{extractor.errors.join("\n")}" if extractor.errors.any?
      end

      def cleanup_spec
        ignored_tags.each do |tag|
          @tag2interfaces.delete(tag)
        end

        ignored_interfaces.each do |interface|
          @sorted_interfaces.reject! { |intf| intf.name == interface }
        end

        @sorted_interfaces.each do |intf|
          intf.members.delete_if { |member| ignored_attributes.include?(member.name) }
        end
      end

      def write_header
        @io.puts "# Autogenerated from #{generator_implementation} specification. Edits may be lost."
        @io.puts 'module Watir'
      end

      def write_class_defs
        @sorted_interfaces.each do |interface|
          interface = generator.generate(interface)
          next if interface.empty?

          interface.gsub!(/^\s+\n/, '') # remove empty lines
          @io.puts indent(interface)
          @io.puts "\n"
        end
      end

      def write_container_methods
        @io.puts "\n"
        @io.puts indent('module Container')

        @tag2interfaces.sort.each do |tag, interfaces|
          raise "multiple interfaces for tag #{tag.inspect}" if interfaces.map(&:name).uniq.size != 1

          tag_string       = tag.inspect
          singular         = Util.paramify(visitor.classify_regexp, tag)
          plural           = singular.pluralize
          element_class    = Util.classify(visitor.classify_regexp, interfaces.first.name)
          collection_class = "#{element_class}Collection"

          # visitor.visit_tag(tag, interfaces.first.name) !?
          @io.puts indent(<<~CODE, 2)

            # @return [#{element_class}]
            def #{singular}(*args)
              #{element_class}.new(self, extract_selector(args).merge(tag_name: #{tag_string}))
            end
            # @return [#{collection_class}]
            def #{plural}(*args)
              #{collection_class}.new(self, extract_selector(args).merge(tag_name: #{tag_string}))
            end
            Watir.tag_to_class[#{tag.to_sym.inspect}] = #{element_class}

          CODE
        end

        @io.puts indent('end # Container')
      end

      def write_footer
        @io.puts 'end # Watir'
      end

      def indent(code, indent = 1)
        indent_string = '  ' * indent
        code.split("\n").map { |line| line.empty? ? line : indent_string + line }.join("\n")
      end
    end # Base
  end # Generator
end # Watir
