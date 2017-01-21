module Validable
  private

  def validate_arguments(data, options)
    validate_options options
    validate_data data
    array?(options, [:labels, :colors])
    validate_colors(data, options, :colors)
    validate_labels(data, options, :labels)
  end

  # rubocop:disable Style/AndOr
  def array?(options, keys)
    keys.each do |key|
      options[key] and
        options[key].is_a?(Array) ||
          raise(ArgumentError, "#{key} not an array")
    end
  end

  def validate_options(options)
    options.is_a?(Hash) or raise ArgumentError, 'Options missing'
    options[:outer_margin].nil? or options[:outer_margin].is_a?(Numeric) or
      raise(ArgumentError, 'outer_margin not a number')
  end

  def validate_data(data)
    data.empty? and raise(ArgumentError, 'Data missing')
    data.is_a?(Array) or raise ArgumentError, 'Data not an array'
  end # rubocop:enable Style/AndOr

  def validate_colors(data, options, key)
    options[key] &&
      options[key].any? && data.count > options[key].count &&
      raise(ArgumentError, "number of #{key} is too small")
  end

  def validate_labels(data, options, key)
    options[key] &&
      options[key].any? && (data.count != options[key].count) &&
      raise(ArgumentError, "number of #{key} does not match array")
  end
end

class Charts::Chart
  include Validable

  attr_reader :data, :options, :prepared_data, :renderer

  OPTIONS = { # rubocop:disable Style/MutableConstant
    title:            nil,
    type:             :svg,
    outer_margin:     30,
    background_color: 'white',
    labels:           [],
    colors:           [
      '#e41a1d',
      '#377eb9',
      '#4daf4b',
      '#984ea4',
      '#ff7f01',
      '#ffff34',
      '#a65629',
      '#f781c0',
      '#888888'
    ]
  }

  def initialize(data, opts = {})
    validate_arguments(data, opts)
    @data = data
    @options = default_options.merge opts
    create_options_methods
    initialize_instance_variables
    @prepared_data = prepare_data
  end

  def render
    pre_draw
    draw
    post_draw
  end

  def draw
    raise NotImplementedError
  end

  private

  def default_options
    OPTIONS
  end

  def draw_background
    renderer.rect(
      0, 0, width, height,
      fill:  background_color,
      class: 'background_color'
    )
  end

  def draw_title # rubocop:disable Metrics/AbcSize
    return unless options[:title]
    x = width / 2
    y = outer_margin / 2 + 2 * renderer.font_size / 5
    renderer.text options[:title], x, y, text_anchor: 'middle', class: 'title'
  end

  def initialize_instance_variables
  end

  def create_options_methods
    options.each do |key, value|
      define_singleton_method key, proc { value }
    end
  end

  def pre_draw
    @renderer = Charts::Renderer.new(self)
    draw_background
    draw_title
  end

  def post_draw
    renderer.post_draw
  end

  def prepare_data
    data
  end
end
