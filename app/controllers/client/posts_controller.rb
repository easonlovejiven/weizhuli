# -*- encoding : utf-8 -*-
class Client::PostsController < Client::ApplicationController
  layout "client"
  add_breadcrumb "Home", "/", title: "my link title"
  add_breadcrumb "微博运营", nil
  
  def index
    # init a @post for form
    # detect mod : direct or forward post
    @mod = params[:mod] == "forward" ? "forward" : nil
    @post = (params[:post_id] ? Post.find(params[:post_id]) : Post.new)
    if !@post.new_record?
      @mod = @post.mod
    else
      @post.mod = @mod
    end


    get_results = ->{
      query = ->{
          sort = (params[:search] && params[:search][:published]) ? -1 : 1
          @posts = Post.user_id(current_user.id).where(mod:@mod).search(params[:search]).order(post_at:sort).
                    paginate(:page=>params[:page], :per_page=>20)
           }
      query.call
      # fix error if :page big than total_pages
      if(params[:page].to_i>@posts.total_pages)
        params[:page] = @posts.total_pages; 
        query.call
      end
      @posts  
    }
    
    respond_to do |format|
      format.html {
        if request.xhr?
          get_results.call
          render :partial=>["list",@mod].compact.join("_")
        else
        end
      }
      format.json {
        get_results.call
        render :json=>@posts.as_json(:methods=>:image_url)
      }
    end
  end

  def show
    @post = Post.find(params[:id])
    render :json=>@post.as_json(:methods=>:image_url)
  end  
  
  def create
    @post = Post.new(params[:post])
    @post.content.strip!
    @post.user_id = current_user.id
    weibo_uid = current_user.authentications.weibo.first.uid
    @post.appkey = WeiboToken.find_by_uid(weibo_uid).appkey
    @post.weibo_uid = weibo_uid
    respond_to  do |format|
      format.html{}
      format.json{
        if @post.save
          render :json=>{:status=>:success,:object=>@post}
        else
          render :json=>{:status=>:error,:errors=>@post.errors}
        end
      }
    end
  end
  
  
  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    
    respond_to  do |format|
      format.html{
        redirect_to client_posts_path(:search=>{:unpublished=>true})
      }
      format.json{
        render :json=>{:status=>:success}
      }
    end
  end

  def update
    @post = Post.find(params[:id])
    @post.attributes = params[:post]
    @post.content.strip!
    @post.user_id = current_user.id
    weibo_uid = current_user.authentications.weibo.first.uid
    @post.appkey = WeiboToken.find_by_uid(weibo_uid).appkey
    @post.weibo_uid = weibo_uid
    respond_to  do |format|
      format.html{}
      format.json{
        if @post.save
          render :json=>{:status=>:success,:object=>@post}
        else
          render :json=>{:status=>:error,:errors=>@post.errors}
        end
      }
    end
  end




  def load_forward
    url = params[:url].strip
    uri = URI.parse(url)
    id = uri.path.split("/").last
    mid = WeiboMidUtil.str_to_mid(id)
    task = GetUserTagsTask.new
    weibo = task.api.statuses.show(id:mid)
    render :json=>weibo
  end
  
end
