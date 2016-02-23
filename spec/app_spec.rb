require File.expand_path('spec_helper', File.dirname(__FILE__))

describe 'r.run' do
  it 'should run the testing framework without exploding' do
  end

  it 'should respond on root' do
    app do |r|
      r.root do
        'Home'
      end
    end

    body.must_equal 'Home'
    status('REQUEST_METHOD' => 'POST').must_equal 404
    status('//').must_equal 404
    status('/foo').must_equal 404
  end

  it 'should get version from .env' do
    app.opts[:version].must_equal ENV['VERSION']
  end
end
