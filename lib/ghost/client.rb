require 'csv'
require 'woothee'
require 'colorize'

module Ghost
  class Client
    def initialize(proxy: {}, user_agent: nil)
      agent_name = if user_agent.nil?
        Ghost::UserAgent.random_get
      else
        user_agent
      end
      logging 'UA', agent_name

      @client = if proxy.empty?
        HTTPClient.new(agent_name: agent_name)
      else
        HTTPClient.new(
          proxy: proxy.fetch(:url),
          agent_name: agent_name
        ).tap do |client|
          client.set_proxy_auth(proxy.fetch(:user), proxy.fetch(:pass))
        end
      end

      @client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    def get(url, need_redirect: false, max_try_count: 5)
      try = 0
      begin
        try += 1
        get_res(url, need_redirect)
      rescue => ex
        logging 'Fail', "#{try} #{ex.message}"
        sleep try ** 3 * 10
        retry if try < max_try_count
        raise ex
      end
    end

    private def get_res(url, need_redirect)
      logging 'GET', url
      res = @client.get(url)
      if res.redirect?
        logging 'redirecting...', ''
        if need_redirect
          logging 'need_redirect...', ''
          url2 = res.headers['location'] || res.headers['Location']
          unless url2.match(/http/)
            if url2.match(%r|\A/|)
              url2 = "#{URI(url).scheme}://#{URI(url).host}#{url2}"
            else
              raise "something wrong: url2=#{url2}"
            end
          end

          logging 'GET', url2
          res2 = @client.get(url2)
          res2
        else
          nil
        end
      else
        res
      end
    end

    private def logging(label, body)
      label_colored = "[#{label}]".colorize(:green)
      body_colored = "[#{body}]".colorize(:light_red)

      puts "#{label_colored}#{body_colored} #{Time.now.strftime('%m/%d %H:%M:%S')}"
    end
  end
end