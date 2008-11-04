var tweets = [];
 var max_tweet = 0;
 
 function display_next_tweet() {
   if (tweets.length) {
     tweet = tweets.pop();
     tweet_li = $("<li class='tweet'></li>")
       .hide()
       .html(tweet.formatted)
       .prependTo("#tweets")
       .toggle("slide", {direction: "up"}, 800);
     setTimeout(function() {
       // console.log($(this).height());
       // $(this).css({top: -1 * $(this).height() + "px"});
       // $(this).css({top: -$(this).height()})
       //   .css({opacity: 10})
       //   .animate({top: 0});
     }, 100);
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
   get_more_tweets();
 });