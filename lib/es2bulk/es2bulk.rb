require 'optparse'
require 'net/http'
require 'uri'
require 'json'

class Es2Bulk
  RETRIEVE_SIZE = 3000
  class Error < StandardError; end
  class EsConnectionError < Error; end
  class EsResponseError < Error; end

  def initialize(index_pattern, host = 'localhost', port = 9200, without_id)
    @index_pattern = index_pattern
    @host = host
    @port = port
    @without_id = without_id
  end

  def generate
    path = "/#{@index_pattern}/_search"
    search_after = nil
    total = 0
    connect
    routing_field = get_version >= '6.0.0' ? :routing : :_routing
    loop do
      body = { query: { match_all: {} }, sort: [:_uid], size: RETRIEVE_SIZE }
      body[:search_after] = search_after if search_after
      req = Net::HTTP::Post.new(path, 'Content-Type' => 'application/json')
      req.body = body.to_json
      response = request(req)
      result = JSON.parse(response.body, symbolize_names: true)
      if result[:error]
        raise EsResponseError, result[:error]
      end
      result[:hits][:hits].each do |hits|
        meta = { index: { _index: hits[:_index], _type: hits[:_type] } }
        meta[:index][routing_field] = hits[routing_field] if hits[routing_field]
        meta[:index][:_id] = hits[:_id] unless @without_id
        body = hits[:_source].sort.to_h
        yield meta, body
      end
      total += result[:hits][:hits].size
      break if result[:hits][:total] <= total

      search_after = result[:hits][:hits][-1][:sort]
    end
  end

  private

  def connect
    @http = Net::HTTP.start(@host, @port)
  rescue StandardError => e
    raise EsConnectionError, e.message
  end

  def request(req)
    @http.request(req)
  rescue StandardError => e
    raise EsResponseError, e.message
  end

  def get_version
    JSON.parse(@http.get('/').body, symbolize_names: true)[:version][:number]
  rescue JSON::ParserError => e
    raise EsResponseError, "JSON parse error: #{e.message}"
  rescue Net::HTTPExceptions => e
    raise EsResponseError, e.message
  end
end
