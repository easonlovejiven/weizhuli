# -*- encoding : utf-8 -*-
class PostWorker

  include Sidekiq::Worker
  sidekiq_options :queue => :post_weibo, :backtrace => true,  :retry=>6
  
  def perform(post_id)
    post = Post.find(post_id)
    return if post.doing?
    post.set(status:Post::STATUS_DOING)

    PostWeiboTask.new(post.weibo_uid, :appkey=>post.appkey,:post=>post).run if post
  end
end

