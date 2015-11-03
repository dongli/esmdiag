require 'minitest/autorun'
require '../scrinium_esm_diag_framework'

describe ScriniumEsmDiag::Dataflow do
  describe 'create_dataset method' do
    it 'sets a dataset in @datasets' do
      ScriniumEsmDiag::Dataflow.model_data_root '/foo'
      ScriniumEsmDiag::Dataflow.model_id 'bar1'
      ScriniumEsmDiag::Dataflow.case_id 'bar2'
      ScriniumEsmDiag::Dataflow.create_dataset :monthly do
        root "#{model_data_root}/bar"
        raw :A, :B, :C
        rename :d => :D
        vinterp [ :A, :C ] => [ 1, 2 ], :B => 3
      end
      @dataflow = ScriniumEsmDiag::Dataflow.new
      @dataflow.model_data_root.must_equal '/foo'
      @dataflow.model_id.must_equal 'bar1'
      @dataflow.case_id.must_equal 'bar2'
      @dataflow.datasets.size.must_equal 1
      @dataflow.datasets[:monthly].class.must_equal ScriniumEsmDiag::Dataset
      @dataflow.datasets[:monthly].root.must_equal '/foo/bar'
      @dataflow.datasets[:monthly].variables[:d][:rename].must_equal :D
      @dataflow.datasets[:monthly].variables[:A][:vinterp].must_equal [ 1, 2 ]
    end
  end
end
