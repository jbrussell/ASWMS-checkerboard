% mk_synevent
% quick script to generate a synthetic event catalog for testing possible
% resolution, event distributions etc.

clear all;
option = 1;

outpath = './';
outfile = sprintf('events_%d.txt',option);

ctrlat = -22.33; % array center
ctrlon = 171.32;

%% Set up parameters for different synth events
% for teleseismic surface waves
if option ==1
minMw = 6.0; % minimum magnitude
maxdepth = 50; % maximum depth
distlim = [180 20]; % distance range
start_time = '2020-01-01 00:00:00';
end_time = '2021-01-01 00:00:00';
% for teleseismic receiver functions
elseif option ==2
   minMw = 6.0; % minimum magnitude
maxdepth = 800; % maximum depth
distlim = [100 25]; % distance range
start_time = '2020-01-01 00:00:00';
end_time = '2021-01-01 00:00:00'; 
end

%% download events and format into text file
events_info = irisFetch.Events('startTime',start_time,'endTime',end_time,...
		'MinimumMagnitude',minMw,'maximumDepth',maxdepth,'radialcoordinates',[ctrlat,ctrlon,distlim]);

% Write event file
formatSpec = ('%s %8.2f %8.2f %8.2f\n');
fileID = fopen([outpath,outfile],'w');

for ii = 1:length(events_info)
    evtlat = events_info(ii).PreferredLatitude;
    evtlon = events_info(ii).PreferredLongitude;
    evtdpt = events_info(ii).PreferredDepth;
    otime = datenum(events_info(ii).PreferredTime,'yyyy-mm-dd HH:MM:SS.FFF');
	eventid = datestr(otime,'yyyymmddHHMM');
    fprintf(fileID,formatSpec,eventid,evtlat,evtlon,evtdpt);
end
fclose(fileID); 
