require 'open-uri'
require 'net/https'

unless Rails.env.test? || Rails.env.development?
  module Net
    class HTTP
      alias_method :original_use_ssl=, :use_ssl=

      def use_ssl=(flag)
        self.ca_file = '/etc/pki/tls/certs/ca-bundle.crt'
        self.verify_mode = OpenSSL::SSL::VERIFY_PEER
        self.original_use_ssl = flag
      end
    end
  end
end