clear all
close all

tdiv = 5000; %time increment (each interval is 1/tdiv seconds)
numslots = 5; %# of horizontal slots
numballs = 2*numslots; %# of vertical slots
collChecks = [1.25, 1, .5, .25, .1, .05]; %collision criteria
collChecks = collChecks.*collChecks;
count = zeros(1, length(collChecks)); %# of shots that hit each collision criteria
tSpread = 0; %total spread for hits in seconds
maxDist = max(collChecks);

%runs is # of simulations
for runs = 1:5
    lastColls = zeros(length(collChecks), 3); %track last collision to prevent double counting
    runs
    x = [];
    y = [];
    z = [];
    for g = 1:numballs
        i = 2;
        x(g, 1) = 2*mod(g, numslots) + normrnd(0, .1);
%         if(g == 1)
%             x(g, 1) = 0;
%         else
%             x(g, 1) = floor(5*rand() + 1) + x(g - 1, 1);
%         end
        y(g, 1) = 0;
        %z(g, 1) = 3*floor(g/(numslots + 1));
%         z(g, 1) = 3*mod(x(g, 1), 3);
        z(g, 1) = 0;
        vx = normrnd(0, 12)/tdiv;
        vy = min(65/tdiv, normrnd(50, 8)/tdiv);
        vx = vx*(40/(tdiv*vy)) + normrnd(0, 3)/tdiv;
        vz = vy/7 + normrnd(3, 5)/tdiv;
        acc = 9.8/(tdiv*tdiv); %g adjusted for time division
        wait = tSpread*rand()*tdiv; %wait time before hit
        j = 2;
        while(z(g, j - 1) >= 0)
            if(j > wait)
                x(g, j) = x(g, j - 1) + vx;
                y(g, j) = y(g, j - 1) + vy;
                z(g, j) = z(g, j - 1) + vz;
                vx = vx - (vx*vx*20/tdiv);
                vy = vy - (vy*vy*20/tdiv);
                vz = vz - (vz*vz*20/tdiv) - acc;
            else
                x(g, j) = x(g, j - 1);
                y(g, j) = y(g, j - 1);
                z(g, j) = z(g, j - 1);
            end
            j = j + 1;
        end
    end
    
    %step through each ball's path in 10 ms increments...since balls are
    %moving at <100 m/s and trigger for more precision is >1 m, this will
    %not miss any collsions
    minDist = 100000;
    for i = 1:numballs
        for j = (i + 1):numballs
            k = 1500;
            kinc = 50;
            while((k < length(x)))
                if(x(i, k) == 0)
                elseif(x(j, k) == 0)
                else
                    dist = power(x(i, k) - x(j, k), 2) + power(y(i, k) - y(j, k), 2) + power(z(i, k) - z(j, k), 2);
                    
                    %if possible collsion, improve resolution to 200 us
                    %increments
                    if(dist < maxDist)
                        for m = (k - 100):(k + 100)
                            
                            %check all collision criteria
                            for c = 1:length(collChecks)
                                if(dist < collChecks(c))
                                    try
                                        temp = [i, j, m] - lastColls(c, :);
                                    catch
                                        temp = [1, 1, 1];
                                    end
                                    
                                    %only count collision if first with
                                    %these two
                                    if((temp(1) ~= 0) || (temp(2) ~= 0))
                                        count(c) = count(c) + 1;
                                        lastColls(c, :) = [i, j, m];
                                    end
                                end
                            end
                        end
                    end
                    if(dist < minDist)
                        minDist = dist;
                    end
                end
                k = k + kinc;
            end
        end
    end
    result(runs) = minDist;
end

% for i = 1:numballs
%     figure(1)
%     scatter3(x(i, :), y(i, :), z(i, :))
%     xlabel('width')
%     ylabel('distance')
%     zlabel('height')
%     hold on
% end
% view(30, 30)
% view(90, 0)

for i = 1:numballs
    figure(1)
    scatter(y(i, :), z(i, :))
    xlabel('distance', 'fontsize', 14)
    ylabel('height', 'fontsize', 14)
    set(gca, 'Fontsize', 14)
    hold on
end

for i = 1:numballs
    figure(2)
    scatter(x(i, :), y(i, :))
    xlabel('horizontal spread', 'fontsize', 14)
    ylabel('distance','fontsize', 14)
    set(gca, 'Fontsize', 14)
    hold on
end

for i = 1:numballs
    figure(3)
    plot(y(i, :))
    hold on
end
