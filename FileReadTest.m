%Turns files into tables
advAthlete = readtable('advancedAthlete.csv');
beginAthlete = readtable('beginnerAthlete.csv');
interAthlete = readtable('intermediateAthlete.csv');

table = advAthlete(:, [1 3:width(advAthlete)]); %Removes exersize name
aaa = table2array(table); %turns table into array
disp(aaa)
