# -*- encoding : utf-8 -*-
class Post
  include MongoMapper::Document
  
  STATUS_NEW = 0
  STATUS_DONE = 1
  STATUS_DOING = 2
  STATUS_FAILED = 3


  key :content,   String
  key :user_id,   Integer,    :required=>true
  key :weibo_uid, Integer
  key :weibo_id,  String
  key :appkey,   Integer
  key :post_at,   Time,       :default => lambda{Time.now}
  key :image_url,     String
  key :image_id,     String
  key :failed_error,    String  # internal error message
  key :failed_reason,   String  # human error message
  key :retries,   Integer  # retry times after failed
  key :category,    String
  key :geo,    String
  key :status,    Integer,    :default => 0

  key :tag1,  String
  key :tag2,  String
  key :tag3,  String
  key :tag4,  String
  key :tag5,  String
  key :tag6,  String


  key :mod,   String   # direct && forward
  key :forward_url,   String
  timestamps!
  
  after_create :create_post_job
  after_update :reschedule_job
  
  validates_presence_of :weibo_uid, :message=>"必须选择一个微博帐号"
  validates_presence_of :appkey, :message=>"weibo APPKEY required"
  validates_presence_of :content, :message=>"内容不能为空", :if=>lambda{|p|p.direct?}
  validate  :custom_validates
  
  scope :user_id, ->(user_id){ where(:user_id=>user_id)}
  scope :unpublished, ->{where(:status=>0)}
  scope :published, ->{where(:status=>1)}
  scope :search, ->(params={}) {
    params ||= {}
    scoped = where
    if params.has_key?(:mod)
      mod = params[:mod] == "forward" ? "forward" : nil
      scoped = where(mod:mod)
    end 

    scoped = scoped.published if params.has_key?(:published) 
    scoped = scoped.unpublished if params.has_key?(:unpublished) 
    
    scoped
  }
  
  
  def custom_validates
    #errors.add :weibo_uids, "必须选择一个微博帐号" if self.weibo_uids.blank?

    if status_changed?
      status_before, status_now = status_change
      if(![STATUS_NEW,nil].include?(status_before))
        errors.add(:base,"此条微博发送时间已过, 无法修改")
      end
    else
      if(![STATUS_NEW,nil].include?(status))
        errors.add(:base, "此条微博发送时间已过, 无法修改")
      end
    end
  end

  def create_post_job(at=nil)
    if at || self.post_at
      PostWorker.perform_at(self.post_at,self.id)
    else
      PostWorker.perform_async(self.id)
    end
  end

  def reschedule_job
    if(post_at_changed?)
      remove_scheduled_job
      create_post_job
    end
  end

  def retry_send
    self.create_post_job(self.post_at + (self.retries ** 4 + 15))
  end

  def done!
    self.set(status: STATUS_DONE)
  end

  def doing?
    status == STATUS_DOING
  end

  def done?
    status == STATUS_DONE
  end
  
  def failed!(failed_error)
    if (self.retries || 0) > 6
      self.set(status: STATUS_FAILED)
    else
      self.failed_error = failed_error
      self.retries ||= 0
      self.retries += 1
      self.save!
    end
    Notifier.post_error(self).deliver
  end
  
  def published?
    self.status == STATUS_DONE
  end
  

  def image_url(style=:thumb)
    urls = []
    if !image_id.blank?
      ids = image_id.split(",")
      urls = ids.map{|id|
        image = Image.find id
        image.attachment.url(style)
      }
    end
    urls
  end

  def direct?
    self.mod == nil
  end
  def forward?
    self.mod == "forward"
  end


  def url
    if  self.weibo_id
      return "http://weibo.com/#{self.weibo_uid}/#{WeiboMidUtil.mid_to_str(self.weibo_id)}"
    end
    nil
  end

  def remove_scheduled_job
    key = "schedule"
    Sidekiq.redis do |r| 
      jobs = r.zrange(key,0,-1)
      jobs.each{|job|

        j = JSON.parse(job)
        if j["queue"] == "post_weibo" && j["args"].include?(self.id.to_s)
          r.zrem(key,job)
        end
      }
    end
  end


end
