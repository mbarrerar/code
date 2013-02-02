# Monkey patch to workaround this bug: http://jira.codehaus.org/browse/JRUBY-6162

module Mail
  class Sendmail

    def initialize(values)
      self.settings = { :location       => '/usr/sbin/sendmail',
                        :arguments      => '-i -t' }.merge(values)
    end

    attr_accessor :settings

    def deliver!(mail)
      envelope_from = mail.return_path || mail.sender || mail.from_addrs.first
      return_path = "-f \"#{envelope_from.to_s.shellescape}\"" if envelope_from

      arguments = [settings[:arguments], return_path].compact.join(" ")

      Sendmail.call(settings[:location], arguments, mail.destinations.collect(&:shellescape).join(" "), mail)
    end

    def Sendmail.call(path, arguments, destinations, mail)
      # Original hack, using 'arguments' doesn't work
      # data = "#{path} #{arguments} #{destinations}"
      data = "#{path} #{destinations}"

      Rails.logger.debug("Sendmail.call(#{data})")
      Rails.logger.debug("#{mail}")

      IO.popen(data, "r+") do |io|
        io.puts mail.encoded.to_lf
        io.close_write  # <------ changed this from flush to close_write
        sleep 1 # <-------- added this line
      end
    end
  end
end
