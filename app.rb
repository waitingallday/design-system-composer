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
  opts[:components] = Dir.entries(opts[:components_path])
  opts[:components] = opts[:components].select { |f| f =~ /^[^\.|\_]*[^\.]$/ }

  route do |r|
    build_navigation

    r.root do
      view('homepage')
    end

    # Component and index
    r.on 'components' do
      r.on :path do |path|
        if Dir.exist? File.join(opts[:components_path], path)
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

    # Complete layout, with source variant and index
    r.on 'layouts' do
      r.on :path do |path|
        f = File.join(root, 'views', 'layouts', path + '.slim')
        if File.exist? f
          @layout = true

          r.on 'source' do
            @file = path
            @source = convert_tags(slim(file_content(f)))
            view('layouts/source')
          end

          view('layouts/' + path)
        end
      end

      r.is do
        view('layouts/index')
      end
    end

    # Content page
    r.is :path do |path|
      basepath = File.join(root, 'views', 'pages', path)
      if File.exist? basepath + '.md'
        @content = markdown(file_content(basepath + '.md'))
        view('page')
      elsif File.exist? basepath + '.slim'
        @content = slim(file_content(basepath + '.slim'))
        view('page')
      elsif File.exist? basepath + '.slim.md'
        @content = markdown(slim(file_content(basepath + '.slim.md')))
        view('page')
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
