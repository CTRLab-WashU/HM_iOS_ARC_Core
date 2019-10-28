#  The App
Handling Differences between pool outs of the app:

	-Different versions of the app will have slightly different behavior, to handle this you can:
		
		> Add the new functionality to the project including the core.
		
		> If it is present in the core already, sub-class it. To use that subclass look for ##State.swift. ## == some prefix specific to the project, like AC. 
			
	-If all versions of the app should have this functionality or are capable of being updated to later use that functionality, add it directly to the core.
		


Surveys:
	
	-All surveys are meant to run through BasicSurveyController.swift
	
	-The views backing the controller is called InfoView.swift
	
	

