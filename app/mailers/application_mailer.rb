class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('MAILER_SENDER_EMAIL', 'accounts@chatwoot.com')
  layout 'mailer'
  append_view_path Rails.root.join('app/views/mailers')

  # helpers
  helper :frontend_urls
  helper do
    def global_config
      @global_config ||= GlobalConfig.get('BRAND_NAME', 'BRAND_URL')
    end
  end

  def smtp_config_set_or_development?
    ENV.fetch('SMTP_ADDRESS', nil).present? || Rails.env.development?
  end
end
