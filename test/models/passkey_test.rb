require 'test_helper'

class PasskeyTest < ActiveSupport::TestCase
  def build_passkey(**overrides)
    Passkey.new({ user: users(:mathew), external_id: 'cred-1', public_key: 'key', label: 'iPhone' }.merge(overrides))
  end

  test 'is valid with a user, credential id, public key and label' do
    assert_predicate build_passkey, :valid?
  end

  test 'requires external_id, public_key and label' do
    passkey = build_passkey(external_id: nil, public_key: nil, label: nil)

    assert_not passkey.valid?
    assert_includes passkey.errors.attribute_names, :external_id
    assert_includes passkey.errors.attribute_names, :public_key
    assert_includes passkey.errors.attribute_names, :label
  end

  test 'external_id is unique' do
    build_passkey.save!

    assert_not build_passkey(user: users(:brooke)).valid?
  end

  test 'destroying a user destroys their passkeys' do
    build_passkey.save!

    assert_difference -> { Passkey.count }, -1 do
      users(:mathew).destroy!
    end
  end

  test 'user generates a stable webauthn_id once' do
    user = users(:mathew)

    assert_nil user.webauthn_id
    first = user.ensure_webauthn_id!
    assert_predicate first, :present?
    assert_equal first, user.ensure_webauthn_id!
    assert_equal first, user.reload.webauthn_id
  end
end
