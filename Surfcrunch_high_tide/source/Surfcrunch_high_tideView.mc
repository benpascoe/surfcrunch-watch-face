using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Calendar;
using Toybox.WatchUi as Ui;
using Toybox.Application as App;

var partialUpdatesAllowed = false;

class Surfcrunch_high_tideView extends Ui.WatchFace {

	var fullScreenRefresh;
	//var _isRectangle = false;

    //var showSecond = false;
    var background_color = Gfx.COLOR_BLACK;
    var width_screen, height_screen;

    var tb_x, tb_y;
    //var tb_width = 144;  //one pixel width is 10 minutes
    //var tb_height = 60;  //one pixel height is 10cm
    //var tbArray = new [5];

    var is24Hour = true;

    function initialize() {
        //var settings = Sys.getDeviceSettings();
        //is24Hour = settings.is24Hour;
        WatchFace.initialize();
    	
   	    var bgdata=App.getApp().getProperty(OSDATA);
        Sys.println("From OS: data="+bgdata); //+" "+counter+" at "+ts);        

      //screenShape = System.getDeviceSettings().screenShape;
      fullScreenRefresh = true;
      partialUpdatesAllowed = ( Toybox.WatchUi.WatchFace has :onPartialUpdate );
      
      System.println("done initilaizing");
    }

    // Load your resources here
    function onLayout(dc) {
        //get screen dimensions
        width_screen = dc.getWidth();
        height_screen = dc.getHeight();
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        var clockTime = Sys.getClockTime();
        
        //get tide chart array
        var rawArray = App.getApp().getProperty(OSDATA);
        // example of the array that populates the forecast values and generates the tide chart
        //var rawArray = [[[5, 0], [5, 51], [6, 51], [8, 50], [10, 48], [12, 46], [14, 44], [16, 41], [18, 38], [20, 35], [22, 32], [24, 29], [26, 26], [28, 23], [30, 21], [32, 18], [34, 16], [36, 15], [38, 14], [40, 13], [42, 13], [43, 13], [43, 0]], [[43, 0], [43, 10], [44, 10], [46, 10], [48, 11], [50, 13], [52, 16], [54, 19], [56, 22], [58, 26], [60, 29], [62, 33], [64, 37], [66, 40], [68, 44], [70, 46], [72, 49], [74, 50], [76, 51], [77, 51], [77, 0]], [[77, 0], [77, 51], [78, 51], [80, 51], [82, 50], [84, 48], [86, 46], [88, 43], [90, 41], [92, 38], [94, 34], [96, 31], [98, 28], [100, 25], [102, 21], [104, 19], [106, 16], [108, 14], [110, 12], [112, 11], [114, 10], [116, 10], [117, 10], [117, 0]], [[117, 0], [117, 10], [118, 10], [120, 11], [122, 13], [124, 15], [126, 18], [128, 22], [130, 25], [132, 29], [134, 33], [136, 37], [138, 40], [140, 44], [142, 46], [0, 49], [2, 50], [4, 51], [5, 51], [5, 0]], [], [[-117, 5.0], [-83, 1.3], [-43, 5.0], [-9, 1.3], [30, 5.2], [64, 1.0], [104, 5.2], [138, 1.0], [177, 5.4], [212, 0.8], [251, 5.4]], [0.21, 0.23, 0.79, 0.82], []];

		var x_offset = (width_screen / 2) - (144 / 2);  //240 / 2 = 120. 144 / 2 = 72. 120-72 = 48
		var y_offset = height_screen - 35;//(height_screen / 2) + 60 + 3;  //200 - 196
		//initialise polygon arrays
		var tideArray = new [5];
		if(rawArray) {
					
			// debug
			//Sys.println(bgdata);
			for( var i = 0; i < 5; i += 1 ) 
			{
				tideArray[i] = new [rawArray[i].size()];
			}
			//populate polygon arrays
			for(var j = 0; j < 5; j += 1)
	        {
	        	if(rawArray[j].size() > 1)
	        	{
	        		for(var i = 0; i < rawArray[j].size(); i += 1)
	        		{	        			
	        			tideArray[j][i] = new [2];
	        			tideArray[j][i].removeAll(null);
		        		tideArray[j][i].add(x_offset + rawArray[j][i][0]);
		        		tideArray[j][i].add(y_offset - rawArray[j][i][1]);
		        		//System.print(tideArray[j][i]);
		        	}
		        }
		    }
	    }
		else {
		}
        // Clear the screen
        dc.setColor(background_color, Gfx.COLOR_WHITE);
        dc.fillRectangle(0, height_screen / 2, width_screen, height_screen / 2);
        dc.setColor(Gfx.COLOR_WHITE, background_color);
        dc.fillRectangle(0, 0, width_screen, height_screen / 2);
        
        // Draw digital time
        drawDigitalTime(dc, Gfx.COLOR_BLACK, clockTime);

        // Draw date
        drawDate(dc, Gfx.COLOR_BLACK);
        
        // Draw tide box
        if(rawArray)
        {
        	drawTide(dc, Gfx.COLOR_WHITE, rawArray, tideArray, clockTime.hour, clockTime.min, y_offset, x_offset);
        }
        else {}
                
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
        //showSecond = true;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
        //showSecond = false;
        requestUpdate();
    }

    function drawDigitalTime(dc, text_color, clockTime)
    {
        var hour = clockTime.hour;
        var ampm = "";
        var font = Gfx.FONT_NUMBER_HOT;
        var font_height = Gfx.getFontHeight(font);
        var timeString = Lang.format("$1$:$2$$3$", [hour.format("%02d"), clockTime.min.format("%02d"), ampm]);
        dc.setColor(text_color, Gfx.COLOR_TRANSPARENT);
        dc.drawText(width_screen/2, (height_screen/2) - font_height / 1.4, font, timeString, Gfx.TEXT_JUSTIFY_CENTER + Gfx.TEXT_JUSTIFY_VCENTER);
    	// Call the parent onUpdate function to redraw the layout
		//View.onUpdate(dc);
    }

    function drawDate(dc, text_color)
    {
        var now = Time.now();
        var info_long = Calendar.info(now, Time.FORMAT_LONG);
        var info = Calendar.info(now, Time.FORMAT_SHORT);
        var font_height = Gfx.getFontHeight(Gfx.FONT_SMALL);
        var dateStr = Lang.format("$1$ $2$.$3$.$4$", [info_long.day_of_week.toUpper().substring(0, 3), info.year, info.month.format("%02d") , info.day.format("%02d")]);
        //var dateStr = Lang.format("$1$ $2$", [info.day_of_week, info.day.format("%02d")]);
        dc.setColor(text_color, Gfx.COLOR_TRANSPARENT);
        dc.drawText(width_screen / 2, (height_screen / 2) - font_height, Gfx.FONT_SMALL, dateStr, Gfx.TEXT_JUSTIFY_CENTER);
    }
    
    // rawArray 0-4 = polygons, 5 = lengths, 6 = extremes, 7 = astro, 8 = forecast
    function drawTide(dc, tideColor, rawArray, tideArray, hour, min, y_offset, x_offset)
    {
    	if(dc has :setAntiAlias) {
			dc.setAntiAlias(true);
		}
				
        dc.setColor(tideColor, Gfx.COLOR_TRANSPARENT);
        dc.fillPolygon(tideArray[0]);
        dc.fillPolygon(tideArray[2]);
        dc.fillPolygon(tideArray[4]);

		if(dc has :setAntiAlias) {
			dc.setAntiAlias(true);
		}
        
        //draw alernate tide sections as an outline only
        dc.setColor(tideColor, Gfx.COLOR_TRANSPARENT);
        
        //bottom line
        dc.setPenWidth(2);
        for(var i = 0; i < rawArray[1].size() - 1; i += 1)
        {
        	dc.drawLine(tideArray[1][i][0], tideArray[1][i][1], tideArray[1][i + 1][0], tideArray[1][i + 1][1]);
        }
        for(var i = 0; i < rawArray[3].size() - 1; i += 1)
        {
        	dc.drawLine(tideArray[3][i][0], tideArray[3][i][1], tideArray[3][i + 1][0], tideArray[3][i + 1][1]);
        }
		// draw astro line
		var astro = rawArray[6];
		// see what it looks like on top of the tide chart
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		dc.drawRoundedRectangle(x_offset, y_offset - 3, 143, 5, 3);
		dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
		dc.fillRoundedRectangle(x_offset + 1, y_offset - 2, 141, 3, 2);
		// twilight
		dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
		var twilight_x = x_offset + 1 + (astro[0] * 141);
		var twilight_l = (astro[3] - astro[0]) * 141;
		dc.fillRoundedRectangle(twilight_x, y_offset - 2, twilight_l, 3, 2);
		// sunrise and sunset
		dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
		var daylight_x = x_offset + 1 + (astro[1] * 141);
		var daylight_l = (astro[2] - astro[1]) * 141;
		dc.fillRoundedRectangle(daylight_x, y_offset - 2, daylight_l, 3, 2);
		
        //current time line
        var mins = (hour * 60) + min;
        var x_line = (mins / 10) + 48;
        dc.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_TRANSPARENT);
        dc.drawLine(x_line, y_offset - 60, x_line, y_offset);
        //height and time text at the start of each polygon, except the first one
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

		// set up forecast array
		var fc = rawArray[7];
		// arrow polygons
	    var arrow_polys = {
	        0 => [[8, 16], [2, 2], [8, 5], [14, 2]],		// N
	        1 => [[5, 15], [5, 1], [9, 5.5], [15, 5]],		// NNE
	        2 => [[2, 14], [8, 0], [10, 6], [16, 8]],		// NE
	        3 => [[1, 11], [11, 1], [10.5, 7], [15, 11]],	// ENE
	        4 => [[0, 8], [14, 2], [11, 8], [14, 14]],		// E
	        5 => [[1, 5], [15, 5], [10.5, 9], [11, 15]],	// ESE
	        6 => [[2, 2], [16, 8], [10, 10], [8, 16]],		// SE
	        7 => [[5, 1], [15, 11], [9, 10.5], [5, 15]],	// SSE
	        8 => [[8, 0], [14, 14], [8, 11], [2, 14]],		// S
	        9 => [[11, 1], [11, 15], [7, 10.5], [1, 11]],	// SSW
	        10 => [[14, 2], [8, 16], [6, 10], [0, 8]],		// SW
	        11 => [[15, 5], [5, 15], [5.5, 9], [1, 5]],		// WSW
	        12 => [[16, 8], [2, 14], [5, 8], [2, 2]],		// W
	        13 => [[15, 11], [1, 11], [5.5, 7], [5, 1]],	// WNW
	        14 => [[14, 14], [0, 8], [6, 6], [8, 0]],		// NW
	        15 => [[11, 15], [1, 5], [7, 5.5], [11, 1]]		// NNW
	    };
	    var arrow_lines = {
	        0 => [[8, 16], [8, 0], [15, 11], [1, 11]],		// N
	        1 => [[5, 15], [11, 1], [14, 14], [0, 8]],		// NNE
	        2 => [[2, 14], [11, 15], [14, 2], [1, 5]],		// NE
	        3 => [[1, 11], [8, 16], [15, 5], [2, 2]],		// ENE
	        4 => [[0, 8], [5, 15], [16, 8], [5, 1]],		// E
	        5 => [[1, 5], [2, 14], [15, 11], [8, 0]],		// ESE
	        6 => [[2, 2], [1, 11], [14, 14], [11, 1]],		// SE
	        7 => [[5, 1], [0, 8], [11, 15], [14, 2]],		// SSE
	        8 => [[8, 0], [1, 5], [8, 16], [15, 5]],		// S
	        9 => [[11, 1], [2, 2], [5, 15], [16, 8]],		// SSW
	        10 => [[14, 2], [5, 1], [2, 14], [15, 11]],	    // SW
	        11 => [[15, 15], [8, 0], [1, 11], [15, 5]],	    // WSW
	        12 => [[16, 8], [11, 1], [0, 8], [11, 15]],	    // W
	        13 => [[15, 11], [14, 2], [1, 5], [8, 16]],	    // WNW
	        14 => [[14, 14], [15, 5], [2, 2], [5, 15]],	    // NW
	        15 => [[11, 15], [16, 8], [5, 1], [2, 14]]	    // NNW
	    };
        
        if (fc.size() == 0) {
		        dc.drawText(width_screen / 2, (height_screen / 2), Gfx.FONT_TINY, "UNAVAILABLE", Gfx.TEXT_JUSTIFY_CENTER);
        } else {
        for(var i = 0; i < 7; i += 1)
        {
        	var x_fc = fc[i][0] + x_offset;
        	//Sys.print(x_line);
        	if(x_line < x_fc - 9 || i == 7) // take off 9 pixels/90 minutes to get the closest forecast to current time
        	{
				var font_height = Gfx.getFontHeight(Gfx.FONT_TINY);
				
				var swellStr = fc[i][1].format("%.1f") + "FT ";
				var swellWindStr = swellStr + "    " + fc[i][2].format("%i") + "S  ";
		        var fcStr = swellWindStr + "      " + fc[i][4];
		        
		        var fullWidth = dc.getTextWidthInPixels(fcStr, Gfx.FONT_TINY);
		        var swellWidth = dc.getTextWidthInPixels(swellStr, Gfx.FONT_TINY);
		        var swellWindWidth = dc.getTextWidthInPixels(swellWindStr, Gfx.FONT_TINY);
		        // figure out where to put the swell arrow
		        // centre of display minus half of the full width gets start point, then add swell width and that's the offset
		        var swellArrowStart = (width_screen / 2) - (fullWidth / 2) + swellWidth;
		        var windArrowStart = (width_screen / 2) - (fullWidth / 2) + swellWindWidth;
		        
		        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
		        dc.drawText(width_screen / 2, (height_screen / 2), Gfx.FONT_TINY, fcStr, Gfx.TEXT_JUSTIFY_CENTER);
		        
        		// height, period, direction, wind speed, wind direction
        		// get arrow polyon and move it into position				
				var swell_arrow_poly = arrow_polys.get(fc[i][3]);
				var swell_arrow_x = swellArrowStart; // (width_screen / 2) - (fullWidth / 2) + swellArrowStart;  // 123;
				var swell_arrow_y = 126;
				
				var wind_arrow_line = arrow_lines.get(fc[i][5]);
				var wind_arrow_x = windArrowStart;
				
				
				for (var i = 0; i < swell_arrow_poly.size(); ++i) {
					swell_arrow_poly[i][0] += swell_arrow_x;
					swell_arrow_poly[i][1] += swell_arrow_y;
				}
				dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
				dc.fillPolygon(swell_arrow_poly);
				
				for (var i = 0; i < wind_arrow_line.size(); ++i) {
					wind_arrow_line[i][0] += wind_arrow_x;
					wind_arrow_line[i][1] += swell_arrow_y;
				}
				dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
				dc.drawLine(wind_arrow_line[0][0], wind_arrow_line[0][1], wind_arrow_line[1][0], wind_arrow_line[1][1]);
				dc.drawLine(wind_arrow_line[0][0], wind_arrow_line[0][1], wind_arrow_line[2][0], wind_arrow_line[2][1]);
				dc.drawLine(wind_arrow_line[0][0], wind_arrow_line[0][1], wind_arrow_line[3][0], wind_arrow_line[3][1]);
		        
		        break;
        	}
        }
        } // end if else
		
		var extremes = rawArray[5];
		var extremes_len = extremes.size();
        for(var i = 1; i < extremes_len; i += 1)
        {
        	var x = extremes[i][0] + x_offset;      	
			// next tide extreme text under chart
        	if(x_line < x)
	        {
	        	var hrs = ((x - x_offset) * 10) / 60;
	        	if(hrs >= 24)
	        	{
	        		hrs -= 24;
	        	}
	        	var mins = ((x - x_offset) * 10) % 60;
	        	var h = extremes[i][1];
	        	var type = "HIGH";
	        	if(extremes[i][1] < extremes[i - 1][1])
	        	{
	        		type = "LOW";
	        	}
		        var t = h.format("%.1f") + "M " + type + " AT " + hrs.format("%02d") + ":" + mins.format("%02d");
	        	dc.drawText(width_screen / 2, y_offset, Gfx.FONT_XTINY, t, Gfx.TEXT_JUSTIFY_CENTER);
	        	break;
	        }
	    }
    }
}
