module AutoSessionTimeoutHelper
  def auto_session_timeout_js(options={})
    frequency = options[:frequency] || 60
    verbosity = options[:verbosity] || 2
    periodic_active_path = options[:active_url] || active_path
    periodic_timeout_path = options[:timeout_url] || timeout_path
    code = <<JS
if (typeof(Ajax) != 'undefined') {
  new Ajax.PeriodicalUpdater('', '#{periodic_active_path}', {frequency:#{frequency}, method:'get', onSuccess: function(e) {
    if (e.responseText == 'false') window.location.href = '#{periodic_timeout_path}';
  }});
}else if(typeof(jQuery) != 'undefined'){
  function PeriodicalQuery() {
    $.ajax({
      url: '#{periodic_active_path}',
      success: function(data) {
        if(data == 'false'){
          window.location.href = '#{periodic_timeout_path}';
        }
      }
    });
    setTimeout(PeriodicalQuery, (#{frequency} * 1000));
  }
  setTimeout(PeriodicalQuery, (#{frequency} * 1000));
} else {
  $.PeriodicalUpdater('#{periodic_active_path}', {minTimeout:#{frequency * 1000}, multiplier:0, method:'get', verbose:#{verbosity}}, function(remoteData, success) {
    if (success == 'success' && remoteData == 'false')
      window.location.href = '#{periodic_timeout_path}';
  });
}
JS
    javascript_tag(code)
  end
end

ActionView::Base.send :include, AutoSessionTimeoutHelper
