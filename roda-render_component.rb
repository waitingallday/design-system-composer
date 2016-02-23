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

      raw_documents.flatten.sort.map { |f| get_section(f) }

      @documents
    end

    def get_section(f)
      section = File.basename(f)[0..1]
      @documents[section] = [] unless @documents[section]
      @documents[section] << process_section(f)
    end

    def process_section(f)
      case File.extname(f)
      when '.md' then
        build_markdown(f) unless opts.include? :code_only
      when '.slim' then
        build_slim(f)
      else
        build_html(f)
      end
    end

    private

    # Render block through tilt template
    def slim(content, scope = self)
      Slim::Template.new(pretty: true) { content }.render(scope)
    end

    # Render block through tilt template
    def markdown(content)
      Tilt::RedcarpetTemplate.new { content }.render
    end

    # Render slim
    def build_slim(f)
      source = basename_without_index_and_extension(f)[-9..-1] == 'no-source'
      source = render_source_block(slim(file_content(f))) unless source
      output = slim(file_content(f))

      [title_from_filename(f), output, source]
    end

    def build_html(f)
      source = basename_without_index_and_extension(f)[-9..-1] == 'no-source'
      source = render_source_block(file_content(f)) unless source
      output = file_content(f)

      [title_from_filename(f), output, source]
    end

    def build_markdown(f)
      markdown(file_content(f))
    end

    # Predefined block for displaying example source
    def render_source_block(block)
      '
    <section class="code"><ul class="accordion">
      <li>
        <span class="accordion__title">Sample Markup</span>
        <div class="accordion__hidden"><pre><code class="html">
' + convert_tags(block) + '
        </code></pre></div>
      </li>
    </ul></section>
'
    end

    # Parse front matter and cache
    def front_matter(file)
      @front_matters ||= {}
      unless @front_matters.key? file
        @front_matters[file] = FrontMatterParser.parse_file(file)
      end
      @front_matters[file]
    end

    def file_settings(file)
      front_matter(file).front_matter
    end

    def file_content(file)
      front_matter(file).content
    end

    # Prep tag block for html display
    def convert_tags(block = '')
      block = yield if block_given?
      block.gsub('<', '&lt;').gsub('>', '&gt;')
    end
  end
end
