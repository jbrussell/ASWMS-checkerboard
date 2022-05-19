% Trace travel times through synthetic phase velocity map creating synthetic
% CSmeasure dataset with mostly dummy variables.
%
clear;

setup_parameters;

evfile = './events.txt'; % text file containing earthquakes [evid, lat, lon, depth]
fname_checker = [parameters.workingdir,'/checker.mat']; % path to checkerboard map

workingdir = parameters.workingdir;
CSoutputpath = [workingdir,'/CSmeasure/'];
if ~exist(CSoutputpath)
    mkdir(CSoutputpath)
end
lalim=parameters.lalim;
lolim=parameters.lolim;
periods = parameters.periods;
component = parameters.component;

% Read event info
[evlist, evlats, evlons, evdeps] = textread(evfile,'%s %f %f %f');

% Read checkboard map
temp = load(fname_checker);
checker = temp.checker;
xi = checker(1).xi;
yi = checker(1).yi;
xnode = xi(1:end,1)';
ynode = yi(1,1:end);

for ie = 1:length(evlist)
    eventcs = [];
    dists = [];
    evid = evlist{ie};
    evla = evlats(ie);
    evlo = evlons(ie);
    evdp = evdeps(ie);
    disp(['Working on ',evid]);
    % Calculate epicentral distances
    for ista = 1:length(stlat)
        dists(ista) = vdist(evla,evlo,stlat(ista),stlon(ista))/1000;
    end
    
    % Trace rays for each station
    CS = [];
    ipair = 0;
    for ista1 = 1:length(stalist)
        sta1 = stalist{ista1};
        for ista2 = ista1:length(stalist)
            sta2 = stalist{ista2};
            if strcmp(sta1,sta2)
                continue
            end
            ipair = ipair + 1;
            
            % Epicentral distance difference
            ddist = dists(ista1)-dists(ista2);
            
            % Trace traveltime through checkerboard map
            lat1 = stlat(ista1);
            lon1 = stlon(ista1);
            lat2 = stlat(ista2);
            lon2 = stlon(ista2);
            [r, ~] = distance(lat1,lon1,lat2,lon2,referenceEllipsoid('GRS80'));
            dr = deg2km(mean(diff(xnode)));
            Nr = floor(r/dr);
            [lat_way,lon_way] = gcwaypts(lat1,lon1,lat2,lon2,Nr);
            dtp = [];
            for ip = 1:length(periods)
                phv = checker(ip).phv;
                phv_path = interp2(yi,xi,phv,lon_way,lat_way);
%                 dtp(ip) = ddist ./ mean(phv_path(:));
                dtp(ip) = ddist .* mean(1./phv_path(:));
%                 disp(num2str(mean(phv_path(:))));
            end
            
%             % Trace traveltime through checkerboard map
%             lat1 = stlat(ista1);
%             lon1 = stlon(ista1);
%             lat2 = stlat(ista2);
%             lon2 = stlon(ista2);
%             ray = [lat1, lon1, lat2, lon2];
% 
%             G = kernel_build(ray, xnode, ynode);
%             Gmatx = [];
%             Gmaty = [];
%             for ii=1:length(xnode)
%                 for jj=1:length(ynode)
%                     n=length(ynode)*(ii-1)+jj;
%                     Gmatx(ii,jj) = sum(G(:,2*n-1));
%                     Gmaty(ii,jj) = sum(G(:,2*n));
%                 end
%             end
%             Gmat = sqrt(Gmatx.^2 + Gmaty.^2);
%             [~, sta_azi] = distance(lat1,lon1,lat2,lon2,referenceEllipsoid('GRS80'));
%             [~, ev_azi] = distance(xi,yi,evla,evlo,referenceEllipsoid('GRS80'));
%             % Rotate Gmat to Radial-transverse
%             GmatRT = Gmat.*cosd(sta_azi-ev_azi);
%             dtp = [];
%             for ip = 1:length(periods)
%                 phv = checker(ip).phv;
%                 slowness = 1./phv;
%                 dtp(ip) = sum(GmatRT(:).*slowness(:));
%             end
            
            CS(ipair).sta1 = ista1;
            CS(ipair).sta2 = ista2;
            CS(ipair).win_cent_t = [];
            CS(ipair).ddist = ddist;
            CS(ipair).fitpara = [];
            CS(ipair).fiterr = zeros(size(periods));
            CS(ipair).dtp = dtp; % interstation phase delay time (travel time)
            CS(ipair).dtg = nan(size(periods));
            CS(ipair).amp = nan(size(periods));
            CS(ipair).dtg = nan(size(periods));
            CS(ipair).w = periods/2/pi;
            CS(ipair).sigma = nan(size(periods));
            CS(ipair).exitflag = ones(size(periods));
            CS(ipair).cohere = 0.99 * ones(size(periods));
            CS(ipair).isgood = true(size(periods));
        end
    end
    
    eventcs.CS = CS;
    eventcs.autocor = [];
    eventcs.id = evid;
    eventcs.avgphv = parameters.refv * ones(size(periods));
    eventcs.stlas = stlat;
    eventcs.stlos = stlon;
    eventcs.stnms = stalist';
    eventcs.evla = evla;
    eventcs.evlo = evlo;
    eventcs.evdp = evdp;
    eventcs.dists = dists;
    eventcs.eventmatfile = '';
    eventcs.Mw = nan;
    
    save([CSoutputpath,'/',evid,'_cs_',component,'.mat'],'eventcs');
end
