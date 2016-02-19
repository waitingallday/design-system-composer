# Custom helpers
module RodaHelpers
  #
  module InstanceMethods
    def path_to_title(path)
      return nil if path.nil? || path == ''
      path.gsub(/^todo-/, '').split('-').map(&:capitalize).join(' ')
    end

    def page_title
      return @settings['title'] if @settings && @settings.key?('title')
      path_to_title request.path_info.split('/').last
    end

    alias_method :component_title, :path_to_title
    alias_method :layout_title, :path_to_title

    def component_path(component)
      "/components/#{component.downcase}"
    end

    def layout_path(layout, opt = false)
      path = "/layouts/#{layout.downcase}"
      !!opt ? "#{path}?view=" + opt : path
    end

    def blank?
      self !~ /\S/
    end
  end
end
