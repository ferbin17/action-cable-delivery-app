import consumer from "./consumer"

consumer.subscriptions.create("MerchantChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    if(data["alert"] != null){
      $(`.container[order-id=${data["content"]}]`).remove();
      $('#orders-side-div')[0].prepend($.parseHTML(data["alert"])[0])
    }
    if($('#orders').length != 0){
      $(`.card[order-id=${data["content"]}]`).remove();
      $('#orders')[0].prepend($.parseHTML(data["html"])[0]);
      $('#audio')[0].play(); 
      setTimeout(function () {
        $('#audio')[0].play(); 
      }, 10000);
    }
    // Called when there's incoming data on the websocket for this channel
  }
});
