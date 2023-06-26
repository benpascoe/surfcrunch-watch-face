using Toybox.Application as App;
using Toybox.Background;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

// info about whats happening with the background process
var counter=0;
var bgdata;
var canDoBG=false;
var inBackground=false;			//new 8-27

// keys to the object store data
var OSCOUNTER="oscounter";
var OSDATA="osdata";

(:background)
class Surfcrunch_high_tideApp extends App.AppBase {
   function initialize() {
      AppBase.initialize();
      var now=Sys.getClockTime();
      var ts=now.hour+":"+now.min.format("%02d");
      //you'll see this gets called in both the foreground and background  
   	  Sys.println(bgdata);	 
      var bgdata=App.getApp().getProperty(OSDATA);
   	  Sys.println(bgdata);	
      Sys.println("App initialize "+ts);
   }

   // onStart() is called on application start up
   function onStart(state) {
   	  Sys.println(bgdata);	
   	  var bgdata=App.getApp().getProperty(OSDATA);
   	  Sys.println(bgdata);	
      Sys.println("onStart");
   }

   // onStop() is called when your application is exiting
   function onStop(state) {
      //moved from onHide() - using the "is this background" trick
    	if(!inBackground) {
	    	var now=Sys.getClockTime();
    		var ts=now.hour+":"+now.min.format("%02d");        
        	Sys.println("onStop counter="+counter+" "+ts);    
    		App.getApp().setProperty(OSCOUNTER, counter);
    		App.getApp().setProperty(OSDATA, bgdata);
    	} else {
    		//Background.deleteTemporalEvent();
    		Sys.println("onStop");
    	}
   }

   // Return the initial view of your application here
   function getInitialView() {
      Sys.println("getInitialView");
		//register for temporal events if they are supported
    	if(Toybox.System has :ServiceDelegate) {
    		canDoBG=true;
    		Background.registerForTemporalEvent(new Time.Duration(5 * 60));  // change this to once a day after midnight
    	} else {
    		Sys.println("****background not available on this device****");
    	}
      return [new Surfcrunch_high_tideView()];
    }
   
       function onBackgroundData(data) {
    	counter++;
    	var now=Sys.getClockTime();
    	var ts=now.hour+":"+now.min.format("%02d");
        Sys.println("onBackgroundData="+data+" "+counter+" at "+ts);
        bgdata=data;
        App.getApp().setProperty(OSDATA,bgdata);
        Ui.requestUpdate();
    }    

    function getServiceDelegate(){
    	var now=Sys.getClockTime();
    	var ts=now.hour+":"+now.min.format("%02d");    
    	Sys.println("getServiceDelegate: "+ts);
        return [new BgbgServiceDelegate()];
    }
    
    function onAppInstall() {
    	Sys.println("onAppInstall");
    }
    
    function onAppUpdate() {
    	Sys.println("onAppUpdate");
    	Background.registerForTemporalEvent(new Time.Duration(5 * 60));
    }
}