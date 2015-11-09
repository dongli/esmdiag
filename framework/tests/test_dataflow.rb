require 'minitest/autorun'
require '../scrinium_esm_diag_framework'

describe ScriniumEsmDiag::Dataflow do
  describe 'create_dataset method' do
    it 'sets a dataset in @datasets' do
      module ScriniumEsmDiag
        class Dataflow_test < Dataflow
          create_dataset :monthly do
            root "/foo/bar"
            requires :A, :B, :C
            vinterp :A, :C, :on => [ 1, 2 ]
            anomaly :all
          end
        end
      end
      @dataflow = ScriniumEsmDiag::Dataflow_test.new
      @dataflow.datasets.size.must_equal 1
      @dataflow.datasets[:monthly].class.must_equal ScriniumEsmDiag::Dataset
      @dataflow.datasets[:monthly].root.must_equal '/foo/bar'
      @dataflow.datasets[:monthly].variables[:A][:vinterp].must_equal :on => [ 1, 2 ]
      @dataflow.datasets[:monthly].variables[:A][:anomaly].must_equal nil
      @dataflow.datasets[:monthly].variables[:B][:anomaly].must_equal nil
      @dataflow.datasets[:monthly].variables[:C][:anomaly].must_equal nil
    end
  end
end
