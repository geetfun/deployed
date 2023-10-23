require "test_helper"

class DeployedTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert Deployed::VERSION
  end
end
