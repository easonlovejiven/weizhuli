# -*- encoding : utf-8 -*-
class Client::NewsController < Client::ApplicationController

  layout  'client/simple'


  def index
    @today_focus_news = News.with_tag_name("ce_news_today_focus").first
    @today_news = News.with_tag_name("ce_news_today_news").limit(6)
    @best_news = News.with_tag_name("ce_news_best_news").limit(6)
    @hottest_news = News.order("views desc").limit(10)
    @latest_news = News.order("id desc").limit(10)
    
    @influential_users = User.order("id desc").limit(4)
    @industries = Industry.publish.all
    @html_title = _('新闻首页')
  end
  
  def list 
    
    @industry = Industry.find(params[:industry_id])
    
    @news = @industry.news.order("id desc").paginate(:page=>params[:page],:per_page=>15)
    
		@tags = Tag.public.order("id desc").limit(12)
		@influential_users = User.order("id desc").limit(5)
    @industries = Industry.publish.all
    @related_news = @industry.news.order("id desc").limit(10)
    @hot_news = @industry.news.order("views desc").limit(10)
    @html_title = _('新闻列表')
  end

  def show
    @news = News.find(params[:id])
    @related_news = News.order("id desc").limit(10)
    @hot_news = News.order("views desc").limit(10)
    @users = User.order("id desc").limit(8)
    @news.update_attributes(@news.views += 1)
    @industries = Industry.publish.all
    @industry = @news.industry
    @html_title = @news.title
    
    # for comments
    @content = @news
    @comment = Comment.new(:target=>@content)
  end


  def dashboard
    @news = News.order("id desc").paginate(:page=>params[:page],:per_page=>20)
    @html_title = _('News dashboard')
    render  :layout=>"client/dashboard"
  end

end
