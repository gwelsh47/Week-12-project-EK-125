%% Figure 1: Heart Rate Zone Comparison (Grouped Bar Chart)
% Create a grouped bar chart showing time spent in each HR zone:
% X-axis: Athletes (Beginner, Intermediate, Advanced)
% Y-axis: Time in minutes
% Four groups of bars representing the four HR zones
% Include title, axis labels, and legend
% Save as 'zone_comparison.png' in Results/Figures/


% PLACE HOLDER DATA !!!
timeInZones = [
    30 20 10  5;   % Beginner
    20 30 25 10;   % Intermediate
    10 25 35 20    % Advanced
];

athletes = {'Beginner', 'Intermediate', 'Advanced'};
zones = {'Zone 1', 'Zone 2', 'Zone 3', 'Zone 4'};

% Create grouped bar chart
figure;
bar(timeInZones, 'grouped');

% Labels and title
xlabel('Athlete Level');
ylabel('Time in HR Zone (minutes)');
title('Comparison of Time Spent in Heart Rate Zones by Athlete Level');

% X-axis tick labels
set(gca, 'XTickLabel', athletes);


legend(zones, 'Location', 'northwest');
grid on;

% Save figure
outputFolder = 'Results/Figures';
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

saveas(gcf, fullfile(outputFolder, 'zone_comparison.png'));

%% Figure 2: Heart Rate Trends Over Time (Line Plot)
% Create a line plot showing PostWorkoutHR trends:
% X-axis: Day (1-21)
% Y-axis: Post-Workout Heart Rate (bpm)
% Three lines (one per athlete) with different markers/colors
% Use hold on/off to plot multiple lines on same axes
% Include title, axis labels, legend, and grid
% Save as 'hr_trends.png'

days = 1:21;   % PLACEHOLDER DATA

PostWorkoutHR_Beginner = [150 152 151 149 148 150 147 145 144 143 142 144 143 141 140 139 138 140 139 138 137];
PostWorkoutHR_Intermediate = [140 139 138 140 137 136 135 134 133 132 131 132 130 129 128 127 126 125 126 124 123];
PostWorkoutHR_Advanced = [130 129 128 127 126 125 124 123 122 121 122 120 119 118 117 116 115 114 114 113 112];

% Create Line Plot
figure;
plot(days, PostWorkoutHR_Beginner, 'LineWidth', 1.8, color="b", linestyle="-", marker="o"); hold on;
plot(days, PostWorkoutHR_Intermediate, 'LineWidth', 1.8, color='r', linestyle = '--', marker = 'square');
plot(days, PostWorkoutHR_Advanced, 'LineWidth', 1.8, color="g", linestyle=":", marker="x", markersize = 10);

xlabel('Day (1–21)');
ylabel('Post-Workout Heart Rate (bpm)');
title('Post-Workout Heart Rate Trends Over 21 Days');

legend({'Beginner','Intermediate','Advanced'}, 'Location','northeast');
grid on;


%% Figure 3: Recovery Rate Comparison (Bar Chart)
% Create a bar chart comparing recovery rates:
% Calculate mean recovery rate (PostWorkoutHR - PreWorkoutHR) for each
% athlete, excluding rest days
% X-axis: Athletes
% Y-axis: Average heart rate increase (bpm)
% Three bars showing recovery rate for each athlete
% Include title and axis labels
% Save as 'recovery_comparison.png'

MeanRecovery_Beginner = 38.5;      % PLACE HOLDER DATA
MeanRecovery_Intermediate = 40.2;  
MeanRecovery_Advanced = 41.7; 

meanRecovery = [MeanRecovery_Beginner, MeanRecovery_Intermediate, MeanRecovery_Advanced];

athletes = {'Beginner','Intermediate','Advanced'};

figure;
bar(meanRecovery);

set(gca, 'XTickLabel', athletes);
ylabel('Average Heart Rate Increase (bpm)');
title('Recovery Rate Comparison');

saveas(gcf, 'recovery_comparison.png');

%% Figure 4: Workout Duration Distribution (Subplots)
% Create histograms showing workout duration patterns:
% Use subplot(3,1,i) to create three vertically stacked histograms
% Each subplot shows one athlete's workout duration distribution
% Use histogram function with appropriate bin count (e.g., 10 bins)
% Filter out rest days (Duration > 0) before creating histograms
% Label each subplot with athlete level and appropriate titles
% Save as 'duration_distributions.png'

% 0 values = rest days PLACE HOLDER DATA
Dur_Beginner = [0 25 30 28 0 32 35 29 0 27 26 33];
Dur_Intermediate = [40 42 0 38 45 47 43 0 39 41 44 0];
Dur_Advanced = [55 58 60 0 62 65 59 0 61 63 64 66];

% Filter out rest days
Dur_Beginner = Dur_Beginner(Dur_Beginner > 0);
Dur_Intermediate = Dur_Intermediate(Dur_Intermediate > 0);
Dur_Advanced = Dur_Advanced(Dur_Advanced > 0);

% Create figure
figure;

% Beginner
subplot(3,1,1);
histogram(Dur_Beginner, 10);
title('Workout Duration Distribution – Beginner');
xlabel('Duration (minutes)');
ylabel('Frequency');

% Intermediate
subplot(3,1,2);
histogram(Dur_Intermediate, 10);
title('Workout Duration Distribution – Intermediate');
xlabel('Duration (minutes)');
ylabel('Frequency');

% Advanced
subplot(3,1,3);
histogram(Dur_Advanced, 10);
title('Workout Duration Distribution – Advanced');
xlabel('Duration (minutes)');
ylabel('Frequency');

saveas(gcf, 'duration_distributions.png');

%% Figure 5: Summary Dashboard (Multi-panel)
% Create a 2×2 subplot figure showing key metrics:
% Use figure('Position', [100, 100, 1200, 800]) to create a large figure window
% Panel 1 (subplot 2,2,1): Total workout time for each athlete (bar chart)
% Panel 2 (subplot 2,2,2): Average workout intensity for each athlete (bar chart,
% excluding rest days)
% Panel 3 (subplot 2,2,3): Number of workouts completed by each athlete (bar
% chart)
% Panel 4 (subplot 2,2,4): Training consistency measured by standard deviation
% of intensity (bar chart, lower is better)
% Use bar charts for all panels with appropriate titles and labels
% as 'summary_dashboard.png

TotalTime_Beginner = 320; % PLACEHOLDER
TotalTime_Intermediate = 415;
TotalTime_Advanced = 510;

% Average workout intensity (0–10 scale), excluding rest days
AvgIntensity_Beginner = 6.2;
AvgIntensity_Intermediate = 7.5; % PLACEHOLDER
AvgIntensity_Advanced = 8.4;

% Number of completed workouts (non-zero entries)
NumWorkouts_Beginner = 10;
NumWorkouts_Intermediate = 12; % PLACEHOLDER
NumWorkouts_Advanced = 14;

% Training consistency (std of intensity values; lower is better)
StdIntensity_Beginner = 1.8;
StdIntensity_Intermediate = 1.4; % PLACEHOLDER
StdIntensity_Advanced = 1.1;

% Group labels
athletes = {'Beginner','Intermediate','Advanced'};

% Convert to arrays
totalTime = [TotalTime_Beginner, TotalTime_Intermediate, TotalTime_Advanced];
avgIntensity = [AvgIntensity_Beginner, AvgIntensity_Intermediate, AvgIntensity_Advanced];
numWorkouts = [NumWorkouts_Beginner, NumWorkouts_Intermediate, NumWorkouts_Advanced];
stdIntensity = [StdIntensity_Beginner, StdIntensity_Intermediate, StdIntensity_Advanced];

% ----- Create Figure -----
figure('Position', [100, 100, 1200, 800]);

% Panel 1 – Total Workout Time
subplot(2,2,1);
bar(totalTime);
set(gca, 'XTickLabel', athletes);
title('Total Workout Time');
ylabel('Minutes');

% Panel 2 – Average Workout Intensity
subplot(2,2,2);
bar(avgIntensity);
set(gca, 'XTickLabel', athletes);
title('Average Workout Intensity');
ylabel('Intensity (0–10)');

% Panel 3 – Number of Workouts Completed
subplot(2,2,3);
bar(numWorkouts);
set(gca, 'XTickLabel', athletes);
title('Number of Workouts Completed');
ylabel('Sessions');

% Panel 4 – Training Consistency (Std Dev of Intensity)
subplot(2,2,4);
bar(stdIntensity);
set(gca, 'XTickLabel', athletes);
title('Training Consistency (Lower is Better)');
ylabel('Std Dev of Intensity');

% Save figure
saveas(gcf, 'summary_dashboard.png');
