% HEART_RATE_ANALYSIS - analysis
%{
 Team Members: Saul, Graham, James
 Roles: Algorithm Developer , Data Manager, Visualization Specialist


Description:
  This script loads athlete workout data from CSV files.
  It figures out which "heart rate zone" each workout was in (Resting, Light, etc.).
  It calculates important stats like how well they recover, how consistent they are, and how much total time they spent working out.
  And it saves all these results so we can make charts later.

Inputs:
  - Data/Athletes/athlete1_beginner.csv
  - Data/Athletes/athlete2_intermediate.csv 
  - Data/Athletes/athlete3_advanced.csv

Outputs:
  - Results/heart_rate_analysis.mat (Variables saved for plotting)
  - Results/athlete_summary.csv (Table of final stats)
%}
%% Setup Section
clear; clc; close all; % Clear old variables and command window


dataDir = fullfile('Data', 'Athletes'); % Defines folder paths using 'fullfile' so it works on Mac and Windows

resultsDir = 'Results';


if ~isfolder(resultsDir) % results folder 
    mkdir(resultsDir);
end

%% Data Loading
fileNames = {'beginnerAthlete.csv', 'intermediateAthlete.csv', 'advancedAthlete.csv'}; 
athleteNames = {'Beginner', 'Intermediate', 'Advanced'};

for i = 1:length(fileNames)
    filePath = fullfile(dataDir, fileNames{i});
    
    if isfile(filePath)
        % 1. Load the table
        T = readtable(filePath);
        
        % 2. Fix capitalization (PostworkoutHR -> PostWorkoutHR)
        % This prevents the "Dot indexing" 
        oldNames = T.Properties.VariableNames;
        newNames = oldNames;
        
        % Fix PostWorkoutHR
        idx = strcmpi(oldNames, 'PostWorkoutHR');
        if any(idx)
            newNames{idx} = 'PostWorkoutHR';
        end
        
        % Fix PreWorkoutHR
        idx = strcmpi(oldNames, 'PreWorkoutHR');
        if any(idx)
            newNames{idx} = 'PreWorkoutHR';
        end
        
        T.Properties.VariableNames = newNames;
        
        % Save into the cell array
        athleteData{i} = T;
        fprintf('Loaded %s successfully.\n', fileNames{i});
    else
        error('File not found: %s', filePath);
    end
end

%% Heart Rate Zone Categorization & Time Calculation

% Rows = Athletes (3), Columns = Zones (4)
% Zones: 1=Resting, 2=Light, 3=Moderate, 4=Vigorous
timeInZones = zeros(3, 4); % table of numbers) to store time spent in each zone

for i = 1:length(athleteData)
    data = athleteData{i};
    
    % --- Zone Logic ---
    %  "True/False" lists (logical vectors) for each zone based on heart rate
    
    isResting = data.PostWorkoutHR < 100; % Resting Zone: Less than 100 bpm
    
    isLight = data.PostWorkoutHR >= 100 & data.PostWorkoutHR < 130; % Light Zone: 100 to 129 bpm
    
   
    isModerate = data.PostWorkoutHR >= 130 & data.PostWorkoutHR < 160; % Moderate Zone: 130 to 159 bpm
    
    
    isVigorous = data.PostWorkoutHR >= 160; % Vigorous Zone: 160 bpm or higher
    
    % --- Calculate Time ---
    % Adds up the 'Duration' minutes for workouts in each zone
    timeInZones(i, 1) = sum(data.Duration(isResting));
    timeInZones(i, 2) = sum(data.Duration(isLight));
    timeInZones(i, 3) = sum(data.Duration(isModerate));
    timeInZones(i, 4) = sum(data.Duration(isVigorous));
end

%% Recovery Rate Calculation
% Recovery Rate = How much HR dropped (PostWorkoutHR - PreWorkoutHR)
% Lower numbers usually mean better fitness.
avgRecoveryRate = zeros(3, 1);

for i = 1:length(athleteData)
    data = athleteData{i};
    isActive = data.Duration > 0; % days where they actually worked out (Duration is not 0)
    rawRecovery = data.PostWorkoutHR(isActive) - data.PreWorkoutHR(isActive); % the HR difference for ONLY the active days
    avgRecoveryRate(i) = mean(rawRecovery); % the average of those differences
end

%% Basic Statistics
% calculate stats, but ignores the "Rest" days
avgPostHR = zeros(3, 1); 
avgDuration = zeros(3, 1);
consistency = zeros(3, 1); % This will be the Standard Deviation of Intensity
totalWorkouts = zeros(3, 1);
totalMinutes = zeros(3, 1); 

for i = 1:length(athleteData)
    data = athleteData{i};
    isActive = data.Duration > 0; % Filter for active workout days again
    avgPostHR(i) = mean(data.PostWorkoutHR(isActive));
    avgDuration(i) = mean(data.Duration(isActive)); % averages using only the active days
    
    % Consistency: Standard deviation of Intensity. 
    % Lower number means they train at a steady intensity (Consistent).
    % Higher number means intensity jumps around a lot (Inconsistent).
    consistency(i) = std(data.Intensity(isActive));
    
    totalWorkouts(i) = sum(isActive); % Count of how many True values are in isActive (total workouts)
    totalMinutes(i) = sum(data.Duration); %Sum up all minutes spent working out (Rest days add 0 anyway)
end

%% Results

 % Summary table to display
summaryTable = table(athleteNames', avgPostHR, totalMinutes, consistency, ... 
 'VariableNames', {'Athlete', 'AvgHeartRate', 'TotalMinutes', 'Consistency'});

disp('--- Athlete Summary Statistics ---');
disp(summaryTable); %Shows table in the Command Window

summaryFile = fullfile(resultsDir, 'athlete_summary.csv');
writetable(summaryTable, summaryFile); % Saves table CSV file
fprintf('Summary table exported to: %s\n', summaryFile);

matFile = fullfile(resultsDir, 'heart_rate_analysis.mat'); % Visualization Specialist use this to make your stuff
save(matFile, 'timeInZones', 'avgRecoveryRate', 'avgPostHR', 'avgDuration', ...
     'consistency', 'totalWorkouts', 'totalMinutes', 'athleteNames', 'athleteData'); % Saves variables to a .mat file
fprintf('Workspace variables saved to: %s\n', matFile);


%{
Comparative Analysis Findings (based on results)

1. Which athlete spent the most time in vigorous zone?
Answer: should be in the 4th column of 'timeInZones'. probably the Advanced athlete.

2. Which athlete has the most consistent training?
Answer: should be in 'Consistency' column. The lower number is the best.

3. Which athlete has the best cardiovascular efficiency?
Answer: Look at avgRecoveryRate. Lower is better efficiency.

4. How do workout patterns differ between fitness levels?
Answer: Beginners are generally random. While Advanceds will be consistent and with more intensity.

%}

%% FIGURE 1: Heart Rate Zone Comparison (Grouped Bar Chart)

% Uses timeInZones calculated earlier
athletes = athleteNames; 
zones = {'Resting','Light','Moderate','Vigorous'};

figure;
bar(timeInZones, 'grouped');

xlabel('Athlete Level');
ylabel('Time in HR Zone (minutes)');
title('Comparison of Time Spent in Heart Rate Zones by Athlete Level');
set(gca, 'XTickLabel', athletes);
legend(zones, 'Location','northwest');
grid on;

outputFolder = fullfile(resultsDir, 'Figures');
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

saveas(gcf, fullfile(outputFolder, 'zone_comparison.png'));

%% FIGURE 2: Heart Rate Trends Over Time (Line Plot)
% Pull true HR time series from athleteData structs

days = 1:length(athleteData{1}.PostWorkoutHR);

PW_Beginner     = athleteData{1}.PostWorkoutHR;
PW_Intermediate = athleteData{2}.PostWorkoutHR;
PW_Advanced     = athleteData{3}.PostWorkoutHR;

figure;
plot(days, PW_Beginner,     'LineWidth',1.8, marker='o'); hold on;
plot(days, PW_Intermediate, 'LineWidth',1.8, linestyle='--', marker='square');
plot(days, PW_Advanced,     'LineWidth',1.8, linestyle=':', marker='x', markersize=10);

xlabel('Day');
ylabel('Post-Workout Heart Rate (bpm)');
title('Post-Workout Heart Rate Trends');
legend(athletes, 'Location', 'northeast');
grid on;

saveas(gcf, fullfile(outputFolder, 'hr_trends.png'));

%% FIGURE 3: Recovery Rate Comparison (Bar Chart)

meanRecovery = avgRecoveryRate(:)';

figure;
bar(meanRecovery);
set(gca,'XTickLabel', athletes);

ylabel('Average Heart Rate Drop (bpm)');
title('Recovery Rate Comparison (Lower = Better)');

saveas(gcf, fullfile(outputFolder, 'recovery_comparison.png'));

%% FIGURE 4: Workout Duration Distribution (Subplots)

Dur_Beginner     = athleteData{1}.Duration(athleteData{1}.Duration > 0);
Dur_Intermediate = athleteData{2}.Duration(athleteData{2}.Duration > 0);
Dur_Advanced     = athleteData{3}.Duration(athleteData{3}.Duration > 0);

figure;

subplot(3,1,1);
histogram(Dur_Beginner,10);
title('Workout Duration Distribution – Beginner');
xlabel('Duration (minutes)');
ylabel('Frequency');

subplot(3,1,2);
histogram(Dur_Intermediate,10);
title('Workout Duration Distribution – Intermediate');
xlabel('Duration (minutes)');
ylabel('Frequency');

subplot(3,1,3);
histogram(Dur_Advanced,10);
title('Workout Duration Distribution – Advanced');
xlabel('Duration (minutes)');
ylabel('Frequency');

saveas(gcf, fullfile(outputFolder, 'duration_distributions.png'));

%% FIGURE 5: Summary Dashboard (Multi-panel)

totalTime    = totalMinutes(:)';
avgIntensity = avgDuration(:)';           % Using avgDuration as the "Intensity-like" metric (no intensity avg computed)
numWorkouts  = totalWorkouts(:)';
stdIntensity = consistency(:)';

figure('Position',[100 100 1200 800]);

subplot(2,2,1);
bar(totalTime);
set(gca,'XTickLabel',athletes);
title('Total Workout Time');
ylabel('Minutes');

subplot(2,2,2);
bar(avgIntensity);
set(gca,'XTickLabel',athletes);
title('Average Workout Duration');
ylabel('Minutes');

subplot(2,2,3);
bar(numWorkouts);
set(gca,'XTickLabel',athletes);
title('Number of Workouts Completed');
ylabel('Sessions');

subplot(2,2,4);
bar(stdIntensity);
set(gca,'XTickLabel',athletes);
title('Training Consistency (Std Dev of Intensity)');
ylabel('Std Dev');

saveas(gcf, fullfile(outputFolder, 'summary_dashboard.png'));







