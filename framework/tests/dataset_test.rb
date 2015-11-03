require 'minitest/autorun'
require '../dataflow/dataset'

describe ScriniumEsmDiag::Dataset do
  before do
    @dataset = ScriniumEsmDiag::Dataset.new
  end

  describe 'root method' do
    it 'sets @root instance variable only once' do
      @dataset.root '/foo/bar'
      @dataset.root.must_equal '/foo/bar'
      error = -> { @dataset.root '/bar/foo' }.must_raise RuntimeError
      error.message.must_equal 'root should only be set once!'
    end
  end

  describe 'raw method' do
    it 'sets @variables' do
      @dataset.raw :U, :V, :T, :Q
      @dataset.variables.size.must_equal 4
      @dataset.variables.keys.must_equal [ :U, :V, :T, :Q ]
      [ :U, :V, :T, :Q ].each do |x|
        @dataset.variables[x].class.must_equal Hash
        @dataset.variables[x].size.must_equal 0
      end
    end
  end

  describe 'rename method' do
    it 'sets rename item of a variable in @variables' do
      @dataset.rename :A => :a, :B => :b
      @dataset.variables.size.must_equal 2
      @dataset.variables[:A].class.must_equal Hash
      @dataset.variables[:A][:rename].must_equal :a
      @dataset.variables[:B].class.must_equal Hash
      @dataset.variables[:B][:rename].must_equal :b
    end
  end

  describe 'vinterp method' do
    it 'sets vinterp item of a variable in @variables' do
      @dataset.vinterp [ :A, :B ] => [ 1, 2 ], :B => [ 3 ]
      @dataset.variables.size.must_equal 2
      @dataset.variables[:A].class.must_equal Hash
      @dataset.variables[:A][:vinterp].class.must_equal Array
      @dataset.variables[:A][:vinterp].must_equal [ 1, 2 ]
      @dataset.variables[:B].class.must_equal Hash
      @dataset.variables[:B][:vinterp].class.must_equal Array
      @dataset.variables[:B][:vinterp].must_equal [ 1, 2, 3 ]
    end
  end
end
