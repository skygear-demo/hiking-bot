let request = require('request');
let skygear = require('skygear');


let apiKey = '4c577b4c54144c1791c63808181104';
let city = 'hong kong';
let cnt = '3';
let url = `http://api.worldweatheronline.com/premium/v1/weather.ashx?q=${city}&num_of_days=${cnt}&key=${apiKey}`;

const skygearCloud = require('skygear/cloud');
skygearCloud.every('@every 1d', function()
{
	request(url, function (err, response, body) {
  if(err){
    console.log('error:', error);
  } else {

	var parseString = require('xml2js').parseString;
	parseString(body, function(err, result)
	{
		object = JSON.stringify(result)
		object = JSON.parse(object);
		today_temp = object.data.current_condition[0].temp_C;
		today_temp = today_temp.toString();
		today_descr = object.data.current_condition[0].weatherDesc;
		today_descr = today_descr.toString();
		today_humidity = object.data.current_condition[0].humidity;
		today_humidity = today_humidity.toString();
		day1 = object.data.weather[0].date;
		day1 = day1.toString();
		day1_temp = object.data.weather[0].hourly[3].tempC;
		day1_temp = day1_temp.toString();
		day1_descr = object.data.weather[0].hourly[3].weatherDesc;
		day1_descr = day1_descr.toString();
		day1_humidity = object.data.weather[0].hourly[3].humidity;
		day1_humidity = day1_humidity.toString();
		day2 = object.data.weather[1].date;
		day2 = day2.toString();
		day2_temp = object.data.weather[1].hourly[3].tempC;
		day2_temp = day2_temp.toString();
		day2_descr = object.data.weather[1].hourly[3].weatherDesc;
		day2_descr = day2_descr.toString();
		day2_humidity = object.data.weather[1].hourly[3].humidity;
		day2_humidity = day2_humidity.toString();
		day3 = object.data.weather[2].date;
		day3 = day3.toString();
		day3_temp = object.data.weather[2].hourly[3].tempC;
		day3_temp = day3_temp.toString();
		day3_descr = object.data.weather[2].hourly[3].weatherDesc;
		day3_descr = day3_descr.toString();
		day3_humidity = object.data.weather[2].hourly[3].humidity;
		day3_humidity = day3_humidity.toString();

		/*
		console.log(today_temp);
		console.log(today_descr);
		console.log(today_humidity);
		console.log(day1)
		console.log(day1_temp);
		console.log(day1_descr);
		console.log(day1_humidity);
		console.log(day2)
		console.log(day2_temp);
		console.log(day2_descr);
		console.log(day2_humidity);
		console.log(day3)
		console.log(day3_temp);
		console.log(day3_descr);
		console.log(day3_humidity);*/


		const container = skygearCloud.getContainer('93113553-183e-4cbd-8fd5-e63ac0452324');
		const TempWeatherData = skygear.Record.extend("TempWeather"); 

		const TempWeatherRecord = new TempWeatherData({
    		date: "today",
    		summary: `The temperature is ${today_temp} and it is ${today_descr}`

   		 });
		container.publicDB.save(TempWeatherRecord).then((result) => {
    	console.log(result);

    })
	
		const TempWeatherRecord1 = new TempWeatherData({
    		date: `${day1}`,
    		summary: `The temperature is ${day1_temp} and it is ${day1_descr}`

   		 });
		container.publicDB.save(TempWeatherRecord1).then((result) => {
    	console.log(result);

    })
	
		const TempWeatherRecord2 = new TempWeatherData({
    		date: `${day2}`,
    		summary: `The temperature is ${day2_temp} and it is ${day2_descr}`

   		 });
		container.publicDB.save(TempWeatherRecord2).then((result) => {
    	console.log(result);

    })
	
		const TempWeatherRecord3 = new TempWeatherData({
    		date: `${day3}`,
    		summary: `The temperature is ${day3_temp} and it is ${day3_descr}`

   		 });

		container.publicDB.save(TempWeatherRecord3).then((result) => {
    	console.log(result);

    })

	})
  		}
});
});
