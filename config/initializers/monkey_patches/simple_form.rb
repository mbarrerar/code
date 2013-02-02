module SimpleForm
  module Inputs
    class Base
      private

      def valid_validator?(validator)
        cond_block = validator.options[:if]
        if cond_block
          cond_block.call(object) && action_validator_match?(validator)
        else
          action_validator_match?(validator)
        end
      end

    end
  end
end