class RepositorySerializer < ActiveModel::Serializer
  attributes :id, :name, :space_name

  has_one :space
end
