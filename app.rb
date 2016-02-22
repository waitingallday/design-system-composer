require File.join(File.dirname(__FILE__), 'roda-helpers')
Roda.plugin RodaHelpers

require File.join(File.dirname(__FILE__), 'roda-render_component')
Roda.plugin RodaRenderComponent

#
class App < Roda
  use Rack::Session::Cookie, secret: ENV['SECRET']
  plugin :static, ['/assets']
  plugin :render, engine: 'slim'

  opts[:version] = ENV['VERSION']

  root = File.join(File.dirname(__FILE__))
  opts[:components_path] = File.join(root, 'assets', 'targets', 'components')
  opts[:components] = Dir.entries(opts[:components_path]).select { |f| f =~ /^[^\.|\_]*[^\.]$/ }

  route do |r|
    build_navigation

    r.root do
      view('homepage')
    end

    r.on 'components' do
      r.on :path do |path|
        if Dir.exist? File.join(root, 'assets', 'targets', 'components', path)
          @title = File.basename(path).capitalize
          @component = path
          @documents = get_component(path, components: opts[:components_path])
          view('components/show')
        end
      end

      r.is do
        view('components/index')
      end
    end

    r.on 'layouts' do
      r.on :path do |path|
        if File.exist? File.join(root, 'views', 'layouts', path + '.slim')
          @layout = true
          view('layouts/' + path)
        end
      end

      r.is do
        view('layouts/index')
      end
    end
  end

  private

  def build_navigation
    opts[:navigation] = []
    opts[:navigation] << {
      title: 'Page Templates', href: '/layouts', children: []
    }
    opts[:navigation] << {
      title: 'Component reference', href: '/components', children: []
    }
  end
end
