module PactBroker
  module Config
    class Setting < Sequel::Model(:config)

      def set_value_from(object)
        self.type = Setting.get_db_type(object)
        self.value = Setting.get_db_value(object)
        self
      end

      def value_object
        case type
        when 'json'
          JSON.parse(value, symbolize_names: true)
        when 'string'
          value
        when 'integer'
          Integer(value)
        when 'float'
          Float(value)
        when 'space_delimited_string_list'
          SpaceDelimitedStringList.parse(value)
        when 'boolean'
          value == "1"
        end
      end

      def self.get_db_value(object)
        case object
        when String, Integer, Float, NilClass
          object
        when TrueClass
          "1"
        when FalseClass
          "0"
        when SpaceDelimitedStringList
          object.to_s
        when Array, Hash
          object.to_json
        else
          nil
        end
      end

      def self.get_db_type(object)
        case object
          when true, false
            'boolean'
          when String, nil
            'string'
          when SpaceDelimitedStringList
            'space_delimited_string_list'
          when Array, Hash
            'json'
          when Integer
            'integer'
          when Float
            'float'
          else
            nil
          end
      end

    end

    Setting.plugin :timestamps, update_on_create: true
  end
end

# Table: config
# Columns:
#  id         | integer                     | PRIMARY KEY DEFAULT nextval('config_id_seq'::regclass)
#  name       | text                        | NOT NULL
#  type       | text                        | NOT NULL
#  value      | text                        |
#  created_at | timestamp without time zone | NOT NULL
#  updated_at | timestamp without time zone | NOT NULL
# Indexes:
#  config_pkey     | PRIMARY KEY btree (id)
#  unq_config_name | UNIQUE btree (name)
