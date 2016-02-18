// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.


// on load
$(function(){

  var mod = $("#new_post").data("mod");

  if($("#unpublished-list").size()>0)
  $("#unpublished-list").set_content_url("/client/posts?search[unpublished]=true&mod="+$("#unpublished-list").data("list-mod")).reload();
  if($("#published-list").size()>0)
  $("#published-list").set_content_url("/client/posts?search[published]=true&mod="+$("#unpublished-list").data("list-mod")).reload();


  var goto_list_page = function(){
    window.location.href="/client/posts?mod="+(mod || "");
  }

  $("#new_post").on("ajax:success", function(e,data,status,xhr){
    if(data.errors){
      var messages = [];
      for(key in data.errors){
        messages.push(data.errors[key]);
      }
      alert(messages.join("\n"));

    }else{
      reset_post_form();
      $("#messages").html("<div class='alert alert-success'><a href='#' class='close' data-dismiss='alert'>&times;</a>发布成功，正在刷新页面，请稍候...</div>");
      setTimeout(goto_list_page,3000);
    }
  }).on("ajax:error",function(e,data,status,xhr){
  }).on("ajax:complete",function(e,data,status,xhr){
  }).on("submit",function(){
    var errors = []
    var num = getWeiboLength($("#post_content").val())
    if(num>140){
      errors.push("微博内容 不能超过140个字");
    }

    if(mod == null){
      //直发
      if($("#post_content").val().trim() == ""){
        errors.push("微博内容 不能为空");
      }

    }else{
      //转发
      if($("#post_forward_url").attr("valid") != "true"){
        errors.push("您要转发的地址不正确，请检查")
      }


    }
    if($("#post_category").val().trim() == ""){
      errors.push("请选择 微博类型");
    }
    if((new Date() > new Date($("#post_post_at").val()))){
      errors.push("您选择的发布时间已经过期");
    }
    if($("#post_geo").size() > 0 && $("#post_geo").val().trim() == ""){
      errors.push("位置 不能为空");
    }
    if(errors.length > 0){
      alert(errors.join("\n"));
      return false;
    }
  })


  var reset_post_form = function(){
    var form = $("#new_post");
    form.removeClass("edit_form"); // whatever , remove edit_form class
    form[0].reset();
    $("#post_image_id").val("");
    $("#unpublished-list").reload();
    $("span.upload-button").show();
    //$("form .image-thumb").html("");


  }
  var set_post_form = function(mode,attrs){
    var content = attrs.content;
    var image_id = attrs.image_id;
    var image_url = attrs.image_url;
    var post_at = attrs.post_at;
    var id = attrs.id;
    var category = attrs.category;

    $("#post_id").val(id);
    $("#post_content").val(content);
    $("#post_image_id").val(image_id);
    $("span.upload-button").hide();
    $("form .image-thumb").html("<img src='"+image_url+"'/>").show();
    $("#post_category").val(category);

    if(mode=="edit"){
      $(".cancel-edit").hide();
    }else{

    }
  }

  $(document).on("ajax:complete",".destroy-link",function(){
    $(this).parents(".ajax-list-container").reload();
  });

  $(".cancel-edit").click(function(){
    if(confirm("确定要退出编辑吗？")){
      goto_list_page();
    }
  })

  // EDIT link
  /*
  $(document).on("click", ".edit-link", function(){
    $.getJSON("/client/posts/"+$(this).data("post-id"),function(data){
      var form = $("#new_post");

      form.addClass("edit_form");
      form.find(".cancel-edit").show();
      set_post_form("edit",data);
    })
    return false;
  });
*/

  $("input[name=time_type]").click(function(){
    if($(this).val()=="now"){
      $("#calendar-panel").hide();
      $("#post_post_at").val("");
    }
    if($(this).val()=="timer"){
      $("#calendar-panel").show();
      $("#time-selector *[name*='post_at_time']").change(); // trig time select event
    }
  })



  var update_uploaded_images_id = function(){
    var ids = $("form .image-thumb img").map(function(){return $(this).data("id")}).toArray().join(",");
    $("#post_image_id").val(ids);
  }

  $('#fileupload').fileupload({
      dataType: 'json',
      loadImageFileTypes:/^image\/(gif|jpeg|png)$/,
      acceptFileTypes:/(\.|\/)(gif|jpe?g|png)$/i,
      add: function (e, data) {
        var goUpload = true;
        var uploadFile = data.files[0];
        if (!(/\.(gif|jpg|jpeg|png)$/i).test(uploadFile.name)) {
            alert("只能上传图片文件 (gif|jpg|jpeg|png).");
            goUpload = false;
        }
        if (uploadFile.size > 5000000)   { // 5mb
          alert("文件大小不能超过5M")
            goUpload = false;
        }
        if($("form .image-thumb img").size()>=9){
          alert("每条微博最多可上传9张图片，目前已达到最大值，请先点击上传的图片删除后再上传新图片。")
          goUpload = false;

        }
        if (goUpload == true) {
            data.submit();
        }
      },
      done: function (e, data) {
        var image = data.result.image;
        var path = image.file_path.thumb;
        $(e.target).parents("span.upload-button").show();
        $("#post-image-form-container .uploading-progress").hide();
        $("form .image-thumb")
          .append("<img src='"+path+"' data-id='"+image.id+"'/>").show();
        update_uploaded_images_id();

        if($("form .image-thumb img").size()>1){
          $("form .image-thumb").addClass("multi");
        }else{
          $("form .image-thumb").removeClass("multi");
        }
      },
      start:function(e,data){
        $(e.target).parents("span.upload-button").hide();
        $("#post-image-form-container .uploading-progress").show();

      },
      progress: function (e, data) {
        var progress = parseInt(data.loaded / data.total * 100, 10);
        $("#post-image-form-container .uploading-progress .bar").css("width",progress+"%");
        console.debug(e,data); 
      },

      progressall: function (e, data) {
        var progress = parseInt(data.loaded / data.total * 100, 10);
        $("#post-image-form-container .uploading-progress .bar").css("width",progress+"%");
        console.debug(e,data); 
      }
  });


  $(document).on("click", "form .image-thumb img",function(){
    if(!confirm("删除此图片？")) return false;
    $(this).remove();
    update_uploaded_images_id();
    if($("form .image-thumb img").size() <= 1)$("form .image-thumb").removeClass("multi");
  });

  
	$('#face').click(function(){return false}).sinaEmotion({
		target: $('#post_content')
	});
	var show_left_words = function(){
	  var num = getWeiboLength($("#post_content").val());
	  console.debug(num);
	  $(".left-words").html("您还可以输入<i>"+(140-num)+"</i>个字");
	}
  show_left_words();
	$("#post_content").keyup(show_left_words).change(show_left_words);
	// $(".popbox").popbox();
  $('#image-upload-panel').popup({
      type: 'tooltip',
      autozindex: true,
      horizontal: 'center',
      vertical: 'bottom',
      fade:0
  });

	// pop

	$("#a-image").click(function(){
		$("#pop-block").show();
	});
	// close
	$(".close-layer").click(function(){
		$("#pop-block").hide();
	});
	

  $("#topic").click(function(){
    $('#post_content').val("#话题#"+$('#post_content').val()).focus();
    return false;
  })
	// on change time, set hidden "post_at" value
	$("#time-selector *[name*='post_at_time']").change(function(){
	  var time_values = $("#time-selector *[name*='post_at_time']").map(function(){
	    return $(this).val();
	  });
	  var time = time_values.slice(0,3).toArray().join("-")+ ' ' + time_values.slice(3,5).toArray().join(":");
	  $("#post_post_at").val(time);
	}).change();
	
	// create datepicker
	$("#calendar").datepicker({dateFormat: "yy-mm-dd" ,onSelect:function(date){
	  var values = date.split("-");
	  $(values).each(function(index,value){
	    $("#time-selector *[name*='post_at_time']")[index].value = parseInt(value)
	  });
	  $("#time-selector *[name*='post_at_time']").change();
	}, defaultDate:$("#calendar").data("default")});
  if($("#calendar").data("default").trim() !=""){
    // $("#calendar").datepicker("option","defaultDate",$("#calendar").data("default"));
  }
	


  $("input[name='time_type']:last").click();


  
	// highcharts
	
  $('#time-line').highcharts({
      chart: {
        type: 'spline'
      },
      credits: { 
        enabled: false
      },
      plotOptions: {
          spline: {
              lineWidth: 4,
              states: {
                  hover: {
                      lineWidth: 5
                  }
              },
              marker: {
                  enabled: false
              },
              events:{
                click: function(event){
                  var hour = event.point.category;
                  $("#time-selector *[name*='post_at_time']")[3].value = ("0" + hour).slice(-2);
                  $("#time-selector *[name*='post_at_time']").change();
                }
              }
          }
      },
      legend: {
          enabled: false
      },
      title: {
          text: null
      },
      xAxis: {
          categories: [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23],
          gridLineWidth: 1,
          gridLineColor: '#d0d0d0',
          gridLineDashStyle: "Dash",
          style: {
	          color: '#6D869F',
	          fontSize: "9px",
	          fontWeight: 'bold'
          }

      },
      yAxis: {
          title: {
              text: null
          }
      },
      series: [{
          data: [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
      }]
  });






  // for forwards
  var load_forward_weibo = function(){
    if($("#post_forward_url").size()== 0) return;
    $("#post_forward_url").attr("valid",false);
    setTimeout(function(){
      var url = $("#post_forward_url").val();
      if(url.trim()=="" || !url.match(/http:\/\/.*/)){
        return false;
      }
      $.getJSON("/client/posts/load_forward?s=1&url="+encodeURIComponent(url),function(data){
        var forwarded_text = "";
        var forwarded_user = "";
        var text = "";
        var forwarding_status = null;
        // forward a forwarding
        if(data.retweeted_status){
          forwarding_status = data.retweeted_status;
          forwarded_user  =  forwarding_status.user;
          text = "//@"+data.user.screen_name+":"+data.text;
        }else{
          forwarding_status = data;
          forwarded_user = data.user;
        }

        $("#post_content").val(text);
        $("#forwarding_preview").html(forwarded_user.screen_name+":"+forwarding_status.text);
        show_left_words();

        $("#post_forward_url").attr("valid",true);

      })


    },100)
  }
  $("#post_forward_url").change(load_forward_weibo).bind({paste:load_forward_weibo});
  load_forward_weibo();
  


});





















