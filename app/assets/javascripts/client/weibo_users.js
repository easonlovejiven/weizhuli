
$(".fans-list-box .basic-row").each(function(){
  var row = $(this);
  $("td:last a",this).click(function(){
    if(!row.next().is(":visible")){
      $("tr.detail-row").hide();
    }
    row.next().toggle();
    return false;
  })
});
$(".rest-in-place").mouseover(function(){$(this).effect("highlight")});

// search group btn single select
// http://stackoverflow.com/questions/12494901/bootstrap-unselectable-radio-button
$(document).on("click", "[data-toggle='buttons-checkbox'][data-single-select] .btn", function(evt){
    $(this).siblings().removeClass('active');
});


// search btn click event
$(".conditions .btn").click(function(){
  var btn = $(this);
  setTimeout(function(){
    //console.debug(btn.hasClass("active"));
    btn.siblings().removeClass('btn-danger');
    var id = btn.parent(".btn-group").data("bind");
    if(btn.hasClass("active")){
      btn.addClass("btn-danger");

      // set value
      $("#search_"+id).val(btn.data("val"));
    }else{
      btn.removeClass("btn-danger");

      // set value
      $("#search_"+id).val(btn.data(""));
    }
  },1);

})


// search btn default status
$(".conditions input:hidden[id*='search_']").each(function(){
  var h = $(this);
  if (h.val().trim() != ''){
    var id = h.attr("id").replace("search_","");
    h.siblings("div[data-bind='"+id+"']").find("button[data-val='"+h.val()+"']").addClass("active").addClass("btn-danger");
  }
})


// 选择分组
$("div.dropdown[data-uid] .dropdown-menu a[data-group-id]").click(function(){
  var self = $(this);
  var dropdown = $(this).parents("div.dropdown");
  var uid = dropdown.data("uid");
  $.post("/client/weibo_user_remarks/"+uid, {_method:"put",weibo_user_remark:{group_id:$(this).data("group-id")}},function(){
    dropdown.find(".dropdown-toggle").html(self.text()+"<b class='caret'></b>");
  });
  dropdown.find(".dropdown-toggle").text("更新中...");
})

