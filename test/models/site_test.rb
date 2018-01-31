require 'test_helper'

class SiteTest < ActiveSupport::TestCase

  def request_mock url, status=443, headers={}

    stub_request(:get , @one.url ).
      with(  headers: {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent'=>'Faraday v0.12.2'
    }).
    to_return(status: 443, body: "", headers: {})

  end


  setup do

    @one=sites(:one)
    request_mock @one.url

  end

  test "#check" do
    assert @one.check
    assert_equal 443, @one.status
  end

end
