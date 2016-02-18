var all_provinces = [{"001011":"北京"},{"001012":"天津"},{"001013":"河北"},{"001014":"山西"},{"001015":"内蒙古"},{"001021":"辽宁"},{"001022":"吉林"},{"001023":"黑龙江"},{"001031":"上海"},{"001032":"江苏"},{"001033":"浙江"},{"001034":"安徽"},{"001035":"福建"},{"001036":"江西"},{"001037":"山东"},{"001041":"河南"},{"001042":"湖北"},{"001043":"湖南"},{"001044":"广东"},{"001045":"广西"},{"001046":"海南"},{"001050":"重庆"},{"001051":"四川"},{"001052":"贵州"},{"001053":"云南"},{"001054":"西藏"},{"001061":"陕西"},{"001062":"甘肃"},{"001063":"青海"},{"001064":"宁夏"},{"001065":"新疆"},{"001071":"台湾"},{"001081":"香港"},{"001082":"澳门"}];
var all_cities = {
  "11":[{"001011001":"东城"},{"001011002":"西城"},{"001011003":"崇文"},{"001011004":"宣武"},{"001011005":"朝阳"},{"001011006":"丰台"},{"001011007":"石景山"},{"001011008":"海淀"},{"001011009":"门头沟"},{"001011011":"房山"},{"001011012":"通州"},{"001011013":"顺义"},{"001011014":"昌平"},{"001011015":"大兴"},{"001011016":"怀柔"},{"001011017":"平谷"},{"001011028":"密云"},{"001011029":"延庆"}],
  "12":[{"001012001":"和平区"},{"001012002":"河东区"},{"001012003":"河西区"},{"001012004":"南开区"},{"001012005":"河北区"},{"001012006":"红桥区"},{"001012007":"塘沽区"},{"001012008":"汉沽区"},{"001012009":"大港区"},{"001012010":"东丽区"},{"001012011":"西青区"},{"001012012":"津南区"},{"001012013":"北辰区"},{"001012014":"武清区"},{"001012015":"宝坻区"},{"001012021":"宁河县"},{"001012023":"静海县"},{"001012025":"蓟县"},{"001012026":"滨海新区"},{"001012027":"保税区"}],
  "13":[{"001013001":"石家庄"},{"001013002":"唐山"},{"001013003":"秦皇岛"},{"001013004":"邯郸"},{"001013005":"邢台"},{"001013006":"保定"},{"001013007":"张家口"},{"001013008":"承德"},{"001013009":"沧州"},{"001013010":"廊坊"},{"001013011":"衡水"}],
  "14":[{"001014001":"太原"},{"001014002":"大同"},{"001014003":"阳泉"},{"001014004":"长治"},{"001014005":"晋城"},{"001014006":"朔州"},{"001014007":"晋中"},{"001014008":"运城"},{"001014009":"忻州"},{"001014010":"临汾"},{"001014023":"吕梁"}],
  "15":[{"001014001":"太原"},{"001014002":"大同"},{"001014003":"阳泉"},{"001014004":"长治"},{"001014005":"晋城"},{"001014006":"朔州"},{"001014007":"晋中"},{"001014008":"运城"},{"001014009":"忻州"},{"001014010":"临汾"},{"001014023":"吕梁"}],
  "21":[{"001021001":"沈阳"},{"001021002":"大连"},{"001021003":"鞍山"},{"001021004":"抚顺"},{"001021005":"本溪"},{"001021006":"丹东"},{"001021007":"锦州"},{"001021008":"营口"},{"001021009":"阜新"},{"001021010":"辽阳"},{"001021011":"盘锦"},{"001021012":"铁岭"},{"001021013":"朝阳"},{"001021014":"葫芦岛"}],
  "22":[{"001022001":"长春"},{"001022002":"吉林"},{"001022003":"四平"},{"001022004":"辽源"},{"001022005":"通化"},{"001022006":"白山"},{"001022007":"松原"},{"001022008":"白城"},{"001022024":"延边朝鲜族自治州"}],
  "23":[{"001023001":"哈尔滨"},{"001023002":"齐齐哈尔"},{"001023003":"鸡西"},{"001023004":"鹤岗"},{"001023005":"双鸭山"},{"001023006":"大庆"},{"001023007":"伊春"},{"001023008":"佳木斯"},{"001023009":"七台河"},{"001023010":"牡丹江"},{"001023011":"黑河"},{"001023012":"绥化"},{"001023027":"大兴安岭"}],
  "31":[{"001031001":"黄浦区"},{"001031003":"卢湾区"},{"001031004":"徐汇区"},{"001031005":"长宁区"},{"001031006":"静安区"},{"001031007":"普陀区"},{"001031008":"闸北区"},{"001031009":"虹口区"},{"001031010":"杨浦区"},{"001031012":"闵行区"},{"001031013":"宝山区"},{"001031014":"嘉定区"},{"001031015":"浦东新区"},{"001031016":"金山区"},{"001031017":"松江区"},{"001031018":"青浦区"},{"001031019":"南汇区"},{"001031020":"奉贤区"},{"001031030":"崇明区"}],
  "32":[{"001032001":"南京"},{"001032002":"无锡"},{"001032003":"徐州"},{"001032004":"常州"},{"001032005":"苏州"},{"001032006":"南通"},{"001032007":"连云港"},{"001032008":"淮安"},{"001032009":"盐城"},{"001032010":"扬州"},{"001032011":"镇江"},{"001032012":"泰州"},{"001032013":"宿迁"}],
  "33":[{"001033001":"杭州"},{"001033002":"宁波"},{"001033003":"温州"},{"001033004":"嘉兴"},{"001033005":"湖州"},{"001033006":"绍兴"},{"001033007":"金华"},{"001033008":"衢州"},{"001033009":"舟山"},{"001033010":"台州"},{"001033011":"丽水"}],
  "34":[{"001034001":"合肥"},{"001034002":"芜湖"},{"001034003":"蚌埠"},{"001034004":"淮南"},{"001034005":"马鞍山"},{"001034006":"淮北"},{"001034007":"铜陵"},{"001034008":"安庆"},{"001034010":"黄山"},{"001034011":"滁州"},{"001034012":"阜阳"},{"001034013":"宿州"},{"001034014":"巢湖"},{"001034015":"六安"},{"001034016":"亳州"},{"001034017":"池州"},{"001034018":"宣城"}],
  "35":[{"001035001":"福州"},{"001035002":"厦门"},{"001035003":"莆田"},{"001035004":"三明"},{"001035005":"泉州"},{"001035006":"漳州"},{"001035007":"南平"},{"001035008":"龙岩"},{"001035009":"宁德"}],
  "36":[{"001036001":"南昌"},{"001036002":"景德镇"},{"001036003":"萍乡"},{"001036004":"九江"},{"001036005":"新余"},{"001036006":"鹰潭"},{"001036007":"赣州"},{"001036008":"吉安"},{"001036009":"宜春"},{"001036010":"抚州"},{"001036011":"上饶"}],
  "37":[{"001037001":"济南"},{"001037002":"青岛"},{"001037003":"淄博"},{"001037004":"枣庄"},{"001037005":"东营"},{"001037006":"烟台"},{"001037007":"潍坊"},{"001037008":"济宁"},{"001037009":"泰安"},{"001037010":"威海"},{"001037011":"日照"},{"001037012":"莱芜"},{"001037013":"临沂"},{"001037014":"德州"},{"001037015":"聊城"},{"001037016":"滨州"},{"001037017":"菏泽"}],
  "41":[{"001041001":"郑州"},{"001041002":"开封"},{"001041003":"洛阳"},{"001041004":"平顶山"},{"001041005":"安阳"},{"001041006":"鹤壁"},{"001041007":"新乡"},{"001041008":"焦作"},{"001041009":"濮阳"},{"001041010":"许昌"},{"001041011":"漯河"},{"001041012":"三门峡"},{"001041013":"南阳"},{"001041014":"商丘"},{"001041015":"信阳"},{"001041016":"周口"},{"001041017":"驻马店"},{"001041018":"济源"}],
  "42":[{"001042001":"武汉"},{"001042002":"黄石"},{"001042003":"十堰"},{"001042005":"宜昌"},{"001042006":"襄阳"},{"001042007":"鄂州"},{"001042008":"荆门"},{"001042009":"孝感"},{"001042010":"荆州"},{"001042011":"黄冈"},{"001042012":"咸宁"},{"001042013":"随州"},{"001042028":"恩施土家族苗族自治州"},{"001042029":"仙桃"},{"001042030":"潜江"},{"001042031":"天门"},{"001042032":"神农架"}],
  "43":[{"001043001":"长沙"},{"001043002":"株洲"},{"001043003":"湘潭"},{"001043004":"衡阳"},{"001043005":"邵阳"},{"001043006":"岳阳"},{"001043007":"常德"},{"001043008":"张家界"},{"001043009":"益阳"},{"001043010":"郴州"},{"001043011":"永州"},{"001043012":"怀化"},{"001043013":"娄底"},{"001043031":"湘西土家族苗族自治州"}],
  "44":[{"001044001":"广州"},{"001044002":"韶关"},{"001044003":"深圳"},{"001044004":"珠海"},{"001044005":"汕头"},{"001044006":"佛山"},{"001044007":"江门"},{"001044008":"湛江"},{"001044009":"茂名"},{"001044012":"肇庆"},{"001044013":"惠州"},{"001044014":"梅州"},{"001044015":"汕尾"},{"001044016":"河源"},{"001044017":"阳江"},{"001044018":"清远"},{"001044019":"东莞"},{"001044020":"中山"},{"001044051":"潮州"},{"001044052":"揭阳"},{"001044053":"云浮"}],
  "45":[{"001045001":"南宁"},{"001045003":"桂林"},{"001045004":"梧州"},{"001045005":"北海"},{"001045006":"防城港"},{"001045007":"钦州"},{"001045008":"贵港"},{"001045009":"玉林"},{"001045010":"百色"},{"001045011":"贺州"},{"001045012":"河池"},{"001045013":"来宾"},{"001045014":"崇左"},{"001045022":"柳州"}],
  "46":[{"001046001":"海口"},{"001046002":"三亚"},{"001046003":"三沙"},{"001046004":"五指山"},{"001046005":"琼海"},{"001046006":"儋州"},{"001046007":"文昌"},{"001046008":"万宁"},{"001046009":"东方"},{"001046010":"澄迈县"},{"001046010":"澄迈县"},{"001046012":"屯昌县"},{"001046013":"临高县"},{"001046014":"白沙黎族自治县"},{"001046015":"昌江黎族自治县"},{"001046016":"乐东黎族自治县"},{"001046017":"陵水黎族自治县"},{"001046018":"保亭黎族苗族自治县"},{"001046019":"琼中黎族苗族自治县"},{"001046020":"洋浦经济开发区"},{"001046090":"其他"}],
  "50":[{"001050001":"万州区"},{"001050002":"涪陵区"},{"001050003":"渝中区"},{"001050004":"大渡口区"},{"001050005":"江北区"},{"001050006":"沙坪坝区"},{"001050007":"九龙坡区"},{"001050008":"南岸区"},{"001050009":"北碚区"},{"001050010":"万盛区"},{"001050011":"双桥区"},{"001050012":"渝北区"},{"001050013":"巴南区"},{"001050014":"黔江区"},{"001050015":"长寿区"},{"001050022":"綦江县"},{"001050023":"潼南县"},{"001050024":"铜梁县"},{"001050025":"大足县"},{"001050026":"荣昌县"},{"001050027":"璧山县"},{"001050028":"梁平县"},{"001050029":"城口县"},{"001050030":"丰都县"},{"001050031":"垫江县"},{"001050032":"武隆县"},{"001050033":"忠县"},{"001050034":"开县"},{"001050035":"云阳县"},{"001050036":"奉节县"},{"001050037":"巫山县"},{"001050038":"巫溪县"},{"001050040":"石柱土家族自治县"},{"001050041":"秀山土家族苗族自治县"},{"001050042":"酉阳土家族苗族自治县"},{"001050043":"彭水苗族土家族自治县"},{"001050081":"江津区"},{"001050082":"合川市"},{"001050083":"永川区"},{"001050084":"南川市"}],
  "51":[{"001051001":"成都"},{"001051003":"自贡"},{"001051004":"攀枝花"},{"001051005":"泸州"},{"001051006":"德阳"},{"001051007":"绵阳"},{"001051008":"广元"},{"001051009":"遂宁"},{"001051010":"内江"},{"001051011":"乐山"},{"001051013":"南充"},{"001051014":"眉山"},{"001051015":"宜宾"},{"001051016":"广安"},{"001051017":"达州"},{"001051018":"雅安"},{"001051019":"巴中"},{"001051020":"资阳"},{"001051032":"阿坝"},{"001051033":"甘孜"},{"001051034":"凉山"}],
  "52":[{"001052001":"贵阳"},{"001052002":"六盘水"},{"001052003":"遵义"},{"001052004":"安顺"},{"001052022":"铜仁"},{"001052023":"黔西南"},{"001052024":"毕节"},{"001052026":"黔东南"},{"001052027":"黔南"}],
  "53":[{"001053001":"昆明"},{"001053003":"曲靖"},{"001053004":"玉溪"},{"001053005":"保山"},{"001053006":"昭通"},{"001053023":"楚雄"},{"001053025":"红河"},{"001053026":"文山"},{"001053027":"思茅"},{"001053028":"西双版纳"},{"001053029":"大理"},{"001053031":"德宏"},{"001053032":"丽江"},{"001053033":"怒江"},{"001053034":"迪庆"},{"001053035":"临沧"}],
  "54":[{"001054001":"拉萨"},{"001054021":"昌都"},{"001054022":"山南"},{"001054023":"日喀则"},{"001054024":"那曲"},{"001054025":"阿里"},{"001054026":"林芝"}],
  "61":[{"001061001":"西安"},{"001061002":"铜川"},{"001061003":"宝鸡"},{"001061004":"咸阳"},{"001061005":"渭南"},{"001061006":"延安"},{"001061007":"汉中"},{"001061008":"榆林"},{"001061009":"安康"},{"001061010":"商洛"}],
  "62":[{"001062001":"兰州市"},{"001062002":"嘉峪关"},{"001062003":"金昌"},{"001062004":"白银"},{"001062005":"天水"},{"001062006":"武威"},{"001062007":"张掖"},{"001062008":"平凉"},{"001062009":"酒泉"},{"001062010":"庆阳"},{"001062024":"定西"},{"001062026":"陇南"},{"001062029":"临夏"},{"001062030":"甘南"}],
  "63":[{"001063001":"西宁"},{"001063021":"海东"},{"001063022":"海北"},{"001063023":"黄南"},{"001063025":"海南"},{"001063026":"果洛"},{"001063027":"玉树"},{"001063028":"海西"}],
  "64":[{"001064001":"银川"},{"001064002":"石嘴山"},{"001064003":"吴忠"},{"001064004":"固原"},{"001064005":"中卫"}],
  "65":[{"001065001":"乌鲁木齐"},{"001065002":"克拉玛依"},{"001065021":"吐鲁番"},{"001065022":"哈密"},{"001065023":"昌吉"},{"001065027":"博尔塔拉"},{"001065028":"巴音郭楞"},{"001065029":"阿克苏"},{"001065030":"克孜勒苏"},{"001065031":"喀什"},{"001065032":"和田"},{"001065040":"伊犁"},{"001065042":"塔城"},{"001065043":"阿勒泰"},{"001065044":"石河子"}],
  "71":[{"001071001":"台北市"},{"001071002":"高雄市"},{"001071003":"基隆市"},{"001071004":"台中市"},{"001071005":"台南市"},{"001071006":"新竹市"},{"001071007":"嘉义市"},{"001071008":"台北县"},{"001071009":"宜兰县"},{"001071010":"桃园县"},{"001071011":"新竹县"},{"001071012":"苗栗县"},{"001071013":"台中县"},{"001071014":"彰化县"},{"001071015":"南投县"},{"001071016":"云林县"},{"001071017":"嘉义县"},{"001071018":"台南县"},{"001071019":"高雄县"},{"001071020":"屏东县"},{"001071021":"澎湖县"},{"001071022":"台东县"},{"001071023":"花莲县"}],
  "81":[{"001081002":"中西区"},{"001081003":"东区"},{"001081004":"九龙城区"},{"001081005":"观塘区"},{"001081006":"南区"},{"001081007":"深水埗区"},{"001081008":"黄大仙区"},{"001081009":"湾仔区"},{"001081010":"油尖旺区"},{"001081011":"离岛区"},{"001081012":"葵青区"},{"001081013":"北区"},{"001081014":"西贡区"},{"001081015":"沙田区"},{"001081016":"屯门区"},{"001081017":"大埔区"},{"001081018":"荃湾区"},{"001081019":"元朗区"}],
  "82":[{"001082002":"花地玛堂区"},{"001082003":"圣安多尼堂区"},{"001082004":"大堂区"},{"001082005":"望德堂区"},{"001082006":"风顺堂区"},{"001082007":"氹仔"},{"001082008":"路环"}],

  "0":null

}

function init_city_selects(pdom,cdom,pval,cval){

  if(pdom.size() == 0 || cdom.size()==0) return false;
  //
  var init_province_select = function(pdom,pval){
    var provinces = all_provinces;
    pdom.empty();
    pdom.append("<option value=''>不限</option>");
    for(var i in provinces){
      var item = provinces[i];
      for(var k in item){
        var id  = parseInt(k.slice(3,k.length));
        var name = item[k];
        pdom.append("<option value='"+id+"' "+(id.toString() == pval ? "selected" : "")+">"+name+"</option>");
        break;
      }
    }
  }


  var init_city_select = function(cdom,pval,cval){
    var cities = all_cities[pval.toString()];
    //
    cdom.empty();
    cdom.append("<option value=''>不限</option>");

    for(var i in cities){
      var item = cities[i];
      for(var k in item){
        var id  = parseInt(k.slice(6,k.length));
        var name = item[k];
        cdom.append("<option value='"+id+"' "+(id.toString() == cval ? "selected" : "")+">"+name+"</option>");
        break;
      }
    }
  }



  init_province_select(pdom,pval);
  init_city_select(cdom,pval,cval);

  pdom.change(function(){
    init_city_select(cdom,$(this).val(),null);
  })

}





