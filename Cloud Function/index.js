// Reject empty 'name' before saving a cat to the database
const skygearCloud = require('skygear/cloud');
skygearCloud.beforeSave('message', function(record, original, pool, options) {
    if (!record['body']) {
    	console.log("error #1");
    }
    record['body'] = "Cloud function2";
    return record;
}, {
    async: false
});