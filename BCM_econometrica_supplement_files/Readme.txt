Data files needed for replication are included and labeled by round and/or topic. 

In general, each do-file creates one table or figure. In the case of multiple related tables, some dofiles create multiple tables. 

All tables can be made by running "Master Table and Figure Creation.do" 

Notes on tables, specifications or coding are commented in the do-files. 

File paths are based on the do file "Globals.do". By editing two lines in this do file, all file paths can be customized to the user's directory. 

Suggested use:

1) Open Globals.do. Set your working directory and edit the global -replication- to match your file structure
2) Run "Master Table and Figure Creation.do" - this creates Tables and Figures. 

Assumed file structure:

Replication/Data
Replication/Do-files
Replication/Do-files/Support
Replication/Output/Tables
Replication/Output/Figures

Household ID - 
In Rounds 1 and 2, households were identified by a unique household id (hhid). Some households split into multiple households. hhid was updated with a decimal to indicate split households. (ie household 1234 would become 1234.1 and 1234.2). In general, a variable hhid2 was created to round back to the whole number, to represent an original household. 

Round 1 data is included in the Round2 dataset with an r1 suffix. 
