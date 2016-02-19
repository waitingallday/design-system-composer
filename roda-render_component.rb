# Deal with component
module RodaRenderComponent
  #
  module InstanceMethods
    def get_component(path, opts = {})
      @documents = {}
      raw_documents = []
      %w(md html slim).each do |ext|
        parent = File.join(opts[:components], path, "*.#{ext}")
        raw_documents << Dir.glob(parent)
      end

      raw_documents.flatten.sort.map do |f|
        section = File.basename(f)[0..1]

        case File.extname(f)
        when '.md' then
          render_markdown unless opts.include? :code_only
        when '.slim' then
          render_slim
        else
          render_html
        end
      end

      @documents
    end

    private

    def render_markdown
      @settings.merge! file_settings(f)
      render_method = !!@settings['no_section_wrap'] ? :render_markdown : :render_markdown_with_section
      if @documents[section]
        @documents[section] << send(render_method, file_content(f))
      else
        @documents[section] = [send(render_method, file_content(f))]
      end
    end

    def render_slim
      if basename_without_index_and_extension(f)[-9..-1] == 'no-source'
        source = ''
      else
        source = render_syntax_highlight(slim file_content(f), layout: false, pretty: true)
      end
      output = slim file_content(f), layout: false, pretty: true
      if @documents[section]
        @documents[section] << [title_from_filename(f), output, source]
      else
        @documents[section] = [[title_from_filename(f), output, source]]
      end
    end

    def render_html
      if basename_without_index_and_extension(f)[-9..-1] == 'no-source'
        source = ''
      else
        source = render_syntax_highlight(file_content(f))
      end
      output = file_content(f)
      if @documents[section]
        @documents[section] << [title_from_filename(f), output, source]
      else
        @documents[section] = [[title_from_filename(f), output, source]]
      end
    end
  end
end
