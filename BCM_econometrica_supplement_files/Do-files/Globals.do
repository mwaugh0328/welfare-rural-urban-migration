cd X:/Monga

global replication  "Replication"

	global dta "$replication/Data"
	global dof "$replication/Do-files"
		global support "$dof/Support"
	global output "$replication/Output"
		global tb  "$output/Tables"
		global fg  "$output/Figures"
	global prep "$replication/Prep"

			
