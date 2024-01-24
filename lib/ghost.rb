require "ghost/version"
require "ghost/client"
require "ghost/user_agent"
require "httpclient"

class HTTPClient::Session
  def set_header(req)
    if @requested_version
      if /^(?:HTTP\/|)(\d+.\d+)$/ =~ @requested_version
        req.http_version = $1
      end
    end
    if @agent_name && req.header.get('User-Agent').empty?
      req.header.set('User-Agent', @agent_name)
    end
    if @from && req.header.get('From').empty?
      req.header.set('From', @from)
    end
    if req.header.get('Accept').empty?
      req.header.set('Accept', '*/*')
    end
    if @transparent_gzip_decompression
      req.header.set('Accept-Encoding', 'gzip,deflate')
    end
    if req.header.get('Date').empty?
      req.header.set_date_header
    end
  end
end
