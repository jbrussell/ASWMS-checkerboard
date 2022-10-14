% mk_stageom
% script for making different potential station geometries for deployment
% to feed into maps, resolution tests, etc

%% set up
clear all;

option = 7;
outpath = './';
outfile = sprintf('stations_%d.txt',option);

% region info
lat = [-25 -19];
lon = [166 175];
deplim = 0; % depth limit to avoid plotting crustal seismicity
matlat = -22.33;
matlon = 171.32;
hunlat = -22.4;
hunlon = 172.05;

% load map grid to extract elevations
[elev,longs,lats]=m_etopo2([lon,lat]);
[a,b] = size(elev);
elvvec = reshape(elev,[1,a*b]);
latvec = reshape(lats,[1,a*b]);
lonvec = reshape(longs,[1,a*b]);

%% already existing stations
start_time = '2021-01-01 00:00:00';
end_time = '2022-01-01 00:00:00';
% find seismic stations available with data
stations_info = irisFetch.Stations('channel','*',...
    '*','*',{'BH*,HH*'},...
    'MinimumLatitude', lat(1), 'MaximumLatitude', lat(2), ...
        'MinimumLongitude',lon(1) ,'MaximumLongitude',lon(2),...
    'startTime',start_time,'endTime',end_time,'IncludeRestricted',0,'federated');

network = 'ND';
stalat2 = [-21.035000,-20.550700,-21.480900,-22.307300,-22.418300,-22.612900,-22.059000];
stalon2 = [167.272400,164.286100,168.030500,166.454000,166.841600,167.446500,166.891000];
stanms2 = {'JNKNC','KOUNC','MARNC','ONTNC','OUENC','PINNC','YATNC'};

for ii = 1:length(stalat2)
    [arclen,az] = distance(stalat2(ii),stalon2(ii),latvec,lonvec);
    [val,idx] = min(arclen);
    staelv2(ii) = elvvec(idx);
end

%% POSSIBLE NEW STATION LOCATIONS

if option ==1

% station option 1
% three dense lines, sparse stations in between
% original version sent in January as a first test

% first line 
distint = 35; % station spacing for lines in km
distsparse = 100;
ninst = 8; %n -1 number of instruments in each line
lon1start = 167.71;
lat1start = -20.73;
lon1end = 169.811;
lat1end = -19.59;
az = azimuth(lat1start,lon1start,lat1end,lon1end);
[latline1,lonline1] = reckon(lat1start,lon1start,distint/111.*[0:ninst],az);
% sparse grid 1
az = az+90;
[latsp1,lonsp1] = reckon(lat1start,lon1start,110/111,az);
az = az-90;
[latsp1,lonsp1] = reckon(latsp1,lonsp1,distsparse/111.*[0:3],az);
% second line 
lon2start = 172.0;
lat2start = -24.0;
lon2end = 172.0;
lat2end = -22.573;
az = azimuth(lat2start,lon2start,lat2end,lon2end);
[latline2,lonline2] = reckon(lat2start,lon2start,distint/111.*[0:ninst],az);
% sparse grid 2
az = az+300;
[latsp2,lonsp2] = reckon(lat2start,lon2start,110/111,az);
az = 10;
[latsp2,lonsp2] = reckon(latsp2,lonsp2,distsparse/111.*[0:2],az);
% third line
lon3start = 169.177;
lat3start = -22.456;
lon3end = 171.156;
lat3end = -21.089;
az = azimuth(lat3start,lon3start,lat3end,lon3end);
[latline3,lonline3] = reckon(lat3start,lon3start,distint/111.*[0:ninst],az);
% sparse grid 3
az = az+70;
[latsp3,lonsp3] = reckon(lat3start,lon3start,110/111,az);
az = 40;
[latsp3,lonsp3] = reckon(latsp3,lonsp3,distsparse/111.*[0:1],az);

stalats = [latsp1,latsp2,latsp3,latline1,latline2,latline3];
stalons = [lonsp1,lonsp2,lonsp3,lonline1,lonline2,lonline3];

elseif option ==2 % all sparse grid in polynomial
    latpts = [-19.5,-23.25,-24,-24,-20];
    lonpts = [175.1,175.5,175.35,169,167.75];
    gridsize = 1; % in degrees
    latptsvec = [min(latpts):gridsize:max(latpts)];
    lonptsvec = [min(lonpts):gridsize:max(lonpts)];
    [latgrd,longrd] = meshgrid(latptsvec,lonptsvec);
    [a,b] = size(latgrd);
    latgrd = reshape(latgrd,[a*b,1]);
    longrd = reshape(longrd,[a*b,1]);
    [in] = inpolygon(latgrd,longrd,latpts,lonpts);
    stalats = latgrd(find(in==1));
    stalons = longrd(find(in==1));
    
elseif option == 3 % sparse grid + two dense lines
    
    latpts = [-19.5,-23.25,-24,-24,-20];
    lonpts = [175.1,175.5,175.35,169,167.75];
    gridsize = 1; % in degrees
    latptsvec = [min(latpts):gridsize:max(latpts)];
    lonptsvec = [min(lonpts):gridsize:max(lonpts)];
    [latgrd,longrd] = meshgrid(latptsvec,lonptsvec);
    [a,b] = size(latgrd);
    latgrd = reshape(latgrd,[a*b,1]);
    longrd = reshape(longrd,[a*b,1]);
    [in] = inpolygon(latgrd,longrd,latpts,lonpts);
    stalatssp = latgrd(find(in==1));
    stalonssp = longrd(find(in==1));
    
    latend = -20;
    lonend = 171.75;
    ninst = 7;
    distint = 25;
    
    % line 1
    latstart = -22;
    lonstart = 169.75;
    az = azimuth(latstart,lonstart,latend,lonend);
    [latline1,lonline1] = reckon(latstart,lonstart,distint/111.*[0:ninst],az);
    
    % line 2
    latstart = -23;
    lonstart = 171.75;
    az = azimuth(latstart,lonstart,latend,lonend);
    [latline2,lonline2] = reckon(latstart,lonstart,distint/111.*[0:ninst],az);
    
    stalats = [stalatssp;latline1';latline2'];
    stalons = [stalonssp;lonline1';lonline2'];

elseif option == 4 % rotated sparse grid
    latend = -24;
    lonend = 169;
    latstart = -19;
    lonstart = 164.5;
    distint = 100;
    az = azimuth(latstart,lonstart,latend,lonend);
    [latline1,lonline1] = reckon(latstart,lonstart,distint/111.*[0:15],az);
    az90 = az-90;
    for ii = 1:length(latline1)
        [latgrd(:,ii),longrd(:,ii)] = reckon(latline1(ii),lonline1(ii),distint/111.*[0:15],az90);
    end
    
    latpts = [-19.1,-19.1,-20,-20.3,-19.7,-23.2,-24.5,-24,-21.6];
    lonpts = [167.05,171.1,171.7,172.8,176,177,173.5,169,167.5];
    gridsize = 1; % in degrees
%     latptsvec = [min(latpts):gridsize:max(latpts)];
%     lonptsvec = [min(lonpts):gridsize:max(lonpts)];
%     [latgrd,longrd] = meshgrid(latptsvec,lonptsvec);
    [a,b] = size(latgrd);
    latgrd = reshape(latgrd,[a*b,1]);
    longrd = reshape(longrd,[a*b,1]);
    [in] = inpolygon(latgrd,longrd,latpts,lonpts);
    stalats = latgrd(find(in==1));
    stalons = longrd(find(in==1));
    
    figure(1)
    plot(stalons,stalats,'ok')
    
    elseif option == 5 % trimmed sparse grid, edge points removed to reduce station total
    % just a copy of stations 4 edited by hand
    
    
elseif option == 6 % sparse grid + dense grid
    outpath1 = './';
    outfile1 = 'stations_5.txt';
    stadataorig = importdata([outpath1,outfile1]);
    stalats_orig = stadataorig.data(:,1);
    stalons_orig = stadataorig.data(:,2);
    
    figure(10); clf
    plot(stalons_orig,stalats_orig,'s','MarkerFaceColor',[1 0 0],'MarkerEdgeColor','k','MarkerSize',7); hold on
    for ii = 1:12
    [x,y] = ginput(1); % for a total of 45 OBS
    plot(x,y,'s','MarkerFaceColor','k','MarkerEdgeColor','r','MarkerSize',7)
    stalon(ii) = x;
    stalat(ii) = y;
    end
    stalons = [stalons_orig;stalon'];
    stalats = [stalats_orig;stalat'];
    
elseif option ==7 % sparse grid + crossing lines
    % volcanoes
volcfile = '/Users/hajanisz/Dropbox/PUBLISHEDDATASETS/SmithsonianVolcano_DB/GVP_Volcano_List_Holocene.txt';
fid = fopen(volcfile);
C = textscan(fid,'%s %s %f %f %f', 'Delimiter','\t');

volclat = C{3};
volclon = C{4};
volcelv = C{5};
names = C{1};

idx = find(volclat<lat(1) | volclat>lat(2));
volclat(idx) = nan;
volclon(idx) = nan;
idx = find(volclon>lon(2) | volclon<lon(1));
volclat(idx) = nan;
volcon(idx) = nan;
    
    outpath1 = './';
    outfile1 = 'stations_5.txt';
    stadataorig = importdata([outpath1,outfile1]);
    stalats_orig = stadataorig.data(:,1);
    stalons_orig = stadataorig.data(:,2);
    
    figure(10); clf
    plot(stalons_orig,stalats_orig,'s','MarkerFaceColor',[1 0 0],'MarkerEdgeColor','k','MarkerSize',7); hold on
    plot(volclon,volclat,'^','MarkerFaceColor',[1 1 1],'MarkerEdgeColor','k','LineWidth',1,'MarkerSize',10)
    for ii = 1:12
    [x,y] = ginput(1); % for a total of 45 OBS
    plot(x,y,'s','MarkerFaceColor','k','MarkerEdgeColor','r','MarkerSize',7)
    stalon(ii) = x;
    stalat(ii) = y;
    end
    stalons = [stalons_orig;stalon'];
    stalats = [stalats_orig;stalat'];

end

%% put together vectors for new stations

for ii = 1:length(stalats)
    [arclen,az] = distance(stalats(ii),stalons(ii),latvec,lonvec);
    [val,idx] = min(arclen);
    staelvs(ii) = elvvec(idx);
end
stanmss = [1:length(stalats)];

%% organizing and writing text file

formatSpec = ('%s %4.2f %5.2f %6.2f\n');
fileID = fopen([outpath,outfile],'w');

for ii = 1:length(stations_info)
    stalat = stations_info(ii).Latitude;
    stalon = stations_info(ii).Longitude;
    staelv = stations_info(ii).Elevation;
    stanms = stations_info(ii).StationCode;
    fprintf(fileID,formatSpec,stanms,stalat,stalon,staelv);
end

for ii = 1:length(stalat2)
    stalat = stalat2(ii);
    stalon = stalon2(ii);
    staelv = staelv2(ii);
    stanms = char(stanms2(ii));
    fprintf(fileID,formatSpec,stanms,stalat,stalon,staelv);
end

for ii = 1:length(stalats)
    stalat = stalats(ii);
    stalon = stalons(ii);
    staelv = staelvs(ii);
    stanms = num2str(stanmss(ii));
    fprintf(fileID,formatSpec,stanms,stalat,stalon,staelv);
end

fclose(fileID);

