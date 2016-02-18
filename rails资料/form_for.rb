#form_for各种表单总结
1,新建一个资源：@person,post提交
  <%= form_for @person do |f|%>
    
    <%= f.lable :username%>
    <%= f.text_field :username%><br/>
    
    <%= f.lable :password%>
    <%= f.text_field :password%><br/>
    
    <%= f.submit%>
  <%end%>
2,form_for表单常用方法整理
(1),复选框:check_box (通常用在登录的比较多)
<%= f.label :remember_me, class: "checkbox inline" do %>
  <%= f.check_box :remember_me %>
  <span>记住我</span>
<% end %>
(2),颜色背景:color_field
<%= f.color_field :color%>
(3),日期组件:date_field
<%= f.date_field :birthday%>
(4),日期组件:datetime_field
<%= f.datetime_field :birthday%>
(5),邮箱组件:email_field
<%= f.email_field :birthday%>
956699386@qq.com
2,git分支练习总结
(1),git branch #查看有哪些分支
(2),git checkout 分支名 #分支间的切换
(3),git pull origin backbone/landing #取回远程主机某个分支的更新，再与本地的指定分支合并
(4),git push origin backbone/landing #本地修改完以后push上去
(5),git branch name #创建一个新的分支
git add -A
git commit -m 'add changes'
git push
grunt server 启动前端命令

github-key: 19:f2:f0:8f:f8:35:ef:25:38:d7:b7:0f:f2:fa:54:e1 jianhe.yuan@weizhuli.com
Agent pid 16983

service postgresql start 启动postgres服务
rails_best_practices . 监控rails代码
https://mailgun.com/app/domains/new 发送邮箱大三方服务(国内:SendCloud)


#把自己的项目push到github上
remote add origin https://github.com/easonlovejiven/keywords-filter.git
git remote -v
git Add -A
git commit -m 'init'
git push origin master
