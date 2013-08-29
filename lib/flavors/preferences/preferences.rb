require 'active_support/concern'

module Flavors
  module Preferences
    extend ::ActiveSupport::Concern

    module ClassMethods
      def preference(name, options = {}, &callback)
        has_many :preferences, :as => :prefered, :class_name => "::Flavors::Preference"
        options[:type] ||= "string" #default

        if options[:type].to_s == "boolean"

          define_method(name) do
            value = read_preference(name, options[:default])
            value == "t" || value == true || value == :true
          end

          define_method("#{name}?") do
            value = read_preference(name, options[:default])
            value == "t" || value == true || value == :true
          end

          define_method("#{name}=") do |value|
            value = case value
            when 0, "0", "f", false then false
            else true
            end
            write_preference(name, value)
            callback.call(self, value) if callback
          end

        else

          define_method(name) do
            read_preference(name, options[:default])
          end

          define_method("#{name}=") do |value|
            write_preference(name, value)
            callback.call(self, value) if callback
          end

        end

      end
    end

    def read_preference(name, default = nil)
      if p = self.preferences.where(name: name).first
        p.value
      elsif default.present?
        default
      else
        nil
      end
    end

    def write_preference(name, value)
      p = self.preferences.where(name: name).first_or_create
      p.update_attribute(:value, value)
    end
  end
end
