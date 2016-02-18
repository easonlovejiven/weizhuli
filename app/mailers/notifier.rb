# -*- encoding : utf-8 -*-
class Notifier < ActionMailer::Base
  default :from => "微助力 <notice@weizhuli.com>"
  default_url_options[:host] = "www.weizhuli.com"

  helper  :images

  def test(email)
    with_custom_smtp_settings do
      mail(:to=>email, :subject=>_("请激活您的微助力帐户"), :template_name=>"test_#{I18n.locale}")
    end
  end

  def password_reset_instructions(user, locale = :zh_CN)
    with_custom_smtp_settings do
      (I18n.locale = locale && FastGettext.locale = locale) if locale
      @reset_url = edit_password_reset_url(user.perishable_token, :l=>I18n.locale)
      mail(:to=>user.email, :subject=>_("请重设您的密码"), :template_name=>"password_reset_instructions_#{I18n.locale}")
    end
  end

  def activation_instructions(user, locale = :zh_CN)
    with_custom_smtp_settings do
      (I18n.locale = locale && FastGettext.locale = locale) if locale
      @activation_url = user_activate_url(user.default_user_token)
      mail(:from=>"report@weizhuli.com",:to=>user.email, :subject=>_('请激活您的微助力帐户'), :template_name=>"activation_instructions_#{I18n.locale}")
    end
  end

  
  def report(opts)
    email = opts[:to]
    subject = opts[:subject] || "Report"
    from = opts[:from] || default_params[:from]

    (opts[:attachments]||[]).each{|name,path|
      attachments[name] = File.read(path)
    }

    body = opts[:body]
    with_custom_smtp_settings do
      mail(:from=>from, :to=>email, :subject=>subject, body:body)
    end
  end


  # 互动 用户 监测 提醒
  def monit_interacts_warning(screen_name, interacts,mail_to)
    @interacts = interacts
    @screen_name = screen_name

    subject = "#{screen_name} 互动监控提醒"
    from = "微助力 <notice@weizhuli.com>"

    with_custom_smtp_settings do
      mail(:from=>from, :to=>mail_to, :subject=>subject)
    end
  end

  # 互动 数量 监测 提醒
  def monit_interacts_number_warning(screen_name,weibos,mail_to)
    @weibos = weibos
    @screen_name = screen_name
    subject = "#{screen_name} 互动量监控提醒"
    from = "微助力 <notice@weizhuli.com>"

    with_custom_smtp_settings do
      mail(:from=>from, :to=>mail_to, :subject=>subject)
    end
  end

  # 新增高质量粉丝 提醒
  def monit_fans_warning(screen_name, accounts, mail_to)
    @accounts = accounts
    @screen_name = screen_name
    subject = "#{screen_name} 新增高质量粉丝监控提醒"
    from = "微助力 <notice@weizhuli.com>"

    with_custom_smtp_settings do
      mail(:from=>from, :to=>mail_to, :subject=>subject)
    end
  end

  def intel_gift_apply_appove(mail_to,gift_apply)
    @gift_apply = gift_apply
    @approver = mail_to
    subject = "礼品使用申请 来自 - #{gift_apply.applyer.login}"
    from = "微助力 <notice@weizhuli.com>"

    with_custom_smtp_settings do
      mail(:from=>from, :to=>mail_to, :subject=>subject)
    end
  end










  def post_error(post)
    @post = post
    email = %w{huye@weizhuli.com zhangzhen@weizhuli.com}
    subject = "定时发送微博失败 #{post.id} | #{post.failed_error}"
    from = "Error Notifier<notice@weizhuli.com>"
    with_custom_smtp_settings do
      mail(:from=>from, :to=>email, :subject=>subject)
    end
  end

private

  def with_custom_smtp_settings(&block)
    # don't use multi SMTP account for now
    # self.smtp_settings.merge!($SMTP_ACCOUNTS[rand($SMTP_ACCOUNTS.size)])
    # puts self.smtp_settings.inspect
    yield
  end


end

