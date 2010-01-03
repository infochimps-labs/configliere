module Thimblerig
  #
  # Methods to add other elements -- hostname, ethernet MAC address, calling
  # script -- to the encrypt key
  #

  module Crypter
    #
    # identify the machine we're on
    #
    def self.hostname
      return @hostname if @hostname
      require "socket"
      @hostname = Socket.gethostname
    end
    def self.override_hostname str
      @hostname = str
    end
    def self.macaddr
      return @macaddr if @macaddr
      require "macaddr"
      @macaddr = Mac.addr
    end
    def self.override_macaddr str
      @macaddr = str
    end

    def self.encrypt_key thimble_key, options={}
      keyparts = {
        'hostname'   => optional_value(options[:hostname]){ Crypter.hostname },
        'macaddr'    => optional_value(options[:macaddr] ){ Crypter.macaddr  },
      }.compact.map{|part,val| "#{part}=#{CGI.escape(val)}" }.sort
      keyparts.unshift CGI.escape(thimble_key)
      Digest::SHA1.hexdigest(keyparts.join('&'))
    end
    def self.optional_value opt, &block
      case opt
      when false, nil then return
      when true       then yield()
      else return opt
      end
    end
  end
end
