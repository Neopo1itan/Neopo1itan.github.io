{%- if theme.footer.beian.enable %}
  <div class="beian">
    {{- next_url('https://beian.miit.gov.cn', theme.footer.beian.icp + ' ') }}
    {%- if theme.footer.beian.gongan_icon_url %}
      <img src="{{ url_for(theme.footer.beian.gongan_icon_url) }}" style="display: inline-block;">
    {%- endif %}
    {%- if theme.footer.beian.gongan_id and theme.footer.beian.gongan_num %}
      {{- next_url('http://www.beian.gov.cn/portal/registerSystemInfo?recordcode=' + theme.footer.beian.gongan_id, theme.footer.beian.gongan_num + ' ') }}
    {%- endif %}
  </div>
{%- endif %}

<div class="copyright">
  {% set copyright_year = date(null, 'YYYY') %}
  &copy; {% if theme.footer.since and theme.footer.since != copyright_year %}{{ theme.footer.since }} – {% endif %}
  <span itemprop="copyrightYear">{{ copyright_year }}</span>
  <span class="with-love">
    <i class="{{ theme.footer.icon.name }}"></i>
  </span>
  <span class="author" itemprop="copyrightHolder">{{ theme.footer.copyright or author }}</span>

  {%- if config.symbols_count_time.total_symbols %}
    <span class="post-meta-divider">|</span>
    <span class="post-meta-item-icon">
      <i class="fa fa-chart-area"></i>
    </span>
    {%- if theme.symbols_count_time.item_text_total %}
      <span class="post-meta-item-text">{{ __('symbols_count_time.count_total') + __('symbol.colon') }}</span>
    {%- endif %}
    <span title="{{ __('symbols_count_time.count_total') }}">{{ symbolsCountTotal(site) }}</span>
  {%- endif %}

  {%- if config.symbols_count_time.total_time %}
    <span class="post-meta-divider">|</span>
    <span class="post-meta-item-icon">
      <i class="fa fa-coffee"></i>
    </span>
    {%- if theme.symbols_count_time.item_text_total %}
      <span class="post-meta-item-text">{{ __('symbols_count_time.time_total') }} &asymp;</span>
    {%- endif %}
    <span title="{{ __('symbols_count_time.time_total') }}">{{ symbolsTimeTotal(site, config.symbols_count_time.awl, config.symbols_count_time.wpm, __('symbols_count_time.time_minutes')) }}</span>
  {%- endif %}
</div>

 {%- if theme.footer.powered %}
  <div class="powered-by">
    <!-- {%- set next_site = 'https://theme-next.org' %}
    {%- if theme.scheme !== 'Gemini' %}
      {%- set next_site = 'https://' + theme.scheme | lower + '.theme-next.org' %}
    {%- endif %}
    {{- __('footer.powered', next_url('https://hexo.io', 'Hexo', {class: 'theme-link'}) + ' & ' + next_url(next_site, 'NexT.' + theme.scheme, {class: 'theme-link'})) }} -->
    <span>个人网站&nbsp&nbsp&nbsp|&nbsp&nbsp&nbsp吉吉邦德</span>
  </div>
{%- endif %} 

{%- if theme.add_this_id %}
  <div class="addthis_inline_share_toolbox">
    <script src="//s7.addthis.com/js/300/addthis_widget.js#pubid={{ theme.add_this_id }}" async="async"></script>
  </div>
{%- endif %}

{{- next_inject('footer') }}

{% if theme.busuanzi_count.enable %}
    <script async src="//dn-lbstatics.qbox.me/busuanzi/2.3/busuanzi.pure.mini.js"></script>

    <span id="busuanzi_container_site_pv">总访问量<span id="busuanzi_value_site_pv"></span>次</span>
    <span class="post-meta-divider">|</span>
    <span id="busuanzi_container_site_uv">总访客数<span id="busuanzi_value_site_uv"></span>人</span>
    <span class="post-meta-divider">|</span>
<!-- 不蒜子计数初始值纠正 -->
<script>
$(document).ready(function() {

    var int = setInterval(fixCount, 50);  // 50ms周期检测函数
    var countOffset = 20000;  // 初始化首次数据

    function fixCount() {            
       if (document.getElementById("busuanzi_container_site_pv").style.display != "none")
        {
            $("#busuanzi_value_site_pv").html(parseInt($("#busuanzi_value_site_pv").html()) + countOffset); 
            clearInterval(int);
        }                  
        if ($("#busuanzi_container_site_pv").css("display") != "none")
        {
            $("#busuanzi_value_site_uv").html(parseInt($("#busuanzi_value_site_uv").html()) + countOffset); // 加上初始数据 
            clearInterval(int); // 停止检测
        }  
    }
       	
});
</script>
{% endif %}

<!--添加运行时间--> 
</br>
<span id="sitetime"></span> 
<script language=javascript> 
  function siteTime(){ 
    window.setTimeout("siteTime()", 1000); 
    var seconds = 1000; 
    var minutes = seconds * 60; 
    var hours = minutes * 60; 
    var days = hours * 24; 
    var years = days * 365; 
    var today = new Date(); 
    var todayYear = today.getFullYear(); 
    var todayMonth = today.getMonth()+1; 
    var todayDate = today.getDate(); 
    var todayHour = today.getHours(); 
    var todayMinute = today.getMinutes(); 
    var todaySecond = today.getSeconds(); 
    /* 
    Date.UTC() -- 返回date对象距世界标准时间(UTC)1970年1月1日午夜之间的毫秒数(时间戳) 
    year - 作为date对象的年份，为4位年份值 
    month - 0-11之间的整数，做为date对象的月份 
    day - 1-31之间的整数，做为date对象的天数 
    hours - 0(午夜24点)-23之间的整数，做为date对象的小时数 
    minutes - 0-59之间的整数，做为date对象的分钟数 
    seconds - 0-59之间的整数，做为date对象的秒数 
    microseconds - 0-999之间的整数，做为date对象的毫秒数 
    */ 
    var t1 = Date.UTC(2023,07,06,15,49,36); //北京时间2018-2-13 00:00:00 
    var t2 = Date.UTC(todayYear,todayMonth,todayDate,todayHour,todayMinute,todaySecond); 
    var diff = t2-t1; 
    var diffYears = Math.floor(diff/years); 
    var diffDays = Math.floor((diff/days)-diffYears*365); 
    var diffHours = Math.floor((diff-(diffYears*365+diffDays)*days)/hours); 
    var diffMinutes = Math.floor((diff-(diffYears*365+diffDays)*days-diffHours*hours)/minutes); 
    var diffSeconds = Math.floor((diff-(diffYears*365+diffDays)*days-diffHours*hours-diffMinutes*minutes)/seconds); 
    document.getElementById("sitetime").innerHTML=" 已运行"+/*diffYears+" 年 "+*/diffDays+" 天 "+diffHours+" 小时 "+diffMinutes+" 分钟 "+diffSeconds+" 秒"; 
    } 
    siteTime(); 
</script> 
<!--// 添加运行时间-->
