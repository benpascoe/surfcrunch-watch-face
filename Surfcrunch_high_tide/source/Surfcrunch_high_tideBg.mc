using Toybox.Background;
using Toybox.System as Sys;

// The Service Delegate is the main entry point for background processes
// our onTemporalEvent() method will get run each time our periodic event
// is triggered by the system.

(:background)
class BgbgServiceDelegate extends Toybox.System.ServiceDelegate {
	
	//var _resultDict = {};
	
	function initialize() {
		Sys.ServiceDelegate.initialize();
		inBackground=true;				//trick for onExit()
	}
	
    function onTemporalEvent() {
    	var now=Sys.getClockTime();
    	var ts=now.hour+":"+now.min.format("%02d");
        Sys.println("bg exit: "+ts);
        //just return the timestamp
        //Background.exit(ts);
        // make a web request and return the array
        
        // if it's after midnight, or there's no data in there already, do the web request
        
        /////////////////
        // web request
        /////////////////
        Sys.println(bgdata);
        if (bgdata==null) {
        
        	Sys.println("bgdata is null, fetching new");
        	var webOptions = {
		           :method => Communications.HTTP_REQUEST_METHOD_GET,
		           :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
		         };
		        // @todo URL encode
		        Sys.println("bgbg making web request...");
		        Toybox.Communications.makeWebRequest(
				   // this is the url that returns the array with forecast and tide details in it
		           "https://raw.githubusercontent.com/benpascoe/surfcrunch-watch-face/main/example_array",
		           {},
		           webOptions,
		           method(:webOnReceive)
		        );
		 }
	        if (now.hour == 0 && now.min < 30) {  // (now.hour == 0 && now.min < 30) || 
		        var webOptions = {
		           :method => Communications.HTTP_REQUEST_METHOD_GET,
		           :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
		         };
		        // @todo URL encode
		        Sys.println("bgbg making web request...");
		        Toybox.Communications.makeWebRequest(
				   // this is the url that returns the array with forecast and tide details in it
		           "https://raw.githubusercontent.com/benpascoe/surfcrunch-watch-face/main/example_array",
		           {},
		           webOptions,
		           method(:webOnReceive)
		        );
	        }
        
    }
    
    /////////////
    // Receive the data from the web request
    /////////////
    function webOnReceive(responseCode, data) {
       if (responseCode == 200) {
           Sys.println(data);
           
           //_resultDict.remove("full_array");
           //_resultDict.put("full_array", data);
       } else {
           Sys.println("Failed to load\nError: " + responseCode.toString());
           //_resultDict.put("error", responseCode.toString());
       }

       //Background.exit(_resultDict);
       Background.exit(data);
       
    }

}
