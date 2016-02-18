===========>用户方法
1,导出用户基本信息:根据 name or uid 查询出微博用户基本信息(weibo_users_by_name)
2,接口到处微博用户基本信息:根据uid查询出用户基本信息(weibo_users_api_by_uid)
3,用户互动量:根据 name or uid 导出每个微博用户的互动量(weibo_users_evaluate)列属性：uid 平均转发率 平均评论率 平均转发 平均评论 活跃度 原创占比 日均发帖量近七天发贴量
4,导出 微博用户 以及与 监控帐户互动 信息:根据 uid (weibo_user_forward)
5,导出微博名称:根据uid(names_to_uids)
6,提取微信基本信息:根据openId(weixin_user_api)
===========>微博互动方法
1,接口提取关键词微博:根据输入的关键词,和日期,可以选择最大的输出行数(search_weibo_interface_by_keywords_time)
2,监控帐号微博列表:根据uids(weibo_list_for_moniting)
3,接口提取微博列表:根据uids(weibo_list_over_api)
4,微博互动信息:根据urls(weibo_list_interactive_user)
5,互动人信息:根据urls(weibo_interactive_users_information)
6,监控帐号微博互动内容列表:根据urls(weibo_list_content)
7,接口提取微博互动内容列表:根据urls(weibo_list_interactive_content)
8,查看一些人与监控帐号互动:根据监控帐号uid,和微博用户uids
9,导出互动数:根据uid(weibo_interactives)注:可以根据监控帐号和主号进一步的筛选
10,互动人粉丝和:根据rul(weibo_interactives_fans_sum)
============>粉丝
1,监控帐号粉丝列表:根据uids(fans_list)注:可以根据日期进一步的筛选
2,接口提取粉丝列表:根据uids(fans_list_api)
3,判断一批人是否关注这个主号:根据uids和主号uid(weibo_user_relation)
4,判断一批人是否关注一些主号:根据uids和主号uids(weibo_users_users_relation)
============>其它
1,商用频道ITDM KOL 互动列表:根据keyword_id(itdm_kol_interaction)
2,Intel Biz Platform:根据urls,keyword(weibo_inter_biz_platform:娜娜)
3,导出time之前与商用频道互动次数:根据date (itdm_kol_interaction_count:张桢)
4,查看一些人与监控帐号互动:根据uids和监控帐号uid(weibo_user_interactive)
5,统计互动粉丝数:根据微博名称,uids,可以根据日期进一步的筛选(weibo_statistics_fans)
6,腾讯用户基本信息:根据openid(tqq_users_by_name)
7,腾讯用户互动量:根据openid(tqq_users_evaluate)
8,腾讯判断一批人是否关注主号:根据腾讯微博openid和主号uid
9,腾讯到处微博互动信息列表:根据urls(tqq_list_api_countent)
10,导出腾讯二次转平是否三次转发:根据urls(tqq_three_forwards)
