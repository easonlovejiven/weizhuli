class SmsCode < ActiveRecord::Base
  attr_accessible :mobile


  before_create   :init_values
  after_create  :create_delay_job

  validates :mobile,  :presence=>true


  def init_values
    self.code = generate_code
    self.status = 2 # not validated
    self.expires_at = (Time.now+0.5.hours).to_i
  end

  def generate_code
    c = []
    4.times{c << rand(10)}
    c*""
  end

  def create_delay_job
    SmsCodeWorker.perform_async(self.id, self.mobile)
  end
end
