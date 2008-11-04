var tweets = [];
var max_tweet = 0;
var page_size = 40;
 
 function prune() {
   var items = $('#tweets li').slice(page_size)
   if (items.length) {
     items.remove();
     $('#more').show();
   }
 }
 
 function display_next_tweet() {
   if (tweets.length) {
     tweet = tweets.pop();
     $('#more').hide();
     $('#tweets').scrollbox.push($("<li class='tweet'></li>").html(tweet.formatted));
     setTimeout(prune, 800);
     setTimeout(display_next_tweet, 1500);
   }
   else {
     setTimeout(get_more_tweets, 1500);
   }
 }
 
 function get_more_tweets() {
   $.getJSON('/tweets?since_id=' + max_tweet, function(server_tweets) {
     tweets = server_tweets;
     if (tweets[0]) {
       max_tweet = tweets[0].id;
       display_next_tweet();
     }
   });
 }
   
 $(function() {
   $('#tweets').scrollbox();
   get_more_tweets();
 });