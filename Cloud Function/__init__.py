import skygear

@skygear.before_save('message', async=False)
def check(record, original_record, db):
	if not record.get('body'):
		raise Exception('Missing cat name')
	else:
		record['body'] = "Cloud function"
		print("changed content")

	return record