import consumer from "./consumer"

consumer.subscriptions.create("UserChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Show order alert if alert html received 
    if(data["alert"] != null){
      $(`.container[order-id=${data["content"]}]`).remove();
      $('#orders-side-div')[0].prepend($.parseHTML(data["alert"])[0])
    }
    // Add order card If in order index page
    if($('#orders').length != 0){
      $(`.card[order-id=${data["content"]}]`).remove();
      $('#orders')[0].prepend($.parseHTML(data["html"])[0]);
    }
    // Page beep sound
    $('#audio')[0].play(); 
    // Called when there's incoming data on the websocket for this channel
  }
});
