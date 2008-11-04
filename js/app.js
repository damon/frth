$(function() {
  var flow = $("<ul id='flow'></ul>");
  function addItem() {
    flow.prepend($('<li>item!</li>'));
    scheduleItem();
  };
  function scheduleItem() {
    setTimeout(addItem, 2000);
  }
  $('body').prepend(flow);
  addItem();
});