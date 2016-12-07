require 'spec_helper'

RSpec.describe GraphTool::CountGraph do
  let(:data) { [1] }
  let(:graph) { GraphTool::CountGraph.new(data, options) }
  let(:columns) { 2 }
  let(:item_width) { 20 }
  let(:item_height) { 20 }
  let(:inner_margin) { 0 }
  let(:outer_margin) { 0 }
  let(:colors) { ['green'] }
  let(:options) do
    {
      columns:      columns,
      item_width:   item_width,
      item_height:  item_height,
      inner_margin: inner_margin,
      outer_margin: outer_margin,
      colors:       colors
    }
  end

  describe '#default_options' do
    let(:graph) { GraphTool::CountGraph.new([1]) }
    it 'has a default item-colors' do
      expect(graph.colors).to eq([
        '#e41a1d',
        '#377eb9',
        '#4daf4b',
        '#984ea4',
        '#ff7f01',
        '#ffff34',
        '#a65629',
        '#f781c0',
        '#888888'
      ])
    end
    it 'has a default background-colors' do
      expect(graph.background_color).to eq('white')
    end
    it 'has a default file-type' do
      expect(graph.type).to eq(:svg)
    end
    it 'has a default item width of 20' do
      expect(graph.item_width).to eq(20)
    end
    it 'has a default item height of 20' do
      expect(graph.item_height).to eq(20)
    end
    it 'has a default inner-margin of 2px' do
      expect(graph.inner_margin).to eq(2)
    end
    it 'has a default outer-margin of 20px' do
      expect(graph.outer_margin).to eq(20)
    end
    it 'has 10 default columns' do
      expect(graph.columns).to eq(10)
    end
    context 'with item_width 40 and item_height 40 in the options' do
      let(:graph) { GraphTool::CountGraph.new(data, options) }
      let(:item_width) { 40 }
      let(:item_height) { 40 }
      it 'has the item_width in the options attribute' do
        expect(graph.item_width).to eq(40)
      end
      it 'has the item_height in the options attribute' do
        expect(graph.item_height).to eq(40)
      end
    end
  end

  describe '#background color' do
    it 'has a background_color attribute' do
      expect(graph).to respond_to(:background_color)
    end
  end

  describe 'inner margin' do
    it 'has a offset_x attribute' do
      expect(graph).to respond_to(:offset_x)
    end
    it 'has a offset_y attribute' do
      expect(graph).to respond_to(:offset_y)
    end
    it 'has a outer_item_width attribute' do
      expect(graph).to respond_to(:outer_item_width)
    end
    it 'has a outer_item_height attribute' do
      expect(graph).to respond_to(:outer_item_height)
    end
    it 'has a inner_margin attribute' do
      expect(graph).to respond_to(:inner_margin)
    end
    context 'width-margin of a single item' do
      let(:inner_margin) { 2 }
      it 'returns the correct outer_item_width' do
        expect(graph.outer_item_width).to eq(24)
      end
      it 'returns the correct offset_x' do
        expect(graph.offset_x(data.first)).to eq(24)
      end
    end
    context 'height-margin of a single item' do
      let(:item_height) { 20 }
      let(:inner_margin) { 2 }
      it 'returns the correct outer_item_height' do
        expect(graph.outer_item_height).to eq(24)
      end
      it 'returns the correct offset_y' do
        expect(graph.offset_y(data.first)).to eq(24)
      end
    end
    context 'width-margin of a several items' do
      let(:data) { [8] }
      let(:inner_margin) { 12 }
      it 'returns the correct outer_item_width' do
        expect(graph.outer_item_width).to eq(44)
      end
      it 'returns the correct offset_x' do
        expect(graph.offset_x(data.first)).to eq(352)
      end
    end
    context 'height-margin of a several items' do
      let(:data) { [8] }
      let(:item_height) { 40 }
      let(:inner_margin) { 12 }
      it 'returns the correct outer_item_height' do
        expect(graph.outer_item_height).to eq(64)
      end
      it 'returns the correct offset_y' do
        expect(graph.offset_y(data.first)).to eq(512)
      end
    end
  end

  describe '#initialize' do
    it 'provides default options' do
      graph = GraphTool::CountGraph.new([2])
      expect(graph.columns).to eq(10)
    end
    it 'merges default options with passed in options' do
      graph = GraphTool::CountGraph.new([2], extra: 123)
      expect(graph.columns).to eq(10)
      expect(graph.extra).to eq(123)
    end
    it 'raises an error when the data is not an array' do
      expect { GraphTool::CountGraph.new('x') }.to raise_error(ArgumentError)
    end
    it 'raises an error when value is not an Integer' do
      expect { GraphTool::CountGraph.new(['k']) }.to raise_error(ArgumentError)
    end
    it 'raises an error when a collection of values contains a Non-Integer' do
      expect { GraphTool::CountGraph.new([23, '@$']) }.to raise_error(ArgumentError)
    end
    it 'raises an error when the number of items does not match number of colors' do
      expect { GraphTool::CountGraph.new([14, 12, 66], colors: ['red', 'blue']) }.to raise_error(ArgumentError)
    end
  end

  describe '#prepare_data' do
    it 'creates the prepared_data for simple keys' do
      graph = GraphTool::CountGraph.new([3, 2], colors: %w(x o), columns: 2)
      expect(graph.prepared_data).to eq([
        ['x', 'x'],
        ['x', 'o'],
        ['o']
      ])
    end
    it 'creates the prepared_data for complex keys' do
      graph = GraphTool::CountGraph.new([2, 2], colors: ['#FF0000', '#00FF00'], columns: 2)
      expect(graph.prepared_data).to eq([
        ['#FF0000', '#FF0000'],
        ['#00FF00', '#00FF00']
      ])
    end
    it 'default colors get assigned when no colors are specified' do
      graph = GraphTool::CountGraph.new([1, 1, 1])
      expect(graph.prepared_data).to eq([
        ['#e41a1d', '#377eb9', '#4daf4b']
      ])
    end
  end

  describe '#height and #width' do
    it 'has a width attribute' do
      expect(graph).to respond_to(:width)
    end
    it 'has a height attribute' do
      expect(graph).to respond_to(:height)
    end
    shared_examples 'has a width and height of' do |width, height|
      it "sets the graph.width to #{width}" do
        expect(graph.width).to eq(width)
      end
      it "sets the graph.height to #{height}" do
        expect(graph.height).to eq(height)
      end
    end
    context 'one item' do
      include_examples 'has a width and height of', 20, 20
    end
    context 'one item with different item width' do
      let(:item_width) { 40 }
      let(:item_height) { 40 }
      include_examples 'has a width and height of', 40, 40
    end
    context 'one column two items' do
      let(:data) { [2] }
      let(:columns) { 1 }
      include_examples 'has a width and height of', 20, 40
    end
    context 'two columns two items' do
      let(:data) { [2] }
      include_examples 'has a width and height of', 40, 20
    end
  end

  describe '#item_height and #item_width' do
    it 'has a item width attribute' do
      expect(graph).to respond_to(:item_width)
    end
    it 'has a item height attribute' do
      expect(graph).to respond_to(:item_height)
    end
    context 'setup' do
      let(:data) { [2] }
      let(:item_width) { 50 }
      let(:item_height) { 50 }
      it 'item width gets correct value' do
        expect(graph.item_width).to eq(50)
      end
      it 'item height gets correct value' do
        expect(graph.item_height).to eq(50)
      end
    end
  end

  context 'A child class has not implemented the required methods' do
    class GraphTool::BogusCountGraph < GraphTool::CountGraph
    end

    it 'raises an exception when draw_item is called' do
      expect { GraphTool::BogusCountGraph.new([1]).draw_item(1, 2, :red) }.to raise_error(NotImplementedError)
    end
  end
end
