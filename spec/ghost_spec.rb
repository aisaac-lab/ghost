require 'json'
require 'pry'

RSpec.describe Ghost do
  it "has a version number" do
    expect(Ghost::VERSION).not_to be nil
  end

  let(:maxwell) {
    Ghost::Client.new(
      proxy: {
        url:  ENV.fetch('URL'),
        user: ENV.fetch('USER'),
        pass: ENV.fetch('PASS'),
      },
      user_agent: user_agent
    )
  }

  let(:user_agent) { Ghost::UserAgent.random_get }

  example do
    res = maxwell.get('https://gogotanaka.me/')
    expect(res.body.empty?).to eq(false)
  end

  context 'UA test' do
    let(:user_agent) { 'hoge UA' }
    example 'UA' do
      res = maxwell.get('https://httpbin.org/get')
      expect(JSON.parse(res.body)['headers']['User-Agent']).to eq(user_agent)
    end
  end

  example do
    ips = 10.times.map {
      res = Ghost::Client.new(proxy: {
        url:  ENV.fetch('URL'),
        user: ENV.fetch('USER'),
        pass: ENV.fetch('PASS'),
      }).get('https://api.ipify.org?format=json')
      JSON.parse(res.body)['ip'].tap { |ip| puts ip }
    }

    expect(5 < ips.uniq.count).to eq(true)
  end

  example do
    res = maxwell.get('http://google.com/')
    expect(res).to eq(nil)

    res = maxwell.get('http://google.com/', need_redirect: true)
    expect(res.body.empty?).to eq(false)
  end
end
