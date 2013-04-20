class UserSerializer < ActiveModel::Serializer
  attributes :bio, :email, :full_name
end
