class SpaceSerializer < ActiveModel::Serializer
  attributes :id, :name

  has_one :owner
end
