// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery
//= require jquery.ui.all
//= require jquery_ujs
//= require twitter/bootstrap
//= require jquery-fileupload/basic
//= require highcharts
//= require highcharts/highcharts-more
//= require jquery.popupoverlay
//= require jquery.sinaEmotion-1.3.min
//= require rest_in_place
//= require autocomplete-rails
//= require city_selects.js
//= require bootstrap-daterangepicker/moment
//= require jquery.daterangepicker.js
//= require jquery.tablesorter.min.js

$.fn.reload = function(){
  
  if($(this).attr("data-ajax-url")) $(this).load($(this).attr("data-ajax-url"));
  else throw "DOM don't have jQuery attribute [data-ajax-url] yet, need set this attribute first";
  return $(this);
}
$.fn.set_content_url = function(url){
  $(this).attr("data-ajax-url",url);
  return $(this);
}
$(function(){
  // $(document).on("click","div.pagination a", function(){
  //   $(this).parents(".ajax-list-container").set_content_url(this.href).reload();
  //   return false;
  // });
});


var getWeiboLength = (function () {
  var trim = function (h) {
    try {
      return h.replace(/^\s+|\s+$/g, "")
    } catch (j) {
      return h
    }
  }
  var byteLength = function (b) {
    if (typeof b == "undefined") {
      return 0
    }
    var a = b.match(/[^\x00-\x80]/g);
    return (b.length + (!a ? 0 : a.length))
  };

  return function (q, g) {
    g = g || {};
    g.max = g.max || 140;
    g.min = g.min || 41;
    g.surl = g.surl || 20;
    var p = trim(q).length;
    if (p > 0) {
      var j = g.min,
        s = g.max,
        b = g.surl,
        n = q;
      var r = q.match(/(http|https):\/\/[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)+([-A-Z0-9a-z\$\.\+\!\_\*\(\)\/\,\:;@&=\?~#%]*)*/gi) || [];
      var h = 0;
      for (var m = 0,
          p = r.length; m < p; m++) {
        var o = byteLength(r[m]);
        if (/^(http:\/\/t.cn)/.test(r[m])) {
          continue
        } else {
          if (/^(http:\/\/)+(weibo.com|weibo.cn)/.test(r[m])) {
            h += o <= j ? o : (o <= s ? b : (o - s + b))
          } else {
            h += o <= s ? b : (o - s + b)
          }
        }
        n = n.replace(r[m], "")
      }
      return Math.ceil((h + byteLength(n)) / 2)
    } else {
      return 0
    }
  }
})();
