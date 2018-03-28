const skygearChatCloud = require("skygear-chat/cloud");
const skygearCloud = require("skygear/cloud");
const botId = "67785199-677e-4f63-8d0d-888eae2971d7" // the user id of the bot

skygearCloud.beforeSave('message', function(record, original, pool, options) {
	console.log("gmrlplj");
    if (record['createdBy'] == botId){
    	console.log("bot message");
    	return
    }
    //record['body'] = "Cloud function test1";  //modify all message
    return record;
}, {
    async: false
});

skygearCloud.afterSave('message', function(record, original, pool, options) {
    if (record['createdBy'] == botId){
    	console.log("bot message");
    	return
    }

    console.log("------Start Container Coding-----------");

    var req = new Request('https://newsapi.org/v2/everything?q=Apple&from=2018-03-20&sortBy=popularity&apiKey=8bff5b23216443659b5f5cb237949be5');
    // Catching unexpected error: ReferenceError: Request is not defined
    fetch(req).then(function(response) {
        console.log("api testing")
        console.log(response.json());
    })
    //console.log(record.conversation);

    /*console.log("dassdadasw");
   	skygearChatCloud.SkygearChatContainer.getConversation("c16a011e-acb0-4fc0-b1b8-e82286fa372d", false).then(function(conversation) {
  		console.log('Save success', result);
  		skygearChat.SkygearChatContainer.createMessage(conversation, message, null, null).then(function (result) {
    		console.log('Message sent!', result);
		});
	});*/
    
	console.log("------End Container Coding-----------");

}, {
    async: false
});

function getContainer(userId) {
  const container = new skygearCloud.CloudCodeContainer();
  container.apiKey = skygearCloud.settings.masterKey;
  container.endPoint = skygearCloud.settings.skygearEndpoint + '/';
  container.asUserId = userId;
  return container;
}