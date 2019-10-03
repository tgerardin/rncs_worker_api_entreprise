module TribunalCommerce
  module Helper
    class CSVReader
      def bulk_processing
        proceed do |batch|
          yield(batch)
        end
      end

      def line_processing
        proceed do |batch|
          batch.each do |line|
            yield(line)
          end
        end
      end

      def initialize(file, mapping, keep_nil: false, **)
        @file = file
        @options = default_options
        add_mapping_to_options(mapping)
        remove_blank_values unless keep_nil
      end

      def proceed
        ::File.open(@file, 'r:bom|utf-8') do |f|
          SmarterCSV.process(f, @options) do |batch|
            yield(batch)
          end
        end
      end

      def default_options
        {
          col_sep: ';',
          chunk_size: Rails.configuration.rncs_sources['import_batch_size'],
          force_simple_split: true,
          hash_transformations: [:none, remove_surrounding_quotes_and_blank],
          header_transformations: [:none, harmonize_headers]
        }
      end

      def add_mapping_to_options(mapping)
        @options[:header_transformations].push(key_mapping: mapping)
      end

      def remove_blank_values
        @options[:hash_transformations].push(:remove_blank_values)
      end

      def harmonize_headers
        proc do |headers|
          headers.map do |h|
            h.yield_self(&:downcase)
              .yield_self(&:strip)
              .yield_self { |it| it.gsub(/\s|-/, '_') }
              .yield_self { |it| it.gsub(/\./, '') }
              .yield_self { |it| it.gsub('"', '') }
              .yield_self { |it| I18n.transliterate(it) }
              .yield_self(&:to_sym)
          end
        end
      end

      def remove_surrounding_quotes_and_blank
        proc do |hash|
          hash.each_with_object({}) do |(k, v), cleaned_hash|
            cleaned_hash[k] = v.nil? ? v : v.gsub(/\A[" ]+|[" ]+\z/, '')
          end
        end
      end
    end
  end
end
