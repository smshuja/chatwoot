require 'rails_helper'

RSpec.describe 'Platform Users API', type: :request do
  let!(:user) { create(:user) }

  describe 'GET /platform/api/v1/users/{user_id}' do
    context 'when it is an unauthenticated platform app' do
      it 'returns unauthorized' do
        get "/platform/api/v1/users/#{user.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an invalid platform app token' do
      it 'returns unauthorized' do
        get "/platform/api/v1/users/#{user.id}", headers: { api_access_token: 'invalid' }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated platform app' do
      let(:platform_app) { create(:platform_app) }

      it 'returns unauthorized when its not a permissible object' do
        get "/platform/api/v1/users/#{user.id}", headers: { api_access_token: platform_app.access_token.token }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'shows a user when its permissible object' do
        create(:platform_app_permissible, platform_app: platform_app, permissible: user)

        get "/platform/api/v1/users/#{user.id}",
            headers: { api_access_token: platform_app.access_token.token }, as: :json

        expect(response).to have_http_status(:success)
        data = JSON.parse(response.body)
        expect(data['email']).to eq(user.email)
      end
    end
  end

  describe 'GET /platform/api/v1/users/{user_id}/login' do
    context 'when it is an unauthenticated platform app' do
      it 'returns unauthorized' do
        get "/platform/api/v1/users/#{user.id}/login"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an invalid platform app token' do
      it 'returns unauthorized' do
        get "/platform/api/v1/users/#{user.id}/login", headers: { api_access_token: 'invalid' }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated platform app' do
      let(:platform_app) { create(:platform_app) }

      it 'returns unauthorized when its not a permissible object' do
        get "/platform/api/v1/users/#{user.id}/login", headers: { api_access_token: platform_app.access_token.token }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'return login link for user' do
        create(:platform_app_permissible, platform_app: platform_app, permissible: user)

        get "/platform/api/v1/users/#{user.id}/login",
            headers: { api_access_token: platform_app.access_token.token }, as: :json

        expect(response).to have_http_status(:success)
        data = JSON.parse(response.body)
        expect(data['url']).to include('sso_auth_token')
      end
    end
  end

  describe 'POST /platform/api/v1/users/' do
    context 'when it is an unauthenticated platform app' do
      it 'returns unauthorized' do
        post '/platform/api/v1/users'
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an invalid platform app token' do
      it 'returns unauthorized' do
        post '/platform/api/v1/users/', headers: { api_access_token: 'invalid' }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated platform app' do
      let(:platform_app) { create(:platform_app) }

      it 'creates a new user and permissible for the user' do
        post '/platform/api/v1/users/', params: { name: 'test', email: 'test@test.com', password: 'password123' },
                                        headers: { api_access_token: platform_app.access_token.token }, as: :json

        expect(response).to have_http_status(:success)
        data = JSON.parse(response.body)
        expect(data['email']).to eq('test@test.com')
        expect(platform_app.platform_app_permissibles.first.permissible_id).to eq data['id']
      end

      it 'fetch existing user and creates permissible for the user' do
        create(:user, name: 'old test', email: 'test@test.com')
        post '/platform/api/v1/users/', params: { name: 'test', email: 'test@test.com', password: 'password123' },
                                        headers: { api_access_token: platform_app.access_token.token }, as: :json

        expect(response).to have_http_status(:success)
        data = JSON.parse(response.body)
        expect(data['name']).to eq('old test')
        expect(platform_app.platform_app_permissibles.first.permissible_id).to eq data['id']
      end
    end
  end

  describe 'PATCH /platform/api/v1/users/{user_id}' do
    context 'when it is an unauthenticated platform app' do
      it 'returns unauthorized' do
        patch "/platform/api/v1/users/#{user.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an invalid platform app token' do
      it 'returns unauthorized' do
        patch "/platform/api/v1/users/#{user.id}", headers: { api_access_token: 'invalid' }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated platform app' do
      let(:platform_app) { create(:platform_app) }

      it 'returns unauthorized when its not a permissible object' do
        patch "/platform/api/v1/users/#{user.id}", params: { name: 'test' },
                                                   headers: { api_access_token: platform_app.access_token.token }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it 'updates the user' do
        create(:platform_app_permissible, platform_app: platform_app, permissible: user)
        patch "/platform/api/v1/users/#{user.id}", params: { name: 'test123' },
                                                   headers: { api_access_token: platform_app.access_token.token }, as: :json

        expect(response).to have_http_status(:success)
        data = JSON.parse(response.body)
        expect(data['name']).to eq('test123')
      end
    end
  end
end
