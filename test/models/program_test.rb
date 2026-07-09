require 'test_helper'

class ProgramTest < ActiveSupport::TestCase
  test 'rejects a duplicate name' do
    Program.create!(name: 'Crossfit.com')
    duplicate = Program.new(name: 'Crossfit.com')

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], 'has already been taken'
  end
end
