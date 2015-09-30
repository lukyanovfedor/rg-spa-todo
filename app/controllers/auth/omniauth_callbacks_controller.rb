module Auth
  class OmniauthCallbacksController < DeviseTokenAuth::OmniauthCallbacksController
    def assign_provider_attrs(resource, auth_hash)
      resource.email ||= auth_hash['info']['email']
      resource.first_name ||= auth_hash['info']['first_name']
      resource.last_name ||= auth_hash['info']['last_name']

      unless resource.image.file
        resource.remote_image_url = auth_hash['info']['image']
      end
    end

    def get_resource_from_auth_hash
      @resource = resource_class.where(provider: auth_hash['provider'], uid: auth_hash['uid']).first
      @resource ||= resource_class.where(email: auth_hash['info']['email']).first

      if @resource
        assign_provider_attrs(@resource, auth_hash)
      else
        @oauth_registration = true
        @resource = resource_class.new(
          provider: auth_hash['provider'],
          uid: auth_hash['uid']
        )

        set_random_password
        assign_provider_attrs(@resource, auth_hash)
      end

      @resource
    end
  end
end