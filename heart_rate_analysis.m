% HEART_RATE_ANALYSIS - analysis
%
% Team Members: Saul, Graham, James
% Roles: Algorithm Developer , Data Manager, Visualization Specialist
%
%

% Description:
%   This script loads athlete workout data from CSV files.
%   It figures out which "heart rate zone" each workout was in (Resting, Light, etc.).
%   It calculates important stats like how well they recover, how consistent they are, and how much total time they spent working out.
%   And it saves all these results so we can make charts later.
%

% Inputs:
%   - Data/Athletes/athlete1_beginner.csv
%   - Data/Athletes/athlete2_intermediate.csv % subject to change, dum data
%   filler
%   - Data/Athletes/athlete3_advanced.csv
%

% Outputs:
%   - Results/heart_rate_analysis.mat (Variables saved for plotting)
%   - Results/athlete_summary.csv (Table of final stats)


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
        % This prevents the "Dot indexing" error you saw
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

%% Comparative Analysis Findings 

% 1. Which athlete spent the most time in vigorous zone?
% Answer: 
[should be in the 4th column of 'timeInZones'. probably the Advanced athlete.

% 2. Which athlete has the most consistent training?
% Answer:
[should be in 'Consistency' column. The lower number is the best.

% 3. Which athlete has the best cardiovascular efficiency?
% Answer: 
[Look at avgRecoveryRate. Lower is better efficiency.

% 4. How do workout patterns differ between fitness levels?
% Beginners are generally random. While Advanceds will be consistent and with more intensity.






